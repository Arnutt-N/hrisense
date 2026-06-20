#!/bin/bash
# ============================================================================
# Deploy migrations to production Supabase
# Usage: bash scripts/deploy-supabase.sh [--dry-run]
#
# Prerequisites:
#   - supabase CLI installed
#   - supabase linked to production project
#   - environment variables set (SUPABASE_ACCESS_TOKEN)
# ============================================================================

set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  echo "🔍 DRY RUN — จะไม่ apply จริง"
  echo ""
fi

# Check supabase is linked
if [ ! -f "supabase/.branches/_current_branch" ]; then
  echo "❌ ไม่พบ Supabase project ที่ link ไว้"
  echo "   รัน: supabase link --project-ref <project-ref>"
  exit 1
fi

# Show pending migrations
echo "=== Pending Migrations ==="
if $DRY_RUN; then
  supabase db diff --linked --schema public 2>/dev/null || echo "(ไม่พบ diff หรือยังไม่ได้ link)"
else
  echo "Apply migrations to production..."
  supabase db push --linked
  echo ""
  echo "✅ Migrations applied successfully!"
fi

# Verify
echo ""
echo "=== Verification ==="
echo "Run this to check production status:"
echo "  supabase db diff --linked --schema public"
echo "  supabase db execute 'SELECT COUNT(*) FROM organizations;'"
