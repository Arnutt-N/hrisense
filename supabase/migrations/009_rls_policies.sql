-- ============================================================================
-- HRiSENSE Migration 009: Row Level Security Policies
-- ============================================================================

CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS TEXT AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_current_user_department()
RETURNS UUID AS $$
  SELECT department_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT COALESCE(get_current_user_role() = 'admin', false);
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_in_org_hierarchy(org_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM organizations
    WHERE id = org_uuid
    AND (
      id = get_current_user_department()
      OR hierarchy_path <@ (SELECT hierarchy_path FROM organizations WHERE id = get_current_user_department())
    )
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "organizations_admin_all" ON organizations FOR ALL USING (is_admin());
CREATE POLICY "organizations_viewer_read" ON organizations FOR SELECT USING (is_in_org_hierarchy(id));

ALTER TABLE position_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "position_types_read" ON position_types FOR SELECT USING (auth.uid() IS NOT NULL);

ALTER TABLE position_levels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "position_levels_read" ON position_levels FOR SELECT USING (auth.uid() IS NOT NULL);

ALTER TABLE position_families ENABLE ROW LEVEL SECURITY;
CREATE POLICY "position_families_read" ON position_families FOR SELECT USING (auth.uid() IS NOT NULL);

ALTER TABLE salary_scales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "salary_scales_admin_all" ON salary_scales FOR ALL USING (is_admin());
CREATE POLICY "salary_scales_read" ON salary_scales FOR SELECT USING (auth.uid() IS NOT NULL);

ALTER TABLE personnel ENABLE ROW LEVEL SECURITY;
CREATE POLICY "personnel_admin_all" ON personnel FOR ALL USING (is_admin());
CREATE POLICY "personnel_viewer_read" ON personnel FOR SELECT USING (is_in_org_hierarchy(organization_id));

ALTER TABLE positions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "positions_admin_all" ON positions FOR ALL USING (is_admin());
CREATE POLICY "positions_viewer_read" ON positions FOR SELECT USING (is_in_org_hierarchy(organization_id));

ALTER TABLE workforce_allocations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "allocations_admin_all" ON workforce_allocations FOR ALL USING (is_admin());
CREATE POLICY "allocations_viewer_read" ON workforce_allocations FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = workforce_allocations.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE risk_indicators ENABLE ROW LEVEL SECURITY;
CREATE POLICY "risk_indicators_admin_all" ON risk_indicators FOR ALL USING (is_admin());
CREATE POLICY "risk_indicators_read" ON risk_indicators FOR SELECT USING (auth.uid() IS NOT NULL);

ALTER TABLE personnel_risk_scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "personnel_risk_admin_all" ON personnel_risk_scores FOR ALL USING (is_admin());
CREATE POLICY "personnel_risk_viewer_read" ON personnel_risk_scores FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = personnel_risk_scores.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE organization_risk_summary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "org_risk_admin_all" ON organization_risk_summary FOR ALL USING (is_admin());
CREATE POLICY "org_risk_viewer_read" ON organization_risk_summary FOR SELECT USING (is_in_org_hierarchy(organization_id));

ALTER TABLE risk_assessments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "risk_assessments_admin_all" ON risk_assessments FOR ALL USING (is_admin());
CREATE POLICY "risk_assessments_viewer_read" ON risk_assessments FOR SELECT
USING (organization_id IS NULL OR is_in_org_hierarchy(organization_id));

ALTER TABLE retirement_forecasts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "retirement_admin_all" ON retirement_forecasts FOR ALL USING (is_admin());
CREATE POLICY "retirement_viewer_read" ON retirement_forecasts FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = retirement_forecasts.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE succession_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "succession_plans_admin_all" ON succession_plans FOR ALL USING (is_admin());
CREATE POLICY "succession_plans_viewer_read" ON succession_plans FOR SELECT
USING (EXISTS(SELECT 1 FROM positions pos WHERE pos.id = succession_plans.position_id AND is_in_org_hierarchy(pos.organization_id)));

ALTER TABLE succession_plan_candidates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "succession_candidates_admin_all" ON succession_plan_candidates FOR ALL USING (is_admin());
CREATE POLICY "succession_candidates_viewer_read" ON succession_plan_candidates FOR SELECT
USING (EXISTS(SELECT 1 FROM succession_plans sp JOIN positions pos ON pos.id = sp.position_id
  WHERE sp.id = succession_plan_candidates.succession_plan_id AND is_in_org_hierarchy(pos.organization_id)));

ALTER TABLE individual_development_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "idp_admin_all" ON individual_development_plans FOR ALL USING (is_admin());
CREATE POLICY "idp_viewer_read" ON individual_development_plans FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = individual_development_plans.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE workforce_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "workforce_plans_admin_all" ON workforce_plans FOR ALL USING (is_admin());
CREATE POLICY "workforce_plans_viewer_read" ON workforce_plans FOR SELECT USING (is_in_org_hierarchy(organization_id));

ALTER TABLE training_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "training_admin_all" ON training_records FOR ALL USING (is_admin());
CREATE POLICY "training_viewer_read" ON training_records FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = training_records.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE performance_evaluations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "evaluations_admin_all" ON performance_evaluations FOR ALL USING (is_admin());
CREATE POLICY "evaluations_viewer_read" ON performance_evaluations FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = performance_evaluations.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE leave_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "leave_admin_all" ON leave_records FOR ALL USING (is_admin());
CREATE POLICY "leave_viewer_read" ON leave_records FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = leave_records.personnel_id AND is_in_org_hierarchy(p.organization_id)));

ALTER TABLE transfer_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "transfer_admin_all" ON transfer_records FOR ALL USING (is_admin());
CREATE POLICY "transfer_viewer_read" ON transfer_records FOR SELECT
USING (EXISTS(SELECT 1 FROM personnel p WHERE p.id = transfer_records.personnel_id
  AND (is_in_org_hierarchy(p.organization_id) OR is_in_org_hierarchy(from_organization_id) OR is_in_org_hierarchy(to_organization_id))));

ALTER TABLE data_imports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "data_imports_admin" ON data_imports FOR ALL USING (is_admin());

ALTER TABLE import_staging ENABLE ROW LEVEL SECURITY;
CREATE POLICY "import_staging_admin" ON import_staging FOR ALL USING (is_admin());

ALTER TABLE import_errors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "import_errors_admin" ON import_errors FOR ALL USING (is_admin());

ALTER TABLE dashboard_configs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dashboard_configs_own" ON dashboard_configs FOR ALL USING (user_id = auth.uid());

ALTER TABLE alert_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "alert_rules_admin_all" ON alert_rules FOR ALL USING (is_admin());
CREATE POLICY "alert_rules_read" ON alert_rules FOR SELECT USING (auth.uid() IS NOT NULL);

ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "alerts_admin_all" ON alerts FOR ALL USING (is_admin());
CREATE POLICY "alerts_viewer_read" ON alerts FOR SELECT
USING (organization_id IS NULL OR is_in_org_hierarchy(organization_id));

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "audit_logs_admin" ON audit_logs FOR ALL USING (is_admin());
CREATE POLICY "audit_logs_own" ON audit_logs FOR SELECT USING (user_id = auth.uid());

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_admin_all" ON profiles FOR ALL USING (is_admin());
CREATE POLICY "profiles_self_read" ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "profiles_self_update" ON profiles FOR UPDATE USING (id = auth.uid());