{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

{-| Data types for describing actions and data structures performed to interact
    with Elasticsearch. The two main buckets your queries against Elasticsearch
    will fall into are 'Query's and 'Filter's. 'Filter's are more like
    traditional database constraints and often have preferable performance
    properties. 'Query's support human-written textual queries, such as fuzzy
    queries.
-}

module Database.Bloodhound.Types
       ( defaultCache
       , defaultIndexSettings
       , halfRangeToKV
       , mkSort
       , rangeToKV
       , showText
       , unpackId
       , mkMatchQuery
       , mkMultiMatchQuery
       , mkBoolQuery
       , mkRangeQuery
       , mkQueryStringQuery
       , Version(..)
       , Status(..)
       , Existence(..)
       , NullValue(..)
       , IndexSettings(..)
       , Server(..)
       , Reply
       , EsResult(..)
       , Query(..)
       , Search(..)
       , SearchResult(..)
       , SearchHits(..)
       , ShardResult(..)
       , Hit(..)
       , Filter(..)
       , Seminearring(..)
       , BoolMatch(..)
       , Term(..)
       , GeoPoint(..)
       , GeoBoundingBoxConstraint(..)
       , GeoBoundingBox(..)
       , GeoFilterType(..)
       , Distance(..)
       , DistanceUnit(..)
       , DistanceType(..)
       , DistanceRange(..)
       , OptimizeBbox(..)
       , LatLon(..)
       , Range(..)
       , HalfRange(..)
       , RangeExecution(..)
       , LessThan(..)
       , LessThanEq(..)
       , GreaterThan(..)
       , GreaterThanEq(..)
       , Regexp(..)
       , RegexpFlags(..)
       , RegexpFlag(..)
       , FieldName(..)
       , IndexName(..)
       , MappingName(..)
       , DocId(..)
       , CacheName(..)
       , CacheKey(..)
       , BulkOperation(..)
       , ReplicaCount(..)
       , ShardCount(..)
       , Sort
       , SortMode(..)
       , SortOrder(..)
       , SortSpec(..)
       , DefaultSort(..)
       , Missing(..)
       , OpenCloseIndex(..)
       , Method
       , Boost(..)
       , MatchQuery(..)
       , MultiMatchQuery(..)
       , BoolQuery(..)
       , BoostingQuery(..)
       , CommonTermsQuery(..)
       , DisMaxQuery(..)
       , FilteredQuery(..)
       , FuzzyLikeThisQuery(..)
       , FuzzyLikeFieldQuery(..)
       , FuzzyQuery(..)
       , HasChildQuery(..)
       , HasParentQuery(..)
       , IndicesQuery(..)
       , MoreLikeThisQuery(..)
       , MoreLikeThisFieldQuery(..)
       , NestedQuery(..)
       , PrefixQuery(..)
       , QueryStringQuery(..)
       , SimpleQueryStringQuery(..)
       , RangeQuery(..)
       , RegexpQuery(..)
       , QueryString(..)
       , BooleanOperator(..)
       , ZeroTermsQuery(..)
       , CutoffFrequency(..)
       , Analyzer(..)
       , MaxExpansions(..)
       , Lenient(..)
       , MatchQueryType(..)
       , MultiMatchQueryType(..)
       , Tiebreaker(..)
       , MinimumMatch(..)
       , DisableCoord(..)
       , CommonMinimumMatch(..)
       , MinimumMatchHighLow(..)
       , PrefixLength(..)
       , Fuzziness(..)
       , IgnoreTermFrequency(..)
       , MaxQueryTerms(..)
       , ScoreType(..)
       , TypeName(..)
       , BoostTerms(..)
       , MaxWordLength(..)
       , MinWordLength(..)
       , MaxDocFrequency(..)
       , MinDocFrequency(..)
       , PhraseSlop(..)
       , StopWord(..)
       , QueryPath(..)
       , MinimumTermFrequency(..)
       , PercentMatch(..)
       , FieldDefinition(..)
       , MappingField(..)
       , Mapping(..)
       , AllowLeadingWildcard(..)
       , LowercaseExpanded(..)
       , GeneratePhraseQueries(..)
       , Locale(..)
       , AnalyzeWildcard(..)
       , EnablePositionIncrements(..)
       , SimpleQueryFlag(..)
       , FieldOrFields(..)
       , Monoid(..)
       , ToJSON(..)
         ) where

import Control.Applicative
import Data.Aeson
import Data.Aeson.Types (emptyObject)
import qualified Data.ByteString.Lazy.Char8 as L
import Data.List (nub)
import Data.List.NonEmpty (NonEmpty(..))
import Data.Monoid
import Data.Text (Text)
import qualified Data.Map as M
import qualified Data.Text as T
import Data.Time.Clock (UTCTime)
import GHC.Generics (Generic)
import Network.HTTP.Client
import qualified Network.HTTP.Types.Method as NHTM

import Database.Bloodhound.Types.Class


{-| 'Version' is embedded in 'Status' -}
data Version = Version { number          :: Text
                       , build_hash      :: Text
                       , build_timestamp :: UTCTime
                       , build_snapshot  :: Bool
                       , lucene_version  :: Text } deriving (Eq, Show, Generic)

{-| 'Status' is a data type for describing the JSON body returned by
    Elasticsearch when you query its status. This was deprecated in 1.2.0.

   <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-status.html#indices-status>
-}

data Status = Status { ok      :: Maybe Bool
                     , status  :: Int
                     , name    :: Text
                     , version :: Version
                     , tagline :: Text } deriving (Eq, Show)

{-| 'IndexSettings' is used to configure the shards and replicas when you create
   an Elasticsearch Index.

   <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-create-index.html>
-}

data IndexSettings =
  IndexSettings { indexShards   :: ShardCount
                , indexReplicas :: ReplicaCount } deriving (Eq, Show)

{-| 'defaultIndexSettings' is an 'IndexSettings' with 3 shards and 2 replicas. -}
defaultIndexSettings :: IndexSettings
defaultIndexSettings =  IndexSettings (ShardCount 3) (ReplicaCount 2)

{-| 'Reply' and 'Method' are type synonyms from 'Network.HTTP.Types.Method.Method' -}
type Reply = Network.HTTP.Client.Response L.ByteString
type Method = NHTM.Method

{-| 'OpenCloseIndex' is a sum type for opening and closing indices.

   <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-open-close.html>
-}
data OpenCloseIndex = OpenIndex | CloseIndex deriving (Eq, Show)

data FieldType = GeoPointType
               | GeoShapeType
               | FloatType
               | IntegerType
               | LongType
               | ShortType
               | ByteType deriving (Eq, Show)

data FieldDefinition =
  FieldDefinition { fieldType :: FieldType } deriving (Eq, Show)

data MappingField =
  MappingField   { mappingFieldName       :: FieldName
                 , fieldDefinition        :: FieldDefinition } deriving (Eq, Show)

{-| Support for type reification of 'Mapping's is currently incomplete, for
    now the mapping API verbiage expects a 'ToJSON'able blob.

    Indexes have mappings, mappings are schemas for the documents contained in the
    index. I'd recommend having only one mapping per index, always having a mapping,
    and keeping different kinds of documents separated if possible.
-}
data Mapping = Mapping { typeName      :: TypeName
                       , mappingFields :: [MappingField] } deriving (Eq, Show)

{-| 'BulkOperation' is a sum type for expressing the four kinds of bulk
    operation index, create, delete, and update. 'BulkIndex' behaves like an
    "upsert", 'BulkCreate' will fail if a document already exists at the DocId.

   <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-bulk.html#docs-bulk>
-}
data BulkOperation =
    BulkIndex  IndexName MappingName DocId Value
  | BulkCreate IndexName MappingName DocId Value
  | BulkDelete IndexName MappingName DocId
  | BulkUpdate IndexName MappingName DocId Value deriving (Eq, Show)

{-| 'EsResult' describes the standard wrapper JSON document that you see in
    successful Elasticsearch responses.
-}
data EsResult a = EsResult { _index   :: Text
                           , _type    :: Text
                           , _id      :: Text
                           , _version :: Int
                           , found    :: Maybe Bool
                           , _source  :: a } deriving (Eq, Show)

{-| 'Sort' is a synonym for a list of 'SortSpec's. Sort behavior is order
    dependent with later sorts acting as tie-breakers for earlier sorts.
-}
type Sort = [SortSpec]

{-| The two main kinds of 'SortSpec' are 'DefaultSortSpec' and
    'GeoDistanceSortSpec'. The latter takes a 'SortOrder', 'GeoPoint', and
    'DistanceUnit' to express "nearness" to a single geographical point as a
    sort specification.

<http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html#search-request-sort>
-}
data SortSpec = DefaultSortSpec DefaultSort
              | GeoDistanceSortSpec SortOrder GeoPoint DistanceUnit deriving (Eq, Show)

{-| 'DefaultSort' is usually the kind of 'SortSpec' you'll want. There's a
    'mkSort' convenience function for when you want to specify only the most
    common parameters.

<http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html#search-request-sort>
-}
data DefaultSort =
  DefaultSort { sortFieldName  :: FieldName
              , sortOrder      :: SortOrder
                                  -- default False
              , ignoreUnmapped :: Bool
              , sortMode       :: Maybe SortMode
              , missingSort    :: Maybe Missing
              , nestedFilter   :: Maybe Filter } deriving (Eq, Show)

{-| 'SortOrder' is 'Ascending' or 'Descending', as you might expect. These get
    encoded into "asc" or "desc" when turned into JSON.

<http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html#search-request-sort>
-}
data SortOrder = Ascending
               | Descending deriving (Eq, Show)

{-| 'Missing' prescribes how to handle missing fields. A missing field can be
    sorted last, first, or using a custom value as a substitute.

<http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html#_missing_values>
-}
data Missing = LastMissing
             | FirstMissing
             | CustomMissing Text deriving (Eq, Show)

{-| 'SortMode' prescribes how to handle sorting array/multi-valued fields.

http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html#_sort_mode_option
-}
data SortMode = SortMin
              | SortMax
              | SortSum
              | SortAvg deriving (Eq, Show)

{-| 'mkSort' defaults everything but the 'FieldName' and the 'SortOrder' so
    that you can concisely describe the usual kind of 'SortSpec's you want.
-}
mkSort :: FieldName -> SortOrder -> DefaultSort
mkSort fieldName sOrder = DefaultSort fieldName sOrder False Nothing Nothing Nothing

{-| 'Cache' is for telling ES whether it should cache a 'Filter' not.
    'Query's cannot be cached.
-}
type Cache   = Bool -- caching on/off
defaultCache :: Cache
defaultCache = False

{-| 'PrefixValue' is used in 'PrefixQuery' as the main query component.
-}
type PrefixValue = Text

{-| 'BooleanOperator' is the usual And/Or operators with an ES compatible
    JSON encoding baked in. Used all over the place.
-}
data BooleanOperator = And | Or deriving (Eq, Show)

{-| 'ShardCount' is part of 'IndexSettings'
-}
newtype ShardCount = ShardCount Int deriving (Eq, Show, Generic)

{-| 'ReplicaCount' is part of 'IndexSettings'
-}
newtype ReplicaCount = ReplicaCount Int deriving (Eq, Show, Generic)

{-| 'Server' is used with the client functions to point at the ES instance
-}
newtype Server = Server String deriving (Eq, Show)

{-| 'IndexName' is used to describe which index to query/create/delete
-}
newtype IndexName = IndexName String deriving (Eq, Generic, Show)

{-| 'MappingName' is part of mappings which are how ES describes and schematizes
    the data in the indices.
-}
newtype MappingName = MappingName String deriving (Eq, Generic, Show)

{-| 'DocId' is a generic wrapper value for expressing unique Document IDs.
    Can be set by the user or created by ES itself. Often used in client
    functions for poking at specific documents.
-}
newtype DocId = DocId String deriving (Eq, Generic, Show)

{-| 'QueryString' is used to wrap query text bodies, be they human written or not.
-}
newtype QueryString = QueryString Text deriving (Eq, Generic, Show)

{-| 'FieldName' is used all over the place wherever a specific field within
     a document needs to be specified, usually in 'Query's or 'Filter's.
-}
newtype FieldName = FieldName Text deriving (Eq, Show)

{-| 'CacheName' is used in 'RegexpFilter' for describing the
    'CacheKey' keyed caching behavior.
-}
newtype CacheName = CacheName Text deriving (Eq, Show)

{-| 'CacheKey' is used in 'RegexpFilter' to key regex caching.
-}
newtype CacheKey =
  CacheKey Text deriving (Eq, Show)
newtype Existence =
  Existence Bool deriving (Eq, Show)
newtype NullValue =
  NullValue Bool deriving (Eq, Show)
newtype CutoffFrequency =
  CutoffFrequency Double deriving (Eq, Show, Generic)
newtype Analyzer =
  Analyzer Text deriving (Eq, Show, Generic)
newtype MaxExpansions =
  MaxExpansions Int deriving (Eq, Show, Generic)

{-| 'Lenient', if set to true, will cause format based failures to be
    ignored. I don't know what the bloody default is, Elasticsearch
    documentation didn't say what it was. Let me know if you figure it out.
-}
newtype Lenient =
  Lenient Bool deriving (Eq, Show, Generic)
newtype Tiebreaker =
  Tiebreaker Double deriving (Eq, Show, Generic)
newtype Boost =
  Boost Double deriving (Eq, Show, Generic)
newtype BoostTerms =
  BoostTerms Double deriving (Eq, Show, Generic)

{-| 'MinimumMatch' controls how many should clauses in the bool query should
     match. Can be an absolute value (2) or a percentage (30%) or a
     combination of both.
-}
newtype MinimumMatch =
  MinimumMatch Int deriving (Eq, Show, Generic)
newtype MinimumMatchText =
  MinimumMatchText Text deriving (Eq, Show)
newtype DisableCoord =
  DisableCoord Bool deriving (Eq, Show, Generic)
newtype IgnoreTermFrequency =
  IgnoreTermFrequency Bool deriving (Eq, Show, Generic)
newtype MinimumTermFrequency =
  MinimumTermFrequency Int deriving (Eq, Show, Generic)
newtype MaxQueryTerms =
  MaxQueryTerms Int deriving (Eq, Show, Generic)
newtype Fuzziness =
  Fuzziness Double deriving (Eq, Show, Generic)

{-| 'PrefixLength' is the prefix length used in queries, defaults to 0. -}
newtype PrefixLength =
  PrefixLength Int deriving (Eq, Show, Generic)
newtype TypeName =
  TypeName Text deriving (Eq, Show, Generic)
newtype PercentMatch =
  PercentMatch Double deriving (Eq, Show, Generic)
newtype StopWord =
  StopWord Text deriving (Eq, Show, Generic)
newtype QueryPath =
  QueryPath Text deriving (Eq, Show, Generic)

{-| Allowing a wildcard at the beginning of a word (eg "*ing") is particularly
    heavy, because all terms in the index need to be examined, just in case
    they match. Leading wildcards can be disabled by setting
    'AllowLeadingWildcard' to false. -}
newtype AllowLeadingWildcard =
  AllowLeadingWildcard     Bool deriving (Eq, Show, Generic)
newtype LowercaseExpanded =
  LowercaseExpanded        Bool deriving (Eq, Show, Generic)
newtype EnablePositionIncrements =
  EnablePositionIncrements Bool deriving (Eq, Show, Generic)

{-| By default, wildcard terms in a query are not analyzed.
    Setting 'AnalyzeWildcard' to true enables best-effort analysis.
-}
newtype AnalyzeWildcard = AnalyzeWildcard Bool deriving (Eq, Show, Generic)

{-| 'GeneratePhraseQueries' defaults to false.
-}
newtype GeneratePhraseQueries =
  GeneratePhraseQueries Bool deriving (Eq, Show, Generic)

{-| 'Locale' is used for string conversions - defaults to ROOT.
-}
newtype Locale        = Locale        Text deriving (Eq, Show, Generic)
newtype MaxWordLength = MaxWordLength Int  deriving (Eq, Show, Generic)
newtype MinWordLength = MinWordLength Int  deriving (Eq, Show, Generic)

{-| 'PhraseSlop' sets the default slop for phrases, 0 means exact
     phrase matches. Default is 0.
-}
newtype PhraseSlop      = PhraseSlop      Int deriving (Eq, Show, Generic)
newtype MinDocFrequency = MinDocFrequency Int deriving (Eq, Show, Generic)
newtype MaxDocFrequency = MaxDocFrequency Int deriving (Eq, Show, Generic)

{-| 'unpackId' is a silly convenience function that gets used once.
-}
unpackId :: DocId -> String
unpackId (DocId docId) = docId

type TrackSortScores = Bool
type From = Int
type Size = Int

data Search = Search { queryBody  :: Maybe Query
                     , filterBody :: Maybe Filter
                     , sortBody   :: Maybe Sort
                     , aggBody :: Maybe Aggregations
                       -- default False
                     , trackSortScores :: TrackSortScores
                     , from :: From
                     , size :: Size } deriving (Eq, Show)

data Query =
  TermQuery                     Term (Maybe Boost)
  | TermsQuery                  [Term] MinimumMatch
  | QueryMatchQuery             MatchQuery
  | QueryMultiMatchQuery        MultiMatchQuery
  | QueryBoolQuery              BoolQuery
  | QueryBoostingQuery          BoostingQuery
  | QueryCommonTermsQuery       CommonTermsQuery
  | ConstantScoreFilter         Filter Boost
  | ConstantScoreQuery          Query Boost
  | QueryDisMaxQuery            DisMaxQuery
  | QueryFilteredQuery          FilteredQuery
  | QueryFuzzyLikeThisQuery     FuzzyLikeThisQuery
  | QueryFuzzyLikeFieldQuery    FuzzyLikeFieldQuery
  | QueryFuzzyQuery             FuzzyQuery
  | QueryHasChildQuery          HasChildQuery
  | QueryHasParentQuery         HasParentQuery
  | IdsQuery                    MappingName [DocId]
  | QueryIndicesQuery           IndicesQuery
  | MatchAllQuery               (Maybe Boost)
  | QueryMoreLikeThisQuery      MoreLikeThisQuery
  | QueryMoreLikeThisFieldQuery MoreLikeThisFieldQuery
  | QueryNestedQuery            NestedQuery
  | QueryPrefixQuery            PrefixQuery
  | QueryQueryStringQuery       QueryStringQuery
  | QuerySimpleQueryStringQuery SimpleQueryStringQuery
  | QueryRangeQuery             RangeQuery
  | QueryRegexpQuery            RegexpQuery
  deriving (Eq, Show)

data RegexpQuery =
  RegexpQuery { regexpQueryField     :: FieldName
              , regexpQuery          :: Regexp
              , regexpQueryFlags     :: RegexpFlags
              , regexpQueryBoost     :: Maybe Boost
              } deriving (Eq, Show)

data RangeQuery =
  RangeQuery { rangeQueryField :: FieldName
             , rangeQueryRange :: Either HalfRange Range
             , rangeQueryBoost :: Boost } deriving (Eq, Show)

mkRangeQuery :: FieldName -> Either HalfRange Range -> RangeQuery
mkRangeQuery f r = RangeQuery f r (Boost 1.0)

data SimpleQueryStringQuery =
  SimpleQueryStringQuery
    { simpleQueryStringQuery             :: QueryString
    , simpleQueryStringField             :: Maybe FieldOrFields
    , simpleQueryStringOperator          :: Maybe BooleanOperator
    , simpleQueryStringAnalyzer          :: Maybe Analyzer
    , simpleQueryStringFlags             :: Maybe [SimpleQueryFlag]
    , simpleQueryStringLowercaseExpanded :: Maybe LowercaseExpanded
    , simpleQueryStringLocale            :: Maybe Locale
    } deriving (Eq, Show)

data SimpleQueryFlag =
  SimpleQueryAll
  | SimpleQueryNone
  | SimpleQueryAnd
  | SimpleQueryOr
  | SimpleQueryPrefix
  | SimpleQueryPhrase
  | SimpleQueryPrecedence
  | SimpleQueryEscape
  | SimpleQueryWhitespace
  | SimpleQueryFuzzy
  | SimpleQueryNear
  | SimpleQuerySlop deriving (Eq, Show)

-- use_dis_max and tie_breaker when fields are plural?
data QueryStringQuery =
  QueryStringQuery
  { queryStringQuery                    :: QueryString
  , queryStringDefaultField             :: Maybe FieldName
  , queryStringOperator                 :: Maybe BooleanOperator
  , queryStringAnalyzer                 :: Maybe Analyzer
  , queryStringAllowLeadingWildcard     :: Maybe AllowLeadingWildcard
  , queryStringLowercaseExpanded        :: Maybe LowercaseExpanded
  , queryStringEnablePositionIncrements :: Maybe EnablePositionIncrements
  , queryStringFuzzyMaxExpansions       :: Maybe MaxExpansions
  , queryStringFuzziness                :: Maybe Fuzziness
  , queryStringFuzzyPrefixLength        :: Maybe PrefixLength
  , queryStringPhraseSlop               :: Maybe PhraseSlop
  , queryStringBoost                    :: Maybe Boost
  , queryStringAnalyzeWildcard          :: Maybe AnalyzeWildcard
  , queryStringGeneratePhraseQueries    :: Maybe GeneratePhraseQueries
  , queryStringMinimumShouldMatch       :: Maybe MinimumMatch
  , queryStringLenient                  :: Maybe Lenient
  , queryStringLocale                   :: Maybe Locale
  } deriving (Eq, Show)

mkQueryStringQuery :: QueryString -> QueryStringQuery
mkQueryStringQuery qs =
  QueryStringQuery qs Nothing Nothing
  Nothing Nothing Nothing Nothing
  Nothing Nothing Nothing Nothing
  Nothing Nothing Nothing Nothing
  Nothing Nothing

data FieldOrFields = FofField   FieldName
                   | FofFields [FieldName] deriving (Eq, Show)

data PrefixQuery =
  PrefixQuery
  { prefixQueryField       :: FieldName
  , prefixQueryPrefixValue :: Text
  , prefixQueryBoost       :: Maybe Boost } deriving (Eq, Show)

data NestedQuery =
  NestedQuery
  { nestedQueryPath      :: QueryPath
  , nestedQueryScoreType :: ScoreType
  , nestedQuery          :: Query } deriving (Eq, Show)

data MoreLikeThisFieldQuery =
  MoreLikeThisFieldQuery
  { moreLikeThisFieldText            :: Text
  , moreLikeThisFieldFields          :: FieldName
                                        -- default 0.3 (30%)
  , moreLikeThisFieldPercentMatch    :: Maybe PercentMatch
  , moreLikeThisFieldMinimumTermFreq :: Maybe MinimumTermFrequency
  , moreLikeThisFieldMaxQueryTerms   :: Maybe MaxQueryTerms
  , moreLikeThisFieldStopWords       :: Maybe [StopWord]
  , moreLikeThisFieldMinDocFrequency :: Maybe MinDocFrequency
  , moreLikeThisFieldMaxDocFrequency :: Maybe MaxDocFrequency
  , moreLikeThisFieldMinWordLength   :: Maybe MinWordLength
  , moreLikeThisFieldMaxWordLength   :: Maybe MaxWordLength
  , moreLikeThisFieldBoostTerms      :: Maybe BoostTerms
  , moreLikeThisFieldBoost           :: Maybe Boost
  , moreLikeThisFieldAnalyzer        :: Maybe Analyzer
  } deriving (Eq, Show)

data MoreLikeThisQuery =
  MoreLikeThisQuery
  { moreLikeThisText            :: Text
  , moreLikeThisFields          :: Maybe [FieldName]
    -- default 0.3 (30%)
  , moreLikeThisPercentMatch    :: Maybe PercentMatch
  , moreLikeThisMinimumTermFreq :: Maybe MinimumTermFrequency
  , moreLikeThisMaxQueryTerms   :: Maybe MaxQueryTerms
  , moreLikeThisStopWords       :: Maybe [StopWord]
  , moreLikeThisMinDocFrequency :: Maybe MinDocFrequency
  , moreLikeThisMaxDocFrequency :: Maybe MaxDocFrequency
  , moreLikeThisMinWordLength   :: Maybe MinWordLength
  , moreLikeThisMaxWordLength   :: Maybe MaxWordLength
  , moreLikeThisBoostTerms      :: Maybe BoostTerms
  , moreLikeThisBoost           :: Maybe Boost
  , moreLikeThisAnalyzer        :: Maybe Analyzer
  } deriving (Eq, Show)

data IndicesQuery =
  IndicesQuery
  { indicesQueryIndices :: [IndexName]
  , indicesQuery          :: Query
    -- default "all"
  , indicesQueryNoMatch   :: Maybe Query } deriving (Eq, Show)

data HasParentQuery =
  HasParentQuery
  { hasParentQueryType      :: TypeName
  , hasParentQuery          :: Query
  , hasParentQueryScoreType :: Maybe ScoreType } deriving (Eq, Show)

data HasChildQuery =
  HasChildQuery
  { hasChildQueryType      :: TypeName
  , hasChildQuery          :: Query
  , hasChildQueryScoreType :: Maybe ScoreType } deriving (Eq, Show)

data ScoreType =
  ScoreTypeMax
  | ScoreTypeSum
  | ScoreTypeAvg
  | ScoreTypeNone deriving (Eq, Show)

data FuzzyQuery =
  FuzzyQuery { fuzzyQueryField         :: FieldName
             , fuzzyQueryValue         :: Text
             , fuzzyQueryPrefixLength  :: PrefixLength
             , fuzzyQueryMaxExpansions :: MaxExpansions
             , fuzzyQueryFuzziness     :: Fuzziness
             , fuzzyQueryBoost         :: Maybe Boost
             } deriving (Eq, Show)

data FuzzyLikeFieldQuery =
  FuzzyLikeFieldQuery
  { fuzzyLikeField                    :: FieldName
    -- anaphora is good for the soul.
  , fuzzyLikeFieldText                :: Text
  , fuzzyLikeFieldMaxQueryTerms       :: MaxQueryTerms
  , fuzzyLikeFieldIgnoreTermFrequency :: IgnoreTermFrequency
  , fuzzyLikeFieldFuzziness           :: Fuzziness
  , fuzzyLikeFieldPrefixLength        :: PrefixLength
  , fuzzyLikeFieldBoost               :: Boost
  , fuzzyLikeFieldAnalyzer            :: Maybe Analyzer
  } deriving (Eq, Show)

data FuzzyLikeThisQuery =
  FuzzyLikeThisQuery
  { fuzzyLikeFields              :: [FieldName]
  , fuzzyLikeText                :: Text
  , fuzzyLikeMaxQueryTerms       :: MaxQueryTerms
  , fuzzyLikeIgnoreTermFrequency :: IgnoreTermFrequency
  , fuzzyLikeFuzziness           :: Fuzziness
  , fuzzyLikePrefixLength        :: PrefixLength
  , fuzzyLikeBoost               :: Boost
  , fuzzyLikeAnalyzer            :: Maybe Analyzer
  } deriving (Eq, Show)

data FilteredQuery =
  FilteredQuery
  { filteredQuery  :: Query
  , filteredFilter :: Filter } deriving (Eq, Show)

data DisMaxQuery =
  DisMaxQuery { disMaxQueries    :: [Query]
                -- default 0.0
              , disMaxTiebreaker :: Tiebreaker
              , disMaxBoost      :: Maybe Boost
              } deriving (Eq, Show)

data MatchQuery =
  MatchQuery { matchQueryField           :: FieldName
             , matchQueryQueryString     :: QueryString
             , matchQueryOperator        :: BooleanOperator
             , matchQueryZeroTerms       :: ZeroTermsQuery
             , matchQueryCutoffFrequency :: Maybe CutoffFrequency
             , matchQueryMatchType       :: Maybe MatchQueryType
             , matchQueryAnalyzer        :: Maybe Analyzer
             , matchQueryMaxExpansions   :: Maybe MaxExpansions
             , matchQueryLenient         :: Maybe Lenient } deriving (Eq, Show)

{-| 'mkMatchQuery' is a convenience function that defaults the less common parameters,
    enabling you to provide only the 'FieldName' and 'QueryString' to make a 'MatchQuery'
-}
mkMatchQuery :: FieldName -> QueryString -> MatchQuery
mkMatchQuery field query = MatchQuery field query Or ZeroTermsNone Nothing Nothing Nothing Nothing Nothing

data MatchQueryType =
  MatchPhrase
  | MatchPhrasePrefix deriving (Eq, Show)

data MultiMatchQuery =
  MultiMatchQuery { multiMatchQueryFields          :: [FieldName]
                  , multiMatchQueryString          :: QueryString
                  , multiMatchQueryOperator        :: BooleanOperator
                  , multiMatchQueryZeroTerms       :: ZeroTermsQuery
                  , multiMatchQueryTiebreaker      :: Maybe Tiebreaker
                  , multiMatchQueryType            :: Maybe MultiMatchQueryType
                  , multiMatchQueryCutoffFrequency :: Maybe CutoffFrequency
                  , multiMatchQueryAnalyzer        :: Maybe Analyzer
                  , multiMatchQueryMaxExpansions   :: Maybe MaxExpansions
                  , multiMatchQueryLenient         :: Maybe Lenient } deriving (Eq, Show)

{-| 'mkMultiMatchQuery' is a convenience function that defaults the less common parameters,
    enabling you to provide only the list of 'FieldName's and 'QueryString' to
    make a 'MultiMatchQuery'.
-}

mkMultiMatchQuery :: [FieldName] -> QueryString -> MultiMatchQuery
mkMultiMatchQuery matchFields query =
  MultiMatchQuery matchFields query
  Or ZeroTermsNone Nothing Nothing Nothing Nothing Nothing Nothing

data MultiMatchQueryType =
  MultiMatchBestFields
  | MultiMatchMostFields
  | MultiMatchCrossFields
  | MultiMatchPhrase
  | MultiMatchPhrasePrefix deriving (Eq, Show)

data BoolQuery =
  BoolQuery { boolQueryMustMatch          :: Maybe Query
            , boolQueryMustNotMatch       :: Maybe Query
            , boolQueryShouldMatch        :: Maybe [Query]
            , boolQueryMinimumShouldMatch :: Maybe MinimumMatch
            , boolQueryBoost              :: Maybe Boost
            , boolQueryDisableCoord       :: Maybe DisableCoord
            } deriving (Eq, Show)

mkBoolQuery :: Maybe Query -> Maybe Query -> Maybe [Query] -> BoolQuery
mkBoolQuery must mustNot should =
  BoolQuery must mustNot should Nothing Nothing Nothing

data BoostingQuery =
  BoostingQuery { positiveQuery :: Query
                , negativeQuery :: Query
                , negativeBoost :: Boost } deriving (Eq, Show)

data CommonTermsQuery =
  CommonTermsQuery { commonField              :: FieldName
                   , commonQuery              :: QueryString
                   , commonCutoffFrequency    :: CutoffFrequency
                   , commonLowFreqOperator    :: BooleanOperator
                   , commonHighFreqOperator   :: BooleanOperator
                   , commonMinimumShouldMatch :: Maybe CommonMinimumMatch
                   , commonBoost              :: Maybe Boost
                   , commonAnalyzer           :: Maybe Analyzer
                   , commonDisableCoord       :: Maybe DisableCoord
                   } deriving (Eq, Show)

data CommonMinimumMatch =
    CommonMinimumMatchHighLow MinimumMatchHighLow
  | CommonMinimumMatch        MinimumMatch
  deriving (Eq, Show)

data MinimumMatchHighLow =
  MinimumMatchHighLow { lowFreq :: MinimumMatch
                      , highFreq :: MinimumMatch } deriving (Eq, Show)

data Filter = AndFilter [Filter] Cache
            | OrFilter  [Filter] Cache
            | NotFilter  Filter  Cache
            | IdentityFilter
            | BoolFilter BoolMatch
            | ExistsFilter FieldName -- always cached
            | GeoBoundingBoxFilter GeoBoundingBoxConstraint
            | GeoDistanceFilter GeoPoint Distance DistanceType OptimizeBbox Cache
            | GeoDistanceRangeFilter GeoPoint DistanceRange
            | GeoPolygonFilter FieldName [LatLon]
            | IdsFilter MappingName [DocId]
            | LimitFilter Int
            | MissingFilter FieldName Existence NullValue
            | PrefixFilter  FieldName PrefixValue Cache
            | RangeFilter   FieldName (Either HalfRange Range) RangeExecution Cache
            | RegexpFilter  FieldName Regexp RegexpFlags CacheName Cache CacheKey
            | TermFilter    Term Cache
              deriving (Eq, Show)

data ZeroTermsQuery = ZeroTermsNone
                    | ZeroTermsAll deriving (Eq, Show)

-- lt, lte | gt, gte
newtype LessThan      = LessThan      Double deriving (Eq, Show)
newtype LessThanEq    = LessThanEq    Double deriving (Eq, Show)
newtype GreaterThan   = GreaterThan   Double deriving (Eq, Show)
newtype GreaterThanEq = GreaterThanEq Double deriving (Eq, Show)

data HalfRange = HalfRangeLt  LessThan
               | HalfRangeLte LessThanEq
               | HalfRangeGt  GreaterThan
               | HalfRangeGte GreaterThanEq deriving (Eq, Show)

data Range = RangeLtGt   LessThan GreaterThan
           | RangeLtGte  LessThan GreaterThanEq
           | RangeLteGt  LessThanEq GreaterThan
           | RangeLteGte LessThanEq GreaterThanEq deriving (Eq, Show)

data RangeExecution = RangeExecutionIndex
                    | RangeExecutionFielddata deriving (Eq, Show)

newtype Regexp = Regexp Text deriving (Eq, Show)

data RegexpFlags = AllRegexpFlags
                 | NoRegexpFlags
                 | SomeRegexpFlags (NonEmpty RegexpFlag) deriving (Eq, Show)

data RegexpFlag = AnyString
                | Automaton
                | Complement
                | Empty
                | Intersection
                | Interval deriving (Eq, Show)

halfRangeToKV :: HalfRange -> (Text, Double)
halfRangeToKV (HalfRangeLt  (LessThan n))      = ("lt",  n)
halfRangeToKV (HalfRangeLte (LessThanEq n))    = ("lte", n)
halfRangeToKV (HalfRangeGt  (GreaterThan n))   = ("gt",  n)
halfRangeToKV (HalfRangeGte (GreaterThanEq n)) = ("gte", n)

rangeToKV :: Range -> (Text, Double, Text, Double)
rangeToKV (RangeLtGt   (LessThan m)   (GreaterThan   n)) = ("lt",  m, "gt",  n)
rangeToKV (RangeLtGte  (LessThan m)   (GreaterThanEq n)) = ("lt",  m, "gte", n)
rangeToKV (RangeLteGt  (LessThanEq m) (GreaterThan   n)) = ("lte", m, "gt",  n)
rangeToKV (RangeLteGte (LessThanEq m) (GreaterThanEq n)) = ("lte", m, "gte", n)

-- phew. Coulda used Agda style case breaking there but, you know, whatever. :)

