module Authorable
  extend ActiveSupport::Concern

  require "namae"

  included do
    # parse author string into CSL format
    # only assume personal name when using sort-order: "Turing, Alan"
    def get_one_author(author, options = {})
      return { "literal" => "" } if author.strip.blank?

      author = cleanup_author(author)
      names = Namae.parse(author)

      if names.blank? || is_personal_name?(author).blank?
        { "literal" => author }
      else
        name = names.first

        { "family" => name.family,
          "given" => name.given }.compact
      end
    end

    def cleanup_author(author)
      # detect pattern "Smith J.", but not "Smith, John K."
      author = author.gsub(/[[:space:]]([A-Z]\.)?(-?[A-Z]\.)$/, ', \1\2') unless author.include?(",")

      # titleize strings
      # remove non-standard space characters
      author.my_titleize
            .gsub(/[[:space:]]/, ' ')
    end

    def is_personal_name?(author)
      return true if author.include?(",")

      # lookup given name
      ::NameDetector.name_exists?(author.split.first)
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
      if name_identifier_scheme == "orcid" && name_identifier = validate_orcid(name_identifier)
        "http://orcid.org/#{name_identifier}"
      else
        nil
      end
    end
  end
end
