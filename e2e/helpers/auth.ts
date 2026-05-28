import { test as base, expect, type Page } from '@playwright/test'

export interface AuthFixture {
  authenticatedPage: Page
  adminPage: Page
}

async function loginViaAPI(
  page: Page,
  loginId: string,
  password: string,
): Promise<void> {
  const response = await page.request.post('/api/v1/backend/sessions', {
    data: { login_id: loginId, password },
  })
  expect(response.ok()).toBeTruthy()
  // Store auth cookie/token — Devise session cookie is set automatically
  const cookies = await page.context().cookies()
  expect(cookies.length).toBeGreaterThan(0)
}

export const test = base.extend<AuthFixture>({
  authenticatedPage: async ({ page }, use) => {
    await loginViaAPI(
      page,
      process.env.E2E_USER_LOGIN || 'demo-shop:admin',
      process.env.E2E_USER_PASSWORD || 'password123',
    )
    await use(page)
  },

  adminPage: async ({ page }, use) => {
    await loginViaAPI(
      page,
      process.env.E2E_ADMIN_LOGIN || 'demo-shop:boss',
      process.env.E2E_ADMIN_PASSWORD || 'password123',
    )
    await use(page)
  },
})

export { expect }
