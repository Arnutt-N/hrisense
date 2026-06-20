-- ============================================================================
-- HRiSENSE Migration 016: Additional Views for Enhanced Dashboard
-- ============================================================================

-- ============================================================================
-- 1. v_critical_positions: Critical positions overview
-- ============================================================================
CREATE OR REPLACE VIEW v_critical_positions AS
SELECT
  pos.id AS position_id,
  pos.position_code,
  pos.name_th AS position_name,
  pos.organization_id,
  o.name_th AS organization_name,
  pt.name_th AS position_type,
  pl.name_th AS position_level,
  pos.quota,
  pos.current_occupancy,
  pos.vacancy_count,
  pos.is_critical,
  -- Current incumbent
  (SELECT COALESCE(p.prefix_th || p.first_name_th || ' ' || p.last_name_th, 'Vacant')
   FROM personnel p WHERE p.current_position_id = pos.id AND p.status = 'active' LIMIT 1
  ) AS incumbent_name,
  -- Succession status
  CASE WHEN EXISTS(
    SELECT 1 FROM succession_plans sp
    WHERE sp.position_id = pos.id AND sp.plan_status IN ('approved', 'in_progress')
  ) THEN true ELSE false
  END AS has_succession_plan,
  CASE WHEN EXISTS(
    SELECT 1 FROM succession_plans sp
    JOIN succession_plan_candidates spc ON spc.succession_plan_id = sp.id
    WHERE sp.position_id = pos.id AND spc.readiness = 'ready_now'
  ) THEN true ELSE false
  END AS has_ready_successor
FROM positions pos
JOIN organizations o ON o.id = pos.organization_id
LEFT JOIN position_types pt ON pt.id = pos.position_type_id
LEFT JOIN position_levels pl ON pl.id = pos.position_level_id
WHERE pos.is_critical = true AND pos.is_active = true
ORDER BY o.name_th, pos.name_th;

-- ============================================================================
-- 2. v_succession_candidates: Succession planning candidates
-- ============================================================================
CREATE OR REPLACE VIEW v_succession_candidates AS
SELECT
  spc.id AS candidate_id,
  spc.personnel_id,
  p.employee_number,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS candidate_name,
  p.organization_id,
  o.name_th AS current_organization,
  pos_current.name_th AS current_position,
  sp.id AS succession_plan_id,
  sp.position_id AS target_position_id,
  pos_target.name_th AS target_position,
  pos_target.organization_id AS target_org_id,
  o_target.name_th AS target_organization,
  spc.readiness,
  spc.readiness_score,
  spc.is_primary,
  spc.assessed_at AS assigned_date,
  spc.notes,
  -- Computed readiness level
  CASE
    WHEN spc.readiness = 'ready_now' THEN 'ready'
    WHEN spc.readiness = 'ready_1_2_years' THEN 'developing'
    WHEN spc.readiness = 'ready_3_5_years' THEN 'early_stage'
    ELSE 'not_ready'
  END AS readiness_level
FROM succession_plan_candidates spc
JOIN personnel p ON p.id = spc.personnel_id
JOIN organizations o ON o.id = p.organization_id
JOIN succession_plans sp ON sp.id = spc.succession_plan_id
JOIN positions pos_target ON pos_target.id = sp.position_id
JOIN organizations o_target ON o_target.id = pos_target.organization_id
LEFT JOIN positions pos_current ON pos_current.id = p.current_position_id
WHERE p.status = 'active'
ORDER BY spc.readiness_score DESC;

-- ============================================================================
-- 3. v_risk_distribution: Risk type distribution
-- ============================================================================
CREATE OR REPLACE VIEW v_risk_distribution AS
SELECT
  'retirement' AS risk_type,
  'เสี่ยงเกษียณ' AS risk_type_th,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM personnel WHERE status = 'active'), 0), 2) AS percentage
FROM personnel p
JOIN personnel_risk_scores prs ON prs.personnel_id = p.id
WHERE p.status = 'active' AND prs.retirement_risk >= 50

UNION ALL

SELECT
  'transfer' AS risk_type,
  'เสี่ยงโอนย้าย' AS risk_type_th,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM personnel WHERE status = 'active'), 0), 2) AS percentage
FROM personnel p
JOIN personnel_risk_scores prs ON prs.personnel_id = p.id
WHERE p.status = 'active' AND prs.transfer_risk >= 50

UNION ALL

SELECT
  'talent_loss' AS risk_type,
  'เสี่ยงทาเลนท์' AS risk_type_th,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM personnel WHERE status = 'active'), 0), 2) AS percentage
FROM personnel p
JOIN personnel_risk_scores prs ON prs.personnel_id = p.id
WHERE p.status = 'active' AND prs.talent_loss_risk >= 50

UNION ALL

SELECT
  'high_risk' AS risk_type,
  'เสี่ยงสูงทั้งหมด' AS risk_type_th,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM personnel WHERE status = 'active'), 0), 2) AS percentage
