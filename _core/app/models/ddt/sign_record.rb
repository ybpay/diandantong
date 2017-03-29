module Ddt
  class SignRecord < Base
    include BelongsToShop
    replicated_model


    belongs_to :base_user, class_name: 'Ddt::BaseUser', counter_cache: true, touch: true

    set_from :base_user

    scope :today,     ->{ by_date(Time.now) }
    scope :yesterday, ->{ by_date(1.day.ago) }
    scope :by_date, ->(date){ where("ddt_sign_records.created_at BETWEEN '#{date.beginning_of_day}' AND '#{date.end_of_day}'")}

    after_create :update_continuous_sign_count
    after_create :create_promotion_event
    default_scope ->{ order(created_at: :desc)}

    private
    def update_continuous_sign_count
      if self.base_user.sign_records.yesterday.present?
        self.base_user.increment!(:continuous_sign_count)
      else
        self.base_user.update_column(:continuous_sign_count, 1)
      end
    end

    def create_promotion_event
      Ddt::Promotion::Events::UserSignIn.create!(user: self.base_user)
    end
  end
end