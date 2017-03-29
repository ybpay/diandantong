module Ddt
  module Webpos
    module WebposAccounts
      class SessionsController < Devise::SessionsController
        include DeviseUrlHelper
        skip_before_action :verify_authenticity_token
        respond_to :json
        def new
          redirect_to "/webpos#/accounts/sign_in"
        end

        def create
          resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
          sign_in(resource_name, resource)
          if current_account.shop.expired?
            sign_out
            render json: { errors: '对不起，该平台因合约到期已暂停服务' }, status: :bad_request
          else
            table_color = current_account.shop.table_color
            permissions = current_account.all_permissions
            render :status => 200,
                   :json => { :success => true,
                              :info => "登录成功",
                              :account => {
                                id:    current_account.id,
                                name:  current_account.name,
                                email: current_account.email,
                                phone: current_account.phone,
                                roles: current_account.roles.map(&:name),
                                shop: {
                                  id:       current_account.shop.id,
                                  name:     current_account.shop.name,
                                  slug:     current_account.shop.slug,
                                  currency: current_account.shop.currency,
                                  card_key: current_account.shop.card_key,
                                  abstract_branch_id: current_account.shop.abstract_branch.id,
                                  use_shop_name_for_queue: current_account.shop.use_shop_name_for_queue,
                                  wechat_account_name: current_account.shop.primary_wechat_account.try(:account_name),
                                  wechat_account_gonghao_open_id: current_account.shop.primary_wechat_account.try(:gonghao_open_id),
                                  table_color: {
                                    idle_color: table_color.idle_color,
                                    opened_color: table_color.opened_color,
                                    ordered_color: table_color.ordered_color,
                                    check_outing_color: table_color.check_outing_color,
                                    paid_color: table_color.paid_color,
                                    active_color: table_color.active_color
                                  }
                                },
                                permissions: {
                                  branch: permissions[:branch],
                                  shop: permissions[:shop]
                                },
                                branches: current_account.managed_branches.valid_now.as_json(only: [:id, :name])
                              },
                              :csrfToken => form_authenticity_token
                            }
          end
        end

        def destroy
          warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
          sign_out
          render :status => 200,
                 :json => { :success => true,
                            :info => "退出成功",
                            :csrfToken => form_authenticity_token
                          }
        end

        def failure
          render :status => :bad_request,
                 :json => { :success => false,
                            :info => "登录失败，请仔细检查账号或密码"
                          }
        end
      end
    end
  end
end
