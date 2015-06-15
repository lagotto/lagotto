# Networking constants
DEFAULT_TIMEOUT = 60
NETWORKABLE_EXCEPTIONS = [Faraday::Error::ClientError,
                          URI::InvalidURIError,
                          Encoding::UndefinedConversionError,
                          ArgumentError,
                          NoMethodError,
                          TypeError]

RESCUABLE_EXCEPTIONS = [ActiveRecord::RecordNotFound,
                        CanCan::AccessDenied,
                        ActionController::ParameterMissing,
                        ActiveModel::ForbiddenAttributesError,
                        NoMethodError]

# Format used for DOI validation
# The prefix is 10.x where x is 4-5 digits. The suffix can be anything, but can"t be left off
DOI_FORMAT = %r(\A10\.\d{4,5}/.+)

# Format used for URL validation
URL_FORMAT = %r(\A(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z)

# Format used for Ark validation
ARK_FORMAT = %r(\Aark:\/[0-9]+\/.+\z)

# Format used for ArXiV validation
ARXIV_FORMAT = %r(\d{4}\.\d{4,5})

# Form queue options
QUEUE_OPTIONS = ["high", "default", "low"]

# Form interval options
INTERVAL_OPTIONS = [["½ hour", 30.minutes],
                    ["1 hour", 1.hour],
                    ["2 hours", 2.hours],
                    ["3 hours", 3.hours],
                    ["6 hours", 6.hours],
                    ["8 hours", 8.hours],
                    ["12 hours", 12.hours],
                    ["24 hours", 24.hours],
                    ["2 days", 48.hours],
                    ["4 days", 96.hours],
                    ["¼ month", (1.month * 0.25).to_i],
                    ["½ month", (1.month * 0.5).to_i],
                    ["1 month", 1.month],
                    ["3 months", 3.months],
                    ["6 months", 6.months],
                    ["12 months", 12.months]]

# CrossRef types from http://api.crossref.org/types
CROSSREF_TYPE_TRANSLATIONS = {
  "proceedings" => nil,
  "reference-book" => nil,
  "journal-issue" => nil,
  "proceedings-article" => "paper-conference",
  "other" => nil,
  "dissertation" => "thesis",
  "dataset" => "dataset",
  "edited-book" => "book",
  "journal-article" => "article-journal",
  "journal" => nil,
  "report" => "report",
  "book-series" => nil,
  "report-series" => nil,
  "book-track" => nil,
  "standard" => nil,
  "book-section" => "chapter",
  "book-part" => nil,
  "book" => "book",
  "book-chapter" => "chapter",
  "standard-series" => nil,
  "monograph" => "book",
  "component" => nil,
  "reference-entry" => "entry-dictionary",
  "journal-volume" => nil,
  "book-set" => nil
}

# DataCite resourceTypeGeneral from DataCite metadata schema: http://dx.doi.org/10.5438/0010
DATACITE_TYPE_TRANSLATIONS = {
  "Audiovisual" => "motion_picture",
  "Collection" => nil,
  "Dataset" => "dataset",
  "Event" => nil,
  "Image" => "graphic",
  "InteractiveResource" => nil,
  "Model" => nil,
  "PhysicalObject" => nil,
  "Service" => nil,
  "Software" => nil,
  "Sound" => "song",
  "Text" => "report",
  "Workflow" => nil,
  "Other" => nil
}

MEDIACURATION_TYPE_TRANSLATIONS = {
  "Blog" => "post",
  "News" => "article-newspaper",
  "Podcast/Video" => "broadcast",
  "Lab website/homepage" => "webpage",
  "University page" => "webpage"
}

# DataCite relationType from DataCite metadata schema: http://dx.doi.org/10.5438/0010
DATACITE_RELATION_TYPE_TRANSLATIONS = {
  "Cites" => "cites",
  "IsCitedBy" => "_cites",
  "Supplements" => "supplements",
  "IsSupplementTo" => "_supplements",
  "Continues" => "continues",
  "IsContinuedBy" => "_continues",
  "IsMetadataFor" => "is_metadata_for",
  "HasMetadata" => "_is_metadata_for",
  "isNewVersionOf" => "is_new_version_of",
  "isPreviousVersionOf" => "_is_new_version_of",
  "IsPartOf" => "is_part_of",
  "HasPart" => "_is_part_of",
  "References" => "references",
  "IsReferencedBy" => "_references",
  "Documents" => "documents",
  "IsDocumentedBy" => "_documents",
  "Compiles" => "compiles",
  "IsCompiledBy" => "_compiles",
  "IsVariantFormOf" => "is_variant_form_of",
  "IsOriginalFormOf" => "_is_variant_form_of",
  "IsIdenticalTo" => "is_identical_to",
  "Reviews" => "reviews",
  "IsReviewedBy" => "_reviews",
  "IsDerivedFrom" => "is_derived_from",
  "IsSourceOf" => "_is_derived_from"
}

TYPES_WITH_TITLE = %w(journal-article
                      proceedings-article
                      dissertation
                      standard
                      report
                      book
                      monograph
                      edited-book
                      reference-book
                      dataset)
