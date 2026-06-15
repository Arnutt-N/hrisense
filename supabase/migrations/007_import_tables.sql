-- ============================================================================
-- HRiSENSE Migration 007: Data Import Tables
-- ============================================================================

-- Data Import Jobs
CREATE TABLE data_imports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  file_name VARCHAR(500) NOT NULL,
  source VARCHAR(100) NOT NULL,
  file_type VARCHAR(50),

  status import_status DEFAULT 'pending',

  total_rows INTEGER DEFAULT 0,
  valid_rows INTEGER DEFAULT 0,
  error_rows INTEGER DEFAULT 0,
  inserted_rows INTEGER DEFAULT 0,
  updated_rows INTEGER DEFAULT 0,
  skipped_rows INTEGER DEFAULT 0,

  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  processing_time_ms INTEGER,

  target_table VARCHAR(100),
  import_mapping JSONB DEFAULT '{}',

  imported_by UUID,
  error_message TEXT,

  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Import Staging
CREATE TABLE import_staging (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  import_id UUID NOT NULL REFERENCES data_imports(id) ON DELETE CASCADE,
  row_number INTEGER NOT NULL,

  raw_data JSONB NOT NULL,
  mapped_data JSONB DEFAULT '{}',

  is_valid BOOLEAN DEFAULT NULL,
  validation_errors JSONB DEFAULT '[]',

  is_processed BOOLEAN DEFAULT FALSE,
  target_id UUID,

  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (import_id, row_number)
);

-- Import Errors
CREATE TABLE import_errors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  import_id UUID NOT NULL REFERENCES data_imports(id) ON DELETE CASCADE,
  staging_id UUID REFERENCES import_staging(id) ON DELETE SET NULL,
  row_number INTEGER,

  error_type VARCHAR(100),
  field_name VARCHAR(200),
  error_code VARCHAR(50),
  error_message TEXT NOT NULL,
  error_value TEXT,
  expected_value TEXT,

  is_resolved BOOLEAN DEFAULT FALSE,
  resolution TEXT,
  resolved_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (import_id, row_number, field_name, error_code)
);
