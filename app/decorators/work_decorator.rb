class WorkDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    to_param
  end

  def filtered_sources
    @filtered_sources ||= Source.accessible(context[:role]).pluck(:name)
  end

  def results
    model.metrics.select { |k,v| filtered_sources.include?(k) && v.to_i > 0 }
  end

  def publication_date
    published_on.to_time.utc.iso8601 if published_on.present?
  end

  def publisher_id
    cached_publisher_id(model.publisher_id).name if model.publisher_id.present?
  end

  def work_type_id
    cached_work_type_names[model.work_type_id] if model.work_type.present?
  end

  def registration_agency_id
    cached_registration_agency_names[model.registration_agency_id] if model.registration_agency.present?
  end

  def DOI
    model.doi
  end

  def URL
    model.canonical_url
  end

  def PMID
    model.pmid
  end

  def PMCID
    model.pmcid
  end

  def issued
    model.issued_at.utc.iso8601
  end

  def cache_key
    "work/#{pid}/#{timestamp}"
  end

  def updated
    model.timestamp
  end

  def version
    "1.0"
  end

  def type
    "rich"
  end

  def width
    (context[:maxwidth] || 600).to_i
  end

  def height
    (context[:maxheight] || 100).to_i
  end

  def html
    <<-eos
#{css}
<blockquote class="alm">
<h4 class="alm">#{title}</h4>
<p class="alm" data-datetime="#{publication_date}">#{issued_date}. <a href="#{doi_as_url}">#{doi_as_url}</a></p>
<p class="alm">#{viewed_span} #{discussed_span} #{saved_span} #{cited_span} #{coins}</p>
</blockquote>
    eos
  end

  def css
    <<-eos
<style type="text/css">
  blockquote.alm {
    display: inline-block;
    background-color: #fff;
    padding: 16px;
    margin: 10px 0;
    max-width: 600px;

    border: #ddd 1px solid;
    border-top-color: #eee;
    border-bottom-color: #bbb;
    border-radius: 5px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.15);

    font-family: Helvetica, Arial, sans-serif;
    font-size: 14px;
    font-style: normal;
    font-weight: 400;
    line-height: 1.2;
    color: #000;
  }
  blockquote h4.alm, #content h4 { color: #34485e; font-family: Helvetica, Arial, sans-serif; font-size: 18px; font-weight: 600; line-height: 1.2; margin: 0 0 5px; }
  blockquote span.alm.signpost {
    border-bottom-left-radius: 0.25em;
    border-bottom-right-radius: 0.25em;
    border-top-left-radius: 0.25em;
    border-top-right-radius: 0.25em;
    color: #FFFFFF;
    display: inline;
    font-size: 75%;
    padding: 0.2em 0.6em 0.3em;
    text-align: center;
    vertical-align: baseline;
    white-space: nowrap;
  }
  blockquote span.alm.viewed { background-color: #3498db; }
  blockquote span.alm.saved { background-color: #1dbc9c; }
  blockquote span.alm.discussed { background-color: #2ecc71; }
  blockquote span.alm.cited { background-color: #a368bd; }
  blockquote p.alm { font-size: 14px; font-weight: 400; line-height: 1.1; margin: 0 0 10px; }
  blockquote p.alm a { text-decoration: none; color: #3498DB; }
</style>
    eos
  end

  def coins
    "<span class=\"Z3988\" title=\"ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft_id=info:doi/#{doi_escaped}&amp;rft.genre=work&amp;rft.atitle=#{title_escaped}&amp;rft_date=#{published_on.to_s(:db)}\"></span>"
  end

  def viewed_span
    if result_count('counter_html') > 0
      "<span class=\"alm signpost viewed\" data-viewed=\"#{result_count('counter_html')}\">Viewed: #{result_count('counter_html')}</span>"
    else
      ""
    end
  end

  def discussed_span
    if result_count('twitter') > 0
      "<span class=\"alm signpost discussed\" data-discussed=\"#{result_count('twitter')}\">Discussed: #{result_count('twitter')}</span>"
    else
      ""
    end
  end

  def saved_span
    if result_count('mendeley') > 0
      "<span class=\"alm signpost saved\" data-saved=\"#{result_count('mendeley')}\">Saved: #{result_count('mendeley')}</span>"
    else
      ""
    end
  end

  def cited_span
    if result_count('crossref') > 0
      "<span class=\"alm signpost cited\" data-cited=\"#{result_count('crossref')}\">Cited: #{result_count('crossref')}</span>"
    else
      ""
    end
  end

  def provider_name
    ENV['SITENAME']
  end

  def provider_url
    "http://#{ENV['SERVERNAME']}"
  end
end
