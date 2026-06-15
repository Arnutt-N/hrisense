-- ============================================================================
-- HRiSENSE Migration 008: System Tables
-- ============================================================================

-- Dashboard Configurations
CREATE TABLE dashboard_configs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  name VARCHAR(300) NOT NULL,

  layout JSONB NOT NULL DEFAULT '{}',
  filters JSONB DEFAULT '{}',
  time_range VARCHAR(50),

  is_default BOOLEAN DEFAULT FALSE,
  is_shared BOOLEAN DEFAULT FALSE,
  shared_with JSONB DEFAULT '[]',

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alert Rules
CREATE TABLE alert_rules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(300) NOT NULL,
  description TEXT,

  indicator_id UUID REFERENCES risk_indicators(id),
  condition_type VARCHAR(50),
  condition_config JSONB NOT NULL,

  scope_type VARCHAR(20) DEFAULT 'organization',
  scope_organization_id UUID REFERENCES organizations(id),

  severity alert_severity DEFAULT 'warning',
  is_active BOOLEAN DEFAULT TRUE,
  notify_roles TEXT[] DEFAULT '{}',
  notify_users UUID[] DEFAULT '{}',

  cooldown_minutes INTEGER DEFAULT 60,
  last_triggered_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alerts
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_rule_id UUID REFERENCES alert_rules(id) ON DELETE SET NULL,

  severity alert_severity NOT NULL,
  title VARCHAR(500) NOT NULL,
  message TEXT NOT NULL,

  organization_id UUID REFERENCES organizations(id),
  personnel_id UUID REFERENCES personnel(id),
  indicator_value NUMERIC(10,2),
  threshold_value NUMERIC(10,2),

  status alert_status DEFAULT 'active',
  acknowledged_by UUID,
  acknowledged_at TIMESTAMPTZ,
  resolved_by UUID,
  resolved_at TIMESTAMPTZ,
  resolution_notes TEXT,

  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit Logs
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  user_id UUID,
  user_email VARCHAR(255),
  user_role VARCHAR(50),

  action VARCHAR(50) NOT NULL,
  table_name VARCHAR(100) NOT NULL,
  record_id UUID,

  old_values JSONB,
  new_values JSONB,
  changed_fields TEXT[],

  ip_address INET,
  user_agent TEXT,
  session_id UUID,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- User Profiles (extends Supabase auth.users)
-- ============================================================================

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  employee_number VARCHAR(50),
  prefix_th VARCHAR(50),
  first_name_th VARCHAR(200),
  last_name_th VARCHAR(200),
  prefix_en VARCHAR(50),
  first_name_en VARCHAR(200),
  last_name_en VARCHAR(200),

  role VARCHAR(50) NOT NULL DEFAULT 'viewer',
  department_id UUID REFERENCES organizations(id),
  access_scope VARCHAR(20) DEFAULT 'department',

  language VARCHAR(10) DEFAULT 'th',
  timezone VARCHAR(50) DEFAULT 'Asia/Bangkok',
  notification_preferences JSONB DEFAULT '{}',

  last_login_at TIMESTAMPTZ,
  last_active_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE personnel;
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE organization_risk_summary;
