
class RetrievalWorker < Workling::Base
  def retrieval(options)
    puts "RetrievalWorker: #{options.inspect}"
    article = Article.find(options[:article_id])
    Retriever.new(:only_source => options[:source],
                  :lazy => options[:lazy],
                  :verbose => options[:verbose]).update(article)
    puts "RetrievalWorker done."
  end
end