data Term = Term { termField :: Text
                 , termValue :: Text } deriving (Eq, Show)

data BoolMatch = MustMatch    Term  Cache
               | MustNotMatch Term  Cache
               | ShouldMatch [Term] Cache deriving (Eq, Show)

-- "memory" or "indexed"
data GeoFilterType = GeoFilterMemory
                   | GeoFilterIndexed deriving (Eq, Show)

data LatLon = LatLon { lat :: Double
                     , lon :: Double } deriving (Eq, Show)

data GeoBoundingBox =
  GeoBoundingBox { topLeft     :: LatLon
                 , bottomRight :: LatLon } deriving (Eq, Show)

data GeoBoundingBoxConstraint =
  GeoBoundingBoxConstraint { geoBBField        :: FieldName
                           , constraintBox     :: GeoBoundingBox
                           , bbConstraintcache :: Cache
                           , geoType           :: GeoFilterType
                           } deriving (Eq, Show)

data GeoPoint =
  GeoPoint { geoField :: FieldName
           , latLon   :: LatLon} deriving (Eq, Show)

data DistanceUnit = Miles
                  | Yards
                  | Feet
                  | Inches
                  | Kilometers
                  | Meters
                  | Centimeters
                  | Millimeters
                  | NauticalMiles deriving (Eq, Show)

