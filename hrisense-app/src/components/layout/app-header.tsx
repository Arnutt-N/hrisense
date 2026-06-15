'use client'
import { Bell, Menu } from 'lucide-react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import { useState, useEffect } from 'react'

export function AppHeader() {
  const [alertCount, setAlertCount] = useState(3)
  const [userName, setUserName] = useState('Admin')
  const router = useRouter()

  useEffect(() => {
    setUserName('ผู้ดูแลระบบ')
    setAlertCount(3)
  }, [])

  async function handleLogout() {
    router.push('/login')
  }

  return (
    <header className="h-14 border-b bg-card flex items-center justify-between px-6 shrink-0">
      <div className="flex items-center gap-2">
        <button className="lg:hidden p-2 rounded-lg hover:bg-muted"><Menu className="w-5 h-5" /></button>
        <h2 className="text-sm font-medium text-muted-foreground">ระบบพยากรณ์และบริหารความเสี่ยงด้านกำลังคน</h2>
      </div>
      <div className="flex items-center gap-3">
        <button className="relative p-2 rounded-lg hover:bg-muted transition">
          <Bell className="w-5 h-5 text-muted-foreground" />
          {alertCount > 0 && (
            <span className="absolute -top-0.5 -right-0.5 w-5 h-5 bg-destructive text-destructive-foreground text-xs rounded-full flex items-center justify-center font-medium">
              {alertCount > 9 ? '9+' : alertCount}
            </span>
          )}
        </button>
        <div className="flex items-center gap-2 pl-3 border-l">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <span className="text-sm font-medium text-primary">A</span>
          </div>
          <span className="text-sm text-foreground hidden sm:inline">{userName}</span>
          <button onClick={handleLogout} className="text-xs text-muted-foreground hover:text-destructive ml-2">ออกจากระบบ</button>
        </div>
      </div>
    </header>
  )
}
