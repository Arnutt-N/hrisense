-- ============================================================================
-- HRiSENSE Migration 013: Dashboard & Reporting Views
-- ============================================================================

-- ============================================================================
-- 1. v_personnel_overview: Main personnel listing with all related data
-- ============================================================================
CREATE OR REPLACE VIEW v_personnel_overview AS
SELECT
  p.id,
  p.citizen_id,
  p.employee_number,
  p.prefix_th,
  p.first_name_th,
  p.last_name_th,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
  p.prefix_en,
  p.first_name_en,
  p.last_name_en,
  (COALESCE(p.prefix_en, '') || COALESCE(p.first_name_en, '') || ' ' || COALESCE(p.last_name_en, '')) AS full_name_en,
  p.birth_date,
  p.birth_date_be,
  p.government_start_date,
  p.position_appointment_date,
  p.retirement_date,
  p.retirement_years_remaining,
  -- Organization
  p.organization_id,
  o.name_th AS organization_name,
  o.abbreviation_th AS org_abbreviation,
  o.level AS org_level,
  o.parent_id AS parent_org_id,
  -- Position
  p.current_position_id,
  pos.name_th AS position_name,
  pos.position_code,
  pos.is_critical AS is_critical_position,
  -- Classification
  pt.name_th AS position_type,
  pt.code AS position_type_code,
  pl.name_th AS position_level,
  pl.c_level,
  pf.name_th AS position_family,
  -- Employment
  p.salary,
  p.salary_step,
  -- Education
  p.education_level,
  p.degree_name,
  p.university,
  p.major,
  -- Contact
  p.email,
  p.mobile,
  -- Status
  p.status,
  p.gender,
  -- Risk
  p.overall_risk_score,
  p.risk_level,
  prs.retirement_risk,
  prs.transfer_risk,
  prs.talent_loss_risk,
  prs.vacancy_risk,
  prs.succession_risk
FROM personnel p
JOIN organizations o ON o.id = p.organization_id
LEFT JOIN positions pos ON pos.id = p.current_position_id
LEFT JOIN position_types pt ON pt.id = p.position_type_id
LEFT JOIN position_levels pl ON pl.id = p.position_level_id
LEFT JOIN position_families pf ON pf.id = p.position_family_id
LEFT JOIN personnel_risk_scores prs ON prs.personnel_id = p.id;

-- ============================================================================
-- 2. v_org_dashboard: Organization-level dashboard data
-- ============================================================================
CREATE OR REPLACE VIEW v_org_dashboard AS
SELECT
  o.id AS organization_id,
  o.org_code,
  o.name_th,
  o.abbreviation_th,
  o.level AS org_level,
  o.parent_id,
  COALESCE(parent_o.name_th, '') AS parent_org_name,
  -- Headcount
  ors.total_personnel,
  ors.total_quota,
  ors.vacancy_count,
  ors.vacancy_rate,
  -- Risk
  ors.overall_risk_score,
  ors.risk_level,
  ors.avg_retirement_risk,
  ors.avg_transfer_risk,
  ors.avg_talent_risk,
  -- Retirement
  ors.retirements_1yr,
  ors.retirements_3yr,
  ors.retirements_5yr,
  ors.retirement_rate_3yr,
  -- Succession
  ors.critical_positions,
  ors.positions_without_successor,
  ors.succession_coverage_rate,
  -- Computed
  ors.snapshot_date,
  ors.computed_at
FROM organizations o
LEFT JOIN organization_risk_summary ors ON ors.organization_id = o.id
  AND ors.snapshot_date = CURRENT_DATE
LEFT JOIN organizations parent_o ON parent_o.id = o.parent_id
WHERE o.is_active = true;

