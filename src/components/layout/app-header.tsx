"use client";

import Image from "next/image";
import Link from "next/link";
import { Bell, HelpCircle, Menu, ChevronDown } from "lucide-react";
import { currentUser } from "@/lib/data";

export function AppHeader({
  onMenuClick,
  subtitle,
}: {
  onMenuClick?: () => void;
  subtitle?: string;
}) {
  return (
    <header className="sticky top-0 z-30 flex h-[68px] items-center justify-between gap-4 border-b border-border bg-card/95 px-4 backdrop-blur md:px-6">
      <div className="flex min-w-0 items-center gap-3">
        <button
          type="button"
          onClick={onMenuClick}
          className="rounded-lg p-2 text-muted-foreground hover:bg-muted lg:hidden"
          aria-label="เปิดเมนู"
        >
          <Menu className="h-5 w-5" />
        </button>
        {subtitle ? (
          <p className="truncate text-sm font-medium leading-snug text-foreground md:text-[15px]">
            {subtitle}
          </p>
        ) : null}
      </div>

      <div className="flex items-center gap-2 md:gap-4">
        <Link
          href="/alerts"
          className="relative rounded-full p-2 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
          aria-label="การแจ้งเตือน"
        >
          <Bell className="h-5 w-5" />
          <span className="absolute -right-0.5 -top-0.5 flex h-5 w-5 items-center justify-center rounded-full bg-destructive text-[11px] font-semibold text-destructive-foreground">
            3
          </span>
        </Link>

        <button
          type="button"
          className="hidden rounded-full p-2 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground sm:block"
          aria-label="ช่วยเหลือ"
        >
          <HelpCircle className="h-5 w-5" />
        </button>

        <div className="flex items-center gap-2.5 border-l border-border pl-3 md:pl-4">
          <Image
            src="/avatars/user.png"
            alt={currentUser.name}
            width={40}
            height={40}
            className="h-9 w-9 rounded-full object-cover ring-2 ring-accent/30 md:h-10 md:w-10"
          />
          <div className="hidden text-right leading-tight sm:block">
            <p className="text-sm font-semibold text-foreground">
              {currentUser.name}
            </p>
            <p className="text-xs text-muted-foreground">{currentUser.role}</p>
          </div>
          <ChevronDown className="hidden h-4 w-4 text-muted-foreground sm:block" />
        </div>
      </div>
    </header>
  );
}
