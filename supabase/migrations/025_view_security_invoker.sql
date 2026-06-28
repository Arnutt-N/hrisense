-- 025_view_security_invoker.sql
--
-- RLS / PII Hardening: set security_invoker = true on all views.
-- Tracking issue: nutchahrmoj/hrisense#32
-- Spec: docs/superpowers/specs/2026-06-28-rls-pii-hardening-design.md
-- Plan: docs/superpowers/plans/2026-06-28-rls-pii-hardening-plan.md
--
-- Root cause: Postgres views default to security_definer, running with the
-- owner's privileges. In Supabase the view owner is a superuser-level role
-- that bypasses RLS. An authenticated caller holding SELECT on a view (granted
-- in 019 / re-granted in 022) could therefore read PII across organizations
-- even though the base tables have RLS enabled.
--
-- Fix: set security_invoker = true so each view runs with the caller's
-- privileges and honors the base tables' RLS policies. Requires PG 15+
-- (supabase/config.toml: major_version = 15).
--
-- Supersedes (close as completed by this change):
--   PR #22 (re-scoped to this single concern)
--   PR #24 (superseded by 022_rls_hardening.sql)
--   PR #29 (superseded by 024_risk_level_enum.sql)
--
-- Idempotent: setting the same option again is a no-op. No schema/data change.
-- Rollback: ALTER VIEW <name> RESET (security_invoker);  (or SET (security_invoker = false))

-- From 013_views.sql (11)
ALTER VIEW v_personnel_overview  SET (security_invoker = true);
ALTER VIEW v_org_dashboard       SET (security_invoker = true);
ALTER VIEW v_retirement_timeline SET (security_invoker = true);
ALTER VIEW v_vacancy_analysis    SET (security_invoker = true);
ALTER VIEW v_high_risk_personnel SET (security_invoker = true);
ALTER VIEW v_succession_status   SET (security_invoker = true);
ALTER VIEW v_training_summary    SET (security_invoker = true);
ALTER VIEW v_evaluation_history  SET (security_invoker = true);
ALTER VIEW v_active_alerts       SET (security_invoker = true);
ALTER VIEW v_workforce_composition SET (security_invoker = true);
ALTER VIEW v_import_status       SET (security_invoker = true);

-- From 016_additional_views.sql (9)
ALTER VIEW v_critical_positions       SET (security_invoker = true);
ALTER VIEW v_succession_candidates    SET (security_invoker = true);
ALTER VIEW v_risk_distribution        SET (security_invoker = true);
ALTER VIEW v_org_risk_details        SET (security_invoker = true);
ALTER VIEW v_idp_summary             SET (security_invoker = true);
ALTER VIEW v_training_records        SET (security_invoker = true);
ALTER VIEW v_high_potential_personnel SET (security_invoker = true);
ALTER VIEW v_org_vacancy_summary     SET (security_invoker = true);
ALTER VIEW v_critical_vacancies      SET (security_invoker = true);

-- From 021_add_burnout_risk.sql (2)
ALTER VIEW v_burnout_analysis        SET (security_invoker = true);
ALTER VIEW v_org_burnout_summary     SET (security_invoker = true);