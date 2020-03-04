class DeleteCanonicalUrlJob < ApplicationJob
  queue_as :high

  def perform(source)
    # reset all canonical urls
    Work.update_all(canonical_url: nil)
  end
end
