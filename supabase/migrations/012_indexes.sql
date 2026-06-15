-- ============================================================================
-- HRiSENSE Migration 012: Performance Indexes
-- ============================================================================

-- ============================================================================
-- Organization hierarchy indexes
-- ============================================================================
CREATE INDEX idx_organizations_parent ON organizations(parent_id);
CREATE INDEX idx_organizations_level ON organizations(level);
CREATE INDEX idx_organizations_path ON organizations USING gist(hierarchy_path);
CREATE INDEX idx_organizations_active ON organizations(is_active) WHERE is_active = true;

-- ============================================================================
-- Personnel indexes (core dashboard queries)
-- ============================================================================
CREATE INDEX idx_personnel_org ON personnel(organization_id);
CREATE INDEX idx_personnel_status ON personnel(status);
CREATE INDEX idx_personnel_org_status ON personnel(organization_id, status);
CREATE INDEX idx_personnel_position_type ON personnel(position_type_id);
CREATE INDEX idx_personnel_position_level ON personnel(position_level_id);
CREATE INDEX idx_personnel_position_family ON personnel(position_family_id);
CREATE INDEX idx_personnel_retirement_date ON personnel(retirement_date);
CREATE INDEX idx_personnel_risk_score ON personnel(overall_risk_score DESC);
CREATE INDEX idx_personnel_risk_level ON personnel(risk_level);
CREATE INDEX idx_personnel_birth_date ON personnel(birth_date);
CREATE INDEX idx_personnel_gov_start ON personnel(government_start_date);
CREATE INDEX idx_personnel_education ON personnel(education_level);
CREATE INDEX idx_personnel_gender ON personnel(gender);

-- Full-text search on Thai names
CREATE INDEX idx_personnel_name_search ON personnel
  USING gin(to_tsvector('simple', first_name_th || ' ' || last_name_th));

-- ============================================================================
-- Position indexes
-- ============================================================================
CREATE INDEX idx_positions_org ON positions(organization_id);
CREATE INDEX idx_positions_type ON positions(position_type_id);
CREATE INDEX idx_positions_level ON positions(position_level_id);
CREATE INDEX idx_positions_family ON positions(position_family_id);
CREATE INDEX idx_positions_critical ON positions(is_critical) WHERE is_critical = true;
CREATE INDEX idx_positions_active ON positions(is_active) WHERE is_active = true;
CREATE INDEX idx_positions_org_active ON positions(organization_id, is_active);

-- ============================================================================
-- Risk indexes
-- ============================================================================
CREATE INDEX idx_personnel_risk_person ON personnel_risk_scores(personnel_id);
CREATE INDEX idx_personnel_risk_score ON personnel_risk_scores(overall_score DESC);
CREATE INDEX idx_personnel_risk_level ON personnel_risk_scores(risk_level);
CREATE INDEX idx_personnel_risk_retirement ON personnel_risk_scores(retirement_risk DESC);

CREATE INDEX idx_org_risk_org ON organization_risk_summary(organization_id);
CREATE INDEX idx_org_risk_date ON organization_risk_summary(snapshot_date DESC);
CREATE INDEX idx_org_risk_org_date ON organization_risk_summary(organization_id, snapshot_date DESC);
CREATE INDEX idx_org_risk_level ON organization_risk_summary(risk_level);
CREATE INDEX idx_org_risk_overall ON organization_risk_summary(overall_risk_score DESC);

CREATE INDEX idx_risk_assessments_org ON risk_assessments(organization_id);
CREATE INDEX idx_risk_assessments_person ON risk_assessments(personnel_id);
CREATE INDEX idx_risk_assessments_period ON risk_assessments(assessment_period);
CREATE INDEX idx_risk_assessments_at ON risk_assessments(assessed_at DESC);

-- ============================================================================
-- Retirement forecast indexes
-- ============================================================================
CREATE INDEX idx_retirement_forecasts_person ON retirement_forecasts(personnel_id);
CREATE INDEX idx_retirement_forecasts_year ON retirement_forecasts(forecast_year);
CREATE INDEX idx_retirement_forecasts_date ON retirement_forecasts(expected_retirement_date);

-- ============================================================================
-- Succession planning indexes
-- ============================================================================
CREATE INDEX idx_succession_plans_position ON succession_plans(position_id);
CREATE INDEX idx_succession_plans_status ON succession_plans(plan_status);
CREATE INDEX idx_succession_candidates_plan ON succession_plan_candidates(succession_plan_id);
CREATE INDEX idx_succession_candidates_person ON succession_plan_candidates(personnel_id);
CREATE INDEX idx_succession_candidates_readiness ON succession_plan_candidates(readiness);

-- ============================================================================
-- IDP indexes
-- ============================================================================
CREATE INDEX idx_idp_person ON individual_development_plans(personnel_id);
CREATE INDEX idx_idp_year ON individual_development_plans(plan_year);
CREATE INDEX idx_idp_status ON individual_development_plans(plan_status);

-- ============================================================================
-- Workforce plans indexes
-- ============================================================================
CREATE INDEX idx_workforce_plans_org ON workforce_plans(organization_id);
CREATE INDEX idx_workforce_plans_period ON workforce_plans(plan_period_start, plan_period_end);
CREATE INDEX idx_workforce_plans_status ON workforce_plans(plan_status);

-- ============================================================================
-- History table indexes
-- ============================================================================
CREATE INDEX idx_training_person ON training_records(personnel_id);
CREATE INDEX idx_training_dates ON training_records(start_date, end_date);

CREATE INDEX idx_eval_person ON performance_evaluations(personnel_id);
CREATE INDEX idx_eval_year ON performance_evaluations(evaluation_year DESC);

CREATE INDEX idx_leave_person ON leave_records(personnel_id);
CREATE INDEX idx_leave_type ON leave_records(leave_type);
CREATE INDEX idx_leave_fiscal ON leave_records(fiscal_year);

CREATE INDEX idx_transfer_person ON transfer_records(personnel_id);
CREATE INDEX idx_transfer_from ON transfer_records(from_organization_id);
CREATE INDEX idx_transfer_to ON transfer_records(to_organization_id);
CREATE INDEX idx_transfer_date ON transfer_records(effective_date DESC);

-- ============================================================================
-- Import indexes
-- ============================================================================
CREATE INDEX idx_imports_status ON data_imports(status);
CREATE INDEX idx_imports_source ON data_imports(source);
CREATE INDEX idx_imports_created ON data_imports(created_at DESC);

CREATE INDEX idx_staging_import ON import_staging(import_id);
CREATE INDEX idx_staging_valid ON import_staging(is_valid) WHERE is_valid = false;

CREATE INDEX idx_errors_import ON import_errors(import_id);
CREATE INDEX idx_errors_type ON import_errors(error_type);

-- ============================================================================
-- Alert indexes
-- ============================================================================
CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_org ON alerts(organization_id);
CREATE INDEX idx_alerts_person ON alerts(personnel_id);
CREATE INDEX idx_alerts_created ON alerts(created_at DESC);

CREATE INDEX idx_alert_rules_active ON alert_rules(is_active) WHERE is_active = true;

-- ============================================================================
-- Audit log indexes
-- ============================================================================
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_table ON audit_logs(table_name);
CREATE INDEX idx_audit_record ON audit_logs(record_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- ============================================================================
-- Dashboard configs
-- ============================================================================
CREATE INDEX idx_dashboard_user ON dashboard_configs(user_id);