-- ============================================================================
-- 3. v_retirement_timeline: Personnel approaching retirement
-- ============================================================================
CREATE OR REPLACE VIEW v_retirement_timeline AS
SELECT
  p.id AS personnel_id,
  p.employee_number,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
  p.birth_date,
  p.retirement_date,
  p.retirement_years_remaining,
  p.organization_id,
  o.name_th AS organization_name,
  pos.name_th AS position_name,
  pl.name_th AS position_level,
  pos.is_critical AS is_critical_position,
  CASE
    WHEN p.retirement_years_remaining <= 0 THEN 'already_retired'
    WHEN p.retirement_years_remaining <= 1 THEN 'within_1_year'
    WHEN p.retirement_years_remaining <= 2 THEN 'within_2_years'
    WHEN p.retirement_years_remaining <= 3 THEN 'within_3_years'
    WHEN p.retirement_years_remaining <= 5 THEN 'within_5_years'
    ELSE 'over_5_years'
  END AS retirement_bucket,
  -- Succession status
  CASE
    WHEN EXISTS(
      SELECT 1 FROM succession_plans sp
      JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
      WHERE sp.position_id = p.current_position_id
      AND spc.readiness = 'ready_now'
    ) THEN true ELSE false
  END AS has_ready_successor,
  CASE
    WHEN EXISTS(
      SELECT 1 FROM succession_plans sp
      JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
      WHERE sp.position_id = p.current_position_id
      AND spc.readiness IN ('ready_now', 'ready_1_2_years')
    ) THEN true ELSE false
  END AS has_near_successor
FROM personnel p
JOIN organizations o ON o.id = p.organization_id
LEFT JOIN positions pos ON pos.id = p.current_position_id
LEFT JOIN position_levels pl ON pl.id = p.position_level_id
WHERE p.status = 'active'
ORDER BY p.retirement_date ASC;

-- ============================================================================
-- 4. v_vacancy_analysis: Position vacancy analysis
-- ============================================================================
CREATE OR REPLACE VIEW v_vacancy_analysis AS
SELECT
  pos.id AS position_id,
  pos.position_code,
  pos.name_th AS position_name,
  pos.organization_id,
  o.name_th AS organization_name,
  pt.name_th AS position_type,
  pl.name_th AS position_level,
  pf.name_th AS position_family,
  pos.quota,
  pos.current_occupancy,
  pos.vacancy_count,
  CASE WHEN pos.quota > 0
    THEN ROUND((pos.vacancy_count::NUMERIC / pos.quota) * 100, 2)
    ELSE 0
  END AS vacancy_rate_pct,
  pos.is_critical,
  -- Current occupant(s)
  array_agg(
    DISTINCT (p.prefix_th || p.first_name_th || ' ' || p.last_name_th)
  ) FILTER (WHERE p.id IS NOT NULL) AS current_occupants,
  -- Succession status
  CASE WHEN EXISTS(
    SELECT 1 FROM succession_plans sp
    WHERE sp.position_id = pos.id AND sp.plan_status IN ('approved', 'in_progress')
  ) THEN true ELSE false
  END AS has_succession_plan
FROM positions pos
JOIN organizations o ON o.id = pos.organization_id
LEFT JOIN position_types pt ON pt.id = pos.position_type_id
LEFT JOIN position_levels pl ON pl.id = pos.position_level_id
LEFT JOIN position_families pf ON pf.id = pos.position_family_id
LEFT JOIN workforce_allocations wa ON wa.position_id = pos.id AND wa.is_current = true
LEFT JOIN personnel p ON p.id = wa.personnel_id
WHERE pos.is_active = true
GROUP BY pos.id, pos.position_code, pos.name_th, pos.organization_id,
  o.name_th, pt.name_th, pl.name_th, pf.name_th, pos.quota,
  pos.current_occupancy, pos.vacancy_count, pos.is_critical;

-- ============================================================================
-- 5. v_high_risk_personnel: Personnel with elevated risk scores
-- ============================================================================
CREATE OR REPLACE VIEW v_high_risk_personnel AS
SELECT
  po.id,
  po.employee_number,
  po.full_name_th,
  po.organization_name,
  po.position_name,
  po.position_level,
  po.position_type,
  po.overall_risk_score,
  po.risk_level,
  po.retirement_risk,
  po.retirement_years_remaining,
  po.retirement_date,
  po.transfer_risk,
  po.talent_loss_risk,
  po.vacancy_risk,
  po.is_critical_position,
  -- Primary risk driver
  CASE
    WHEN po.retirement_risk >= 75 THEN 'retirement'
    WHEN po.talent_loss_risk >= 75 THEN 'talent_loss'
    WHEN po.transfer_risk >= 75 THEN 'transfer'
    WHEN po.vacancy_risk >= 75 THEN 'vacancy'
    ELSE 'mixed'
  END AS primary_risk_driver
