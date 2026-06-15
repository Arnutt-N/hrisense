import { type ReactNode } from 'react'
import { cn } from '@/lib/utils/cn'
import { Card, CardContent } from '@/components/ui/card'

interface KPICardProps {
  title: string
  value: string | number
  subtitle?: string
  icon: ReactNode
  trend?: 'up' | 'down' | 'neutral'
  trendValue?: string
  colorClass?: string
}

export function KPICard({ title, value, subtitle, icon, trend, trendValue, colorClass }: KPICardProps) {
  return (
    <Card>
      <CardContent className="p-6">
        <div className="flex items-start justify-between">
          <div className="space-y-2">
            <p className="text-sm text-muted-foreground">{title}</p>
            <p className="text-3xl font-bold text-foreground">{value}</p>
            {subtitle && <p className="text-xs text-muted-foreground">{subtitle}</p>}
            {trend && trendValue && (
              <p className={cn('text-xs font-medium', trend === 'up' ? 'text-green-600' : trend === 'down' ? 'text-destructive' : 'text-muted-foreground')}>
                {trend === 'up' ? '▲' : trend === 'down' ? '▼' : '—'} {trendValue}
              </p>
            )}
          </div>
          <div className={cn('p-3 rounded-xl', colorClass || 'bg-primary/10')}>{icon}</div>
        </div>
      </CardContent>
    </Card>
  )
}
