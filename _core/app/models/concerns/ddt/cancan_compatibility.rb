# frozen_string_literal: true

# Compatibility shim for the CanCan -> ActionPolicy migration.
#
# Provides the CanCan::Ability DSL (can, cannot, alias_action, with_options)
# and the underlying @rules / @aliased_actions machinery so that the existing
# Ability classes keep working without the cancancan gem.
#
# Usage:
#   class MyAbility
#     include Ddt::CanCanCompatibility
#     def initialize(account)
#       # ... use can/cannot/with_options exactly as before ...
#     end
#   end
#
module Ddt::CanCanCompatibility
  extend ActiveSupport::Concern

  Rule = Struct.new(:actions, :base_behavior, :conditions, :block, :match_all, :subjects, keyword_init: true) do
    def matches_action?(action)
      actions.include?(:manage) || actions.include?(action)
    end

    def matches_subject?(subject)
      match_all ||
        subjects.any? { |s|
          s == :all ||
          s == subject ||
          (s.is_a?(Class) && subject.is_a?(Class) && subject.ancestors.include?(s)) ||
          (s.is_a?(String) && subject.to_s.demodulize.underscore == s)
        }
    end
  end

  included do
    attr_reader :rules, :aliased_actions
  end

  def initialize_rules
    @rules = []
    @aliased_actions = { index: :read, show: :read, new: :create, edit: :update }
  end

  # Define a permission rule.
  #
  # Signatures:
  #   can(action, subject, conditions_hash = {})
  #   can(action, subject, &block)
  #   can(action, :all)  # match everything
  #
  def can(action, subjects, *args, &block)
    _add_rule(true, action, subjects, *args, &block)
  end

  # Define a denial rule.
  def cannot(action, subjects, *args, &block)
    _add_rule(false, action, subjects, *args, &block)
  end

  def alias_action(*actions, to:)
    @aliased_actions[to] ||= []
    @aliased_actions[to] += actions.flatten.map(&:to_sym)
  end

  # Mimics CanCan::Ability#with_options
  def with_options(conditions, &block)
    @current_conditions = conditions
    yield self
  ensure
    @current_conditions = nil
  end

  # Check whether a given action+subject is allowed.
  #
  # Signatures (kept compatible with the existing call sites):
  #   can?(action, subject)                # CanCan-style 2-arg
  #   can?(scope, target, action, options)  # custom Permission-style 4-arg
  #
  def can?(*args)
    if args.length == 2
      # CanCan-style: can?(:action, Subject)
      action, subject = args
      _check_can?(action, subject)
    else
      # Fallback: not handled by this compatibility layer
      false
    end
  end

  # Raise when unauthorized.  Supports both CanCan-style and custom-style calls.
  #
  # CanCan-style (used by ckeditor):
  #   authorize!(:show, resource)
  #
  # Custom 4-arg style (used in AbilityApi):
  #   authorize!(:show, resource)
  #
  def authorize!(*args)
    if args.length == 2
      action, subject = args
      _check_can!(action, subject)
      true
    else
      raise Ddt::Error::NoPermissionError, "unauthorized"
    end
  end

  private

  def _expand_actions(actions)
    expanded = []
    Array(actions).flatten.each do |action|
      if @aliased_actions.key?(action)
        expanded += _expand_actions(@aliased_actions[action])
      else
        expanded << action
      end
    end
    expanded.uniq
  end

  def _add_rule(base_behavior, actions, subjects, conditions_hash_or_block = nil, &block)
    subjects = Array(subjects).flatten
    actions  = _expand_actions(Array(actions).flatten)

    match_all = subjects.include?(:all)
    block ||= conditions_hash_or_block if conditions_hash_or_block.is_a?(Proc)
    conditions = conditions_hash_or_block.is_a?(Hash) ? conditions_hash_or_block : {}

    # Merge with any conditions set by with_options
    if @current_conditions.is_a?(Hash)
      conditions = @current_conditions.merge(conditions)
    end

    @rules << Rule.new(
      actions: actions,
      base_behavior: base_behavior,
      conditions: conditions,
      block: block,
      match_all: match_all,
      subjects: subjects
    )
  end

  def _check_can?(action, subject)
    # Walk rules in reverse; last matching rule wins (CanCan semantics)
    @rules.reverse_each do |rule|
      next unless rule.matches_action?(action)
      next unless rule.matches_subject?(subject)

      if rule.block
        return rule.base_behavior if rule.block.call(subject)
      elsif rule.conditions.present?
        return rule.base_behavior if _conditions_match?(rule.conditions, subject)
      else
        return rule.base_behavior
      end
    end
    false
  end

  def _check_can!(action, subject)
    _check_can?(action, subject) || raise(Ddt::Error::NoPermissionError, "unauthorized")
  end

  def _conditions_match?(conditions, subject)
    return true unless subject.is_a?(ActiveRecord::Base) || subject.respond_to?(:attributes)

    conditions.all? do |key, expected|
      actual = subject.respond_to?(key) ? subject.send(key) : nil
      if expected.is_a?(Array)
        expected.include?(actual)
      else
        actual == expected
      end
    end
  end
end