data DistanceType = Arc
                  | SloppyArc -- doesn't exist <1.0
                  | Plane deriving (Eq, Show)

data OptimizeBbox = OptimizeGeoFilterType GeoFilterType
                  | NoOptimizeBbox deriving (Eq, Show)

data Distance =
  Distance { coefficient :: Double
           , unit        :: DistanceUnit } deriving (Eq, Show)

data DistanceRange =
  DistanceRange { distanceFrom :: Distance
                , distanceTo   :: Distance } deriving (Eq, Show)

data FromJSON a => SearchResult a =
  SearchResult { took       :: Int
               , timedOut   :: Bool
               , shards     :: ShardResult
               , searchHits :: SearchHits a } deriving (Eq, Show)

type Score = Double

data FromJSON a => SearchHits a =
  SearchHits { hitsTotal :: Int
             , maxScore  :: Score
             , hits      :: [Hit a] } deriving (Eq, Show)

data FromJSON a => Hit a =
  Hit { hitIndex      :: IndexName
      , hitType       :: MappingName
      , hitDocId      :: DocId
      , hitScore      :: Score
      , hitSource     :: a } deriving (Eq, Show)

data ShardResult =
  ShardResult { shardTotal       :: Int
              , shardsSuccessful :: Int
              , shardsFailed     :: Int } deriving (Eq, Show, Generic)

