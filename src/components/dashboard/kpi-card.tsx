import { type ReactNode } from 'react'
import Link from 'next/link'
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
  href?: string
}

export function KPICard({ title, value, subtitle, icon, trend, trendValue, colorClass, href }: KPICardProps) {
  const content = (
    <CardContent className="p-6">
      <div className="flex items-start justify-between gap-3">
        <dl className="space-y-2 min-w-0">
          <dt className="text-sm text-muted-foreground">{title}</dt>
          <dd className="text-3xl font-bold text-foreground tabular-nums">{value}</dd>
          {subtitle && <dd className="text-xs text-muted-foreground">{subtitle}</dd>}
          {trend && trendValue && (
            <dd
              className={cn(
                'text-xs font-medium',
                trend === 'up' ? 'text-green-600' : trend === 'down' ? 'text-destructive' : 'text-muted-foreground',
              )}
            >
              <span aria-hidden="true">{trend === 'up' ? '▲' : trend === 'down' ? '▼' : '—'}</span>{' '}
              {trendValue}
            </dd>
          )}
        </dl>
        <div className={cn('p-3 rounded-xl shrink-0', colorClass || 'bg-primary/10')}>{icon}</div>
      </div>
    </CardContent>
  )

  if (href) {
    return (
      <Link
        href={href}
        className="block rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ring-offset-background"
      >
        <Card className="h-full transition-shadow hover:shadow-md">{content}</Card>
      </Link>
    )
  }

  return <Card className="h-full">{content}</Card>
}
