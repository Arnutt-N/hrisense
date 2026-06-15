import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div><h1 className="text-2xl font-bold">ตั้งค่า</h1></div>
      <Card><CardHeader><CardTitle>การตั้งค่าทั่วไป</CardTitle></CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between py-2 border-b"><div><p className="font-medium">ภาษา</p><p className="text-sm text-muted-foreground">เลือกภาษาที่ต้องการแสดงผล</p></div><span className="px-3 py-1 rounded-full bg-primary/10 text-primary text-sm font-medium">ภาษาไทย</span></div>
          <div className="flex items-center justify-between py-2 border-b"><div><p className="font-medium">เขตเวลา</p><p className="text-sm text-muted-foreground">เขตเวลาสำหรับแสดงข้อมูล</p></div><span className="text-sm text-muted-foreground">Asia/Bangkok (UTC+7)</span></div>
          <div className="flex items-center justify-between py-2"><div><p className="font-medium">การแจ้งเตือน</p><p className="text-sm text-muted-foreground">รับการแจ้งเตือนเมื่อมีความเสี่ยงใหม่</p></div><span className="px-3 py-1 rounded-full bg-green-100 text-green-800 text-sm font-medium">เปิด</span></div>
        </CardContent>
      </Card>
      <Card><CardHeader><CardTitle>เกี่ยวกับระบบ</CardTitle></CardHeader>
        <CardContent className="space-y-2 text-sm">
          <p><span className="text-muted-foreground">ชื่อระบบ:</span> HRiSENSE</p>
          <p><span className="text-muted-foreground">เวอร์ชัน:</span> 0.1.0</p>
          <p><span className="text-muted-foreground">หน่วยงาน:</span> กระทรวงยุติธรรม</p>
          <p><span className="text-muted-foreground">Database:</span> Supabase (PostgreSQL)</p>
        </CardContent>
      </Card>
    </div>
  )
}
