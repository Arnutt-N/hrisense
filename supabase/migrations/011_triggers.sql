-- ============================================================================
-- HRiSENSE Migration 011: Triggers & Updated_at Management
-- ============================================================================

-- ============================================================================
-- Generic updated_at trigger function
-- ============================================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Apply updated_at triggers to all tables
-- ============================================================================
CREATE TRIGGER trg_organizations_updated_at
  BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_position_types_updated_at
  BEFORE UPDATE ON position_types FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_position_levels_updated_at
  BEFORE UPDATE ON position_levels FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_position_families_updated_at
  BEFORE UPDATE ON position_families FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_salary_scales_updated_at
  BEFORE UPDATE ON salary_scales FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_personnel_updated_at
  BEFORE UPDATE ON personnel FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_positions_updated_at
  BEFORE UPDATE ON positions FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_workforce_allocations_updated_at
  BEFORE UPDATE ON workforce_allocations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_risk_indicators_updated_at
  BEFORE UPDATE ON risk_indicators FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_personnel_risk_scores_updated_at
  BEFORE UPDATE ON personnel_risk_scores FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_organization_risk_summary_updated_at
  BEFORE UPDATE ON organization_risk_summary FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_succession_plans_updated_at
  BEFORE UPDATE ON succession_plans FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_succession_plan_candidates_updated_at
  BEFORE UPDATE ON succession_plan_candidates FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_idp_updated_at
  BEFORE UPDATE ON individual_development_plans FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_workforce_plans_updated_at
  BEFORE UPDATE ON workforce_plans FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_training_records_updated_at
  BEFORE UPDATE ON training_records FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_performance_evaluations_updated_at
  BEFORE UPDATE ON performance_evaluations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_leave_records_updated_at
  BEFORE UPDATE ON leave_records FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_transfer_records_updated_at
  BEFORE UPDATE ON transfer_records FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_retirement_forecasts_updated_at
  BEFORE UPDATE ON retirement_forecasts FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_data_imports_updated_at
  BEFORE UPDATE ON data_imports FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_alert_rules_updated_at
  BEFORE UPDATE ON alert_rules FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_alerts_updated_at
  BEFORE UPDATE ON alerts FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- Position occupancy trigger on workforce_allocations
-- ============================================================================
CREATE TRIGGER trg_allocation_occupancy
  AFTER INSERT OR UPDATE OR DELETE ON workforce_allocations
  FOR EACH ROW EXECUTE FUNCTION update_position_occupancy();

-- ============================================================================
-- Auto-trigger risk recalculation on personnel changes
-- ============================================================================
CREATE OR REPLACE FUNCTION trigger_personnel_risk_recalc()
RETURNS TRIGGER AS $$
BEGIN
  -- Recalculate risk score for the affected person
  PERFORM calculate_personnel_risk_score(
    COALESCE(NEW.id, OLD.id)
  );

  -- Recalculate org summary for affected org
  PERFORM calculate_org_risk_summary(
    COALESCE(NEW.organization_id, OLD.organization_id)
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_personnel_risk_auto_calc
  AFTER INSERT OR UPDATE OF organization_id, position_level_id, position_type_id, status, birth_date
  ON personnel
  FOR EACH ROW EXECUTE FUNCTION trigger_personnel_risk_recalc();

-- ============================================================================
-- Auto-trigger org risk recalc on position changes
-- ============================================================================
CREATE OR REPLACE FUNCTION trigger_org_risk_on_position_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM calculate_org_risk_summary(
    COALESCE(NEW.organization_id, OLD.organization_id)
  );
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_position_org_risk_recalc
  AFTER INSERT OR UPDATE OR DELETE ON positions
  FOR EACH ROW EXECUTE FUNCTION trigger_org_risk_on_position_change();

-- ============================================================================
-- Audit log triggers on key tables
-- ============================================================================
CREATE TRIGGER trg_audit_personnel
  AFTER INSERT OR UPDATE OR DELETE ON personnel
  FOR EACH ROW EXECUTE FUNCTION generate_audit_log();

CREATE TRIGGER trg_audit_positions
  AFTER INSERT OR UPDATE OR DELETE ON positions
  FOR EACH ROW EXECUTE FUNCTION generate_audit_log();

CREATE TRIGGER trg_audit_organizations
  AFTER INSERT OR UPDATE OR DELETE ON organizations
  FOR EACH ROW EXECUTE FUNCTION generate_audit_log();

CREATE TRIGGER trg_audit_workforce_allocations
  AFTER INSERT OR UPDATE OR DELETE ON workforce_allocations
  FOR EACH ROW EXECUTE FUNCTION generate_audit_log();

CREATE TRIGGER trg_audit_succession_plans
  AFTER INSERT OR UPDATE OR DELETE ON succession_plans
  FOR EACH ROW EXECUTE FUNCTION generate_audit_log();