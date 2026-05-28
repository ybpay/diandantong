export interface AdminShop {
  id: number
  name: string
  contact_name: string
  contact_phone: string
  address: string
  logo_url: string
  description: string
  branches: AdminBranch[]
  business_hours: string
  created_at: string
  updated_at: string
}

export interface AdminBranch {
  id: number
  name: string
  shop_id: number
  address: string
  phone: string
  business_mode: BranchBusinessMode
  support_delivery: boolean
  support_eat_in_hall: boolean
  support_fast_food: boolean
  support_reservation: boolean
  support_payment: boolean
  support_queue: boolean
  status: 'active' | 'inactive'
  created_at: string
}

export interface AdminUser {
  id: number
  username: string
  name: string
  role: string
  phone: string
  email: string
  branch_ids: number[]
  avatar_url: string
  created_at: string
}

export interface AdminRole {
  id: number
  name: string
  permissions: string[]
  description: string
  created_at: string
}

export interface AdminProduct {
  id: number
  name: string
  price: number
  original_price: number
  category_id: number
  category_name: string
  description: string
  image_url: string
  unit: string
  is_sold_out: boolean
  is_active: boolean
  variants: AdminProductVariant[]
  created_at: string
}

export interface AdminCategory {
  id: number
  name: string
  parent_id: number | null
  sort_order: number
  icon_url: string
  is_active: boolean
  children: AdminCategory[]
}

export interface AdminCombo {
  id: number
  name: string
  price: number
  original_price: number
  image_url: string
  items: AdminComboItem[]
  is_active: boolean
  created_at: string
}

export interface AdminComboItem {
  id: number
  name: string
  product_id: number
  quantity: number
}

export interface AdminProductVariant {
  id: number
  name: string
  price: number
  product_id: number
  sku: string
}

export interface AdminOrder {
  id: number
  order_no: string
  branch_id: number
  branch_name?: string
  order_type: OrderType
  status: OrderStatus
  state?: string
  total_price: number
  total_amount: number
  original_price: number
  discount_amount: number
  line_items: AdminLineItem[]
  note: string
  placed_at?: string
  created_at: string
  completed_at: string
  // Eat-in-hall specific
  table_id?: number
  table_name?: string
  guest_num?: number
  // Delivery specific
  delivery_address?: string
  delivery_man_id?: number
  delivery_man_name?: string
  delivery_status?: DeliveryStatus
  // Fast-food specific
  take_no?: string
  // Groupon specific
  groupon_id?: number
  groupon_code?: string
  groupon_platform?: string
  // Reservation specific
  reserved_at?: string
  person_count?: number
  customer_name?: string
  customer_phone?: string
  // Recharge specific
  recharge_amount?: number
  bonus_amount?: number
  vip_id?: number
  vip_name?: string
  vip_phone?: string
  // Payment specific
  payment_method?: PaymentMethod
  related_order_id?: number
  related_order_no?: string
  operator_name?: string
  // Common
  vip_info?: AdminVipInfo
  pay_items?: AdminPayItem[]
  adjustments?: AdminAdjustment[]
}

export interface AdminEatInHallOrder extends AdminOrder {
  order_type: 'eat_in_hall'
  table_id: number
  table_name: string
  guest_num: number
}

export interface AdminDeliveryOrder extends AdminOrder {
  order_type: 'delivery'
  delivery_address: string
  delivery_man_id: number | null
  delivery_man_name: string
  delivery_status: DeliveryStatus
}

export interface AdminFastfoodOrder extends AdminOrder {
  order_type: 'fast_food'
  take_no: string
}

export interface AdminGrouponOrder extends AdminOrder {
  order_type: 'groupon'
  groupon_id: number
  groupon_code: string
  groupon_platform: string
}

export interface AdminReservationOrder extends AdminOrder {
  order_type: 'reservation'
  reserved_at: string
  person_count: number
  customer_name: string
  customer_phone: string
  table_id?: number
  table_name?: string
}

export interface AdminRechargeOrder extends AdminOrder {
  order_type: 'recharge'
  recharge_amount: number
  bonus_amount: number
  vip_id: number
  vip_name: string
  vip_phone: string
}

export interface AdminPaymentOrder extends AdminOrder {
  order_type: 'payment'
  payment_method: PaymentMethod
  related_order_id: number
  related_order_no: string
  operator_name: string
}

export type AdminOrderSubtype =
  | AdminEatInHallOrder
  | AdminDeliveryOrder
  | AdminFastfoodOrder
  | AdminGrouponOrder
  | AdminReservationOrder
  | AdminRechargeOrder
  | AdminPaymentOrder

