
class RetrievalWorker < Workling::Base
  def retrieval(options)
    puts "RetrievalWorker: #{options.inspect}"
    article = Article.find(options[:article_id])
    Retriever::update(article, false, options[:source], true)
    puts "RetrievalWorker done."
  end
end
