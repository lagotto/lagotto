module Identifiable
  extend ActiveSupport::Concern

  included do
    def doi_from_url(url)
      Array(/^http:\/\/doi\.org\/(.+)/.match(url)).last
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
  end
end
