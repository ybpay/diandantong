#encoding: utf-8
require "open-uri"
require "rest-client"
module Ddt
  module WeixinApi
    class WeixinApiError < ::StandardError
      attr_accessor :errcode, :errmsg, :data

      def initialize(errcode, errmsg, data)
        @errcode = errcode.to_i
        @errmsg = errmsg
        @data = data
        message = ""
        if WxErrcode.has?(errcode)
          message << "\n#{WxErrcode.msg_for(errcode)}"
        end
        message << "[ errcode: #{@errcode}, errmsg: #{@errmsg} ]"
        super(message)
      end
    end

    AUTHORIZE_URL = "https://open.weixin.qq.com/connect/oauth2/authorize"

    def self.oauth_url(appid, redirect_uri, response_type, scope, state)
      redirect_uri = self.parse_from_oauth_url(redirect_uri)
      # redirect_uri = CGI::escape(redirect_uri)
      url_hash = {
        appid: appid,
        redirect_uri: redirect_uri,
        response_type: response_type,
        scope: scope,
        state: state
      }
      "#{AUTHORIZE_URL}?#{url_hash.to_query}#wechat_redirect"
    end

    def self.parse_from_oauth_url(url)
      #解析url里面的redirect_uri参数
      if url.present? && url.start_with?(AUTHORIZE_URL)
        query_params = Rack::Utils.parse_query(URI.parse(url).query)
        uri = URI.parse(query_params["redirect_uri"])
        uri.query = Rack::Utils.parse_query(uri.query).select{|k, v| !["code", "state"].include?(k)}.to_query
        uri.to_s
      else
        url
      end
    end

    def self.oauth_base_url(appid, redirect_uri)
      self.oauth_url(appid, redirect_uri, "code", "snsapi_base",0)
    end

    def self.oauth_userinfo_url(appid, redirect_uri)
      self.oauth_url(appid, redirect_uri, "code", "snsapi_userinfo",1)
    end

    def self.weixin_host
      # 'https://api.weixin.qq.com'
      'http://weixinproxy.diandantong.com'
      # 'http://115.29.244.71'
    end

    def self.fetch_user_info(access_token, openid, lang = 'zh_CN')
      params = {
        :access_token => access_token,
        :openid => openid,
        :lang => lang
      }
      self.get_method("/sns/userinfo", params) do |data|
        {
          openid:     data[:openid],
          nickname:   data[:nickname],
          sex:        data[:sex],
          province:   data[:province],
          city:       data[:city],
          country:    data[:country],
          headimgurl: data[:headimgurl],
          privilege:  data[:privilege],
          unionid:    data[:unionid]
        }
      end
    end

    def self.fetch_access_token(app_id, app_secret)
      params = {
        :grant_type => 'client_credential',
        :appid => app_id,
        :secret => app_secret
      }
      self.get_method("/cgi-bin/token", params) do |data|
        data[:access_token]
      end
    rescue WeixinApiError => e
      # 给商家发邮件
      wa = WechatAccount.find_by(app_id: app_id)
      wa.delay.send_appid_or_appsecret_error_email(e) if wa.present?
      raise Ddt::KnownException.wrap(e)
    end

    def self.fetch_jsapi_ticket(access_token)
      params = {
        :access_token => access_token,
        :type=> 'jsapi'
      }
      self.get_method("/cgi-bin/ticket/getticket", params, false) do |data|
        data[:ticket]
      end
    end

    def self.fetch_oauth_access_token(appid, secret, code)
      params = {
        appid:  appid,
        secret: secret,
        code:   code,
        grant_type: "authorization_code"
      }
      self.get_method("/sns/oauth2/access_token", params, false) do |data|
        data
      end
    end

    #发送客服消息
    def self.send_custom_message(material, to_user_open_id, access_token)

      body = {
        :touser => to_user_open_id,
        :msgtype => material.msg_type
      }

      if material.is_text?
        body = body.merge({
          :text => {
            :content=> material.content
          }
        })
      elsif material.is_music?
        body = body.merge({
          :music => {
            :title => material.title,
            :description => material.description,
            :musicurl => material.music_url,
            :hqmusicurl => material.hq_music_url,
            :thumb_media_id => nil #必填选项
          }
        })
      elsif material.is_news?
        articles = []
        material.articles.each do |article|
          unless articles.length <= 10
            raise "articles can not be more than 10"
          end
          articles << {
            :title => article.title,
            :description => article.description,
            :url => article.url,
            :picurl => article.pic_url
          }
        end
        body = body.merge({
          :news => {
            :articles => articles
          }
        })
      end

      post_method "/cgi-bin/message/custom/send", { access_token: access_token } , body do |data|
        true
      end
    end

    def self.add_template(access_token, template_id_short)
      body = { template_id_short: template_id_short}
      post_method "/cgi-bin/template/api_add_template", { access_token: access_token}, body do |data|
        return data[:template_id]
      end
    end

    def self.send_template_message(access_token, to_user_open_id, template_id, url, data)
      body = {
        touser: to_user_open_id,
        topcolor: data.delete(:topcolor),
        template_id: template_id,
        url: url,
        data: data
      }
      post_method "/cgi-bin/message/template/send", { access_token: access_token } , body do |data|
        true
      end
    end

    def self.jsapi_ticket_signature(jsapi_ticket, noncestr, timestamp, url)
      url_hash = {}
      url_hash[:jsapi_ticket] = jsapi_ticket
      url_hash[:noncestr] = noncestr
      url_hash[:timestamp] = timestamp
      url_hash[:url] = url
      Digest::SHA1.hexdigest(url_hash.sort.map{|field| field.join("=")}.join("&"))
    end

    # 自定义菜单创建接口
    def self.create_custom_menu(access_token, menus_hash)
      body = menus_hash.to_json
      # 微信的接口不接受含有 \uxxxx 的字符串，而to_json方法会把 '&' 转换成\u0026
      # 这里需要将\u0026转回 '&'
      body.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
      post_method "/cgi-bin/menu/create", { access_token: access_token } , body do |data|
        true
      end
    end

    # 自定义菜单删除
    def self.delete_custom_menu(access_token)
      params = {
        access_token: access_token
      }
      body = URI.parse("#{self.weixin_host}/cgi-bin/menu/delete?#{params.to_query}").read
      data = ActiveSupport::JSON.decode(body).to_options
      check_errcode data do
        true
      end
    end

    #创建永久微信二维码接口,返回图片的URL地址
    def self.create_limit_qr_code(access_token, scene_id)
       body = {
        :action_name => "QR_LIMIT_SCENE",
        :action_info => {
          :scene => {
            :scene_id => scene_id
          }
        }
      }
      self.create_qr_code(access_token, body)
    end

    #创建临时微信二维码接口,返回图片的URL地址
    def self.create_snap_qr_code(access_token, scene_id, expiration_seconds = 7200)
      body = {
        :expire_seconds => expiration_seconds,
        :action_name => "QR_SCENE",
        :action_info => {
          :scene => {
            :scene_id => scene_id
          }
        }
      }
      self.create_qr_code(access_token, body)
    end

    def self.create_qr_code(access_token, body_hash)
      post_method "/cgi-bin/qrcode/create", { access_token: access_token }, body_hash do |data|
        "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{data[:ticket]}"
      end
    end

    # 获取组件access_token
    def self.get_component_access_token(component_appid, component_appsecret, component_verify_ticket)
      body = {
        component_appid: component_appid,
        component_appsecret: component_appsecret,
        component_verify_ticket: component_verify_ticket
      }
      post_method "/cgi-bin/component/api_component_token", {}, body do |data|
        [data[:component_access_token], data[:expires_in]]
      end
    end

    # 获取预授权码pre_auth_code
    def self.get_component_pre_auth_code(component_access_token, component_appid)
      params = { component_access_token: component_access_token }
      body   = { component_appid: component_appid }
      post_method "/cgi-bin/component/api_create_preauthcode", params, body do |data|
        [data[:pre_auth_code], data[:expires_in]]
      end
    end

    # 使用授权码换取公众号的授权信息
    def self.get_component_auth_info(component_access_token, component_appid, authorization_code)
      params = { component_access_token: component_access_token }
      body   = {
        component_appid: component_appid,
        authorization_code: authorization_code
      }
      post_method "/cgi-bin/component/api_query_auth", params, body do |data|
        data
      end
    end

    # 获取授权方的账户信息
    def self.get_authorizer_info(component_access_token, component_appid, authorizer_appid)
      params = { component_access_token: component_access_token }
      body   = {
        component_appid: component_appid,
        authorizer_appid: authorizer_appid
      }
      post_method "/cgi-bin/component/api_get_authorizer_info", params, body do |data|
        data
      end
    end

    # 获取（刷新）授权公众号的令牌
    def self.refresh_authorizer_access_token(component_access_token, component_appid, authorizer_appid, authorizer_refresh_token)
      params = { component_access_token: component_access_token }
      body   = {
        component_appid: component_appid,
        authorizer_appid: authorizer_appid,
        authorizer_refresh_token: authorizer_refresh_token,
      }
      post_method "/cgi-bin/component/api_authorizer_token", params, body do |data|
        data
      end
    end

    # 申请设备ID ok
    def self.device_apply_id(access_token, quantity, apply_reason, comment=nil, poi_id=nil)
      params = { access_token: access_token }
      body   = {
        quantity: quantity,
        apply_reason: apply_reason
      }
      body.merge({comment: comment}) unless comment.nil?
      body.merge({poi_id: poi_id}) unless poi_id.nil?
      post_method "/shakearound/device/applyid", params, body do |data|
        result = data[:data]
        result.symbolize_keys
      end
    end

    # 查询设备ID申请状态 ok
    def self.device_apply_status(access_token, apply_id)
      params = { access_token: access_token }
      body   = { apply_id: apply_id}
      post_method "/shakearound/device/applystatus", params, body do |data|
        data = data[:data].symbolize_keys
        result = {
          apply_time: Time.at(data[:apply_time]),
          audit_comment: data[:audit_comment],
          audit_status: data[:audit_status]
        }
        result[:audit_time] = Time.at(data[:audit_time]) if data[:audit_status] != 1
        result
      end
    end

    # 编辑设备信息(只能改备注) ok
    def self.device_update(access_token, device_id, comment)
      params = { access_token: access_token}
      body   = {
        device_identifier: {
          device_id: device_id
        },
        comment: comment
      }
      post_method "/shakearound/device/update", params, body do |data|
        true
      end
    end

    # 配置设备与门店的关联关系
    def self.device_bind_location(access_token, device_id, poi_id)
      params = { access_token: access_token }
      body   = {
        device_identifier: {
          device_id: device_id
        },
        poi_id: poi_id
      }
      post_method "/shakearound/device/bindlocation", params, body do |data|
        data
      end
    end

    # 查询设备列表(根据提供的设备id) device_ids不能超过50个 ok
    def self.device_search_by_ids(access_token, device_ids)
      body = {
        device_identifiers: device_ids.map{|id| {device_id: id}}
      }
      device_search(access_token, body)
    end

    # count 不能超过50 ok
    def self.device_search_by_page(access_token, offset, count)
      body = {
        :begin => offset,
        :count => count
      }
      device_search(access_token, body)
    end

    # count 不能超过50 ok
    def self.device_search_by_apply_id(access_token, apply_id, offset, count)
      body = {
        :apply_id => apply_id,
        :begin => offset,
        :count => count
      }
      device_search(access_token, body)
    end

    # ok
    def self.device_search(access_token, body)
      params = { access_token: access_token }
      post_method "/shakearound/device/search", params, body do |data|
        result = data[:data]
        result.symbolize_keys
      end
    end

    # 新增页面
    def self.page_add(access_token, title, description, page_url, icon_url, comment=nil)
      params = { access_token: access_token }
      body   = {
        title: title,
        description: description,
        page_url: page_url,
        icon_url: icon_url
      }
      body.merge(comment: comment) unless comment.nil?
      post_method "/shakearound/page/add", params, body do |data|
        data[:data]["page_id"]
      end
    end

    # 编辑页面
    def self.page_update(access_token, page_id, title, description, page_url, icon_url, comment=nil)
      params = { access_token: access_token }
      body   = {
        page_id: page_id,
        title: title,
        description: description,
        page_url: page_url,
        icon_url: icon_url
      }
      body.merge(comment: comment) unless comment.nil?
      post_method "/shakearound/page/update", params, body do |data|
        true
      end
    end

    # 删除页面
    def self.page_delete(access_token, page_ids)
      params = { access_token: access_token }
      body   = { page_ids: page_ids}
      post_method "/shakearound/page/delete", params, body do |data|
        true
      end
    end

    # 查询页面
    def self.page_search_by_ids(access_token, page_ids)
      body = { page_ids: page_ids }
      page_search(access_token, body)
    end

    def self.page_search_by_page(access_token, offset, count)
      body = {
        :begin => offset,
        :count => count
      }
      page_search(access_token, body)
    end

    def self.page_search(access_token, body)
      params = { access_token: access_token }
      post_method "/shakearound/page/search", params, body do |data|
        result = data[:data]
        result.symbolize_keys
      end
    end

    # 上传图片素材
    def self.material_add(access_token, file, type="icon")
      body = RestClient.post 'https://api.weixin.qq.com/shakearound/material/add', {
        type: type,
        access_token: access_token,
        media: file
      }
      data = ActiveSupport::JSON.decode(body).to_options
      check_errcode data do
      end
      data[:data]["pic_url"]
    end

    # 配置设备与页面的关联关系
    def self.device_bind_page(access_token, device_id, page_ids, bind, append)
      params = { access_token: access_token}
      body = {
        device_identifier: {
          device_id: device_id
        },
        page_ids: page_ids,
        bind: bind,
        append: append
      }
      post_method "/shakearound/device/bindpage", params, body do |data|
        true
      end
    end

    # 获取摇周边的设备及用户信息
    def self.user_get_shake_info(access_token, ticket, need_poi=0)
      params = { access_token: access_token}
      body = {
        ticket: ticket,
        need_poi: need_poi
      }
      post_method "/shakearound/user/getshakeinfo", params, body do |data|
        result = data[:data]
        result.symbolize_keys
      end
    end

    # 以设备为维度的数据统计接口
    def self.statistics_device(access_token, device_id, begin_date, end_date)
      params = { access_token: access_token}
      body   = {
        device_identifier: {
          device_id: device_id
        },
        begin_date: begin_date,
        end_date: end_date
      }
      post_method "/shakearound/statistics/device", params, body do |data|
        data
      end
    end

    # 以设备为维度的数据统计接口
    def self.statistics_page(access_token, page_id, begin_date, end_date)
      params = { access_token: access_token}
      body   = {
        page_id: page_id,
        begin_date: begin_date,
        end_date: end_date
      }
      post_method "/shakearound/statistics/page", params, body do |data|
        data
      end
    end

    def self.get_method(url, params, need_check_errcode = true)
      body = URI.parse("#{self.weixin_host}#{url}?#{params.to_query}").read
      data = ActiveSupport::JSON.decode(body).to_options
      if need_check_errcode
        check_errcode data do yield(data); end
      else
        yield(data)
      end
    end



    # 如果body是字符串，则直接作为请求的内容。如果body是其他类型，则会在内部调用to_json
    def self.post_method(url, params={}, body={}, need_check_errcode=true)
      uri = URI.parse("#{weixin_host}#{url}?#{params.to_query}")
      https = Net::HTTP.new(uri.host,uri.port)
      https.open_timeout = 60
      https.read_timeout = 60
      # https.use_ssl = true
      req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      req.body = body.is_a?(String) ? body : body.to_json
      response = https.request(req)
      data = ActiveSupport::JSON.decode(response.body).to_options
      if need_check_errcode
        check_errcode data do yield(data); end
      else
        yield(data)
      end
    end

    def self.check_errcode(data)
      Rails.logger.info data
      if data[:errcode].present? && data[:errcode] != 0
        raise WeixinApiError.new(data[:errcode], data[:errmsg], data)
      else
        yield
      end
    end
  end
end
