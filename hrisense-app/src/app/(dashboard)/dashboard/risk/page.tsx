import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { RiskBadge } from '@/components/personnel/risk-badge'
import { cn } from '@/lib/utils/cn'

export const dynamic = 'force-dynamic'

export default async function RiskPage() {
  const supabase = await createServerSupabaseClient()
  const [orgData, highRiskData] = await Promise.all([
    supabase.from('v_org_dashboard').select('*'),
    supabase.from('v_high_risk_personnel').select('*').limit(20),
  ])
  const orgs = orgData.data || []
  const avgScore = orgs.length > 0 ? orgs.reduce((s:number,o:any)=>s+(o.overall_risk_score||0),0)/orgs.length : 0
  const redOrgs = orgs.filter((o:any)=>o.risk_level==='red'||o.risk_level==='critical').length
  const amberOrgs = orgs.filter((o:any)=>o.risk_level==='amber').length
  const greenOrgs = orgs.filter((o:any)=>o.risk_level==='green').length
  const cellBg = (s:number|null) => !s ? 'bg-gray-100' : s>=75 ? 'bg-red-200 text-red-900' : s>=50 ? 'bg-orange-200 text-orange-900' : s>=25 ? 'bg-amber-100 text-amber-900' : 'bg-green-100 text-green-900'

  return (
    <div className="space-y-6">
      <div><h1 className="text-2xl font-bold">วิเคราะห์ความเสี่ยง</h1><p className="text-muted-foreground text-sm mt-1">ภาพรวมความเสี่ยงด้านกำลังคน</p></div>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">คะแนนเฉลี่ย</p><p className="text-2xl font-bold">{avgScore.toFixed(1)}</p></CardContent></Card>
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">เสี่ยงสูง</p><p className="text-2xl font-bold text-red-600">{redOrgs}</p></CardContent></Card>
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">เฝ้าระวัง</p><p className="text-2xl font-bold text-amber-600">{amberOrgs}</p></CardContent></Card>
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">ปกติ</p><p className="text-2xl font-bold text-green-600">{greenOrgs}</p></CardContent></Card>
      </div>
      <Card>
        <CardHeader><CardTitle>แผนที่ความร้อนความเสี่ยง</CardTitle></CardHeader>
        <CardContent className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="border-b"><th className="text-left py-2 px-3">หน่วยงาน</th><th className="text-center py-2 px-3 text-muted-foreground">เกษียณ</th><th className="text-center py-2 px-3 text-muted-foreground">โอนย้าย</th><th className="text-center py-2 px-3 text-muted-foreground">ทาเลนท์</th><th className="text-center py-2 px-3 text-muted-foreground">อัตราว่าง</th><th className="text-center py-2 px-3 text-muted-foreground">สืบทอด</th><th className="text-center py-2 px-3 font-bold">รวม</th></tr></thead>
            <tbody>{orgs.map((o:any)=>(
              <tr key={o.organization_id} className="border-b hover:bg-muted/30">
                <td className="py-2 px-3 font-medium">{o.name_th}</td>
                <td className={cn('text-center py-2 px-3 rounded',cellBg(null))}>—</td>
                <td className={cn('text-center py-2 px-3 rounded',cellBg(null))}>—</td>
                <td className={cn('text-center py-2 px-3 rounded',cellBg(null))}>—</td>
                <td className={cn('text-center py-2 px-3 rounded',cellBg(o.vacancy_rate))}>{o.vacancy_rate?.toFixed(0)||'—'}</td>
                <td className={cn('text-center py-2 px-3 rounded',cellBg(null))}>—</td>
                <td className={cn('text-center py-2 px-3 font-bold rounded',cellBg(o.overall_risk_score))}>{o.overall_risk_score?.toFixed(0)||'—'}</td>
              </tr>
            ))}</tbody>
          </table>
        </CardContent>
      </Card>
      <Card>
        <CardHeader><CardTitle>บุคลากรเสี่ยงสูง</CardTitle></CardHeader>
        <CardContent className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="border-b"><th className="text-left py-2 px-3 text-muted-foreground">ชื่อ</th><th className="text-left py-2 px-3 text-muted-foreground">หน่วยงาน</th><th className="text-left py-2 px-3 text-muted-foreground">ความเสี่ยง</th><th className="text-left py-2 px-3 text-muted-foreground">สาเหตุ</th><th className="text-right py-2 px-3 text-muted-foreground">คะแนน</th></tr></thead>
            <tbody>{highRiskData.data?.map((p:any)=>(
              <tr key={p.id} className="border-b hover:bg-muted/50">
                <td className="py-2 px-3 font-medium">{p.full_name_th}</td>
                <td className="py-2 px-3 text-muted-foreground">{p.organization_name}</td>
                <td className="py-2 px-3"><RiskBadge level={p.risk_level} score={p.overall_risk_score}/></td>
                <td className="py-2 px-3 text-muted-foreground">{p.primary_risk_driver||'—'}</td>
                <td className="py-2 px-3 text-right font-mono">{p.overall_risk_score?.toFixed(0)}</td>
              </tr>
            ))}</tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  )
}
