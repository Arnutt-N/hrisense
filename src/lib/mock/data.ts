// Mock data for local testing

export const mockOrganizations = [
  { id: 'org-1', parent_id: null, org_code: '00', name_th: 'กระทรวงยุติธรรม', abbreviation_th: 'ยธ.', level: 'ministry' },
  { id: 'org-2', parent_id: 'org-1', org_code: '01', name_th: 'สป.กระทรวงยุติธรรม', abbreviation_th: 'สป.ยธ.', level: 'department' },
  { id: 'org-5', parent_id: 'org-2', org_code: '01.01', name_th: 'กองการเจ้าหน้าที่', abbreviation_th: 'กจ.', level: 'division' },
  { id: 'org-6', parent_id: 'org-2', org_code: '01.02', name_th: 'กองเทคโนโลยีสารสนเทศ', abbreviation_th: 'กทส.', level: 'division' },
]

export const mockPersonnel = [
  { id: 'p-1', full_name_th: 'นายสมชาย ใจดี', birth_date: '1967-03-15', retirement_date: '2027-09-30', retirement_years_remaining: 1.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นิติกรเชี่ยวชาญ', position_type: 'วิชาการ', position_level: 'เชี่ยวชาญ', salary: 55000, status: 'active', gender: 'male', overall_risk_score: 85, risk_level: 'red', retirement_risk: 95, transfer_risk: 20, talent_loss_risk: 70, employee_number: 'EMP001', citizen_id: '1100100000001' },
  { id: 'p-2', full_name_th: 'นางสมหญิง รักงาน', birth_date: '1968-07-22', retirement_date: '2028-09-30', retirement_years_remaining: 2.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นิติกรชำนาญการพิเศษ', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', salary: 42000, status: 'active', gender: 'female', overall_risk_score: 72, risk_level: 'red', retirement_risk: 80, transfer_risk: 15, talent_loss_risk: 65, employee_number: 'EMP002', citizen_id: '1100100000002' },
  { id: 'p-3', full_name_th: 'นายวิชัย มั่นคง', birth_date: '1970-01-10', retirement_date: '2030-09-30', retirement_years_remaining: 4.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นิติกรชำนาญการพิเศษ', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', salary: 38000, status: 'active', gender: 'male', overall_risk_score: 55, risk_level: 'amber', retirement_risk: 65, transfer_risk: 25, talent_loss_risk: 50, employee_number: 'EMP003', citizen_id: '1100100000003' },
  { id: 'p-4', full_name_th: 'นางสาวพิมพ์ใจ ดีเลิศ', birth_date: '1971-05-18', retirement_date: '2031-09-30', retirement_years_remaining: 5.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นักวิชาการเงินและบัญชี', position_type: 'วิชาการ', position_level: 'ชำนาญการ', salary: 30000, status: 'active', gender: 'female', overall_risk_score: 42, risk_level: 'amber', retirement_risk: 55, transfer_risk: 20, talent_loss_risk: 45, employee_number: 'EMP004', citizen_id: '1100100000004' },
  { id: 'p-5', full_name_th: 'นายประเสริฐ ยิ่งยง', birth_date: '1972-11-03', retirement_date: '2032-09-30', retirement_years_remaining: 6.3, organization_id: 'org-6', organization_name: 'กองเทคโนโลยีสารสนเทศ', position_name: 'นักวิชาการคอมพิวเตอร์ชำนาญการพิเศษ', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', salary: 40000, status: 'active', gender: 'male', overall_risk_score: 48, risk_level: 'amber', retirement_risk: 50, transfer_risk: 30, talent_loss_risk: 55, employee_number: 'EMP005', citizen_id: '1100100000005' },
  { id: 'p-6', full_name_th: 'นางสุดา ศรีสุข', birth_date: '1973-08-25', retirement_date: '2033-09-30', retirement_years_remaining: 7.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นักทรัพยากรบุคคลชำนาญการพิเศษ', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', salary: 38000, status: 'active', gender: 'female', overall_risk_score: 35, risk_level: 'amber', retirement_risk: 45, transfer_risk: 15, talent_loss_risk: 40, employee_number: 'EMP006', citizen_id: '1100100000006' },
  { id: 'p-7', full_name_th: 'นายณัฐชา อนันตวิเชียร', birth_date: '1985-02-14', retirement_date: '2045-09-30', retirement_years_remaining: 19.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นักทรัพยากรบุคคลชำนาญการพิเศษ', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', salary: 35000, status: 'active', gender: 'female', overall_risk_score: 28, risk_level: 'green', retirement_risk: 15, transfer_risk: 20, talent_loss_risk: 35, employee_number: 'EMP007', citizen_id: '1100100000007' },
  { id: 'p-8', full_name_th: 'นายอนุชา รักชาติ', birth_date: '1983-06-30', retirement_date: '2043-09-30', retirement_years_remaining: 17.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นิติกรชำนาญการ', position_type: 'วิชาการ', position_level: 'ชำนาญการ', salary: 28000, status: 'active', gender: 'male', overall_risk_score: 22, risk_level: 'green', retirement_risk: 18, transfer_risk: 15, talent_loss_risk: 28, employee_number: 'EMP008', citizen_id: '1100100000008' },
  { id: 'p-9', full_name_th: 'นางสาวกัญญา พัฒน์ดี', birth_date: '1988-09-12', retirement_date: '2048-09-30', retirement_years_remaining: 22.3, organization_id: 'org-6', organization_name: 'กองเทคโนโลยีสารสนเทศ', position_name: 'นักวิชาการคอมพิวเตอร์ชำนาญการ', position_type: 'วิชาการ', position_level: 'ชำนาญการ', salary: 25000, status: 'active', gender: 'female', overall_risk_score: 18, risk_level: 'green', retirement_risk: 10, transfer_risk: 12, talent_loss_risk: 25, employee_number: 'EMP009', citizen_id: '1100100000009' },
  { id: 'p-10', full_name_th: 'นายธนกฤต สุขสำราญ', birth_date: '1980-04-05', retirement_date: '2040-09-30', retirement_years_remaining: 14.3, organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_name: 'นักวิเคราะห์นโยบายและแผน', position_type: 'วิชาการ', position_level: 'ชำนาญการ', salary: 26000, status: 'active', gender: 'male', overall_risk_score: 25, risk_level: 'green', retirement_risk: 20, transfer_risk: 18, talent_loss_risk: 30, employee_number: 'EMP010', citizen_id: '1100100000010' },
]

export const mockRetirementTimeline = mockPersonnel.map(p => ({
  personnel_id: p.id, employee_number: p.employee_number, full_name_th: p.full_name_th,
  birth_date: p.birth_date, retirement_date: p.retirement_date,
  retirement_years_remaining: p.retirement_years_remaining,
  organization_id: p.organization_id, organization_name: p.organization_name,
  position_name: p.position_name, position_level: p.position_level,
  is_critical_position: p.salary > 40000,
  retirement_bucket: p.retirement_years_remaining <= 1 ? 'within_1_year' : p.retirement_years_remaining <= 3 ? 'within_3_years' : p.retirement_years_remaining <= 5 ? 'within_5_years' : 'over_5_years',
  has_ready_successor: p.id === 'p-1' || p.id === 'p-2',
}))

export const mockVacancyAnalysis = [
  { position_id: 'pos-1', position_code: 'LEG-EX-001', position_name: 'นิติกรเชี่ยวชาญ', organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_type: 'วิชาการ', position_level: 'เชี่ยวชาญ', quota: 1, current_occupancy: 1, vacancy_count: 0, vacancy_rate_pct: 0, is_critical: true, has_succession_plan: true },
  { position_id: 'pos-2', position_code: 'LEG-SP-001', position_name: 'นิติกรชำนาญการพิเศษ', organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', quota: 2, current_occupancy: 2, vacancy_count: 0, vacancy_rate_pct: 0, is_critical: true, has_succession_plan: true },
  { position_id: 'pos-3', position_code: 'COM-SP-001', position_name: 'นักวิชาการคอมพิวเตอร์ชำนาญการพิเศษ', organization_id: 'org-6', organization_name: 'กองเทคโนโลยีสารสนเทศ', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', quota: 1, current_occupancy: 1, vacancy_count: 0, vacancy_rate_pct: 0, is_critical: true, has_succession_plan: true },
  { position_id: 'pos-4', position_code: 'COM-PR-001', position_name: 'นักวิชาการคอมพิวเตอร์ชำนาญการ', organization_id: 'org-6', organization_name: 'กองเทคโนโลยีสารสนเทศ', position_type: 'วิชาการ', position_level: 'ชำนาญการ', quota: 2, current_occupancy: 1, vacancy_count: 1, vacancy_rate_pct: 50, is_critical: false, has_succession_plan: false },
  { position_id: 'pos-5', position_code: 'GEN-SP-001', position_name: 'นักทรัพยากรบุคคลชำนาญการพิเศษ', organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', position_type: 'วิชาการ', position_level: 'ชำนาญการพิเศษ', quota: 1, current_occupancy: 1, vacancy_count: 0, vacancy_rate_pct: 0, is_critical: true, has_succession_plan: true },
]

export const mockOrgDashboard = mockOrganizations
  .filter(o => o.level === 'division')
  .map(org => {
    const personnel = mockPersonnel.filter(p => p.organization_id === org.id)
    const positions = mockVacancyAnalysis.filter(v => v.organization_id === org.id)
    const totalQuota = positions.reduce((s, v) => s + v.quota, 0)
    const totalVacant = positions.reduce((s, v) => s + v.vacancy_count, 0)
    const avgRisk = personnel.length > 0 ? personnel.reduce((s, p) => s + (p.overall_risk_score || 0), 0) / personnel.length : 0
    let riskLevel = 'green'
    if (avgRisk >= 70) riskLevel = 'red'
    else if (avgRisk >= 40) riskLevel = 'amber'
    return {
      organization_id: org.id, org_code: org.org_code, name_th: org.name_th,
      abbreviation_th: org.abbreviation_th, level: org.level,
      total_personnel: personnel.length, total_quota: totalQuota,
      vacancy_count: totalVacant, vacancy_rate: totalQuota > 0 ? (totalVacant / totalQuota) * 100 : 0,
      overall_risk_score: avgRisk, risk_level: riskLevel,
      retirements_1yr: personnel.filter(p => (p.retirement_years_remaining || 99) <= 1).length,
      retirements_3yr: personnel.filter(p => (p.retirement_years_remaining || 99) <= 3).length,
      retirements_5yr: personnel.filter(p => (p.retirement_years_remaining || 99) <= 5).length,
    }
  })

export const mockHighRiskPersonnel = mockPersonnel
  .filter(p => p.overall_risk_score >= 40)
  .sort((a, b) => (b.overall_risk_score || 0) - (a.overall_risk_score || 0))
  .map(p => ({ ...p, primary_risk_driver: p.retirement_risk > p.talent_loss_risk ? 'retirement' : 'talent_loss' }))

export const mockActiveAlerts = [
  { id: 'alert-1', severity: 'critical', title: 'ตำแหน่งสำคัญว่าง', message: 'ไม่มีผู้สืบทอดพร้อม', organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', personnel_id: null, personnel_name: null, created_at: '2026-06-10T08:00:00', age_hours: 120 },
  { id: 'alert-2', severity: 'warning', title: 'บุคลากรเกษียณภายใน 1 ปี', message: 'นายสมชาย ใจดี จะเกษียณ', organization_id: 'org-5', organization_name: 'กองการเจ้าหน้าที่', personnel_id: 'p-1', personnel_name: 'นายสมชาย ใจดี', created_at: '2026-06-12T10:00:00', age_hours: 72 },
  { id: 'alert-3', severity: 'warning', title: 'อัตราการว่างสูงเกิน 30%', message: 'กองเทคโนโลยีสารสนเทศ อัตราว่าง 50%', organization_id: 'org-6', organization_name: 'กองเทคโนโลยีสารสนเทศ', personnel_id: null, personnel_name: null, created_at: '2026-06-13T14:00:00', age_hours: 48 },
]

export const mockWorkforceComposition = mockOrganizations
  .filter(o => o.level === 'division')
  .map(org => {
    const personnel = mockPersonnel.filter(p => p.organization_id === org.id && p.status === 'active')
    return {
      organization_id: org.id, organization_name: org.name_th,
      exec_count: 0, director_count: 0,
      academic_count: personnel.filter(p => p.position_type === 'วิชาการ').length,
      general_count: 0,
      male_count: personnel.filter(p => p.gender === 'male').length,
      female_count: personnel.filter(p => p.gender === 'female').length,
      doctorate_count: 0, masters_count: Math.floor(personnel.length * 0.4),
      bachelors_count: Math.floor(personnel.length * 0.6),
      near_retirement_count: personnel.filter(p => (p.retirement_years_remaining || 99) <= 5).length,
      mid_career_count: personnel.filter(p => { const r = p.retirement_years_remaining || 99; return r > 5 && r <= 15 }).length,
      early_career_count: personnel.filter(p => (p.retirement_years_remaining || 99) > 15).length,
      total_active: personnel.length,
    }
  })
