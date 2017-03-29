#encoding: utf-8
require 'ddt_core'

class Ddt::ErrorNotFromWeixin < StandardError;
end
class Ddt::ErrorNotFoundException < StandardError;
end
class Ddt::NoOpenIdException < StandardError;
end
class Ddt::NoBaseUserInfoException < StandardError;
end
class Ddt::BaseWeixinController < Ddt::BaseController
  helper Ddt::Core::Engine.helpers
  helper Ddt::Backend::Engine.helpers
  include Ddt::CheckFeature

  before_filter :set_current_shop
  #before_filter :check_shop_enabled
  before_filter :set_current_branch
  before_filter :validate_user_info
  before_filter :record_shake_around
  before_filter :check_current_shop
  before_filter :check_shop_ban
  before_action :set_track_from
  before_action :check_branch_online
  helper_method :has_feature?

  def set_current_branch
    key = params[:branch_id] || (controller_name == 'branches' ? params[:id] : nil)
    if key.present?
      @current_branch = @current_shop.branches_include_abstract.find_by(id: key)
      @branch = @current_branch
      if @branch.blank?
        respond_to do |format|
          format.json { render json: {errors: '门店已经不存在或被删除，无法再访问此门店相关信息及订单'}, status: :bad_request }
        end
      end
    end
  end

  def validate_wifi_user_info
    # 判断wifi_code是否合法：与 branch_ext 中的 wifi_code 对应，否则导入错误指示页面
    if params[:wifi_code] && params[:_ng_path]
      params_branch_id = params[:_ng_path].gsub(/\/branches\//, "").gsub(/\/products.*/, "").to_i
      params_wifi_code = params[:wifi_code]
      @branch = Ddt::Branch.find(params_branch_id)
      if @branch.branch_ext.nil? || @branch.branch_ext.wifi_code != params_wifi_code
        render template: 'ddt/weixin/shops/invalidbranch'
        return
      end
    end
    # wifi_code合法，则继续判断 wifiuser 是否存在，不存在则创建
    @current_user = Ddt::WifiUser.find_by(wifi_code: params[:wifi_code]||cookies[:wifi_code])
    if @current_user.blank?
      @current_user = Ddt::WifiUser.create!(wifi_code: params[:wifi_code], shop_id: @current_shop.id)
    end
    cookies[:wifi_code] = params[:wifi_code] if params[:wifi_code]
    session[:store_type] = "for_wifi_order"
  end

  def validate_user_info
    # 判断是 微信用户 还是 wifi用户
    if params[:wifi_code].present? || cookies[:wifi_code].present?
      validate_wifi_user_info
    else
      validate_unique_user_info
      if cookies_get(:validate_wechatpay_user_info).present? and 'verify_vip_info_qr_code_scenes' != controller_name
        validate_wechatpay_user_info
      end
    end
  end

  #
  # 验证、获取微信用户相对于'点单通'服务号的 id，
  # 以后记为 UOID
  #
  def validate_unique_user_info
    user = nil
    # state为1代表获取身份信息，state为0代表获取基础信息
    if params[:state] == '1' || params[:state] == '0'
      if params[:code].present? and ( params[:force_fetch].present? || cookies_get(:open_id).blank?)

        access_resp = Ddt::WeixinApi.fetch_oauth_access_token(Ddt::WeixinConfig.gonghao.app_id, Ddt::WeixinConfig.gonghao.app_secret, params[:code])
        if access_resp.present? and access_resp.to_options[:openid].present?
          access_token_resp_json = access_resp.to_options
          # cookies 中的 open_id 设置为 UOID
          cookies_set(:open_id, access_token_resp_json[:openid])
          unless cookies_get(:open_id).present?
            raise "cookies open_id from weixin can not be empty #{cookies_get(:open_id)}"
          end
          # 把 UOID 添加到微信订阅关系中，此表记录用户相对公众号的 open_id，点单通公众号实质上也是一个公众号，只是在我们系统中比较特殊
          Ddt::WechatSubscribeRelationship.add_relationship(Ddt::WeixinConfig.gonghao.open_id, cookies_get(:open_id))
          # 用 UOID 寻找微信用户
          user = Ddt::User.find_or_create_shop_user(@current_shop.id, Ddt::WeixinConfig.gonghao.open_id, cookies_get(:open_id))

          if params[:state] == '1'
            #获取用户的详细身份信息
            oauth_user_info = Ddt::WeixinApi.fetch_user_info(access_token_resp_json[:access_token], access_token_resp_json[:openid])
            # 校验新获取的信息是否与系统存储起来是否不同
            # 若不同，使用新的信息
            if oauth_user_info.present? &&
                user.unique_user.user_open_id == oauth_user_info[:openid] &&
                user.unique_user.is_different_from(oauth_user_info)
              oauth_user_info.delete(:openid)
              user.unique_user.update!(oauth_user_info)
            end
          end
        end
      end
    end

    #为了方便开发者在浏览器下进行调试，允许通过HTTP请求参数来修改cookies_open_id
    # if (Rails.env.development? or Rails.env.test?) and params[:ddt_fake_open_id]
    if params[:ddt_fake_open_id].present?
      cookies_set(:open_id, params[:ddt_fake_open_id])
    end


    if cookies_get(:open_id).blank?
      raise Ddt::NoOpenIdException
    end
    if user.nil?
      # 此允许输入 open_id 创建 user
      user = Ddt::User.find_or_create_shop_user(@current_shop.id, Ddt::WeixinConfig.gonghao.open_id, cookies_get(:open_id))
    end

    if @current_shop.force_fetch_user_info? && (user.headimgurl.nil? || user.nickname.nil?)
      cookies_set(:open_id, nil)
      raise Ddt::NoBaseUserInfoException
    end

    #若base_user之前未与unique_user绑定，在此进行绑定
    user_open_id = request.query_parameters[:user_open_id]||params[:user_open_id]
    if user_open_id.present?
      wechat_user = @current_shop.wechat_users.find_by(user_open_id: user_open_id)
      @current_wechat_account = wechat_user.wechat_account if wechat_user.present?
      if wechat_user.present? and wechat_user.user.nil?
        wechat_user.update_attribute(:user, user)
        Ddt::Promotion::Events::UserFollow.create!(user: user)
        if user.from_branch_id.blank? && params[:from_branch_id].present?
          user.update(from_branch_id: params[:from_branch_id])
        end
      end
    end

    @hash_of_additional_params = {:source => "mp.weixin.qq.com"}
    @current_user = user
    Ddt::BaseUser.current = user
    Ddt::Account.current = nil
  end

  def validate_wechatpay_user_info
    # 如果 wechatpay3.3.6 没被激活，则不需要继续检查
    method = @current_shop.wechatpay_method_v336
    # 检查是否支持 wechatpay3.3.6
    if method.try(:active)
      open_id_index = method.try(:cookie_open_id_index).to_sym
      if params[:state] == '2' and params[:code].present? and cookies_get(open_id_index).blank?
        #没有微信支付open_id,需要人工获取
        resp = Ddt::WeixinApi.fetch_oauth_access_token(method.appid, method.appSecret, params[:code])
        if resp.present? && resp[:openid].present?
          openid = resp[:openid]
          if openid.present?
            current_wechatpay_user = Ddt::WechatUser.get_wechat_user(@current_shop, method.gonghao_open_id, openid, Ddt::WechatUser::SOURCE_OF_OAUTH)
            if current_wechatpay_user.user.nil?
              @current_user.wechat_users << current_wechatpay_user
              Ddt::Promotion::Events::UserFollow.create!(user: @current_user)
              if @current_user.from_branch_id.blank? && params[:from_branch_id].present?
                @current_user.update(from_branch_id: params[:from_branch_id])
              end
            end
            Ddt::WechatSubscribeRelationship.add_relationship(method.gonghao_open_id, openid)
            cookies_set(open_id_index, openid)
          end
        else
          method.delay.send_appid_or_appsecret_error_email
          raise Ddt::KnownException.wrap(Exception.new("no openid"))
        end
      elsif params[:state] == '2' and params[:code].blank?
        raise "no code"
      end

      #为了方便开发者在浏览器下进行调试，允许通过HTTP请求参数来修改cookies[open_id_index]
      # if (Rails.env.development? or Rails.env.test?) and params[:ddt_fake_open_id]
      if params[:ddt_fake_open_id].present?
        cookies_set(open_id_index, @current_user.wechat_users.where(gonghao_open_id: method.gonghao_open_id).try(:first).try(:user_open_id))
      end

      if cookies_get(open_id_index).blank?
        current_wechatpay_user = @current_user.wechat_users.find_by(gonghao_open_id: method.gonghao_open_id)
        cookies_set(open_id_index, current_wechatpay_user.user_open_id) if current_wechatpay_user.present?
      end

      if cookies_get(open_id_index).blank?
        raise Ddt::NoWechatpayOpenIdException, method
      end
    end
  end

  # 摇一摇周边, 用户点进去页面
  # params[:_shake_around] 存储的是 wechat_account.id
  def record_shake_around
    if params[:_shake_around].present? && params[:ticket]
      wechat_account = @current_shop.wechat_accounts.find_by(id: params[:_shake_around])
      if wechat_account.present?
        result = Ddt::WeixinApi.user_get_shake_info(wechat_account.get_access_token, params[:ticket])
        # 之前摇一摇，用户还没有记录，在此记录
        wechat_account.shake_infos.where(user_open_id: result[:openid], user_id: nil).update_all(user_id: @current_user.id, unique_user_id: @current_user.unique_user_id)
        # 记录用户进入页面
        shake_info = wechat_account.shake_infos.new(
          page_id: result[:page_id],
          user_open_id: result[:openid],
          poi_id: result[:poi_id],
          shop_id: wechat_account.shop_id,
          shake_time: Time.now,
          is_from_notify: false,
          user_id: @current_user.id,
          unique_user_id: @current_user.unique_user_id
        )
        shake_info.beacon_infos << Ddt::ShakeAround::BeaconInfo.new(result[:beacon_info].merge(is_chosen: true))
        shake_info.save


      end
    end
  end

  def check_current_shop
    if @current_shop.expired?
      render :template => "ddt/errors/disabled", layout: false
      return
    end
    unless @current_shop.is_open?
      render :template => "ddt/errors/closed", layout: false
      return
    end
  end

  def check_shop_enabled
    # TODO 检查微信模块是否开启
  end

  def render_not_from_weixin
    render :template => "ddt/errors/not_from_weixin", layout: false
  end

  def cookies_get(index)
    cookies.permanent[index]
  end

  def cookies_set(index, value)
    cookies.permanent[index] = value
  end

  rescue_from Ddt::ErrorNotFromWeixin, :with => :render_not_from_weixin

  rescue_from Ddt::Error::NoFeatureError, Ddt::Error::FeatureNotEnabled do |e|
    render :json => {errors: e.message}, status: :bad_request
  end

  # 当没有 openid，需要向微信请求访问用户信息的授权
  rescue_from Ddt::NoOpenIdException do |e|
    request_url = "#{request.protocol}#{Rails.application.default_url_options[:host]}#{request.fullpath}"
    redirect_to Ddt::WeixinApi.oauth_base_url(Ddt::WeixinConfig.gonghao.app_id, request_url)
  end

  rescue_from Ddt::NoBaseUserInfoException do |e|
    request_url = "#{request.protocol}#{Rails.application.default_url_options[:host]}#{request.fullpath}"
    redirect_to Ddt::WeixinApi.oauth_userinfo_url(Ddt::WeixinConfig.gonghao.app_id, request_url)
  end

  rescue_from Ddt::NoWechatpayOpenIdException do |e|
    method = e.wechatpay_method_v336
    request_url = "#{request.protocol}#{Rails.application.default_url_options[:host]}#{request.fullpath}"
    redirect_to Ddt::WeixinApi.oauth_url(method.appid, request_url, "code", "snsapi_base", 2)
  end

  private
  def set_track_from
    if @current_user.present? && @current_user.wifi_code.present?
      @track_from = :FromWifi
    else
      @track_from = :FromWechat
    end
  end

  def check_branch_online
    if Ddt::CsBranchBinding.deny_online_access?(@current_branch, request)
      respond_to { |format|
        format.html {
          render '门店未连网,不接受在线点餐'
        }
        format.json {
          render :json => {errors: '门店未连网,不接受在线点餐'}, status: :bad_request
        }
      }
    end
  end
end

# hack: change impression create to sidekiq
module ImpressionistController
  module InstanceMethods
    def impressionist(obj,message=nil,opts={})
      unless bypass
        if obj.respond_to?("impressionable?")
          if unique_instance?(obj, opts[:unique])
            # obj.impressions.create(associative_create_statement({:message => message}))
            Impression.delay(:retry => false).create({impressionable_id: obj.id, impressionable_type: obj.class.name}.merge(associative_create_statement({:message => message})))
          end
        else
          # we could create an impression anyway. for classes, too. why not?
          raise "#{obj.class.to_s} is not impressionable!"
        end
      end
    end
  end
end