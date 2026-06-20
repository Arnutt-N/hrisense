-- ============================================================================
-- HRiSENSE Migration 010: Database Functions
-- ============================================================================

-- ============================================================================
-- 1. calculate_personnel_risk_score(personnel_id UUID)
-- Computes individual risk scores for retirement, transfer, talent, vacancy
-- Returns composite risk score and updates personnel_risk_scores table
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_personnel_risk_score(p_personnel_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_retirement_risk NUMERIC(5,2) := 0;
  v_transfer_risk NUMERIC(5,2) := 0;
  v_talent_risk NUMERIC(5,2) := 0;
  v_vacancy_risk NUMERIC(5,2) := 0;
  v_competency_risk NUMERIC(5,2) := 0;
  v_succession_risk NUMERIC(5,2) := 0;
  v_overall NUMERIC(5,2);
  v_risk_level risk_level;
  v_years_remaining NUMERIC(4,1);
  v_is_critical BOOLEAN;
  v_has_successor BOOLEAN;
  v_result JSONB;
BEGIN
  -- 1. Retirement risk: based on years until retirement
  -- 0-2 years = 100, 2-5 = 75, 5-10 = 40, 10+ = 10
  SELECT
    EXTRACT(YEAR FROM (birth_date + INTERVAL '60 years')) - EXTRACT(YEAR FROM CURRENT_DATE)
    + CASE
        WHEN EXTRACT(DOY FROM (birth_date + INTERVAL '60 years')) < EXTRACT(DOY FROM CURRENT_DATE)
        THEN -1 ELSE 0
      END
  INTO v_years_remaining
  FROM personnel WHERE id = p_personnel_id;

  IF v_years_remaining IS NULL THEN
    RETURN '{"error": "personnel not found"}'::jsonb;
  ELSIF v_years_remaining <= 0 THEN
    v_retirement_risk := 100;
  ELSIF v_years_remaining <= 2 THEN
    v_retirement_risk := 90;
  ELSIF v_years_remaining <= 5 THEN
    v_retirement_risk := 70;
  ELSIF v_years_remaining <= 10 THEN
    v_retirement_risk := 40;
  ELSE
    v_retirement_risk := 10;
  END IF;

  -- 2. Transfer risk: based on transfer history frequency
  -- More transfers in last 5 years = higher risk
  SELECT COUNT(*) * 15
  INTO v_transfer_risk
  FROM transfer_records
  WHERE personnel_id = p_personnel_id
  AND effective_date >= CURRENT_DATE - INTERVAL '5 years';
  v_transfer_risk := LEAST(v_transfer_risk, 100);

  -- 3. Talent loss risk: combination of high performance + near retirement + critical position
  -- Check if has excellent recent evaluations
  DECLARE
    v_avg_eval_score NUMERIC(5,2);
    v_eval_count INTEGER;
  BEGIN
    SELECT AVG(overall_score), COUNT(*)
    INTO v_avg_eval_score, v_eval_count
    FROM performance_evaluations
    WHERE personnel_id = p_personnel_id
    AND evaluation_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 2;

    IF v_eval_count > 0 AND v_avg_eval_score >= 4.0 THEN
      v_talent_risk := v_talent_risk + 30; -- high performer
    END IF;
  END;

  -- Check if in critical position
  SELECT COALESCE(pos.is_critical, false)
  INTO v_is_critical
  FROM personnel p
  LEFT JOIN positions pos ON p.current_position_id = pos.id
  WHERE p.id = p_personnel_id;

  IF v_is_critical THEN
    v_talent_risk := v_talent_risk + 40;
  END IF;

  -- Factor in retirement proximity for talent risk
  IF v_years_remaining <= 5 AND v_years_remaining > 0 THEN
    v_talent_risk := v_talent_risk + 20;
  END IF;
  v_talent_risk := LEAST(v_talent_risk, 100);

  -- 4. Vacancy risk: if position has no occupants and quota > 0
  SELECT
    CASE
      WHEN pos.id IS NULL THEN 0
      WHEN pos.current_occupancy = 0 AND pos.quota > 0 THEN 90
      WHEN pos.current_occupancy < pos.quota THEN 40
      ELSE 0
    END
  INTO v_vacancy_risk
  FROM personnel p
  LEFT JOIN positions pos ON p.current_position_id = pos.id
  WHERE p.id = p_personnel_id;

  -- 5. Succession risk: if in critical position with no ready successor
  IF v_is_critical THEN
    SELECT EXISTS(
      SELECT 1 FROM succession_plans sp
      JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
      WHERE sp.position_id = (SELECT current_position_id FROM personnel WHERE id = p_personnel_id)
      AND spc.readiness IN ('ready_now', 'ready_1_2_years')
    ) INTO v_has_successor;

    IF NOT v_has_successor THEN
      v_succession_risk := 80;
    ELSE
      v_succession_risk := 20;
    END IF;
  END IF;

  -- 6. Competency gap risk: based on training gaps
  SELECT COUNT(*) * 10
  INTO v_competency_risk
  FROM individual_development_plans
  WHERE personnel_id = p_personnel_id
  AND plan_status IN ('draft', 'in_progress')
  AND target_completion_date < CURRENT_DATE;
  v_competency_risk := LEAST(v_competency_risk, 100);

  -- Calculate weighted overall score
  v_overall := (
    v_retirement_risk * 0.25 +
    v_transfer_risk * 0.10 +
    v_talent_risk * 0.20 +
    v_vacancy_risk * 0.15 +
    v_competency_risk * 0.10 +
    v_succession_risk * 0.20
  );

  -- Determine risk level
  IF v_overall >= 75 THEN
    v_risk_level := 'critical';
  ELSIF v_overall >= 50 THEN
    v_risk_level := 'red';
  ELSIF v_overall >= 25 THEN
    v_risk_level := 'amber';
  ELSE
    v_risk_level := 'green';
  END IF;

  -- Upsert personnel_risk_scores
  INSERT INTO personnel_risk_scores (
    personnel_id, retirement_risk, transfer_risk, talent_loss_risk,
    vacancy_risk, competency_gap_risk, succession_risk,
    overall_score, risk_level, computed_at
  ) VALUES (
    p_personnel_id, v_retirement_risk, v_transfer_risk, v_talent_risk,
    v_vacancy_risk, v_competency_risk, v_succession_risk,
    v_overall, v_risk_level, NOW()
  )
  ON CONFLICT (personnel_id) DO UPDATE SET
    retirement_risk = EXCLUDED.retirement_risk,
    transfer_risk = EXCLUDED.transfer_risk,
    talent_loss_risk = EXCLUDED.talent_loss_risk,
    vacancy_risk = EXCLUDED.vacancy_risk,
    competency_gap_risk = EXCLUDED.competency_gap_risk,
    succession_risk = EXCLUDED.succession_risk,
    overall_score = EXCLUDED.overall_score,
    risk_level = EXCLUDED.risk_level,
    computed_at = NOW(),
    updated_at = NOW();

  -- Update personnel table
  UPDATE personnel SET
    retirement_years_remaining = v_years_remaining,
    overall_risk_score = v_overall,
    risk_level = v_risk_level,
    updated_at = NOW()
  WHERE id = p_personnel_id;

  -- Return result
  v_result := jsonb_build_object(
    'personnel_id', p_personnel_id,
    'retirement_risk', v_retirement_risk,
    'transfer_risk', v_transfer_risk,
    'talent_loss_risk', v_talent_risk,
    'vacancy_risk', v_vacancy_risk,
    'competency_gap_risk', v_competency_risk,
    'succession_risk', v_succession_risk,
    'overall_score', v_overall,
    'risk_level', v_risk_level,
    'years_to_retirement', v_years_remaining
  );

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 2. calculate_org_risk_summary(org_id UUID)
-- Aggregates risk metrics for an entire organization
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_org_risk_summary(p_org_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_total_personnel INTEGER;
  v_total_quota INTEGER;
  v_total_positions INTEGER;
  v_vacancy_count INTEGER;
  v_vacancy_rate NUMERIC(5,2);
  v_retirements_1yr INTEGER;
  v_retirements_3yr INTEGER;
  v_retirements_5yr INTEGER;
  v_avg_retirement NUMERIC(5,2);
  v_avg_transfer NUMERIC(5,2);
  v_avg_talent NUMERIC(5,2);
  v_overall NUMERIC(5,2);
  v_risk_level risk_level;
  v_critical_positions INTEGER;
  v_no_successor INTEGER;
  v_result JSONB;
  v_today DATE := CURRENT_DATE;
BEGIN
  -- Headcount metrics
  SELECT COUNT(*) INTO v_total_personnel
  FROM personnel WHERE organization_id = p_org_id AND status = 'active';

  SELECT COALESCE(SUM(quota), 0) INTO v_total_quota
  FROM positions WHERE organization_id = p_org_id AND is_active = true;

  SELECT COUNT(*) INTO v_total_positions
  FROM positions WHERE organization_id = p_org_id AND is_active = true;

  SELECT v_total_quota - v_total_personnel INTO v_vacancy_count;
  v_vacancy_count := GREATEST(v_vacancy_count, 0);

  IF v_total_quota > 0 THEN
    v_vacancy_rate := ROUND((v_vacancy_count::NUMERIC / v_total_quota) * 100, 2);
  ELSE
    v_vacancy_rate := 0;
  END IF;

  -- Retirement forecasts
  SELECT
    COUNT(*) FILTER (WHERE retirement_date <= v_today + INTERVAL '1 year'),
    COUNT(*) FILTER (WHERE retirement_date <= v_today + INTERVAL '3 years'),
    COUNT(*) FILTER (WHERE retirement_date <= v_today + INTERVAL '5 years')
  INTO v_retirements_1yr, v_retirements_3yr, v_retirements_5yr
  FROM personnel
  WHERE organization_id = p_org_id AND status = 'active';

  -- Average risk scores from personnel_risk_scores
  SELECT
    COALESCE(AVG(retirement_risk), 0),
    COALESCE(AVG(transfer_risk), 0),
    COALESCE(AVG(talent_loss_risk), 0)
  INTO v_avg_retirement, v_avg_transfer, v_avg_talent
  FROM personnel_risk_scores prs
  JOIN personnel p ON p.id = prs.personnel_id
  WHERE p.organization_id = p_org_id AND p.status = 'active';

  -- Succession coverage
  SELECT COUNT(*) INTO v_critical_positions
  FROM positions
  WHERE organization_id = p_org_id AND is_critical = true AND is_active = true;

  SELECT COUNT(*) INTO v_no_successor
  FROM positions pos
  WHERE pos.organization_id = p_org_id AND pos.is_critical = true AND pos.is_active = true
  AND NOT EXISTS (
    SELECT 1 FROM succession_plans sp
    JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
    WHERE sp.position_id = pos.id AND spc.readiness IN ('ready_now', 'ready_1_2_years')
  );

  -- Overall org risk (weighted composite)
  v_overall := (
    v_avg_retirement * 0.25 +
    v_avg_transfer * 0.10 +
    v_avg_talent * 0.20 +
    LEAST(v_vacancy_rate * 2, 100) * 0.15 +
    CASE WHEN v_critical_positions > 0
      THEN (v_no_successor::NUMERIC / v_critical_positions) * 100
      ELSE 0
    END * 0.30
  );

  IF v_overall >= 75 THEN v_risk_level := 'critical';
  ELSIF v_overall >= 50 THEN v_risk_level := 'red';
  ELSIF v_overall >= 25 THEN v_risk_level := 'amber';
  ELSE v_risk_level := 'green';
  END IF;

  -- Upsert org risk summary
  INSERT INTO organization_risk_summary (
    organization_id, total_personnel, total_positions, total_quota,
    vacancy_count, vacancy_rate, retirements_1yr, retirements_3yr,
    retirements_5yr, avg_retirement_risk, avg_transfer_risk,
    avg_talent_risk, overall_risk_score, risk_level,
    critical_positions, positions_without_successor,
    computed_at
  ) VALUES (
    p_org_id, v_total_personnel, v_total_positions, v_total_quota,
    v_vacancy_count, v_vacancy_rate, v_retirements_1yr, v_retirements_3yr,
    v_retirements_5yr, v_avg_retirement, v_avg_transfer,
    v_avg_talent, v_overall, v_risk_level,
    v_critical_positions, v_no_successor,
    NOW()
  )
  ON CONFLICT (organization_id, snapshot_date) DO UPDATE SET
    total_personnel = EXCLUDED.total_personnel,
    total_positions = EXCLUDED.total_positions,
    total_quota = EXCLUDED.total_quota,
    vacancy_count = EXCLUDED.vacancy_count,
    vacancy_rate = EXCLUDED.vacancy_rate,
    retirements_1yr = EXCLUDED.retirements_1yr,
    retirements_3yr = EXCLUDED.retirements_3yr,
    retirements_5yr = EXCLUDED.retirements_5yr,
    avg_retirement_risk = EXCLUDED.avg_retirement_risk,
    avg_transfer_risk = EXCLUDED.avg_transfer_risk,
    avg_talent_risk = EXCLUDED.avg_talent_risk,
    overall_risk_score = EXCLUDED.overall_risk_score,
    risk_level = EXCLUDED.risk_level,
    critical_positions = EXCLUDED.critical_positions,
    positions_without_successor = EXCLUDED.positions_without_successor,
    computed_at = NOW(),
    updated_at = NOW();

  v_result := jsonb_build_object(
    'organization_id', p_org_id,
    'total_personnel', v_total_personnel,
    'vacancy_rate', v_vacancy_rate,
    'retirements_1yr', v_retirements_1yr,
    'retirements_3yr', v_retirements_3yr,
    'retirements_5yr', v_retirements_5yr,
    'overall_risk_score', v_overall,
    'risk_level', v_risk_level,
    'critical_positions', v_critical_positions,
    'positions_without_successor', v_no_successor
  );

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 3. forecast_retirements(org_id UUID, years_ahead INTEGER)
-- Returns personnel projected to retire within N years
-- ============================================================================
CREATE OR REPLACE FUNCTION forecast_retirements(
  p_org_id UUID DEFAULT NULL,
  p_years_ahead INTEGER DEFAULT 5
)
RETURNS TABLE (
  personnel_id UUID,
  full_name_th TEXT,
  organization_id UUID,
  organization_name_th TEXT,
  position_name_th TEXT,
  position_level_th TEXT,
  birth_date DATE,
  retirement_date DATE,
  years_remaining NUMERIC,
  is_critical_position BOOLEAN,
  has_successor BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id AS personnel_id,
    (p.prefix_th || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
    p.organization_id,
    o.name_th AS organization_name_th,
    pos.name_th AS position_name_th,
    pl.name_th AS position_level_th,
    p.birth_date,
    (p.birth_date + INTERVAL '60 years')::DATE AS retirement_date,
    ROUND(
      EXTRACT(YEAR FROM (p.birth_date + INTERVAL '60 years')) - EXTRACT(YEAR FROM CURRENT_DATE)
      + CASE
          WHEN EXTRACT(DOY FROM (p.birth_date + INTERVAL '60 years')) < EXTRACT(DOY FROM CURRENT_DATE)
          THEN -1 ELSE 0
        END,
      1
    ) AS years_remaining,
    COALESCE(pos.is_critical, false) AS is_critical_position,
    EXISTS(
      SELECT 1 FROM succession_plans sp
      JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
      WHERE sp.position_id = p.current_position_id
      AND spc.readiness IN ('ready_now', 'ready_1_2_years')
    ) AS has_successor
  FROM personnel p
  JOIN organizations o ON o.id = p.organization_id
  LEFT JOIN positions pos ON pos.id = p.current_position_id
  LEFT JOIN position_levels pl ON pl.id = p.position_level_id
  WHERE p.status = 'active'
    AND (p.organization_id = p_org_id OR p_org_id IS NULL)
    AND (p.birth_date + INTERVAL '60 years') <= CURRENT_DATE + (p_years_ahead || ' years')::INTERVAL
  ORDER BY retirement_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 4. get_vacancy_rate(org_id UUID)
-- Returns vacancy rate for an organization
-- ============================================================================
CREATE OR REPLACE FUNCTION get_vacancy_rate(p_org_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_quota INTEGER;
  v_filled INTEGER;
  v_vacancy INTEGER;
  v_rate NUMERIC(5,2);
BEGIN
  SELECT COALESCE(SUM(quota), 0) INTO v_quota
  FROM positions WHERE organization_id = p_org_id AND is_active = true;

  SELECT COUNT(*) INTO v_filled
  FROM personnel p
  JOIN positions pos ON pos.id = p.current_position_id
  WHERE p.organization_id = p_org_id
  AND p.status = 'active'
  AND pos.is_active = true;

  v_vacancy := GREATEST(v_quota - v_filled, 0);

  IF v_quota > 0 THEN
    v_rate := ROUND((v_vacancy::NUMERIC / v_quota) * 100, 2);
  ELSE
    v_rate := 0;
  END IF;

  RETURN jsonb_build_object(
    'organization_id', p_org_id,
    'quota', v_quota,
    'filled', v_filled,
    'vacancy', v_vacancy,
    'vacancy_rate', v_rate
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 5. recalculate_all_risks()
-- Batch recalculation for all active personnel
-- ============================================================================
CREATE OR REPLACE FUNCTION recalculate_all_risks()
RETURNS JSONB AS $$
DECLARE
  v_count INTEGER := 0;
  v_personnel RECORD;
BEGIN
  FOR v_personnel IN
    SELECT id FROM personnel WHERE status = 'active'
  LOOP
    PERFORM calculate_personnel_risk_score(v_personnel.id);
    v_count := v_count + 1;
  END LOOP;

  -- Recalculate org summaries
  DECLARE
    v_org RECORD;
  BEGIN
    FOR v_org IN
      SELECT DISTINCT organization_id FROM personnel WHERE status = 'active'
    LOOP
      PERFORM calculate_org_risk_summary(v_org.organization_id);
    END LOOP;
  END;

  RETURN jsonb_build_object('personnel_processed', v_count, 'completed_at', NOW());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 6. update_position_occupancy()
-- Trigger function to update position occupancy counts
-- ============================================================================
CREATE OR REPLACE FUNCTION update_position_occupancy()
RETURNS TRIGGER AS $$
BEGIN
  -- Decrement old position
  IF TG_OP = 'DELETE' OR TG_OP = 'UPDATE' THEN
    UPDATE positions
    SET current_occupancy = GREATEST(current_occupancy - 1, 0)
    WHERE id = OLD.position_id;
  END IF;

  -- Increment new position
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    IF NEW.is_current = true THEN
      UPDATE positions
      SET current_occupancy = current_occupancy + 1
      WHERE id = NEW.position_id;
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. generate_audit_log()
-- Trigger function for audit logging
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_audit_log()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_email VARCHAR(255);
  v_role VARCHAR(50);
  v_old JSONB;
  v_new JSONB;
  v_changed TEXT[];
BEGIN
  v_user_id := auth.uid();

  SELECT au.email, p.role INTO v_email, v_role
  FROM profiles p
  LEFT JOIN auth.users au ON au.id = p.id
  WHERE p.id = v_user_id;

  IF TG_OP = 'INSERT' THEN
    v_new := to_jsonb(NEW);
    v_changed := ARRAY(SELECT jsonb_object_keys(v_new));
  ELSIF TG_OP = 'UPDATE' THEN
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
    v_changed := ARRAY(
      SELECT key FROM jsonb_each(v_new)
      WHERE v_old->key IS DISTINCT FROM v_new->key
    );
  ELSIF TG_OP = 'DELETE' THEN
    v_old := to_jsonb(OLD);
  END IF;

  INSERT INTO audit_logs (
    user_id, user_email, user_role,
    action, table_name, record_id,
    old_values, new_values, changed_fields
  ) VALUES (
    v_user_id, v_email, v_role,
    TG_OP, TG_TABLE_NAME, COALESCE(NEW.id, OLD.id),
    v_old, v_new, v_changed
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. check_and_create_alerts()
-- Trigger function: check alert rules and create alerts
-- ============================================================================
CREATE OR REPLACE FUNCTION check_and_create_alerts()
RETURNS TRIGGER AS $$
DECLARE
  v_rule RECORD;
  v_value NUMERIC;
  v_threshold NUMERIC;
  v_breached BOOLEAN := false;
  v_title TEXT;
  v_message TEXT;
BEGIN
  -- Check all active alert rules
  FOR v_rule IN
    SELECT * FROM alert_rules WHERE is_active = true
    AND (last_triggered_at IS NULL OR last_triggered_at < NOW() - (cooldown_minutes || ' minutes')::INTERVAL)
  LOOP
    v_breached := false;

    -- Check based on scope
    IF v_rule.scope_type = 'organization' AND NEW.organization_id IS NOT NULL THEN
      -- Check org-level indicators
      IF v_rule.condition_config->>'metric' = 'vacancy_rate' THEN
        SELECT vacancy_rate INTO v_value
        FROM organization_risk_summary
        WHERE organization_id = NEW.organization_id
        AND snapshot_date = CURRENT_DATE;

        v_threshold := (v_rule.condition_config->>'value')::NUMERIC;
        IF v_value >= v_threshold THEN v_breached := true; END IF;
      END IF;
    END IF;

    IF v_breached AND v_rule.scope_organization_id = NEW.organization_id THEN
      v_title := format('Alert: %s', v_rule.name);
      v_message := format('Threshold breached for %s. Value: %s, Threshold: %s',
        v_rule.condition_config->>'metric', v_value, v_threshold);

      INSERT INTO alerts (
        alert_rule_id, severity, title, message,
        organization_id, indicator_value, threshold_value, status
      ) VALUES (
        v_rule.id, v_rule.severity, v_title, v_message,
        NEW.organization_id, v_value, v_threshold, 'active'
      );

      UPDATE alert_rules SET last_triggered_at = NOW() WHERE id = v_rule.id;
    END IF;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;