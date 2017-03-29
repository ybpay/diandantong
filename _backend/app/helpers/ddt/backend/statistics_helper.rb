# encoding:utf-8
module Ddt
  module Backend
    module StatisticsHelper

      def access_from_options
        [["来自微信", "wechat"], ["来自网站", "web"], ["来自朋友圈分享", "friendcircle"]]
      end

      def format_statistics_query(jsonstr)
        return nil if jsonstr.nil?
        json = JSON.parse(jsonstr)
        branch_name = ""
        if json["门店"].to_i > 0
          branch_name = Ddt::Branch.find(json["门店"].to_i).name
        end
        json["门店"] = branch_name

        time_interval_name = ""
        if json["时间区间"].to_i > 0
          time_interval_name = Ddt::TimeInterval.find(json["时间区间"].to_i).name
        end
        json["时间区间"] = time_interval_name
        
        if json["skus"].present?
          variant_names = []
          (YAML.load json["skus"]).each do |sku|
            variant_names.append(Ddt::Variant.find_by(sku: sku.to_s).cache_name)
          end
          json["skus"] = variant_names.to_s
        end
        json = {"门店" => json["门店"], "开始时间" => json["开始时间"], "结束时间" => json["结束时间"]}
        json["门店"] = "所有门店" if json["门店"] == ""
        JSON.pretty_generate(json).gsub(/["\{\},]/, ' ')
      end

    end
  end
end
