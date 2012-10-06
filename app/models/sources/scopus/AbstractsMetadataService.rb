require 'xsd/qname'

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CacheInfoType
#   absMetCache - AbsMetCacheType
#   timeToken - (any)
class CacheInfoType
  attr_accessor :absMetCache
  attr_accessor :timeToken

  def initialize(absMetCache = nil, timeToken = nil)
    @absMetCache = absMetCache
    @timeToken = timeToken
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetPublishersReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
class GetPublishersReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil)
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetPublishersType
#   getPublishersReqPayload - GetPublishersReqPayloadType
class GetPublishersType
  attr_accessor :getPublishersReqPayload

  def initialize(getPublishersReqPayload = nil)
    @getPublishersReqPayload = getPublishersReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}PublisherType
#   collectionList - CollectionListType
#   pubId - (any)
#   publisherName - (any)
#   logoURL - (any)
#   sortName - (any)
#   dbName - (any)
class PublisherType
  attr_accessor :collectionList
  attr_accessor :pubId
  attr_accessor :publisherName
  attr_accessor :logoURL
  attr_accessor :sortName
  attr_accessor :dbName

  def initialize(collectionList = nil, pubId = nil, publisherName = nil, logoURL = nil, sortName = nil, dbName = nil)
    @collectionList = collectionList
    @pubId = pubId
    @publisherName = publisherName
    @logoURL = logoURL
    @sortName = sortName
    @dbName = dbName
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}PublisherListType
class PublisherListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetPublishersRspPayloadType
#   cacheInfo - CacheInfoType
#   publisherList - PublisherListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetPublishersRspPayloadType
  attr_accessor :cacheInfo
  attr_accessor :publisherList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(cacheInfo = nil, publisherList = nil, stringBlob = nil, dataResponseStyle = nil)
    @cacheInfo = cacheInfo
    @publisherList = publisherList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetPublishersResponseType
#   status - MetaDataStatusType
#   getPublishersRspPayload - GetPublishersRspPayloadType
class GetPublishersResponseType
  attr_accessor :status
  attr_accessor :getPublishersRspPayload

  def initialize(status = nil, getPublishersRspPayload = nil)
    @status = status
    @getPublishersRspPayload = getPublishersRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceMetadataReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
#   chunkingInfo - RequestChunkType
#   smi - (any)
#   dbName - (any)
#   abstractsId - (any)
#   suppressDbItems - (any)
#   suppressSubjectAreaList - (any)
class GetSourceMetadataReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle
  attr_accessor :chunkingInfo
  attr_accessor :smi
  attr_accessor :dbName
  attr_accessor :abstractsId
  attr_accessor :suppressDbItems
  attr_accessor :suppressSubjectAreaList

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil, chunkingInfo = nil, smi = [], dbName = [], abstractsId = [], suppressDbItems = nil, suppressSubjectAreaList = nil)
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
    @chunkingInfo = chunkingInfo
    @smi = smi
    @dbName = dbName
    @abstractsId = abstractsId
    @suppressDbItems = suppressDbItems
    @suppressSubjectAreaList = suppressSubjectAreaList
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceMetadataType
#   getSourceMetadataReqPayload - GetSourceMetadataReqPayloadType
class GetSourceMetadataType
  attr_accessor :getSourceMetadataReqPayload

  def initialize(getSourceMetadataReqPayload = nil)
    @getSourceMetadataReqPayload = getSourceMetadataReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceMetadataRspPayloadType
#   cacheInfo - CacheInfoType
#   metricsTimestamp - SOAP::SOAPString
#   abstractsList - AbstractsListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
#   chunkingInfo - ResponseChunkType
class GetSourceMetadataRspPayloadType
  attr_accessor :cacheInfo
  attr_accessor :metricsTimestamp
  attr_accessor :abstractsList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle
  attr_accessor :chunkingInfo

  def initialize(cacheInfo = nil, metricsTimestamp = nil, abstractsList = nil, stringBlob = nil, dataResponseStyle = nil, chunkingInfo = nil)
    @cacheInfo = cacheInfo
    @metricsTimestamp = metricsTimestamp
    @abstractsList = abstractsList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
    @chunkingInfo = chunkingInfo
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceMetadataResponseType
#   status - MetaDataStatusType
#   getSourceMetadataRspPayload - GetSourceMetadataRspPayloadType
class GetSourceMetadataResponseType
  attr_accessor :status
  attr_accessor :getSourceMetadataRspPayload

  def initialize(status = nil, getSourceMetadataRspPayload = nil)
    @status = status
    @getSourceMetadataRspPayload = getSourceMetadataRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}AbstractsListType
class AbstractsListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}AbstractsType
#   collectionList - CollectionListType
#   abstractsId - (any)
#   gid - (any)
#   displayName - (any)
#   variantName - (any)
#   dbItem - DbItemType
#   sourceType - (any)
#   smi - (any)
#   sortName - (any)
#   sortNumber - (any)
#   issn - (any)
#   eissn - (any)
#   isbn - ISBNWrapperType
#   coden - (any)
#   publisherName - (any)
#   abbrevTitle - (any)
#   subjectAreaList - SubjectAreaListType
#   relationship - RelationshipType
#   active - (any)
#   metricList - MetricListType
#   aipCount - (any)
#   coverageRange - CoverageRangeType
class AbstractsType
  attr_accessor :collectionList
  attr_accessor :abstractsId
  attr_accessor :gid
  attr_accessor :displayName
  attr_accessor :variantName
  attr_accessor :dbItem
  attr_accessor :sourceType
  attr_accessor :smi
  attr_accessor :sortName
  attr_accessor :sortNumber
  attr_accessor :issn
  attr_accessor :eissn
  attr_accessor :isbn
  attr_accessor :coden
  attr_accessor :publisherName
  attr_accessor :abbrevTitle
  attr_accessor :subjectAreaList
  attr_accessor :relationship
  attr_accessor :active
  attr_accessor :metricList
  attr_accessor :aipCount
  attr_accessor :coverageRange

  def initialize(collectionList = nil, abstractsId = nil, gid = nil, displayName = nil, variantName = [], dbItem = [], sourceType = nil, smi = nil, sortName = nil, sortNumber = nil, issn = [], eissn = [], isbn = [], coden = nil, publisherName = nil, abbrevTitle = nil, subjectAreaList = nil, relationship = [], active = nil, metricList = nil, aipCount = nil, coverageRange = [])
    @collectionList = collectionList
    @abstractsId = abstractsId
    @gid = gid
    @displayName = displayName
    @variantName = variantName
    @dbItem = dbItem
    @sourceType = sourceType
    @smi = smi
    @sortName = sortName
    @sortNumber = sortNumber
    @issn = issn
    @eissn = eissn
    @isbn = isbn
    @coden = coden
    @publisherName = publisherName
    @abbrevTitle = abbrevTitle
    @subjectAreaList = subjectAreaList
    @relationship = relationship
    @active = active
    @metricList = metricList
    @aipCount = aipCount
    @coverageRange = coverageRange
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CoverageRangeType
#   coverageStartYear - (any)
#   coverageEndYear - (any)
class CoverageRangeType
  attr_accessor :coverageStartYear
  attr_accessor :coverageEndYear

  def initialize(coverageStartYear = nil, coverageEndYear = nil)
    @coverageStartYear = coverageStartYear
    @coverageEndYear = coverageEndYear
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}ISBNWrapperType
#   isbn - (any)
#   length - (any)
class ISBNWrapperType
  attr_accessor :isbn
  attr_accessor :length

  def initialize(isbn = nil, length = nil)
    @isbn = isbn
    @length = length
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}MetricListType
class MetricListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}MetricType
#   name - SOAP::SOAPString
#   year - SOAP::SOAPString
#   value - SOAP::SOAPString
class MetricType
  attr_accessor :name
  attr_accessor :year
  attr_accessor :value

  def initialize(name = nil, year = nil, value = nil)
    @name = name
    @year = year
    @value = value
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}RelationshipType
#   sourceId - SOAP::SOAPString
#   relationshipStatus - SOAP::SOAPString
#   relationshipType - SOAP::SOAPString
class RelationshipType
  attr_accessor :sourceId
  attr_accessor :relationshipStatus
  attr_accessor :relationshipType

  def initialize(sourceId = [], relationshipStatus = nil, relationshipType = nil)
    @sourceId = sourceId
    @relationshipStatus = relationshipStatus
    @relationshipType = relationshipType
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SubjectAreaListType
class SubjectAreaListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SubjectAreaType
#   displayName - (any)
#   subjectCode - (any)
class SubjectAreaType
  attr_accessor :displayName
  attr_accessor :subjectCode

  def initialize(displayName = nil, subjectCode = nil)
    @displayName = displayName
    @subjectCode = subjectCode
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetDbMetadataReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
#   smi - (any)
#   dbName - (any)
class GetDbMetadataReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle
  attr_accessor :smi
  attr_accessor :dbName

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil, smi = [], dbName = [])
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
    @smi = smi
    @dbName = dbName
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetDbMetadataType
#   getDbMetadataReqPayload - GetDbMetadataReqPayloadType
class GetDbMetadataType
  attr_accessor :getDbMetadataReqPayload

  def initialize(getDbMetadataReqPayload = nil)
    @getDbMetadataReqPayload = getDbMetadataReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetDbMetadataRspPayloadType
#   cacheInfo - CacheInfoType
#   dbInfoList - DbInfoListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetDbMetadataRspPayloadType
  attr_accessor :cacheInfo
  attr_accessor :dbInfoList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(cacheInfo = nil, dbInfoList = nil, stringBlob = nil, dataResponseStyle = nil)
    @cacheInfo = cacheInfo
    @dbInfoList = dbInfoList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetDbMetadataResponseType
#   status - MetaDataStatusType
#   getDbMetadataRspPayload - GetDbMetadataRspPayloadType
class GetDbMetadataResponseType
  attr_accessor :status
  attr_accessor :getDbMetadataRspPayload

  def initialize(status = nil, getDbMetadataRspPayload = nil)
    @status = status
    @getDbMetadataRspPayload = getDbMetadataRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}DbInfoListType
class DbInfoListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}DbInfoType
#   collectionList - CollectionListType
#   dbItem - DbItemType
#   smi - (any)
#   sortName - (any)
#   sortNumber - (any)
#   publisherName - (any)
class DbInfoType
  attr_accessor :collectionList
  attr_accessor :dbItem
  attr_accessor :smi
  attr_accessor :sortName
  attr_accessor :sortNumber
  attr_accessor :publisherName

  def initialize(collectionList = nil, dbItem = nil, smi = nil, sortName = nil, sortNumber = nil, publisherName = nil)
    @collectionList = collectionList
    @dbItem = dbItem
    @smi = smi
    @sortName = sortName
    @sortNumber = sortNumber
    @publisherName = publisherName
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetLinkDataReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
#   inputKey - InputKeyType
class GetLinkDataReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle
  attr_accessor :inputKey

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil, inputKey = [])
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
    @inputKey = inputKey
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetLinkDataType
#   getLinkDataReqPayload - GetLinkDataReqPayloadType
class GetLinkDataType
  attr_accessor :getLinkDataReqPayload

  def initialize(getLinkDataReqPayload = nil)
    @getLinkDataReqPayload = getLinkDataReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetLinkDataRspPayloadType
#   citedLinkDataList - CitedLinkDataListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetLinkDataRspPayloadType
  attr_accessor :citedLinkDataList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(citedLinkDataList = nil, stringBlob = nil, dataResponseStyle = nil)
    @citedLinkDataList = citedLinkDataList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CitedLinkDataListType
class CitedLinkDataListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CitedLinkDataType
#   linkData - LinkDataType
#   recordType - SOAP::SOAPString
#   citedByCount - SOAP::SOAPDecimal
class CitedLinkDataType
  attr_accessor :linkData
  attr_accessor :recordType
  attr_accessor :citedByCount

  def initialize(linkData = nil, recordType = nil, citedByCount = nil)
    @linkData = linkData
    @recordType = recordType
    @citedByCount = citedByCount
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}LinkDataType
#   collectionList - CollectionListType
#   inputKey - InputKeyType
#   eid - (any)
#   doi - (any)
#   uoi - (any)
#   pii - (any)
#   refKey - RefKeyType
#   ivip - IVIPType
#   dbname - (any)
class LinkDataType
  attr_accessor :collectionList
  attr_accessor :inputKey
  attr_accessor :eid
  attr_accessor :doi
  attr_accessor :uoi
  attr_accessor :pii
  attr_accessor :refKey
  attr_accessor :ivip
  attr_accessor :dbname

  def initialize(collectionList = nil, inputKey = nil, eid = nil, doi = nil, uoi = nil, pii = nil, refKey = nil, ivip = nil, dbname = nil)
    @collectionList = collectionList
    @inputKey = inputKey
    @eid = eid
    @doi = doi
    @uoi = uoi
    @pii = pii
    @refKey = refKey
    @ivip = ivip
    @dbname = dbname
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}DbItemType
#   dbName - (any)
#   dbUrl - (any)
#   coverageRange - CoverageRangeType
class DbItemType
  attr_accessor :dbName
  attr_accessor :dbUrl
  attr_accessor :coverageRange

  def initialize(dbName = nil, dbUrl = nil, coverageRange = [])
    @dbName = dbName
    @dbUrl = dbUrl
    @coverageRange = coverageRange
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetLinkDataResponseType
#   status - MetaDataStatusType
#   getLinkDataRspPayload - GetLinkDataRspPayloadType
class GetLinkDataResponseType
  attr_accessor :status
  attr_accessor :getLinkDataRspPayload

  def initialize(status = nil, getLinkDataRspPayload = nil)
    @status = status
    @getLinkDataRspPayload = getLinkDataRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetCitedByCountType
#   getCitedByCountReqPayload - GetLinkDataReqPayloadType
class GetCitedByCountType
  attr_accessor :getCitedByCountReqPayload

  def initialize(getCitedByCountReqPayload = nil)
    @getCitedByCountReqPayload = getCitedByCountReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetCitedByCountRspPayloadType
#   citedByCountList - CitedByCountListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetCitedByCountRspPayloadType
  attr_accessor :citedByCountList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(citedByCountList = nil, stringBlob = nil, dataResponseStyle = nil)
    @citedByCountList = citedByCountList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CitedByCountListType
class CitedByCountListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CitedByCountType
#   inputKey - InputKeyType
#   linkData - CitedByCountItemType
class CitedByCountType
  attr_accessor :inputKey
  attr_accessor :linkData

  def initialize(inputKey = nil, linkData = [])
    @inputKey = inputKey
    @linkData = linkData
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}CitedByCountItemType
#   eid - (any)
#   scopusID - (any)
#   citedByCount - SOAP::SOAPDecimal
class CitedByCountItemType
  attr_accessor :eid
  attr_accessor :scopusID
  attr_accessor :citedByCount

  def initialize(eid = nil, scopusID = nil, citedByCount = nil)
    @eid = eid
    @scopusID = scopusID
    @citedByCount = citedByCount
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetCitedByCountResponseType
#   status - MetaDataStatusType
#   getCitedByCountRspPayload - GetCitedByCountRspPayloadType
class GetCitedByCountResponseType
  attr_accessor :status
  attr_accessor :getCitedByCountRspPayload

  def initialize(status = nil, getCitedByCountRspPayload = nil)
    @status = status
    @getCitedByCountRspPayload = getCitedByCountRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}TopicListType
class TopicListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetTopicsRspPayloadType
#   cacheInfo - CacheInfoType
#   topicList - TopicListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetTopicsRspPayloadType
  attr_accessor :cacheInfo
  attr_accessor :topicList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(cacheInfo = nil, topicList = nil, stringBlob = nil, dataResponseStyle = nil)
    @cacheInfo = cacheInfo
    @topicList = topicList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}TopicType