showText :: Show a => a -> Text
showText = T.pack . show

type Aggregations = M.Map Text Aggregation
  
data Aggregation = TermsAggregation { term :: Term
                                    , aggs :: Maybe [(Text, Aggregations)]
                                    }
                 | DateHistogramAggregation { field :: FieldName } deriving (Eq, Show)


instance ToJSON Aggregation where
  toJSON (TermsAggregation term aggs) =
    object ["terms" .= (object [ (termField term) .= (toJSON $ termValue term)]),
            "aggs" .= (toJSON aggs) ]

  toJSON (DateHistogramAggregation field) = emptyObject

instance Monoid Filter where
  mempty = IdentityFilter
  mappend a b = AndFilter [a, b] defaultCache

instance Seminearring Filter where
  a <||> b = OrFilter [a, b] defaultCache

instance ToJSON Filter where
  toJSON (AndFilter filters cache) =
    object ["and"     .=
            object [ "filters" .= fmap toJSON filters
                   , "_cache" .= cache]]

  toJSON (OrFilter filters cache) =
    object ["or"      .= fmap toJSON filters
           , "_cache" .= cache]

  toJSON (NotFilter notFilter cache) =
    object ["not" .=
            object ["filter"  .= toJSON notFilter
                   , "_cache" .= cache]]

  toJSON (IdentityFilter) =
    object ["match_all" .= object []]

  toJSON (TermFilter (Term termFilterField termFilterValue) cache) =
    object ["term" .= object base]
    where base = [termFilterField .= termFilterValue,
                  "_cache"        .= cache]

  toJSON (ExistsFilter (FieldName fieldName)) =
    object ["exists"  .= object
            ["field"  .= fieldName]]

  toJSON (BoolFilter boolMatch) =
    object ["bool"    .= toJSON boolMatch]

  toJSON (GeoBoundingBoxFilter bbConstraint) =
    object ["geo_bounding_box" .= toJSON bbConstraint]

  toJSON (GeoDistanceFilter (GeoPoint (FieldName distanceGeoField) geoDistLatLon)
          distance distanceType optimizeBbox cache) =
    object ["geo_distance" .=
            object ["distance" .= toJSON distance
                   , "distance_type" .= toJSON distanceType
                   , "optimize_bbox" .= optimizeBbox
                   , distanceGeoField .= toJSON geoDistLatLon
                   , "_cache" .= cache]]

  toJSON (GeoDistanceRangeFilter (GeoPoint (FieldName gddrField) drLatLon)
          (DistanceRange geoDistRangeDistFrom drDistanceTo)) =
    object ["geo_distance_range" .=
            object ["from" .= toJSON geoDistRangeDistFrom
                   , "to"  .= toJSON drDistanceTo
                   , gddrField .= toJSON drLatLon]]

  toJSON (GeoPolygonFilter (FieldName geoPolygonFilterField) latLons) =
    object ["geo_polygon" .=
            object [geoPolygonFilterField .=
                    object ["points" .= fmap toJSON latLons]]]

  toJSON (IdsFilter (MappingName mappingName) values) =
    object ["ids" .=
            object ["type" .= mappingName
                   , "values" .= fmap (T.pack . unpackId) values]]

  toJSON (LimitFilter limit) =
    object ["limit" .= object ["value" .= limit]]

  toJSON (MissingFilter (FieldName fieldName) (Existence existence) (NullValue nullValue)) =
    object ["missing" .=
            object ["field"       .= fieldName
                   , "existence"  .= existence
                   , "null_value" .= nullValue]]

  toJSON (PrefixFilter (FieldName fieldName) fieldValue cache) =
    object ["prefix" .=
            object [fieldName .= fieldValue
                   , "_cache" .= cache]]

  toJSON (RangeFilter (FieldName fieldName) (Left halfRange) rangeExecution cache) =
    object ["range" .=
            object [fieldName .=
                    object [key .= val]
                   , "execution" .= toJSON rangeExecution
                   , "_cache" .= cache]]
    where
      (key, val) = halfRangeToKV halfRange

  toJSON (RangeFilter (FieldName fieldName) (Right range) rangeExecution cache) =
    object ["range" .=
            object [fieldName .=
                    object [lessKey .= lessVal
                           , greaterKey .= greaterVal]
                   , "execution" .= toJSON rangeExecution
                   , "_cache" .= cache]]
    where
      (lessKey, lessVal, greaterKey, greaterVal) = rangeToKV range

  toJSON (RegexpFilter (FieldName fieldName)
          (Regexp regexText) flags (CacheName cacheName) cache (CacheKey cacheKey)) =
    object ["regexp" .=
            object [fieldName .=
                    object ["value"  .= regexText
                           , "flags" .= toJSON flags]
                   , "_name"      .= cacheName
                   , "_cache"     .= cache
                   , "_cache_key" .= cacheKey]]

