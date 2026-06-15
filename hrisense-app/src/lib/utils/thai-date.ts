const MONTHS_TH = ['ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.']
const MONTHS_TH_FULL = ['มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม']

export function toThaiDate(adDate: Date | string, fullMonth = false): string {
  const d = typeof adDate === 'string' ? new Date(adDate) : adDate
  const months = fullMonth ? MONTHS_TH_FULL : MONTHS_TH
  return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear() + 543}`
}

export function toBEYear(adYear: number): number {
  return adYear + 543
}

export function fromBEYear(beYear: number): number {
  return beYear - 543
}

export function formatYearBE(adYear: number): string {
  return `พ.ศ. ${adYear + 543}`
}

export function formatRetirementCountdown(retirementDate: string): string {
  const d = new Date(retirementDate)
  const now = new Date()
  const diffMs = d.getTime() - now.getTime()
  const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24))
  const years = Math.floor(diffDays / 365)
  const months = Math.floor((diffDays % 365) / 30)
  const days = diffDays % 30

  if (diffDays < 0) return 'เกษียณแล้ว'
  if (years > 0) return `อีก ${years} ปี ${months} เดือน`
  if (months > 0) return `อีก ${months} เดือน ${days} วัน`
  return `อีก ${days} วัน`
}
