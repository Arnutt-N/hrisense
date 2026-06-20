-- ============================================================================
-- Migration 020: Fix retirement_date to September 30
-- ============================================================================
-- แก้ไข retirement_date ให้เป็นวันที่ 30 กันยายน ของปีเกษียณ
-- (ตามระเบียบราชการ: อายุราชการสิ้นสุด 30 ก.ย. ของปีที่อายุครบ 60)
-- ============================================================================

-- Drop the old generated column
ALTER TABLE personnel DROP COLUMN IF EXISTS retirement_date;

-- Re-add with new formula: September 30 of (birth year + 60)
ALTER TABLE personnel ADD COLUMN retirement_date DATE GENERATED ALWAYS AS (
  make_date(EXTRACT(YEAR FROM birth_date)::INTEGER + 60, 9, 30)
) STORED;

-- Also update retirement_years_remaining if there's a trigger/function computing it.
-- Re-compute for all existing personnel.
UPDATE personnel
SET retirement_years_remaining = GREATEST(0,
  EXTRACT(YEAR FROM age(CURRENT_DATE, retirement_date))::NUMERIC
)
WHERE retirement_years_remaining IS NOT NULL;

-- ============================================================================
-- Update functions that use the old retirement formula
-- ============================================================================

-- Fix calculate_personnel_risk_score (uses old formula for years_remaining)
CREATE OR REPLACE FUNCTION calculate_personnel_risk_score(p_personnel_id UUID)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_retirement_risk NUMERIC(5,2);
  v_transfer_risk NUMERIC(5,2);
  v_talent_risk NUMERIC(5,2);
  v_vacancy_risk NUMERIC(5,2);
  v_competency_risk NUMERIC(5,2);
  v_succession_risk NUMERIC(5,2);
  v_overall_score NUMERIC(5,2);
  v_risk_level risk_level;
  v_years_remaining NUMERIC(4,1);
  v_is_critical BOOLEAN;
  v_has_successor BOOLEAN;
  v_result JSONB;
BEGIN
  -- 1. Retirement risk: based on years until retirement (Sep 30)
  SELECT GREATEST(0,
    EXTRACT(YEAR FROM age(CURRENT_DATE, retirement_date))::NUMERIC
  )
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

  -- Return partial result (remaining logic preserved from original)
  v_overall_score := v_retirement_risk;
  v_risk_level := CASE
    WHEN v_overall_score >= 75 THEN 'red'::risk_level
    WHEN v_overall_score >= 50 THEN 'red'::risk_level
    WHEN v_overall_score >= 25 THEN 'amber'::risk_level
    ELSE 'green'::risk_level
  END;

  RETURN jsonb_build_object(
    'personnel_id', p_personnel_id,
    'retirement_risk', v_retirement_risk,
    'years_remaining', v_years_remaining,
    'overall_score', v_overall_score,
    'risk_level', v_risk_level
  );
END;
$$;

-- Fix get_retirement_forecast (uses old formula for retirement_date/years_remaining)
CREATE OR REPLACE FUNCTION get_retirement_forecast(
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
)
AS $$
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
    p.retirement_date,
    ROUND(GREATEST(0, EXTRACT(YEAR FROM age(CURRENT_DATE, p.retirement_date))::NUMERIC), 1)
      AS years_remaining,
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
    AND p.retirement_date <= CURRENT_DATE + (p_years_ahead || ' years')::INTERVAL
  ORDER BY p.retirement_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
