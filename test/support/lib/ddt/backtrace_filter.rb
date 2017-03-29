module Ddt
  class BacktraceFilter
    def filter bt
      bt.dup.reject{|x| not x.to_s =~ /#{::Rails.root.to_s}/}
    end
  end
end
# MiniTest.backtrace_filter = Ddt::BacktraceFilter.new
# Rails.backtrace_cleaner.remove_silencers!