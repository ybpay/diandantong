module Ddt
  module Webpos
    module BaseHelper
      def asset_root_url
        asset = Ddt::Host::ASSET
        asset.present? ? "#{asset}/" : root_url()
      end
    end
  end
end

