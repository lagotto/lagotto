class ApiSnapshotJob < ApplicationJob
  queue_as :high

  def perform(options={})
    id = options[:id] || raise(ArgumentError, "Must supply :id")
    upload_on_finished = options[:upload_on_finished]

    api_snapshot = ApiSnapshot.find_by_id!(options[:id])
    api_snapshot.snapshot!

    if !api_snapshot.finished?
      api_snapshot.update_attributes!(
        start_page: api_snapshot.pageno + 1,
        mode: ApiSnapshot::APPEND_MODE
      )
      ApiSnapshotJob.perform_later(id: api_snapshot.id)
    elsif upload_on_finished
      ApiSnapshotUtility.zip(api_snapshot)
      ApiSnapshotUtility.export_to_zenodo(api_snapshot)
    end
  rescue Exception => ex
    Alert.create(exception: ex, details: options.inspect)
  end

end
