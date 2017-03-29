module Ddt
  module OrderService
    module Api
      class Litp
        include OrderService::Api::Base
        def self.query(params={})
          new_params = params.merge({
              _format: :ransack,
              _page: params[:page],
              _size: params[:per_page],
            }).except(:page, :per_page)
          service_get("/litps", new_params)
        end

        def self.count(params={})
          service_get("/litps/count", params.merge(_format: :ransack)).try(:to_i)
        end

        def self.get(id)
          service_get("/litps/#{id}", {})
        end

        def self.update(id, body={})
          service_put("/litps/#{id}", {}, body)
        end

        mock_for :query, :count, :get, :update
      end
    end
  end
end