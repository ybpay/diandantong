export interface Shop {
  id: number
  name: string
  branches: Branch[]
}

export interface Branch {
  id: number
  name: string
  shop_id: number
  business_mode: 'eat_in_hall' | 'fast_food' | 'delivery' | 'reservation' | 'payment'
  support_delivery: boolean
  support_eat_in_hall: boolean
  support_fast_food: boolean
  support_reservation: boolean
  support_payment: boolean
  support_queue: boolean
}

export interface Table {
  id: number
  name: string
  seats: number
  status: 'idle' | 'occupied' | 'reserved' | 'ordering'
  zone_id: number
  branch_id: number
  current_order_id?: number
}

export interface TableZone {
  id: number
  name: string
  branch_id: number
  tables: Table[]
}

export interface Product {
  id: number
  name: string
  price: number
  original_price: number
  category_id: number
  category_name: string
  is_sold_out: boolean
  description?: string
  image_url?: string
  unit?: string
  variants?: ProductVariant[]
  combos?: ComboItem[]
}

export interface ProductVariant {
  id: number
  name: string
  price: number
  product_id: number
}

export interface ComboItem {
  id: number
  name: string
  product_id: number
  quantity: number
}

export interface CartItem {
  id?: number
  product_id: number
  product_name: string
  variant_id?: number
  variant_name?: string
  quantity: number
  price: number
  original_price: number
  note?: string
  is_gift: boolean
  is_separate: boolean
  combo_items?: ComboItem[]
}

export interface Cart {
  id?: number
  branch_id: number
  table_id?: number
  items: CartItem[]
  total_price: number
  original_price: number
  discount_amount: number
  vip_info_id?: number
  order_type: OrderType
}

export type OrderType = 'eat_in_hall' | 'fast_food' | 'delivery' | 'reservation' | 'payment' | 'groupon' | 'recharge'

export type OrderStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled'

export interface Order {
  id: number
  order_no: string
  branch_id: number
  order_type: OrderType
  status: OrderStatus
  total_price: number
  total_amount: number
  original_price: number
  discount_amount: number
  hastened: boolean
  vip_info?: VipInfo
  line_items: LineItem[]
  table?: Table
  note?: string
  created_at: string
  completed_at?: string
  delivery_man_id?: number
  delivery_address?: DeliveryAddress
  guest_num?: number
  reservation_info?: ReservationInfo
}

export interface LineItem {
  id: number
  product_id: number
  product_name: string
  variant_name?: string
  quantity: number
  price: number
  original_price: number
  note?: string
  is_gift: boolean
  is_separate: boolean
  combo_items?: ComboItem[]
  printed: boolean
  status: 'pending' | 'cooking' | 'done'
}

export interface VipInfo {
  id: number
  name: string
  phone: string
  level: number
  level_name: string
  balance: number
  credits: number
  discount_rate: number
  card_no: string
}

export interface DiscountPlan {
  id: number
  name: string
  type: 'percent' | 'fixed' | 'reduction'
  value: number
  min_price?: number
}

export interface Coupon {
  id: number
  name: string
  type: 'percent' | 'fixed' | 'gift'
  value: number
  min_price?: number
  expires_at: string
}

export interface Voucher {
  id: number
  name: string
  value: number
  expires_at: string
}

export interface PayItem {
  id?: number
  payment_method: PaymentMethod
  amount: number
  status: 'pending' | 'paid' | 'refunded'
}

export type PaymentMethod = 'cash' | 'wechat' | 'alipay' | 'card' | 'vip_balance' | 'credits' | 'voucher' | 'coupon' | 'mixed'

export interface Printer {
  id: number
  name: string
  printer_type: string
  status: 'online' | 'offline'
  branch_id: number
}

export interface Notification {
  id: string
  type: 'new_order' | 'order_cancelled' | 'queue_called' | 'delivery_assigned' | 'estimate_clear'
  title: string
  content: string
  branch_id: number
  created_at: string
  read: boolean
}

export interface GuestQueue {
  id: number
  branch_id: number
  queue_no: string
  name: string
  phone?: string
  guest_num: number
  status: 'waiting' | 'called' | 'seated' | 'cancelled'
  table_id?: number
  created_at: string
  called_at?: string
}

export interface QueueEntry {
  id: number
  branch_id: number
  queue_number: string
  name: string
  phone?: string
  guest_num: number
  status: 'waiting' | 'called' | 'seated' | 'cancelled'
  table_id?: number
  created_at: string
  called_at?: string
}

export interface DeliveryAddress {
  id: number
  name: string
  phone: string
  address: string
  lat?: number
  lng?: number
}

export interface ReservationInfo {
  id: number
  name: string
  phone: string
  guest_num: number
  reserved_at: string
  table_id?: number
  note?: string
}

export interface BillCenter {
  id: number
  branch_id: number
  date: string
  total_orders: number
  total_amount: number
  cash_amount: number
  wechat_amount: number
  alipay_amount: number
  card_amount: number
  other_amount: number
  refund_amount: number
}

export interface Statistic {
  branch_id: number
  date: string
  total_orders: number
  total_amount: number
  avg_order_amount: number
  top_products: { name: string; quantity: number; amount: number }[]
}

export interface LoginParams {
  username: string
  password: string
  terminal_id?: string
}

export interface LoginResult {
  token: string
  user: User
  shop: Shop
}

export interface User {
  id: number
  username: string
  name: string
  role: 'admin' | 'manager' | 'cashier' | 'waiter' | 'delivery_man'
  branch_ids: number[]
}

export interface FormElement {
  id: number
  name: string
  field_type: 'text' | 'number' | 'select' | 'date' | 'textarea'
  required: boolean
  options?: string[]
}

export interface ExtendedFormData {
  [key: string]: string | number | boolean
}

export interface PaginatedResult<T> {
  data: T[]
  total: number
  page: number
  per_page: number
}

export interface ApiError {
  status: number
  message: string
  errors?: Record<string, string[]>
}
