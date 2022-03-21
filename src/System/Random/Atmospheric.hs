{-# LANGUAGE DataKinds              #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE DuplicateRecordFields  #-}
{-# LANGUAGE OverloadedStrings      #-}
{-# LANGUAGE RecordWildCards        #-}
{-# LANGUAGE TypeOperators          #-}

{-|
Module      : System.Random.Atmospheric
Description : Haskell bindings to the random.org Basic API (Release 4)
Copyright   : Copyright 2022 Mike Pilgrem
License     : BSD-3-Clause
Maintainer  : public@pilgrem.com
Stability   : Experimental
Portability : Portable

Haskell bindings to the [random.org](https://random.org) Basic API (Release 4).
The API provides access to a true random number generator (TRNG) based on
atmospheric noise.

For each API method yielding random data there are two functions (for example
'generateIntegers' and 'generateIntegers''). They differ in the the type of the
value they yield, which can be simple (@IO (Maybe (a, Int))@, where the second
value of the tuple represents the advised delay in milliseconds before next
calling the API) or complex
(@IO (Either ClientError (JsonRpcResponse Value (RandomResponse a)))@).

Certain optional API parameters (@replacement@, default @true@; @base@, default
@10@; and @pregeneratedRandomization@, default @null@) are not implemented.

This module has no connection with Randomness and Integrity Services Ltd or
its affilates.
-}

module System.Random.Atmospheric
  ( -- * Simple functions yielding random data
    generateIntegers
  , generateIntegerSequences
  , generateIntegerSequencesMultiform
  , generateDecimalFractions
  , generateGaussians
  , generateStrings
  , generateUUIDs
  , generateBlobs
    -- * Complex functions yielding random data
  , generateIntegers'
  , generateIntegerSequences'
  , generateIntegerSequencesMultiform'
  , generateDecimalFractions'
  , generateGaussians'
  , generateStrings'
  , generateUUIDs'
  , generateBlobs'
    -- * Usage of the Basic API
  , getUsage
    -- * Types and type synonyms
  , Key (..)
  , Boundary (..)
  , BlobFormat (..)
  , RandomResponse (..)
  , UsageResponse (..)
  , RndResponse
  ) where

import Data.Proxy (Proxy (..))
import GHC.Generics (Generic)

import Data.Aeson.Encoding (text)
import Data.Aeson.Types (FromJSON (..), ToJSON (..), Value (..), (.:),
  defaultOptions, fieldLabelModifier, genericToEncoding, genericToJSON,
  genericParseJSON, withObject)
import Data.Time (UTCTime)
import Data.UUID.Types (UUID)
import Network.HTTP.Client (Manager)
import Servant.API ((:<|>) (..), (:>))
import Servant.Client (BaseUrl (BaseUrl), ClientEnv (..), ClientError, ClientM,
  Scheme (Https), client, defaultMakeClientRequest, runClientM)
import Servant.Client.JsonRpc (JsonRpc, JsonRpcResponse (..), RawJsonRpc)

-- |Type synonym to simplify type signatures defining the Basic API.
type Rnd a b c = JsonRpc a b Value (RandomResponse c)

-- |Type synonym to simplify type signatures defining responses from the Basic
-- API.
type RndResponse a = JsonRpcResponse Value (RandomResponse a)

type GenerateIntegers =
  Rnd "generateIntegers" GenerateIntegersParams [Int]
type GenerateIntegerSequences =
  Rnd "generateIntegerSequences" GenerateIntegerSequencesParams [[Int]]
type GenerateIntegerSequencesMultiform =
  Rnd "generateIntegerSequences" GenerateIntegerSequencesMultiformParams [[Int]]
type GenerateDecimalFractions =
  Rnd "generateDecimalFractions" GenerateDecimalFractionsParams [Double]
type GenerateGaussians =
  Rnd "generateGaussians" GenerateGaussiansParams [Double]
type GenerateStrings =
  Rnd "generateStrings" GenerateStringsParams [String]
type GenerateUUIDs =
  Rnd "generateUUIDs" GenerateUUIDsParams [UUID]
type GenerateBlobs =
  Rnd "generateBlobs" GenerateBlobsParams [String]
type GetUsage =
  JsonRpc "getUsage" GetUsageParams Value UsageResponse

type RpcAPI =    GenerateIntegers
            :<|> GenerateIntegerSequences
            :<|> GenerateIntegerSequencesMultiform
            :<|> GenerateDecimalFractions
            :<|> GenerateGaussians
            :<|> GenerateStrings
            :<|> GenerateUUIDs
            :<|> GenerateBlobs
            :<|> GetUsage

type JsonRpcAPI = "json-rpc" :> "4" :> "invoke" :> RawJsonRpc RpcAPI

data GenerateIntegersParams = GenerateIntegersParams
  { gip_apiKey :: String
  , gip_n      :: Int
  , gip_min    :: Int
  , gip_max    :: Int
  } deriving Generic

instance ToJSON GenerateIntegersParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data GenerateIntegerSequencesParams = GenerateIntegerSequencesParams
  { gisp_apiKey :: String
  , gisp_n      :: Int
  , gisp_length :: Int
  , gisp_min    :: Int
  , gisp_max    :: Int
  } deriving Generic

instance ToJSON GenerateIntegerSequencesParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 5}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 5}

data GenerateIntegerSequencesMultiformParams =
  GenerateIntegerSequencesMultiformParams
    { gismp_apiKey :: String
    , gismp_n      :: Int
    , gismp_length :: [Int]
    , gismp_min    :: Boundary
    , gismp_max    :: Boundary
    } deriving Generic

-- |Type representing boundaries of multiform @generateIntegerSequences@.
data Boundary
  = Fixed Int        -- ^ Fixed boundary for all sequences.
  | Multiform [Int]  -- ^ List of boundaries for each sequence.
  deriving (Eq, Show)

instance ToJSON Boundary where
  toJSON (Fixed b) = toJSON b
  toJSON (Multiform bs) = toJSON bs
  toEncoding (Fixed b) = toEncoding b
  toEncoding (Multiform bs) = toEncoding bs

instance ToJSON GenerateIntegerSequencesMultiformParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 6}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 6}

data GenerateDecimalFractionsParams = GenerateDecimalFractionsParams
  { gdfp_apiKey        :: String
  , gdfp_n             :: Int
  , gdfp_decimalPlaces :: Int
  } deriving Generic

instance ToJSON GenerateDecimalFractionsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 5}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 5}

