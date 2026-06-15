import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { RiskBadge } from '@/components/personnel/risk-badge'
import { ThaiDate } from '@/components/shared/thai-date'

export const dynamic = 'force-dynamic'

export default async function PersonnelDetailPage({ params }: { params: { id: string } }) {
  const supabase = await createServerSupabaseClient()
  const { data: person } = await supabase
    .from('v_personnel_overview')
    .select('*')
    .eq('id', params.id)
    .single() as { data: any }

  if (!person) return <div className="p-6 text-center text-muted-foreground">ไม่พบข้อมูล</div>

  return (
    <div className="space-y-6">
      <div><h1 className="text-2xl font-bold">{person.full_name_th}</h1><p className="text-muted-foreground text-sm">{person.organization_name} | {person.position_name || 'ไม่มีตำแหน่ง'}</p></div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card><CardHeader><CardTitle>ข้อมูลส่วนตัว</CardTitle></CardHeader>
          <CardContent className="space-y-3 text-sm">
            <div className="flex justify-between"><span className="text-muted-foreground">เลขบัตรประชาชน</span><span>{person.citizen_id}</span></div>
            <div className="flex justify-between"><span className="text-muted-foreground">วันเกิด</span><span><ThaiDate date={person.birth_date}/></span></div>
            <div className="flex justify-between"><span className="text-muted-foreground">วันเกษียณ</span><span><ThaiDate date={person.retirement_date}/></span></div>
            <div className="flex justify-between"><span className="text-muted-foreground">เงินเดือน</span><span>{person.salary ? person.salary.toLocaleString() + ' บาท' : '—'}</span></div>
          </CardContent>
        </Card>
        <Card><CardHeader><CardTitle>ประเมินความเสี่ยง</CardTitle></CardHeader>
          <CardContent className="space-y-4">
            <div className="text-center py-4">
              <RiskBadge level={person.risk_level} score={person.overall_risk_score} size="md" />
              <p className="text-3xl font-bold mt-2">{person.overall_risk_score?.toFixed(0) || '—'}</p>
              <p className="text-xs text-muted-foreground">คะแนนความเสี่ยงรวม</p>
            </div>
            <div className="space-y-2">{[{l:'เกษียณ',v:person.retirement_risk},{l:'โอนย้าย',v:person.transfer_risk},{l:'ทาเลนท์',v:person.talent_loss_risk}].map((f: any) => (
              <div key={f.l}><div className="flex justify-between text-sm"><span>{f.l}</span><span>{f.v?.toFixed(0)||'—'}</span></div><div className="h-2 bg-muted rounded-full mt-1"><div className="h-full rounded-full bg-red-500" style={{width: (f.v||0) + '%'}}/></div></div>
            ))}</div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
