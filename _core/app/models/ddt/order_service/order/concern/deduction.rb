module Ddt
  module OrderService
    module Order
      module Concern
        module Deduction
          extend ActiveSupport::Concern
          included do
            has_one :card_deduction
            has_many :credits_deductions
          end

          def credits_deduction
            self.credits_deductions.where(state: [:pending, :completed]).first
          end

          def add_card_deduction(amount)
            if can_change_total? && amount && amount > 0
              if current_vip.present? && current_vip.card_wallet.amount > amount
                transaction do
                  card_deduction = self.create_card_deduction(amount: amount)
                  adjust(reason: :card_deduction, source: card_deduction)
                  current_vip.card_wallet.deduct(card_deduction)
                  update_total_and_save
                end
                true
              else
                self.errors[:base] << "余额不足"
                false
              end
            end
          end

          def add_credits_deduction(amount)
            if can_change_total? && amount && amount > 0
              amount = [amount, self.total * self.shop.credits_setting.exchange_radio].min
              if current_vip.present? && current_vip.credits_wallet.amount >= amount
                transaction do
                  credits_deduction = self.credits_deductions.create(amount: amount, wallet: current_vip.credits_wallet)
                  adjust(reason: :credits_deduction, source: credits_deduction, need_apportion: true)
                  current_vip.credits_wallet.deduct(credits_deduction)
                  update_total_and_save
                end
                true
              else
                self.errors[:base] << "积分不足"
                false
              end
            end
          end

          def cancel_credits_deduction
            if can_change_total? && self.credits_deduction.present?
              self.credits_deduction.try(:cancel)
              self.adjustments.credits_deduction.destroy_all
            end
          end
        end
      end
    end
  end
end