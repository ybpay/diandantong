# encoding:utf-8
module Ddt
  class GuestQueue < Ddt::Base
    include BelongsToBranch
    include TrackFrom
    include Scanable
    include ActionView::Helpers::DateHelper
    include AASM

    belongs_to :base_user, class_name: 'Ddt::BaseUser'
    alias_method :user, :base_user
    belongs_to :queue_setting, class_name: 'Ddt::QueueSetting'
    validates :queue_setting, presence: true
    validates :guest_num, presence: true, numericality: {:greater_than_or_equal_to => 1, :less_than => 200}
    scope :without            ,->(guest_queue) { where("id != ?", guest_queue.id)}
    scope :within_24_hours, -> {where('created_at > DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 DAY)')}
    scope :of_current_queue   ,->{ with_queueing_state}
    scope :in_advance_of_guest, ->(guest_no) { where('guest_no < ?', guest_no)}
    validate :should_queue_at_valid_time, on: :create
    default_scope -> {order(created_at: :asc)}
    validate :phone
    validate :phone_uniq_with_queueing, on: :create
    set_from :queue_setting
    attr_accessor :terminal_id

    after_create do
      justify_guest_no
      attrs = {
          :last_push_queue_item_at => DateTime.now,
          :last_push_queue_item_no => (self.guest_no.match(/(\d+)/)[0]).to_i
      }
      attrs[:current_queue_head] = self unless self.queue_setting.current_queue_head.present?
      self.queue_setting.update!(attrs)
      Notification::Event::Queue::Enqueueing.delay.create_and_send_notification(guest_queue_id: self.id)
    end

    acts_as_type :workflow_state, [:queueing, :accepted, :canceled, :past], %W(排队中 已入号 已取消 已过号)
    acts_as_type :track_from, [WECHAT, WEBPOS, APP, UNKNOW], [WECHAT_LABEL, WEBPOS_LABEL, APP_LABEL, UNKNOW_LABEL]

    aasm column: :workflow_state, initial: :queueing do
      state :queueing, :accepted, :canceled, :past

      event :accept do
        transitions from: :queueing, to: :accepted
        transitions from: :past, to: :accepted
      end
      event :cancel do
        transitions from: :queueing, to: :canceled
      end
      event :pass do
        transitions from: :queueing, to: :past
      end
      event :requeue do
        transitions from: :accepted, to: :queueing
        transitions from: :past, to: :queueing
        transitions from: :canceled, to: :queueing
      end
    end

    # Backward-compatible scope for workflow gem's with_<state>_state pattern
    scope :with_queueing_state, -> { where(workflow_state: :queueing) }

    def front_guest_no
      return '' if self.guest_no.nil?
      no = self.guest_no.match(/(\d+)/)[0]
      no_i = no.to_i
      pre_no = "%03d" % (no_i-1)
      self.guest_no.gsub(/\d+/, pre_no)
    end

    def pass
      Notification::Event::Queue::Past.create_and_send_notification(guest_queue_id: self.id, terminal_id: terminal_id)
      refresh_queue_head
    end

    def requeue
      refresh_queue_head(notify: false)
    end

    def cancel
      if self.queue_setting.current_queue_head == self
        refresh_queue_head
      else
        self.queue_setting.guest_queues.with_queueing_state.limit(self.queue_setting.notify_number_in_advance + 2).where("created_at > ?", self.created_at).each do |guest_queue|
          Notification::Event::Queue::Change.create_and_send_notification(guest_queue_id: guest_queue.id)
        end
      end
      user.clear_pre_order_itemables(self.branch) if user.has_pre_order?(self.branch)
      Notification::Event::Queue::Cancel.create_and_send_notification(guest_queue_id: self.id, terminal_id: terminal_id)
    end

    def accept
      Notification::Event::Queue::Accepted.create_and_send_notification(guest_queue_id: self.id, terminal_id: terminal_id)
      refresh_queue_head
    end

    def notify
      self.update_attribute(:is_notified, true)
      Notification::Event::Queue::Notify.create_and_send_notification(guest_queue_id: self.id)
    end

    def reprint
      Notification::Event::Queue::Reprint.create_and_send_notification(guest_queue_id: self.id)
    end

    def print_pre_order
      Notification::Event::Queue::PrintPreOrder.create_and_send_notification(guest_queue_id: self.id)
    end

    def guest_num_at_front
      queue_setting.guest_queues.with_queueing_state.where("created_at < ?", self.created_at).count
    end

    def weixin_show_path
      "weixin/shops/#{self.shop_id}/queue?_ng_path=/branches/#{self.branch_id}/guest_queue"
    end

    concerning :Scanable do
      included do
        has_one :qr_code_scene, ->{ of_builtin }, class_name: 'Ddt::BaseQrCodeScene', as: :owner, dependent: :destroy
        delegate :scan_times, to: :qr_code_scene, allow_nil: true
      end

      def qr_code_image
        self.qr_code_scene.try(:url).try(:to_s)
      end

      def create_qr_code?
        is_FromWebpos? || is_FromApp?
      end

      def create_qr_code
        if qr_code_type == :snap_wechat_qr_code
          # 认证的服务号用临时微信二维码
          self.qr_code_scene = WechatQrCodeScene.of_builtin.create(owner: self, name: "#{self.class.name.demodulize} #{self.name}", scene_id: self.id, wechat_scene_type: :snap, snap_scene_type: :queue) if create_qr_code? && self.qr_code_scene.nil?
        else
          self.qr_code_scene = QrCodeScene.of_builtin.create(owner: self, name: "#{self.class.name.demodulize} #{self.name}") if create_qr_code? && self.qr_code_scene.nil?
        end
      end

      def qr_code_type
        wechat_account = self.shop.primary_wechat_account
        if wechat_account.present?
          if wechat_account.account_service? && wechat_account.account_verified?
            :snap_wechat_qr_code
          else
            :base_qr_code
          end
        end
      end

      def scaners
        qr_code_scene.try(:scaners) || []
      end
    end

    def name
      self.try(:guest_no)
    end

    def weixin_bind_path
      "/weixin/shops/#{self.shop_id}/queue?_ng_path=/branches/#{self.branch_id}/guest_queue_qr_code/#{self.qr_code_scene.id}"
    end

    url_method_for :weixin_bind, :weixin_show

    def weixin_view_url
      if is_FromWebpos? || is_FromApp?
        weixin_bind_url
      else
        weixin_show_url
      end
    end

    def bind_user(user)
      if self.user.blank?
        last_guest_queue = user.guest_queues.where(branch: self.branch).with_queueing_state.first
        if last_guest_queue.present?
          if last_guest_queue.track_from == "FromWechat"
            self.errors[:base] << "您已经在微信端取号,不可以在绑定其他号码"
          else
            self.errors[:base] << "您已经绑定其他排号二维码"
          end
          false
        else
          self.update(base_user: user)
          Notification::Event::Queue::Binded.create_and_send_notification(guest_queue_id: self.id)
          true
        end
      else
        self.errors[:base] << "已经被绑定, 不能再次绑定"
        false
      end
    end

    def bind_state_label
      return "不可绑定" unless (is_FromWebpos? || is_FromApp?)
      self.user.present? ? "已绑定微信" : "未绑定微信"
    end

    def is_binded
      return false unless (is_FromWebpos? || is_FromApp?)
      self.user.present?
    end

    def waited_time_str
      distance_of_time_in_words(Time.now - self.created_at)
    end

    def detail_in_bill(print_spec='58')
      printer = Printer::Normal.new(print_spec: print_spec)
      BillTemplate::Queue::EnqueueingBill.new(guest_queue: self, printer: printer).render
    end

    def detail_in_html
      printer = Printer::Normal.new(print_spec: '58')
      BillTemplate::Queue::EnqueueingBill.new(guest_queue: self, printer: printer).render.gsub(" ","&nbsp;").gsub("\n", "<br/>")
    end

    def pre_order_detail_in_bill(print_spec = '58')
      printer = Printer::Normal.new(print_spec: print_spec)
      BillTemplate::Queue::PreOrderBill.new(guest_queue: self, printer: printer).render
    end

    def pre_order_detail_in_html
      pre_order_detail_in_bill('58').gsub(" ","&nbsp;").gsub("\n", "<br/>")
    end

    def pre_order_itemables
      self.user.pre_order_itemables(self.branch) if self.user.present?
    end

    private
    def refresh_queue_head(options = {})
      notify = options[:notify] ? options[:notify] : true
      new_head_guest = self.queue_setting.guest_queues.with_queueing_state.without(self).first rescue nil
      self.queue_setting.attributes = {:current_queue_head => new_head_guest}
      self.queue_setting.save!
      if notify
        self.queue_setting.guest_queues.with_queueing_state.limit(self.queue_setting.notify_number_in_advance + 1).each do |guest_queue|
          Notification::Event::Queue::Change.create_and_send_notification(guest_queue_id: guest_queue.id,front_guest_number: guest_queue.guest_num_at_front - 1) unless guest_queue.id == self.id
        end
      end
    end

    def should_queue_at_valid_time
      self.errors.add(:base, I18n.t("not in queue service time")) if not self.queue_setting.is_in_service_time(DateTime.now)
    end

    def justify_guest_no
      guest_no_resource = self.queue_setting.competition_resources.where(name: :guest_queue_guest_no).lock(true).first
      if guest_no_resource.value.present? && guest_no_resource.updated_at.to_date == Date.today
        guest_no_str = guest_no_resource.value.next
      else
        guest_no_str = "#{self.queue_setting.queue_no_prefix}#{ '%03d' % 1}"
      end
      guest_no_str = loop do
        if self.queue_setting.guest_queues.with_queueing_state.exists?(guest_no: guest_no_str)
          guest_no_str = guest_no_str.next
        else
          break guest_no_str
        end
      end
      self.update_column(:guest_no, guest_no_str)
      guest_no_resource.update(value: guest_no_str)
    end

    def phone_uniq_with_queueing
      # 来自 App 的，允许不填手机号
      return if self.phone.blank?
      if self.branch.guest_queues.with_queueing_state.where(phone: self.phone).present?
        self.errors[:phone] << "每个手机号只能排一个号码"
      end
    end


  end
end
