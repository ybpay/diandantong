# encoding: utf-8
module Ddt
  class GhConfig
    require 'faraday-cookie_jar'
    attr_accessor :shop, :api_url, :wechat_account_id, :username, :password

    def initialize(params, current_shop, api_url)
      self.username = params[:username]
      self.password = params[:password]
      self.wechat_account_id = params[:id]
      self.api_url = api_url
      self.shop = current_shop
    end
    
    def auto_config
      if login
        begin
          toggle_dev_mode(1,2)
          result = configure_callback
          if result.nil?
            result = configure_callback
          end
          wechat_account = result
          sleep 1.5
          wechat_account = config_dev_profile(wechat_account)
        rescue Exception => e
          e.message
          return false
        end
        return wechat_account
      else
        return false
      end
    end

    private
    
    
    def login
      return false if invalid?
      response = conn_post(url: "/cgi-bin/login?lang=zh_CN",
                          body: {:username=>username, :pwd=>Digest::MD5.hexdigest(password.to_s)})
      responseBody = ActiveSupport::JSON.decode(response.body).to_options[:base_resp].to_options
      Rails.logger.info responseBody
      return false if responseBody[:ret].to_i != 0 
      @token = CGI.parse(ActiveSupport::JSON.decode(response.body).to_options[:redirect_url])["token"][0] rescue nil
      @slave_user = CGI::Cookie::parse(response.headers['set-cookie']).to_options[:slave_user][0] rescue nil
      return false unless @slave_user.present?
      true
    end

    def toggle_dev_mode(flag=nil, type=nil)
      response = conn_post(url: "/misc/skeyform?form=advancedswitchform&lang=zh_CN",
                          body: {:flag=>flag, :type=>type, :token=>@token})
      Rails.logger.info response.to_json
      Rails.logger.info response.body
      responseBody = ActiveSupport::JSON.decode(response.body).to_options
      Rails.logger.info responseBody.to_json
    end

    def config_dev_profile(wechat_account)
      profile_content = load_profile
      doc = Nokogiri::HTML(profile_content)
      is_service_account = doc.xpath('//li[@class="account_setting_item"]').select{|node| node.xpath('./div[@class="meta_content"]').text.strip =="服务号"}.length == 1 rescue nil
      is_not_verified = doc.xpath('//li[@class="account_setting_item"]').select{|node| node.xpath('./div[@class="meta_content"]').text.strip =="未认证"}.length == 1 rescue nil
      wechat_account.gonghao_type = is_service_account ? Ddt::WechatAccount::GONGHAO_SERVICE : Ddt::WechatAccount::GONGHAO_SUBSCRIBE
      wechat_account.be_verified = !is_not_verified
      wechat_account.public_account_name = doc.xpath('//li[@class="account_setting_item"]/div[@class="meta_content"]')[0].text.strip
      wechat_account.public_account_name += "("+doc.xpath('//li[@class="account_setting_item"]/div[@class="meta_content"]')[3].text.strip+")"
      develop_config_content = load_develop_config
      develop_doc = Nokogiri::HTML(develop_config_content)
      unless wechat_account.gonghao_type and !wechat_account.be_verified
        wechat_account.app_id = develop_doc.xpath('//div[@class="frm_control_group"]/div[contains(@class,"frm_controls")]')[0].text.strip rescue nil
        wechat_account.app_secret = develop_doc.xpath('//div[@class="frm_control_group"]/div[contains(@class,"frm_controls")]/text()')[1].text.strip rescue nil
      end
      validate_config_success(doc, develop_doc, wechat_account)
      wechat_account.save!
      wechat_account
    end

    def configure_callback
      uuid = "ddt" #SecureRandom.uuid.to_s.gsub(/\-/,"")
      wechat_account = shop.wechat_accounts.find(wechat_account_id) rescue nil if wechat_account_id.present?
      if wechat_account.nil?
        wechat_account = @shop.wechat_accounts.create(:token=>uuid, :gonghao_open_id=>@slave_user)
      else
        wechat_account.token = uuid
        wechat_account.gonghao_open_id = @slave_user
        wechat_account.save!
      end
      response = conn_post(url: "/advanced/callbackprofile?t=ajax-response&token=#{@token}&lang=zh_CN",
                          body: {:url=> api_url, :callback_token=> wechat_account.token}, 
                       headers: { Origin: 'https://mp.weixin.qq.com'})
      Rails.logger.info response.to_json
      responseBody = ActiveSupport::JSON.decode(response.body).to_options
      Rails.logger.info responseBody.to_json
      return wechat_account if responseBody[:ret].to_i == 0
      return nil
    end


    def validate_config_success(profile_doc, develop_config_doc, wechat_account)
      raise I18n.t 'gh error config of ID' if profile_doc.xpath('//li[@class="account_setting_item"]').
        select{|node| node.xpath('./div[@class="meta_content"]').text.strip ==wechat_account.gonghao_open_id} rescue nil
      if !wechat_account.gonghao_type or wechat_account.be_verified
        dev_confs = develop_config_doc.xpath('//div[@class="frm_control_group"]/div[contains(@class,"frm_controls")]')
        raise I18n.t 'gh error config of appId' if dev_confs[0].text.strip != wechat_account.app_id rescue nil
        raise I18n.t 'gh error config of appSecret' if dev_confs[1].text.strip != wechat_account.app_secret rescue nil
        raise I18n.t 'gh error config of URL' if dev_confs[2].text.strip != api_url rescue nil
        raise I18n.t 'gh error config of token' if dev_confs[3].text.strip != wechat_account.token rescue nil
      else
        raise I18n.t 'gh error config of URL' if dev_confs[0].text.strip != api_url rescue nil
        raise I18n.t 'gh error config of token' if dev_confs[1].text.strip != wechat_account.token rescue nil
      end
    end



    def load_profile
      conn_get "/cgi-bin/settingpage?t=setting/index&action=index&token=#{@token}&lang=zh_CN"
    end

    def load_develop_config
      conn_get "/advanced/advanced?action=dev&t=advanced/dev&token=#{@token}&lang=zh_CN"
    end

    def conn_get(url)
      response = conn.get url do |req|
        req.headers[:accept_encoding] = 'none'
      end
      return response.body.to_s
    end

    def conn_post(args)
      response = conn.post do |req|
        req.url args[:url]
        req.headers['Referer'] = 'https://mp.weixin.qq.com'
        req.headers['Host'] = 'mp.weixin.qq.com'
        req.headers['User-Agent'] = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
        args[:headers] && args[:headers].each do |key, value|
          req.headers[key.to_s] = value
        end
        req.body = args[:body]
      end
    end

    def conn
      @conn ||= Faraday.new(:url => 'https://mp.weixin.qq.com') do |faraday|
        faraday.use :cookie_jar
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def invalid?
      return true unless username.present?
      return true unless password.present?
      false
    end

    def inflate(string)
      zstream = Zlib::Inflate.new
      buf = zstream.inflate(string)
      zstream.finish
      zstream.close
      buf
    end
  end
end