module Ddt
  module WalletActions
    class Base
      include ActiveModel::Validations
      attr_accessor :amount, :cash_amount, :note, :wallet, :operator, :branch, :branch_id, :order

      validates_presence_of :amount
      validates_numericality_of :amount, greater_than: 0, less_than: ::Ddt::Base::MAX_DECIMAL
      delegate :amount_name, to: :wallet

      def initialize(hash = {})
        hash.each do |key, value|
          self.send(:"#{key}=", value)
        end
        self.amount = self.amount.to_f
        self.cash_amount = self.cash_amount.to_f
      end

      def to_key
        nil
      end

      def current_branch
        if branch_id.present?
          Ddt::Branch.find(branch_id)
        elsif branch.present?
          branch
        elsif operator.present? && operator.is_boss?
          #管理员时返回空，其他均返回错误，必须指定branch
          nil
        else
          raise
        end
      end
    end
  end
end
