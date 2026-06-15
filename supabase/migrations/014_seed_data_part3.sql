-- ============================================================================
-- HRiSENSE Seed Data Part 3: Risk Indicators, History, Alerts, Workforce Allocations
-- ============================================================================

-- ============================================================================
-- Risk Indicator Definitions
-- ============================================================================
INSERT INTO risk_indicators (code, name_th, name_en, category, formula_type, weight, threshold_green, threshold_amber, threshold_red, direction, applies_to) VALUES
  ('VACANCY_RATE', 'อัตราการว่างของตำแหน่ง', 'Vacancy Rate', 'vacancy', 'simple', 0.15, 5.00, 15.00, 25.00, 'higher_is_worse', 'organization'),
  ('RETIREMENT_1Y', 'จำนวนเกษียณภายใน 1 ปี', 'Retirements within 1 Year', 'retirement', 'simple', 0.25, 2.00, 5.00, 10.00, 'higher_is_worse', 'organization'),
  ('RETIREMENT_3Y', 'จำนวนเกษียณภายใน 3 ปี', 'Retirements within 3 Years', 'retirement', 'simple', 0.20, 5.00, 10.00, 20.00, 'higher_is_worse', 'organization'),
  ('SUCCESSION_COVERAGE', 'อัตราครอบคลุมการสืบทอดตำแหน่ง', 'Succession Coverage Rate', 'succession_gap', 'simple', 0.20, 80.00, 50.00, 25.00, 'lower_is_worse', 'organization'),
  ('TALENT_FLIGHT_RISK', 'ความเสี่ยงสูญเสียบุคลากรที่มีความสามารถ', 'Talent Flight Risk', 'talent_loss', 'simple', 0.15, 10.00, 30.00, 50.00, 'higher_is_worse', 'both'),
  ('RETIREMENT_YEARS_LEFT', 'ปีจนถึงเกษียณ', 'Years to Retirement', 'retirement', 'simple', 0.30, 10.00, 5.00, 2.00, 'lower_is_worse', 'personnel'),
  ('TRANSFER_FREQUENCY', 'ความถี่ในการโยกย้าย', 'Transfer Frequency', 'transfer', 'simple', 0.10, 1.00, 3.00, 5.00, 'higher_is_worse', 'personnel'),
  ('CRITICAL_POSITION_VACANT', 'ตำแหน่งสำคัญที่ว่าง', 'Critical Positions Vacant', 'vacancy', 'simple', 0.15, 0.00, 1.00, 3.00, 'higher_is_worse', 'organization'),
  ('COMPETENCY_GAP', 'ช่องว่างสมรรถนะ', 'Competency Gap Rate', 'competency_gap', 'simple', 0.10, 10.00, 25.00, 40.00, 'higher_is_worse', 'organization'),
  ('WORKLOAD_OVERLOAD', 'ภาระงานเกินกำลัง', 'Workload Overload', 'workload', 'composite', 0.05, 10.00, 25.00, 40.00, 'higher_is_worse', 'organization');

-- ============================================================================
-- Workforce Allocations (current assignments)
-- ============================================================================
INSERT INTO workforce_allocations (personnel_id, position_id, effective_date, is_current, assignment_type)
SELECT id, current_position_id, position_appointment_date, true, 'permanent'
FROM personnel
WHERE current_position_id IS NOT NULL AND status = 'active';

