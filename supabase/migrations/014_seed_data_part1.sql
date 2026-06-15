-- ============================================================================
-- HRiSENSE Migration 014: Seed Data
-- Realistic Thai Ministry of Justice HR mock data
-- ============================================================================

-- ============================================================================
-- 1. Organizations (hierarchical)
-- ============================================================================
-- Ministry level
INSERT INTO organizations (id, org_code, name_th, name_en, abbreviation_th, abbreviation_en, level, org_type, province, headcount_quota)
VALUES
  ('a0000001-0000-0000-0000-000000000001', 'MOJ', 'กระทรวงยุติธรรม', 'Ministry of Justice', 'ยธ.', 'MOJ', 'ministry', 'ส่วนกลาง', 'กรุงเทพมหานคร', 5000),
  -- Departments
  ('a0000001-0000-0000-0000-000000000002', 'DOP', 'กรมคุ้มครองสิทธิและเสรีภาพ', 'Department of Rights and Liberties Protection', 'คสป.', 'DRLP', 'department', 'ส่วนกลาง', 'กรุงเทพมหานคร', 500),
  ('a0000001-0000-0000-0000-000000000003', 'DOR', 'กรมราชทัณฑ์', 'Department of Corrections', 'รท.', 'DOC', 'department', 'ส่วนกลาง', 'กรุงเทพมหานคร', 2000),
  ('a0000001-0000-0000-0000-000000000004', 'DOL', 'กรมบังคับคดี', 'Legal Execution Department', 'บค.', 'LED', 'department', 'ส่วนกลาง', 'กรุงเทพมหานคร', 800),
  ('a0000001-0000-0000-0000-000000000005', 'DIP', 'กรมทรัพย์สินทางปัญญา', 'Department of Intellectual Property', 'ทรัพย์.', 'DIP', 'department', 'ส่วนกลาง', 'กรุงเทพมหานคร', 400),
  ('a0000001-0000-0000-0000-000000000006', 'DOJ', 'กรมยุติธรรมแห่งประเทศไทย', 'Department of Justice Administration', 'ยธ.', 'DOJ', 'department', 'ส่วนกลาง', 'กรุงเทพมหานคร', 600),
  -- Divisions under DOR (Corrections)
  ('a0000001-0000-0000-0000-000000000010', 'DOR-DIV1', 'กองบริหารงานราชทัณฑ์', 'Corrections Administration Division', 'บก.รท.', 'CAD', 'division', 'ส่วนกลาง', 'กรุงเทพมหานคร', 150),
  ('a0000001-0000-0000-0000-000000000011', 'DOR-DIV2', 'กองบริการทางการแพทย์', 'Medical Services Division', 'กบพ.', 'MSD', 'division', 'ส่วนกลาง', 'กรุงเทพมหานคร', 100),
  -- Divisions under MOJ central
  ('a0000001-0000-0000-0000-000000000020', 'MOJ-DIV1', 'สำนักงานปลัดกระทรวงยุติธรรม', 'Office of the Permanent Secretary', 'สป.ยธ.', 'OPS', 'division', 'ส่วนกลาง', 'กรุงเทพมหานคร', 300),
  ('a0000001-0000-0000-0000-000000000021', 'MOJ-DIV2', 'กองการเจ้าหน้าที่', 'Personnel Division', 'กจ.', 'PD', 'division', 'ส่วนกลาง', 'กรุงเทพมหานคร', 80);

-- Set hierarchy
UPDATE organizations SET parent_id = 'a0000001-0000-0000-0000-000000000001'
WHERE org_code IN ('DOP','DOR','DOL','DIP','DOJ');

UPDATE organizations SET parent_id = 'a0000001-0000-0000-0000-000000000003'
WHERE org_code IN ('DOR-DIV1','DOR-DIV2');

UPDATE organizations SET parent_id = 'a0000001-0000-0000-0000-000000000001'
WHERE org_code IN ('MOJ-DIV1','MOJ-DIV2');

-- Set hierarchy paths
UPDATE organizations SET hierarchy_path = 'MOJ' WHERE org_code = 'MOJ';
UPDATE organizations SET hierarchy_path = 'MOJ.DOP' WHERE org_code = 'DOP';
UPDATE organizations SET hierarchy_path = 'MOJ.DOR' WHERE org_code = 'DOR';
UPDATE organizations SET hierarchy_path = 'MOJ.DOL' WHERE org_code = 'DOL';
UPDATE organizations SET hierarchy_path = 'MOJ.DIP' WHERE org_code = 'DIP';
UPDATE organizations SET hierarchy_path = 'MOJ.DOJ' WHERE org_code = 'DOJ';
UPDATE organizations SET hierarchy_path = 'MOJ.DOR.DIV1' WHERE org_code = 'DOR-DIV1';
UPDATE organizations SET hierarchy_path = 'MOJ.DOR.DIV2' WHERE org_code = 'DOR-DIV2';
UPDATE organizations SET hierarchy_path = 'MOJ.MOJ_DIV1' WHERE org_code = 'MOJ-DIV1';
UPDATE organizations SET hierarchy_path = 'MOJ.MOJ_DIV2' WHERE org_code = 'MOJ-DIV2';

