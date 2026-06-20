-- ============================================================================
-- HRiSENSE Migration 019: Grant view permissions to Supabase roles
-- PostgREST (REST API) connects as anon/authenticated/service_role.
-- Views need explicit GRANT SELECT or the API returns 403.
-- ============================================================================

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO service_role;

-- Also allow sequence usage (needed for some inserts)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;