data GenerateGaussiansParams = GenerateGaussiansParams
  { ggp_apiKey            :: String
  , ggp_n                 :: Int
  , ggp_mean              :: Double
  , ggp_standardDeviation :: Double
  , ggp_significantDigits :: Int
  } deriving Generic

instance ToJSON GenerateGaussiansParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data GenerateStringsParams = GenerateStringsParams
  { gsp_apiKey     :: String
  , gsp_n          :: Int
  , gsp_length     :: Int
  , gsp_characters :: String
  } deriving Generic

instance ToJSON GenerateStringsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data GenerateUUIDsParams = GenerateUUIDsParams
  { gup_apiKey     :: String
  , gup_n          :: Int
  } deriving Generic

instance ToJSON GenerateUUIDsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data GenerateBlobsParams = GenerateBlobsParams
  { gbp_apiKey :: String
  , gbp_n      :: Int
  , gbp_size   :: Int
  , gbp_format :: BlobFormat
  } deriving Generic

instance ToJSON GenerateBlobsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

-- |Type representing BLOB formats.
data BlobFormat
  = Base64
  | Hex
  deriving (Eq, Show)

instance ToJSON BlobFormat where
  toJSON Base64 = String "base64"
  toJSON Hex    = String "hex"

  toEncoding Base64 = text "base64"
  toEncoding Hex    = text "hex"


newtype GetUsageParams = GetUsageParams
  { usep_apiKey :: String
  } deriving Generic

instance ToJSON GetUsageParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 5}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 5}

-- |Type representing responses from methods of the Basic API yielding random
-- data.
data RandomResponse a = RandomResponse
  { randomData     :: a
  , completionTime :: UTCTime
  , bitsUsed       :: Int
  , bitsLeft       :: Int
  , requestsLeft   :: Int
  , advisoryDelay  :: Int
  } deriving (Eq, Show)

