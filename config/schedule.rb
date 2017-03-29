job_type :job, "cd :path && :environment_variable=:environment bundle exec script/sidekiq_pusher.rb :task :output"

set :output, "#{Dir.pwd}/log/whenever.log"

every 1.days, :at => '9:00 am', roles: [:master] do
  job "Ddt::Schedule::VipBirthdayNotificationWorker"
end

every :day, :at => '00:00', roles: [:master] do
  job "Ddt::Schedule::SaleEmployeeStatisticWorker"
end

every :day, :at => '01:00', roles: [:master] do
  job "Ddt::Schedule::CheckNewShopWorker"
end

every :monday, :at => '9:00 am', roles: [:master] do
  job "Ddt::Schedule::CheckShopExpireTimeWorker"
end

every 5.minutes, roles: [:master] do
  job "Ddt::Schedule::CheckNewOrderWorker"
end

every 1.hour, roles: [:master] do
  job "Ddt::Schedule::OrderAutoShipWorker"
end

every 2.days, :at => '04:00', roles: [:slaver, :master] do
  # job "Ddt::Schedule::ClearCacheWorker"
  runner "Rails.cache.clear"
  runner "CarrierWave.clean_cached_files!"
end

every 7.days, :at => '01:00', roles: [:master] do
  job 'Ddt::Schedule::DeleteOldMessageReceptionWorker'
end

every 7.days, :at => '02:00', roles: [:master] do
  job 'Ddt::Schedule::CheckShopInactiveWorker'
end

every 7.days, :at => '03:00', roles: [:master] do
  job 'Ddt::Schedule::CheckAgentRelExpireWorker'
end

every 5.minutes, roles: [:master] do
  job "Ddt::Schedule::SidekiqMonitorWorker"
end

every :day, :at => '03:20', roles: [:master] do
  job "Ddt::Schedule::CheckWalletAmountWorker"
end

every :day, :at => '01:30', roles: [:master] do
  job 'Ddt::Schedule::FillPhoneAddressWorker'
end

every :day, :at => '04:00', roles: [:master] do
  job 'Ddt::Schedule::VipShopWorker'
end

every 10.days, :at => '03:30', roles: [:master] do
  job 'Ddt::Schedule::CleanDbWorker'
end

every :day, :at => '01:00', roles: [:master] do
  job 'Ddt::Schedule::CheckAdjustmentAmountWorker'
end

every :day, :at => '01:45', roles: [:master] do
  job 'Ddt::Schedule::CheckShiftWorker'
end

every '0 6 1 1 *', roles: [:master] do
  job 'Ddt::Schedule::AutoClearCreditsWorker'
end

every :day, :at => '09:00', roles: [:master] do
  job 'Ddt::Schedule::CheckCouponExpiringWorker'
end

every 30.minutes, roles: [:master] do
  job 'Ddt::Schedule::ClearStatisticsCacheWorker'
end

every :day, :at => '09:00', roles: [:master] do
  job 'Ddt::Schedule::AutoSendFormWorker'
end

every :day, :at => '3:10', roles: [:master] do
  job 'Ddt::Schedule::FixOrderExtWorker'
end

# rvm cron setup
# whenever --update-crontab ddt_whenever --roles master
# whenever --update-crontab ddt_whenever --roles slaver
