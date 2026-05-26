# Stub for Ckeditor::Paginatable (ckeditor gem removed in Phase 6).
# Wraps a collection with page-based pagination.
class Ckeditor::Paginatable
  def initialize(collection)
    @collection = collection
  end

  def page(num = 1)
    current = num.to_i
    per = 24
    offset = (current - 1) * per
    @paginated = @collection.offset(offset).limit(per + 1)
    @has_next = @paginated.size > per
    @paginated = @paginated.limit(per)
    self
  end

  def first_page?
    true
  end

  def next_page
    @has_next ? 2 : nil
  end

  def each(&block)
    @paginated.each(&block)
  end

  delegate :size, to: :@paginated
end
