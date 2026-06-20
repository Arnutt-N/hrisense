import { AppSidebar } from '@/components/layout/app-sidebar'
import { AppHeader } from '@/components/layout/app-header'

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen bg-background">
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-3 focus:left-3 focus:z-[100] focus:px-4 focus:py-2 focus:bg-primary focus:text-primary-foreground focus:rounded-lg focus:shadow-md focus:text-sm focus:font-medium"
      >
        ข้ามไปยังเนื้อหาหลัก
      </a>
      <AppSidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        <AppHeader />
        <main id="main-content" className="flex-1 overflow-y-auto p-6 focus:outline-none" tabIndex={-1}>
          {children}
        </main>
      </div>
    </div>
  )
}
