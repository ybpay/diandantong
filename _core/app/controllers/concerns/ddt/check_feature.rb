module Ddt
  module CheckFeature
    extend ActiveSupport::Concern

    included do

      def self.check_feature(scope)
        method_name = "check_feature_#{scope}"
        define_method method_name do
          shop = (current_shop rescue nil)
          return if shop.blank?
          return if current_account.present? && current_account.is_admin?
          action_feature_rels = Ddt::ActionFeatureRel.send(scope.to_sym).send(:[], controller_name.to_sym)

          if action_feature_rels.present?
            match_conf = action_feature_rels.detect do |actions, value|
              actions.is_a?(Array) && actions.include?(action_name.to_sym) ||
              [String, Symbol].include?(actions.class) && actions.to_sym == :all
            end
            if match_conf.present?
              features = match_conf[1]
              raise "Features Blank?(scope: #{scope})" if features.blank?
              features = features.call(request) if features.is_a?(Proc)
              if features.present?
                features = [features] if !features.is_a?(Array)
                features.each do |feature|
                  unless Ddt::FeatureModules::WHITE_LIST_FEATURES.include?(feature)
                    qfmc = shop.qualified_feature_modules_configs(feature)
                    raise Ddt::Error::NoFeatureError.new(feature) if qfmc.blank?
                    raise Ddt::Error::FeatureNotEnabled.new(feature, qfmc.map(&:disable_reason).join("，")) if qfmc.all?{|fmc| !fmc.enabled}
                  end
                end
              end
            end
          end
        end
        before_action method_name
      end

    end

  end
end
