# Contributing Guide — HRiSENSE

คู่มือการพัฒนาและ workflow ของโปรเจค HRiSENSE

---

## Development Workflow

```
Local Dev (Docker) → Commit + Push → PR → CI → All Green → Merge → CD (Deploy)
```

### ลำดับขั้นตอนที่ถูกต้อง (Migrate vs Push)

Migrations เป็น **code** → commit ไปด้วยกันใน PR (พร้อมกับ code changes)
Apply migrations กับ production → ทำ**หลัง merge** เท่านั้น (ใน CD pipeline)

```
┌─ LOCAL DEVELOPMENT ─────────────────────────────────┐
│  1. supabase start         # start Supabase local    │
│  2. แก้ code + เขียน migration                       │
│  3. supabase migration up  # apply ใน local          │
│  4. npm run dev            # ทดสอบ                    │
│  5. npm run test           # unit tests              │
│  6. npm run test:e2e       # e2e tests               │
└──────────────────────────────────────────────────────┘
                       ↓
┌─ COMMIT + PUSH ─────────────────────────────────────┐
│  7. git add . && git commit -m "..."                 │
│  8. git push origin feature-branch                   │
└──────────────────────────────────────────────────────┘
                       ↓
┌─ PULL REQUEST (GitHub Actions CI) ──────────────────┐
│  9. เปิด PR → CI ทำงาน:                             │
│     - Lint + Type Check                              │
│     - Build Next.js                                  │
│     - ทดสอบ migration บน temp Supabase               │
│     - Vitest (unit tests + coverage)                 │
│     - Playwright (e2e tests)                         │
│     - Deploy preview ไป Vercel                       │
└──────────────────────────────────────────────────────┘
                       ↓
┌─ ALL GREEN → MERGE ─────────────────────────────────┐
│  10. Review + approve → squash merge ไป main         │
└──────────────────────────────────────────────────────┘
                       ↓
┌─ CD (Deploy) ───────────────────────────────────────┐
│  11. GitHub Action:                                  │
│      a. supabase db push → apply migrations          │
│      b. vercel deploy --prod → deploy frontend       │
└──────────────────────────────────────────────────────┘
```

---

## Setup

### Requirements
- Node.js 20+
- Docker Desktop (สำหรับ Supabase local)
- Supabase CLI (`npm i -g supabase`)

### First-time setup
```bash
npm install
supabase start                # start Supabase local (Postgres, Auth, API, Studio)
supabase db push              # apply migrations + seed data
npm run dev                   # start Next.js dev server (localhost:3000)
```

### Studio UI
เปิด http://localhost:54323 เพื่อจัดการ DB ตรงๆ (view tables, edit data, run SQL)

---

## Project Structure

```
hrisense/
├── src/
│   ├── app/
│   │   ├── (auth)/login/         # หน้า login
│   │   ├── (dashboard)/
│   │   │   ├── dashboard/        # Dashboard หลัก + ย่อย (retirement, risk, vacancy, succession, idp)
│   │   │   ├── personnel/        # รายการ/รายละเอียด บุคลากร
│   │   │   ├── alerts/           # รายการแจ้งเตือน
│   │   │   └── settings/         # ตั้งค่า
│   │   └── api/                  # API routes
│   ├── components/               # React components (ui, charts, filters, layout)
│   └── lib/
│       ├── mock/                 # Mock data (ใช้เมื่อ NEXT_PUBLIC_USE_MOCK=true)
│       ├── supabase/             # Supabase clients
│       └── types/                # TypeScript types
├── supabase/
│   ├── migrations/               # SQL migrations (รันตามลำดับ)
│   ├── config.toml               # Supabase local config
│   └── seed.sql                  # seed หลัง migrate
├── tests/
│   ├── unit/                     # Vitest unit tests
│   └── e2e/                      # Playwright e2e tests
├── .github/workflows/            # CI/CD pipelines
├── docker-compose.prod.yml       # Supabase self-hosted (production)
└── scripts/                      # helper scripts
```

---

## Database Changes

### สร้าง migration ใหม่
```bash
bash scripts/new-migration.sh <name>
# หรือ
supabase migration new <name>
```

ไฟล์จะถูกสร้างใน `supabase/migrations/` — แก้ไข SQL ตามต้องการ

### ทดสอบ migration ใน local
```bash
supabase start           # ถ้ายังไม่ได้ start
supabase db reset        # reset DB + apply migrations + seed
```

### สร้าง type definitions ใหม่
```bash
npx supabase gen types typescript --local > src/lib/types/database.ts
```

---

## Testing

### Unit Tests (Vitest)
```bash
npm run test            # watch mode
npm run test:run        # run once
npm run test:coverage   # with coverage report
npm run test:ui         # visual UI
```

### E2E Tests (Playwright)
```bash
npm run dev             # start dev server ก่อน
npm run test:e2e        # run tests
npm run test:e2e:ui     # visual UI
```

### Mock Mode vs Real DB
- `NEXT_PUBLIC_USE_MOCK=true` → ใช้ mock data (ไม่ต้องมี Supabase)
- `NEXT_PUBLIC_USE_MOCK=false` → ใช้ Supabase local/production

---

## Deployment

### Production Supabase (Self-hosted Docker)
```bash
cp .env.production.example .env.production
# แก้ไขค่าต่างๆ ให้ครบ
docker compose -f docker-compose.prod.yml --env-file .env.production up -d
```

### Manual Migration
```bash
bash scripts/deploy-supabase.sh
# หรือ
supabase link --project-ref <project-id>
supabase db push --linked
```

### Frontend
Deploy ไป Vercel อัตโนมัติหลัง merge ผ่าน GitHub Actions CD pipeline

---

## Required GitHub Secrets

| Secret | คำอธิบาย |
|--------|---------|
| `SUPABASE_ACCESS_TOKEN` | Supabase access token |
| `SUPABASE_PROD_PROJECT_REF` | Project ref ของ production Supabase |
| `SUPABASE_PROD_DB_PASSWORD` | DB password ของ production |
| `NEXT_PUBLIC_SUPABASE_URL` | URL ของ Supabase (สำหรับ frontend) |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Anon key (สำหรับ frontend) |
| `VERCEL_TOKEN` | Vercel deployment token |
| `VERCEL_ORG_ID` | Vercel organization ID |
| `VERCEL_PROJECT_ID` | Vercel project ID |
