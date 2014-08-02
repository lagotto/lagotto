object false

node(:error) { @error }
unless @article.blank?
  node(:article) { @article }
end
