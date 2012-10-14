unless @article.blank?
  object @article
  
  extends "api/v3/articles/base" 
else
  object false
  
  node(:error) { "Article not found." }
end