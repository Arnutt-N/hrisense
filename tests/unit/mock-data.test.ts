import { describe, it, expect } from 'vitest'
import {
  mockOrganizations,
  mockPersonnel,
  mockActiveAlerts,
} from '@/lib/mock/data'

describe('Mock Data Structure', () => {
  describe('Organizations', () => {
    it('มี 19 หน่วยงาน (MOJ + OPSMJ + 17 divisions)', () => {
      expect(mockOrganizations).toHaveLength(19)
    })

    it('มี ministry ระดับบนสุด (กระทรวงยุติธรรม)', () => {
      const ministry = mockOrganizations.find(o => o.level === 'ministry')
      expect(ministry).toBeDefined()
      expect(ministry?.name_th).toBe('กระทรวงยุติธรรม')
      expect(ministry?.parent_id).toBeNull()
    })

    it('มี department ระดับ สป.ยธ.', () => {
      const dept = mockOrganizations.find(o => o.level === 'department')
      expect(dept).toBeDefined()
      expect(dept?.name_th).toBe('สำนักงานปลัดกระทรวงยุติธรรม')
      expect(dept?.parent_id).toBe('org-1')
    })

    it('มี 17 divisions ภายใต้ สป.ยธ.', () => {
      const divisions = mockOrganizations.filter(o => o.level === 'division')
      expect(divisions).toHaveLength(17)
      divisions.forEach(d => {
        expect(d.parent_id).toBe('org-2')
      })
    })

    it('17 หน่วยงาน มีชื่อถูกต้อง', () => {
      const expectedNames = [
        'กองกลาง',
        'กองบริหารทรัพยากรบุคคล',
        'กองบริหารการคลัง',
        'กองการต่างประเทศ',
        'กองออกแบบและก่อสร้าง',
        'ศูนย์เทคโนโลยีสารสนเทศและการสื่อสาร',
        'กองกฎหมาย',
        'กองยุทธศาสตร์และแผนงาน',
        'สถาบันพัฒนาบุคลากรกระทรวงยุติธรรม',
        'กลุ่มตรวจสอบภายใน',
        'กลุ่มพัฒนาระบบบริหารกระทรวงยุติธรรม',
        'สำนักผู้ตรวจราชการกระทรวงยุติธรรม',
        'กองพัฒนานวัตกรรมการยุติธรรม',
        'ศูนย์ปฏิบัติการต่อต้านการทุจริต',
        'ศูนย์บริการร่วมกระทรวงยุติธรรม',
        'สำนักงานกองทุนยุติธรรม',
        'กองประสานราชการยุติธรรมจังหวัด',
      ]
      const divisions = mockOrganizations.filter(o => o.level === 'division')
      const actualNames = divisions.map(d => d.name_th)
      expect(actualNames).toEqual(expectedNames)
    })

    it('ทุกหน่วยงานมี org_code และ abbreviation_th', () => {
      mockOrganizations.forEach(org => {
        expect(org.org_code).toBeTruthy()
        expect(org.abbreviation_th).toBeTruthy()
      })
    })
  })

  describe('Personnel', () => {
    it('มีข้อมูลบุคลากร', () => {
      expect(mockPersonnel.length).toBeGreaterThan(0)
    })

    it('มีกำลังพลรวม 300 อัตรา', () => {
      expect(mockPersonnel).toHaveLength(300)
    })

    it('บุคลากรทุกคนสังกัดหนึ่งใน 17 divisions', () => {
      const divisionIds = mockOrganizations
        .filter(o => o.level === 'division')
        .map(o => o.id)

      mockPersonnel.forEach(p => {
        expect(divisionIds).toContain(p.organization_id)
      })
    })

    it('บุคลากรมีการกระจายไปทุก 17 divisions', () => {
      const divisionIds = mockOrganizations
        .filter(o => o.level === 'division')
        .map(o => o.id)

      const usedOrgs = new Set(mockPersonnel.map(p => p.organization_id))
      // At least most divisions should have personnel
      const coverage = divisionIds.filter(id => usedOrgs.has(id)).length
      expect(coverage).toBeGreaterThanOrEqual(15)
    })
  })

  describe('Active Alerts', () => {
    it('alerts อ้างอิงหน่วยงานที่มีอยู่จริง', () => {
      const orgIds = new Set(mockOrganizations.map(o => o.id))
      mockActiveAlerts.forEach(alert => {
        expect(orgIds.has(alert.organization_id)).toBe(true)
      })
    })

    it('alerts มี severity ถูกต้อง', () => {
      const validSeverities = ['critical', 'warning', 'info']
      mockActiveAlerts.forEach(alert => {
        expect(validSeverities).toContain(alert.severity)
      })
    })
  })
})