FROM v_personnel_overview po
WHERE po.overall_risk_score >= 25
  AND po.status = 'active'
ORDER BY po.overall_risk_score DESC;

-- ============================================================================
-- 6. v_succession_status: Succession planning overview
-- ============================================================================
CREATE OR REPLACE VIEW v_succession_status AS
SELECT
  sp.id AS succession_plan_id,
  sp.plan_name,
  sp.plan_status,
  sp.priority,
  pos.id AS position_id,
  pos.position_code,
  pos.name_th AS position_name,
  pos.is_critical AS is_critical_position,
  pos.organization_id,
  o.name_th AS organization_name,
  -- Current incumbent
  (SELECT COALESCE(p.prefix_th || p.first_name_th || ' ' || p.last_name_th, 'Vacant')
   FROM personnel p WHERE p.current_position_id = pos.id AND p.status = 'active' LIMIT 1
  ) AS incumbent_name,
  -- Candidates count
  COUNT(spc.id) AS total_candidates,
  COUNT(spc.id) FILTER (WHERE spc.readiness = 'ready_now') AS ready_now_count,
  COUNT(spc.id) FILTER (WHERE spc.readiness = 'ready_1_2_years') AS ready_1_2yr_count,
  COUNT(spc.id) FILTER (WHERE spc.readiness = 'ready_3_5_years') AS ready_3_5yr_count,
  COUNT(spc.id) FILTER (WHERE spc.readiness = 'not_ready') AS not_ready_count,
  -- Primary candidate
  (SELECT COALESCE(p.prefix_th || p.first_name_th || ' ' || p.last_name_th, 'None')
   FROM succession_plan_candidates spc2
   JOIN personnel p ON p.id = spc2.personnel_id
   WHERE spc2.succession_plan_id = sp.id AND spc2.is_primary = true
   LIMIT 1
  ) AS primary_candidate_name,
  sp.target_date,
  sp.notes
FROM succession_plans sp
JOIN positions pos ON pos.id = sp.position_id
JOIN organizations o ON o.id = pos.organization_id
LEFT JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
GROUP BY sp.id, sp.plan_name, sp.plan_status, sp.priority,
  pos.id, pos.position_code, pos.name_th, pos.is_critical,
  pos.organization_id, o.name_th, sp.target_date, sp.notes;

-- ============================================================================
-- 7. v_training_summary: Training statistics per person
-- ============================================================================
CREATE OR REPLACE VIEW v_training_summary AS
SELECT
  p.id AS personnel_id,
  p.employee_number,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
  p.organization_id,
  o.name_th AS organization_name,
  COUNT(tr.id) AS total_training_count,
  COUNT(tr.id) FILTER (WHERE tr.is_completed = true) AS completed_count,
  COALESCE(SUM(tr.duration_hours) FILTER (WHERE tr.is_completed = true), 0) AS total_hours,
  EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER AS current_year,
  COUNT(tr.id) FILTER (WHERE EXTRACT(YEAR FROM tr.start_date) = EXTRACT(YEAR FROM CURRENT_DATE)) AS current_year_count,
  COALESCE(SUM(tr.duration_hours) FILTER (WHERE EXTRACT(YEAR FROM tr.start_date) = EXTRACT(YEAR FROM CURRENT_DATE)), 0) AS current_year_hours,
  COALESCE(SUM(tr.cost), 0) AS total_cost
FROM personnel p
JOIN organizations o ON o.id = p.organization_id
LEFT JOIN training_records tr ON tr.personnel_id = p.id
WHERE p.status = 'active'
GROUP BY p.id, p.employee_number, p.prefix_th, p.first_name_th, p.last_name_th,
  p.organization_id, o.name_th;

-- ============================================================================
-- 8. v_evaluation_history: Performance evaluation history
-- ============================================================================
CREATE OR REPLACE VIEW v_evaluation_history AS
SELECT
  pe.id,
  p.id AS personnel_id,
  p.employee_number,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
  p.organization_id,
  o.name_th AS organization_name,
  pe.evaluation_year,
  pe.evaluation_period,
  pe.overall_score,
  pe.rating,
  pe.kpi_score,
  pe.competency_score,
  pe.behavior_score,
  pe.assessor_name,
  pe.evaluation_date
