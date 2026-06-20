export type RiskLevel = 'green' | 'amber' | 'red' | 'critical'

export const riskColorMap: Record<RiskLevel, string> = {
  green: 'bg-green-100 text-green-800 border-green-200',
  amber: 'bg-amber-100 text-amber-800 border-amber-200',
  red: 'bg-red-100 text-red-800 border-red-200',
  critical: 'bg-red-600 text-white border-red-700',
}

export const riskDotMap: Record<RiskLevel, string> = {
  green: 'bg-green-500',
  amber: 'bg-amber-500',
  red: 'bg-red-500',
  critical: 'bg-red-700',
}

export const riskLabelTh: Record<RiskLevel, string> = {
  green: 'ปกติ',
  amber: 'เฝ้าระวัง',
  red: 'เสี่ยงสูง',
  critical: 'วิกฤต',
}

export function getRiskLevel(score: number): RiskLevel {
  if (score > 80) return 'critical'
  if (score > 60) return 'red'
  if (score > 40) return 'amber'
  return 'green'
}

export const riskChartColors = {
  green: '#22c55e',
  amber: '#f59e0b',
  red: '#ef4444',
  critical: '#991b1b',
} as const