#   collectionList - CollectionListType
#   topicId - (any)
#   topicName - (any)
class TopicType
  attr_accessor :collectionList
  attr_accessor :topicId
  attr_accessor :topicName

  def initialize(collectionList = nil, topicId = nil, topicName = nil)
    @collectionList = collectionList
    @topicId = topicId
    @topicName = topicName
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetTopicsReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
class GetTopicsReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil)
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetTopicsType
#   getTopicsReqPayload - GetTopicsReqPayloadType
class GetTopicsType
  attr_accessor :getTopicsReqPayload

  def initialize(getTopicsReqPayload = nil)
    @getTopicsReqPayload = getTopicsReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetTopicsResponseType
#   status - MetaDataStatusType
#   getTopicsRspPayload - GetTopicsRspPayloadType
class GetTopicsResponseType
  attr_accessor :status
  attr_accessor :getTopicsRspPayload

  def initialize(status = nil, getTopicsRspPayload = nil)
    @status = status
    @getTopicsRspPayload = getTopicsRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IsCacheCurrentReqPayloadType
#   cacheInfo - CacheInfoType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
class IsCacheCurrentReqPayloadType
  attr_accessor :cacheInfo
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle

  def initialize(cacheInfo = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil)
    @cacheInfo = cacheInfo
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IsCacheCurrentType
#   isCacheCurrentReqPayload - IsCacheCurrentReqPayloadType
class IsCacheCurrentType
  attr_accessor :isCacheCurrentReqPayload

  def initialize(isCacheCurrentReqPayload = nil)
    @isCacheCurrentReqPayload = isCacheCurrentReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IsCacheCurrentRspPayloadType
#   cacheCurrentFlag - (any)
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class IsCacheCurrentRspPayloadType
  attr_accessor :cacheCurrentFlag
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(cacheCurrentFlag = nil, stringBlob = nil, dataResponseStyle = nil)
    @cacheCurrentFlag = cacheCurrentFlag
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IsCacheCurrentResponseType
#   status - MetaDataStatusType
#   isCacheCurrentRspPayload - IsCacheCurrentRspPayloadType
class IsCacheCurrentResponseType
  attr_accessor :status
  attr_accessor :isCacheCurrentRspPayload

  def initialize(status = nil, isCacheCurrentRspPayload = nil)
    @status = status
    @isCacheCurrentRspPayload = isCacheCurrentRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceInfoRspPayloadType
#   cacheInfo - CacheInfoType
#   metricsTimestamp - SOAP::SOAPString
#   sourceInfoList - SourceInfoListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetSourceInfoRspPayloadType
  attr_accessor :cacheInfo
  attr_accessor :metricsTimestamp
  attr_accessor :sourceInfoList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(cacheInfo = nil, metricsTimestamp = nil, sourceInfoList = nil, stringBlob = nil, dataResponseStyle = nil)
    @cacheInfo = cacheInfo
    @metricsTimestamp = metricsTimestamp
    @sourceInfoList = sourceInfoList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SourceInfoListType
class SourceInfoListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SourceInfoType
#   abstracts - AbstractsType
#   noDisplay - NoDisplayType
#   issueInfoList - IssueInfoListType
class SourceInfoType
  attr_accessor :abstracts
  attr_accessor :noDisplay
  attr_accessor :issueInfoList

  def initialize(abstracts = nil, noDisplay = nil, issueInfoList = nil)
    @abstracts = abstracts
    @noDisplay = noDisplay
    @issueInfoList = issueInfoList
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}VolumePairType
#   volumeFirst - (any)
#   volumeLast - (any)
class VolumePairType
  attr_accessor :volumeFirst
  attr_accessor :volumeLast

  def initialize(volumeFirst = nil, volumeLast = nil)
    @volumeFirst = volumeFirst
    @volumeLast = volumeLast
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IssueInfoListType
class IssueInfoListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IssueInfoType
#   issueFirst - SOAP::SOAPString
#   issueLast - SOAP::SOAPString
#   volume - VolumePairType
#   sortDate - SOAP::SOAPString
#   dbItem - DbItemType
class IssueInfoType
  attr_accessor :issueFirst
  attr_accessor :issueLast
  attr_accessor :volume
  attr_accessor :sortDate
  attr_accessor :dbItem

  def initialize(issueFirst = nil, issueLast = nil, volume = nil, sortDate = nil, dbItem = [])
    @issueFirst = issueFirst
    @issueLast = issueLast
    @volume = volume
    @sortDate = sortDate
    @dbItem = dbItem
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceInfoResponseType
#   status - MetaDataStatusType
#   getSourceInfoRspPayload - GetSourceInfoRspPayloadType
class GetSourceInfoResponseType
  attr_accessor :status
  attr_accessor :getSourceInfoRspPayload

  def initialize(status = nil, getSourceInfoRspPayload = nil)
    @status = status
    @getSourceInfoRspPayload = getSourceInfoRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceInfoType
#   getSourceInfoReqPayload - GetSourceInfoReqPayloadType
class GetSourceInfoType
  attr_accessor :getSourceInfoReqPayload

  def initialize(getSourceInfoReqPayload = nil)
    @getSourceInfoReqPayload = getSourceInfoReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceInfoReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
