module Ddt
  module OrderService
    module Cart
      module Concern
        module SessionStore
          extend ActiveSupport::Concern
          included do
            def self.init_from_session(branch, user, session, options={})
              session ||= {}
              self.new({
                branch: branch,
                user: user,
                track_from: options[:track_from]
              }.merge(cart_options_from_session(session)))
            end

            def self.cart_options_from_session(session)
              line_itemables = OrderService::LineItemable.init_list(session.fetch(:line_itemables, []))
              form_contentables = OrderService::FormContentable.init_list(session.fetch(:form_contentables, []))
              coupon = Coupon.find_by(id: session[:coupon_id]) if session[:coupon_id].present?
              options = {
                line_itemables: line_itemables,
                form_contentables: form_contentables,
                coupon: coupon,
                note: session[:note],
              }
            end
          end

          def to_session
            session = { note: note, coupon_id: coupon_id }
            session[:line_itemables] = self.line_items.to_line_itemable_options
            session[:form_contentables] = self.form_contents.to_form_contentable_options
            session
          end
        end
      end
    end
  end
end
