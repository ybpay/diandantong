# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Backend OrderTypes', type: :request do
  let(:shop) { create(:shop_with_boss) }
  let(:boss) { shop.accounts.boss }
  let(:branch) { shop.branches.real.first }
  let(:user) { create(:user, shop: shop) }
  let(:order) { create(:order, shop: shop, branch: branch, user: user) }

  let(:auth_headers) do
    { 'X-Account-Login-Id' => boss.login_id, 'X-Account-Authentication-Token' => boss.authentication_token }
  end

  # ---- Delivery Orders ----

  describe 'Delivery Orders' do
    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders' do
      it 'returns delivery orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end

      it 'returns 401 without auth' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/assigned' do
      it 'returns assigned delivery orders' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/assigned", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id' do
      it 'returns delivery order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['id']).to eq(order.id)
      end

      it 'returns 404 for non-existent order' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/999999", headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id/confirm' do
      it 'confirms a delivery order' do
        allow_any_instance_of(order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id/cancel' do
      it 'cancels a delivery order' do
        allow_any_instance_of(order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/cancel",
            params: { reason: '测试取消' }, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id/complete' do
      it 'completes a delivery order' do
        allow_any_instance_of(order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id/assign' do
      it 'assigns delivery man' do
        allow_any_instance_of(order.class).to receive(:assign_delivery_man)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/assign",
            params: { delivery_man_id: 1 }, headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'returns 400 without delivery_man_id' do
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/assign",
            headers: auth_headers
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id/start' do
      it 'starts shipment' do
        allow_any_instance_of(order.class).to receive(:start_shipment)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/start",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/delivery_orders/:id/ship' do
      it 'ships the order' do
        allow_any_instance_of(order.class).to receive(:ship_shipment)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/delivery_orders/#{order.id}/ship",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---- Eat In Hall Orders ----

  describe 'Eat In Hall Orders' do
    let(:eat_in_hall_order) { create(:order, shop: shop, branch: branch, user: user) }

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/eat_in_hall_orders' do
      it 'returns eat in hall orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/eat_in_hall_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/eat_in_hall_orders/:id' do
      it 'returns order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/eat_in_hall_orders/#{eat_in_hall_order.id}",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['id']).to eq(eat_in_hall_order.id)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/eat_in_hall_orders/:id/confirm' do
      it 'confirms the order' do
        allow_any_instance_of(eat_in_hall_order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(eat_in_hall_order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/eat_in_hall_orders/#{eat_in_hall_order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/eat_in_hall_orders/:id/cancel' do
      it 'cancels the order' do
        allow_any_instance_of(eat_in_hall_order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(eat_in_hall_order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/eat_in_hall_orders/#{eat_in_hall_order.id}/cancel",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/eat_in_hall_orders/:id/complete' do
      it 'completes the order' do
        allow_any_instance_of(eat_in_hall_order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(eat_in_hall_order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/eat_in_hall_orders/#{eat_in_hall_order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---- Fastfood Orders ----

  describe 'Fastfood Orders' do
    let(:fastfood_order) { create(:order, shop: shop, branch: branch, user: user) }

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/fastfood_orders' do
      it 'returns fastfood orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/fastfood_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/fastfood_orders/:id' do
      it 'returns order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/fastfood_orders/#{fastfood_order.id}",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/fastfood_orders/:id/confirm' do
      it 'confirms the order' do
        allow_any_instance_of(fastfood_order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(fastfood_order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/fastfood_orders/#{fastfood_order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/fastfood_orders/:id/cancel' do
      it 'cancels the order' do
        allow_any_instance_of(fastfood_order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(fastfood_order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/fastfood_orders/#{fastfood_order.id}/cancel",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/fastfood_orders/:id/complete' do
      it 'completes the order' do
        allow_any_instance_of(fastfood_order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(fastfood_order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/fastfood_orders/#{fastfood_order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---- Groupon Orders ----

  describe 'Groupon Orders' do
    let(:groupon_order) { create(:order, shop: shop, branch: branch, user: user) }

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/groupon_orders' do
      it 'returns groupon orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/groupon_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/groupon_orders/:id' do
      it 'returns order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/groupon_orders/#{groupon_order.id}",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/groupon_orders/:id/confirm' do
      it 'confirms the order' do
        allow_any_instance_of(groupon_order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(groupon_order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/groupon_orders/#{groupon_order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/groupon_orders/:id/cancel' do
      it 'cancels the order' do
        allow_any_instance_of(groupon_order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(groupon_order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/groupon_orders/#{groupon_order.id}/cancel",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/groupon_orders/:id/complete' do
      it 'completes the order' do
        allow_any_instance_of(groupon_order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(groupon_order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/groupon_orders/#{groupon_order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---- Reservation Orders ----

  describe 'Reservation Orders' do
    let(:reservation_order) { create(:order, shop: shop, branch: branch, user: user) }

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/reservation_orders' do
      it 'returns reservation orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/reservation_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/reservation_orders/:id' do
      it 'returns order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/reservation_orders/#{reservation_order.id}",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/reservation_orders/:id/confirm' do
      it 'confirms the order' do
        allow_any_instance_of(reservation_order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(reservation_order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/reservation_orders/#{reservation_order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/reservation_orders/:id/cancel' do
      it 'cancels the order' do
        allow_any_instance_of(reservation_order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(reservation_order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/reservation_orders/#{reservation_order.id}/cancel",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/reservation_orders/:id/complete' do
      it 'completes the order' do
        allow_any_instance_of(reservation_order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(reservation_order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/reservation_orders/#{reservation_order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---- Recharge Orders ----

  describe 'Recharge Orders' do
    let(:recharge_order) { create(:order, shop: shop, branch: branch, user: user) }

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/recharge_orders' do
      it 'returns recharge orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/recharge_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/recharge_orders/:id' do
      it 'returns order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/recharge_orders/#{recharge_order.id}",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/recharge_orders/:id/confirm' do
      it 'confirms the order' do
        allow_any_instance_of(recharge_order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(recharge_order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/recharge_orders/#{recharge_order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/recharge_orders/:id/cancel' do
      it 'cancels the order' do
        allow_any_instance_of(recharge_order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(recharge_order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/recharge_orders/#{recharge_order.id}/cancel",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/recharge_orders/:id/complete' do
      it 'completes the order' do
        allow_any_instance_of(recharge_order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(recharge_order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/recharge_orders/#{recharge_order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ---- Payment Orders ----

  describe 'Payment Orders' do
    let(:payment_order) { create(:order, shop: shop, branch: branch, user: user) }

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/payment_orders' do
      it 'returns payment orders list' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/payment_orders", headers: auth_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('data')
      end
    end

    describe 'GET /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/payment_orders/:id' do
      it 'returns order details' do
        get "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/payment_orders/#{payment_order.id}",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/payment_orders/:id/confirm' do
      it 'confirms the order' do
        allow_any_instance_of(payment_order.class).to receive(:may_confirm?).and_return(true)
        allow_any_instance_of(payment_order.class).to receive(:confirm!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/payment_orders/#{payment_order.id}/confirm",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/payment_orders/:id/cancel' do
      it 'cancels the order' do
        allow_any_instance_of(payment_order.class).to receive(:may_cancel?).and_return(true)
        allow_any_instance_of(payment_order.class).to receive(:cancel!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/payment_orders/#{payment_order.id}/cancel",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'PUT /api/v1/backend/shops/:shop_slug/branches/:branch_id/order/payment_orders/:id/complete' do
      it 'completes the order' do
        allow_any_instance_of(payment_order.class).to receive(:may_complete?).and_return(true)
        allow_any_instance_of(payment_order.class).to receive(:complete!)
        put "/api/v1/backend/shops/#{shop.slug}/branches/#{branch.id}/order/payment_orders/#{payment_order.id}/complete",
            headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
