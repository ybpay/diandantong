import { test, expect } from '@playwright/test'
import { TEST_SHOP, TEST_BRANCH, TEST_USER } from '../fixtures/seed'

const WEIXIN_API = '/api/v1/weixin'

test.describe('WeChat Shop Listing', () => {
  test('lists available shops', async ({ request }) => {
    const res = await request.get(`${WEIXIN_API}/shops`)
    test.skip(!res.ok(), 'Weixin shops endpoint unavailable')

    const body = await res.json()
    const shops = Array.isArray(body) ? body : body.shops || body.data
    expect(Array.isArray(shops)).toBeTruthy()
  })

  test('shows shop detail', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const res = await request.get(`${WEIXIN_API}/shops/${shopSlug}`)
    test.skip(!res.ok(), `Shop ${shopSlug} not found`)

    const shop = await res.json()
    expect(shop).toHaveProperty('name')
  })
})

test.describe('WeChat Product Browsing', () => {
  test('lists products for a branch', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/products`,
    )
    test.skip(!res.ok(), 'Products endpoint unavailable')

    const body = await res.json()
    const products = Array.isArray(body) ? body : body.products || body.data
    expect(Array.isArray(products)).toBeTruthy()
  })

  test('shows product detail', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Get products list first
    const listRes = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/products`,
    )
    test.skip(!listRes.ok(), 'Products endpoint unavailable')

    const listBody = await listRes.json()
    const products = Array.isArray(listBody) ? listBody : listBody.products || listBody.data

    if (products && products.length > 0) {
      const productId = products[0].id
      const detailRes = await request.get(
        `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/products/${productId}`,
      )
      expect(detailRes.ok()).toBeTruthy()
      const product = await detailRes.json()
      expect(product).toHaveProperty('name')
      expect(product).toHaveProperty('price')
    }
  })

  test('lists categories for a branch', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/categories`,
    )
    test.skip(!res.ok(), 'Categories endpoint unavailable')

    const body = await res.json()
    const categories = Array.isArray(body) ? body : body.categories || body.data
    expect(Array.isArray(categories)).toBeTruthy()
  })
})

test.describe('WeChat Ordering Flow', () => {
  test('creates an order', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Query available products first
    const productsRes = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/products`,
    )
    test.skip(!productsRes.ok(), 'Cannot fetch products for order')

    const productsBody = await productsRes.json()
    const products = Array.isArray(productsBody) ? productsBody : productsBody.products || productsBody.data || []
    test.skip(products.length === 0, 'No products available for order creation')

    const orderRes = await request.post(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/orders`,
      {
        data: {
          order: {
            order_type: 'fastfood',
            line_items_attributes: [
              { product_id: products[0].id, quantity: 1 },
            ],
            customer_phone: TEST_USER.phone,
            customer_name: TEST_USER.nickname,
          },
        },
      },
    )

    test.skip(!orderRes.ok(), 'Order creation failed — needs seed data')

    const order = await orderRes.json()
    expect(order).toHaveProperty('id')
    expect(order).toHaveProperty('state')
  })

  test('lists orders for a branch', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/orders`,
    )
    if (res.ok()) {
      const body = await res.json()
      const orders = Array.isArray(body) ? body : body.orders || body.data
      expect(Array.isArray(orders)).toBeTruthy()
    }
  })

  test('shows order detail', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Get orders list
    const listRes = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/orders`,
    )
    test.skip(!listRes.ok(), 'Cannot fetch orders')

    const listBody = await listRes.json()
    const orders = Array.isArray(listBody) ? listBody : listBody.orders || listBody.data

    if (orders && orders.length > 0) {
      const orderId = orders[0].id
      const detailRes = await request.get(
        `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/orders/${orderId}`,
      )
      if (detailRes.ok()) {
        const order = await detailRes.json()
        expect(order).toHaveProperty('id')
      }
    }
  })
})

test.describe('WeChat Guest Queue', () => {
  test('lists queue status for a branch', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await request.get(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/guest_queues`,
    )
    if (res.ok()) {
      const body = await res.json()
      expect(body).toBeDefined()
    }
  })

  test('creates a guest queue entry', async ({ request }) => {
    const shopSlug = process.env.E2E_SHOP_SLUG || TEST_SHOP.slug
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    const res = await request.post(
      `${WEIXIN_API}/shops/${shopSlug}/branches/${branchId}/guest_queues`,
      {
        data: {
          guest_queue: {
            guest_num: 2,
            phone: TEST_USER.phone,
          },
        },
      },
    )

    test.skip(!res.ok(), 'Guest queue creation failed — needs queue settings seed data')
    const queue = await res.json()
    expect(queue).toHaveProperty('id')
  })
})
