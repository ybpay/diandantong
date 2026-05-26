# Transitional concern that bridges Paranoia → Discard.
#
# Provides backward-compatible class methods (`with_deleted`, `only_deleted`)
# so that existing code continues to work while models switch from
# `acts_as_paranoid` to `discard`.
#
# Usage in models:
#   include Ddt::SoftDeletable   # instead of acts_as_paranoid
#
module Ddt::SoftDeletable
  extend ActiveSupport::Concern

  included do
    include Discard::Model

    # Discard defaults to `discarded_at`, but our DB uses `deleted_at`.
    self.discard_column = :deleted_at

    # Paranoia-compatible: exclude discarded records by default
    default_scope { kept }

    # Paranoia-compatible scopes
    scope :with_deleted, -> { unscope(where: :deleted_at) }
    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
  end
end
