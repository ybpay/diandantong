# Diandantong API v1 Documentation

## Overview

The Diandantong API provides RESTful JSON endpoints for all business operations.
All APIs are versioned under `/api/v1/`.

## Authentication

Three authentication methods are supported:

### 1. Legacy Token Authentication
```
X-Account-Login-Id: <login_id>
X-Account-Authentication-Token: <token>
```

### 2. JWT Bearer Token (planned for Rails 8.1 upgrade)
```
Authorization: Bearer <jwt_token>
```

### 3. OAuth 2.0 (Doorkeeper)
```
Authorization: Bearer <oauth_access_token>
```

## Response Format

### Success Response
```json
{
  "data": { ... },
  "meta": { ... }
}
```

### Error Response
```json
{
  "errors": [
    {
      "status": 422,
      "title": "Validation failed",
      "code": "VALIDATION_ERROR",
      "detail": "Name can't be blank",
      "source": { "pointer": "/data/attributes/name" }
    }
  ]
}
```

## Pagination

Paginated responses include headers:
- `X-Total-Count`: Total number of records
- `X-Total-Pages`: Total number of pages
- `X-Per-Page`: Records per page (max 100)
- `X-Page`: Current page number
- `Link`: Pagination links (first, prev, next, last)

Query parameters: `page`, `per_page`

## API Endpoints

---

### Core API (`/api/v1/`)

#### Authentication
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/login` | Login with login_id + password |
| GET | `/api/v1/auth/me` | Get current user info |

#### Accounts
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/accounts/:id` | Get account details |
| PATCH | `/api/v1/accounts/:id` | Update account |

#### Shops
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/shops` | List shops |
| GET | `/api/v1/shops/:id` | Get shop details |
| GET | `/api/v1/shops/:shop_id/branches` | List branches |
| GET | `/api/v1/shops/:shop_id/branches/:id` | Get branch |
| PATCH | `/api/v1/shops/:shop_id/branches/:id` | Update branch |

---

### WebPOS API (`/api/v1/webpos/`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/products` | List products |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/products/:id` | Get product |
| POST | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/products` | Create product |
| PATCH | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/products/:id` | Update product |
| DELETE | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/products/:id` | Delete product |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/categories` | List categories |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/categories/:id` | Get category |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/orders` | List orders |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/orders/:id` | Get order |
| PATCH | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/orders/:id` | Update order |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/orders/pending_counts` | Pending order counts |
| POST | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/orders/batch_change_state` | Batch change order state |
| POST | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/orders/:order_id/payments` | Create payment |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/vip_infos` | List VIP customers |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/vip_infos/:id` | Get VIP customer |
| POST | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/vip_infos` | Create VIP customer |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/printers` | List printers |
| POST | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/printers` | Create printer |
| PATCH | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/printers/:id` | Update printer |
| DELETE | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/printers/:id` | Delete printer |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/tables` | List tables |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/shift/current` | Current shift |
| POST | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/shift/open` | Open shift |
| PATCH | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/shift/close/:id` | Close shift |
| GET | `/api/v1/webpos/shops/:shop_slug/branches/:branch_id/statistics` | Branch statistics |

---

### WeChat API (`/api/v1/weixin/`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/weixin/shops` | List shops (public) |
| GET | `/api/v1/weixin/shops/:id` | Get shop (public) |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/products` | List products |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/products/:id` | Get product |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/categories` | List categories |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/orders` | List orders |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/orders/:id` | Get order |
| POST | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/orders` | Create order |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/guest_queues` | List queue |
| POST | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/guest_queues` | Join queue |
| GET | `/api/v1/weixin/shops/:shop_id/branches/:branch_id/vip_infos` | List VIP |

---

### Backend API (`/api/v1/backend/`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/backend/shops/:shop_slug/branches` | List branches |
| POST | `/api/v1/backend/shops/:shop_slug/branches` | Create branch |
| PATCH | `/api/v1/backend/shops/:shop_slug/branches/:id` | Update branch |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products` | List products |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products` | Create product |
| PATCH | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products/:id` | Update product |
| DELETE | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products/:id` | Delete product |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products/search` | Search products |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products/batch_on_shelf` | Batch on-shelf |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products/batch_off_shelf` | Batch off-shelf |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/products/batch_remove` | Batch delete |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/categories` | List categories |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/categories` | Create category |
| PATCH | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/categories/:id` | Update category |
| DELETE | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/categories/:id` | Delete category |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/orders` | List orders |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/orders/:id` | Get order |
| PATCH | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/orders/:id` | Update order |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/printers` | List printers |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/printers` | Create printer |
| PATCH | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/printers/:id` | Update printer |
| DELETE | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/printers/:id` | Delete printer |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos` | List VIP customers |
| POST | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos` | Create VIP |
| PATCH | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/crm/vip_infos/:id` | Update VIP |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/business` | Business stats |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/orders` | Order stats |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/products` | Product stats |
| GET | `/api/v1/backend/shops/:shop_slug/branches/:branch_id/statistics/finance` | Finance stats |
| GET | `/api/v1/backend/shops/:shop_slug/coupons` | List coupons |
| POST | `/api/v1/backend/shops/:shop_slug/coupons` | Create coupon |
| PATCH | `/api/v1/backend/shops/:shop_slug/coupons/:id` | Update coupon |
| DELETE | `/api/v1/backend/shops/:shop_slug/coupons/:id` | Delete coupon |

---

### Agent System API (`/api/v1/agentsys/`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/agentsys/shops` | List agent shops |
| GET | `/api/v1/agentsys/shops/:id` | Get agent shop |
| GET | `/api/v1/agentsys/shops/:shop_id/recharge_records` | List recharge records |
| POST | `/api/v1/agentsys/shops/:shop_id/recharge_records` | Create recharge record |

---

### Common API (`/api/v1/common/`)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/common/session` | Login |
| DELETE | `/api/v1/common/session` | Logout |
| GET | `/api/v1/common/account` | Current account |
| POST | `/api/v1/common/account` | Register |
| POST | `/api/v1/common/account/update_password` | Change password |

---

### OAuth API (`/api/v1/oauth/`)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/oauth/account` | Get account via OAuth |
| GET | `/api/v1/oauth/branches` | List branches via OAuth |
| GET | `/api/v1/oauth/branches/:branch_id/products` | List products via OAuth |

---

### Internal API (`/api/v1/inner/`)

Requires API key authentication (ApiAuth HMAC signature).

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/inner/shops` | List shops |
| GET | `/api/v1/inner/shops/:id` | Get shop |
| GET | `/api/v1/inner/branches` | List branches |
| GET | `/api/v1/inner/accounts` | List accounts |
| POST | `/api/v1/inner/accounts/authenticate` | Authenticate account |
| POST | `/api/v1/inner/printers/notify_error` | Printer error notification |
| POST | `/api/v1/inner/printers/notify_not_working` | Printer offline notification |

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `AUTH_FAILED` | 401 | Authentication failed |
| `TOKEN_EXPIRED` | 401 | Token has expired |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `FEATURE_DISABLED` | 403 | Feature not enabled |
| `NOT_FOUND` | 404 | Resource not found |
| `PARAMETER_MISSING` | 400 | Required parameter missing |
| `PAYMENT_ERROR` | 400 | Payment processing error |
| `CONFLICT` | 409 | Concurrent modification conflict |

## Backward Compatibility

All existing HAML-view controllers and legacy endpoints remain functional.
The new API endpoints coexist with the existing web interface during the transition period.
