class PaginatingDecorator < Draper::CollectionDecorator
  # support for will_paginate
  delegate :current_page, :total_entries, :total_pages, :per_page, :offset
end