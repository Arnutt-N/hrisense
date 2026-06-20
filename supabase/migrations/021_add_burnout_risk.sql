-- ============================================================================
-- Migration 021: Add Burnout Risk Analysis
-- ============================================================================
-- เพิ่มระบบวิเคราะห์ความเสี่ยงเหนื่อยล้า (Burnout)
-- ใช้ข้อมูลพฤติกรรมและผลงานจริงในการคำนวณ ไม่ใช่ค่าสุ่ม
--
-- ปัจจัย 6 อย่าง (ถ่วงน้ำหนักรวม 100%):
--   1. การมาสาย (late_days_ytd)         15%  — มาก = เสี่ยงสูง
--   2. การขาดงาน (absent_days_ytd)      15%  — มาก = เสี่ยงสูง
--   3. ผลการประเมิน (performance_score)  20%  — ต่ำ = เสี่ยงสูง (invert)
--   4. ชั่วโมงล่วงเวลา (overtime_hours)  20%  — มาก = เสี่ยงสูง
--   5. การฝึกอบรม (training_hours)       10%  — มาก = เสี่ยงลด (protective, invert)
--   6. ดัชนีภาระงาน (workload_index)     20%  — สูง = เสี่ยงสูง
-- ============================================================================

-- 1. ตารางเก็บปัจจัย Burnout (raw inputs) ต่อปี
CREATE TABLE IF NOT EXISTS personnel_burnout_factors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  personnel_id UUID NOT NULL REFERENCES personnel(id) ON DELETE CASCADE,
  year INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,

  -- ปัจจัย 6 อย่าง
  late_days_ytd INTEGER NOT NULL DEFAULT 0,          -- จำนวนวันมาสาย (max ~20)
  absent_days_ytd INTEGER NOT NULL DEFAULT 0,        -- จำนวนวันขาดงาน (max ~15)
  performance_score NUMERIC(5,2) NOT NULL DEFAULT 75, -- คะแนนประเมิน 0-100 (ต่ำ=เสี่ยง)
  overtime_hours_ytd NUMERIC(6,1) NOT NULL DEFAULT 0,-- ชั่วโมงล่วงเวลา (max ~240)
  training_hours_ytd NUMERIC(6,1) NOT NULL DEFAULT 0,-- ชั่วโมงอบรม (max ~40, protective)
  workload_index NUMERIC(5,2) NOT NULL DEFAULT 50,   -- ดัชนีภาระงาน 0-100

  -- Metadata
  assessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assessor_notes TEXT,

  UNIQUE(personnel_id, year)
);

CREATE INDEX IF NOT EXISTS idx_burnout_personnel ON personnel_burnout_factors(personnel_id);
CREATE INDEX IF NOT EXISTS idx_burnout_year ON personnel_burnout_factors(year);

COMMENT ON TABLE personnel_burnout_factors IS
  'ปัจจัยเสี่ยงเหนื่อยล้า (Burnout) ต่อปี ใช้คำนวณ burnout_risk';

-- 2. เพิ่มคอลัมน์ burnout_risk ใน personnel_risk_scores
ALTER TABLE personnel_risk_scores
  ADD COLUMN IF NOT EXISTS burnout_risk NUMERIC(5,2);

-- 3. Function คำนวณ burnout score จาก factors
CREATE OR REPLACE FUNCTION calculate_burnout_risk(p_personnel_id UUID, p_year INTEGER DEFAULT NULL)
RETURNS NUMERIC(5,2)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_late INTEGER;
  v_absent INTEGER;
  v_performance NUMERIC(5,2);
  v_overtime NUMERIC(6,1);
  v_training NUMERIC(6,1);
  v_workload NUMERIC(5,2);
  v_year INTEGER;
  v_burnout NUMERIC(5,2);
