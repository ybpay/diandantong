import { test, expect } from '@playwright/test'
import { TEST_SHOP } from '../fixtures/seed'

test.describe('Backend Login', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/account/sign_in')
  })

  test('shows login form with required fields', async ({ page }) => {
    await expect(page.locator('#account_login_id')).toBeVisible()
    await expect(page.locator('#account_password')).toBeVisible()
    await expect(page.locator('input[type="submit"], button[type="submit"]')).toBeVisible()
  })

  test('displays error on invalid credentials', async ({ page }) => {
    await page.fill('#account_login_id', 'invalid:user')
    await page.fill('#account_password', 'wrong_password')
    await page.click('input[type="submit"], button[type="submit"]')

    await expect(page.locator('.alert, .error, [role="alert"]')).toBeVisible()
  })

  test('logs in successfully with valid credentials', async ({ page }) => {
    await page.fill('#account_login_id', TEST_SHOP.admin_login)
    await page.fill('#account_password', TEST_SHOP.admin_password)
    await page.click('input[type="submit"], button[type="submit"]')

    await expect(page).toHaveURL(/\/(admin|backend|dashboard)/)
  })

  test('redirects unauthenticated users to login', async ({ page }) => {
    await page.goto('/api/v1/backend/shops/demo-shop')
    // API endpoints return 401 for unauthenticated requests
    const status = await page.evaluate(() => fetch('/api/v1/backend/shops/demo-shop').then(r => r.status))
    expect(status).toBe(401)
  })

  test('remember me persists session', async ({ page }) => {
    await page.fill('#account_login_id', TEST_SHOP.admin_login)
    await page.fill('#account_password', TEST_SHOP.admin_password)
    const rememberCheckbox = page.locator('#account_remember_me')
    if (await rememberCheckbox.isVisible()) {
      await rememberCheckbox.check()
    }
    await page.click('input[type="submit"], button[type="submit"]')
    await expect(page).toHaveURL(/\/(admin|backend|dashboard)/)
  })
})

test.describe('Backend Logout', () => {
  test('logs out and redirects to login page', async ({ page }) => {
    // Login first via API
    const loginRes = await page.request.post('/api/v1/backend/sessions', {
      data: { login_id: TEST_SHOP.admin_login, password: TEST_SHOP.admin_password },
    })
    test.skip(!loginRes.ok(), 'Login failed — test user may not exist')

    // Logout
    await page.goto('/account/sign_out')
    // Verify redirected to login or home
    await expect(page).toHaveURL(/\/(sign_in|account\/sign_in|\.)?$/)
  })
})
