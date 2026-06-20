export default function DashboardLoading() {
  return (
    <div className="space-y-6" aria-busy="true" aria-label="กำลังโหลดแดชบอร์ด">
      {/* Header */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div className="space-y-2">
          <div className="h-7 w-44 rounded-md bg-muted animate-pulse" />
          <div className="h-4 w-72 rounded-md bg-muted/70 animate-pulse" />
        </div>
        <div className="h-9 w-24 rounded-lg bg-muted animate-pulse" />
      </div>

      {/* KPI Row 1 */}
      <section>
        <div className="h-5 w-28 rounded-md bg-muted/70 animate-pulse mb-3" />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="rounded-lg border bg-card p-6">
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-2 flex-1">
                  <div className="h-4 w-24 rounded bg-muted/70 animate-pulse" />
                  <div className="h-8 w-16 rounded bg-muted animate-pulse" />
                  <div className="h-3 w-28 rounded bg-muted/60 animate-pulse" />
                </div>
                <div className="h-11 w-11 rounded-xl bg-muted/70 animate-pulse shrink-0" />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* KPI Row 2 */}
      <section>
        <div className="h-5 w-32 rounded-md bg-muted/70 animate-pulse mb-3" />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="rounded-lg border bg-card p-6">
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-2 flex-1">
                  <div className="h-4 w-24 rounded bg-muted/70 animate-pulse" />
                  <div className="h-8 w-16 rounded bg-muted animate-pulse" />
                  <div className="h-3 w-28 rounded bg-muted/60 animate-pulse" />
                </div>
                <div className="h-11 w-11 rounded-xl bg-muted/70 animate-pulse shrink-0" />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Charts */}
      <section>
        <div className="h-5 w-36 rounded-md bg-muted/70 animate-pulse mb-3" />
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="rounded-lg border bg-card p-6 space-y-4">
            <div className="h-5 w-48 rounded bg-muted/70 animate-pulse" />
            <div className="h-[200px] w-full rounded-md bg-muted/40 animate-pulse" />
          </div>
          <div className="rounded-lg border bg-card p-6 space-y-4">
            <div className="h-5 w-40 rounded bg-muted/70 animate-pulse" />
            <div className="grid grid-cols-2 gap-4">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="rounded-lg border bg-card p-4 space-y-2">
                  <div className="h-3 w-16 rounded bg-muted/60 animate-pulse" />
                  <div className="h-7 w-10 rounded bg-muted animate-pulse" />
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Table */}
      <section>
        <div className="h-5 w-32 rounded-md bg-muted/70 animate-pulse mb-3" />
        <div className="rounded-lg border bg-card">
          <div className="space-y-3 p-6">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center gap-4">
                <div className="h-4 flex-1 rounded bg-muted/60 animate-pulse" />
                <div className="h-4 w-24 rounded bg-muted/60 animate-pulse" />
                <div className="h-4 w-16 rounded bg-muted/60 animate-pulse" />
                <div className="h-6 w-12 rounded-full bg-muted/70 animate-pulse" />
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  )
}
