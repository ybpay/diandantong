require "test_helper"
module Ddt
  module BillTemplate
    class TagHelperTest < TestCase::Base
      def test_scan_tag
        tag = TagHelper.scan_tag("aaa<item-name/>aaa", "item-name").first
        assert_equal "<item-name/>", tag.body
        assert_equal "", tag.content
      end

      def test_scan_tag_with_attrs
        tag = TagHelper.scan_tag("aaa<item-name width=10 align='right'/>aaa", "item-name").first
        assert_equal "<item-name width=10 align='right'/>", tag.body
        assert_equal "", tag.content
        assert_equal 10, tag.width
        assert_equal 'right', tag.align
      end

      def test_scan_tag_with_content
        tag = TagHelper.scan_tag("aaa<item-repeat size='M'>\n<item-name/>\n</item-repeat>aaa", "item-repeat").first
        assert_equal "<item-repeat size='M'>\n<item-name/>\n</item-repeat>", tag.body
        assert_equal "<item-name/>", tag.content
        assert_equal 'M', tag.size
      end

      def test_scan_tag_with_same_tags
        tags = TagHelper.scan_tag("aaa<item-repeat></item-repeat><item-repeat></item-repeat>aaa", "item-repeat")
        assert_equal 2, tags.count
        assert_equal "<item-repeat></item-repeat>", tags[0].body
        assert_equal "<item-repeat></item-repeat>", tags[1].body
      end

      def test_scan_if_tag
        tag = TagHelper.scan_tag("aaa\n<if></if>aaa", "if").first
        assert_equal "\n<if></if>", tag.body
        assert_equal "", tag.content
      end
    end
  end
end
