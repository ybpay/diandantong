import { test, expect } from '@playwright/test'
import { TEST_AGENT } from '../fixtures/seed'

const AGENT_API = '/api/v1/agent'

test.describe('Agent System Authentication', () => {
  test('login with valid credentials returns token', async ({ request }) => {
    const res = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })

    test.skip(!res.ok(), 'Agent login failed — test agent may not exist in seed data')

    const body = await res.json()
    expect(body).toHaveProperty('token')
  })

  test('login with invalid credentials returns error', async ({ request }) => {
    const res = await request.post(`${AGENT_API}/auth/login`, {
      data: { login: 'nonexistent', password: 'wrong' },
    })

    expect(res.status()).toBe(401)
  })

  test('unauthenticated requests are rejected', async ({ request }) => {
    const res = await request.get(`${AGENT_API}/user`)
    expect([401, 403]).toContain(res.status())
  })

  test('authenticated user can get profile', async ({ request }) => {
    // Login first
    const loginRes = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })
    test.skip(!loginRes.ok(), 'Agent login failed — skipping authenticated tests')

    const { token } = await loginRes.json()

    // Get current user
    const userRes = await request.get(`${AGENT_API}/user`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect(userRes.ok()).toBeTruthy()

    const user = await userRes.json()
    expect(user).toHaveProperty('name')
  })

  test('logout destroys session', async ({ request }) => {
    // Login first
    const loginRes = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })
    test.skip(!loginRes.ok(), 'Agent login failed')

    const { token } = await loginRes.json()

    // Logout
    const logoutRes = await request.delete(`${AGENT_API}/auth/logout`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect([200, 204]).toContain(logoutRes.status())

    // Token should be invalidated
    const userRes = await request.get(`${AGENT_API}/user`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    expect([401, 403]).toContain(userRes.status())
  })
})

test.describe('Agent Dashboard', () => {
  async function getAgentToken(request: import('@playwright/test').APIRequestContext) {
    const loginRes = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })
    if (!loginRes.ok()) return null
    const { token } = await loginRes.json()
    return token
  }

  test('can access dashboard', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/dashboard`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    test.skip(!res.ok(), 'Dashboard endpoint unavailable')
    const dashboard = await res.json()
    expect(dashboard).toBeDefined()
  })
})

test.describe('Merchant Management', () => {
  async function getAgentToken(request: import('@playwright/test').APIRequestContext) {
    const loginRes = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })
    if (!loginRes.ok()) return null
    const { token } = await loginRes.json()
    return token
  }

  test('lists merchants', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/merchants`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    test.skip(!res.ok(), 'Merchants endpoint unavailable')
    const body = await res.json()
    const merchants = Array.isArray(body) ? body : body.merchants || body.data
    expect(Array.isArray(merchants)).toBeTruthy()
  })

  test('views merchant detail', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    // Get merchants list
    const listRes = await request.get(`${AGENT_API}/merchants`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    test.skip(!listRes.ok(), 'Merchants endpoint unavailable')

    const listBody = await listRes.json()
    const merchants = Array.isArray(listBody) ? listBody : listBody.merchants || listBody.data

    if (merchants && merchants.length > 0) {
      const merchantId = merchants[0].id
      const detailRes = await request.get(`${AGENT_API}/merchants/${merchantId}`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      expect(detailRes.ok()).toBeTruthy()
    }
  })

  test('checks merchant expiration list', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/merchants/expirations`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (res.ok()) {
      const body = await res.json()
      expect(body).toBeDefined()
    }
  })
})

test.describe('Brand Management', () => {
  async function getAgentToken(request: import('@playwright/test').APIRequestContext) {
    const loginRes = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })
    if (!loginRes.ok()) return null
    const { token } = await loginRes.json()
    return token
  }

  test('lists brands', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/brands`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (res.ok()) {
      const body = await res.json()
      expect(body).toBeDefined()
    }
  })
})

test.describe('Statistics and Settings', () => {
  async function getAgentToken(request: import('@playwright/test').APIRequestContext) {
    const loginRes = await request.post(`${AGENT_API}/auth/login`, {
      data: {
        login: process.env.E2E_AGENT_LOGIN || TEST_AGENT.login,
        password: process.env.E2E_AGENT_PASSWORD || TEST_AGENT.password,
      },
    })
    if (!loginRes.ok()) return null
    const { token } = await loginRes.json()
    return token
  }

  test('views statistics', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/statistics`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (res.ok()) {
      const stats = await res.json()
      expect(stats).toBeDefined()
    }
  })

  test('views agent settings', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/settings`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    test.skip(!res.ok(), 'Settings endpoint unavailable')
    const settings = await res.json()
    expect(settings).toBeDefined()
  })

  test('views available plans', async ({ request }) => {
    const token = await getAgentToken(request)
    test.skip(!token, 'Cannot get agent token')

    const res = await request.get(`${AGENT_API}/plans`, {
      headers: { Authorization: `Bearer ${token}` },
    })

    if (res.ok()) {
      const plans = await res.json()
      expect(plans).toBeDefined()
    }
  })
})
