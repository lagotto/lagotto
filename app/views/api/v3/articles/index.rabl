unless @articles.blank?
  collection @articles

  extends "api/v3/articles/base" 
else
  object false
  
  node(:error) { "No article found." }
end


