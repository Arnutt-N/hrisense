# GitHub Actions Workflows

This project uses GitHub Actions for CI/CD automation.

## Workflows

### 1. CI/CD Pipeline (`ci.yml`)
**Triggers:** Push/PR to `main` or `develop`

**Jobs:**
- **Lint & Type Check**: Runs ESLint and TypeScript type checking
- **Build**: Builds the Next.js application
- **Database Migration Test**: Tests Supabase migrations on a fresh database
- **Deploy to Vercel**: Deploys to production (only on `main` branch pushes)

### 2. Database Migrations (`db-migrations.yml`)
**Triggers:** PR to `main` or `develop` with changes in `supabase/migrations/**`

**Jobs:**
- **Test Migrations**: Runs all migrations on a fresh Supabase instance
- **Migration Diff**: Generates a diff of schema changes for review

### 3. Code Quality (`code-quality.yml`)
**Triggers:** Push/PR to `main` or `develop`

**Jobs:**
- **Format Check**: Checks code formatting with Prettier
- **Dependency Audit**: Runs `npm audit` for security vulnerabilities
- **Test**: Runs tests with coverage (if tests exist)
- **Bundle Size Check**: Analyzes bundle size

### 4. Deploy Preview (`deploy-preview.yml`)
**Triggers:** PR to `main` or `develop`

**Jobs:**
- **Deploy Preview**: Deploys preview to Vercel and comments PR with URL
- **Database Migration (Preview)**: Tests migrations for the PR

## Required Secrets

Add these secrets to your GitHub repository:

| Secret | Description | Where to get |
|--------|-------------|--------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | Supabase Dashboard → Settings → API |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anon/public key | Supabase Dashboard → Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key | Supabase Dashboard → Settings → API |
| `VERCEL_TOKEN` | Vercel API token | Vercel Dashboard → Settings → Tokens |
| `VERCEL_ORG_ID` | Vercel organization ID | Vercel Dashboard → Settings → General |
| `VERCEL_PROJECT_ID` | Vercel project ID | Vercel Dashboard → Settings → General |

## Branch Protection Rules

Recommended branch protection rules for `main`:

1. **Require pull request reviews before merging**
   - Required approving reviews: 1
   - Dismiss stale pull request approvals when new commits are pushed

2. **Require status checks to pass before merging**
   - Required status checks:
     - `Lint & Type Check`
     - `Build Application`
     - `Test Migrations`
     - `Format Check`
     - `Dependency Audit`

3. **Require branches to be up to date before merging**

4. **Include administrators** (optional but recommended)

## Local Development

### Run linting locally
```bash
npm run lint
```

### Run type checking locally
```bash
npx tsc --noEmit
```

### Test migrations locally
```bash
npx supabase start
npx supabase db push
npx supabase stop
```

### Build locally
```bash
npm run build
```

## Workflow Status Badges

Add these badges to your README.md:

```markdown
[![CI/CD](https://github.com/nutchahrmoj/hrisense/actions/workflows/ci.yml/badge.svg)](https://github.com/nutchahrmoj/hrisense/actions/workflows/ci.yml)
[![Database Migrations](https://github.com/nutchahrmoj/hrisense/actions/workflows/db-migrations.yml/badge.svg)](https://github.com/nutchahrmoj/hrisense/actions/workflows/db-migrations.yml)
[![Code Quality](https://github.com/nutchahrmoj/hrisense/actions/workflows/code-quality.yml/badge.svg)](https://github.com/nutchahrmoj/hrisense/actions/workflows/code-quality.yml)
[![Deploy Preview](https://github.com/nutchahrmoj/hrisense/actions/workflows/deploy-preview.yml/badge.svg)](https://github.com/nutchahrmoj/hrisense/actions/workflows/deploy-preview.yml)
```
