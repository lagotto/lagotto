class ChangeMetricsDefaultToZero < ActiveRecord::Migration
  def up
    RetrievalStatus.update_all(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0, extra: nil)
    Month.update_all(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0)
    Day.update_all(pdf: 0, html: 0, readers: 0, comments: 0, likes: 0)
    ApiResponse.update_all(pdf: 0, html: 0, total: 0)
  end

  def down

  end
end
