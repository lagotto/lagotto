# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'AbstractsMetadataService.rb'
require 'soap/mapping'

module AbstractsMetadataServiceMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsV1 = "http://webservices.elsevier.com/schemas/easi/headers/types/v1"
  NsV2 = "http://webservices.elsevier.com/schemas/ews/common/types/v2"
  NsV2_0 = "http://webservices.elsevier.com/schemas/ae/client/types/v2"
  NsV4 = "http://webservices.elsevier.com/schemas/metadata/common/types/v4"
  NsV7 = "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7"

  EncodedRegistry.register(
    :class => CacheInfoType,
    :schema_type => XSD::QName.new(NsV7, "CacheInfoType"),
    :schema_element => [
      ["absMetCache", "AbsMetCacheType"],
      ["timeToken", nil]
    ]
  )

  EncodedRegistry.register(
    :class => GetPublishersReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetPublishersType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersType"),
    :schema_element => [
      ["getPublishersReqPayload", "GetPublishersReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => PublisherType,
    :schema_type => XSD::QName.new(NsV7, "PublisherType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["pubId", nil],
      ["publisherName", nil],
      ["logoURL", nil],
      ["sortName", nil],
      ["dbName", nil, [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => PublisherListType,
    :schema_type => XSD::QName.new(NsV7, "PublisherListType"),
    :schema_element => [
      ["publisher", "PublisherType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetPublishersRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["publisherList", "PublisherListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetPublishersResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getPublishersRspPayload", "GetPublishersRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceMetadataReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["chunkingInfo", "RequestChunkType", [0, 1]],
      ["smi", "[]", [0, nil]],
      ["dbName", "[]", [0, nil]],
      ["abstractsId", "[]", [0, nil]],
      ["suppressDbItems", nil],
      ["suppressSubjectAreaList", nil]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceMetadataType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataType"),
    :schema_element => [
      ["getSourceMetadataReqPayload", "GetSourceMetadataReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceMetadataRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["abstractsList", "AbstractsListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"],
      ["chunkingInfo", "ResponseChunkType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceMetadataResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceMetadataRspPayload", "GetSourceMetadataRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => AbstractsListType,
    :schema_type => XSD::QName.new(NsV7, "AbstractsListType"),
    :schema_element => [
      ["abstracts", "AbstractsType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => AbstractsType,
    :schema_type => XSD::QName.new(NsV7, "AbstractsType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["abstractsId", nil, [0, 1]],
      ["gid", nil, [0, 1]],
      ["displayName", nil],
      ["variantName", "[]", [0, nil]],
      ["dbItem", "DbItemType[]", [0, nil]],
      ["sourceType", nil],
      ["smi", nil, [0, 1]],
      ["sortName", nil],
      ["sortNumber", nil],
      ["issn", "[]", [0, nil]],
      ["eissn", "[]", [0, nil]],
      ["isbn", "ISBNWrapperType[]", [0, nil]],
      ["coden", nil, [0, 1]],
      ["publisherName", nil, [0, 1]],
      ["abbrevTitle", nil, [0, 1]],
      ["subjectAreaList", "SubjectAreaListType", [0, 1]],
      ["relationship", "RelationshipType[]", [0, nil]],
      ["active", nil, [0, 1]],
      ["rank", nil, [0, 1]],
      ["aipCount", nil, [0, 1]],
      ["coverageRange", "CoverageRangeType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => CoverageRangeType,
    :schema_type => XSD::QName.new(NsV7, "CoverageRangeType"),
    :schema_element => [
      ["coverageStartYear", nil, [0, 1]],
      ["coverageEndYear", nil, [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => ISBNWrapperType,
    :schema_type => XSD::QName.new(NsV7, "ISBNWrapperType"),
    :schema_element => [
      ["isbn", nil],
      ["length", nil, [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => RelationshipType,
    :schema_type => XSD::QName.new(NsV7, "RelationshipType"),
    :schema_element => [
      ["sourceId", "SOAP::SOAPString[]", [1, nil]],
      ["relationshipStatus", "SOAP::SOAPString"],
      ["relationshipType", "SOAP::SOAPString"]
    ]
  )

  EncodedRegistry.register(
    :class => SubjectAreaListType,
    :schema_type => XSD::QName.new(NsV7, "SubjectAreaListType"),
    :schema_element => [
      ["subjectArea", ["SubjectAreaType[]", XSD::QName.new(NsV7, "SubjectArea")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => SubjectAreaType,
    :schema_type => XSD::QName.new(NsV7, "SubjectAreaType"),
    :schema_element => [
      ["displayName", nil],
      ["subjectCode", nil]
    ]
  )

  EncodedRegistry.register(
    :class => GetDbMetadataReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["smi", "[]", [0, nil]],
      ["dbName", "[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetDbMetadataType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataType"),
    :schema_element => [
      ["getDbMetadataReqPayload", "GetDbMetadataReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetDbMetadataRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["dbInfoList", "DbInfoListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetDbMetadataResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getDbMetadataRspPayload", "GetDbMetadataRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => DbInfoListType,
    :schema_type => XSD::QName.new(NsV7, "DbInfoListType"),
    :schema_element => [
      ["dbInfo", "DbInfoType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => DbInfoType,
    :schema_type => XSD::QName.new(NsV7, "DbInfoType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["dbItem", "DbItemType"],
      ["smi", nil, [0, 1]],
      ["sortName", nil],
      ["sortNumber", nil],
      ["publisherName", nil, [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetLinkDataReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["inputKey", "InputKeyType[]", [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetLinkDataType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataType"),
    :schema_element => [
      ["getLinkDataReqPayload", "GetLinkDataReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetLinkDataRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataRspPayloadType"),
    :schema_element => [
      ["citedLinkDataList", "CitedLinkDataListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => CitedLinkDataListType,
    :schema_type => XSD::QName.new(NsV7, "CitedLinkDataListType"),
    :schema_element => [
      ["citedLinkData", "CitedLinkDataType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => CitedLinkDataType,
    :schema_type => XSD::QName.new(NsV7, "CitedLinkDataType"),
    :schema_element => [
      ["linkData", "LinkDataType"],
      ["recordType", "SOAP::SOAPString"],
      ["citedByCount", "SOAP::SOAPDecimal"]
    ]
  )

  EncodedRegistry.register(
    :class => LinkDataType,
    :schema_type => XSD::QName.new(NsV7, "LinkDataType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["inputKey", "InputKeyType"],
      ["eid", nil],
      ["doi", nil, [0, 1]],
      ["uoi", nil, [0, 1]],
      ["pii", nil, [0, 1]],
      ["refKey", "RefKeyType"],
      ["ivip", "IVIPType"],
      ["dbname", nil]
    ]
  )

  EncodedRegistry.register(
    :class => DbItemType,
    :schema_type => XSD::QName.new(NsV7, "DbItemType"),
    :schema_element => [
      ["dbName", nil, [0, 1]],
      ["dbUrl", nil, [0, 1]],
      ["coverageRange", "CoverageRangeType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetLinkDataResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getLinkDataRspPayload", "GetLinkDataRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetCitedByCountType,
    :schema_type => XSD::QName.new(NsV7, "GetCitedByCountType"),
    :schema_element => [
      ["getCitedByCountReqPayload", "GetLinkDataReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetCitedByCountRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetCitedByCountRspPayloadType"),
    :schema_element => [
      ["citedByCountList", "CitedByCountListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => CitedByCountListType,
    :schema_type => XSD::QName.new(NsV7, "CitedByCountListType"),
    :schema_element => [
      ["citedByCount", "CitedByCountType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => CitedByCountType,
    :schema_type => XSD::QName.new(NsV7, "CitedByCountType"),
    :schema_element => [
      ["inputKey", "InputKeyType"],
      ["linkData", "CitedByCountItemType[]", [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => CitedByCountItemType,
    :schema_type => XSD::QName.new(NsV7, "CitedByCountItemType"),
    :schema_element => [
      ["eid", nil],
      ["scopusID", nil],
      ["citedByCount", "SOAP::SOAPDecimal"]
    ]
  )

  EncodedRegistry.register(
    :class => GetCitedByCountResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetCitedByCountResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getCitedByCountRspPayload", "GetCitedByCountRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => TopicListType,
    :schema_type => XSD::QName.new(NsV7, "TopicListType"),
    :schema_element => [
      ["topic", "TopicType[]", [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetTopicsRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["topicList", "TopicListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => TopicType,
    :schema_type => XSD::QName.new(NsV7, "TopicType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["topicId", nil],
      ["topicName", nil]
    ]
  )

  EncodedRegistry.register(
    :class => GetTopicsReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetTopicsType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsType"),
    :schema_element => [
      ["getTopicsReqPayload", "GetTopicsReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetTopicsResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getTopicsRspPayload", "GetTopicsRspPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => IsCacheCurrentReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentReqPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType"],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => IsCacheCurrentType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentType"),
    :schema_element => [
      ["isCacheCurrentReqPayload", "IsCacheCurrentReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => IsCacheCurrentRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentRspPayloadType"),
    :schema_element => [
      ["cacheCurrentFlag", nil, [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => IsCacheCurrentResponseType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["isCacheCurrentRspPayload", "IsCacheCurrentRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceInfoRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["sourceInfoList", "SourceInfoListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => SourceInfoListType,
    :schema_type => XSD::QName.new(NsV7, "SourceInfoListType"),
    :schema_element => [
      ["sourceInfo", "SourceInfoType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => SourceInfoType,
    :schema_type => XSD::QName.new(NsV7, "SourceInfoType"),
    :schema_element => [
      ["abstracts", "AbstractsType"],
      ["noDisplay", "NoDisplayType", [0, 1]],
      ["issueInfoList", "IssueInfoListType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => VolumePairType,
    :schema_type => XSD::QName.new(NsV7, "VolumePairType"),
    :schema_element => [
      ["volumeFirst", nil],
      ["volumeLast", nil, [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => IssueInfoListType,
    :schema_type => XSD::QName.new(NsV7, "IssueInfoListType"),
    :schema_element => [
      ["issueInfo", "IssueInfoType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IssueInfoType,
    :schema_type => XSD::QName.new(NsV7, "IssueInfoType"),
    :schema_element => [
      ["issueFirst", "SOAP::SOAPString", [0, 1]],
      ["issueLast", "SOAP::SOAPString", [0, 1]],
      ["volume", "VolumePairType", [0, 1]],
      ["sortDate", "SOAP::SOAPString"],
      ["dbItem", "DbItemType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceInfoResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceInfoRspPayload", "GetSourceInfoRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceInfoType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoType"),
    :schema_element => [
      ["getSourceInfoReqPayload", "GetSourceInfoReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceInfoReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["abstractsId", "[]", [1, nil]],
      ["suppressDummyRecords", nil],
      ["suppressAIP", nil],
      ["suppressDbItems", nil],
      ["suppressSubjectAreaList", nil],
      ["coverageRange", "CoverageRangeType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetIDsRequestType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsRequestType"),
    :schema_element => [
      ["getIDsRequestPayload", "GetIDsRequestPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetIDsRequestPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsRequestPayloadType"),
    :schema_element => [
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["keys", ["KeyType[]", XSD::QName.new(NsV7, "Keys")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => KeyType,
    :schema_type => XSD::QName.new(NsV7, "KeyType"),
    :schema_element => [
      ["clientCRF", nil],
      ["bibkeys", [nil, XSD::QName.new(NsV7, "Bibkeys")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetIDsResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getIDsResponsePayload", "GetIDsResponsePayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetIDsResponsePayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsResponsePayloadType"),
    :schema_element => [
      ["dataResponseStyle", "DataResponseType"],
      ["stringBlob", nil, [0, 1]],
      ["iDList", ["IDListType", XSD::QName.new(NsV7, "IDList")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => IDListType,
    :schema_type => XSD::QName.new(NsV7, "IDListType"),
    :schema_element => [
      ["iDItem", ["IDItemType[]", XSD::QName.new(NsV7, "IDItem")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => IDItemType,
    :schema_type => XSD::QName.new(NsV7, "IDItemType"),
    :schema_element => [
      ["inputKey", "KeyType"],
      ["scopusID", ["[]", XSD::QName.new(NsV7, "ScopusID")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceYearInfoRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["updatedDate", "SOAP::SOAPString", [0, 1]],
      ["sourceYearInfoList", "SourceYearInfoListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  EncodedRegistry.register(
    :class => SourceYearInfoListType,
    :schema_type => XSD::QName.new(NsV7, "SourceYearInfoListType"),
    :schema_element => [
      ["sourceYearInfo", "SourceYearInfoType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => SourceYearInfoType,
    :schema_type => XSD::QName.new(NsV7, "SourceYearInfoType"),
    :schema_element => [
      ["abstractsId", nil, [0, 1]],
      ["displayName", nil],
      ["sourceType", nil],
      ["issn", "[]", [0, nil]],
      ["publisherName", nil, [0, 1]],
      ["rank", nil, [0, 1]],
      ["coverageRange", "CoverageRangeType[]", [0, nil]],
      ["yearInfoList", "YearInfoListType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => YearInfoListType,
    :schema_type => XSD::QName.new(NsV7, "YearInfoListType"),
    :schema_element => [
      ["yearInfo", "YearInfoType[]", [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => YearInfoType,
    :schema_type => XSD::QName.new(NsV7, "YearInfoType"),
    :schema_element => [
      ["year", "SOAP::SOAPInteger", [0, 1]],
      ["citeCount", "SOAP::SOAPInteger", [0, 1]],
      ["publicationCount", "SOAP::SOAPInteger", [0, 1]],
      ["averageCount", "SOAP::SOAPString", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceYearInfoResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceYearInfoRspPayload", "GetSourceYearInfoRspPayloadType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceYearInfoType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoType"),
    :schema_element => [
      ["getSourceYearInfoReqPayload", "GetSourceYearInfoReqPayloadType"]
    ]
  )

  EncodedRegistry.register(
    :class => GetSourceYearInfoReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["abstractsId", "[]", [1, nil]],
      ["coverageRange", "CoverageRangeType", [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => EIDListType,
    :schema_type => XSD::QName.new(NsV2, "EIDListType"),
    :schema_element => [
      ["eID", ["[]", XSD::QName.new(nil, "EID")], [1, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => RefKeyType,
    :schema_type => XSD::QName.new(NsV2, "RefKeyType"),
    :schema_element => [
      ["documentType", ["SOAP::SOAPString", XSD::QName.new(nil, "DocumentType")], [0, 1]],
      ["firstAuthorSurname", ["SOAP::SOAPString", XSD::QName.new(nil, "FirstAuthorSurname")]],
      ["yearOfPublication", ["SOAP::SOAPString", XSD::QName.new(nil, "YearOfPublication")]],
      ["firstPageNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "FirstPageNumber")]],
      ["lastPageNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "LastPageNumber")], [0, 1]],
      ["firstInitialFirstAuthor", ["SOAP::SOAPString", XSD::QName.new(nil, "FirstInitialFirstAuthor")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => IVIPType,
    :schema_type => XSD::QName.new(NsV2, "IVIPType"),
    :schema_element => [
      ["iSSN", [nil, XSD::QName.new(nil, "ISSN")]],
      ["iSBN", [nil, XSD::QName.new(nil, "ISBN")], [0, 1]],
      ["eISSN", [nil, XSD::QName.new(nil, "EISSN")], [0, 1]],
      ["volume", [nil, XSD::QName.new(nil, "Volume")]],
      ["issue", ["SOAP::SOAPString", XSD::QName.new(nil, "Issue")]],
      ["page", ["SOAP::SOAPString", XSD::QName.new(nil, "Page")]]
    ]
  )

  EncodedRegistry.register(
    :class => RequestChunkType,
    :schema_type => XSD::QName.new(NsV2, "RequestChunkType"),
    :schema_element => [
      ["positionHandle", ["SOAP::SOAPString", XSD::QName.new(nil, "positionHandle")], [0, 1]],
      ["maxItems", ["SOAP::SOAPInteger", XSD::QName.new(nil, "maxItems")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => ResponseChunkType,
    :schema_type => XSD::QName.new(NsV2, "ResponseChunkType"),
    :schema_element => [
      ["nextPositionHandle", ["SOAP::SOAPString", XSD::QName.new(nil, "nextPositionHandle")], [0, 1]],
      ["itemCount", ["SOAP::SOAPInteger", XSD::QName.new(nil, "itemCount")]],
      ["integrityToken", ["SOAP::SOAPString", XSD::QName.new(nil, "integrityToken")]]
    ]
  )

  EncodedRegistry.register(
    :class => MetaDataStatusType,
    :schema_type => XSD::QName.new(NsV4, "MetaDataStatusType"),
    :schema_element => [
      ["statusCode", ["MetaDataStatusCodeType", XSD::QName.new(nil, "statusCode")]],
      ["statusText", ["SOAP::SOAPString", XSD::QName.new(nil, "statusText")]]
    ]
  )

  EncodedRegistry.register(
    :class => InputKeyType,
    :schema_type => XSD::QName.new(NsV4, "InputKeyType"),
    :schema_element => [
      ["doi", [nil, XSD::QName.new(nil, "doi")], [0, 1]],
      ["eid", [nil, XSD::QName.new(nil, "eid")], [0, 1]],
      ["scopusid", [nil, XSD::QName.new(nil, "scopusid")], [0, 1]],
      ["pii", [nil, XSD::QName.new(nil, "pii")], [0, 1]],
      ["issn", [nil, XSD::QName.new(nil, "issn")], [0, 1]],
      ["isbn", [nil, XSD::QName.new(nil, "isbn")], [0, 1]],
      ["eissn", [nil, XSD::QName.new(nil, "eissn")], [0, 1]],
      ["vol", [nil, XSD::QName.new(nil, "vol")], [0, 1]],
      ["issue", [nil, XSD::QName.new(nil, "issue")], [0, 1]],
      ["documenttype", [nil, XSD::QName.new(nil, "documenttype")], [0, 1]],
      ["firstAuthorSurname", [nil, XSD::QName.new(nil, "firstAuthorSurname")], [0, 1]],
      ["yearOfPublication", [nil, XSD::QName.new(nil, "yearOfPublication")], [0, 1]],
      ["firstPageNumber", [nil, XSD::QName.new(nil, "firstPageNumber")], [0, 1]],
      ["lastPageNumber", [nil, XSD::QName.new(nil, "lastPageNumber")], [0, 1]],
      ["firstInitialFirstAuthor", [nil, XSD::QName.new(nil, "firstInitialFirstAuthor")], [0, 1]],
      ["articleTitle", [nil, XSD::QName.new(nil, "articleTitle")], [0, 1]],
      ["clientCRF", [nil, XSD::QName.new(nil, "clientCRF")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => GetEIDsRequestPayloadType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsRequestPayloadType"),
    :schema_element => [
      ["cIDQualifier", ["CIDQualifierType", XSD::QName.new(nil, "CIDQualifier")]],
      ["requestChunk", ["RequestChunkType", XSD::QName.new(nil, "requestChunk")]],
      ["dataResponseStyle", ["DataResponseType", XSD::QName.new(nil, "dataResponseStyle")]]
    ]
  )

  EncodedRegistry.register(
    :class => GetEIDsRequestType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsRequestType"),
    :schema_element => [
      ["getEIDsRequestPayload", ["GetEIDsRequestPayloadType", XSD::QName.new(nil, "getEIDsRequestPayload")]]
    ]
  )

  EncodedRegistry.register(
    :class => GetEIDsResponsePayloadType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsResponsePayloadType"),
    :schema_element => [
      ["responseChunk", ["ResponseChunkType", XSD::QName.new(nil, "responseChunk")]],
      ["dataResponseStyle", ["DataResponseType", XSD::QName.new(nil, "dataResponseStyle")]],
      ["eIDItem", ["EIDItemType[]", XSD::QName.new(nil, "EIDItem")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => EIDItemType,
    :schema_type => XSD::QName.new(NsV4, "EIDItemType"),
    :schema_element => [
      ["collectionList", ["CollectionListType", XSD::QName.new(nil, "collectionList")], [0, 1]],
      ["eID", [nil, XSD::QName.new(nil, "EID")]]
    ]
  )

  EncodedRegistry.register(
    :class => GetEIDsResponseType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsResponseType"),
    :schema_element => [
      ["status", ["MetaDataStatusType", XSD::QName.new(nil, "status")]],
      ["getEIDsResponsePayload", ["GetEIDsResponsePayloadType", XSD::QName.new(nil, "getEIDsResponsePayload")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => CIDQualifierType,
    :schema_type => XSD::QName.new(NsV2_0, "CIDQualifierType"),
    :schema_element => [
      ["cIDExpression", ["SOAP::SOAPString", XSD::QName.new(nil, "CIDExpression")]],
      ["returnCIDsList", ["CIDListType", XSD::QName.new(nil, "returnCIDsList")]],
      ["expandCIDsFlag", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "expandCIDsFlag")]],
      ["verboseFlag", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "verboseFlag")], [0, 1]],
      ["stampedCIDsFlag", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "stampedCIDsFlag")], [0, 1]]
    ]
  )

  EncodedRegistry.register(
    :class => CIDListType,
    :schema_type => XSD::QName.new(NsV2_0, "CIDListType"),
    :schema_element => [
      ["cID", ["SOAP::SOAPString[]", XSD::QName.new(nil, "CID")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => CollectionListType,
    :schema_type => XSD::QName.new(NsV2_0, "CollectionListType"),
    :schema_element => [
      ["collection", ["CollectionType[]", XSD::QName.new(nil, "collection")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => CollectionType,
    :schema_type => XSD::QName.new(NsV2_0, "CollectionType"),
    :schema_element => [
      ["cID", ["SOAP::SOAPString", XSD::QName.new(nil, "CID")]],
      ["type", ["SOAP::SOAPString", XSD::QName.new(nil, "type")], [0, 1]],
      ["attribute", ["AttributeType[]", XSD::QName.new(nil, "attribute")], [0, nil]]
    ]
  )

  EncodedRegistry.register(
    :class => AttributeType,
    :schema_type => XSD::QName.new(NsV2_0, "AttributeType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["value", ["SOAP::SOAPString", XSD::QName.new(nil, "value")]]
    ]
  )

  EncodedRegistry.register(
    :class => RequestHeaderType,
    :schema_type => XSD::QName.new(NsV1, "RequestHeaderType"),
    :schema_element => [
      ["transId", ["SOAP::SOAPString", XSD::QName.new(nil, "TransId")], [0, 1]],
      ["reqId", ["SOAP::SOAPString", XSD::QName.new(nil, "ReqId")]],
      ["ver", ["SOAP::SOAPString", XSD::QName.new(nil, "Ver")]],
      ["consumer", ["SOAP::SOAPString", XSD::QName.new(nil, "Consumer")]],
      ["consumerClient", ["SOAP::SOAPString", XSD::QName.new(nil, "ConsumerClient")], [0, 1]],
      ["opaqueInfo", ["SOAP::SOAPString", XSD::QName.new(nil, "OpaqueInfo")], [0, 1]],
      ["logLevel", ["LogLevelType", XSD::QName.new(nil, "LogLevel")]]
    ]
  )

  EncodedRegistry.register(
    :class => ResponseHeaderType,
    :schema_type => XSD::QName.new(NsV1, "ResponseHeaderType"),
    :schema_element => [
      ["transRespId", ["SOAP::SOAPString", XSD::QName.new(nil, "TransRespId")], [0, 1]],
      ["respId", ["SOAP::SOAPString", XSD::QName.new(nil, "RespId")]],
      ["serverId", ["SOAP::SOAPString", XSD::QName.new(nil, "ServerId")]]
    ]
  )

  EncodedRegistry.register(
    :class => AbsMetSourceType,
    :schema_type => XSD::QName.new(NsV7, "AbsMetSourceType")
  )

  EncodedRegistry.register(
    :class => AbsMetCacheType,
    :schema_type => XSD::QName.new(NsV7, "AbsMetCacheType")
  )

  EncodedRegistry.register(
    :class => NoDisplayType,
    :schema_type => XSD::QName.new(NsV7, "NoDisplayType")
  )

  EncodedRegistry.register(
    :class => DataResponseType,
    :schema_type => XSD::QName.new(NsV2, "DataResponseType")
  )

  EncodedRegistry.register(
    :class => MetaDataStatusCodeType,
    :schema_type => XSD::QName.new(NsV4, "MetaDataStatusCodeType")
  )

  EncodedRegistry.register(
    :class => CacheType,
    :schema_type => XSD::QName.new(NsV4, "CacheType")
  )

  EncodedRegistry.register(
    :class => ResponseStyleType,
    :schema_type => XSD::QName.new(NsV4, "ResponseStyleType")
  )

  EncodedRegistry.register(
    :class => LogLevelType,
    :schema_type => XSD::QName.new(NsV1, "LogLevelType")
  )

  LiteralRegistry.register(
    :class => CacheInfoType,
    :schema_type => XSD::QName.new(NsV7, "CacheInfoType"),
    :schema_element => [
      ["absMetCache", "AbsMetCacheType"],
      ["timeToken", nil]
    ]
  )

  LiteralRegistry.register(
    :class => GetPublishersReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetPublishersType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersType"),
    :schema_element => [
      ["getPublishersReqPayload", "GetPublishersReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => PublisherType,
    :schema_type => XSD::QName.new(NsV7, "PublisherType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["pubId", nil],
      ["publisherName", nil],
      ["logoURL", nil],
      ["sortName", nil],
      ["dbName", nil, [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => PublisherListType,
    :schema_type => XSD::QName.new(NsV7, "PublisherListType"),
    :schema_element => [
      ["publisher", "PublisherType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetPublishersRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["publisherList", "PublisherListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetPublishersResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetPublishersResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getPublishersRspPayload", "GetPublishersRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceMetadataReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["chunkingInfo", "RequestChunkType", [0, 1]],
      ["smi", "[]", [0, nil]],
      ["dbName", "[]", [0, nil]],
      ["abstractsId", "[]", [0, nil]],
      ["suppressDbItems", nil],
      ["suppressSubjectAreaList", nil]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceMetadataType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataType"),
    :schema_element => [
      ["getSourceMetadataReqPayload", "GetSourceMetadataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceMetadataRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["abstractsList", "AbstractsListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"],
      ["chunkingInfo", "ResponseChunkType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceMetadataResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceMetadataResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceMetadataRspPayload", "GetSourceMetadataRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => AbstractsListType,
    :schema_type => XSD::QName.new(NsV7, "AbstractsListType"),
    :schema_element => [
      ["abstracts", "AbstractsType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => AbstractsType,
    :schema_type => XSD::QName.new(NsV7, "AbstractsType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["abstractsId", nil, [0, 1]],
      ["gid", nil, [0, 1]],
      ["displayName", nil],
      ["variantName", "[]", [0, nil]],
      ["dbItem", "DbItemType[]", [0, nil]],
      ["sourceType", nil],
      ["smi", nil, [0, 1]],
      ["sortName", nil],
      ["sortNumber", nil],
      ["issn", "[]", [0, nil]],
      ["eissn", "[]", [0, nil]],
      ["isbn", "ISBNWrapperType[]", [0, nil]],
      ["coden", nil, [0, 1]],
      ["publisherName", nil, [0, 1]],
      ["abbrevTitle", nil, [0, 1]],
      ["subjectAreaList", "SubjectAreaListType", [0, 1]],
      ["relationship", "RelationshipType[]", [0, nil]],
      ["active", nil, [0, 1]],
      ["rank", nil, [0, 1]],
      ["aipCount", nil, [0, 1]],
      ["coverageRange", "CoverageRangeType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => CoverageRangeType,
    :schema_type => XSD::QName.new(NsV7, "CoverageRangeType"),
    :schema_element => [
      ["coverageStartYear", nil, [0, 1]],
      ["coverageEndYear", nil, [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ISBNWrapperType,
    :schema_type => XSD::QName.new(NsV7, "ISBNWrapperType"),
    :schema_element => [
      ["isbn", nil],
      ["length", nil, [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => RelationshipType,
    :schema_type => XSD::QName.new(NsV7, "RelationshipType"),
    :schema_element => [
      ["sourceId", "SOAP::SOAPString[]", [1, nil]],
      ["relationshipStatus", "SOAP::SOAPString"],
      ["relationshipType", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => SubjectAreaListType,
    :schema_type => XSD::QName.new(NsV7, "SubjectAreaListType"),
    :schema_element => [
      ["subjectArea", ["SubjectAreaType[]", XSD::QName.new(NsV7, "SubjectArea")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => SubjectAreaType,
    :schema_type => XSD::QName.new(NsV7, "SubjectAreaType"),
    :schema_element => [
      ["displayName", nil],
      ["subjectCode", nil]
    ]
  )

  LiteralRegistry.register(
    :class => GetDbMetadataReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["smi", "[]", [0, nil]],
      ["dbName", "[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetDbMetadataType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataType"),
    :schema_element => [
      ["getDbMetadataReqPayload", "GetDbMetadataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetDbMetadataRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["dbInfoList", "DbInfoListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetDbMetadataResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetDbMetadataResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getDbMetadataRspPayload", "GetDbMetadataRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => DbInfoListType,
    :schema_type => XSD::QName.new(NsV7, "DbInfoListType"),
    :schema_element => [
      ["dbInfo", "DbInfoType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => DbInfoType,
    :schema_type => XSD::QName.new(NsV7, "DbInfoType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["dbItem", "DbItemType"],
      ["smi", nil, [0, 1]],
      ["sortName", nil],
      ["sortNumber", nil],
      ["publisherName", nil, [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetLinkDataReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["inputKey", "InputKeyType[]", [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetLinkDataType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataType"),
    :schema_element => [
      ["getLinkDataReqPayload", "GetLinkDataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetLinkDataRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataRspPayloadType"),
    :schema_element => [
      ["citedLinkDataList", "CitedLinkDataListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => CitedLinkDataListType,
    :schema_type => XSD::QName.new(NsV7, "CitedLinkDataListType"),
    :schema_element => [
      ["citedLinkData", "CitedLinkDataType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => CitedLinkDataType,
    :schema_type => XSD::QName.new(NsV7, "CitedLinkDataType"),
    :schema_element => [
      ["linkData", "LinkDataType"],
      ["recordType", "SOAP::SOAPString"],
      ["citedByCount", "SOAP::SOAPDecimal"]
    ]
  )

  LiteralRegistry.register(
    :class => LinkDataType,
    :schema_type => XSD::QName.new(NsV7, "LinkDataType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["inputKey", "InputKeyType"],
      ["eid", nil],
      ["doi", nil, [0, 1]],
      ["uoi", nil, [0, 1]],
      ["pii", nil, [0, 1]],
      ["refKey", "RefKeyType"],
      ["ivip", "IVIPType"],
      ["dbname", nil]
    ]
  )

  LiteralRegistry.register(
    :class => DbItemType,
    :schema_type => XSD::QName.new(NsV7, "DbItemType"),
    :schema_element => [
      ["dbName", nil, [0, 1]],
      ["dbUrl", nil, [0, 1]],
      ["coverageRange", "CoverageRangeType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetLinkDataResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetLinkDataResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getLinkDataRspPayload", "GetLinkDataRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetCitedByCountType,
    :schema_type => XSD::QName.new(NsV7, "GetCitedByCountType"),
    :schema_element => [
      ["getCitedByCountReqPayload", "GetLinkDataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetCitedByCountRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetCitedByCountRspPayloadType"),
    :schema_element => [
      ["citedByCountList", "CitedByCountListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => CitedByCountListType,
    :schema_type => XSD::QName.new(NsV7, "CitedByCountListType"),
    :schema_element => [
      ["citedByCount", "CitedByCountType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => CitedByCountType,
    :schema_type => XSD::QName.new(NsV7, "CitedByCountType"),
    :schema_element => [
      ["inputKey", "InputKeyType"],
      ["linkData", "CitedByCountItemType[]", [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => CitedByCountItemType,
    :schema_type => XSD::QName.new(NsV7, "CitedByCountItemType"),
    :schema_element => [
      ["eid", nil],
      ["scopusID", nil],
      ["citedByCount", "SOAP::SOAPDecimal"]
    ]
  )

  LiteralRegistry.register(
    :class => GetCitedByCountResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetCitedByCountResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getCitedByCountRspPayload", "GetCitedByCountRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => TopicListType,
    :schema_type => XSD::QName.new(NsV7, "TopicListType"),
    :schema_element => [
      ["topic", "TopicType[]", [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetTopicsRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["topicList", "TopicListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => TopicType,
    :schema_type => XSD::QName.new(NsV7, "TopicType"),
    :schema_element => [
      ["collectionList", "CollectionListType", [0, 1]],
      ["topicId", nil],
      ["topicName", nil]
    ]
  )

  LiteralRegistry.register(
    :class => GetTopicsReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetTopicsType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsType"),
    :schema_element => [
      ["getTopicsReqPayload", "GetTopicsReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetTopicsResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetTopicsResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getTopicsRspPayload", "GetTopicsRspPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => IsCacheCurrentReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentReqPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType"],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => IsCacheCurrentType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentType"),
    :schema_element => [
      ["isCacheCurrentReqPayload", "IsCacheCurrentReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => IsCacheCurrentRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentRspPayloadType"),
    :schema_element => [
      ["cacheCurrentFlag", nil, [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => IsCacheCurrentResponseType,
    :schema_type => XSD::QName.new(NsV7, "IsCacheCurrentResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["isCacheCurrentRspPayload", "IsCacheCurrentRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceInfoRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["sourceInfoList", "SourceInfoListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => SourceInfoListType,
    :schema_type => XSD::QName.new(NsV7, "SourceInfoListType"),
    :schema_element => [
      ["sourceInfo", "SourceInfoType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => SourceInfoType,
    :schema_type => XSD::QName.new(NsV7, "SourceInfoType"),
    :schema_element => [
      ["abstracts", "AbstractsType"],
      ["noDisplay", "NoDisplayType", [0, 1]],
      ["issueInfoList", "IssueInfoListType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => VolumePairType,
    :schema_type => XSD::QName.new(NsV7, "VolumePairType"),
    :schema_element => [
      ["volumeFirst", nil],
      ["volumeLast", nil, [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => IssueInfoListType,
    :schema_type => XSD::QName.new(NsV7, "IssueInfoListType"),
    :schema_element => [
      ["issueInfo", "IssueInfoType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IssueInfoType,
    :schema_type => XSD::QName.new(NsV7, "IssueInfoType"),
    :schema_element => [
      ["issueFirst", "SOAP::SOAPString", [0, 1]],
      ["issueLast", "SOAP::SOAPString", [0, 1]],
      ["volume", "VolumePairType", [0, 1]],
      ["sortDate", "SOAP::SOAPString"],
      ["dbItem", "DbItemType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceInfoResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceInfoRspPayload", "GetSourceInfoRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceInfoType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoType"),
    :schema_element => [
      ["getSourceInfoReqPayload", "GetSourceInfoReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceInfoReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceInfoReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["abstractsId", "[]", [1, nil]],
      ["suppressDummyRecords", nil],
      ["suppressAIP", nil],
      ["suppressDbItems", nil],
      ["suppressSubjectAreaList", nil],
      ["coverageRange", "CoverageRangeType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDsRequestType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsRequestType"),
    :schema_element => [
      ["getIDsRequestPayload", "GetIDsRequestPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDsRequestPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsRequestPayloadType"),
    :schema_element => [
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["keys", ["KeyType[]", XSD::QName.new(NsV7, "Keys")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => KeyType,
    :schema_type => XSD::QName.new(NsV7, "KeyType"),
    :schema_element => [
      ["clientCRF", nil],
      ["bibkeys", [nil, XSD::QName.new(NsV7, "Bibkeys")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDsResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getIDsResponsePayload", "GetIDsResponsePayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDsResponsePayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetIDsResponsePayloadType"),
    :schema_element => [
      ["dataResponseStyle", "DataResponseType"],
      ["stringBlob", nil, [0, 1]],
      ["iDList", ["IDListType", XSD::QName.new(NsV7, "IDList")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => IDListType,
    :schema_type => XSD::QName.new(NsV7, "IDListType"),
    :schema_element => [
      ["iDItem", ["IDItemType[]", XSD::QName.new(NsV7, "IDItem")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => IDItemType,
    :schema_type => XSD::QName.new(NsV7, "IDItemType"),
    :schema_element => [
      ["inputKey", "KeyType"],
      ["scopusID", ["[]", XSD::QName.new(NsV7, "ScopusID")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceYearInfoRspPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoRspPayloadType"),
    :schema_element => [
      ["cacheInfo", "CacheInfoType", [0, 1]],
      ["updatedDate", "SOAP::SOAPString", [0, 1]],
      ["sourceYearInfoList", "SourceYearInfoListType", [0, 1]],
      ["stringBlob", nil, [0, 1]],
      ["dataResponseStyle", "DataResponseType"]
    ]
  )

  LiteralRegistry.register(
    :class => SourceYearInfoListType,
    :schema_type => XSD::QName.new(NsV7, "SourceYearInfoListType"),
    :schema_element => [
      ["sourceYearInfo", "SourceYearInfoType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => SourceYearInfoType,
    :schema_type => XSD::QName.new(NsV7, "SourceYearInfoType"),
    :schema_element => [
      ["abstractsId", nil, [0, 1]],
      ["displayName", nil],
      ["sourceType", nil],
      ["issn", "[]", [0, nil]],
      ["publisherName", nil, [0, 1]],
      ["rank", nil, [0, 1]],
      ["coverageRange", "CoverageRangeType[]", [0, nil]],
      ["yearInfoList", "YearInfoListType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => YearInfoListType,
    :schema_type => XSD::QName.new(NsV7, "YearInfoListType"),
    :schema_element => [
      ["yearInfo", "YearInfoType[]", [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => YearInfoType,
    :schema_type => XSD::QName.new(NsV7, "YearInfoType"),
    :schema_element => [
      ["year", "SOAP::SOAPInteger", [0, 1]],
      ["citeCount", "SOAP::SOAPInteger", [0, 1]],
      ["publicationCount", "SOAP::SOAPInteger", [0, 1]],
      ["averageCount", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceYearInfoResponseType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoResponseType"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceYearInfoRspPayload", "GetSourceYearInfoRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceYearInfoType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoType"),
    :schema_element => [
      ["getSourceYearInfoReqPayload", "GetSourceYearInfoReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceYearInfoReqPayloadType,
    :schema_type => XSD::QName.new(NsV7, "GetSourceYearInfoReqPayloadType"),
    :schema_element => [
      ["cidQualifier", "CIDQualifierType", [0, 1]],
      ["absMetSource", "AbsMetSourceType"],
      ["responseStyle", "ResponseStyleType"],
      ["dataResponseStyle", "DataResponseType"],
      ["abstractsId", "[]", [1, nil]],
      ["coverageRange", "CoverageRangeType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => EIDListType,
    :schema_type => XSD::QName.new(NsV2, "EIDListType"),
    :schema_element => [
      ["eID", ["[]", XSD::QName.new(nil, "EID")], [1, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => RefKeyType,
    :schema_type => XSD::QName.new(NsV2, "RefKeyType"),
    :schema_element => [
      ["documentType", ["SOAP::SOAPString", XSD::QName.new(nil, "DocumentType")], [0, 1]],
      ["firstAuthorSurname", ["SOAP::SOAPString", XSD::QName.new(nil, "FirstAuthorSurname")]],
      ["yearOfPublication", ["SOAP::SOAPString", XSD::QName.new(nil, "YearOfPublication")]],
      ["firstPageNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "FirstPageNumber")]],
      ["lastPageNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "LastPageNumber")], [0, 1]],
      ["firstInitialFirstAuthor", ["SOAP::SOAPString", XSD::QName.new(nil, "FirstInitialFirstAuthor")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => IVIPType,
    :schema_type => XSD::QName.new(NsV2, "IVIPType"),
    :schema_element => [
      ["iSSN", [nil, XSD::QName.new(nil, "ISSN")]],
      ["iSBN", [nil, XSD::QName.new(nil, "ISBN")], [0, 1]],
      ["eISSN", [nil, XSD::QName.new(nil, "EISSN")], [0, 1]],
      ["volume", [nil, XSD::QName.new(nil, "Volume")]],
      ["issue", ["SOAP::SOAPString", XSD::QName.new(nil, "Issue")]],
      ["page", ["SOAP::SOAPString", XSD::QName.new(nil, "Page")]]
    ]
  )

  LiteralRegistry.register(
    :class => RequestChunkType,
    :schema_type => XSD::QName.new(NsV2, "RequestChunkType"),
    :schema_element => [
      ["positionHandle", ["SOAP::SOAPString", XSD::QName.new(nil, "positionHandle")], [0, 1]],
      ["maxItems", ["SOAP::SOAPInteger", XSD::QName.new(nil, "maxItems")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ResponseChunkType,
    :schema_type => XSD::QName.new(NsV2, "ResponseChunkType"),
    :schema_element => [
      ["nextPositionHandle", ["SOAP::SOAPString", XSD::QName.new(nil, "nextPositionHandle")], [0, 1]],
      ["itemCount", ["SOAP::SOAPInteger", XSD::QName.new(nil, "itemCount")]],
      ["integrityToken", ["SOAP::SOAPString", XSD::QName.new(nil, "integrityToken")]]
    ]
  )

  LiteralRegistry.register(
    :class => MetaDataStatusType,
    :schema_type => XSD::QName.new(NsV4, "MetaDataStatusType"),
    :schema_element => [
      ["statusCode", ["MetaDataStatusCodeType", XSD::QName.new(nil, "statusCode")]],
      ["statusText", ["SOAP::SOAPString", XSD::QName.new(nil, "statusText")]]
    ]
  )

  LiteralRegistry.register(
    :class => InputKeyType,
    :schema_type => XSD::QName.new(NsV4, "InputKeyType"),
    :schema_element => [
      ["doi", [nil, XSD::QName.new(nil, "doi")], [0, 1]],
      ["eid", [nil, XSD::QName.new(nil, "eid")], [0, 1]],
      ["scopusid", [nil, XSD::QName.new(nil, "scopusid")], [0, 1]],
      ["pii", [nil, XSD::QName.new(nil, "pii")], [0, 1]],
      ["issn", [nil, XSD::QName.new(nil, "issn")], [0, 1]],
      ["isbn", [nil, XSD::QName.new(nil, "isbn")], [0, 1]],
      ["eissn", [nil, XSD::QName.new(nil, "eissn")], [0, 1]],
      ["vol", [nil, XSD::QName.new(nil, "vol")], [0, 1]],
      ["issue", [nil, XSD::QName.new(nil, "issue")], [0, 1]],
      ["documenttype", [nil, XSD::QName.new(nil, "documenttype")], [0, 1]],
      ["firstAuthorSurname", [nil, XSD::QName.new(nil, "firstAuthorSurname")], [0, 1]],
      ["yearOfPublication", [nil, XSD::QName.new(nil, "yearOfPublication")], [0, 1]],
      ["firstPageNumber", [nil, XSD::QName.new(nil, "firstPageNumber")], [0, 1]],
      ["lastPageNumber", [nil, XSD::QName.new(nil, "lastPageNumber")], [0, 1]],
      ["firstInitialFirstAuthor", [nil, XSD::QName.new(nil, "firstInitialFirstAuthor")], [0, 1]],
      ["articleTitle", [nil, XSD::QName.new(nil, "articleTitle")], [0, 1]],
      ["clientCRF", [nil, XSD::QName.new(nil, "clientCRF")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEIDsRequestPayloadType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsRequestPayloadType"),
    :schema_element => [
      ["cIDQualifier", ["CIDQualifierType", XSD::QName.new(nil, "CIDQualifier")]],
      ["requestChunk", ["RequestChunkType", XSD::QName.new(nil, "requestChunk")]],
      ["dataResponseStyle", ["DataResponseType", XSD::QName.new(nil, "dataResponseStyle")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEIDsRequestType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsRequestType"),
    :schema_element => [
      ["getEIDsRequestPayload", ["GetEIDsRequestPayloadType", XSD::QName.new(nil, "getEIDsRequestPayload")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEIDsResponsePayloadType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsResponsePayloadType"),
    :schema_element => [
      ["responseChunk", ["ResponseChunkType", XSD::QName.new(nil, "responseChunk")]],
      ["dataResponseStyle", ["DataResponseType", XSD::QName.new(nil, "dataResponseStyle")]],
      ["eIDItem", ["EIDItemType[]", XSD::QName.new(nil, "EIDItem")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => EIDItemType,
    :schema_type => XSD::QName.new(NsV4, "EIDItemType"),
    :schema_element => [
      ["collectionList", ["CollectionListType", XSD::QName.new(nil, "collectionList")], [0, 1]],
      ["eID", [nil, XSD::QName.new(nil, "EID")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEIDsResponseType,
    :schema_type => XSD::QName.new(NsV4, "GetEIDsResponseType"),
    :schema_element => [
      ["status", ["MetaDataStatusType", XSD::QName.new(nil, "status")]],
      ["getEIDsResponsePayload", ["GetEIDsResponsePayloadType", XSD::QName.new(nil, "getEIDsResponsePayload")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => CIDQualifierType,
    :schema_type => XSD::QName.new(NsV2_0, "CIDQualifierType"),
    :schema_element => [
      ["cIDExpression", ["SOAP::SOAPString", XSD::QName.new(nil, "CIDExpression")]],
      ["returnCIDsList", ["CIDListType", XSD::QName.new(nil, "returnCIDsList")]],
      ["expandCIDsFlag", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "expandCIDsFlag")]],
      ["verboseFlag", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "verboseFlag")], [0, 1]],
      ["stampedCIDsFlag", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "stampedCIDsFlag")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => CIDListType,
    :schema_type => XSD::QName.new(NsV2_0, "CIDListType"),
    :schema_element => [
      ["cID", ["SOAP::SOAPString[]", XSD::QName.new(nil, "CID")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => CollectionListType,
    :schema_type => XSD::QName.new(NsV2_0, "CollectionListType"),
    :schema_element => [
      ["collection", ["CollectionType[]", XSD::QName.new(nil, "collection")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => CollectionType,
    :schema_type => XSD::QName.new(NsV2_0, "CollectionType"),
    :schema_element => [
      ["cID", ["SOAP::SOAPString", XSD::QName.new(nil, "CID")]],
      ["type", ["SOAP::SOAPString", XSD::QName.new(nil, "type")], [0, 1]],
      ["attribute", ["AttributeType[]", XSD::QName.new(nil, "attribute")], [0, nil]]
    ]
  )

  LiteralRegistry.register(
    :class => AttributeType,
    :schema_type => XSD::QName.new(NsV2_0, "AttributeType"),
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["value", ["SOAP::SOAPString", XSD::QName.new(nil, "value")]]
    ]
  )

  LiteralRegistry.register(
    :class => RequestHeaderType,
    :schema_type => XSD::QName.new(NsV1, "RequestHeaderType"),
    :schema_element => [
      ["transId", ["SOAP::SOAPString", XSD::QName.new(nil, "TransId")], [0, 1]],
      ["reqId", ["SOAP::SOAPString", XSD::QName.new(nil, "ReqId")]],
      ["ver", ["SOAP::SOAPString", XSD::QName.new(nil, "Ver")]],
      ["consumer", ["SOAP::SOAPString", XSD::QName.new(nil, "Consumer")]],
      ["consumerClient", ["SOAP::SOAPString", XSD::QName.new(nil, "ConsumerClient")], [0, 1]],
      ["opaqueInfo", ["SOAP::SOAPString", XSD::QName.new(nil, "OpaqueInfo")], [0, 1]],
      ["logLevel", ["LogLevelType", XSD::QName.new(nil, "LogLevel")]]
    ]
  )

  LiteralRegistry.register(
    :class => ResponseHeaderType,
    :schema_type => XSD::QName.new(NsV1, "ResponseHeaderType"),
    :schema_element => [
      ["transRespId", ["SOAP::SOAPString", XSD::QName.new(nil, "TransRespId")], [0, 1]],
      ["respId", ["SOAP::SOAPString", XSD::QName.new(nil, "RespId")]],
      ["serverId", ["SOAP::SOAPString", XSD::QName.new(nil, "ServerId")]]
    ]
  )

  LiteralRegistry.register(
    :class => AbsMetSourceType,
    :schema_type => XSD::QName.new(NsV7, "AbsMetSourceType")
  )

  LiteralRegistry.register(
    :class => AbsMetCacheType,
    :schema_type => XSD::QName.new(NsV7, "AbsMetCacheType")
  )

  LiteralRegistry.register(
    :class => NoDisplayType,
    :schema_type => XSD::QName.new(NsV7, "NoDisplayType")
  )

  LiteralRegistry.register(
    :class => DataResponseType,
    :schema_type => XSD::QName.new(NsV2, "DataResponseType")
  )

  LiteralRegistry.register(
    :class => MetaDataStatusCodeType,
    :schema_type => XSD::QName.new(NsV4, "MetaDataStatusCodeType")
  )

  LiteralRegistry.register(
    :class => CacheType,
    :schema_type => XSD::QName.new(NsV4, "CacheType")
  )

  LiteralRegistry.register(
    :class => ResponseStyleType,
    :schema_type => XSD::QName.new(NsV4, "ResponseStyleType")
  )

  LiteralRegistry.register(
    :class => LogLevelType,
    :schema_type => XSD::QName.new(NsV1, "LogLevelType")
  )

  LiteralRegistry.register(
    :class => GetPublishersType,
    :schema_name => XSD::QName.new(NsV7, "getPublishers"),
    :schema_element => [
      ["getPublishersReqPayload", "GetPublishersReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetPublishersResponseType,
    :schema_name => XSD::QName.new(NsV7, "getPublishersResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getPublishersRspPayload", "GetPublishersRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceMetadataType,
    :schema_name => XSD::QName.new(NsV7, "getSourceMetadata"),
    :schema_element => [
      ["getSourceMetadataReqPayload", "GetSourceMetadataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceMetadataResponseType,
    :schema_name => XSD::QName.new(NsV7, "getSourceMetadataResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceMetadataRspPayload", "GetSourceMetadataRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetDbMetadataType,
    :schema_name => XSD::QName.new(NsV7, "getDbMetadata"),
    :schema_element => [
      ["getDbMetadataReqPayload", "GetDbMetadataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetDbMetadataResponseType,
    :schema_name => XSD::QName.new(NsV7, "getDbMetadataResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getDbMetadataRspPayload", "GetDbMetadataRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetLinkDataType,
    :schema_name => XSD::QName.new(NsV7, "getLinkData"),
    :schema_element => [
      ["getLinkDataReqPayload", "GetLinkDataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetLinkDataResponseType,
    :schema_name => XSD::QName.new(NsV7, "getLinkDataResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getLinkDataRspPayload", "GetLinkDataRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetCitedByCountType,
    :schema_name => XSD::QName.new(NsV7, "getCitedByCount"),
    :schema_element => [
      ["getCitedByCountReqPayload", "GetLinkDataReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetCitedByCountResponseType,
    :schema_name => XSD::QName.new(NsV7, "getCitedByCountResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getCitedByCountRspPayload", "GetCitedByCountRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetTopicsType,
    :schema_name => XSD::QName.new(NsV7, "getTopics"),
    :schema_element => [
      ["getTopicsReqPayload", "GetTopicsReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetTopicsResponseType,
    :schema_name => XSD::QName.new(NsV7, "getTopicsResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getTopicsRspPayload", "GetTopicsRspPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => IsCacheCurrentType,
    :schema_name => XSD::QName.new(NsV7, "isCacheCurrent"),
    :schema_element => [
      ["isCacheCurrentReqPayload", "IsCacheCurrentReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => IsCacheCurrentResponseType,
    :schema_name => XSD::QName.new(NsV7, "isCacheCurrentResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["isCacheCurrentRspPayload", "IsCacheCurrentRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceInfoResponseType,
    :schema_name => XSD::QName.new(NsV7, "getSourceInfoResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceInfoRspPayload", "GetSourceInfoRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceInfoType,
    :schema_name => XSD::QName.new(NsV7, "getSourceInfo"),
    :schema_element => [
      ["getSourceInfoReqPayload", "GetSourceInfoReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetEIDsRequestType,
    :schema_name => XSD::QName.new(NsV7, "getEIDs"),
    :schema_element => [
      ["getEIDsRequestPayload", ["GetEIDsRequestPayloadType", XSD::QName.new(nil, "getEIDsRequestPayload")]]
    ]
  )

  LiteralRegistry.register(
    :class => GetEIDsResponseType,
    :schema_name => XSD::QName.new(NsV7, "getEIDsResponse"),
    :schema_element => [
      ["status", ["MetaDataStatusType", XSD::QName.new(nil, "status")]],
      ["getEIDsResponsePayload", ["GetEIDsResponsePayloadType", XSD::QName.new(nil, "getEIDsResponsePayload")], [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDsRequestType,
    :schema_name => XSD::QName.new(NsV7, "getIDs"),
    :schema_element => [
      ["getIDsRequestPayload", "GetIDsRequestPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => GetIDsResponseType,
    :schema_name => XSD::QName.new(NsV7, "getIDsResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getIDsResponsePayload", "GetIDsResponsePayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceYearInfoResponseType,
    :schema_name => XSD::QName.new(NsV7, "getSourceYearInfoResponse"),
    :schema_element => [
      ["status", "MetaDataStatusType"],
      ["getSourceYearInfoRspPayload", "GetSourceYearInfoRspPayloadType", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => GetSourceYearInfoType,
    :schema_name => XSD::QName.new(NsV7, "getSourceYearInfo"),
    :schema_element => [
      ["getSourceYearInfoReqPayload", "GetSourceYearInfoReqPayloadType"]
    ]
  )

  LiteralRegistry.register(
    :class => ResponseHeaderType,
    :schema_name => XSD::QName.new(NsV1, "EASIResp"),
    :schema_element => [
      ["transRespId", ["SOAP::SOAPString", XSD::QName.new(nil, "TransRespId")], [0, 1]],
      ["respId", ["SOAP::SOAPString", XSD::QName.new(nil, "RespId")]],
      ["serverId", ["SOAP::SOAPString", XSD::QName.new(nil, "ServerId")]]
    ]
  )

  LiteralRegistry.register(
    :class => RequestHeaderType,
    :schema_name => XSD::QName.new(NsV1, "EASIReq"),
    :schema_element => [
      ["transId", ["SOAP::SOAPString", XSD::QName.new(nil, "TransId")], [0, 1]],
      ["reqId", ["SOAP::SOAPString", XSD::QName.new(nil, "ReqId")]],
      ["ver", ["SOAP::SOAPString", XSD::QName.new(nil, "Ver")]],
      ["consumer", ["SOAP::SOAPString", XSD::QName.new(nil, "Consumer")]],
      ["consumerClient", ["SOAP::SOAPString", XSD::QName.new(nil, "ConsumerClient")], [0, 1]],
      ["opaqueInfo", ["SOAP::SOAPString", XSD::QName.new(nil, "OpaqueInfo")], [0, 1]],
      ["logLevel", ["LogLevelType", XSD::QName.new(nil, "LogLevel")]]
    ]
  )
end
