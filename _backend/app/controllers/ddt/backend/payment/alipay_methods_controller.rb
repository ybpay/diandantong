module Ddt
  module Backend
    module Payment
      class AlipayMethodsController < PaymentMethodsController
        layout 'ddt/layouts/backend/alipay_method'
        check_permission :shop, :payment_method, { [:gen_rsa] => :show}, only: [:gen_rsa]

        def show
          @payment_method.preferred_contract =
              @payment_method.preferred_contract.split('|').map{ |it|
                found = Ddt::AlipayMethod::CONTRACT_COLLECTIONS.find {|that| that[1] == it }
                found.present? ? found[0] : nil
              }.join('|')
        end

        def gen_rsa
          pri_pub = OpenSSL::PKey::RSA.generate(1024)
          @private_key_pem = pri_pub.to_pem
          @public_key_pem = pri_pub.public_key.to_pem.lines[1...-1].map(&:strip).join
          render :json => {
              private_key: @private_key_pem,
              public_key: @public_key_pem
          }
        end

        def edit
        end

        def update
          params['alipay_method']['preferred_contract'] = params['alipay_method']['preferred_contract'].select{|it|it.present?}.join('|')
          if @payment_method.update(payment_method_params)
            redirect_to [:backend, @current_shop, controller_name], notice: "#{t("activerecord.models.ddt/#{controller_name.singularize}")} 更新成功."
          else
            render :edit
          end
        end
      end
    end
  end
end