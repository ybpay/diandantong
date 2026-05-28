module Ddt
  class QueueSetting < Ddt::Base
    include BelongsToBranch

    belongs_to :current_queue_head, class_name: 'Ddt::GuestQueue'
    has_many :guest_queues, dependent: :destroy, class_name: 'Ddt::GuestQueue'
    has_many :queueing_guests, -> {with_queueing_state}, dependent: :destroy, class_name: 'Ddt::GuestQueue'
    has_many :competition_resources, class_name: 'Ddt::CompetitionResource', as: :owner, dependent: :destroy
    delegate :guest_no, to: :current_queue_head, allow_nil: true
    default_scope -> {order('guest_num_le ASC')}
    ### callbacks
    before_save :assign_qr_code

    ### attachable
    include Ddt::Attachable
    attachable_one :queue_qr_code, variants: { medium: [400, 400], thumb: [100, 100] }

    ### validations
    validates :name, :start_at, :end_at, presence: true
    validates :guest_num_le, presence: true, numericality: {:greater_than_or_equal_to => 1 }
    validates :notify_number_in_advance, presence: true, numericality: {:greater_than_or_equal_to => 1 }
    validate :start_at_not_equal_to_end_at
    scope :of_enabled, -> {where(:enabled => true)}

    after_create :create_competition_resource

    def self.find_available_queue(guest_num, branch)
      branch.queue_settings.select{|queue_setting| guest_num.to_i <= queue_setting.guest_num_le }.first
    end

    def enabled_name
      self.enabled? ? I18n.t("queue_setting.enabled.enabled") : I18n.t("queue_setting.enabled.disabled")
    end

    def is_in_service_time(date_time)
      time = TimeUtil.time_since_beginning_of_day(date_time.in_time_zone(shop.shop_time_zone))
      start_at_time = TimeUtil.time_since_beginning_of_day(start_at)
      end_at_time = TimeUtil.time_since_beginning_of_day(end_at)
      if start_at_time > end_at_time
        (time >= start_at_time) || (time <= end_at_time)
      else
        (time >= start_at_time) && (time <= end_at_time)
      end
    end

    def new_guest_queue(params={})
      guest_queue = self.guest_queues.create(params)
      if guest_queue.errors.blank?
        guest_queue.reload 
      else
        guest_queue
      end
    end

    def guest_number_min
      pre_queue = self.branch.queue_settings.where("guest_num_le < ?", self.guest_num_le).reorder(guest_num_le: :desc).first
      min_number = pre_queue.present? ? pre_queue.guest_num_le + 1 : 1
    end

    def guest_number_max
      next_queue = self.branch.queue_settings.where("guest_num_le > ?", self.guest_num_le).reorder(guest_num_le: :asc).first
      max_number = next_queue.present? ? self.guest_num_le : self.guest_num_le + 100
    end

    def guest_number_interval_str
      min = guest_number_min
      max = guest_number_max
      if max > self.guest_num_le
        "#{min}+人"
      else
        "#{min}-#{max}人"
      end
    end

    def queueing_guests_num
      self.queueing_guests.count
    end

    private
    def assign_qr_code
      if self.queue_url_changed? && self.queue_url.present?
        tmp_path = Rails.root.join('tmp', "qrcode_queue_setting_#{DateTime.now.to_i}.png")
        png = QrcodeTool.generate_qrcode_image(queue_url, width=250).save(tmp_path)
        File.open(tmp_path) do |file|
          self.queue_qr_code = file
        end
        File.delete(tmp_path)
      end
    end

    def start_at_not_equal_to_end_at
      self.errors.add(:end_at, I18n.t("end_at can not be equal to start_at")) if start_at == end_at
    end

    def create_competition_resource
      self.competition_resources.create!(name: :guest_queue_guest_no)
    end
  end
end
