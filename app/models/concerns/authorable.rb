module Authorable
  extend ActiveSupport::Concern

  require "namae"

  included do
    # parse author string into CSL format
    def get_one_author(author, options={})
      return "" if author.blank?

      author = author.split(" ").reverse.join(" ") if options[:reversed]

      names = Namae.parse(author)
      if names.present?
        name = names.first

        { "family" => name.family,
          "given" => name.given }.compact
      else
        { "literal" => author }
      end
    end

    # parse array of author strings into CSL format
    def get_authors(authors, options={})
      Array(authors).map { |author| get_one_author(author, options) }
    end

    # parse array of author hashes into CSL format
    def get_hashed_authors(authors)
      Array(authors).map { |author| get_one_hashed_author(author) }
    end

    def get_one_hashed_author(author)
      raw_name = author.fetch("creatorName", nil)

      author_hsh = get_one_author(raw_name)
      author_hsh["ORCID"] = get_name_identifier(author)
      author_hsh.compact
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