FROM personnel p
JOIN personnel_risk_scores prs ON prs.personnel_id = p.id
WHERE p.status = 'active' AND prs.overall_score >= 50;

-- ============================================================================
-- 4. v_org_risk_details: Organization risk details
-- ============================================================================
CREATE OR REPLACE VIEW v_org_risk_details AS
SELECT
  o.id AS organization_id,
  o.name_th AS organization_name,
  o.abbreviation_th,
  -- Personnel count
  COUNT(p.id) AS total_personnel,
  -- Risk scores (averages from personnel_risk_scores)
  ROUND(AVG(prs.overall_score)::NUMERIC, 2) AS overall_risk_score,
  ROUND(AVG(prs.retirement_risk)::NUMERIC, 2) AS retirement_risk,
  ROUND(AVG(prs.transfer_risk)::NUMERIC, 2) AS transfer_risk,
  ROUND(AVG(prs.talent_loss_risk)::NUMERIC, 2) AS talent_loss_risk,
  -- Vacancy rate
  ROUND(
    CASE WHEN SUM(pos.quota) > 0
      THEN (SUM(pos.vacancy_count)::NUMERIC / SUM(pos.quota)) * 100
      ELSE 0
    END, 2
  ) AS vacancy_rate,
  -- Risk level
  CASE
    WHEN AVG(prs.overall_score) >= 75 THEN 'critical'
    WHEN AVG(prs.overall_score) >= 50 THEN 'red'
    WHEN AVG(prs.overall_score) >= 25 THEN 'amber'
    ELSE 'green'
  END AS risk_level,
  -- Retirement counts
  COUNT(p.id) FILTER (WHERE p.retirement_years_remaining <= 1) AS retiring_1yr,
  COUNT(p.id) FILTER (WHERE p.retirement_years_remaining <= 3) AS retiring_3yr,
  COUNT(p.id) FILTER (WHERE p.retirement_years_remaining <= 5) AS retiring_5yr
FROM organizations o
LEFT JOIN personnel p ON p.organization_id = o.id AND p.status = 'active'
LEFT JOIN personnel_risk_scores prs ON prs.personnel_id = p.id
LEFT JOIN positions pos ON pos.organization_id = o.id AND pos.is_active = true
WHERE o.is_active = true
GROUP BY o.id, o.name_th, o.abbreviation_th
ORDER BY overall_risk_score DESC;

-- ============================================================================
-- 5. v_idp_summary: IDP summary
-- ============================================================================
CREATE OR REPLACE VIEW v_idp_summary AS
SELECT
  idp.id,
  idp.personnel_id,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS personnel_name,
  p.employee_number,
  p.organization_id,
  o.name_th AS organization_name,
  pos.name_th AS position_name,
  idp.plan_year,
  idp.plan_status AS status,
  idp.goal_description,
  idp.activities,
  idp.target_position,
  idp.created_at,
  idp.updated_at,
  -- Training progress
  COALESCE(ts.total_hours, 0) AS completed_hours,
  COALESCE(ts.completed_count, 0) AS completed_trainings,
  idp.progress_percentage AS completion_percentage
FROM individual_development_plans idp
JOIN personnel p ON p.id = idp.personnel_id
JOIN organizations o ON o.id = p.organization_id
LEFT JOIN positions pos ON pos.id = p.current_position_id
LEFT JOIN v_training_summary ts ON ts.personnel_id = p.id
WHERE idp.plan_year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER + 543
ORDER BY idp.created_at DESC;

-- ============================================================================
-- 6. v_training_records: Training records detail
-- ============================================================================
CREATE OR REPLACE VIEW v_training_records AS
SELECT
  tr.id,
  tr.personnel_id,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS personnel_name,
  p.employee_number,
  p.organization_id,
  o.name_th AS organization_name,
  tr.course_name,
  tr.training_type AS course_type,
  tr.training_provider AS provider,
  tr.start_date,
  tr.end_date,
  tr.duration_hours AS training_hours,
  tr.cost,
  CASE WHEN tr.is_completed THEN 'completed' ELSE 'in_progress' END AS status,
  tr.certificate_number,
  tr.notes,
  tr.created_at
FROM training_records tr
JOIN personnel p ON p.id = tr.personnel_id
JOIN organizations o ON o.id = p.organization_id
ORDER BY tr.start_date DESC;

