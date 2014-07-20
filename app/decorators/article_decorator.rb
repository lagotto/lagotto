class ArticleDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :retrieval_statuses

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def publication_date
    published_on.nil? ? nil : published_on.to_time.utc.iso8601
  end

  def issued
    date_parts = [year, month, day].reject(&:blank?)
    { "date_parts" => date_parts }
  end

  def url
    canonical_url
  end

  def mendeley
    mendeley_uuid
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    { :article_id => id,
      :timestamp => updated_at.to_s(:number),
      :source => context[:source],
      :info => context[:info] }
  end

  def version
    "1.0"
  end

  def type
    "rich"
  end

  def width
    (context[:maxwidth] || 500).to_i
  end

  def height
    (context[:maxheight] || 75).to_i
  end

  def html
    <<-eos
<style type="text/css">
  blockquote.alm {
    display: inline-block;
    padding: 16px;
    margin: 10px 0;
    max-width: 500px;

    border: #ddd 1px solid;
    border-top-color: #eee;
    border-bottom-color: #bbb;
    border-radius: 5px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.15);

    font-family: Helvetica, Arial, sans-serif;
    font-size: 14px;
    font-style: normal;
    line-height: 1;
    color: #000;
  }
  h4.alm { color: #34485e; font-size: 18px; font-weight: 600; margin-top: 0; margin-bottom: 10px; }
  span.alm.signpost {
    border-bottom-left-radius: 0.25em;
    border-bottom-right-radius: 0.25em;
    border-top-left-radius: 0.25em;
    border-top-right-radius: 0.25em;
    color: #FFFFFF;
    display: inline;
    font-size: 75%;
    font-weight: bold;
    padding: 0.2em 0.6em 0.3em;
    text-align: center;
    vertical-align: baseline;
    white-space: nowrap;
  }
  span.alm.viewed { color: #3498db; }
  span.alm.saved { color: #1dbc9c; }
  span.alm.discussed { color: #2ecc71; }
  span.alm.cited { color: #a368bd; }
  p.alm a { text-decoration: none; color: #3498DB; margin-bottom: 10px; }
</style>
<blockquote class="alm">
<h4 class="alm">#{title}</h4>
<p class="alm" data-datetime="#{publication_date}">#{published_on.to_s(:long)}. <a href="#{doi_as_url}">#{doi_as_url}</a></p>
<p class="alm">#{viewed_span} #{discussed_span} #{saved_span} #{cited_span} #{coins}</p>
</blockquote>
    eos
  end

  def coins
    "<span class=\"Z3988\" title=\"ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft_id=info:doi/#{doi_escaped}&amp;rft.genre=article&amp;rft.atitle=#{title_escaped}&amp;rft_date=#{published_on.to_s(:db)}\"></span>"
  end

  def viewed_span
    if model.viewed > 0
      "<span class=\"alm signpost viewed\" data-viewed=\"#{model.viewed}\">Viewed: #{model.viewed}</span>"
    else
      ""
    end
  end

  def discussed_span
    if model.discussed > 0
      "<span class=\"alm signpost discussed\" data-discussed=\"#{model.discussed}\">Discussed: #{model.discussed}</span>"
    else
      ""
    end
  end

  def saved_span
    if model.saved > 0
      "<span class=\"alm signpost saved\" data-saved=\"#{model.saved}\">Saved: #{model.saved}</span>"
    else
      ""
    end
  end

  def cited_span
    if model.cited > 0
      "<span class=\"alm signpost cited\" data-cited=\"#{model.cited}\">Cited: #{model.cited}</span>"
    else
      ""
    end
  end

  def provider_name
    CONFIG[:sitename] || CONFIG[:useragent]
  end

  def provider_url
    "http://#{CONFIG[:hostname]}"
  end

  protected


  # Filter by source parameter, filter out private sources unless staff or admin
  def get_source_ids(source_names)
    if source_names && current_user.try(:is_admin_or_staff?)
      source_ids = Source.where("lower(name) in (?)", source_names.split(",")).order("group_id, sources.display_name").pluck(:id)
    elsif source_names
      source_ids = Source.where("private = ?", false).where("lower(name) in (?)", source_names.split(",")).order("name").pluck(:id)
    elsif current_user.try(:is_admin_or_staff?)
      source_ids = Source.order("group_id, sources.display_name").pluck(:id)
    else
      source_ids = Source.where("private = ?", false).order("group_id, sources.display_name").pluck(:id)
    end
  end
end
