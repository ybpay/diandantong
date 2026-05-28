module Ddt
  module Api
    module V1
      module Agentsys
        class MerchantsController < BaseController
          before_action :set_shop, only: [:show, :update, :renew, :suspend, :activate, :reset_password]

          def index
            shops = current_agent.shops.includes(:accounts)
            shops = filter_shops(shops)
            shops = shops.ransack(params[:q]).result(distinct: true) if params[:q].present?
            items = paginate_collection(shops.order(created_at: :desc))
            render json: {
              merchants: items.map { |s| merchant_json(s) },
              total: shops.count
            }
          end

          def show
            authorize! @shop, with: Ddt::Agentsys::ShopPolicy
            render json: { data: merchant_detail_json(@shop) }
          end

          def create
            authorize! Ddt::Shop, to: :create?, with: Ddt::Agentsys::ShopPolicy
            unless current_agent.can_create_account?
              render json: { errors: [{ status: 403, title: "不允许创建账户", code: "FORBIDDEN" }] }, status: :forbidden
              return
            end

            account = Account.new(account_params.slice(:phone, :name, :password, :password_confirmation, :login_id, :email))
            account.captcha_valid = true
            permit_params = account_params.dup
            permit_params[:shop_attributes] = { agent_no: current_agent.agent_no }

            if account.init(permit_params, track_from: :FromAgent)
              account.roles = account.shop.roles.boss_role
              render json: { data: { id: account.shop.id } }, status: :created
            else
              render json: { errors: [{ status: 422, title: "创建失败", detail: account.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def update
            authorize! @shop, with: Ddt::Agentsys::ShopPolicy
            if @shop.update(shop_params)
              render json: { data: { message: "修改成功" } }
            else
              render json: { errors: [{ status: 422, title: "修改失败", detail: @shop.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def renew
            authorize! @shop, to: :renew?, with: Ddt::Agentsys::ShopPolicy
            days = params[:days].to_i
            shop = @shop
            recharge_type = params[:recharge_type]&.to_sym || shop.shop_type.to_sym

            if recharge_type == :base && !current_agent.is_hardware_level?
              render json: { errors: [{ status: 403, title: "不允许的续费类型，仅硬件渠道商可为base类型充值", code: "FORBIDDEN" }] }, status: :forbidden
              return
            end

            record = shop.shop_recharge_records.build(
              increment_days: days,
              recharge_type: recharge_type,
              branch_num: shop.max_branches_limit,
              beginning_time: [Time.current, shop.expiration_time].max,
              agent: current_agent
            )
            record.ending_time = record.beginning_time + days.days

            max_agent_to = current_agent.agent_rels.maximum(:agent_to)
            if record.increment_days > 0 && shop.expiration_time > max_agent_to
              render json: { errors: [{ status: 403, title: "您的代理期限到#{max_agent_to.to_date}截止，不能为超出代理期限的客户充值", code: "AGENT_EXPIRATION_EXCEEDED" }] }, status: :forbidden
              return
            end

            record.original_price = Ddt::FeatureModuleGroup.price_of_charge_version(shop, record.ending_time, record.branch_num, record.recharge_type)
            record.price = (record.original_price * current_agent.discount).round(2)

            if record.save
              render json: { data: { message: "续费成功", expires_at: record.ending_time.to_s } }
            else
              render json: { errors: [{ status: 422, title: "续费失败", detail: record.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def suspend
            authorize! @shop, to: :suspend?, with: Ddt::Agentsys::ShopPolicy
            @shop.update_column(:is_give_up, true)
            render json: { data: { message: "已停用" } }
          end

          def activate
            authorize! @shop, to: :activate?, with: Ddt::Agentsys::ShopPolicy
            @shop.update_column(:is_give_up, false)
            render json: { data: { message: "已启用" } }
          end

          def reset_password
            authorize! @shop, to: :reset_password?, with: Ddt::Agentsys::ShopPolicy
            account = @shop.accounts.first
            if account
              new_password = SecureRandom.hex(8)
              account.update(password: new_password, password_confirmation: new_password)
              render json: { data: { message: "密码已重置", new_password: new_password } }
            else
              render json: { errors: [{ status: 404, title: "账户不存在", code: "NOT_FOUND" }] }, status: :not_found
            end
          end

          private

          def set_shop
            @shop = current_agent.shops.find(params[:id])
          end

          def filter_shops(shops)
            result = shops
            if params[:keyword].present?
              kw = "%#{params[:keyword]}%"
              result = result.joins(:accounts).where(
                "ddt_shops.name ILIKE :kw OR ddt_accounts.name ILIKE :kw OR ddt_shops.phone ILIKE :kw",
                kw: kw
              )
            end
            case params[:status]
            when "active"
              result = result.where(is_give_up: false).where("expiration_time > ?", Time.current)
            when "expired"
              result = result.where("expiration_time <= ?", Time.current)
            when "suspended"
              result = result.where(is_give_up: true)
            end
            result
          end

          def merchant_json(shop)
            account = shop.accounts.first
            {
              id: shop.id,
              name: shop.name,
              contact_name: account&.name.to_s,
              phone: shop.phone.to_s,
              plan_name: shop.shop_type.to_s,
              status: merchant_status(shop),
              status_label: merchant_status_label(shop),
              created_at: shop.created_at.to_s,
              expires_at: shop.expiration_time&.to_s
            }
          end

          def merchant_detail_json(shop)
            merchant_json(shop).merge(
              email: shop.accounts.first&.email.to_s,
              address: shop.address.to_s,
              activated_at: shop.created_at.to_s,
              branch_count: shop.branches.count,
              worker_count: shop.users.count,
              monthly_orders: shop.orders.where(created_at: 30.days.ago..).count,
              monthly_revenue: format("%.2f", shop.orders.where(created_at: 30.days.ago..).sum(:total_amount).to_f)
            )
          end

          def merchant_status(shop)
            return "suspended" if shop.is_give_up?
            return "expired" if shop.expiration_time && shop.expiration_time < Time.current
            "active"
          end

          def merchant_status_label(shop)
            case merchant_status(shop)
            when "suspended" then "已停用"
            when "expired" then "已过期"
            else "活跃"
            end
          end

          def shop_params
            params.require(:merchant).permit(:name, :is_ban)
          end

          def account_params
            params.require(:merchant).permit(:phone, :name, :password, :password_confirmation, :login_id, :email, :address)
          end
        end
      end
    end
  end
end
