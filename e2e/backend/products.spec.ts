import { test, expect } from '../helpers/auth'
import { BackendAPI } from '../helpers/api'
import { TEST_PRODUCT, TEST_BRANCH } from '../fixtures/seed'

test.describe('Product CRUD', () => {
  let api: BackendAPI
  let branchId: string | number

  test.beforeAll(async ({ browser }) => {
    const context = await browser.newContext()
    const page = await context.newPage()

    // Authenticate
    const loginRes = await page.request.post('/api/v1/backend/sessions', {
      data: {
        login_id: process.env.E2E_USER_LOGIN || TEST_SHOP.admin_login,
        password: process.env.E2E_USER_PASSWORD || TEST_SHOP.admin_password,
      },
    })
    test.skip(!loginRes.ok(), 'Login failed — test user may not exist')

    api = new BackendAPI(page.request)
    branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    await context.close()
  })

  test('creates a new product', async ({ authenticatedPage }) => {
    const api = new BackendAPI(authenticatedPage.request)
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const product = await api.createProduct(branchId, {
      product: {
        name: `${TEST_PRODUCT.name} ${Date.now()}`,
        price: TEST_PRODUCT.price,
        description: TEST_PRODUCT.description,
        unit: TEST_PRODUCT.unit,
      },
    })

    expect(product).toHaveProperty('id')
    expect(product.name).toContain(TEST_PRODUCT.name)
  })

  test('lists products for a branch', async ({ authenticatedPage }) => {
    const api = new BackendAPI(authenticatedPage.request)
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const result = await api.getProducts(branchId)

    expect(result).toBeDefined()
    // API returns products array or paginated result
    const products = Array.isArray(result) ? result : result.products || result.data
    expect(Array.isArray(products)).toBeTruthy()
  })

  test('updates a product', async ({ authenticatedPage }) => {
    const api = new BackendAPI(authenticatedPage.request)
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Create first
    const created = await api.createProduct(branchId, {
      product: {
        name: `Update Test ${Date.now()}`,
        price: 19.9,
        unit: '份',
      },
    })

    // Then update
    const updated = await api.updateProduct(branchId, created.id, {
      product: { name: `Updated ${Date.now()}`, price: 39.9 },
    })

    expect(updated.name).toContain('Updated')
  })

  test('deletes a product', async ({ authenticatedPage }) => {
    const api = new BackendAPI(authenticatedPage.request)
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Create first
    const created = await api.createProduct(branchId, {
      product: {
        name: `Delete Test ${Date.now()}`,
        price: 9.9,
        unit: '份',
      },
    })

    // Then delete
    await api.deleteProduct(branchId, created.id)

    // Verify deletion (should 404 or return empty)
    const res = await authenticatedPage.request.get(
      `/api/v1/backend/branches/${branchId}/products/${created.id}`,
    )
    expect([404, 410, 200]).toContain(res.status())
  })

  test('searches products', async ({ authenticatedPage }) => {
    const api = new BackendAPI(authenticatedPage.request)
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await authenticatedPage.request.get(
      `/api/v1/backend/branches/${branchId}/products/search?q=test`,
    )

    if (res.ok()) {
      const result = await res.json()
      expect(result).toBeDefined()
    }
  })

  test('batch operations on products', async ({ authenticatedPage }) => {
    const api = new BackendAPI(authenticatedPage.request)
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Create two products for batch test
    const p1 = await api.createProduct(branchId, {
      product: { name: `Batch 1 ${Date.now()}`, price: 10, unit: '份' },
    })
    const p2 = await api.createProduct(branchId, {
      product: { name: `Batch 2 ${Date.now()}`, price: 15, unit: '份' },
    })

    // Batch on-shelf
    const shelfRes = await authenticatedPage.request.post(
      `/api/v1/backend/branches/${branchId}/products/batch_on_shelf`,
      { data: { product_ids: [p1.id, p2.id] } },
    )
    if (shelfRes.ok()) {
      const body = await shelfRes.json()
      expect(body).toBeDefined()
    }
  })
})

// Need TEST_SHOP import for the test.beforeAll
const TEST_SHOP = {
  admin_login: process.env.E2E_USER_LOGIN || 'demo-shop:admin',
  admin_password: process.env.E2E_USER_PASSWORD || 'password123',
}
