import { APIRequestContext, expect } from '@playwright/test'

const BASE = '/api/v1/backend'

export class BackendAPI {
  constructor(private request: APIRequestContext) {}

  async createProduct(branchId: number | string, data: Record<string, unknown>) {
    const res = await this.request.post(`${BASE}/branches/${branchId}/products`, { data })
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async getProducts(branchId: number | string) {
    const res = await this.request.get(`${BASE}/branches/${branchId}/products`)
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async updateProduct(
    branchId: number | string,
    productId: number | string,
    data: Record<string, unknown>,
  ) {
    const res = await this.request.patch(
      `${BASE}/branches/${branchId}/products/${productId}`,
      { data },
    )
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async deleteProduct(branchId: number | string, productId: number | string) {
    const res = await this.request.delete(
      `${BASE}/branches/${branchId}/products/${productId}`,
    )
    expect(res.ok()).toBeTruthy()
  }

  async getCategories(branchId: number | string) {
    const res = await this.request.get(`${BASE}/branches/${branchId}/categories`)
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async createCategory(branchId: number | string, data: Record<string, unknown>) {
    const res = await this.request.post(`${BASE}/branches/${branchId}/categories`, { data })
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async getOrders(branchId: number | string) {
    const res = await this.request.get(`${BASE}/branches/${branchId}/orders`)
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async confirmOrder(branchId: number | string, orderId: number | string) {
    const res = await this.request.put(
      `${BASE}/branches/${branchId}/orders/${orderId}/confirm`,
    )
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async getRoles() {
    const res = await this.request.get(`${BASE}/roles`)
    expect(res.ok()).toBeTruthy()
    return res.json()
  }

  async createRole(data: Record<string, unknown>) {
    const res = await this.request.post(`${BASE}/roles`, { data })
    expect(res.ok()).toBeTruthy()
    return res.json()
  }
}
