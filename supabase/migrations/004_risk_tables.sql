-- ============================================================================
-- HRiSENSE Migration 004: Risk & Analytics Tables
-- ============================================================================

-- Risk Indicator Definitions
CREATE TABLE risk_indicators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name_th VARCHAR(300) NOT NULL,
  name_en VARCHAR(300),
  description TEXT,
  category risk_category NOT NULL,

  -- Formula & calculation
  formula TEXT,
  formula_type VARCHAR(50),
  weight NUMERIC(3,2) DEFAULT 1.0,

  -- Thresholds
  threshold_green NUMERIC(5,2),
  threshold_amber NUMERIC(5,2),
  threshold_red NUMERIC(5,2),
  direction VARCHAR(20) DEFAULT 'higher_is_worse',

  -- Scope
  applies_to VARCHAR(20) DEFAULT 'both',

  -- Configuration
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Personnel Risk Scores (computed per person)
CREATE TABLE personnel_risk_scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  -- Individual risk factors
  retirement_risk NUMERIC(5,2) DEFAULT 0,
  transfer_risk NUMERIC(5,2) DEFAULT 0,
  talent_loss_risk NUMERIC(5,2) DEFAULT 0,
  vacancy_risk NUMERIC(5,2) DEFAULT 0,
  competency_gap_risk NUMERIC(5,2) DEFAULT 0,
  succession_risk NUMERIC(5,2) DEFAULT 0,

  -- Aggregated
  overall_score NUMERIC(5,2) DEFAULT 0,
  risk_level risk_level DEFAULT 'green',

  -- Detail breakdown
  risk_factors JSONB DEFAULT '{}',

  -- Computation metadata
  computed_at TIMESTAMPTZ DEFAULT NOW(),
  computed_by VARCHAR(100) DEFAULT 'system',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (personnel_id)
);

-- Organization Risk Summary
CREATE TABLE organization_risk_summary (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

  -- Headcount metrics
  total_personnel INTEGER DEFAULT 0,
  total_positions INTEGER DEFAULT 0,
  total_quota INTEGER DEFAULT 0,
  vacancy_count INTEGER DEFAULT 0,
  vacancy_rate NUMERIC(5,2) DEFAULT 0,

  -- Retirement forecast
  retirements_1yr INTEGER DEFAULT 0,
  retirements_3yr INTEGER DEFAULT 0,
  retirements_5yr INTEGER DEFAULT 0,
  retirement_rate_3yr NUMERIC(5,2) DEFAULT 0,

  -- Risk scores
  avg_retirement_risk NUMERIC(5,2) DEFAULT 0,
  avg_transfer_risk NUMERIC(5,2) DEFAULT 0,
  avg_talent_risk NUMERIC(5,2) DEFAULT 0,
  overall_risk_score NUMERIC(5,2) DEFAULT 0,
  risk_level risk_level DEFAULT 'green',

  -- Succession
  critical_positions INTEGER DEFAULT 0,
  positions_without_successor INTEGER DEFAULT 0,
  succession_coverage_rate NUMERIC(5,2) DEFAULT 0,

  -- Competency
  avg_competency_score NUMERIC(5,2) DEFAULT 0,
  competency_gap_rate NUMERIC(5,2) DEFAULT 0,

  -- Detail breakdown
  risk_factors JSONB DEFAULT '{}',
  top_risks JSONB DEFAULT '[]',

  -- Snapshot
  snapshot_date DATE DEFAULT CURRENT_DATE,
  computed_at TIMESTAMPTZ DEFAULT NOW(),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (organization_id, snapshot_date)
);

-- Risk Assessment Snapshots
CREATE TABLE risk_assessments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  personnel_id UUID REFERENCES personnel(id) ON DELETE CASCADE,
  indicator_id UUID REFERENCES risk_indicators(id),

  assessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assessment_period VARCHAR(50),

  -- Results
  indicator_value NUMERIC(10,2),
  risk_level risk_level,
  risk_score NUMERIC(5,2),
  threshold_breached BOOLEAN DEFAULT FALSE,

  -- Context
  notes TEXT,
  assessed_by UUID,
  assessor_name VARCHAR(200),

  -- Supporting data
  details JSONB DEFAULT '{}',

  created_at TIMESTAMPTZ DEFAULT NOW(),

  CHECK ((organization_id IS NOT NULL) OR (personnel_id IS NOT NULL))
);

-- Retirement Forecasts
CREATE TABLE retirement_forecasts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  -- Forecast data
  expected_retirement_date DATE NOT NULL,
  years_remaining NUMERIC(4,1),
  forecast_year INTEGER,

  -- Risk
  is_early_retirement_risk BOOLEAN DEFAULT FALSE,
  early_retirement_risk_score NUMERIC(5,2) DEFAULT 0,

  -- Impact
  is_critical_position BOOLEAN DEFAULT FALSE,
  has_successor BOOLEAN DEFAULT FALSE,
  successor_ready readiness_level DEFAULT 'not_ready',

  -- Notes
  notes TEXT,

  snapshot_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (personnel_id, forecast_year)
);