-- ============================================================================
-- 2. Position Types
-- ============================================================================
INSERT INTO position_types (id, code, name_th, name_en, category, sort_order) VALUES
  ('b0000001-0000-0000-0000-000000000001', 'EXEC', 'ตำแหน่งบริหาร', 'Executive Positions', 'บริหาร', 1),
  ('b0000001-0000-0000-0000-000000000002', 'DIR', 'ตำแหน่งอำนวยการ', 'Directorial Positions', 'อำนวยการ', 2),
  ('b0000001-0000-0000-0000-000000000003', 'ACAD', 'ตำแหน่งวิชาการ', 'Academic/Professional Positions', 'วิชาการ', 3),
  ('b0000001-0000-0000-0000-000000000004', 'GEN', 'ตำแหน่งทั่วไป', 'General Positions', 'ทั่วไป', 4),
  ('b0000001-0000-0000-0000-000000000005', 'SENIORDIR', 'ตำแหน่งอำนวยการสูง', 'Senior Directorial', 'อำนวยการสูง', 5);

-- ============================================================================
-- 3. Position Levels
-- ============================================================================
INSERT INTO position_levels (id, code, name_th, name_en, position_type_id, c_level, min_salary, max_salary, sort_order) VALUES
  ('c0000001-0000-0000-0000-000000000001', 'EXEC_HIGH', 'บริหารสูง', 'Senior Executive', 'b0000001-0000-0000-0000-000000000001', 'C11', 75000, 120000, 1),
  ('c0000001-0000-0000-0000-000000000002', 'EXEC_MID', 'บริหารกลาง', 'Middle Executive', 'b0000001-0000-0000-0000-000000000001', 'C9', 55000, 85000, 2),
  ('c0000001-0000-0000-0000-000000000003', 'EXEC_LOW', 'บริหารต้น', 'Junior Executive', 'b0000001-0000-0000-0000-000000000001', 'C8', 42000, 62000, 3),
  ('c0000001-0000-0000-0000-000000000004', 'DIR_HIGH', 'อำนวยการสูง', 'Senior Directorial', 'b0000001-0000-0000-0000-000000000002', 'C9', 55000, 85000, 4),
  ('c0000001-0000-0000-0000-000000000005', 'DIR_MID', 'อำนวยการกลาง', 'Middle Directorial', 'b0000001-0000-0000-0000-000000000002', 'C8', 42000, 62000, 5),
  ('c0000001-0000-0000-0000-000000000006', 'DIR_LOW', 'อำนวยการต้น', 'Junior Directorial', 'b0000001-0000-0000-0000-000000000002', 'C7', 35000, 52000, 6),
  ('c0000001-0000-0000-0000-000000000007', 'ACAD_DISTINGUISHED', 'ทรงคุณวุฒิ', 'Distinguished Expert', 'b0000001-0000-0000-0000-000000000003', 'C9', 55000, 85000, 7),
  ('c0000001-0000-0000-0000-000000000008', 'ACAD_EXPERT', 'เชี่ยวชาญ', 'Expert', 'b0000001-0000-0000-0000-000000000003', 'C8', 42000, 62000, 8),
  ('c0000001-0000-0000-0000-000000000009', 'ACAD_SENIOR', 'ชำนาญการพิเศษ', 'Senior Professional', 'b0000001-0000-0000-0000-000000000003', 'C7', 35000, 52000, 9),
  ('c0000001-0000-0000-0000-000000000010', 'ACAD_PRO', 'ชำนาญการ', 'Professional', 'b0000001-0000-0000-0000-000000000003', 'C6', 28000, 42000, 10),
  ('c0000001-0000-0000-0000-000000000011', 'ACAD_PRACT', 'ปฏิบัติการ', 'Practitioner', 'b0000001-0000-0000-0000-000000000003', 'C5', 15000, 28000, 11),
  ('c0000001-0000-0000-0000-000000000012', 'GEN_SPECIAL', 'ทักษะพิเศษ', 'Special Skill', 'b0000001-0000-0000-0000-000000000004', NULL, 22000, 38000, 12),
  ('c0000001-0000-0000-0000-000000000013', 'GEN_SKILLED', 'ชำนาญงาน', 'Skilled', 'b0000001-0000-0000-0000-000000000004', NULL, 18000, 32000, 13),
  ('c0000001-0000-0000-0000-000000000014', 'GEN_PROF', 'ชำนาญการทั่วไป', 'Professional (General)', 'b0000001-0000-0000-0000-000000000004', NULL, 15000, 28000, 14),
  ('c0000001-0000-0000-0000-000000000015', 'GEN_OPER', 'ปฏิบัติงาน', 'Operator', 'b0000001-0000-0000-0000-000000000004', NULL, 9400, 18000, 15);

-- ============================================================================
-- 4. Position Families
-- ============================================================================
INSERT INTO position_families (id, code, name_th, name_en) VALUES
  ('d0000001-0000-0000-0000-000000000001', 'LEGAL', 'นิติการ', 'Legal'),
  ('d0000001-0000-0000-0000-000000000002', 'FINANCE', 'การเงินและบัญชี', 'Finance and Accounting'),
  ('d0000001-0000-0000-0000-000000000003', 'COMPUTER', 'คอมพิวเตอร์', 'Computer/IT'),
  ('d0000001-0000-0000-0000-000000000004', 'ADMIN_GEN', 'บริหารงานทั่วไป', 'General Administration'),
  ('d0000001-0000-0000-0000-000000000005', 'HR', 'การบริหารงานบุคคล', 'Human Resources'),
  ('d0000001-0000-0000-0000-000000000006', 'CORRECTION', 'ราชทัณฑ์', 'Corrections'),
  ('d0000001-0000-0000-0000-000000000007', 'ENFORCE', 'บังคับคดี', 'Legal Execution'),
  ('d0000001-0000-0000-0000-000000000008', 'IP_LAW', 'ทรัพย์สินทางปัญญา', 'Intellectual Property'),
  ('d0000001-0000-0000-0000-000000000009', 'MEDICAL', 'ทางการแพทย์', 'Medical'),
  ('d0000001-0000-0000-0000-000000000010', 'LANG', 'ภาษา', 'Language/Interpretation');