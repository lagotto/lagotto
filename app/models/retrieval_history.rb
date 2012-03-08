class RetrievalHistory < ActiveRecord::Base
  SUCCESS_MSG = "SUCCESS"
  SUCCESS_NODATA_MSG = "SUCCESS WITH NO DATA"
  ERROR_MSG = "ERROR"
  SKIPPED_MSG = "SKIPPED"
  SOURCE_DISABLED = "Source disabled"
  SOURCE_NOT_ACTIVE = "Source not active"
end