#   abstractsId - (any)
#   suppressAIP - (any)
#   suppressDbItems - (any)
#   suppressSubjectAreaList - (any)
#   coverageRange - CoverageRangeType
class GetSourceInfoReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle
  attr_accessor :abstractsId
  attr_accessor :suppressAIP
  attr_accessor :suppressDbItems
  attr_accessor :suppressSubjectAreaList
  attr_accessor :coverageRange

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil, abstractsId = [], suppressAIP = nil, suppressDbItems = nil, suppressSubjectAreaList = nil, coverageRange = nil)
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
    @abstractsId = abstractsId
    @suppressAIP = suppressAIP
    @suppressDbItems = suppressDbItems
    @suppressSubjectAreaList = suppressSubjectAreaList
    @coverageRange = coverageRange
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetIDsRequestType
#   getIDsRequestPayload - GetIDsRequestPayloadType
class GetIDsRequestType
  attr_accessor :getIDsRequestPayload

  def initialize(getIDsRequestPayload = nil)
    @getIDsRequestPayload = getIDsRequestPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetIDsRequestPayloadType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
#   keys - KeyType
class GetIDsRequestPayloadType
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle
  attr_accessor :keys

  def initialize(responseStyle = nil, dataResponseStyle = nil, keys = [])
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
    @keys = keys
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}KeyType
#   clientCRF - (any)
#   bibkeys - (any)
class KeyType
  attr_accessor :clientCRF
  attr_accessor :bibkeys

  def initialize(clientCRF = nil, bibkeys = nil)
    @clientCRF = clientCRF
    @bibkeys = bibkeys
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetIDsResponseType
#   status - MetaDataStatusType
#   getIDsResponsePayload - GetIDsResponsePayloadType
class GetIDsResponseType
  attr_accessor :status
  attr_accessor :getIDsResponsePayload

  def initialize(status = nil, getIDsResponsePayload = nil)
    @status = status
    @getIDsResponsePayload = getIDsResponsePayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetIDsResponsePayloadType
#   dataResponseStyle - DataResponseType
#   stringBlob - (any)
#   iDList - IDListType
class GetIDsResponsePayloadType
  attr_accessor :dataResponseStyle
  attr_accessor :stringBlob
  attr_accessor :iDList

  def initialize(dataResponseStyle = nil, stringBlob = nil, iDList = nil)
    @dataResponseStyle = dataResponseStyle
    @stringBlob = stringBlob
    @iDList = iDList
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IDListType
class IDListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}IDItemType
#   inputKey - KeyType
#   scopusID - (any)
class IDItemType
  attr_accessor :inputKey
  attr_accessor :scopusID

  def initialize(inputKey = nil, scopusID = [])
    @inputKey = inputKey
    @scopusID = scopusID
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceYearInfoRspPayloadType
#   cacheInfo - CacheInfoType
#   updatedDate - SOAP::SOAPString
#   metricsTimestamp - SOAP::SOAPString
#   sourceYearInfoList - SourceYearInfoListType
#   stringBlob - (any)
#   dataResponseStyle - DataResponseType
class GetSourceYearInfoRspPayloadType
  attr_accessor :cacheInfo
  attr_accessor :updatedDate
  attr_accessor :metricsTimestamp
  attr_accessor :sourceYearInfoList
  attr_accessor :stringBlob
  attr_accessor :dataResponseStyle

  def initialize(cacheInfo = nil, updatedDate = nil, metricsTimestamp = nil, sourceYearInfoList = nil, stringBlob = nil, dataResponseStyle = nil)
    @cacheInfo = cacheInfo
    @updatedDate = updatedDate
    @metricsTimestamp = metricsTimestamp
    @sourceYearInfoList = sourceYearInfoList
    @stringBlob = stringBlob
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SourceYearInfoListType
class SourceYearInfoListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SourceYearInfoType
#   abstractsId - (any)
#   displayName - (any)
#   sourceType - (any)
#   issn - (any)
#   publisherName - (any)
#   metricList - MetricListType
#   coverageRange - CoverageRangeType
#   yearInfoList - YearInfoListType
class SourceYearInfoType
  attr_accessor :abstractsId
  attr_accessor :displayName
  attr_accessor :sourceType
  attr_accessor :issn
  attr_accessor :publisherName
  attr_accessor :metricList
  attr_accessor :coverageRange
  attr_accessor :yearInfoList

  def initialize(abstractsId = nil, displayName = nil, sourceType = nil, issn = [], publisherName = nil, metricList = nil, coverageRange = [], yearInfoList = nil)
    @abstractsId = abstractsId
    @displayName = displayName
    @sourceType = sourceType
    @issn = issn
    @publisherName = publisherName
    @metricList = metricList
    @coverageRange = coverageRange
    @yearInfoList = yearInfoList
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}YearInfoListType
class YearInfoListType < ::Array
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}YearInfoType
#   year - SOAP::SOAPInteger
#   citeCount - SOAP::SOAPInteger
#   publicationCount - SOAP::SOAPInteger
#   zeroCites - SOAP::SOAPString
#   zeroCitesPercent - SOAP::SOAPString
#   citeCountSCE - SOAP::SOAPString
#   zeroCitesSCE - SOAP::SOAPString
#   zeroCitesPercentSCE - SOAP::SOAPString
#   revPercent - SOAP::SOAPString
class YearInfoType
  attr_accessor :year
  attr_accessor :citeCount
  attr_accessor :publicationCount
  attr_accessor :zeroCites
  attr_accessor :zeroCitesPercent
  attr_accessor :citeCountSCE
  attr_accessor :zeroCitesSCE
  attr_accessor :zeroCitesPercentSCE
  attr_accessor :revPercent

  def initialize(year = nil, citeCount = nil, publicationCount = nil, zeroCites = nil, zeroCitesPercent = nil, citeCountSCE = nil, zeroCitesSCE = nil, zeroCitesPercentSCE = nil, revPercent = nil)
    @year = year
    @citeCount = citeCount
    @publicationCount = publicationCount
    @zeroCites = zeroCites
    @zeroCitesPercent = zeroCitesPercent
    @citeCountSCE = citeCountSCE
    @zeroCitesSCE = zeroCitesSCE
    @zeroCitesPercentSCE = zeroCitesPercentSCE
    @revPercent = revPercent
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceYearInfoResponseType
#   status - MetaDataStatusType
#   getSourceYearInfoRspPayload - GetSourceYearInfoRspPayloadType
class GetSourceYearInfoResponseType
  attr_accessor :status
  attr_accessor :getSourceYearInfoRspPayload

  def initialize(status = nil, getSourceYearInfoRspPayload = nil)
    @status = status
    @getSourceYearInfoRspPayload = getSourceYearInfoRspPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceYearInfoType
