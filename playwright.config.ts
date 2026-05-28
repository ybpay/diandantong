import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI
    ? [['github'], ['html', { open: 'never' }]]
    : [['list'], ['html', { open: 'on-failure' }]],
  timeout: 30_000,
  expect: { timeout: 10_000 },

  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:9000',
    trace: 'on-first-retry',
    screenshot: 'on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'backend',
      testDir: './e2e/backend',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'webpos',
      testDir: './e2e/webpos',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'weixin',
      testDir: './e2e/weixin',
      use: {
        ...devices['iPhone 14'],
        viewport: { width: 375, height: 812 },
        userAgent:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.38',
      },
    },
    {
      name: 'agentsys',
      testDir: './e2e/agentsys',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
})
