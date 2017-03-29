#encoding: utf-8
module Ddt
  module Schedule
    class AutoSendFormWorker < Ddt::Schedule::Base
      def perform
        send_form_to_worker(get_accounts)
      end

      private
        def send_form_to_worker(accounts)
          start_time = 1.day.ago.beginning_of_day
          end_time = 1.day.ago.end_of_day
          time = Time.now
          year = time.year
          month = time.month
          day = time.day-1
          content =  Ddt::Account.to_csv(accounts,col_sep: ",")
          BaseAttachmentMailer.notify(Rails.application.config.worker_mail, "#{year}年#{month}月#{day}日注册用户信息列表", body(accounts), "accounts_#{start_time}_#{end_time}.csv", content )
        end

        def get_accounts
          start_time = 1.day.ago.beginning_of_day
          end_time = 1.day.ago.end_of_day
          shops = Ddt::Shop.where(:created_at=>start_time..end_time, :agent_no=>[nil, ""])
          accounts = []
          shops.each do |shop|
            shop.accounts.each do |account|
              if account.is_boss?
                accounts << account
              end
            end
          end
          return accounts
        end

        def body(accounts)
          track_froms = {}
          addresses = {}
          track_froms.default = 0
          addresses.default = 0
          accounts.each do |account|
            if account.shop.address.blank?
              addresses["未知"] += 1
            else
              addresses[account.shop.address] += 1
            end
            if account.shop.track_from_name.blank?
            else
              track_froms[account.shop.track_from_name] += 1
            end
          end
          body =%Q(总人数:#{accounts.count}人\n\n)
          body += "地区: "
          addresses.each do |address, count|
            body += address+"---"+"#{count}; "
          end
          body+="\n\n"
          body += "来源: "
          track_froms.each do |track_from, count|
            body += track_from+"---"+"#{count}; "
          end
          body+="\n\n"
        end
    end
  end
end


