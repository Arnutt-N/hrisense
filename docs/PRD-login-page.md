# PRD: Login Page Feature — HRiSENSE

## 1. Overview

| Field | Value |
|-------|-------|
| **Product** | HRiSENSE — ระบบพยากรณ์และบริหารความเสี่ยงด้านกำลังคน |
| **Feature** | Login Page |
| **Branch** | `feature/add-login-page` |
| **Author** | Nutcha Anantawichian |
| **Date** | 2026-06-20 |
| **Status** | Draft |

---

## 2. Problem Statement

HRiSENSE is an internal HR risk management system for the Ministry of Justice (สำนักงานปลัดกระทรวงยุติธรรม). The current login page exists but needs improvement in the following areas:

- **No error handling UI** — login failures are silent (no user feedback)
- **No "forgot password" flow** — users cannot self-recover credentials
- **No input validation** — empty fields can be submitted
- **Default credentials exposed** — `admin@moj.go.th` / `password` are hardcoded as defaults
- **No remember me / session persistence** options
- **No role-based redirection** — all users go to `/dashboard` regardless of role

---

## 3. Goals

| # | Goal | Success Metric |
|---|------|----------------|
| G1 | Secure authentication via Supabase Auth | Zero credential leaks in production |
| G2 | Clear error messages for failed logins | 100% of error states display Thai-language feedback |
| G3 | Input validation before submission | No empty/invalid submissions reach the API |
| G4 | Password reset flow | Users can reset password via email |
| G5 | Role-based redirection after login | Admin → `/dashboard`, Viewer → `/personnel` |

---

## 4. User Stories

### 4.1 As a Ministry staff member
> I want to log in with my email and password so that I can access the HR risk dashboard.

**Acceptance Criteria:**
- [ ] Email field validates format before submission
- [ ] Password field is masked with toggle visibility
- [ ] Loading state shows during authentication
- [ ] Success → redirect to `/dashboard`
- [ ] Error → display Thai-language error message below form

### 4.2 As a user who forgot their password
> I want to reset my password via email so that I can regain access.

**Acceptance Criteria:**
- [ ] "ลืมรหัสผ่าน?" link below the login form
- [ ] Clicking opens a modal or navigates to `/forgot-password`
- [ ] User enters email → receives reset link via Supabase
- [ ] Reset link opens `/reset-password` page with new password form

### 4.3 As an admin
> I want to be redirected to the admin dashboard after login.

**Acceptance Criteria:**
- [ ] After login, check `user.role` from Supabase
- [ ] Admin role → `/dashboard`
- [ ] Other roles → `/personnel` (read-only view)

### 4.4 As a developer
> I want the login page to work in mock mode for development.

**Acceptance Criteria:**
- [ ] `NEXT_PUBLIC_USE_MOCK=true` bypasses Supabase
- [ ] Mock mode shows visual indicator (already implemented)
- [ ] Mock mode uses a configurable delay to simulate network

---

## 5. Technical Requirements

### 5.1 Tech Stack
- **Framework:** Next.js 14.2 (App Router)
- **Auth:** Supabase Auth (`@supabase/ssr` + `@supabase/supabase-js`)
- **Styling:** Tailwind CSS
- **Validation:** Zod
- **Icons:** Lucide React

### 5.2 API Integration
```
POST /auth/v1/token?grant_type=password
  → Supabase signInWithPassword()

POST /auth/v1/recover
  → Supabase resetPasswordForEmail()

GET /auth/v1/user
  → Supabase getUser() for role check
```

### 5.3 Files to Modify/Create

| File | Action | Description |
|------|--------|-------------|
| `src/app/(auth)/login/page.tsx` | Modify | Add validation, error UI, password toggle |
| `src/app/(auth)/forgot-password/page.tsx` | Create | Password reset request form |
| `src/app/(auth)/reset-password/page.tsx` | Create | New password form after email link |
| `src/app/(auth)/layout.tsx` | Modify | Add shared error boundary |
| `src/lib/validations/auth.ts` | Create | Zod schemas for login/reset forms |
| `src/lib/supabase/client.ts` | Review | Ensure SSR-compatible client |

### 5.4 Database / Supabase Config
- Enable "Email" provider in Supabase Dashboard
- Configure email templates in Thai language
- Set `SITE_URL` for password reset redirect

---

## 6. UI/UX Requirements

### 6.1 Login Form Layout
```
┌─────────────────────────────┐
│         🛡️ HRiSENSE         │
│   ระบบพยากรณ์และบริหาร      │
│   ความเสี่ยงด้านกำลังคน     │
│                             │
│   ┌───────────────────┐     │
│   │ อีเมล             │     │
│   │ [_______________] │     │
│   └───────────────────┘     │
│   ┌───────────────────┐     │
│   │ รหัสผ่าน    👁️   │     │
│   │ [_______________] │     │
│   └───────────────────┘     │
│                             │
│   [   เข้าสู่ระบบ   ]     │
│                             │
│   ลืมรหัสผ่าน?             │
└─────────────────────────────┘
```

### 6.2 Error States
| Scenario | Message (Thai) |
|----------|---------------|
| Empty email | กรุณากรอกอีเมล |
| Invalid email format | รูปแบบอีเมลไม่ถูกต้อง |
| Empty password | กรุณากรอกรหัสผ่าน |
| Wrong credentials | อีเมลหรือรหัสผ่านไม่ถูกต้อง |
| Network error | ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ |
| Account locked | บัญชีถูกล็อก กรุณาลองใหม่ภายหลัง |

### 6.3 Responsive Design
- Mobile: Single column, full-width inputs
- Desktop: Centered card (max-w-md), as current

---

## 7. Security Requirements

- [ ] Passwords never logged to console in production
- [ ] Rate limiting on login attempts (Supabase built-in)
- [ ] CSRF protection via Supabase SSR cookies
- [ ] No default credentials in production builds
- [ ] Password reset tokens expire after 1 hour
- [ ] Session tokens stored in httpOnly cookies

---

## 8. Out of Scope (v1)

- OAuth / Social login (Google, Microsoft)
- Multi-factor authentication (MFA)
- SSO integration with MOJ systems
- Account registration (admin-only user creation)
- Session timeout configuration UI

---

## 9. Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Design & PRD | 1 day | This document |
| Implementation | 2 days | Login + validation + error UI |
| Password Reset | 1 day | Forgot/reset password flow |
| Role-based Redirect | 0.5 day | Post-login routing |
| Testing | 1 day | Unit + E2E tests |
| Review & Deploy | 0.5 day | PR review + merge |

**Total: ~6 days**

---

## 10. Open Questions

| # | Question | Owner | Status |
|---|----------|-------|--------|
| Q1 | What roles exist in Supabase? (admin, viewer, editor?) | Backend | Open |
| Q2 | Should we enforce password complexity rules? | Security | Open |
| Q3 | Do we need account lockout after N failed attempts? | Security | Open |
| Q4 | Email template language — Thai only or bilingual? | Product | Open |

---

## 11. References

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Next.js App Router](https://nextjs.org/docs/app)
- [Current Login Page](src/app/(auth)/login/page.tsx)
- [Supabase Client](src/lib/supabase/client.ts)