#   getSourceYearInfoReqPayload - GetSourceYearInfoReqPayloadType
class GetSourceYearInfoType
  attr_accessor :getSourceYearInfoReqPayload

  def initialize(getSourceYearInfoReqPayload = nil)
    @getSourceYearInfoReqPayload = getSourceYearInfoReqPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}GetSourceYearInfoReqPayloadType
#   cidQualifier - CIDQualifierType
#   absMetSource - AbsMetSourceType
#   responseStyle - ResponseStyleType
#   dataResponseStyle - DataResponseType
#   abstractsId - (any)
#   coverageRange - CoverageRangeType
#   selfCitation - SelfCitationType
#   suppressRawInfo - (any)
class GetSourceYearInfoReqPayloadType
  attr_accessor :cidQualifier
  attr_accessor :absMetSource
  attr_accessor :responseStyle
  attr_accessor :dataResponseStyle
  attr_accessor :abstractsId
  attr_accessor :coverageRange
  attr_accessor :selfCitation
  attr_accessor :suppressRawInfo

  def initialize(cidQualifier = nil, absMetSource = nil, responseStyle = nil, dataResponseStyle = nil, abstractsId = [], coverageRange = nil, selfCitation = nil, suppressRawInfo = nil)
    @cidQualifier = cidQualifier
    @absMetSource = absMetSource
    @responseStyle = responseStyle
    @dataResponseStyle = dataResponseStyle
    @abstractsId = abstractsId
    @coverageRange = coverageRange
    @selfCitation = selfCitation
    @suppressRawInfo = suppressRawInfo
  end
end

# {http://webservices.elsevier.com/schemas/ews/common/types/v2}EIDListType
class EIDListType < ::Array
end

# {http://webservices.elsevier.com/schemas/ews/common/types/v2}RefKeyType
#   documentType - SOAP::SOAPString
#   firstAuthorSurname - SOAP::SOAPString
#   yearOfPublication - SOAP::SOAPString
#   firstPageNumber - SOAP::SOAPString
#   lastPageNumber - SOAP::SOAPString
#   firstInitialFirstAuthor - SOAP::SOAPString
class RefKeyType
  attr_accessor :documentType
  attr_accessor :firstAuthorSurname
  attr_accessor :yearOfPublication
  attr_accessor :firstPageNumber
  attr_accessor :lastPageNumber
  attr_accessor :firstInitialFirstAuthor

  def initialize(documentType = nil, firstAuthorSurname = nil, yearOfPublication = nil, firstPageNumber = nil, lastPageNumber = nil, firstInitialFirstAuthor = nil)
    @documentType = documentType
    @firstAuthorSurname = firstAuthorSurname
    @yearOfPublication = yearOfPublication
    @firstPageNumber = firstPageNumber
    @lastPageNumber = lastPageNumber
    @firstInitialFirstAuthor = firstInitialFirstAuthor
  end
end

# {http://webservices.elsevier.com/schemas/ews/common/types/v2}IVIPType
#   iSSN - (any)
#   iSBN - (any)
#   eISSN - (any)
#   volume - (any)
#   issue - SOAP::SOAPString
#   page - SOAP::SOAPString
class IVIPType
  attr_accessor :iSSN
  attr_accessor :iSBN
  attr_accessor :eISSN
  attr_accessor :volume
  attr_accessor :issue
  attr_accessor :page

  def initialize(iSSN = nil, iSBN = nil, eISSN = nil, volume = nil, issue = nil, page = nil)
    @iSSN = iSSN
    @iSBN = iSBN
    @eISSN = eISSN
    @volume = volume
    @issue = issue
    @page = page
  end
end

# {http://webservices.elsevier.com/schemas/ews/common/types/v2}RequestChunkType
#   positionHandle - SOAP::SOAPString
#   maxItems - SOAP::SOAPInteger
class RequestChunkType
  attr_accessor :positionHandle
  attr_accessor :maxItems

  def initialize(positionHandle = nil, maxItems = nil)
    @positionHandle = positionHandle
    @maxItems = maxItems
  end
