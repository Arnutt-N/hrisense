-- ============================================================================
-- HRiSENSE Migration 023: Harden RLS policies (CRITICAL C6 + C7)
--
-- C6 — cross-tenant leak: alerts & risk_assessments used
--      `organization_id IS NULL OR is_in_org_hierarchy(organization_id)`, which
--      let ANY authenticated user read every row whose organization_id is NULL.
-- C7 — per-row evaluation: RLS helper functions re-evaluated auth.uid() and
--      get_current_user_department() once per scanned row. Wrapping the
--      non-row-dependent calls in (SELECT ...) lets the planner cache them.
--
-- See docs/SECURITY_AUDIT.md.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- C7: cache non-row-dependent subexpressions inside the helper functions.
-- (SELECT auth.uid()) / (SELECT get_current_user_department()) are evaluated
-- once per statement as an initplan instead of once per row.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS TEXT AS $$
  SELECT role FROM profiles WHERE id = (SELECT auth.uid());
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_current_user_department()
RETURNS UUID AS $$
  SELECT department_id FROM profiles WHERE id = (SELECT auth.uid());
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_in_org_hierarchy(org_uuid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM organizations
    WHERE id = org_uuid
    AND (
      id = (SELECT get_current_user_department())
      OR hierarchy_path <@ (
        SELECT hierarchy_path FROM organizations
        WHERE id = (SELECT get_current_user_department())
      )
    )
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- ----------------------------------------------------------------------------
-- C6: remove the `organization_id IS NULL` bypass. A row is visible to a viewer
-- only when it is in their org hierarchy — scoped either by organization_id or,
-- when that is NULL, by the linked personnel's organization. Rows with BOTH
-- NULL remain admin-only (covered by the existing *_admin_all policies).
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "risk_assessments_viewer_read" ON risk_assessments;
CREATE POLICY "risk_assessments_viewer_read" ON risk_assessments FOR SELECT
USING (
  (organization_id IS NOT NULL AND is_in_org_hierarchy(organization_id))
  OR (
    personnel_id IS NOT NULL AND EXISTS(
      SELECT 1 FROM personnel p
      WHERE p.id = risk_assessments.personnel_id
        AND is_in_org_hierarchy(p.organization_id)
    )
  )
);

DROP POLICY IF EXISTS "alerts_viewer_read" ON alerts;
CREATE POLICY "alerts_viewer_read" ON alerts FOR SELECT
USING (
  (organization_id IS NOT NULL AND is_in_org_hierarchy(organization_id))
  OR (
    personnel_id IS NOT NULL AND EXISTS(
      SELECT 1 FROM personnel p
      WHERE p.id = alerts.personnel_id
        AND is_in_org_hierarchy(p.organization_id)
    )
  )
);