instance FromJSON a => FromJSON (RandomResponse a) where
  parseJSON = withObject "random.org response" $ \obj -> do
    random <- obj .: "random"
    randomData <- random .: "data"
    completionTime <- random  .: "completionTime"
    bitsUsed <- obj .: "bitsUsed"
    bitsLeft <- obj .: "bitsLeft"
    requestsLeft <- obj .: "requestsLeft"
    advisoryDelay <- obj .: "advisoryDelay"
    pure RandomResponse {..}

-- |Type representing responses from the method of the Basic API yielding
-- information about the API usage.
data UsageResponse = UsageResponse
  { status        :: String
  , creationTime  :: UTCTime
  , bitsLeft      :: Int
  , requestsLeft  :: Int
  , totalBits     :: Int
  , totalRequests :: Int
  } deriving (Eq, Generic, Show)

instance FromJSON UsageResponse where
  parseJSON = genericParseJSON defaultOptions

api :: Proxy JsonRpcAPI
api = Proxy

randomDotOrgApi :: BaseUrl
randomDotOrgApi = BaseUrl Https "api.random.org" 443 ""

-- |Type representing API keys.
newtype Key = Key String
              deriving (Eq, Show)

-- |This method generates true random integers within a user-defined range. If
-- successful, the function yields the random data and the advised delay in
-- milliseconds.
generateIntegers
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of integers requested. Must be in the range
              --   [1, 10,000].
  -> Int      -- ^ The lower boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> Int      -- ^ The upper boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([Int], Int))
generateIntegers mgr key n rangeMin rangeMax =
  toMaybe <$> generateIntegers' mgr key n rangeMin rangeMax

-- |This method generates true random integers within a user-defined range.
generateIntegers'
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of integers requested. Must be in the range
              --   [1, 10,000].
  -> Int      -- ^ The lower boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> Int      -- ^ The upper boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [Int]))
generateIntegers' mgr key n rangeMin rangeMax =
  runClientM (generateIntegers'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateIntegersParams
             { gip_apiKey = apiKey
             , gip_n      = n
             , gip_min    = rangeMin
             , gip_max    = rangeMax
             }

generateIntegers''
  :: GenerateIntegersParams -> ClientM (RndResponse [Int])

-- |This method generates sequences of true random integers within a
-- user-defined range. If successful, the function yields the random data and
-- the advised delay in milliseconds.
generateIntegerSequences
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of sequences requested. Must be in the range
              --   [1, 10,000].
  -> Int      -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int      -- ^ The lower boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> Int      -- ^ The upper boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([[Int]], Int))
generateIntegerSequences mgr key n l rangeMin rangeMax =
  toMaybe <$> generateIntegerSequences' mgr key n l rangeMin rangeMax

-- |This method generates sequences of true random integers within a
-- user-defined range.
generateIntegerSequences'
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of sequences requested. Must be in the range
              --   [1, 10,000].
  -> Int      -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int      -- ^ The lower boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> Int      -- ^ The upper boundary for the range from which the random
              --   integers will be picked. Must be within the range
              --   [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [[Int]]))
generateIntegerSequences' mgr key n l rangeMin rangeMax =
  runClientM (generateIntegerSequences'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateIntegerSequencesParams
             { gisp_apiKey = apiKey
             , gisp_n      = n
             , gisp_length = l
             , gisp_min    = rangeMin
             , gisp_max    = rangeMax
             }

generateIntegerSequences''
  :: GenerateIntegerSequencesParams -> ClientM (RndResponse [[Int]])

-- |This method generates multiform sequences of true random integers within a
-- user-defined range. If successful, the function yields the random data and
-- the advised delay in milliseconds.
generateIntegerSequencesMultiform
  :: Manager   -- ^ The connection manager.
  -> Key       -- ^ The API key.
  -> Int       -- ^ The number of sequences requested. Must be in the range
               --   [1, 10,000].
  -> [Int]     -- ^ The lengths of the sequences. Each must be in the range
               --   [1, 10,000].
  -> Boundary  -- ^ The lower boundary (or boundaries) for the range from which
               --   the random integers will be picked. Must be within the range
               --   [-1,000,000,000, 1,000,000,000].
  -> Boundary  -- ^ The upper boundary (or boundaries) for the range from which
               --   the random integers will be picked. Must be within the range
               --   [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([[Int]], Int))
generateIntegerSequencesMultiform mgr key n ls rangeMin rangeMax =
  toMaybe <$> generateIntegerSequencesMultiform' mgr key n ls rangeMin rangeMax

-- |This method generates multiform sequences of true random integers within a
-- user-defined range.
generateIntegerSequencesMultiform'
  :: Manager   -- ^ The connection manager.
  -> Key       -- ^ The API key.
  -> Int       -- ^ The number of sequences requested. Must be in the range
               --   [1, 10,000].
  -> [Int]     -- ^ The lengths of the sequences. Each must be in the range
               --   [1, 10,000].
  -> Boundary  -- ^ The lower boundary (or boundaries) for the range from which
               --   the random integers will be picked. Must be within the range
               --   [-1,000,000,000, 1,000,000,000].
  -> Boundary  -- ^ The upper boundary (or boundaries) for the range from which
               --   the random integers will be picked. Must be within the range
               --   [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [[Int]]))
