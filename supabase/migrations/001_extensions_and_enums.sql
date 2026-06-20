-- HRiSENSE Database Schema
-- Migration 001: Extensions, Enums

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "ltree";

-- Core Enums
CREATE TYPE personnel_status AS ENUM ('active', 'transferred_out', 'transferred_in', 'retired', 'resigned', 'deceased', 'dismissed', 'suspended');
CREATE TYPE readiness_level AS ENUM ('ready_now', 'ready_1_2_years', 'ready_3_5_years', 'needs_development', 'not_ready');
CREATE TYPE import_status AS ENUM ('pending', 'processing', 'completed', 'completed_with_errors', 'failed');
CREATE TYPE risk_level AS ENUM ('green', 'amber', 'red');
CREATE TYPE user_role AS ENUM ('admin', 'viewer');

-- Additional Enums
CREATE TYPE org_level AS ENUM ('ministry', 'department', 'bureau', 'division', 'section', 'unit');
CREATE TYPE org_type AS ENUM ('ส่วนกลาง', 'ส่วนภูมิภาค', 'ส่วนท้องถิ่น');
CREATE TYPE position_category AS ENUM ('บริหาร', 'อำนวยการ', 'วิชาการ', 'ทั่วไป', 'บริหารระดับสูง');
CREATE TYPE education_level AS ENUM ('below_bachelors', 'bachelors', 'masters', 'doctorate', 'postdoctorate', 'diploma', 'certificate');
CREATE TYPE risk_category AS ENUM ('retirement', 'transfer', 'talent', 'vacancy', 'succession', 'competency', 'organizational');
CREATE TYPE plan_status AS ENUM ('draft', 'in_progress', 'approved', 'completed', 'archived', 'cancelled');
CREATE TYPE evaluation_rating AS ENUM ('excellent', 'very_good', 'good', 'fair', 'poor');
CREATE TYPE leave_type AS ENUM ('annual', 'sick', 'personal', 'maternity', 'ordination', 'pilgrimage', 'military', 'government_duty', 'moving', 'other');
CREATE TYPE alert_severity AS ENUM ('emergency', 'critical', 'warning', 'info');
CREATE TYPE alert_status AS ENUM ('active', 'acknowledged', 'resolved', 'expired', 'suppressed');

