module Authorable
  extend ActiveSupport::Concern

  require "namae"

  included do
    # parse author string into CSL format
    def get_one_author(author, options = { sep: " " })
      return "" if author.blank?

      name_parts = author.split(options[:sep])
      if options[:reversed]
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
    def get_authors(authors, options = { sep: " " })
      Array(authors).map { |author| get_one_author(author, options) }
    end

    # parse array of author hashes into CSL format
    def get_hashed_authors(authors)
      Array(authors).map { |author| get_one_hashed_author(author) }
    end

    def get_one_hashed_author(author)
      raw_name = author.fetch("creatorName", nil)
      names = Namae.parse(raw_name)
      if names.present?
        name = names.first
        orcid = get_name_identifier(author)

        { "family" => name.family,
          "given" => name.given,
          "ORCID" => orcid }.compact
      else
        { "literal" => raw_name }
      end
    end

    def get_name_identifier(author)
      name_identifier = author.fetch("nameIdentifier", nil)
      name_identifier_scheme = author.fetch("nameIdentifierScheme", "orcid").downcase
      if name_identifier.present? && name_identifier_scheme == "orcid"
        "http://orcid.org/#{name_identifier}"
      else
        nil
      end
    end
  end
end
