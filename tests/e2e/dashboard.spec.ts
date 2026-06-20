import { test, expect } from '@playwright/test'

test.describe('Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    // Login ก่อนเข้า dashboard (mock mode)
    await page.goto('/login')
    await page.getByRole('button', { name: /เข้าสู่ระบบ/ }).click()
    await page.waitForURL('**/dashboard', { timeout: 5000 })
  })

  test('หน้า dashboard หลักโหลดสำเร็จ', async ({ page }) => {
    await expect(page).toHaveURL(/.*dashboard/)
    await expect(page.locator('h1, h2').first()).toBeVisible()
  })

  test('มีเมนู sidebar นำทาง', async ({ page }) => {
    // Sidebar ควรมีเมนู้ต่างๆ
    const sidebar = page.locator('nav, [role="navigation"]').first()
    await expect(sidebar).toBeVisible()
  })

  test('导航 ไปหน้า Personnel ได้', async ({ page }) => {
    const personnelLink = page.getByText(/บุคลากร|Personnel/i).first()
    if (await personnelLink.isVisible()) {
      await personnelLink.click()
      await page.waitForURL('**/personnel**', { timeout: 5000 })
      await expect(page).toHaveURL(/.*personnel/)
    }
  })

  test('หน้า dashboard มี KPI cards', async ({ page }) => {
    // KPI cards มักจะใช้ card component
    const cards = page.locator('[class*="card"], [class*="kpi"]')
    const count = await cards.count()
    expect(count).toBeGreaterThan(0)
  })
})
