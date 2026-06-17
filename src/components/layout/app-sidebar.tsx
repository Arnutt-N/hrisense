"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Home,
  LayoutGrid,
  ShieldAlert,
  Users,
  Network,
  BarChart3,
  Bell,
  Settings,
  LogOut,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils/cn";
import { BrandLogo } from "./brand-logo";

type NavItem = { href: string; label: string; icon: LucideIcon; match?: string[] };

const navItems: NavItem[] = [
  { href: "/", label: "หน้าหลัก", icon: Home },
  { href: "/dashboard", label: "Dashboard", icon: LayoutGrid },
  { href: "/risk", label: "วิเคราะห์ความเสี่ยง", icon: ShieldAlert },
  { href: "/personnel", label: "กำลังคนและตำแหน่ง", icon: Users, match: ["/personnel", "/profile"] },
  { href: "/succession", label: "แผนสืบทอดตำแหน่ง", icon: Network },
  { href: "/executive", label: "รายงานสำหรับผู้บริหาร", icon: BarChart3 },
  { href: "/alerts", label: "แจ้งเตือน", icon: Bell },
  { href: "/settings", label: "ตั้งค่าและระบบ", icon: Settings },
];

export function AppSidebar({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();

  const isActive = (item: NavItem) => {
    if (item.href === "/") return pathname === "/";
    const targets = item.match ?? [item.href];
    return targets.some((t) => pathname === t || pathname.startsWith(t + "/"));
  };

  return (
    <div className="flex h-full w-64 flex-col bg-sidebar text-sidebar-foreground">
      {/* Logo */}
      <div className="flex h-[68px] items-center border-b border-white/10 px-5">
        <BrandLogo />
      </div>

      {/* Nav */}
      <nav className="flex-1 space-y-1.5 overflow-y-auto px-3 py-5">
        {navItems.map((item) => {
          const active = isActive(item);
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onNavigate}
              aria-current={active ? "page" : undefined}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3.5 py-2.5 text-sm font-medium transition-colors",
                active
                  ? "bg-sidebar-accent text-white shadow-sm"
                  : "text-sidebar-foreground/80 hover:bg-white/5 hover:text-white",
              )}
            >
              <item.icon className="h-[18px] w-[18px] shrink-0" />
              <span className="truncate">{item.label}</span>
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="border-t border-white/10 px-3 py-4">
        <button
          type="button"
          className="flex w-full items-center gap-3 rounded-lg px-3.5 py-2.5 text-sm font-medium text-sidebar-foreground/80 transition-colors hover:bg-white/5 hover:text-white"
        >
          <LogOut className="h-[18px] w-[18px] shrink-0" />
          ออกจากระบบ
        </button>
      </div>
    </div>
  );
}
