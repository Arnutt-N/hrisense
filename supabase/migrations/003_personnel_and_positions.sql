-- ============================================================================
-- HRiSENSE Migration 003: Personnel & Position Tables
-- ============================================================================

-- Personnel (full HR records)
CREATE TABLE personnel (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  citizen_id VARCHAR(13) UNIQUE NOT NULL,
  prefix_th VARCHAR(50),
  first_name_th VARCHAR(200) NOT NULL,
  last_name_th VARCHAR(200) NOT NULL,
  prefix_en VARCHAR(50),
  first_name_en VARCHAR(200),
  last_name_en VARCHAR(200),
  nickname VARCHAR(100),

  -- Dates
  birth_date DATE NOT NULL,
  birth_date_be VARCHAR(20),
  government_start_date DATE,
  government_start_date_be VARCHAR(20),
  position_appointment_date DATE,
  last_promotion_date DATE,
  retirement_date DATE GENERATED ALWAYS AS (
    birth_date + INTERVAL '60 years'
  ) STORED,

  -- Organizational assignment
  organization_id UUID NOT NULL REFERENCES organizations(id),

  -- Position details
  position_type_id UUID REFERENCES position_types(id),
  position_level_id UUID REFERENCES position_levels(id),
  position_family_id UUID REFERENCES position_families(id),

  -- Employment details
  employee_number VARCHAR(50) UNIQUE,
  salary NUMERIC(12,2),
  salary_step INTEGER,
  rank_or_title VARCHAR(200),

  -- Education
  education_level education_level,
  degree_name VARCHAR(300),
  university VARCHAR(300),
  major VARCHAR(200),
  gpa NUMERIC(3,2),

  -- Contact
  email VARCHAR(255),
  phone VARCHAR(50),
  mobile VARCHAR(50),
  address TEXT,

  -- Status
  status personnel_status DEFAULT 'active',
  status_reason TEXT,
  status_effective_date DATE,

  -- Additional
  gender VARCHAR(20),
  blood_type VARCHAR(5),
  disability_status BOOLEAN DEFAULT FALSE,
  military_service_completed BOOLEAN DEFAULT FALSE,

  -- Risk computed fields (updated by triggers/functions)
  retirement_years_remaining NUMERIC(4,1),
  overall_risk_score NUMERIC(5,2),
  risk_level risk_level DEFAULT 'green',

  -- Metadata
  metadata JSONB DEFAULT '{}',
  photo_url TEXT,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Positions (position master)
CREATE TABLE positions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  position_code VARCHAR(50) UNIQUE NOT NULL,
  name_th VARCHAR(500) NOT NULL,
  name_en VARCHAR(500),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  position_type_id UUID REFERENCES position_types(id),
  position_level_id UUID REFERENCES position_levels(id),
  position_family_id UUID REFERENCES position_families(id),

  -- Headcount
  quota INTEGER DEFAULT 1,
  current_occupancy INTEGER DEFAULT 0,
  vacancy_count INTEGER GENERATED ALWAYS AS (
    quota - current_occupancy
  ) STORED,

  -- Classification
  is_critical BOOLEAN DEFAULT FALSE,
  is_sensitive BOOLEAN DEFAULT FALSE,
  is_special VARCHAR(100),

  -- Requirements
  required_education education_level,
  required_experience_years INTEGER,
  required_competencies JSONB DEFAULT '[]',

  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  effective_date DATE,

  -- Metadata
  description TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK from personnel to positions (after both tables exist)
ALTER TABLE personnel ADD COLUMN IF NOT EXISTS current_position_id UUID REFERENCES positions(id) ON DELETE SET NULL;

-- Workforce Allocations (personnel-to-position assignment with history)
CREATE TABLE workforce_allocations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,
  position_id UUID NOT NULL REFERENCES positions(id) ON DELETE CASCADE,
  effective_date DATE NOT NULL,
  end_date DATE,
  is_current BOOLEAN DEFAULT FALSE,
  assignment_type VARCHAR(50) DEFAULT 'permanent',
  allocation_order INTEGER DEFAULT 1,

  -- Change tracking
  reason TEXT,
  order_number VARCHAR(100),
  order_date DATE,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (personnel_id, is_current)
);

CREATE INDEX idx_allocations_current ON workforce_allocations(personnel_id)
  WHERE is_current = TRUE;
