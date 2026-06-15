-- ============================================================================
-- HRiSENSE Migration 006: History & Records Tables
-- ============================================================================

-- Training Records
CREATE TABLE training_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  course_name VARCHAR(500) NOT NULL,
  course_code VARCHAR(100),
  training_provider VARCHAR(300),
  training_type VARCHAR(100),

  start_date DATE,
  end_date DATE,
  duration_hours NUMERIC(6,1),

  score NUMERIC(5,2),
  grade VARCHAR(20),
  certificate_number VARCHAR(100),
  is_completed BOOLEAN DEFAULT FALSE,

  competency_area VARCHAR(200),
  is_mandatory BOOLEAN DEFAULT FALSE,

  cost NUMERIC(10,2),
  funding_source VARCHAR(100),

  notes TEXT,
  document_url TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Performance Evaluations
CREATE TABLE performance_evaluations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  evaluation_year INTEGER NOT NULL,
  evaluation_period VARCHAR(50),

  overall_score NUMERIC(5,2),
  rating evaluation_rating,

  kpi_score NUMERIC(5,2),
  competency_score NUMERIC(5,2),
  behavior_score NUMERIC(5,2),

  assessor_id UUID REFERENCES personnel(id),
  assessor_name VARCHAR(200),

  strengths TEXT,
  areas_for_improvement TEXT,
  goals TEXT,

  rating_details JSONB DEFAULT '{}',

  evaluation_date DATE,
  approved_at TIMESTAMPTZ,
  approved_by UUID,

  notes TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (personnel_id, evaluation_year, evaluation_period)
);

-- Leave Records
CREATE TABLE leave_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  leave_type leave_type NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  days NUMERIC(4,1) NOT NULL,

  reason TEXT,

  status VARCHAR(20) DEFAULT 'approved',
  approved_by UUID,
  approved_at TIMESTAMPTZ,

  fiscal_year INTEGER,

  notes TEXT,
  document_url TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transfer Records
CREATE TABLE transfer_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  from_organization_id UUID NOT NULL REFERENCES organizations(id),
  to_organization_id UUID NOT NULL REFERENCES organizations(id),
  from_position_id UUID REFERENCES positions(id),
  to_position_id UUID REFERENCES positions(id),

  transfer_type VARCHAR(50),
  reason TEXT,
  order_number VARCHAR(100),
  order_date DATE,
  effective_date DATE NOT NULL,

  from_position_level_id UUID REFERENCES position_levels(id),
  to_position_level_id UUID REFERENCES position_levels(id),

  notes TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
