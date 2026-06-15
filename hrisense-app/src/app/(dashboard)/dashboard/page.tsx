import { createServerSupabaseClient } from '@/lib/supabase/server'
import { KPICard } from '@/components/dashboard/kpi-card'
import { RiskBadge } from '@/components/personnel/risk-badge'
import { Users, TrendingDown, CalendarClock, AlertTriangle } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export const dynamic = 'force-dynamic'

export default async function DashboardPage() {
  const supabase = await createServerSupabaseClient()

  const [orgData, retirementData, highRiskData, alertData] = await Promise.all([
    supabase.from('v_org_dashboard').select('*'),
    supabase.from('v_retirement_timeline').select('retirement_date, retirement_years_remaining, retirement_bucket, is_critical_position').limit(500),
    supabase.from('v_high_risk_personnel').select('*').limit(10),
    supabase.from('v_active_alerts').select('*').limit(10),
  ])

  const orgs = orgData.data || []
  const totalHeadcount = orgs.reduce((sum: number, o: any) => sum + (o.total_personnel || 0), 0)
  const totalQuota = orgs.reduce((sum: number, o: any) => sum + (o.total_quota || 0), 0)
  const totalVacant = orgs.reduce((sum: number, o: any) => sum + (o.vacancy_count || 0), 0)
  const vacancyRate = totalQuota > 0 ? ((totalVacant / totalQuota) * 100).toFixed(1) : '0'
  const retiring3yr = orgs.reduce((sum: number, o: any) => sum + (o.retirements_3yr || 0), 0)
  const highRiskCount = highRiskData.data?.length || 0
  const alertCount = alertData.data?.length || 0

  const retirementByYear: Record<number, number> = {}
  retirementData.data?.forEach((r: any) => {
    if (r.retirement_date) {
      const year = new Date(r.retirement_date).getFullYear() + 543
      retirementByYear[year] = (retirementByYear[year] || 0) + 1
    }
  })
  const sortedYears = Object.entries(retirementByYear).sort(([a], [b]) => Number(a) - Number(b)).slice(0, 6)
  const maxCount = Math.max(...Object.values(retirementByYear), 1)

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">แดชบอร์ดหลัก</h1>
        <p className="text-muted-foreground text-sm mt-1">ภาพรวมสถานการณ์กำลังคนและความเสี่ยง</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <KPICard title="กำลังพลทั้งหมด" value={totalHeadcount.toLocaleString()} subtitle={`อัตรา ${totalQuota.toLocaleString()} | ว่าง ${totalVacant}`} icon={<Users className="w-5 h-5 text-primary" />} />
        <KPICard title="อัตราว่าง" value={`${vacancyRate}%`} subtitle={`${totalVacant} ตำแหน่ง`} icon={<TrendingDown className="w-5 h-5 text-amber-600" />} colorClass="bg-amber-50" />
        <KPICard title="เกษียณใน 3 ปี" value={retiring3yr} subtitle="คน" icon={<CalendarClock className="w-5 h-5 text-red-600" />} colorClass="bg-red-50" />
        <KPICard title="บุคลากรเสี่ยงสูง" value={highRiskCount} subtitle={`แจ้งเตือน ${alertCount} รายการ`} icon={<AlertTriangle className="w-5 h-5 text-destructive" />} colorClass="bg-destructive/10" />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Retirement Timeline */}
        <Card>
          <CardHeader><CardTitle>แนวโน้มการเกษียณอายุ (พ.ศ.)</CardTitle></CardHeader>
          <CardContent>
            <div className="h-64 flex items-end justify-around gap-2">
              {sortedYears.map(([year, count]) => (
                <div key={year} className="flex flex-col items-center gap-1 flex-1">
                  <div className="w-full bg-red-500 rounded-t-lg transition-all hover:bg-red-600" style={{ height: `${(count / maxCount) * 180}px` }} />
                  <span className="text-xs text-muted-foreground">{year}</span>
                  <span className="text-xs font-medium">{count}</span>
                </div>
              ))}
              {sortedYears.length === 0 && <p className="text-sm text-muted-foreground">ไม่มีข้อมูล</p>}
            </div>
          </CardContent>
        </Card>

        {/* Active Alerts */}
        <Card>
          <CardHeader><CardTitle>การแจ้งเตือนล่าสุด</CardTitle></CardHeader>
          <CardContent>
            <div className="space-y-3 max-h-64 overflow-y-auto">
              {alertData.data?.length === 0 && <p className="text-sm text-muted-foreground text-center py-8">ไม่มีการแจ้งเตือน</p>}
              {alertData.data?.map((alert: any) => (
                <div key={alert.id} className="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
                  <span className={`w-2 h-2 rounded-full mt-2 shrink-0 ${alert.severity === 'emergency' || alert.severity === 'critical' ? 'bg-red-500' : alert.severity === 'warning' ? 'bg-amber-500' : 'bg-blue-500'}`} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{alert.title}</p>
                    <p className="text-xs text-muted-foreground truncate">{alert.organization_name || 'ทั้งองค์กร'}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* High Risk Personnel Table */}
      <Card>
        <CardHeader><CardTitle>บุคลากรที่มีความเสี่ยงสูง</CardTitle></CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2 px-3 text-muted-foreground font-medium">ชื่อ-นามสกุล</th>
                  <th className="text-left py-2 px-3 text-muted-foreground font-medium">หน่วยงาน</th>
                  <th className="text-left py-2 px-3 text-muted-foreground font-medium">ตำแหน่ง</th>
                  <th className="text-left py-2 px-3 text-muted-foreground font-medium">ความเสี่ยง</th>
                  <th className="text-right py-2 px-3 text-muted-foreground font-medium">คะแนน</th>
                </tr>
              </thead>
              <tbody>
                {highRiskData.data?.map((p: any) => (
                  <tr key={p.id} className="border-b hover:bg-muted/50 transition">
                    <td className="py-2 px-3 font-medium">{p.full_name_th}</td>
                    <td className="py-2 px-3 text-muted-foreground">{p.organization_name}</td>
                    <td className="py-2 px-3 text-muted-foreground">{p.position_name || '—'}</td>
                    <td className="py-2 px-3"><RiskBadge level={p.risk_level} score={p.overall_risk_score} /></td>
                    <td className="py-2 px-3 text-right font-mono">{p.overall_risk_score?.toFixed(0) || '—'}</td>
                  </tr>
                ))}
                {(!highRiskData.data || highRiskData.data.length === 0) && (
                  <tr><td colSpan={5} className="py-8 text-center text-muted-foreground">ไม่พบข้อมูล</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