FROM performance_evaluations pe
JOIN personnel p ON p.id = pe.personnel_id
JOIN organizations o ON o.id = p.organization_id
ORDER BY pe.evaluation_year DESC, pe.evaluation_period;

-- ============================================================================
-- 9. v_active_alerts: Current active alerts with details
-- ============================================================================
CREATE OR REPLACE VIEW v_active_alerts AS
SELECT
  a.id,
  a.severity,
  a.title,
  a.message,
  a.status,
  a.organization_id,
  o.name_th AS organization_name,
  a.personnel_id,
  (p.prefix_th || p.first_name_th || ' ' || p.last_name_th) AS personnel_name,
  a.indicator_value,
  a.threshold_value,
  a.alert_rule_id,
  ar.name AS rule_name,
  a.created_at,
  a.acknowledged_at,
  a.resolved_at,
  -- Age in hours
  ROUND(EXTRACT(EPOCH FROM (NOW() - a.created_at)) / 3600, 1) AS age_hours
FROM alerts a
LEFT JOIN organizations o ON o.id = a.organization_id
LEFT JOIN personnel p ON p.id = a.personnel_id
LEFT JOIN alert_rules ar ON ar.id = a.alert_rule_id
WHERE a.status = 'active'
ORDER BY
  CASE a.severity WHEN 'emergency' THEN 1 WHEN 'critical' THEN 2 WHEN 'warning' THEN 3 ELSE 4 END,
  a.created_at DESC;

-- ============================================================================
-- 10. v_workforce_composition: Workforce composition by type/level/family
-- ============================================================================
CREATE OR REPLACE VIEW v_workforce_composition AS
SELECT
  o.id AS organization_id,
  o.name_th AS organization_name,
  -- By position type
  COUNT(p.id) FILTER (WHERE pt.category = 'บริหาร') AS exec_count,
  COUNT(p.id) FILTER (WHERE pt.category = 'อำนวยการ') AS director_count,
  COUNT(p.id) FILTER (WHERE pt.category = 'วิชาการ') AS academic_count,
  COUNT(p.id) FILTER (WHERE pt.category = 'ทั่วไป') AS general_count,
  -- By gender
  COUNT(p.id) FILTER (WHERE p.gender = 'male') AS male_count,
  COUNT(p.id) FILTER (WHERE p.gender = 'female') AS female_count,
  -- By education
  COUNT(p.id) FILTER (WHERE p.education_level = 'doctorate') AS doctorate_count,
  COUNT(p.id) FILTER (WHERE p.education_level = 'masters') AS masters_count,
  COUNT(p.id) FILTER (WHERE p.education_level = 'bachelors') AS bachelors_count,
  -- By age bracket
  COUNT(p.id) FILTER (WHERE p.retirement_years_remaining <= 5) AS near_retirement_count,
  COUNT(p.id) FILTER (WHERE p.retirement_years_remaining > 5 AND p.retirement_years_remaining <= 10) AS mid_career_count,
  COUNT(p.id) FILTER (WHERE p.retirement_years_remaining > 10) AS early_career_count,
  -- Total
  COUNT(p.id) AS total_active
FROM organizations o
LEFT JOIN personnel p ON p.organization_id = o.id AND p.status = 'active'
LEFT JOIN position_types pt ON pt.id = p.position_type_id
WHERE o.is_active = true
GROUP BY o.id, o.name_th;

-- ============================================================================
-- 11. v_import_status: Current import status overview
-- ============================================================================
CREATE OR REPLACE VIEW v_import_status AS
SELECT
  di.id,
  di.file_name,
  di.source,
  di.file_type,
  di.status,
  di.total_rows,
  di.valid_rows,
  di.error_rows,
  di.inserted_rows,
  di.updated_rows,
  di.started_at,
  di.completed_at,
  di.processing_time_ms,
  di.imported_by,
  CASE WHEN di.started_at IS NOT NULL AND di.completed_at IS NULL
    THEN ROUND(EXTRACT(EPOCH FROM (NOW() - di.started_at))::numeric, 0)::INTEGER
    ELSE di.processing_time_ms
  END AS elapsed_seconds,
  (SELECT COUNT(*) FROM import_errors ie WHERE ie.import_id = di.id AND ie.is_resolved = false)
    AS unresolved_errors
FROM data_imports di
ORDER BY di.created_at DESC;