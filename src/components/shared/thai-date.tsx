import { toThaiDate } from '@/lib/utils/thai-date'

interface ThaiDateProps { date: string | Date | null; format?: 'full' | 'short' | 'year' }

export function ThaiDate({ date, format = 'full' }: ThaiDateProps) {
  if (!date) return <span className="text-muted-foreground">{'—'}</span>
  const d = typeof date === 'string' ? new Date(date) : date
  if (isNaN(d.getTime())) return <span className="text-muted-foreground">{'—'}</span>
  if (format === 'year') return <span>{d.getFullYear() + 543}</span>
  if (format === 'short') return <span>{`${d.getDate()}/${d.getMonth()+1}/${d.getFullYear() + 543}`}</span>
  return <span>{toThaiDate(d)}</span>
}
