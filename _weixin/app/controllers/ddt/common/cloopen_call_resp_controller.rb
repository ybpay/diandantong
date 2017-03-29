# encoding : utf-8
module Ddt
  class Common::CloopenCallRespController < ApplicationController
    protect_from_forgery :except => :create

    def create
      body = request.body.read
      hash_request = Hash.from_xml(body).to_options[:request].to_options
      # {
      #   :action=>"SellingCall",
      #   :callSid=>"1506021533070415000600020000565f",
      #   :number=>"15715779004",
      #   :state=>"0",
      #   :starttime=>'20150602155026',
      #   :endtime=>'20150602155026',
      #   :duration=>"0"
      # }
      order_call = Ddt::OrderCall.find_by(call_sid: hash_request[:callSid])
      if order_call.present?
        order_call.set_state(hash_request[:state].to_i, hash_request[:duration].to_i)
      end
      render xml: { statuscode: '000000' }.to_xml(root: 'Response')
    end

  end
end