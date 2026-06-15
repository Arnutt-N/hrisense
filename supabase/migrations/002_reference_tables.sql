-- ============================================================================
-- HRiSENSE Migration 002: Core Reference Tables
-- ============================================================================

-- Organizations (hierarchical)
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  parent_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  org_code VARCHAR(50) UNIQUE NOT NULL,
  name_th VARCHAR(500) NOT NULL,
  name_en VARCHAR(500),
  abbreviation_th VARCHAR(100),
  abbreviation_en VARCHAR(100),
  level org_level NOT NULL DEFAULT 'division',
  org_type org_type DEFAULT 'ส่วนกลาง',
  address TEXT,
  province VARCHAR(100) DEFAULT 'กรุงเทพมหานคร',
  phone VARCHAR(50),
  email VARCHAR(255),
  website VARCHAR(500),
  headcount_quota INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  hierarchy_path ltree,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Position Types
CREATE TABLE position_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name_th VARCHAR(200) NOT NULL,
  name_en VARCHAR(200),
  description TEXT,
  category position_category NOT NULL,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Position Levels
CREATE TABLE position_levels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name_th VARCHAR(200) NOT NULL,
  name_en VARCHAR(200),
  position_type_id UUID REFERENCES position_types(id),
  c_level VARCHAR(10),
  min_salary NUMERIC(12,2),
  max_salary NUMERIC(12,2),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Position Families (สายงาน)
CREATE TABLE position_families (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name_th VARCHAR(200) NOT NULL,
  name_en VARCHAR(200),
  description TEXT,
  parent_family_id UUID REFERENCES position_families(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Salary Scales
CREATE TABLE salary_scales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  position_level_id UUID REFERENCES position_levels(id),
  position_type_id UUID REFERENCES position_types(id),
  step INTEGER NOT NULL,
  min_salary NUMERIC(12,2) NOT NULL,
  max_salary NUMERIC(12,2),
  effective_date DATE NOT NULL,
  expiry_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(position_level_id, position_type_id, step)
);
