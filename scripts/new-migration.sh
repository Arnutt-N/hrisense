#!/bin/bash
# ============================================================================
# Create a new Supabase migration file
# Usage: bash scripts/new-migration.sh <name>
# Example: bash scripts/new-migration.sh add-personnel-avatar-column
# ============================================================================

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <migration-name>"
  echo "Example: $0 add-personnel-avatar-column"
  exit 1
fi

NAME="$1"

# Find highest migration number
LATEST=$(ls supabase/migrations/*.sql 2>/dev/null | sort | tail -1 | grep -oP '\d+' | head -1)

if [ -z "$LATEST" ]; then
  NEXT="001"
else
  NEXT=$(printf "%03d" $((10#$LATEST + 1)))
fi

FILENAME="supabase/migrations/${NEXT}_${NAME}.sql"

cat > "$FILENAME" << EOF
-- ============================================================================
-- Migration ${NEXT}: ${NAME}
-- Description: TODO — describe what this migration does
-- ============================================================================

BEGIN;

-- TODO: Add your SQL here

COMMIT;
EOF

echo "✅ Created: $FILENAME"
echo ""
echo "Next steps:"
echo "  1. Edit $FILENAME"
echo "  2. supabase db reset    # test migration locally"
echo "  3. npm run dev          # verify app works"
echo "  4. git add $FILENAME"
echo "  5. git commit -m 'feat: ${NAME}'"
