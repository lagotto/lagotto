
class CrossRef < Source
  include SourceHelper
  def uses_username; true; end
  def uses_password; true; end

  def query(article)
    raise(ArgumentError, "Crossref configuration requires username & password") \
      if username.blank? or password.blank?

    url = "http://doi.crossref.org/servlet/getForwardLinks?usr=" + username + "&pwd=" + password + "&doi="

    get_xml(url + CGI.escape(article.doi)) do |document|
      document.root.namespaces.default_prefix = "x"
      citations = []
      document.find("//x:journal_cite").each do |cite|
        citation = {}
        %w[doi journal_title journal_abbreviation article_title volume issue first_page year].each do |a|
          first = cite.find_first("x:#{a}")
          if first
            content = first.content
            citation[a.intern] = content
          end
        end
        if citation[:doi]
          contributors_element = cite.find_first("x:contributors")
          citation[:contributors] = extract_contributors(contributors_element) \
            if contributors_element

          citation[:uri] = DOI::to_url(citation[:doi])
          citations << citation
        end
      end
      citations
    end
  end

protected
  def extract_contributors(contributors_element)
    contributors = []
    contributors_element.find("x:contributor").each do |c|
      surname = c.find_first("x:surname")
      surname = surname.content if surname
      given_name = c.find_first("x:given_name")
      given_name = given_name.content if given_name
      given_name = given_name.split.map { |w| w.first.upcase }.join("") \
        if given_name
      contributor = [surname, given_name].compact.join(" ")
      if c.attributes['first-author'] == 'true'
        contributors.unshift contributor
      else
        contributors << contributor
      end
    end
    contributors.join(", ")
  end
end