-- ============================================================================
-- Performance Evaluations (recent years)
-- ============================================================================
INSERT INTO performance_evaluations (personnel_id, evaluation_year, evaluation_period, overall_score, rating, kpi_score, competency_score, behavior_score, assessor_name, evaluation_date) VALUES
  -- Somchai (near retirement, high performer)
  ('f0000001-0000-0000-0000-000000000001', 2024, 'Annual', 4.80, 'excellent', 4.90, 4.70, 4.80, 'นายกรัฐมนตรี', '2025-01-15'),
  ('f0000001-0000-0000-0000-000000000001', 2023, 'Annual', 4.70, 'excellent', 4.80, 4.60, 4.70, 'นายกรัฐมนตรี', '2024-01-15'),
  -- Nattawadee (young high performer)
  ('f0000001-0000-0000-0000-000000000005', 2024, 'Annual', 4.50, 'excellent', 4.60, 4.40, 4.50, 'อธิบดีกรมคุ้มครองสิทธิฯ', '2025-01-20'),
  ('f0000001-0000-0000-0000-000000000005', 2023, 'Annual', 4.30, 'very_good', 4.40, 4.20, 4.30, 'อธิบดีกรมคุ้มครองสิทธิฯ', '2024-01-20'),
  -- Wichai (IT expert)
  ('f0000001-0000-0000-0000-000000000004', 2024, 'Annual', 4.60, 'excellent', 4.70, 4.50, 4.60, 'ปลัดกระทรวงยุติธรรม', '2025-01-18'),
  -- Weera (DOP DG)
  ('f0000001-0000-0000-0000-000000000025', 2024, 'Annual', 4.20, 'very_good', 4.30, 4.10, 4.20, 'ปลัดกระทรวงยุติธรรม', '2025-01-15'),
  -- Thanakorn (DOR DG)
  ('f0000001-0000-0000-0000-000000000006', 2024, 'Annual', 4.00, 'very_good', 4.10, 3.90, 4.00, 'ปลัดกระทรวงยุติธรรม', '2025-01-15'),
  -- Suda (DOL, near retirement)
  ('f0000001-0000-0000-0000-000000000010', 2024, 'Annual', 4.10, 'very_good', 4.20, 4.00, 4.10, 'อธิบดีกรมบังคับคดี', '2025-01-20'),
  -- Kanya (young IP professional)
  ('f0000001-0000-0000-0000-000000000012', 2024, 'Annual', 4.40, 'very_good', 4.50, 4.30, 4.40, 'อธิบดีกรมทรัพย์สินทางปัญญา', '2025-01-20'),
  -- Kitti (young IT)
  ('f0000001-0000-0000-0000-000000000016', 2024, 'Annual', 4.30, 'very_good', 4.40, 4.20, 4.30, 'ผู้เชี่ยวชาญด้านไอที', '2025-01-22'),
  -- Piyanut (young IT female)
  ('f0000001-0000-0000-0000-000000000017', 2024, 'Annual', 4.50, 'excellent', 4.60, 4.40, 4.50, 'ผู้เชี่ยวชาญด้านไอที', '2025-01-22'),
  -- Suree (finance, near retirement)
  ('f0000001-0000-0000-0000-000000000018', 2024, 'Annual', 4.20, 'very_good', 4.30, 4.10, 4.20, 'ปลัดกระทรวงยุติธรรม', '2025-01-15');

-- ============================================================================
-- Training Records
-- ============================================================================
INSERT INTO training_records (personnel_id, course_name, training_provider, training_type, start_date, end_date, duration_hours, is_completed, competency_area) VALUES
  ('f0000001-0000-0000-0000-000000000004', 'Data Analytics for Government', 'สำนักงาน ก.พ.', 'external', '2024-06-01', '2024-06-05', 40, true, 'technology'),
  ('f0000001-0000-0000-0000-000000000004', 'AI/ML for Public Sector', 'มหาวิทยาลัยธรรมศาสตร์', 'external', '2024-09-01', '2024-09-10', 60, true, 'technology'),
  ('f0000001-0000-0000-0000-000000000005', 'Executive Leadership Program', 'สถาบันดำรงราชานุภาพ', 'internal', '2024-03-01', '2024-03-15', 80, true, 'leadership'),
  ('f0000001-0000-0000-0000-000000000016', 'Cloud Computing (AWS)', 'AWS Training', 'online', '2024-07-01', '2024-07-31', 40, true, 'technology'),
  ('f0000001-0000-0000-0000-000000000017', 'Cybersecurity Fundamentals', 'CompTIA', 'online', '2024-08-01', '2024-08-15', 30, true, 'technology'),
  ('f0000001-0000-0000-0000-000000000012', 'IP Law Advanced Workshop', 'WIPO', 'external', '2024-05-10', '2024-05-15', 40, true, 'legal'),
  ('f0000001-0000-0000-0000-000000000023', 'HR Analytics', 'สำนักงาน ก.พ.', 'external', '2024-04-01', '2024-04-03', 24, true, 'hr'),
  ('f0000001-0000-0000-0000-000000000024', 'Strategic Corrections Management', 'กรมราชทัณฑ์', 'internal', '2024-02-01', '2024-02-05', 40, true, 'corrections');

