module Identifiable
  extend ActiveSupport::Concern

  included do
    def doi_from_url(url)
      if /(http|https):\/\/(dx\.)?doi\.org\/(\w+)/.match(url)
        uri = Addressable::URI.parse(url)
        uri.path[1..-1].upcase
      elsif id.starts_with?("doi:")
        id[4..-1].upcase
      end
    end

    def orcid_from_url(url)
      Array(/^http:\/\/orcid\.org\/(.+)/.match(url)).last
    end

    def github_repo(url)
      Array(/^https:\/\/github\.com\/(.+)\/(.+)/.match(url)).last
    end

    def github_release(url)
      Array(/^https:\/\/github\.com\/(.+)\/(.+)\/tree\/(.+)/.match(url)).last
    end

    def github_owner(url)
      Array(/^https:\/\/github\.com\/(.+)/.match(url)).last
    end

    def doi_as_url(doi)
      Addressable::URI.encode("http://doi.org/#{clean_doi(doi)}") if doi.present?
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
  end
end
