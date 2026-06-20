'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Shield } from 'lucide-react'

export default function LoginPage() {
  const [loading, setLoading] = useState(false)
  const router = useRouter()
  const isMock = process.env.NEXT_PUBLIC_USE_MOCK === 'true'

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    if (isMock) {
      setTimeout(() => router.push('/dashboard'), 500)
    } else {
      const { createClient } = await import('@/lib/supabase/client')
      const supabase = createClient()
      const form = e.target as HTMLFormElement
      const email = (form.elements.namedItem('email') as HTMLInputElement).value
      const password = (form.elements.namedItem('password') as HTMLInputElement).value
      const { error } = await supabase.auth.signInWithPassword({ email, password })
      if (error) { setLoading(false); return }
      router.push('/dashboard')
    }
  }

  return (
    <div className="space-y-6">
      <div className="text-center space-y-2">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-primary/10 mb-4">
          <Shield className="w-8 h-8 text-primary" />
        </div>
        <h1 className="text-2xl font-bold text-foreground">HRiSENSE</h1>
        <p className="text-sm text-muted-foreground">ระบบพยากรณ์และบริหารความเสี่ยงด้านกำลังคน</p>
        <p className="text-xs text-muted-foreground">สำนักงานปลัดกระทรวงยุติธรรม</p>
        {isMock && <p className="text-xs text-amber-600 font-medium">🧪 โหมดทดสอบ (Mock Data)</p>}
      </div>
      <form onSubmit={handleLogin} className="space-y-4">
        <div className="space-y-2">
          <label className="text-sm font-medium">อีเมล</label>
          <input name="email" type="email" defaultValue="admin@moj.go.th"
            className="w-full px-3 py-2 rounded-lg border bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary/20" />
        </div>
        <div className="space-y-2">
          <label className="text-sm font-medium">รหัสผ่าน</label>
          <input name="password" type="password" defaultValue="password"
            className="w-full px-3 py-2 rounded-lg border bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary/20" />
        </div>
        <button type="submit" disabled={loading}
          className="w-full py-2.5 rounded-lg bg-primary text-primary-foreground font-medium hover:bg-primary/90 transition disabled:opacity-50">
          {loading ? 'กำลังเข้าสู่ระบบ...' : isMock ? 'เข้าสู่ระบบ (Mock)' : 'เข้าสู่ระบบ'}
        </button>
      </form>
    </div>
  )
}
