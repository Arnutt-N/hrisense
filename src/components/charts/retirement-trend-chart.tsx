'use client'

import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts'

interface RetirementTrendChartProps {
  data: Array<{
    year: string
    count: number
    color?: string
  }>
  className?: string
}

export function RetirementTrendChart({ data, className }: RetirementTrendChartProps) {
  const getColor = (index: number) => {
    const colors = ['#ef4444', '#f59e0b', '#eab308']
    return colors[index % colors.length]
  }

  const ariaLabel = `แผนภูมิแท่งแนวโน้มการเกษียณอายุ: ${data
    .map((d) => `ปี ${d.year} จำนวน ${d.count} คน`)
    .join(', ')}`

  return (
    <div className={className} role="img" aria-label={ariaLabel}>
      <ResponsiveContainer width="100%" height={200}>
        <BarChart data={data} margin={{ top: 5, right: 5, left: 5, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
          <XAxis
            dataKey="year"
            tick={{ fontSize: 12, fill: '#64748b' }}
            axisLine={{ stroke: '#e2e8f0' }}
            tickLine={false}
          />
          <YAxis
            tick={{ fontSize: 12, fill: '#64748b' }}
            axisLine={{ stroke: '#e2e8f0' }}
            tickLine={false}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: '#ffffff',
              border: '1px solid #e2e8f0',
              borderRadius: '0.5rem',
              fontSize: '0.875rem',
            }}
            formatter={(value: number) => [`${value} คน`, 'จำนวน']}
            labelFormatter={(label) => `ปี ${label}`}
          />
          <Bar dataKey="count" radius={[4, 4, 0, 0]}>
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color || getColor(index)} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
