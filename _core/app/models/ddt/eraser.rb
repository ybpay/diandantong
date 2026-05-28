
module Ddt
  class Eraser
    class << self

      ERASE_MARK    = {delete_by_admin: true,  discarded_at: Time.now}
      ROLLBACK_MARK = {delete_by_admin: false, discarded_at: nil}

      def perform_order_data(branch_id, from, to)
        ActiveRecord::Base.transaction do
          sql1 = "select id from ddt_orders where branch_id=#{branch_id} and paid_at between '#{from}' and '#{to}'; "
          sql2 = "select id from ddt_orders where branch_id=#{branch_id} and placed_at between '#{from}' and '#{to}';"
          paid_order_ids = ActiveRecord::Base.connection.execute(sql1).to_a.flatten
          placed_order_ids = ActiveRecord::Base.connection.execute(sql2).to_a.flatten
          order_ids = (paid_order_ids + placed_order_ids).uniq
          OrderService::Api::Mock::Model::OrderChangeLog.where(order_id: order_ids).update_all(ERASE_MARK)
          OrderService::Api::Mock::Model::LineItem.where(order_id: order_ids).update_all(ERASE_MARK)
          OrderService::Api::Mock::Model::PayItem.where(order_id: order_ids, discarded_at: nil).update_all(ERASE_MARK)
          OrderService::Api::Mock::Model::Order.where(id: order_ids).update_all(ERASE_MARK)
        end
      end

      def rollback_order_data(branch_id, from, to)
        ActiveRecord::Base.transaction do
          sql1 = "select id from ddt_orders where branch_id=#{branch_id} and paid_at between '#{from}' and '#{to}' and delete_by_admin=1; "
          sql2 = "select id from ddt_orders where branch_id=#{branch_id} and placed_at between '#{from}' and '#{to}' and delete_by_admin=1; "
          paid_order_ids = ActiveRecord::Base.connection.execute(sql1).to_a.flatten
          placed_order_ids = ActiveRecord::Base.connection.execute(sql2).to_a.flatten
          order_ids = (paid_order_ids + placed_order_ids).uniq
          OrderService::Api::Mock::Model::OrderChangeLog.discarded.where(delete_by_admin: true, order_id: order_ids).update_all(ROLLBACK_MARK)
          OrderService::Api::Mock::Model::LineItem.discarded.where(delete_by_admin: true, order_id: order_ids).update_all(ROLLBACK_MARK)
          OrderService::Api::Mock::Model::PayItem.discarded.where(delete_by_admin: true, order_id: order_ids).update_all(ROLLBACK_MARK)
          OrderService::Api::Mock::Model::Order.discarded.where(delete_by_admin: true, id: order_ids).update_all(ROLLBACK_MARK)
        end
      end

      def perform_shift_data(branch_id, from, to)
        ActiveRecord::Base.transaction do
          shift_ids = Ddt::Shift.where("branch_id = #{branch_id} and created_at between '#{from}' and '#{to}' ").pluck(:id)
          Ddt::ShiftItem.where(shift_id: shift_ids).update_all(ERASE_MARK)
          Ddt::Shift.where(id: shift_ids).update_all(ERASE_MARK)
        end
      end

      def rollback_shift_data(branch_id, from, to)
        ActiveRecord::Base.transaction do
          shift_ids = Ddt::Shift.discarded.where("branch_id = #{branch_id} and created_at between '#{from}' and '#{to}' and delete_by_admin=1").pluck(:id)
          Ddt::ShiftItem.discarded.where(delete_by_admin: true, shift_id: shift_ids).update_all(ROLLBACK_MARK)
          Ddt::Shift.discarded.where(delete_by_admin: true, id: shift_ids).update_all(ROLLBACK_MARK)
        end
      end



    end
  end
end