-- ============================================================================
-- 7. v_high_potential_personnel: High potential personnel (Hi-Po)
-- ============================================================================
CREATE OR REPLACE VIEW v_high_potential_personnel AS
SELECT
  p.id,
  p.employee_number,
  (COALESCE(p.prefix_th, '') || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
  p.organization_id,
  o.name_th AS organization_name,
  pos.name_th AS position_name,
  pl.name_th AS position_level,
  pt.name_th AS position_type,
  p.education_level,
  p.degree_name,
  -- Performance score (from latest evaluation)
  (SELECT pe.overall_score
   FROM performance_evaluations pe
   WHERE pe.personnel_id = p.id
   ORDER BY pe.evaluation_year DESC, pe.evaluation_period DESC
   LIMIT 1
  ) AS performance_score,
  -- Potential score (composite)
  ROUND((
    COALESCE((SELECT pe.overall_score FROM performance_evaluations pe WHERE pe.personnel_id = p.id ORDER BY pe.evaluation_year DESC LIMIT 1), 50) * 0.4 +
    COALESCE(p.salary / 1000, 50) * 0.2 +
    CASE p.education_level
      WHEN 'doctorate' THEN 100
      WHEN 'masters' THEN 80
      WHEN 'bachelors' THEN 60
      ELSE 40
    END * 0.2 +
    (100 - COALESCE(prs.retirement_risk, 50)) * 0.2
  )::NUMERIC, 2) AS potential_score,
  -- Training hours
  COALESCE(ts.current_year_hours, 0) AS training_hours_ytd,
  -- Talent flags
  CASE WHEN COALESCE((SELECT pe.overall_score FROM performance_evaluations pe WHERE pe.personnel_id = p.id ORDER BY pe.evaluation_year DESC LIMIT 1), 0) >= 80 THEN true ELSE false END AS high_performer,
  CASE WHEN p.education_level IN ('doctorate', 'masters') THEN true ELSE false END AS advanced_education,
  CASE WHEN p.retirement_years_remaining > 5 THEN true ELSE false END AS long_term_potential
FROM personnel p
JOIN organizations o ON o.id = p.organization_id
LEFT JOIN positions pos ON pos.id = p.current_position_id
LEFT JOIN position_levels pl ON pl.id = p.position_level_id
LEFT JOIN position_types pt ON pt.id = p.position_type_id
LEFT JOIN v_training_summary ts ON ts.personnel_id = p.id
LEFT JOIN personnel_risk_scores prs ON prs.personnel_id = p.id
WHERE p.status = 'active'
  AND p.retirement_years_remaining > 3
ORDER BY potential_score DESC;

-- ============================================================================
-- 8. v_org_vacancy_summary: Organization vacancy summary
-- ============================================================================
CREATE OR REPLACE VIEW v_org_vacancy_summary AS
SELECT
  o.id AS organization_id,
  o.name_th AS organization_name,
  o.abbreviation_th,
  -- Totals
  SUM(pos.quota) AS total_quota,
  SUM(pos.current_occupancy) AS total_filled,
  SUM(pos.vacancy_count) AS vacancy_count,
  -- Vacancy rate
  ROUND(
    CASE WHEN SUM(pos.quota) > 0
      THEN (SUM(pos.vacancy_count)::NUMERIC / SUM(pos.quota)) * 100
      ELSE 0
    END, 2
  ) AS vacancy_rate,
  -- Critical vacancies
  SUM(pos.vacancy_count) FILTER (WHERE pos.is_critical = true) AS critical_vacancy_count,
  SUM(pos.quota) FILTER (WHERE pos.is_critical = true) AS critical_quota,
  -- Position count
  COUNT(pos.id) AS total_positions,
  COUNT(pos.id) FILTER (WHERE pos.vacancy_count > 0) AS positions_with_vacancy
FROM organizations o
JOIN positions pos ON pos.organization_id = o.id AND pos.is_active = true
WHERE o.is_active = true
GROUP BY o.id, o.name_th, o.abbreviation_th
ORDER BY vacancy_rate DESC;

-- ============================================================================
-- 9. v_critical_vacancies: Critical vacancies detail
-- ============================================================================
CREATE OR REPLACE VIEW v_critical_vacancies AS
SELECT
  pos.id AS position_id,
  pos.position_code,
  pos.name_th AS position_name,
  pos.organization_id,
  o.name_th AS organization_name,
  pt.name_th AS position_type,
  pl.name_th AS position_level,
  pos.quota,
  pos.current_occupancy,
  pos.vacancy_count,
  ROUND(
    CASE WHEN pos.quota > 0
      THEN (pos.vacancy_count::NUMERIC / pos.quota) * 100
      ELSE 0
    END, 2
  ) AS vacancy_rate_pct,
  pos.is_critical,
  -- Days vacant
  (SELECT MIN(wa.effective_date)
   FROM workforce_allocations wa
   WHERE wa.position_id = pos.id AND wa.is_current = false
  ) AS vacant_since,
  -- Impact assessment
  CASE
    WHEN pos.vacancy_count >= pos.quota THEN 'critical'
    WHEN pos.vacancy_count >= (pos.quota * 0.5) THEN 'high'
    ELSE 'medium'
  END AS vacancy_impact
FROM positions pos
JOIN organizations o ON o.id = pos.organization_id
LEFT JOIN position_types pt ON pt.id = pos.position_type_id
LEFT JOIN position_levels pl ON pl.id = pos.position_level_id
WHERE pos.is_critical = true AND pos.is_active = true AND pos.vacancy_count > 0
ORDER BY vacancy_rate_pct DESC;

-- ============================================================================
-- Note: v_recruitment_pipeline skipped - recruitment_plans table does not exist
-- ============================================================================
