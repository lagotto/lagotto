class ArticleDecorator < Draper::Decorator  
  delegate_all
  decorates_finders
  decorates_association :retrieval_statuses
  
  def publication_date
    published_on.nil? ? nil : published_on.to_time.utc.iso8601
  end
  
  def update_date
    updated_at.utc.iso8601
  end
  
  def pmid
    pub_med
  end
  
  def pmcid
    pub_med_central
  end

  def cache_key
    { :article_id => id, 
      :timestamp => updated_at, 
      :source => context[:source],
      :info => context[:info],
      :days => context[:days],
      :months => context[:months],
      :year => context[:year] }
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
<blockquote class="alm well well-small">
<h4 class="alm"><a href="#{doi_as_url}">#{title}</a></h4>
<div class="alm date" data-datetime="#{publication_date}">Published #{published_on.to_s(:long)}</div> 
#{views_span} #{shares_span} #{bookmarks_span} #{citations_span} #{coins}
</blockquote>
    eos
  end
  
  def coins
    "<span class=\"Z3988\" title=\"ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft_id=info:doi/#{CGI.escape(doi)}&amp;rft.genre=article&amp;rft.atitle=#{CGI.escape(title)}&amp;rft_date=#{published_on.to_s(:db)}\"></span>"
  end
  
  def views_span
    if model.views > 0
      "<span class=\"alm label views\" data-views=\"#{model.views}\">#{model.views} Views</span>"
    else
      ""
    end
  end
  
  def shares_span
    if model.shares > 0
      "<span class=\"alm label label-success shares\" data-shares=\"#{model.shares}\">#{model.shares} Social Shares</span>"
    else
      ""
    end
  end
  
  def bookmarks_span
    if model.bookmarks > 0
      "<span class=\"alm label label-info bookmarks\" data-bookmarks=\"#{model.bookmarks}\">#{model.bookmarks} Academic Bookmarks</span>"
    else
      ""
    end
  end
  
  def citations_span
    if model.citations > 0
      "<span class=\"alm label label-inverse citations\" data-citations=\"#{model.citations}\">#{model.citations} Citations</span>"
    else
      ""
    end
  end
  
  def provider_name
    APP_CONFIG['useragent']
  end
  
  def provider_url
    APP_CONFIG['hostname']
  end 
end