instance ToJSON GeoPoint where
  toJSON (GeoPoint (FieldName geoPointField) geoPointLatLon) =
    object [ geoPointField  .= toJSON geoPointLatLon ]


instance ToJSON Query where
  toJSON (TermQuery (Term termQueryField termQueryValue) boost) =
    object [ "term" .=
             object [termQueryField .= object merged]]
    where
      base = [ "value" .= termQueryValue ]
      boosted = maybe [] (return . ("boost" .=)) boost
      merged = mappend base boosted

  toJSON (TermsQuery terms termsQueryMinimumMatch) =
    object [ "terms" .= object conjoined ]
    where conjoined =
            [ "tags"                 .= fmap toJSON terms
            , "minimum_should_match" .= toJSON termsQueryMinimumMatch ]

  toJSON (IdsQuery idsQueryMappingName docIds) =
    object [ "ids" .= object conjoined ]
    where conjoined = [ "type"   .= toJSON idsQueryMappingName
                      , "values" .= fmap toJSON docIds ]

  toJSON (QueryQueryStringQuery qQueryStringQuery) =
    object [ "query_string" .= toJSON qQueryStringQuery ]

  toJSON (QueryMatchQuery matchQuery) =
    object [ "match" .= toJSON matchQuery ]

  toJSON (QueryMultiMatchQuery multiMatchQuery) =
    object [ "multi_match" .= toJSON multiMatchQuery ]

  toJSON (QueryBoolQuery boolQuery) =
    object [ "bool" .= toJSON boolQuery ]

  toJSON (QueryBoostingQuery boostingQuery) =
    object [ "boosting" .= toJSON boostingQuery ]

  toJSON (QueryCommonTermsQuery commonTermsQuery) =
    object [ "common" .= toJSON commonTermsQuery ]

  toJSON (ConstantScoreFilter csFilter boost) =
    object [ "constant_score" .= toJSON csFilter
           , "boost" .= toJSON boost]

  toJSON (ConstantScoreQuery query boost) =
    object [ "constant_score" .= toJSON query
           , "boost"          .= toJSON boost]

  toJSON (QueryDisMaxQuery disMaxQuery) =
    object [ "dis_max" .= toJSON disMaxQuery ]

  toJSON (QueryFilteredQuery qFilteredQuery) =
    object [ "filtered" .= toJSON qFilteredQuery ]

  toJSON (QueryFuzzyLikeThisQuery fuzzyQuery) =
    object [ "fuzzy_like_this" .= toJSON fuzzyQuery ]

  toJSON (QueryFuzzyLikeFieldQuery fuzzyFieldQuery) =
    object [ "fuzzy_like_this_field" .= toJSON fuzzyFieldQuery ]

  toJSON (QueryFuzzyQuery fuzzyQuery) =
    object [ "fuzzy" .= toJSON fuzzyQuery ]

  toJSON (QueryHasChildQuery childQuery) =
    object [ "has_child" .= toJSON childQuery ]

  toJSON (QueryHasParentQuery parentQuery) =
    object [ "has_parent" .= toJSON parentQuery ]

  toJSON (QueryIndicesQuery qIndicesQuery) =
    object [ "indices" .= toJSON qIndicesQuery ]

  toJSON (MatchAllQuery boost) =
    object [ "match_all" .= omitNulls [ "boost" .= boost ] ]

  toJSON (QueryMoreLikeThisQuery query) =
    object [ "more_like_this" .= toJSON query ]

  toJSON (QueryMoreLikeThisFieldQuery query) =
    object [ "more_like_this_field" .= toJSON query ]

  toJSON (QueryNestedQuery query) =
    object [ "nested" .= toJSON query ]

  toJSON (QueryPrefixQuery query) =
    object [ "prefix" .= toJSON query ]

  toJSON (QueryRangeQuery query) =
    object [ "range"  .= toJSON query ]

  toJSON (QueryRegexpQuery query) =
    object [ "regexp" .= toJSON query ]

  toJSON (QuerySimpleQueryStringQuery query) =
    object [ "simple_query_string" .= toJSON query ]


