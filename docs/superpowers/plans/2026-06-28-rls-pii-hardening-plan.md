# Implementation Plan: RLS / PII Hardening — View `security_invoker`

- **Date:** 2026-06-28
- **Spec:** `docs/superpowers/specs/2026-06-28-rls-pii-hardening-design.md` (approved Sections 1–3)
- **Tracking issue:** [nutchahrmoj/hrisense#32](https://github.com/nutchahrmoj/hrisense/issues/32)
- **Branch:** `fix/view-security-invoker` (from `main` @ `7b1cf25`)
- **Supersedes:** PR #22 (re-scoped), #24, #29

## 1. Goal / Summary

ปิด PII-leak gap สุดท้ายจาก audit remediation: เปลี่ยน Postgres views ทั้ง **22 ตัว** ให้รันด้วยสิทธิ์ของ **caller** (ไม่ใช่ owner ที่ bypass RLS) ผ่าน migration `025_view_security_invoker.sql` ที่ทำ `ALTER VIEW ... SET (security_invoker = true)` ครบทุก view ผลคือ `authenticated` ที่มี `SELECT` บน view จะถูกกรองด้วย RLS policy ของ base table → ไม่สามารถอ่าน PII ข้าม org ได้อีก ปิด PR #22 และ supersede #24/#29 โดยสมบูรณ์ พร้อม trailing cleanup (optional) ลบ `as any` 2 จุดใน `server.ts`

> **Phase 0 แก้ไข (2026-06-28):** grep `CREATE ... VIEW` ครบทุก migration พบ views เพิ่ม 2 ตัวใน `021_add_burnout_risk.sql` (`v_burnout_analysis`, `v_org_burnout_summary`) ที่ spec/plan ต้นฉบับนับเฉพาะ 013+016 = 20 ตัว ต้อง flip ครบ 22 มิฉะนั้น burnout views ยัง `security_definer` และเปิด leak path อยู่

## 2. Files to Create / Modify

### 2.1 Create — `supabase/migrations/025_view_security_invoker.sql`
- migration ใหม่ (slot 025 ว่าง, 001–024 ใช้แล้ว)
- **เนื้อหา:** comment header (อ้าง spec, #32, root cause, supersedes #22/#24/#29) + 22 บรรทัด `ALTER VIEW <name> SET (security_invoker = true);`
- Views ทั้ง 22 (verified จาก grep ใน 013/016/021):
  - **จาก `013_views.sql` (11):** `v_personnel_overview`, `v_org_dashboard`, `v_retirement_timeline`, `v_vacancy_analysis`, `v_high_risk_personnel`, `v_succession_status`, `v_training_summary`, `v_evaluation_history`, `v_active_alerts`, `v_workforce_composition`, `v_import_status`
  - **จาก `016_additional_views.sql` (9):** `v_critical_positions`, `v_succession_candidates`, `v_risk_distribution`, `v_org_risk_details`, `v_idp_summary`, `v_training_records`, `v_high_potential_personnel`, `v_org_vacancy_summary`, `v_critical_vacancies`
  - **จาก `021_add_burnout_risk.sql` (2):** `v_burnout_analysis`, `v_org_burnout_summary`
- Idempotent — re-run ปลอดภัย, ไม่แก้ schema/data
- Risk: Low

### 2.2 (Optional, trailing commit) Modify — `src/lib/supabase/server.ts`
- ลบ `as any` 2 จุด:
  - **Line 13:** `return createMockServerClient() as any` → type-narrowed return
  - **Line 32:** `cookieStore.set(name, value, options as any)` → type-safe options
- Risk: Low–Medium — อาจทำให้ `tsc --noEmit` พัง → **drop** trailing commit นี้ออกจาก PR ถ้า fail (R4)
- **ห้าม rename `USE_MOCK` เป็น `NEXT_PUBLIC_USE_MOCK`** (server-only flag — เปลี่ยนแล้วเป็น regression)

## 3. Phase Breakdown

### Phase 0 — Pre-flight Verification (no code changes) ✅ DONE 2026-06-28
1. ✅ ยืนยัน `major_version = 15` ใน `supabase/config.toml` line 15 (R3 mitigation)
2. ✅ ลิสต์ `supabase/migrations/` ยืนยัน slot 025 ว่าง
3. ⚠️ grep `CREATE (OR REPLACE )?VIEW` ครบทุก migration พบ **22 views** (ไม่ใช่ 20) — เพิ่ม `v_burnout_analysis` + `v_org_burnout_summary` จาก `021_add_burnout_risk.sql` → spec/plan อัปเดตเป็น 22
4. ✅ ยืนยันตำแหน่ง `as any` 2 จุดใน `src/lib/supabase/server.ts` (lines 13, 32)

### Phase 1 — Write Migration 025
5. สร้าง `supabase/migrations/025_view_security_invoker.sql` (comment header + 22 บรรทัด `ALTER VIEW ... SET (security_invoker = true);`)

### Phase 2 — Local Supabase Test (ตาม spec section 2.4 ข้อ 1–7)
6. `supabase start` → migrations `001`–`025` รันครบ + seed
7. `supabase status` ยืนยัน PG = 15
8. `authenticated` (org เดียว) query ทุก view → เฉพาะ rows ที่ policy อนุญาต (no cross-org PII)
9. `anon` / unauthenticated query ทุก view → blocked
10. `service_role` query ทุก view → full data (bypass)
11. smoke-test dashboard pages (`v_org_dashboard`, `v_personnel_overview`) → render ปกติ ไม่ empty state

### Phase 3 — Lint / Typecheck / Unit Tests
12. `npm run lint` → green
13. `npx tsc --noEmit` → green
14. `npm run test:run` → green, coverage ≥ 80%

### Phase 4 — (Optional) `as any` Cleanup
15. แก้ `as any` 2 จุดใน `server.ts` → `npx tsc --noEmit` + `npm run build` → **drop commit ถ้าพัง** (R4)

### Phase 5 — Commit + Fork-based PR
16. commit migration 025: `fix(security): set security_invoker on views to honor caller RLS (closes #22)`
17. (optional) commit `server.ts` cleanup แยก: `refactor(types): remove as any casts in server.ts`
18. push `-u` → เปิด fork-based PR (Arnutt-N/hrisense → nutchahrmoj/hrisense, base `main`) ผ่าน API + git credential (no gh CLI)
19. handoff comment บน #32 แจ้ง owner ปิด #22/#24/#29

## 4. Test Plan Checklist

### 4.1 Real Supabase stack
- [ ] `supabase start` รัน migrations `001`–`025` ครบ + seed สำเร็จ
- [ ] `supabase status` ยืนยัน PG = 15
- [ ] `authenticated` (org `ORG_A`) query ทุก view → เฉพาะ policy-permitted rows (no cross-org PII)
- [ ] `anon` / unauthenticated query ทุก view → blocked
- [ ] `service_role` query ทุก view → full data (bypass)
- [ ] dashboard pages render ปกติ — no empty state from over-restrictive policy
- [ ] `npm run lint`, `npx tsc --noEmit`, `npm run test:run` green (coverage ≥ 80%)

### 4.2 View inventory coverage (22 ตัว ครบ)
- [ ] 11 จาก `013`: `v_personnel_overview`, `v_org_dashboard`, `v_retirement_timeline`, `v_vacancy_analysis`, `v_high_risk_personnel`, `v_succession_status`, `v_training_summary`, `v_evaluation_history`, `v_active_alerts`, `v_workforce_composition`, `v_import_status`
- [ ] 9 จาก `016`: `v_critical_positions`, `v_succession_candidates`, `v_risk_distribution`, `v_org_risk_details`, `v_idp_summary`, `v_training_records`, `v_high_potential_personnel`, `v_org_vacancy_summary`, `v_critical_vacancies`
- [ ] 2 จาก `021`: `v_burnout_analysis`, `v_org_burnout_summary`

## 5. Risks & Rollback

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|-----------|
| R1 | Views aggregating คืน rows น้อยเกินไป → dashboard empty state | Medium | Medium | Verify base-table policies permit `authenticated` กว้างพอ; test dashboard end-to-end (Phase 2 step 11) |
| R2 | base table บางตัวไม่มี policy → view คืน 0 rows | Medium | Medium | Audit policies บนทุก base table ที่ 22 views อ้างถึง; test multi-join views ก่อน (`v_org_dashboard`, `v_personnel_overview`, `v_burnout_analysis`) |
| R3 | runtime PG < 15 → `ALTER VIEW SET` error | Low | High | `supabase status` ยืนยัน version ก่อน migration (Phase 2 step 7); fallback = ขอ owner upgrade |
| R4 | removing `as any` breaks TS build | Low | Low | Trailing commit แยก → **drop จาก PR ถ้า `tsc`/`build` พัง** |

**Rollback** (migration 025 เปลี่ยนเฉพาะ view option — ไม่แก้ data/schema):
```sql
ALTER VIEW v_personnel_overview RESET (security_invoker);
-- หรือ SET (security_invoker = false) ทุก view ที่ถูก flip
```

## 6. Acceptance Criteria (จาก spec section 3.3)

- [ ] migration `025` รันได้สะอาดบน local Supabase (PG 15)
- [ ] `authenticated` querying views เห็นเฉพาะ policy-permitted rows (no cross-org PII)
- [ ] `anon` querying views → blocked
- [ ] `service_role` bypass RLS เหมือนเดิม
- [ ] dashboard pages render ปกติ
- [ ] `npm run lint`, `npx tsc --noEmit`, `npm run test:run` green (coverage ≥ 80%)
- [ ] PR เปิดจาก fork; #22 ถูกปิด; owner ได้รับแจ้งให้ปิด #24/#29

## 7. Definition of Done

- [ ] Migration `025_view_security_invoker.sql` commit อยู่บน `fix/view-security-invoker`
- [ ] (optional) `server.ts` cleanup commit แยก หรือถูก drop หาก build พัง
- [ ] Phase 0–3 ทุก step เสร็จ พร้อม evidence
- [ ] Phase 2 test plan checklist tick ครบ
- [ ] PR เปิดจาก fork `Arnutt-N/hrisense` → upstream `nutchahrmoj/hrisense`, base `main`
- [ ] PR title: `fix(security): set security_invoker on views to honor caller RLS (closes #22)`
- [ ] PR body ระบุ: tracking #32, superseded #24/#29, link spec, test plan checklist
- [ ] Handoff comment บน #32 แจ้ง owner ปิด #22/#24/#29
- [ ] ไม่มี hardcoded secrets / ไม่มี `console.log` / ไม่มี mutation / coverage ≥ 80%
- [ ] ห้าม rename `USE_MOCK` เป็น `NEXT_PUBLIC_USE_MOCK` (regression)

## Relevant File Paths

- `supabase/migrations/025_view_security_invoker.sql` — สร้างใหม่
- `supabase/migrations/013_views.sql` — อ้างอิง (11 views)
- `supabase/migrations/016_additional_views.sql` — อ้างอิง (9 views)
- `supabase/migrations/021_add_burnout_risk.sql` — อ้างอิง (2 views: `v_burnout_analysis`, `v_org_burnout_summary`)
- `supabase/migrations/019_grant_view_permissions.sql` — อ้างอิง (grant ที่ทำให้ leak path เปิดอยู่)
- `supabase/migrations/022_rls_hardening.sql` — อ้างอิง (revoke `anon` แต่ไม่ touch view invoker)
- `supabase/config.toml` — ยืนยัน `major_version = 15`
- `src/lib/supabase/server.ts` — optional cleanup `as any` (lines 13, 32)
- `docs/superpowers/specs/2026-06-28-rls-pii-hardening-design.md` — spec ต้นทาง