end

# {http://webservices.elsevier.com/schemas/ews/common/types/v2}ResponseChunkType
#   nextPositionHandle - SOAP::SOAPString
#   itemCount - SOAP::SOAPInteger
#   integrityToken - SOAP::SOAPString
class ResponseChunkType
  attr_accessor :nextPositionHandle
  attr_accessor :itemCount
  attr_accessor :integrityToken

  def initialize(nextPositionHandle = nil, itemCount = nil, integrityToken = nil)
    @nextPositionHandle = nextPositionHandle
    @itemCount = itemCount
    @integrityToken = integrityToken
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}MetaDataStatusType
#   statusCode - MetaDataStatusCodeType
#   statusText - SOAP::SOAPString
class MetaDataStatusType
  attr_accessor :statusCode
  attr_accessor :statusText

  def initialize(statusCode = nil, statusText = nil)
    @statusCode = statusCode
    @statusText = statusText
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}InputKeyType
#   doi - (any)
#   eid - (any)
#   scopusid - (any)
#   pii - (any)
#   issn - (any)
#   isbn - (any)
#   eissn - (any)
#   vol - (any)
#   issue - (any)
#   documenttype - (any)
#   firstAuthorSurname - (any)
#   yearOfPublication - (any)
#   firstPageNumber - (any)
#   lastPageNumber - (any)
#   firstInitialFirstAuthor - (any)
#   articleTitle - (any)
#   clientCRF - (any)
class InputKeyType
  attr_accessor :doi
  attr_accessor :eid
  attr_accessor :scopusid
  attr_accessor :pii
  attr_accessor :issn
  attr_accessor :isbn
  attr_accessor :eissn
  attr_accessor :vol
  attr_accessor :issue
  attr_accessor :documenttype
  attr_accessor :firstAuthorSurname
  attr_accessor :yearOfPublication
  attr_accessor :firstPageNumber
  attr_accessor :lastPageNumber
  attr_accessor :firstInitialFirstAuthor
  attr_accessor :articleTitle
  attr_accessor :clientCRF

  def initialize(doi = nil, eid = nil, scopusid = nil, pii = nil, issn = nil, isbn = nil, eissn = nil, vol = nil, issue = nil, documenttype = nil, firstAuthorSurname = nil, yearOfPublication = nil, firstPageNumber = nil, lastPageNumber = nil, firstInitialFirstAuthor = nil, articleTitle = nil, clientCRF = nil)
    @doi = doi
    @eid = eid
    @scopusid = scopusid
    @pii = pii
    @issn = issn
    @isbn = isbn
    @eissn = eissn
    @vol = vol
    @issue = issue
    @documenttype = documenttype
    @firstAuthorSurname = firstAuthorSurname
    @yearOfPublication = yearOfPublication
    @firstPageNumber = firstPageNumber
    @lastPageNumber = lastPageNumber
    @firstInitialFirstAuthor = firstInitialFirstAuthor
    @articleTitle = articleTitle
    @clientCRF = clientCRF
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}GetEIDsRequestPayloadType
#   cIDQualifier - CIDQualifierType
#   requestChunk - RequestChunkType
#   dataResponseStyle - DataResponseType
class GetEIDsRequestPayloadType
  attr_accessor :cIDQualifier
  attr_accessor :requestChunk
  attr_accessor :dataResponseStyle

  def initialize(cIDQualifier = nil, requestChunk = nil, dataResponseStyle = nil)
    @cIDQualifier = cIDQualifier
    @requestChunk = requestChunk
    @dataResponseStyle = dataResponseStyle
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}GetEIDsRequestType
#   getEIDsRequestPayload - GetEIDsRequestPayloadType
class GetEIDsRequestType
  attr_accessor :getEIDsRequestPayload

  def initialize(getEIDsRequestPayload = nil)
    @getEIDsRequestPayload = getEIDsRequestPayload
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}GetEIDsResponsePayloadType
#   responseChunk - ResponseChunkType
#   dataResponseStyle - DataResponseType
#   eIDItem - EIDItemType
class GetEIDsResponsePayloadType
  attr_accessor :responseChunk
  attr_accessor :dataResponseStyle
  attr_accessor :eIDItem

  def initialize(responseChunk = nil, dataResponseStyle = nil, eIDItem = [])
    @responseChunk = responseChunk
    @dataResponseStyle = dataResponseStyle
    @eIDItem = eIDItem
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}EIDItemType
#   collectionList - CollectionListType
#   eID - (any)
class EIDItemType
  attr_accessor :collectionList
  attr_accessor :eID

  def initialize(collectionList = nil, eID = nil)
    @collectionList = collectionList
    @eID = eID
  end
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}GetEIDsResponseType
#   status - MetaDataStatusType
#   getEIDsResponsePayload - GetEIDsResponsePayloadType
class GetEIDsResponseType
  attr_accessor :status
  attr_accessor :getEIDsResponsePayload

  def initialize(status = nil, getEIDsResponsePayload = nil)
    @status = status
    @getEIDsResponsePayload = getEIDsResponsePayload
  end
end

