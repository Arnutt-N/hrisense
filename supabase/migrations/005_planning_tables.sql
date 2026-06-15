-- ============================================================================
-- HRiSENSE Migration 005: Planning Tables
-- ============================================================================

-- Succession Plans
CREATE TABLE succession_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  position_id UUID NOT NULL REFERENCES positions(id) ON DELETE CASCADE,
  plan_name VARCHAR(300),

  target_date DATE,
  plan_status plan_status DEFAULT 'draft',
  priority VARCHAR(20) DEFAULT 'medium',

  -- Requirements
  required_competencies JSONB DEFAULT '[]',
  required_experience_years INTEGER,
  required_education education_level,

  -- Gap analysis
  current_gaps JSONB DEFAULT '[]',
  development_actions JSONB DEFAULT '[]',

  -- Approval
  created_by UUID,
  approved_by UUID,
  approved_at TIMESTAMPTZ,

  notes TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Succession Plan Candidates
CREATE TABLE succession_plan_candidates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  succession_plan_id UUID NOT NULL REFERENCES succession_plans(id) ON DELETE CASCADE,
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  readiness readiness_level DEFAULT 'not_ready',
  readiness_score NUMERIC(5,2) DEFAULT 0,

  -- Assessment
  strengths JSONB DEFAULT '[]',
  gaps JSONB DEFAULT '[]',
  development_needs JSONB DEFAULT '[]',

  -- Ranking
  ranking INTEGER,
  is_primary BOOLEAN DEFAULT FALSE,

  -- Timeline
  estimated_ready_date DATE,

  notes TEXT,
  assessed_at TIMESTAMPTZ,
  assessed_by UUID,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (succession_plan_id, personnel_id)
);

-- Individual Development Plans (IDP)
CREATE TABLE individual_development_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,

  plan_name VARCHAR(300) NOT NULL,
  plan_year INTEGER,
  plan_status plan_status DEFAULT 'draft',

  -- Goals
  goal_description TEXT,
  goal_type VARCHAR(100),
  target_position VARCHAR(300),

  -- Competencies
  target_competencies JSONB DEFAULT '[]',
  current_competency_level VARCHAR(50),
  target_competency_level VARCHAR(50),

  -- Activities
  activities JSONB DEFAULT '[]',

  -- Timeline
  start_date DATE,
  target_completion_date DATE,
  actual_completion_date DATE,

  -- Assessment
  progress_percentage NUMERIC(5,2) DEFAULT 0,
  last_review_date DATE,
  reviewer_notes TEXT,

  -- Approval
  prepared_by UUID,
  approved_by UUID,
  approved_at TIMESTAMPTZ,

  notes TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workforce Plans (org-level)
CREATE TABLE workforce_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

  plan_name VARCHAR(300) NOT NULL,
  plan_period_start DATE NOT NULL,
  plan_period_end DATE NOT NULL,

  -- Targets
  target_headcount INTEGER,
  target_vacancy_rate NUMERIC(5,2),
  target_retirement_coverage NUMERIC(5,2),
  target_succession_coverage NUMERIC(5,2),

  -- Strategies
  strategies JSONB DEFAULT '[]',
  initiatives JSONB DEFAULT '[]',

  -- Status
  plan_status plan_status DEFAULT 'draft',
  priority VARCHAR(20) DEFAULT 'medium',

  -- Budget
  budget_allocation NUMERIC(15,2),
  budget_used NUMERIC(15,2) DEFAULT 0,

  -- Approval
  prepared_by UUID,
  approved_by UUID,
  approved_at TIMESTAMPTZ,

  notes TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
