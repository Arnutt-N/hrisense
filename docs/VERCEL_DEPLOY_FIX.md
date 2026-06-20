# แก้ปัญหา Vercel Production 404 (HRiSENSE)

> production `https://hrisense.vercel.app/` ขึ้น **404: NOT_FOUND** เพราะ **ทุก deployment build ล้มเหลว** (production + preview ทุก branch) ทั้งที่ `next build` ในเครื่อง **สำเร็จปกติ**

อัปเดต: 2026-06-20
สถานะ: รอเจ้าของแก้ Root Directory ใน Vercel Dashboard

---

## 1. อาการ (Symptom)

- เปิด `https://hrisense.vercel.app/` → `404: NOT_FOUND` (เช่น `Code: NOT_FOUND`, `ID: sin1::...`)
- ใน GitHub Deployments ทุก deployment เป็น `state: failure`:

```
PROD b97db99 (main) → failure
PREVIEW 0a26639 (fix/security-...) → failure
PREVIEW 62bf247 (feature/enhancement) → failure
... ทุก branch fail หมด
```

- แต่ `npm ci && npm run build` ในเครื่อง **สำเร็จ 18/18 หน้า ไม่มี error** (มีแค่ warning เรื่อง Edge Runtime ของ `@supabase/supabase-js` ซึ่งไม่ทำให้ fail)

> **สรุปการวินิจฉัย:** โค้ด build ได้ → ปัญหาไม่ได้อยู่ที่โค้ด แต่อยู่ที่ **Vercel project configuration** ที่ทำให้ทุก build พังเหมือนกันหมด

---

## 2. สาเหตุที่แท้จริง (Root Cause)

**Vercel "Root Directory" setting ยังชี้ที่ `hrisense-app` ค้างอยู่** จากตอนที่ repo เคยเป็น monorepo

ประวัติที่ทำให้เกิด:

1. เดิม repo เป็น monorepo — แอป Next.js อยู่ในโฟลเดอร์ย่อย `hrisense-app/`
2. เพื่อให้ Vercel build เจอแอป จึง **ตั้ง Root Directory = `hrisense-app`** ใน Dashboard
3. ต่อมา **ย้ายไฟล์แอปทั้งหมดมาไว้ที่ root + ลบโฟลเดอร์ `hrisense-app/` ทิ้ง**
4. ❌ **แต่ลืม revert ค่า Root Directory ใน Vercel Dashboard กลับเป็น root**

ผลลัพธ์: Vercel พยายาม build ในโฟลเดอร์ `hrisense-app/` ที่**ไม่มีอยู่แล้ว** → build fail ทุกครั้ง → ไม่มี production build ที่สำเร็จให้ serve → โดเมน production ตอบ **404 NOT_FOUND**

โครงสร้าง repo ปัจจุบัน (แอปอยู่ที่ root แล้ว — ถูกต้องสำหรับ Vercel zero-config):

```
hrisense/                          ← Root Directory ควรชี้มาที่นี่ (ปัจจุบันตั้งผิดเป็น hrisense-app)
├── package.json                   ← มี "build": "next build", deps Next.js 14.2.0
├── next.config.js
├── src/app/                       ← App Router (มี page.tsx, layout.tsx ครบ)
├── docs/
└── supabase/
```

---

## 3. วิธีแก้ (เจ้าของต้องทำใน Vercel Dashboard — แก้ผ่าน repo ไม่ได้)

1. เข้า **Project → Settings → Build and Deployment**
2. หัวข้อ **Root Directory** → **ลบค่า `hrisense-app` ออกให้ว่าง** (= ใช้ root ของ repo)
3. **Save**
4. ไปที่ **Deployments → ⋯ → Redeploy** (ปิด "Use existing build cache")

ผลลัพธ์: Vercel จะ auto-detect Next.js 14 แล้วรัน `npm install` + `next build` ที่ root ของ repo

> ⚠️ **อย่าตั้ง Root Directory = `hrisense-app` อีก** — โฟลเดอร์นั้นถูกลบไปแล้ว (นี่คือสาเหตุของ 404 ปัจจุบัน)

---

## 4. ยืนยันสาเหตุ (ถ้าต้องการ proof จาก build log)

อ่าน build log ของ deployment ที่ fail — น่าจะเห็นข้อความแนว:

```
The specified Root Directory "hrisense-app" does not exist.
```

ดูได้จาก:
- Vercel Dashboard → Deployments → (deployment ที่ fail) → Build Logs
- หรือ CLI: `npx vercel inspect <deployment-id> --logs`

---

## 5. Checklist หลังแก้

- [ ] Build log เห็น `Detected Next.js version: 14.2.0` และ `Running "next build"` (ใช้เวลาหลายสิบวินาที ไม่ใช่จบใน < 1s)
- [ ] Deployment เปลี่ยนจาก `failure` เป็น `success`
- [ ] เปิด `https://hrisense.vercel.app/` แล้ว redirect ไป `/login` (ไม่ใช่ 404)
- [ ] ตั้ง Environment Variables ของ Supabase ใน Vercel ครบ (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`)

---

## 6. หมายเหตุ (เกี่ยวข้องแต่คนละเรื่อง)

- การที่ GitHub Actions `deploy.yml` เคย fail เป็น**คนละปัญหา** (secrets ใน job-level `if:` — แก้แล้วใน commit `0a26639`) Vercel deploy ทำผ่าน **Git integration** ไม่ได้พึ่ง GitHub Actions ฉะนั้นแก้ workflow ไม่ได้ทำให้ 404 หาย — ต้องแก้ Root Directory เท่านั้น
- `next.config.js` เพิ่ม `eslint.ignoreDuringBuilds` + `typescript.ignoreBuildErrors` เป็น safety net โดยให้ CI (`.github/workflows/ci.yml`) เป็น gate ตรวจ lint/type แทน — กันไม่ให้ lint/type error บล็อก production deploy ในอนาคต (ไม่เกี่ยวกับ 404 รอบนี้)
