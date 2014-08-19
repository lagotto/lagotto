object @status
cache [@status.articles_count]

attributes :version, :articles_count, :update_date
node(:status) { "OK" }
