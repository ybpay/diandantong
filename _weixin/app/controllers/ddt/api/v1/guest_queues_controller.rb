module Ddt
  module Api
    module V1
      module Weixin
        class GuestQueuesController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            queues = @branch.guest_queues.ransack(params[:q]).result
            render_paginated(queues)
          end

          def create
            queue = @branch.guest_queues.build(queue_params.merge(
              user: current_user,
              queued_at: Time.current
            ))
            if queue.save
              render_resource_created(queue)
            else
              render_errors(queue.errors)
            end
          end

          def show
            queue = @branch.guest_queues.find(params[:id])
            render_resource(queue)
          end

          private

          def set_branch
            @branch = Ddt::Branch.find(params[:branch_id])
          end

          def queue_params
            params.require(:guest_queue).permit(:person_count, :phone, :note)
          end
        end
      end
    end
  end
end
