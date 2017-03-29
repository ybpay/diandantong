module Ddt
  module RecordStateChange
    extend ActiveSupport::Concern
    included do
      has_many :state_changes, as: :stateful
    end

    module ClassMethods
      def record_state_change_for(*state_names)
        state_names.each do |state_name|
          self.class_eval do
            after_save "record_state_change_for_#{state_name}".to_sym
            define_method "record_state_change_for_#{state_name}".to_sym do
              previous_state = self.send("#{state_name}_was")
              next_state = self.send("#{state_name}")
              if self.send("#{state_name}_changed?") && previous_state.present? && next_state.present? && previous_state != next_state
                self.state_changes.create!(
                  state_name:     state_name,
                  previous_state: previous_state,
                  next_state:     next_state,
                  operator:       Ddt::Account.current || Ddt::BaseUser.current)
              end
            end
          end
        end
      end
    end

    def state_changed(state_name)
      previous_state = self.send("#{state_name}_was")
      next_state     = self.send(state_name)
      unless previous_state == next_state
        self.state_changes.create(
          state_name:     state_name,
          previous_state: previous_state,
          next_state:     next_state,
          operator:       Ddt::Account.current || Ddt::BaseUser.current
        )
      end
    end

  end
end