-- ============================================================================
-- Leave Records (recent year)
-- ============================================================================
INSERT INTO leave_records (personnel_id, leave_type, start_date, end_date, days, status, fiscal_year) VALUES
  ('f0000001-0000-0000-0000-000000000001', 'annual', '2024-04-10', '2024-04-15', 5, 'approved', 2024),
  ('f0000001-0000-0000-0000-000000000005', 'study', '2024-08-01', '2024-08-10', 8, 'approved', 2024),
  ('f0000001-0000-0000-0000-000000000016', 'annual', '2024-12-25', '2024-12-31', 5, 'approved', 2024),
  ('f0000001-0000-0000-0000-000000000017', 'sick', '2024-06-10', '2024-06-12', 2, 'approved', 2024),
  ('f0000001-0000-0000-0000-000000000007', 'annual', '2024-01-15', '2024-01-19', 4, 'approved', 2024);

-- ============================================================================
-- Transfer Records (history)
-- ============================================================================
INSERT INTO transfer_records (personnel_id, from_organization_id, to_organization_id, transfer_type, reason, effective_date) VALUES
  -- Thanakrit transferred 3 times in 5 years (high transfer risk)
  ('f0000001-0000-0000-0000-000000000021', 'a0000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000004', 'permanent', 'โยกย้ายตามคำสั่ง', '2019-04-01'),
  ('f0000001-0000-0000-0000-000000000021', 'a0000001-0000-0000-0000-000000000004', 'a0000001-0000-0000-0000-000000000005', 'permanent', 'โยกย้ายตามคำสั่ง', '2021-10-01'),
  ('f0000001-0000-0000-0000-000000000021', 'a0000001-0000-0000-0000-000000000005', 'a0000001-0000-0000-0000-000000000021', 'permanent', 'โยกย้ายตามคำสั่ง', '2024-01-15'),
  -- Bonsong retired
  ('f0000001-0000-0000-0000-000000000022', 'a0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000001', 'permanent', 'เกษียณอายุราชการ', '2023-09-30');

-- ============================================================================
-- Succession Plans (for critical positions)
-- ============================================================================
INSERT INTO succession_plans (id, position_id, plan_name, plan_status, priority, target_date) VALUES
  ('e0000002-0000-0000-0000-000000000001', 'e0000001-0000-0000-0000-000000000001', 'แผนสืบทอดตำแหน่งปลัดกระทรวง', 'in_progress', 'critical', '2027-09-30'),
  ('e0000002-0000-0000-0000-000000000002', 'e0000001-0000-0000-0000-000000000030', 'แผนสืบทอดตำแหน่งอธิบดีกรมราชทัณฑ์', 'draft', 'critical', '2027-09-30'),
  ('e0000002-0000-0000-0000-000000000003', 'e0000001-0000-0000-0000-000000000070', 'แผนสืบทอดตำแหน่งผู้เชี่ยวชาญไอที', 'approved', 'high', '2026-12-31'),
  ('e0000002-0000-0000-0000-000000000004', 'e0000001-0000-0000-0000-000000000033', 'แผนสืบทอดตำแหน่งผู้อำนวยการกองบริการทางการแพทย์', 'draft', 'critical', '2026-06-30'),
  ('e0000002-0000-0000-0000-000000000005', 'e0000001-0000-0000-0000-000000000041', 'แผนสืบทอดตำแหน่งนักวิชาการบังคับคดีอาวุโส', 'proposed', 'high', '2027-03-31');

