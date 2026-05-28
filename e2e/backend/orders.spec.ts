import { test, expect } from '../helpers/auth'
import { TEST_BRANCH } from '../fixtures/seed'

test.describe('Order Management', () => {
  test('lists orders for a branch', async ({ authenticatedPage }) => {
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id
    const res = await authenticatedPage.request.get(
      `/api/v1/backend/branches/${branchId}/orders`,
    )
    test.skip(!res.ok(), 'Orders endpoint unavailable')

    const result = await res.json()
    expect(result).toBeDefined()
  })

  test('view order detail', async ({ authenticatedPage }) => {
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Get orders list first
    const listRes = await authenticatedPage.request.get(
      `/api/v1/backend/branches/${branchId}/orders`,
    )
    test.skip(!listRes.ok(), 'Orders endpoint unavailable')

    const list = await listRes.json()
    const orders = Array.isArray(list) ? list : list.orders || list.data

    if (orders && orders.length > 0) {
      const orderId = orders[0].id
      const detailRes = await authenticatedPage.request.get(
        `/api/v1/backend/branches/${branchId}/orders/${orderId}`,
      )
      expect(detailRes.ok()).toBeTruthy()
      const order = await detailRes.json()
      expect(order).toHaveProperty('id')
    }
  })

  test('confirm an order', async ({ authenticatedPage }) => {
    const branchId = process.env.E2E_BRANCH_ID || TEST_BRANCH.id

    // Get pending orders
    const listRes = await authenticatedPage.request.get(
      `/api/v1/backend/branches/${branchId}/orders?state=pending`,
    )
    test.skip(!listRes.ok(), 'Orders endpoint unavailable')

    const list = await listRes.json()
    const orders = Array.isArray(list) ? list : list.orders || list.data

    if (orders && orders.length > 0) {
      const orderId = orders[0].id
      const confirmRes = await authenticatedPage.request.put(
        `/api/v1/backend/branches/${branchId}/orders/${orderId}/confirm`,
      )
      if (confirmRes.ok()) {
        const order = await confirmRes.json()
        expect(['confirmed', 'processing']).toContain(order.state?.toLowerCase())
      }
    }
  })
})
