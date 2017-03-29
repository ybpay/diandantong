#encoding: utf-8
module Ddt
  module TimeUtil

    SECOND = 1
    MINUTE = 60 * SECOND
    HOUR = 60 * MINUTE
    DAY = 24 * HOUR
    MONTH = 30 * DAY
    YEAR = 365 * DAY


    def self.time_since_beginning_of_day(the_time)
      the_time.to_i - the_time.beginning_of_day.to_i
    end

    def self.time_a_early_than_b(a, b)
      return true  if a.hour < b.hour
      return false if a.hour > b.hour
      return true  if a.min  < b.min
      false
    end

    def self.days_between(from, to)
      from = Time.parse(from) if from.is_a? String
      to = Time.parse(to) if to.is_a? String
      return 1 if is_same_day?(from, to)
      Integer( 2 + (to.beginning_of_day.to_i - from.end_of_day.to_i).abs / DAY )
    end

    def self.is_same_day?(a, b)
      return a.year == b.year && a.month == b.month && a.day == b.day
    end

    def self.label_of_second(second)
      case second
      when SECOND...MINUTE; "#{second}秒"
      when MINUTE...HOUR  ; "#{Integer(second/MINUTE)}分钟#{Integer((second%MINUTE))}秒"
      when HOUR...DAY     ; "#{Integer(second/HOUR)}小时#{Integer((second%HOUR)/MINUTE)}分钟"
      when DAY...MONTH    ; "#{Integer(second/DAY)}天#{Integer((second%DAY)/HOUR)}小时"
      when MONTH...YEAR   ; "#{Integer(second/MONTH)}月#{Integer((second%MONTH)/DAY)}天"
      else
        "#{second/YEAR}年"
      end
    end

    def self.get_and_reset_timer
      # thread local?
      t = Time.now.to_f
      if @timer.nil?
        @timer = t
        return 0
      else
        r = t - @timer
        @timer = t
        return r
      end
    end

    # labels
    def self.day_labels(month=Time.now.month, year=Time.now.year)
      year = Integer(year)
      month = Integer(month)
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      if current_year == year && current_month == month
        end_date = [end_date, Date.today].min
      end
      (start_date.day..end_date.day).map do |day|
        "%02d-%02d" % [month, day]
      end
    end

    def self.week_label(wday)
      week_labels[wday]
    end

    def self.week_labels
      %W[星期日 星期一 星期二 星期三 星期四 星期五 星期六]
    end

    def self.month_labels(year=Time.now.year, all: false)
      year = Integer(year)
      start_date = Date.new(year, 1, 1)
      end_date = start_date.end_of_year
      if !all && current_year == year
        end_date = [end_date, Date.today].min
      end
      (start_date.month..end_date.month).map do |month|
        "%04d-%02d" % [year, month]
      end
    end

    def self.current_year
      Time.now.year
    end

    def self.current_month
      Time.now.month
    end

  end
end
