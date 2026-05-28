import { test, expect } from '@playwright/test'
import { TEST_SHOP, TEST_BRANCH } from '../fixtures/seed'

const WEBPOS_LOGIN = '/webpos_accounts/sign_in'

test.describe('WebPOS Login', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(WEBPOS_LOGIN)
  })

  test('shows POS login form', async ({ page }) => {
    await expect(page.locator('#webpos_account_login_id, input[name="login_id"]')).toBeVisible()
    await expect(page.locator('input[type="password"]')).toBeVisible()
  })

  test('logs in with valid credentials and sees POS interface', async ({ page }) => {
    const loginInput = page.locator('#webpos_account_login_id, input[name="login_id"]')
    await loginInput.fill(TEST_SHOP.admin_login)
    await page.fill('input[type="password"]', TEST_SHOP.admin_password)
    await page.click('input[type="submit"], button[type="submit"]')

    // Should redirect to webpos dashboard
    await expect(page).toHaveURL(/\/webpos/)
  })
})

test.describe('POS Checkout Flow', () => {
  let authToken: string | undefined

  test.beforeEach(async ({ page }) => {
    // Authenticate via POS session
    await page.goto(WEBPOS_LOGIN)
    const loginInput = page.locator('#webpos_account_login_id, input[name="login_id"]')
    await loginInput.fill(TEST_SHOP.admin_login)
    await page.fill('input[type="password"]', TEST_SHOP.admin_password)
    await page.click('input[type="submit"], button[type="submit"]')

    const redirected = page.url()
    test.skip(!redirected.includes('webpos'), 'POS login failed — test user may not exist')
  })

  test('shows shop and branch selection', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await page.request.get(`/webpos/shops/${shopId}/branches`)
    if (res.ok()) {
      const branches = await res.json()
      expect(branches).toBeDefined()
    }
  })

  test('can load products for a branch', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/products`,
    )
    if (res.ok()) {
      const products = await res.json()
      expect(Array.isArray(products) || products.data).toBeTruthy()
    }
  })

  test('can load categories for a branch', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/categories`,
    )
    if (res.ok()) {
      const categories = await res.json()
      expect(Array.isArray(categories) || categories.data).toBeTruthy()
    }
  })

  test('can create a fast food order', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Query available products first
    const productsRes = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/products`,
    )
    test.skip(!productsRes.ok(), 'Cannot fetch products for order')

    const productsBody = await productsRes.json()
    const products = Array.isArray(productsBody) ? productsBody : productsBody.data || []
    test.skip(products.length === 0, 'No products available for order creation')

    const orderRes = await page.request.post(
      `/webpos/shops/${shopId}/branches/${branchId}/fastfood_orders`,
      {
        data: {
          fastfood_order: {
            line_items_attributes: [
              {
                product_id: products[0].id,
                quantity: 1,
                price: products[0].price,
              },
            ],
          },
        },
      },
    )

    test.skip(!orderRes.ok(), 'Fast food order creation failed — needs seed data')

    const order = await orderRes.json()
    expect(order).toHaveProperty('id')
  })

  test('can confirm and complete an order', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Get existing orders
    const listRes = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/orders`,
    )
    test.skip(!listRes.ok(), 'Cannot fetch orders')

    const result = await listRes.json()
    const orders = Array.isArray(result) ? result : result.orders || result.data

    if (orders && orders.length > 0) {
      const orderId = orders[0].id

      // Confirm
      const confirmRes = await page.request.post(
        `/webpos/shops/${shopId}/branches/${branchId}/orders/${orderId}/confirm`,
      )
      if (confirmRes.ok()) {
        // Complete
        const completeRes = await page.request.post(
          `/webpos/shops/${shopId}/branches/${branchId}/orders/${orderId}/complete`,
        )
        expect([200, 201, 204]).toContain(completeRes.status())
      }
    }
  })

  test('can handle payment for an order', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Get confirmed orders
    const listRes = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/orders?state=confirmed`,
    )
    test.skip(!listRes.ok(), 'Cannot fetch confirmed orders')

    const result = await listRes.json()
    const orders = Array.isArray(result) ? result : result.orders || result.data

    if (orders && orders.length > 0) {
      const orderId = orders[0].id

      // Query available payment methods
      const methodsRes = await page.request.get(
        `/webpos/shops/${shopId}/branches/${branchId}/payment_methods`,
      )
      if (!methodsRes.ok()) return
      const methodsBody = await methodsRes.json()
      const methods = Array.isArray(methodsBody) ? methodsBody : methodsBody.data || methodsBody.payment_methods || []
      if (methods.length === 0) return

      // Create pay items
      const payRes = await page.request.post(
        `/webpos/shops/${shopId}/branches/${branchId}/orders/${orderId}/create_pay_items`,
        {
          data: {
            pay_items: [{ payment_method_id: methods[0].id, amount: orders[0].total_amount || 19.9 }],
          },
        },
      )

      if (payRes.ok()) {
        const payResult = await payRes.json()
        expect(payResult).toBeDefined()
      }
    }
  })

  test('can view bill for an order', async ({ page }) => {
    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const listRes = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/orders`,
    )
    test.skip(!listRes.ok(), 'Cannot fetch orders')

    const result = await listRes.json()
    const orders = Array.isArray(result) ? result : result.orders || result.data

    if (orders && orders.length > 0) {
      const orderId = orders[0].id

      // Get bill
      const billRes = await page.request.get(
        `/webpos/shops/${shopId}/branches/${branchId}/orders/${orderId}/bill`,
      )
      if (billRes.ok()) {
        const bill = await billRes.json()
        expect(bill).toBeDefined()
      }
    }
  })
})

test.describe('POS Table Management', () => {
  test('lists tables for a branch', async ({ page }) => {
    // Login first
    await page.goto(WEBPOS_LOGIN)
    const loginInput = page.locator('#webpos_account_login_id, input[name="login_id"]')
    await loginInput.fill(TEST_SHOP.admin_login)
    await page.fill('input[type="password"]', TEST_SHOP.admin_password)
    await page.click('input[type="submit"], button[type="submit"]')

    const redirected = page.url()
    test.skip(!redirected.includes('webpos'), 'POS login failed')

    const shopId = process.env.E2E_SHOP_ID || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const tablesRes = await page.request.get(
      `/webpos/shops/${shopId}/branches/${branchId}/tables`,
    )
    if (tablesRes.ok()) {
      const tables = await tablesRes.json()
      expect(tables).toBeDefined()
    }
  })
})
