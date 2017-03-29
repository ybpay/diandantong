module Ddt
  module Statistic
    module Concern
      module BaseTest
      extend ActiveSupport::Concern
        def test_respond_to_view_methods
          assert_respond_to statistic, :info
          assert_respond_to statistic, :filters
          assert_respond_to statistic, :title
          assert_respond_to statistic, :body
        end

        def test_body
          assert statistic.body
        end

        def test_foot
          assert statistic.foot
        end

        def test_paginate
          if statistic.info[:paginate]
            statistic.result
            assert_respond_to statistic, :records
            assert_respond_to statistic.records, :total_pages
          else
            assert true
          end
        end

        def test_to_html
          assert statistic.to_html
        end

        def test_to_wechat_html
          assert statistic.to_wechat_html
        end

        def test_to_csv
          assert statistic.to_csv
        end

      end
    end
  end
end