generateIntegerSequencesMultiform' mgr key n ls rangeMin rangeMax =
  runClientM (generateIntegerSequencesMultiform'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateIntegerSequencesMultiformParams
             { gismp_apiKey = apiKey
             , gismp_n      = n
             , gismp_length = ls
             , gismp_min    = rangeMin
             , gismp_max    = rangeMax
             }

generateIntegerSequencesMultiform''
  :: GenerateIntegerSequencesMultiformParams -> ClientM (RndResponse [[Int]])

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places. If successful, the function yields the random data and the advised
-- delay in milliseconds.
generateDecimalFractions
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of decimal fractions requested. Must be in the
              --   range [1, 10,000].
  -> Int      -- ^ The number of decimal places. Must be within the range
              --   [1, 14].
  -> IO (Maybe ([Double], Int))
generateDecimalFractions  mgr key n dps =
  toMaybe <$> generateDecimalFractions' mgr key n dps

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places.
generateDecimalFractions'
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of decimal fractions requested. Must be in the
              --   range [1, 10,000].
  -> Int      -- ^ The number of decimal places. Must be within the range
              --   [1, 14].
  -> IO (Either ClientError (RndResponse [Double]))
generateDecimalFractions' mgr key n dps =
  runClientM (generateDecimalFractions'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateDecimalFractionsParams
             { gdfp_apiKey        = apiKey
             , gdfp_n             = n
             , gdfp_decimalPlaces = dps
             }

generateDecimalFractions''
  :: GenerateDecimalFractionsParams -> ClientM (RndResponse [Double])

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.  If
-- successful, the function yields the random data and the advised delay in
-- milliseconds.
generateGaussians
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of random numbers requested. Must be in the range
              --   [1, 10,000].
  -> Double   -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double   -- ^ The standard deviation. Must be in the range [-1,000,000,
              --   1,000,000].
  -> Int      -- ^ The number of significant digits. Must be within the range
              --   [2, 14].
  -> IO (Maybe ([Double], Int))
generateGaussians mgr key n mean sd sds =
  toMaybe <$> generateGaussians' mgr key n mean sd sds

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.
generateGaussians'
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of random numbers requested. Must be in the range
              --   [1, 10,000].
  -> Double   -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double   -- ^ The standard deviation. Must be in the range [-1,000,000,
              --   1,000,000].
  -> Int      -- ^ The number of significant digits. Must be within the range
              --   [2, 14].
  -> IO (Either ClientError (RndResponse [Double]))
generateGaussians' mgr key n mean sd sds =
  runClientM (generateGaussians'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateGaussiansParams
             { ggp_apiKey            = apiKey
             , ggp_n                 = n
             , ggp_mean              = mean
             , ggp_standardDeviation = sd
             , ggp_significantDigits = sds
             }

generateGaussians''
  :: GenerateGaussiansParams -> ClientM (RndResponse [Double])

-- |This method generates true random strings. If successful, the function
-- yields the random data and the advised delay in milliseconds.
generateStrings
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of random strings requested. Must be in the range
              --   [1, 10,000].
  -> Int      -- ^ The length of each string. Must be in the range [1, 32].
  -> String   -- ^ The set of characters that are allowed to occur in the random
              --   strings. The maximum number of characters is 128.
  -> IO (Maybe ([String], Int))
generateStrings mgr key n l cs = toMaybe <$> generateStrings' mgr key n l cs

-- |This method generates true random strings.
generateStrings'
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of random strings requested. Must be in the range
              --   [1, 10,000].
  -> Int      -- ^ The length of each string. Must be in the range [1, 32].
  -> String   -- ^ The set of characters that are allowed to occur in the random
              --   strings. The maximum number of characters is 128.
  -> IO (Either ClientError (RndResponse [String]))
generateStrings' mgr key n l cs =
  runClientM (generateStrings'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateStringsParams
             { gsp_apiKey     = apiKey
             , gsp_n          = n
             , gsp_length     = l
             , gsp_characters = cs
             }

generateStrings''
  :: GenerateStringsParams -> ClientM (RndResponse [String])

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122. If successful, the
-- function yields the random data and the advised delay in milliseconds.
generateUUIDs
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of random UUIDs requested. Must be in the range
              --   [1, 10,000].
  -> IO (Maybe ([UUID], Int))
generateUUIDs mgr key n = toMaybe <$> generateUUIDs' mgr key n

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122.
generateUUIDs'
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key.
  -> Int      -- ^ The number of random UUIDs requested. Must be in the range
              --   [1, 10,000].
  -> IO (Either ClientError (RndResponse [UUID]))
generateUUIDs' mgr key n =
  runClientM (generateUUIDs'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateUUIDsParams
             { gup_apiKey     = apiKey
             , gup_n          = n
             }

generateUUIDs''
  :: GenerateUUIDsParams -> ClientM (RndResponse [UUID])

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
-- If successful, the function yields the random data and the advised delay in
-- milliseconds.
generateBlobs
  :: Manager     -- ^ The connection manager.
  -> Key         -- ^ The API key.
  -> Int         -- ^ The number of random BLOBs requested. Must be in the range
                 --   [1, 100].
  -> Int         -- ^ The size of each blob, measured in bytes. Must be in the
                 --   range [1, 131,072].
  -> BlobFormat  -- ^ The format of the BLOBs.
  -> IO (Maybe ([String], Int))
generateBlobs mgr key n s f = toMaybe <$> generateBlobs' mgr key n s f

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
generateBlobs'
  :: Manager     -- ^ The connection manager.
  -> Key         -- ^ The API key.
  -> Int         -- ^ The number of random BLOBs requested. Must be in the range
                 --   [1, 100].
  -> Int         -- ^ The size of each blob, measured in bytes (not bits). Must
                 --   be in the range [1, 131,072].
  -> BlobFormat  -- ^ The format of the BLOBs.
  -> IO (Either ClientError (RndResponse [String]))
generateBlobs' mgr key n s f =
  runClientM (generateBlobs'' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GenerateBlobsParams
             { gbp_apiKey = apiKey
             , gbp_n      = n
             , gbp_size   = s * 8
             , gbp_format = f
             }

generateBlobs''
  :: GenerateBlobsParams -> ClientM (RndResponse [String])

-- |Helper function to help simplify method functions
toMaybe :: Either ClientError (RndResponse a) -> Maybe (a, Int)
toMaybe (Right (Result _ result')) =
  Just $ (randomData result', advisoryDelay result')
toMaybe _                          = Nothing

-- |This method returns information related to the usage of a given API key.
getUsage
  :: Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key
  -> IO (Either ClientError (JsonRpcResponse Value UsageResponse))
getUsage mgr key =
  runClientM (getUsage' params)
             (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
 where
  Key apiKey = key
  params = GetUsageParams
             { usep_apiKey = apiKey
             }

getUsage'
  :: GetUsageParams -> ClientM (JsonRpcResponse Value UsageResponse)

generateIntegers'' :<|> generateIntegerSequences'' :<|>
  generateIntegerSequencesMultiform'' :<|> generateDecimalFractions'' :<|>
    generateGaussians'' :<|> generateStrings'' :<|> generateUUIDs'' :<|>
      generateBlobs'' :<|> getUsage' = client api
