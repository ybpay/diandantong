class FixRollbackVipCardLog < ActiveRecord::Migration
  def change
    Octopus.using(:master) do
      query
      date_msg = fix_wallet_log
      update_shift(date_msg)
    end
  end

  def query
    @errors = []
    r = ActiveRecord::Base.connection.execute <<-SQL
      SELECT order_id, wallet_id, count(*) as c
      FROM ddt_wallet_logs
      WHERE reason = 'for_rollback_vip_card_pay'
      GROUP BY order_id, wallet_id having c > 1
    SQL

    r.to_a.each do |row|
      order_id = row[0]
      wallet_id= row[1]
      wallet_logs = Ddt::WalletLog.where(wallet_id: wallet_id, order_id: order_id, reason: [:for_vip_card_pay ,:for_rollback_vip_card_pay])
      wallet_logs = wallet_logs.to_a.sort{|a, b| a.created_at.to_i - b.created_at.to_i}
      if wallet_logs.any?{|l| l.note.present? && (l.note =~ /\[系统调账\]/) != nil}
        puts "[已调账] order_id: #{order_id}, wallet_id: #{wallet_id}"
        next
      end

      vip_card_pay_amounts = []
      rollback_pay_logs = []

      wallet_logs.each do |wallet_log|
        if wallet_log.reason == 'for_vip_card_pay'
          vip_card_pay_amounts << wallet_log.amount
        else
          rollback_pay_logs << wallet_log
        end
      end

      wrong_logs = []
      rollback_pay_logs.each do |log|
        idx = vip_card_pay_amounts.index(-log.amount)
        if idx.nil?
          wrong_logs << log
        else
          vip_card_pay_amounts.delete_at idx
        end
      end
      if wrong_logs.size > 0
        if vip_card_pay_amounts.size >= wrong_logs.size
          wrong_logs.each_with_index do |log, index|
            store_logs(log, -vip_card_pay_amounts[index])
          end
        else
          puts "[有问题的log] order_id: #{order_id}, wallet_id: #{wallet_id}"
        end
      end
    end && nil
    puts_errors
  end

  def store_logs(log, right_amount)
    @errors << {log: log, right_amount: right_amount}
  end

  def fix_wallet_log
    fixed = []
    @errors.each do |error|
      log = error[:log]
      diff = error[:right_amount] - log.amount
      wallet = log.wallet
      if wallet.of_user? && wallet.amount + diff < 0
        puts "[AmountNotEnough]{wallet_id: #{wallet.id}, log_id: #{log.id}}, order_id: #{log.order_id}"
        next
      end

      cash, extra = wallet.get_cash_and_extra_from_total(diff.abs)
      same_attrs = log.slice(:shop_id, :branch_id, :wallet_id, :order_id, :reason, :created_at)
      note = "[系统调账](#{log.id})"
      if diff > 0
        puts "[FixLog](#{log.created_at.strftime('%F %T')}: #{wallet.type}) wallet_id: #{wallet.id}, log_id: #{log.id}, order_id: #{log.order_id} diff: #{diff}, cash: #{cash}, extra: #{extra}"
        fixed << "[FixLog](#{log.created_at.strftime('%F %T')}: #{wallet.type}) wallet_id: #{wallet.id}, log_id: #{log.id}, order_id: #{log.order_id} diff: #{diff}, cash: #{cash}, extra: #{extra}"
        params = same_attrs.merge(amount: diff, cash_amount: cash, extra_amount: extra, note: note)
        wallet.increment_amount(diff.abs, cash, extra)
        wallet.wallet_logs.create params
      else
        puts "[FixLog](#{log.created_at.strftime('%F %T')}: #{wallet.type}) wallet_id: #{wallet.id}, log_id: #{log.id}, order_id: #{log.order_id} diff: #{diff}, cash: #{-cash}, extra: #{-extra}"
        fixed << "[FixLog](#{log.created_at.strftime('%F %T')}: #{wallet.type}) wallet_id: #{wallet.id}, log_id: #{log.id}, order_id: #{log.order_id} diff: #{diff}, cash: #{-cash}, extra: #{-extra}"
        params = same_attrs.merge(amount: diff, cash_amount: -cash, extra_amount: -extra, note: note)
        wallet.decrement_amount(diff.abs, cash, extra)
        wallet.wallet_logs.create params
      end
    end
    date_msg = []
    @errors.each do |error|
      date_msg << {created_at: error[:log].created_at, branch_id: error[:log].branch_id}
    end
    date_msg
  end

  def update_shift(date_msg)
    date_msg.each do |msg|
      shifts = Ddt::Shift.closed.where(branch_id: msg[:branch_id], created_at: (msg[:created_at].beginning_of_day)..(msg[:created_at].end_of_day))
      shifts.each do |shift|
        shift.update_amount
      end
    end
  end


  def puts_errors
    @errors.each do |error|
      puts "LogID: #{error[:log].id}, wrong: #{error[:log].amount}, right: #{error[:right_amount]}"
    end
  end

end
