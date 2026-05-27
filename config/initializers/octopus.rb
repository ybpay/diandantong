# frozen_string_literal: true

# ar-octopus has been removed in the PostgreSQL migration.
# This file is intentionally left empty to prevent load errors
# if any code references Octopus constants.
#
# All database connections now go through the standard Rails
# database.yml configuration with PostgreSQL as the sole adapter.
#
# For read replicas and multi-database support in Rails 6+,
# use the built-in Rails multiple database feature:
#   https://guides.rubyonrails.org/active_record_multiple_databases.html

module Octopus
  def self.enabled?
    false
  end

  def self.using(*args)
    yield if block_given?
  end

  def self.config
    {}
  end
end
