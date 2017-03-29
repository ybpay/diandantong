module Ddt
  module TestCase
    module Controller
      class Base < ActionController::TestCase
        include EngineControllerTestRoutePatch
        include RequestJsonHelper

        def assert_change(expression, message=nil, &block)
          expressions = Array(expression)
          exps = expressions.map { |e| e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }}
          before = exps.map { |e| e.call }
          yield
          expressions.zip(exps).each_with_index do |(code, e), i|
            error = message ? "#{message}.\n#{error}" : "#{code.inspect} didn't change"
            assert_not_equal(before[i], e.call, error)
          end
        end

        def assert_no_change(expressions, message=nil, &block)
          expressions = Array(expressions)
          exps = expressions.map { |e| e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }}
          before = exps.map { |e| e.call }
          yield
          expressions.zip(exps).each_with_index do |(code, e), i|
            error = message ? "#{message}.\n#{error}" : "#{code.inspect} changed"
            assert_equal(before[i], e.call, error)
          end
        end
      end
    end
  end
end