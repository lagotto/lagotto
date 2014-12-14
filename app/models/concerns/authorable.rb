module Authorable
  extend ActiveSupport::Concern

  included do
    # parse author string into CSL format
    def get_one_author(author, sep = " ", reversed = false)
      return "" if author.blank?

      name_parts = author.split(sep)
      if reversed
        family = name_parts.first
        given = name_parts.length > 1 ? name_parts[1..-1].join(" ") : ""
      else
        family = name_parts.last
        given = name_parts.length > 1 ? name_parts[0..-2].join(" ") : ""
      end

      { "family" => String(family).titleize,
        "given" => String(given).titleize }
    end

    # parse array of author strings into CSL format
    def get_authors(authors, sep = " ", reversed = false)
      authors.map { |author| get_one_author(author, sep, reversed) }
    end
  end
end
