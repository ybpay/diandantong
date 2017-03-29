#encoding: utf-8
module Ddt
  class Common::ClearCookiesController < ApplicationController
    def clear_cookies
      open_id = cookies[:open_id]
      cookies.clear
      cookies[:open_id] = open_id
      render :json => cookies.to_json
    end
  end
end