# {http://webservices.elsevier.com/schemas/ae/client/types/v2}CIDQualifierType
#   cIDExpression - SOAP::SOAPString
#   returnCIDsList - CIDListType
#   expandCIDsFlag - SOAP::SOAPBoolean
#   verboseFlag - SOAP::SOAPBoolean
#   stampedCIDsFlag - SOAP::SOAPBoolean
class CIDQualifierType
  attr_accessor :cIDExpression
  attr_accessor :returnCIDsList
  attr_accessor :expandCIDsFlag
  attr_accessor :verboseFlag
  attr_accessor :stampedCIDsFlag

  def initialize(cIDExpression = nil, returnCIDsList = nil, expandCIDsFlag = nil, verboseFlag = nil, stampedCIDsFlag = nil)
    @cIDExpression = cIDExpression
    @returnCIDsList = returnCIDsList
    @expandCIDsFlag = expandCIDsFlag
    @verboseFlag = verboseFlag
    @stampedCIDsFlag = stampedCIDsFlag
  end
end

# {http://webservices.elsevier.com/schemas/ae/client/types/v2}CIDListType
class CIDListType < ::Array
end

# {http://webservices.elsevier.com/schemas/ae/client/types/v2}CollectionListType
class CollectionListType < ::Array
end

# {http://webservices.elsevier.com/schemas/ae/client/types/v2}CollectionType
#   cID - SOAP::SOAPString
#   type - SOAP::SOAPString
#   attribute - AttributeType
class CollectionType
  attr_accessor :cID
  attr_accessor :type
  attr_accessor :attribute

  def initialize(cID = nil, type = nil, attribute = [])
    @cID = cID
    @type = type
    @attribute = attribute
  end
end

# {http://webservices.elsevier.com/schemas/ae/client/types/v2}AttributeType
#   name - SOAP::SOAPString
#   value - SOAP::SOAPString
class AttributeType
  attr_accessor :name
  attr_accessor :value

  def initialize(name = nil, value = nil)
    @name = name
    @value = value
  end
end

# {http://webservices.elsevier.com/schemas/easi/headers/types/v1}RequestHeaderType
#   transId - SOAP::SOAPString
#   reqId - SOAP::SOAPString
#   ver - SOAP::SOAPString
#   consumer - SOAP::SOAPString
#   consumerClient - SOAP::SOAPString
#   opaqueInfo - SOAP::SOAPString
#   logLevel - LogLevelType
class RequestHeaderType
  attr_accessor :transId
  attr_accessor :reqId
  attr_accessor :ver
  attr_accessor :consumer
  attr_accessor :consumerClient
  attr_accessor :opaqueInfo
  attr_accessor :logLevel

  def initialize(transId = nil, reqId = nil, ver = nil, consumer = nil, consumerClient = nil, opaqueInfo = nil, logLevel = nil)
    @transId = transId
    @reqId = reqId
    @ver = ver
    @consumer = consumer
    @consumerClient = consumerClient
    @opaqueInfo = opaqueInfo
    @logLevel = logLevel
  end
end

# {http://webservices.elsevier.com/schemas/easi/headers/types/v1}ResponseHeaderType
#   transRespId - SOAP::SOAPString
#   respId - SOAP::SOAPString
#   serverId - SOAP::SOAPString
class ResponseHeaderType
  attr_accessor :transRespId
  attr_accessor :respId
  attr_accessor :serverId

  def initialize(transRespId = nil, respId = nil, serverId = nil)
    @transRespId = transRespId
    @respId = respId
    @serverId = serverId
  end
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}AbsMetSourceType
class AbsMetSourceType < ::String
  All = new("all")
  ScidirAI = new("scidirAI")
  ScopusJournal = new("scopusJournal")
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}AbsMetCacheType
class AbsMetCacheType < ::String
  DbList = new("dbList")
  PublisherList = new("publisherList")
  SourceInfoList = new("sourceInfoList")
  SourceList = new("sourceList")
  TopicList = new("topicList")
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}NoDisplayType
class NoDisplayType < ::String
  All = new("all")
  Latest = new("latest")
  No = new("no")
  Yes = new("yes")
end

# {http://webservices.elsevier.com/schemas/metadata/abstracts/types/v10}SelfCitationType
class SelfCitationType < ::String
  All = new("all")
  Exclude = new("exclude")
  Include = new("include")
end

# {http://webservices.elsevier.com/schemas/ews/common/types/v2}DataResponseType
class DataResponseType < ::String
  ATTACHMENT = new("ATTACHMENT")
  COMPRESSED = new("COMPRESSED")
  MESSAGE = new("MESSAGE")
  NONE = new("NONE")
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}MetaDataStatusCodeType
class MetaDataStatusCodeType < ::String
  FAILURE = new("FAILURE")
  INVALID = new("INVALID")
  OK = new("OK")
  RESTRICTED = new("RESTRICTED")
  UNKNOWN = new("UNKNOWN")
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}CacheType
class CacheType < ::String
  IssueList = new("issueList")
  PublisherJournalList = new("publisherJournalList")
  PublisherList = new("publisherList")
  SourceInfoList = new("sourceInfoList")
  SourceList = new("sourceList")
  TopicList = new("topicList")
end

# {http://webservices.elsevier.com/schemas/metadata/common/types/v4}ResponseStyleType
class ResponseStyleType < ::String
  StringBlob = new("stringBlob")
  WellDefined = new("wellDefined")
end

# {http://webservices.elsevier.com/schemas/easi/headers/types/v1}LogLevelType
class LogLevelType < ::String
  All = new("All")
  Debug = new("Debug")
  Default = new("Default")
  Info = new("Info")
end
