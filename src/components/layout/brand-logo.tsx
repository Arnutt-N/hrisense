import { cn } from "@/lib/utils/cn";

export function BrandLogo({
  className,
  showText = true,
}: {
  className?: string;
  showText?: boolean;
}) {
  return (
    <div className={cn("flex items-center gap-2.5", className)}>
      <span className="relative flex h-10 w-10 shrink-0 items-center justify-center">
        <svg viewBox="0 0 48 48" className="h-10 w-10" aria-hidden="true">
          <defs>
            <linearGradient id="brandG" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor="#4f86f7" />
              <stop offset="100%" stopColor="#1e3a8a" />
            </linearGradient>
          </defs>
          <circle cx="24" cy="24" r="22" fill="url(#brandG)" />
          <circle cx="24" cy="24" r="22" fill="none" stroke="#ffffff" strokeOpacity="0.25" strokeWidth="1.5" />
          {/* network nodes */}
          <g fill="#ffffff">
            <circle cx="24" cy="13" r="2.4" />
            <circle cx="14" cy="21" r="2.2" />
            <circle cx="34" cy="21" r="2.2" />
            <circle cx="18" cy="33" r="2.2" />
            <circle cx="30" cy="33" r="2.2" />
          </g>
          <g stroke="#ffffff" strokeOpacity="0.7" strokeWidth="1.3">
            <line x1="24" y1="13" x2="14" y2="21" />
            <line x1="24" y1="13" x2="34" y2="21" />
            <line x1="14" y1="21" x2="18" y2="33" />
            <line x1="34" y1="21" x2="30" y2="33" />
            <line x1="18" y1="33" x2="30" y2="33" />
            <line x1="14" y1="21" x2="34" y2="21" />
          </g>
          {/* shield accent */}
          <path
            d="M31 25l5 1.8v4.2c0 2.7-2 4.6-5 5.6-3-1-5-2.9-5-5.6v-4.2z"
            fill="#ffd43b"
            stroke="#1e3a8a"
            strokeWidth="1"
          />
        </svg>
      </span>
      {showText && (
        <span className="text-xl font-bold tracking-tight text-white">
          HR<span className="text-amber-400">i</span>SENSE
        </span>
      )}
    </div>
  );
}
