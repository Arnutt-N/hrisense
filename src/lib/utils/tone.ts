export type Tone = "info" | "success" | "warning" | "danger" | "violet";

// Soft icon chip background + foreground per tone (matches the mockups).
export const toneChip: Record<Tone, string> = {
  info: "bg-blue-100 text-blue-600",
  success: "bg-emerald-100 text-emerald-600",
  warning: "bg-amber-100 text-amber-600",
  danger: "bg-red-100 text-red-600",
  violet: "bg-violet-100 text-violet-600",
};

// Tinted card surface used by the executive summary KPI strip / risk tiles.
export const toneSurface: Record<Tone, string> = {
  info: "bg-blue-50/70 border-blue-100",
  success: "bg-emerald-50/70 border-emerald-100",
  warning: "bg-amber-50/70 border-amber-100",
  danger: "bg-red-50/70 border-red-100",
  violet: "bg-violet-50/70 border-violet-100",
};

export const toneText: Record<Tone, string> = {
  info: "text-blue-600",
  success: "text-emerald-600",
  warning: "text-amber-600",
  danger: "text-red-600",
  violet: "text-violet-600",
};

// Risk level color helpers
export type RiskLevel = "low" | "medium" | "high" | "critical";

export const riskBadge: Record<RiskLevel, string> = {
  low: "bg-emerald-100 text-emerald-700",
  medium: "bg-amber-100 text-amber-700",
  high: "bg-orange-100 text-orange-700",
  critical: "bg-red-500 text-white",
};

export const riskDot: Record<RiskLevel, string> = {
  low: "bg-emerald-500",
  medium: "bg-amber-500",
  high: "bg-orange-500",
  critical: "bg-red-600",
};

export const riskHex: Record<RiskLevel, string> = {
  low: "#37b24d",
  medium: "#f59f00",
  high: "#fd7e14",
  critical: "#e03131",
};