-- Succession candidates
INSERT INTO succession_plan_candidates (succession_plan_id, personnel_id, readiness, readiness_score, ranking, is_primary) VALUES
  -- Permanent Secretary succession
  ('e0000002-0000-0000-0000-000000000001', 'f0000001-0000-0000-0000-000000000002', 'ready_1_2_years', 75.00, 1, true),
  ('e0000002-0000-0000-0000-000000000001', 'f0000001-0000-0000-0000-000000000025', 'ready_3_5_years', 55.00, 2, false),
  -- DOR DG succession (no ready candidates - gap)
  ('e0000002-0000-0000-0000-000000000002', 'f0000001-0000-0000-0000-000000000024', 'ready_3_5_years', 50.00, 1, true),
  -- IT Expert succession
  ('e0000002-0000-0000-0000-000000000003', 'f0000001-0000-0000-0000-000000000004', 'ready_1_2_years', 72.00, 1, true),
  ('e0000002-0000-0000-0000-000000000003', 'f0000001-0000-0000-0000-000000000016', 'ready_3_5_years', 45.00, 2, false),
  -- Medical Division (vacant - no candidates yet)
  -- DOL succession
  ('e0000002-0000-0000-0000-000000000005', 'f0000001-0000-0000-0000-000000000010', 'ready_now', 80.00, 1, true);

-- ============================================================================
-- Individual Development Plans
-- ============================================================================
INSERT INTO individual_development_plans (personnel_id, plan_name, plan_year, plan_status, goal_type, goal_description, start_date, target_completion_date, progress_percentage) VALUES
  ('f0000001-0000-0000-0000-000000000004', 'พัฒนาสู่ระดับทรงคุณวุฒิ', 2025, 'in_progress', 'career', 'เตรียมความพร้อมสำหรับระดับทรงคุณวุฒิ', '2025-01-01', '2026-12-31', 25.00),
  ('f0000001-0000-0000-0000-000000000005', 'พัฒนาภาวะผู้นำระดับบริหาร', 2025, 'in_progress', 'competency', 'เสริมสร้างสมรรถนะการบริหาร', '2025-01-01', '2027-12-31', 15.00),
  ('f0000001-0000-0000-0000-000000000016', 'พัฒนาทักษะ Cloud Architecture', 2025, 'in_progress', 'skill', 'ได้รับการรับรอง AWS Solutions Architect', '2025-01-01', '2025-12-31', 40.00),
  ('f0000001-0000-0000-0000-000000000017', 'พัฒนาทักษะ Data Science', 2025, 'draft', 'skill', 'เรียนรู้ Machine Learning และ AI', '2025-06-01', '2026-06-01', 0.00),
  ('f0000001-0000-0000-0000-000000000024', 'พัฒนาสู่ระดับอธิบดี', 2025, 'in_progress', 'career', 'เตรียมความพร้อมสำหรับตำแหน่งบริหารสูง', '2025-01-01', '2028-12-31', 20.00),
  ('f0000001-0000-0000-0000-000000000019', 'พัฒนาสมรรถนะนิติกรอาวุโส', 2025, 'approved', 'competency', 'มุ่งสู่ระดับชำนาญการพิเศษ', '2025-04-01', '2028-12-31', 10.00);

-- ============================================================================
-- Alert Rules
-- ============================================================================
INSERT INTO alert_rules (name, description, condition_type, condition_config, scope_type, severity, is_active, cooldown_minutes) VALUES
  ('อัตราการว่างวิกฤต', 'แจ้งเตือนเมื่ออัตราว่างเกิน 20%', 'threshold',
   '{"metric": "vacancy_rate", "operator": ">=", "value": 20}'::jsonb,
   'organization', 'critical', true, 1440),
  ('เกษียณจำนวนมาก', 'แจ้งเตือนเมื่อมีเกษียณเกิน 5 คนใน 3 ปี', 'threshold',
   '{"metric": "retirements_3yr", "operator": ">=", "value": 5}'::jsonb,
   'organization', 'warning', true, 10080),
  ('ตำแหน่งสำคัญว่าง', 'แจ้งเตือนเมื่อตำแหน่งสำคัญว่าง', 'threshold',
   '{"metric": "critical_vacant", "operator": ">=", "value": 1}'::jsonb,
   'organization', 'critical', true, 1440);

