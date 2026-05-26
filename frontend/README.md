# Diandantong WebPOS - Vue 3 Monorepo

## Overview

Vue 3 + TypeScript + Vite monorepo replacing the legacy AngularJS 1.3 POS applications.

## Tech Stack

- **Vue 3** with Composition API + `<script setup>`
- **TypeScript** for type safety
- **Vite** as build tool
- **Element Plus** for UI components
- **Tailwind CSS 4** for utility styling
- **Pinia** for state management
- **Vue Router 4** for routing
- **Axios** for HTTP requests
- **ECharts 5** for charts (planned)

## Structure

```
frontend/
├── apps/
│   ├── webpos/              # Main POS cashier
│   ├── webpos-queue/        # Queue management
│   ├── webpos-bill/         # Bill center
│   ├── webpos-kitchen/      # Kitchen display (KDS)
│   ├── webpos-users/        # VIP user management
│   ├── webpos-estimate/     # Table clearing
│   └── webpos-extended-form/# Extended forms
├── packages/
│   ├── ui/                  # Shared UI components
│   ├── composables/         # Shared composables
│   ├── api/                 # Axios API service layer
│   ├── stores/              # Pinia stores
│   └── types/               # TypeScript type definitions
├── tailwind.config.ts
├── tsconfig.json
└── pnpm-workspace.yaml
```

## Getting Started

```bash
cd frontend
pnpm install
pnpm dev          # Start main POS app
pnpm dev:queue    # Start queue app
pnpm dev:bill     # Start bill app
pnpm dev:kitchen  # Start kitchen app
pnpm dev:users    # Start users app
pnpm build        # Build all apps
```

## Development

Each app runs independently on its own port (3001-3007). The dev server proxies API requests to the Rails backend at localhost:3000.

## Build Output

Built assets go to `public/webpos_*` directories, served by the Rails application.
