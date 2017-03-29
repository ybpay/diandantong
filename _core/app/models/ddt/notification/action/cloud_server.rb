module Ddt
  class Notification
    module Action
      class CloudServer < Ddt::NotificationAction
        def perform
          messages = Ddt::Notification::View::CloudServer.new(event, target).render

          if messages.is_a? Array
            messages.each { |msg| notify_cloud_server(msg)}
          else
            notify_cloud_server(messages)
          end

        end

        private

        def notify_cloud_server(message)
          # expect in format (e.g.)
          # {
          #     shop_id: shop.id,
          #     branch_id: branch.id,
          #     entity_type: entity_type,
          #     entity_id: entity_id
          # }

          cs_branch_bindings = Ddt::CsBranchBinding.where(branch_id: message[:branch_id]).first
          if cs_branch_bindings.present?
            Ddt::CloudServer.post(:sync, :notify,
              path_params: {
                  shop_id: message[:shop_id],
                  branch_id: message[:branch_id]
              },
              query_params: {
                  entity_type: message[:entity_type],
                  entity_id: message[:entity_id]
              }
            )
          end
        end

      end
    end
  end
end
