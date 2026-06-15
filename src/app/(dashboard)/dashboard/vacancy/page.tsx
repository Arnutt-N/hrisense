import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export const dynamic = 'force-dynamic'

export default async function VacancyPage() {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase.from('v_vacancy_analysis').select('*').order('vacancy_rate_pct', { ascending: false })
  const totalQuota = data?.reduce((s:number,v:any)=>s+(v.quota||0),0)||0
  const totalVacant = data?.reduce((s:number,v:any)=>s+(v.vacancy_count||0),0)||0
  const rate = totalQuota>0?((totalVacant/totalQuota)*100).toFixed(1):'0'
  const criticalVacant = data?.filter((v:any)=>v.is_critical&&v.vacancy_count>0).length||0

  return (
    <div className="space-y-6">
      <div><h1 className="text-2xl font-bold">วิเคราะห์อัตรากำลัง</h1><p className="text-muted-foreground text-sm mt-1">สถานการณ์อัตราว่าง</p></div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">อัตราว่างรวม</p><p className="text-3xl font-bold text-amber-600">{rate}%</p><p className="text-xs text-muted-foreground">{totalVacant}/{totalQuota}</p></CardContent></Card>
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">ตำแหน่งสำคัญว่าง</p><p className="text-3xl font-bold text-destructive">{criticalVacant}</p></CardContent></Card>
        <Card><CardContent className="p-4"><p className="text-xs text-muted-foreground">ตำแหน่งทั้งหมด</p><p className="text-3xl font-bold">{data?.length||0}</p></CardContent></Card>
      </div>
      <Card>
        <CardHeader><CardTitle>รายละเอียดอัตรารายตำแหน่ง</CardTitle></CardHeader>
        <CardContent className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="border-b"><th className="text-left py-2 px-3 text-muted-foreground">รหัส</th><th className="text-left py-2 px-3 text-muted-foreground">ตำแหน่ง</th><th className="text-left py-2 px-3 text-muted-foreground">หน่วยงาน</th><th className="text-right py-2 px-3 text-muted-foreground">อัตรา</th><th className="text-right py-2 px-3 text-muted-foreground">มี</th><th className="text-right py-2 px-3 text-muted-foreground">ว่าง</th><th className="text-right py-2 px-3 text-muted-foreground">%ว่าง</th><th className="text-center py-2 px-3 text-muted-foreground">สำคัญ</th></tr></thead>
            <tbody>{data?.map((v:any)=>{
              const highlight = v.is_critical && v.vacancy_count > 0
              return (<tr key={v.position_id} className={`border-b hover:bg-muted/50 ${highlight?'bg-red-50/50':''}`}>
                <td className="py-2 px-3 font-mono text-xs">{v.position_code}</td>
                <td className="py-2 px-3 font-medium">{v.position_name}</td>
                <td className="py-2 px-3 text-muted-foreground">{v.organization_name}</td>
                <td className="py-2 px-3 text-right">{v.quota}</td>
                <td className="py-2 px-3 text-right">{v.current_occupancy}</td>
                <td className="py-2 px-3 text-right text-amber-600 font-medium">{v.vacancy_count}</td>
                <td className="py-2 px-3 text-right">{v.vacancy_rate_pct?.toFixed(1)}%</td>
                <td className="py-2 px-3 text-center">{v.is_critical?'⭐':''}</td>
              </tr>)
            })}</tbody>
          </table>
        </CardContent>
      </Card>
    </div>
  )
}