export interface AdminLineItem {
  id: number
  product_id: number
  product_name: string
  variant_name: string
  quantity: number
  price: number
  original_price: number
  note: string
  is_gift: boolean
  is_separate: boolean
  printed: boolean
  status: 'pending' | 'cooking' | 'done'
}

export interface AdminVipInfo {
  id: number
  name: string
  phone: string
  level: number
  level_name: string
  balance: number
  credits: number
  discount_rate: number
  card_no: string
  total_spent: number
  visit_count: number
  last_visit_at: string
  created_at: string
}

export interface AdminVipLevel {
  id: number
  name: string
  min_spent: number
  discount_rate: number
  credits_rate: number
  benefits: string
  is_default: boolean
}

export interface AdminCoupon {
  id: number
  name: string
  type: 'percent' | 'fixed' | 'gift'
  value: number
  min_price: number
  expires_at: string
  total_count: number
  used_count: number
  status: 'active' | 'expired' | 'disabled'
}

export interface AdminCouponVersion {
  id: number
  name: string
  description: string
  coupon_type: 'percent' | 'fixed' | 'gift'
  coupons: AdminCoupon[]
  created_at: string
}

export interface AdminRechargeProduct {
  id: number
  name: string
  amount: number
  bonus_amount: number
  credits: number
  is_active: boolean
  sort_order: number
}

export interface AdminCreditsSetting {
  id: number
  rate: number
  min_order_amount: number
  max_daily_earn: number
  is_active: boolean
}

export interface AdminPromotion {
  id: number
  name: string
  type: string
  description: string
  start_at: string
  end_at: string
  rules: Record<string, unknown>
  actions: Record<string, unknown>
  is_active: boolean
}

export interface AdminGroupon {
  id: number
  name: string
  price: number
  original_price: number
  image_url: string
  total_count: number
  sold_count: number
  expires_at: string
  status: 'active' | 'expired' | 'sold_out'
}

export interface AdminVoucher {
  id: number
  name: string
  value: number
  min_price: number
  total_count: number
  used_count: number
  expires_at: string
  status: 'active' | 'expired' | 'disabled'
}

export interface AdminPrinter {
  id: number
  name: string
  printer_type: string
  status: 'online' | 'offline'
  branch_id: number
  auto_print: boolean
}

export interface AdminTable {
  id: number
  name: string
  seats: number
  status: 'idle' | 'occupied' | 'reserved' | 'ordering'
  zone_id: number
  zone_name: string
  branch_id: number
}

export interface AdminTableZone {
  id: number
  name: string
  branch_id: number
  tables: AdminTable[]
}

export interface AdminQueue {
  id: number
  branch_id: number
  queue_no: string
  name: string
  phone: string
  guest_num: number
  status: 'waiting' | 'called' | 'seated' | 'cancelled'
  table_id: number | null
  created_at: string
  called_at: string | null
}

export interface AdminStatistic {
  date: string
  branch_id: number
  total_orders: number
  total_amount: number
  avg_order_amount: number
  breakdown: Record<string, number>
}

export interface AdminLoginParams {
  username: string
  password: string
}

export interface AdminLoginResult {
  token: string
  user: AdminUser
  shop: AdminShop
}

export interface AdminPaginatedResult<T> {
  data: T[]
  total: number
  page: number
  per_page: number
}

export interface AdminApiError {
  status: number
  message: string
  errors?: Record<string, string[]>
}

export interface AdminPayItem {
  id?: number
  payment_method: PaymentMethod
  amount: number
  status: 'pending' | 'paid' | 'refunded'
}

export interface AdminAdjustment {
  id: number
  adjustment_type: 'discount' | 'coupon' | 'promotion' | 'manual'
  label: string
  amount: number
  source_type?: string
  source_id?: number
}

export type DeliveryStatus = 'pending' | 'assigned' | 'preparing' | 'delivering' | 'delivered' | 'cancelled'

export type OrderType = 'eat_in_hall' | 'fast_food' | 'delivery' | 'groupon' | 'reservation' | 'recharge' | 'payment'

export type OrderStatus = 'pending' | 'confirmed' | 'preparing' | 'completed' | 'cancelled' | 'refunded'

export type PaymentMethod = 'cash' | 'wechat' | 'alipay' | 'card' | 'vip_balance' | 'credits' | 'voucher' | 'coupon' | 'mixed'

export type BranchBusinessMode = 'eat_in_hall' | 'fast_food' | 'delivery' | 'reservation' | 'payment'
