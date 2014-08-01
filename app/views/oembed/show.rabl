object @article => :oembed
cache ['oembed', @article.oembed_key]

attributes :type, :version, :width, :height, :provider_name, :provider_url, :title, :html
attribute :doi_as_url => :url