-- ============================================================================
-- Sample Alerts (triggered from seed data)
-- ============================================================================
INSERT INTO alerts (alert_rule_id, severity, title, message, organization_id, indicator_value, threshold_value, status) VALUES
  (NULL, 'critical', 'ตำแหน่งสำคัญว่าง: กองบริการทางการแพทย์', 'ตำแหน่งผู้อำนวยการกองบริการทางการแพทย์ (DOR-MED-001) ไม่มีผู้ดำรงตำแหน่ง',
   'a0000001-0000-0000-0000-000000000011', 1, 1, 'active'),
  (NULL, 'warning', 'ความเสี่ยงเกษียณสูง: กรมบังคับคดี', 'นางสุดา พิทักษ์ธรรม จะเกษียณภายใน 1.2 ปี ไม่มีการเตรียมสืบทอดตำแหน่ง',
   'a0000001-0000-0000-0000-000000000004', 1.2, 2.0, 'active'),
  (NULL, 'critical', 'ความเสี่ยงเกษียณ: ปลัดกระทรวงยุติธรรม', 'นายสมชาย รักความยุติธรรม จะเกษียณภายใน 1.5 ปี',
   'a0000001-0000-0000-0000-000000000001', 1.5, 2.0, 'acknowledged'),
  (NULL, 'warning', 'อัตราการโยกย้ายสูง: นายธนกฤต ย้ายบ่อย', 'มีการโยกย้าย 3 ครั้งใน 5 ปี แสดงถึงความไม่มั่นคง',
   'a0000001-0000-0000-0000-000000000021', 3, 3, 'active'),
  (NULL, 'warning', 'ความเสี่ยงบุคลากร: กรมคุ้มครองสิทธิฯ', 'ณัฐวดี เก่งกาจ เป็นบุคลากรระดับสูง อาจสูญเสียหากไม่มีแผนรักษา',
   'a0000001-0000-0000-0000-000000000002', 1, 1, 'active');

-- ============================================================================
-- Workforce Plans
-- ============================================================================
INSERT INTO workforce_plans (organization_id, plan_name, plan_period_start, plan_period_end, target_headcount, target_vacancy_rate, plan_status, priority) VALUES
  ('a0000001-0000-0000-0000-000000000001', 'แผนกำลังคนกระทรวงยุติธรรม 2568-2570', '2025-10-01', '2027-09-30', 5000, 5.00, 'approved', 'high'),
  ('a0000001-0000-0000-0000-000000000003', 'แผนกำลังคนกรมราชทัณฑ์ 2568-2570', '2025-10-01', '2027-09-30', 2000, 3.00, 'in_progress', 'high'),
  ('a0000001-0000-0000-0000-000000000005', 'แผนกำลังคนกรมทรัพย์สินทางปัญญา 2568-2570', '2025-10-01', '2027-09-30', 400, 8.00, 'draft', 'medium');

-- ============================================================================
-- Retirement Forecasts
-- ============================================================================
INSERT INTO retirement_forecasts (personnel_id, expected_retirement_date, years_remaining, forecast_year, is_critical_position, has_successor, successor_ready, notes)
SELECT
  id,
  retirement_date,
  retirement_years_remaining,
  EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
  CASE WHEN current_position_id IN (SELECT id FROM positions WHERE is_critical = true) THEN true ELSE false END,
  CASE WHEN EXISTS(SELECT 1 FROM succession_plan_candidates spc WHERE spc.personnel_id = personnel.id AND spc.readiness IN ('ready_now', 'ready_1_2_years')) THEN true ELSE false END,
  COALESCE(
    (SELECT spc.readiness FROM succession_plan_candidates spc WHERE spc.personnel_id = personnel.id AND spc.readiness IN ('ready_now', 'ready_1_2_years') LIMIT 1),
    'not_ready'::readiness_level
  ),
  CASE
    WHEN retirement_years_remaining <= 2 THEN 'เร่งด่วน - ต้องดำเนินการทันที'
    WHEN retirement_years_remaining <= 5 THEN 'เตรียมแผนสืบทอดตำแหน่ง'
    ELSE 'ติดตามตามปกติ'
  END
FROM personnel
WHERE status = 'active'
  AND retirement_years_remaining IS NOT NULL
  AND retirement_years_remaining <= 10;