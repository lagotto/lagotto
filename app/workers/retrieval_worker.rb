
class RetrievalWorker < Workling::Base
  def retrieval(options)
    puts "RetrievalWorker: #{options.inspect}"
    article = Article.find(options[:article_id])
    Retriever.new(:lazy => true, :only_source => options[:source],
                  :verbose => options[:verbose]).update(article)
    puts "RetrievalWorker done."
  end
end