omitNulls :: [(Text, Value)] -> Value
omitNulls = object . filter notNull where
  notNull (_, Null) = False
  notNull _         = True


instance ToJSON SimpleQueryStringQuery where
  toJSON SimpleQueryStringQuery {..} =
    omitNulls (base ++ maybeAdd)
    where base = [ "query" .= toJSON simpleQueryStringQuery ]
          maybeAdd = [ "fields" .= simpleQueryStringField
                     , "default_operator" .= simpleQueryStringOperator
                     , "analyzer" .= simpleQueryStringAnalyzer
                     , "flags" .= simpleQueryStringFlags
                     , "lowercase_expanded_terms" .= simpleQueryStringLowercaseExpanded
                     , "locale" .= simpleQueryStringLocale ]


instance ToJSON FieldOrFields where
  toJSON (FofField fieldName) =
    toJSON fieldName
  toJSON (FofFields fieldNames) =
    toJSON fieldNames

instance ToJSON SimpleQueryFlag where
  toJSON SimpleQueryAll        = "ALL"
  toJSON SimpleQueryNone       = "NONE"
  toJSON SimpleQueryAnd        = "AND"
  toJSON SimpleQueryOr         = "OR"
  toJSON SimpleQueryPrefix     = "PREFIX"
  toJSON SimpleQueryPhrase     = "PHRASE"
  toJSON SimpleQueryPrecedence = "PRECEDENCE"
  toJSON SimpleQueryEscape     = "ESCAPE"
  toJSON SimpleQueryWhitespace = "WHITESPACE"
  toJSON SimpleQueryFuzzy      = "FUZZY"
  toJSON SimpleQueryNear       = "NEAR"
  toJSON SimpleQuerySlop       = "SLOP"


instance ToJSON RegexpQuery where
  toJSON (RegexpQuery (FieldName rqQueryField)
          (Regexp regexpQueryQuery) rqQueryFlags
          rqQueryBoost) =
   object [ rqQueryField .= omitNulls base ]
   where base = [ "value" .= regexpQueryQuery
                , "flags" .= toJSON rqQueryFlags
                , "boost" .= rqQueryBoost ]


instance ToJSON QueryStringQuery where
  toJSON (QueryStringQuery qsQueryString
          qsDefaultField qsOperator
          qsAnalyzer qsAllowWildcard
          qsLowercaseExpanded  qsEnablePositionIncrements
          qsFuzzyMaxExpansions qsFuzziness
          qsFuzzyPrefixLength qsPhraseSlop
          qsBoost qsAnalyzeWildcard
          qsGeneratePhraseQueries qsMinimumShouldMatch
          qsLenient qsLocale) =
    omitNulls base
    where
      base = [ "query" .= toJSON qsQueryString
             , "default_field" .= qsDefaultField
             , "default_operator" .= qsOperator
             , "analyzer" .= qsAnalyzer
             , "allow_leading_wildcard" .= qsAllowWildcard
             , "lowercase_expanded_terms" .= qsLowercaseExpanded
             , "enable_position_increments" .= qsEnablePositionIncrements
             , "fuzzy_max_expansions" .= qsFuzzyMaxExpansions
             , "fuzziness" .= qsFuzziness
             , "fuzzy_prefix_length" .= qsFuzzyPrefixLength
             , "phrase_slop" .= qsPhraseSlop
             , "boost" .= qsBoost
             , "analyze_wildcard" .= qsAnalyzeWildcard
             , "auto_generate_phrase_queries" .= qsGeneratePhraseQueries
             , "minimum_should_match" .= qsMinimumShouldMatch
             , "lenient" .= qsLenient
             , "locale" .= qsLocale ]


instance ToJSON RangeQuery where
  toJSON (RangeQuery (FieldName fieldName) (Right range) boost) =
    object [ fieldName .= conjoined ]
    where conjoined = [ "boost" .= toJSON boost
                      , lessKey .= lessVal
                      , greaterKey .= greaterVal ]
          (lessKey, lessVal, greaterKey, greaterVal) = rangeToKV range

  toJSON (RangeQuery (FieldName fieldName) (Left halfRange) boost) =
    object [ fieldName .= conjoined ]
    where conjoined = [ "boost" .= toJSON boost
                      , key     .= val ]
          (key, val) = halfRangeToKV halfRange


