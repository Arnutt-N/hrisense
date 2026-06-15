import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'HRiSENSE - ระบบพยากรณ์และบริหารความเสี่ยงด้านกำลังคน',
  description: 'Human Resource Intelligence System for Early-risk Notification and Strategic Evaluation — กระทรวงยุติธรรม',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="th">
      <body className="min-h-screen bg-background font-[var(--font-thai)] antialiased">
        {children}
      </body>
    </html>
  )
}
