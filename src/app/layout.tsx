import type { Metadata, Viewport } from "next";
import { Noto_Sans_Thai } from "next/font/google";
import "./globals.css";

const notoSansThai = Noto_Sans_Thai({
  subsets: ["thai", "latin"],
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-noto-thai",
  display: "swap",
});

export const metadata: Metadata = {
  title: "HRiSENSE — ระบบพยากรณ์และบริหารความเสี่ยงด้านกำลังคน",
  description:
    "Human Resource Intelligence System for Early-risk Notification and Strategic Evaluation — ระบบสนับสนุนการบริหารกำลังคนเชิงรุก",
};

export const viewport: Viewport = {
  themeColor: "#23306b",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="th" className={`${notoSansThai.variable} bg-background`}>
      <body className="min-h-screen bg-background font-sans text-foreground antialiased">
        {children}
      </body>
    </html>
  );
}