instance ToJSON PrefixQuery where
  toJSON (PrefixQuery (FieldName fieldName) queryValue boost) =
    object [ fieldName .= omitNulls base ]
    where base = [ "value" .= toJSON queryValue
                 , "boost" .= boost ]


instance ToJSON NestedQuery where
  toJSON (NestedQuery nqPath nqScoreType nqQuery) =
    object [ "path"       .= toJSON nqPath
           , "score_mode" .= toJSON nqScoreType
           , "query"      .= toJSON nqQuery ]


instance ToJSON MoreLikeThisFieldQuery where
  toJSON (MoreLikeThisFieldQuery text (FieldName fieldName)
          percent mtf mqt stopwords mindf maxdf
          minwl maxwl boostTerms boost analyzer) =
    object [ fieldName .= omitNulls base ]
    where base = [ "like_text" .= toJSON text
                 , "percent_terms_to_match" .= percent
                 , "min_term_freq" .= mtf
                 , "max_query_terms" .= mqt
                 , "stop_words" .= stopwords
                 , "min_doc_freq" .= mindf
                 , "max_doc_freq" .= maxdf
                 , "min_word_length" .= minwl
                 , "max_word_length" .= maxwl
                 , "boost_terms" .= boostTerms
                 , "boost" .= boost
                 , "analyzer" .= analyzer ]


instance ToJSON MoreLikeThisQuery where
  toJSON (MoreLikeThisQuery text fields percent
          mtf mqt stopwords mindf maxdf
          minwl maxwl boostTerms boost analyzer) =
    omitNulls base
    where base = [ "like_text" .= toJSON text
                 , "fields" .= fields
                 , "percent_terms_to_match" .= percent
                 , "min_term_freq" .= mtf
                 , "max_query_terms" .= mqt
                 , "stop_words" .= stopwords
                 , "min_doc_freq" .= mindf
                 , "max_doc_freq" .= maxdf
                 , "min_word_length" .= minwl
                 , "max_word_length" .= maxwl
                 , "boost_terms" .= boostTerms
                 , "boost" .= boost
                 , "analyzer" .= analyzer ]


instance ToJSON IndicesQuery where
  toJSON (IndicesQuery indices query noMatch) =
    omitNulls [ "indices" .= toJSON indices
              , "no_match_query" .= toJSON noMatch
              , "query" .= toJSON query ]


instance ToJSON HasParentQuery where
  toJSON (HasParentQuery queryType query scoreType) =
    omitNulls [ "parent_type" .= toJSON queryType
              , "score_type" .= toJSON scoreType
              , "query" .= toJSON query ]


instance ToJSON HasChildQuery where
  toJSON (HasChildQuery queryType query scoreType) =
    omitNulls [ "query" .= toJSON query
              , "score_type" .= toJSON scoreType
              , "type"  .= toJSON queryType ]


instance ToJSON FuzzyQuery where
  toJSON (FuzzyQuery (FieldName fieldName) queryText
          prefixLength maxEx fuzziness boost) =
    object [ fieldName .= omitNulls base ]
    where base = [ "value"          .= toJSON queryText
                 , "fuzziness"      .= toJSON fuzziness
                 , "prefix_length"  .= toJSON prefixLength
                 , "boost" .= toJSON boost
                 , "max_expansions" .= toJSON maxEx ]


instance ToJSON FuzzyLikeFieldQuery where
  toJSON (FuzzyLikeFieldQuery (FieldName fieldName)
          fieldText maxTerms ignoreFreq fuzziness prefixLength
          boost analyzer) =
    object [ fieldName .=
             omitNulls [ "like_text"       .= toJSON fieldText
                       , "max_query_terms" .= toJSON maxTerms
                       , "ignore_tf"       .= toJSON ignoreFreq
                       , "fuzziness"       .= toJSON fuzziness
                       , "prefix_length"   .= toJSON prefixLength
                       , "analyzer" .= toJSON analyzer
                       , "boost"           .= toJSON boost ]]


instance ToJSON FuzzyLikeThisQuery where
  toJSON (FuzzyLikeThisQuery fields text maxTerms
          ignoreFreq fuzziness prefixLength boost analyzer) =
    omitNulls base
    where base = [ "fields"          .= toJSON fields
                 , "like_text"       .= toJSON text
                 , "max_query_terms" .= toJSON maxTerms
                 , "ignore_tf"       .= toJSON ignoreFreq
                 , "fuzziness"       .= toJSON fuzziness
                 , "prefix_length"   .= toJSON prefixLength
                 , "analyzer"        .= toJSON analyzer
                 , "boost"           .= toJSON boost ]


instance ToJSON FilteredQuery where
  toJSON (FilteredQuery query fFilter) =
    object [ "query"  .= toJSON query
           , "filter" .= toJSON fFilter ]


instance ToJSON DisMaxQuery where
  toJSON (DisMaxQuery queries tiebreaker boost) =
    omitNulls base
    where base = [ "queries"     .= toJSON queries
                 , "boost"       .= toJSON boost
                 , "tie_breaker" .= toJSON tiebreaker ]


instance ToJSON CommonTermsQuery where
  toJSON (CommonTermsQuery (FieldName fieldName)
          (QueryString query) cf lfo hfo msm
          boost analyzer disableCoord) =
    object [fieldName .= omitNulls base ]
    where base = [ "query"              .= toJSON query
                 , "cutoff_frequency"   .= toJSON cf
                 , "low_freq_operator"  .= toJSON lfo
                 , "minimum_should_match" .= toJSON msm
                 , "boost" .= toJSON boost
                 , "analyzer" .= toJSON analyzer
                 , "disable_coord" .= toJSON disableCoord
                 , "high_freq_operator" .= toJSON hfo ]


instance ToJSON CommonMinimumMatch where
  toJSON (CommonMinimumMatch mm) = toJSON mm
  toJSON (CommonMinimumMatchHighLow (MinimumMatchHighLow lowF highF)) =
    object [ "low_freq"  .= toJSON lowF
           , "high_freq" .= toJSON highF ]

instance ToJSON BoostingQuery where
  toJSON (BoostingQuery bqPositiveQuery bqNegativeQuery bqNegativeBoost) =
    object [ "positive"       .= toJSON bqPositiveQuery
           , "negative"       .= toJSON bqNegativeQuery
           , "negative_boost" .= toJSON bqNegativeBoost ]


instance ToJSON BoolQuery where
  toJSON (BoolQuery mustM notM shouldM bqMin boost disableCoord) =
    omitNulls base
    where base = [ "must" .= toJSON mustM
                 , "must_not" .= toJSON notM
                 , "should" .= toJSON shouldM
                 , "minimum_should_match" .= toJSON bqMin
                 , "boost" .= toJSON boost
                 , "disable_coord" .= toJSON disableCoord ]


instance ToJSON MatchQuery where
  toJSON (MatchQuery (FieldName fieldName)
          (QueryString mqQueryString) booleanOperator
          zeroTermsQuery cutoffFrequency matchQueryType
          analyzer maxExpansions lenient) =
    object [ fieldName .= omitNulls base ]
    where base = [ "query" .= mqQueryString
                 , "operator" .= toJSON booleanOperator
                 , "zero_terms_query" .= toJSON zeroTermsQuery
                 , "cutoff_frequency" .= toJSON cutoffFrequency
                 , "type" .= toJSON matchQueryType
                 , "analyzer" .= toJSON analyzer
                 , "max_expansions" .= toJSON maxExpansions
                 , "lenient" .= toJSON lenient ]


instance ToJSON MultiMatchQuery where
  toJSON (MultiMatchQuery fields (QueryString query) boolOp
          ztQ tb mmqt cf analyzer maxEx lenient) =
    object ["multi_match" .= omitNulls base]
    where base = [ "fields" .= fmap toJSON fields
                 , "query" .= query
                 , "operator" .= toJSON boolOp
                 , "zero_terms_query" .= toJSON ztQ
                 , "tiebreaker" .= toJSON tb
                 , "type" .= toJSON mmqt
                 , "cutoff_frequency" .= toJSON cf
                 , "analyzer" .= toJSON analyzer
                 , "max_expansions" .= toJSON maxEx
                 , "lenient" .= toJSON lenient ]


instance ToJSON MultiMatchQueryType where
  toJSON MultiMatchBestFields = "best_fields"
  toJSON MultiMatchMostFields = "most_fields"
  toJSON MultiMatchCrossFields = "cross_fields"
  toJSON MultiMatchPhrase = "phrase"
  toJSON MultiMatchPhrasePrefix = "phrase_prefix"

instance ToJSON BooleanOperator where
  toJSON And = String "and"
  toJSON Or = String "or"

