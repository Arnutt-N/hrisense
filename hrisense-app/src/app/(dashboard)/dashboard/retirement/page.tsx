import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ThaiDate } from '@/components/shared/thai-date'

export const dynamic = 'force-dynamic'

export default async function RetirementPage() {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase.from('v_retirement_timeline').select('*').order('retirement_date')

  const retiring1yr = data?.filter((r: any) => (r.retirement_years_remaining || 99) <= 1).length || 0
  const retiring3yr = data?.filter((r: any) => (r.retirement_years_remaining || 99) <= 3).length || 0
  const retiring5yr = data?.filter((r: any) => (r.retirement_years_remaining || 99) <= 5).length || 0
  const criticalAtRisk = data?.filter((r: any) => r.is_critical_position && (r.retirement_years_remaining || 99) <= 3).length || 0

  return (
    <div className="space-y-6">
      <div><h1 className="text-2xl font-bold">พยากรณ์เกษียณอายุ</h1><p className="text-muted-foreground text-sm mt-1">แนวโน้มการเกษียณอายุราชการ</p></div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[{l:'เกษียณใน 1 ปี',v:retiring1yr,c:'text-red-600'},{l:'เกษียณใน 3 ปี',v:retiring3yr,c:'text-amber-600'},{l:'เกษียณใน 5 ปี',v:retiring5yr,c:'text-yellow-600'},{l:'ตำแหน่งสำคัญเสี่ยง',v:criticalAtRisk,c:'text-destructive'}].map((item,i)=>(
          <Card key={i}><CardContent className="p-4"><p className="text-xs text-muted-foreground">{item.l}</p><p className={`text-2xl font-bold ${item.c}`}>{item.v}</p></CardContent></Card>
        ))}
      </div>
      <Card>
        <CardHeader><CardTitle>รายชื่อเกษียณอายุ</CardTitle></CardHeader>
        <CardContent>
          <table className="w-full text-sm">
            <thead><tr className="border-b"><th className="text-left py-2 px-3 text-muted-foreground">ชื่อ</th><th className="text-left py-2 px-3 text-muted-foreground">หน่วยงาน</th><th className="text-left py-2 px-3 text-muted-foreground">ตำแหน่ง</th><th className="text-left py-2 px-3 text-muted-foreground">วันเกษียณ</th><th className="text-left py-2 px-3 text-muted-foreground">ปีเหลือ</th><th className="text-left py-2 px-3 text-muted-foreground">สืบทอด</th></tr></thead>
            <tbody>{data?.map((r:any)=>(
              <tr key={r.personnel_id} className="border-b hover:bg-muted/50">
                <td className="py-2 px-3 font-medium">{r.full_name_th}</td>
                <td className="py-2 px-3 text-muted-foreground">{r.organization_name}</td>
                <td className="py-2 px-3 text-muted-foreground">{r.position_name||'—'}</td>
                <td className="py-2 px-3"><ThaiDate date={r.retirement_date}/></td>
                <td className="py-2 px-3">{r.retirement_years_remaining??'—'} ปี</td>
                <td className="py-2 px-3">{r.has_ready_successor?'✅':'❌'}</td>
              </tr>
            ))}</tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  )
}