BEGIN
  v_year := COALESCE(p_year, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

  -- ดึงข้อมูลปัจจัย (ใช้ปีล่าสุดถ้าไม่ระบุ)
  SELECT
    late_days_ytd, absent_days_ytd, performance_score,
    overtime_hours_ytd, training_hours_ytd, workload_index
  INTO v_late, v_absent, v_performance, v_overtime, v_training, v_workload
  FROM personnel_burnout_factors
  WHERE personnel_id = p_personnel_id AND year = v_year;

  -- ถ้าไม่มีข้อมูล → return NULL
  IF v_late IS NULL THEN
    RETURN NULL;
  END IF;

  -- Normalize ทุกปัจจัยเป็น 0-100 แล้วถ่วงน้ำหนัก
  -- late: 0-20 days → 0-100
  -- absent: 0-15 days → 0-100
  -- performance: 0-100 (invert: ต่ำ = เสี่ยงสูง) → 100 - score
  -- overtime: 0-240 hours → 0-100
  -- training: 0-40 hours (invert: มาก = ป้องกัน) → 100 - normalized
  -- workload: 0-100 index → 0-100
  v_burnout :=
    LEAST(100, (v_late::NUMERIC / 20) * 100) * 0.15 +
    LEAST(100, (v_absent::NUMERIC / 15) * 100) * 0.15 +
    (100 - LEAST(100, v_performance)) * 0.20 +
    LEAST(100, (v_overtime / 240) * 100) * 0.20 +
    (100 - LEAST(100, (v_training / 40) * 100)) * 0.10 +
    LEAST(100, v_workload) * 0.20;

  RETURN ROUND(v_burnout, 2);
END;
$$;

-- 4. Function คำนวณ burnout ทั้งหมด (batch) สำหรับ personnel ที่ active
CREATE OR REPLACE FUNCTION update_all_burnout_risks(p_year INTEGER DEFAULT NULL)
RETURNS INTEGER
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_year INTEGER;
  v_count INTEGER := 0;
  v_rec RECORD;
BEGIN
  v_year := COALESCE(p_year, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

  FOR v_rec IN
    SELECT p.id AS personnel_id
    FROM personnel p
    JOIN personnel_burnout_factors bf ON bf.personnel_id = p.id AND bf.year = v_year
    WHERE p.status = 'active'
  LOOP
    UPDATE personnel_risk_scores
    SET burnout_risk = calculate_burnout_risk(v_rec.personnel_id, v_year),
        computed_at = NOW()
    WHERE personnel_id = v_rec.personnel_id;

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

-- 5. View: burnout factors + score สำหรับแต่ละคน
CREATE OR REPLACE VIEW v_burnout_analysis AS
SELECT
  p.id AS personnel_id,
  (p.prefix_th || ' ' || p.first_name_th || ' ' || p.last_name_th) AS full_name_th,
  p.organization_id,
  o.name_th AS organization_name,
  bf.year,
  bf.late_days_ytd,
  bf.absent_days_ytd,
  bf.performance_score,
  bf.overtime_hours_ytd,
  bf.training_hours_ytd,
  bf.workload_index,
  calculate_burnout_risk(p.id, bf.year) AS burnout_risk,
  CASE
    WHEN calculate_burnout_risk(p.id, bf.year) >= 75 THEN 'critical'
    WHEN calculate_burnout_risk(p.id, bf.year) >= 50 THEN 'high'
    WHEN calculate_burnout_risk(p.id, bf.year) >= 25 THEN 'moderate'
    ELSE 'low'
  END AS burnout_level,
  bf.assessed_at,
  bf.assessor_notes
FROM personnel p
JOIN organizations o ON o.id = p.organization_id
JOIN personnel_burnout_factors bf ON bf.personnel_id = p.id
WHERE p.status = 'active';

COMMENT ON VIEW v_burnout_analysis IS
  'วิเคราะห์ความเสี่ยงเหนื่อยล้า (Burnout) ของบุคลากรแต่ละคน';

-- 6. View: burnout summary per organization
CREATE OR REPLACE VIEW v_org_burnout_summary AS
SELECT
  o.id AS organization_id,
  o.name_th AS organization_name,
  COUNT(ba.personnel_id) AS total_assessed,
  ROUND(AVG(ba.burnout_risk), 2) AS avg_burnout_risk,
  COUNT(*) FILTER (WHERE ba.burnout_risk >= 75) AS critical_count,
  COUNT(*) FILTER (WHERE ba.burnout_risk >= 50 AND ba.burnout_risk < 75) AS high_count,
  COUNT(*) FILTER (WHERE ba.burnout_risk >= 25 AND ba.burnout_risk < 50) AS moderate_count,
  COUNT(*) FILTER (WHERE ba.burnout_risk < 25) AS low_count,
  ROUND(AVG(ba.late_days_ytd), 1) AS avg_late_days,
  ROUND(AVG(ba.absent_days_ytd), 1) AS avg_absent_days,
  ROUND(AVG(ba.performance_score), 1) AS avg_performance,
  ROUND(AVG(ba.overtime_hours_ytd), 1) AS avg_overtime_hours,
  ROUND(AVG(ba.training_hours_ytd), 1) AS avg_training_hours,
  ROUND(AVG(ba.workload_index), 1) AS avg_workload_index
FROM organizations o
JOIN v_burnout_analysis ba ON ba.organization_id = o.id
WHERE ba.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
GROUP BY o.id, o.name_th;

COMMENT ON VIEW v_org_burnout_summary IS
  'สรุปความเสี่ยง Burnout ต่อหน่วยงาน';

-- 7. Grant permissions
GRANT SELECT ON personnel_burnout_factors TO authenticated;
GRANT SELECT ON v_burnout_analysis TO authenticated;
GRANT SELECT ON v_org_burnout_summary TO authenticated;