instance ToJSON ZeroTermsQuery where
  toJSON ZeroTermsNone = String "none"
  toJSON ZeroTermsAll  = String "all"

instance ToJSON MatchQueryType where
  toJSON MatchPhrase = "phrase"
  toJSON MatchPhrasePrefix = "phrase_prefix"

instance ToJSON FieldName where
  toJSON (FieldName fieldName) = String fieldName

instance ToJSON ReplicaCount
instance ToJSON ShardCount
instance ToJSON CutoffFrequency
instance ToJSON Analyzer
instance ToJSON MaxExpansions
instance ToJSON Lenient
instance ToJSON Boost
instance ToJSON Version
instance ToJSON Tiebreaker
instance ToJSON MinimumMatch
instance ToJSON DisableCoord
instance ToJSON PrefixLength
instance ToJSON Fuzziness
instance ToJSON IgnoreTermFrequency
instance ToJSON MaxQueryTerms
instance ToJSON TypeName
instance ToJSON IndexName
instance ToJSON BoostTerms
instance ToJSON MaxWordLength
instance ToJSON MinWordLength
instance ToJSON MaxDocFrequency
instance ToJSON MinDocFrequency
instance ToJSON PhraseSlop
instance ToJSON StopWord
instance ToJSON QueryPath
instance ToJSON MinimumTermFrequency
instance ToJSON PercentMatch
instance ToJSON MappingName
instance ToJSON DocId
instance ToJSON QueryString
instance ToJSON AllowLeadingWildcard
instance ToJSON LowercaseExpanded
instance ToJSON AnalyzeWildcard
instance ToJSON GeneratePhraseQueries
instance ToJSON Locale
instance ToJSON EnablePositionIncrements
instance FromJSON Version
instance FromJSON IndexName
instance FromJSON MappingName
instance FromJSON DocId


instance FromJSON Status where
  parseJSON (Object v) = Status <$>
                         v .:? "ok" <*>
                         v .: "status" <*>
                         v .: "name" <*>
                         v .: "version" <*>
                         v .: "tagline"
  parseJSON _          = empty


instance ToJSON IndexSettings where
  toJSON (IndexSettings s r) = object ["settings" .= object ["shards" .= s, "replicas" .= r]]


instance (FromJSON a) => FromJSON (EsResult a) where
  parseJSON (Object v) = EsResult <$>
                         v .:  "_index"   <*>
                         v .:  "_type"    <*>
                         v .:  "_id"      <*>
                         v .:  "_version" <*>
                         v .:? "found"    <*>
                         v .:  "_source"
  parseJSON _          = empty


instance ToJSON Search where
  toJSON (Search query sFilter sort aggs sTrackSortScores sFrom sSize) =
    omitNulls [ "query" .= query
              , "filter" .= sFilter
              , "sort" .= sort
              , "aggregations" .= aggs
              , "from" .= sFrom
              , "size" .= sSize
              , "track_scores" .= sTrackSortScores ]


instance ToJSON SortSpec where
  toJSON (DefaultSortSpec
          (DefaultSort (FieldName dsSortFieldName) dsSortOrder dsIgnoreUnmapped
           dsSortMode dsMissingSort dsNestedFilter)) =
    object [dsSortFieldName .= omitNulls base] where
      base = [ "order" .= toJSON dsSortOrder
             , "ignore_unmapped" .= dsIgnoreUnmapped
             , "mode" .= dsSortMode
             , "missing" .= dsMissingSort
             , "nested_filter" .= dsNestedFilter ]

  toJSON (GeoDistanceSortSpec gdsSortOrder (GeoPoint (FieldName field) gdsLatLon) units) =
    object [ "unit" .= toJSON units
           , field .= toJSON gdsLatLon
           , "order" .= toJSON gdsSortOrder ]


instance ToJSON SortOrder where
  toJSON Ascending  = String "asc"
  toJSON Descending = String "desc"


instance ToJSON SortMode where
  toJSON SortMin = String "min"
  toJSON SortMax = String "max"
  toJSON SortSum = String "sum"
  toJSON SortAvg = String "avg"


instance ToJSON Missing where
  toJSON LastMissing = String "_last"
  toJSON FirstMissing = String "_first"
  toJSON (CustomMissing txt) = String txt


instance ToJSON ScoreType where
  toJSON ScoreTypeMax  = "max"
  toJSON ScoreTypeAvg  = "avg"
  toJSON ScoreTypeSum  = "sum"
  toJSON ScoreTypeNone = "none"


instance ToJSON Distance where
  toJSON (Distance dCoefficient dUnit) =
    String boltedTogether where
      coefText = showText dCoefficient
      (String unitText) = toJSON dUnit
      boltedTogether = mappend coefText unitText


instance ToJSON DistanceUnit where
  toJSON Miles         = String "mi"
  toJSON Yards         = String "yd"
  toJSON Feet          = String "ft"
  toJSON Inches        = String "in"
  toJSON Kilometers    = String "km"
  toJSON Meters        = String "m"
  toJSON Centimeters   = String "cm"
  toJSON Millimeters   = String "mm"
  toJSON NauticalMiles = String "nmi"


instance ToJSON DistanceType where
  toJSON Arc       = String "arc"
  toJSON SloppyArc = String "sloppy_arc"
  toJSON Plane     = String "plane"


instance ToJSON OptimizeBbox where
  toJSON NoOptimizeBbox = String "none"
  toJSON (OptimizeGeoFilterType gft) = toJSON gft


instance ToJSON GeoBoundingBoxConstraint where
  toJSON (GeoBoundingBoxConstraint
          (FieldName gbbcGeoBBField) gbbcConstraintBox cache type') =
    object [gbbcGeoBBField .= toJSON gbbcConstraintBox
           , "_cache"  .= cache
           , "type" .= type']


instance ToJSON GeoFilterType where
  toJSON GeoFilterMemory  = String "memory"
  toJSON GeoFilterIndexed = String "indexed"


instance ToJSON GeoBoundingBox where
  toJSON (GeoBoundingBox gbbTopLeft gbbBottomRight) =
    object ["top_left"      .= toJSON gbbTopLeft
           , "bottom_right" .= toJSON gbbBottomRight]


instance ToJSON LatLon where
  toJSON (LatLon lLat lLon) =
    object ["lat"  .= lLat
           , "lon" .= lLon]


-- index for smaller ranges, fielddata for longer ranges
instance ToJSON RangeExecution where
  toJSON RangeExecutionIndex     = "index"
  toJSON RangeExecutionFielddata = "fielddata"


instance ToJSON RegexpFlags where
  toJSON AllRegexpFlags              = String "ALL"
  toJSON NoRegexpFlags               = String "NONE"
  toJSON (SomeRegexpFlags (h :| fs)) = String $ T.intercalate "|" flagStrs
    where flagStrs             = map flagStr . nub $ h:fs
          flagStr AnyString    = "ANYSTRING"
          flagStr Automaton    = "AUTOMATON"
          flagStr Complement   = "COMPLEMENT"
          flagStr Empty        = "EMPTY"
          flagStr Intersection = "INTERSECTION"
          flagStr Interval     = "INTERVAL"

instance ToJSON Term where
  toJSON (Term field value) = object ["term" .= object
                                      [field .= value]]


instance ToJSON BoolMatch where
  toJSON (MustMatch    term  cache) = object ["must"     .= toJSON term,
                                              "_cache" .= cache]
  toJSON (MustNotMatch term  cache) = object ["must_not" .= toJSON term,
                                              "_cache" .= cache]
  toJSON (ShouldMatch  terms cache) = object ["should"   .= fmap toJSON terms,
                                              "_cache" .= cache]


instance (FromJSON a) => FromJSON (SearchResult a) where
  parseJSON (Object v) = SearchResult <$>
                         v .: "took"      <*>
                         v .: "timed_out" <*>
                         v .: "_shards"   <*>
                         v .: "hits"
  parseJSON _          = empty

instance (FromJSON a) => FromJSON (SearchHits a) where
  parseJSON (Object v) = SearchHits <$>
                         v .: "total"     <*>
                         v .: "max_score" <*>
                         v .: "hits"
  parseJSON _          = empty

instance (FromJSON a) => FromJSON (Hit a) where
  parseJSON (Object v) = Hit <$>
                         v .: "_index" <*>
                         v .: "_type"  <*>
                         v .: "_id"    <*>
                         v .: "_score" <*>
                         v .: "_source"
  parseJSON _          = empty

instance FromJSON ShardResult where
  parseJSON (Object v) = ShardResult <$>
                         v .: "total"      <*>
                         v .: "successful" <*>
                         v .: "failed"
  parseJSON _          = empty
