# AGENTS.md

Repo-specific guidance for OpenCode sessions working in `D:\hrisense`.
HRiSENSE is a Next.js 14 (App Router) workforce-analytics dashboard for the Thai Ministry of Justice, backed by Supabase. UI is Thai-first.

## Commands

- `npm run dev` — dev server on `:3000`
- `npm run build` / `npm start` — production build & serve
- `npm run lint` — `next lint` (the only script in `package.json` besides dev/build/start)
- `npx tsc --noEmit` — **typecheck is not a named script**; CI runs it this way. Run it before considering work done.
- No test framework is configured. `npm test` is a no-op (CI runs it with `continue-on-error`). Do not assume tests exist.
- Formatting is not enforced: Prettier is not a dependency and there is no `format` script (CI's `prettier --check` is `continue-on-error`).

## Environment & mock mode (read this first)

App behavior is gated by two **separate** env vars in `.env.local` (gitignored):

- `USE_MOCK` — read by the **server** client (`src/lib/supabase/server.ts`)
- `NEXT_PUBLIC_USE_MOCK` — read by the **browser** client (`src/lib/supabase/client.ts`) and the login page

When either is `"true"`, the Supabase client is swapped for an in-memory mock (`src/lib/mock/`). The committed `.env.local` defaults both to `true`, so **the app runs with no database**. To hit a real Supabase, set both to `false` and provide `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY`.

Other required env vars (local Supabase values are in `.env.local`): `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.

## Data layer

- **Query the `v_*` views, not base tables.** Every page selects from views: `v_personnel_overview`, `v_org_dashboard`, `v_retirement_timeline`, `v_vacancy_analysis`, `v_high_risk_personnel`, `v_active_alerts`, `v_workforce_composition`. The mock client (`src/lib/mock/client.ts`) keys its fake data off these same view names, so mock and real paths return the same shapes.
- Server data fetching pattern: `export const dynamic = 'force-dynamic'` + `const supabase = await createServerSupabaseClient()` (async, awaits `cookies()`). Browser fetching uses `createClient()` from `src/lib/supabase/client.ts`.
- `src/lib/types/database.ts` is a **hand-written stub**, not generated (the header comment is aspirational). Regenerate against a real project with `npx supabase gen types typescript --project-id <id> > src/lib/types/database.ts` and reconcile before trusting it.
- Risk scoring: `getRiskLevel(score)` in `src/lib/utils/risk-colors.ts` — `>=75` critical, `>=50` red, `>=25` amber, else green. Thai labels: ปกติ / เฝ้าระวัง / เสี่ยงสูง / วิกฤต. Use `RiskBadge` for display; keep the semantic colors identical everywhere (a design-system rule).
- Years shown in the UI are Buddhist Era (Gregorian `+ 543`); see `src/app/(dashboard)/dashboard/page.tsx`.

## Auth & middleware gotcha

- `src/lib/supabase/middleware.ts` exports `updateSession`, but **there is no `src/middleware.ts` (or root `middleware.ts`) that calls it**. The standard Supabase SSR session-refresh middleware is therefore not wired up.
- Dashboard routes have **no auth guard**: pages call `createServerSupabaseClient()` and query directly, with no `getUser()` check or redirect. In mock mode, login just `router.push('/dashboard')`. If you add route protection, create `src/middleware.ts` invoking `updateSession` and add server-side redirects — don't assume it already works.

## Supabase local dev

- `npx supabase start` then `npx supabase db push` to apply migrations. Ports: API `54321`, Postgres `54322`, Studio `54323`. Config in `supabase/config.toml` (project_id `hrisense`, Postgres 15).
- Migrations live in `supabase/migrations/`, numbered `001`–`017`. Files ending `.bak` (e.g. `014_seed_data_part*.sql.bak`, `015_sample_personnel_400.sql.bak`) are disabled backups — `017_comprehensive_seed_data.sql` is the active seed. RLS policies (`009`), functions (`010`), triggers (`011`), indexes (`012`), views (`013`, `016`) are split across files.

## Project layout

- Real app code is in `src/`. `@/*` maps to `./src/*` (tsconfig paths).
- Route groups: `src/app/(auth)/` (login), `src/app/(dashboard)/` (app shell with `AppSidebar` + `AppHeader` in its layout). Root `src/app/page.tsx` redirects to `/login`. API route: `src/app/api/auth/callback/route.ts` (OAuth code exchange).
- `hrisense-app/` at the repo root is an **empty leftover** (`hrisense-app/src/lib` is empty, no `package.json`). Do not put code there.
- Empty placeholder dirs (safe to ignore): `src/lib/hooks/`, `src/components/providers/`, `supabase/seed/`, `supabase/snippets/`.

## UI & design conventions

- **Thai-first.** `lang="th"`, UI strings are Thai, sole typeface is Noto Sans Thai (loaded via `@import` in `globals.css`, exposed as `--font-thai`). Don't pair fonts.
- Theming is shadcn-style CSS variables in `src/app/globals.css` (HSL triples, `hsl(var(--*))`), wired through `tailwind.config.ts`. Colors: Authority Blue primary `215 52% 24%`, Warm Sand accent `43 55% 54%` (use on ≤10% of any screen), risk green/amber/red/critical.
- Design system sources of truth: `DESIGN.md`, `PRODUCT.md`, `.impeccable/design.json`. Known issues and P0/P1 fix priorities are tracked in `AUDIT-REPORT.md` (form label associations, table ARIA, focus indicators, hard-coded `bg-green-100`/`amber-100`/`red-100` that should be semantic tokens).
- `src/app/layout.tsx` contains an injected live-reload snippet between `<!-- impeccable-live-start -->` / `<!-- impeccable-live-end -->` markers (loads `http://localhost:8400/live.js`). Preserve the markers if you edit the layout; the script only runs locally.

## CI & deploy

- Workflows in `.github/workflows/` trigger on `main` / `develop` (push + PR). Vercel prod deploy runs only on `main` push. Required repo secrets are listed in `.github/WORKFLOWS.md`.
- `db-migrations.yml` runs on PRs that touch `supabase/migrations/**` (`supabase start` + `db push` on a fresh instance).
