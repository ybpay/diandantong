# Configure Discard to use the existing `deleted_at` column
# (instead of the default `discarded_at`) so that we don't need
# a data migration from the old Paranoia soft-delete setup.
#
# All models that previously used `acts_as_paranoid` will
# include `Discard::Model` and continue to use `deleted_at`.
