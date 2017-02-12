module Identifiable
  extend ActiveSupport::Concern

  included do
    def doi_from_url(url)
      if /(http|https):\/\/(dx\.)?doi\.org\/(\w+)/.match(url)
        uri = Addressable::URI.parse(url)
        uri.path[1..-1].upcase
      elsif id.is_a?(String) && id.starts_with?("doi:")
        id[4..-1].upcase
      end
    end

    def orcid_from_url(url)
      Array(/\Ahttp:\/\/orcid\.org\/(.+)/.match(url)).last
    end

    def validate_orcid(orcid)
      Array(/\A(?:http:\/\/orcid\.org\/)?(\d{4}-\d{4}-\d{4}-\d{3}[0-9X]+)\z/.match(orcid)).last
    end

    def github_from_url(url)
      return {} unless /\Ahttps:\/\/github\.com\/(.+)(?:\/)?(.+)?(?:\/tree\/)?(.*)\z/.match(url)
      words = URI.parse(url).path[1..-1].split('/')

      { owner: words[0],
        repo: words[1],
        release: words[3] }.compact
    end

    def github_repo_from_url(url)
      github_from_url(url).fetch(:repo, nil)
    end

    def github_release_from_url(url)
      github_from_url(url).fetch(:release, nil)
    end

    def github_owner_from_url(url)
      github_from_url(url).fetch(:owner, nil)
    end

    def doi_as_url(doi)
      Addressable::URI.encode("https://doi.org/#{clean_doi(doi)}") if doi.present?
    end

    def pmid_as_url(pmid)
      "http://www.ncbi.nlm.nih.gov/pubmed/#{pmid}" if pmid.present?
    end

    def pmcid_as_url(pmcid)
      "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC#{pmcid}" if pmcid.present?
    end

    def ark_as_url(ark)
      "http://n2t.net/#{ark}" if ark.present?
    end

    def arxiv_as_url(arxiv)
      "http://arxiv.org/abs/#{arxiv}" if arxiv.present?
    end

    def dataone_as_url(dataone)
      "https://cn.dataone.org/cn/v1/resolve/#{dataone}" if dataone.present?
    end

    def orcid_as_url(orcid)
      "http://orcid.org/#{orcid}" if orcid.present?
    end

    def github_as_owner_url(github_hash)
      "https://github.com/#{github_hash[:owner]}" if github_hash[:owner].present?
    end

    def github_as_repo_url(github_hash)
      "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}" if github_hash[:repo].present?
    end

    def github_as_release_url(github_hash)
      "https://github.com/#{github_hash[:owner]}/#{github_hash[:repo]}/tree/#{github_hash[:release]}" if github_hash[:release].present?
    end
  end
end
