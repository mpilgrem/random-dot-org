{-# LANGUAGE CPP                        #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE DuplicateRecordFields      #-}
{-# LANGUAGE GeneralisedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE TypeOperators              #-}
{-# LANGUAGE InstanceSigs #-}

{-|
Module      : System.Random.Atmospheric.Api
Description : Haskell bindings to the RANDOM.ORG Core API
Copyright   : Copyright 2022-2024 Mike Pilgrem
License     : BSD-3-Clause
Maintainer  : public@pilgrem.com
Stability   : Experimental
Portability : Portable

Haskell bindings to the [RANDOM.ORG](https://random.org) Core API (Release 4).
The API provides access to a true random number generator (TRNG) based on
atmospheric noise.

NB: The use of the API's services is subject to the terms and conditions of
Randomness and Integrity Services Limited.

This module has no connection with Randomness and Integrity Services Limited or
its affilates or the RANDOM.ORG domain.

The Core API comprises the Basic API and the Signed API.
-}

module System.Random.Atmospheric.Api
  ( -- * The Basic API
    --
    -- | For each API method yielding random data there are four functions. For
    -- example:
    --
    -- * 'genIntegers'
    -- * 'genIntegers''
    -- * 'genWithSeedIntegers'
    -- * 'genWithSeedIntegers''
    --
    -- The functions with and without a prime character differ in the type of
    -- the value they yield. This can be simple:
    --
    -- > IO (Maybe (a, Int))
    --
    -- where the second value of the tuple represents the advised delay in
    -- milliseconds before next calling the API, or complex:
    --
    -- > IO (Either ClientError (JsonRpcResponse Value (RandomResponse a)))
    --
    -- The type synonym 'RndResponse' is used to simplify the type signatures
    -- of the complex functions:
    --
    -- > type RndResponse a = JsonRpcResponse Value (RandomResponse a)
    --
    -- The @genWithSeed...@ functions are more general, taking an optional seed
    -- which, if specified, causes the API to use pregenerated noise.
    --
    -- > genIntegers mgr key == genWithSeedIntegers mgr key Nothing
    --
    -- > genIntegers' mgr key == genWithSeedIntegers' mgr key Nothing
    --
    -- Certain optional API parameters (@base@, default @10@) are not
    -- implemented.

    -- ** Simple functions yielding random data
    genIntegers
  , genIntegerSequences
  , genIntegerSequencesMultiform
  , genDecimalFractions
  , genGaussians
  , genStrings
  , genUUIDs
  , genBlobs
    -- ** Complex functions yielding random data
  , genIntegers'
  , genIntegerSequences'
  , genIntegerSequencesMultiform'
  , genDecimalFractions'
  , genGaussians'
  , genStrings'
  , genUUIDs'
  , genBlobs'
    -- ** Simple functions yielding random data, maybe from pregenerated randomization
  , genWithSeedIntegers
  , genWithSeedIntegerSequences
  , genWithSeedIntegerSequencesMultiform
  , genWithSeedDecimalFractions
  , genWithSeedGaussians
  , genWithSeedStrings
  , genWithSeedUUIDs
  , genWithSeedBlobs
    -- ** Complex functions yielding random data, maybe from pregenerated randomization
  , genWithSeedIntegers'
  , genWithSeedIntegerSequences'
  , genWithSeedIntegerSequencesMultiform'
  , genWithSeedDecimalFractions'
  , genWithSeedGaussians'
  , genWithSeedStrings'
  , genWithSeedUUIDs'
  , genWithSeedBlobs'
    -- *  The Signed API
    --
    -- | For each API method yielding random data there are two functions. For
    -- example:
    --
    -- * 'genSignedIntegers'
    -- * 'genWithSeedSignedIntegers'
    --
    -- The @genWithSeed...@ functions are more general, taking an optional seed
    -- which, if specified, causes the API to use pregenerated noise.
    --
    -- > genIntegers mgr key == genWithSeedIntegers mgr key Nothing
    --
    -- > genIntegers' mgr key == genWithSeedIntegers' mgr key Nothing
    --
    -- The type synonym 'SigRndResponse' is used to simplify the type signatures
    -- of the functions:
    --
    -- > type SigRndResponse a b = JsonRpcResponse Value (SignedRandomResponse a b)
    --
    -- Certain optional API parameters (@base@, default @10@) are not
    -- implemented.

    -- ** Functions yielding signed random data
  , genSignedIntegers
  , genSignedIntegerSequences
  , genSignedIntegerSequencesMultiform
  , genSignedDecimalFractions
  , genSignedGaussians
  , genSignedStrings
  , genSignedUUIDs
  , genSignedBlobs
    -- ** Functions yielding signed random data, maybe from pregenerated randomization
  , genWithSeedSignedIntegers
  , genWithSeedSignedIntegerSequences
  , genWithSeedSignedIntegerSequencesMultiform
  , genWithSeedSignedDecimalFractions
  , genWithSeedSignedGaussians
  , genWithSeedSignedStrings
  , genWithSeedSignedUUIDs
  , genWithSeedSignedBlobs
    -- ** Functions related to serial numbers
  , getResult
    -- ** Functions related to tickets
  , createTickets
  , createTickets'
  , revealTickets
  , revealTickets'
  , listTickets
  , listTickets'
  , getTicket
  , getTicket'
    -- ** Functions related to verification
  , verifySignedResponse
  , verifySignedResponse'
    -- * Usage of the Core API
  , getUsage
  , getUsage'
    -- * Types and type synonyms
    -- ** The Core API
  , Key (..)
  , Seed
  , MkSeedError
  , mkSeedfromDate
  , mkSeedFromId
  , Boundary (..)
  , Blob (..)
  , BlobFormat (..)
  , RandomResponse (..)
  , RndResponse
  , UsageResponse (..)
  , Status (..)
    -- ** The Signed API only
  , ApiKey (..)
  , Method (..)
  , LicenseData (..)
  , CurrencyAmount (..)
  , Currency (..)
  , TicketResponse (..)
  , TicketData (..)
  , TicketId (..)
  , TicketType (..)
  , Signature (..)
  , SignedRandomResponse (..)
  , GenIntegersParams (..)
  , GenIntegerSequencesParams (..)
  , GenIntegerSequencesMultiformParams (..)
  , GenDecimalFractionsParams (..)
  , GenGaussiansParams (..)
  , GenStringsParams (..)
  , GenUUIDsParams (..)
  , GenBlobsParams (..)
  , ClientSigResponse
  , GetResultResponse (..)
  , CreateTicketsResponse (..)
  , RevealTicketsResponse (..)
  , TicketInfoResponse (..)
  , VerifySignatureResponse (..)
  , SigRndResponse
  ) where

import           Control.Applicative ( (<|>) )
import           Data.Aeson.Encoding ( unsafeToEncoding )
import qualified Data.Aeson.KeyMap as KM
import           Data.Aeson.Types
                   ( FromJSON (..), Object, Options (..), SumEncoding (..)
                   , ToJSON (..), Value (..), (.:), defaultOptions
                   , fieldLabelModifier, genericParseJSON, genericToEncoding
                   , genericToJSON, withObject, withText
                   )
import           Data.Binary.Builder ( fromByteString )
import           Data.ByteString ( ByteString )
import           Data.Char ( toLower )
import           Data.Proxy ( Proxy (..) )
import qualified Data.Text as T
import           Data.Text ( Text )
import           Data.Text.Encoding ( decodeUtf8, encodeUtf8 )
import           Data.Time ( Day, UTCTime )
import           Data.UUID.Types ( UUID )
import           GHC.Generics ( Generic )
import           Network.HTTP.Client ( Manager )
import           Servant.API ( (:<|>) (..), (:>), JSON )
import           Servant.Client
                   ( BaseUrl (BaseUrl), ClientEnv (..), ClientError, ClientM
                   , Scheme (Https), client, defaultMakeClientRequest
                   , runClientM
                   )
import           Servant.Client.JsonRpc
                   ( JsonRpc, JsonRpcResponse (..), RawJsonRpc )
import           System.Random.Atmospheric.Api.DateTime ( DateTime (..) )

-- |Type synonym to simplify type signatures defining the Basic API.
type Rnd a b c = JsonRpc a b Value (RandomResponse c)

type SigRnd a b c d = JsonRpc a b Value (SignedRandomResponse c d)

-- |Type synonym to simplify type signatures defining responses from the Basic
-- API.
type RndResponse a = JsonRpcResponse Value (RandomResponse a)

-- |Type synonym to simplify type signatures defining responses from the Signed
-- API.
type SigRndResponse a b = JsonRpcResponse Value (SignedRandomResponse a b)

-- |Type synonym to simplify type signatures defining responses from the Signed
-- API.
type ClientSigResponse a b = Either ClientError (SigRndResponse a b)

type GenIntegers =
   Rnd "generateIntegers" GenIntegersParams [Int]

type GenIntegerSequences =
  Rnd "generateIntegerSequences" GenIntegerSequencesParams [[Int]]

type GenIntegerSequencesMultiform =
  Rnd "generateIntegerSequences" GenIntegerSequencesMultiformParams [[Int]]

type GenDecimalFractions =
  Rnd "generateDecimalFractions" GenDecimalFractionsParams [Double]

type GenGaussians =
   Rnd "generateGaussians" GenGaussiansParams [Double]

type GenStrings =
   Rnd "generateStrings" GenStringsParams [Text]

type GenUUIDs =
   Rnd "generateUUIDs" GenUUIDsParams [UUID]

type GenBlobs =
  Rnd "generateBlobs" GenBlobsParams [Blob]

type GenSigIntegers =
  SigRnd "generateSignedIntegers" GenSigIntegersParams [Int] GenIntegersParams

type GenSigIntegerSequences =
  SigRnd
    "generateSignedIntegerSequences"
    GenSigIntegerSequencesParams
    [[Int]]
    GenIntegerSequencesParams

type GenSigIntegerSequencesMultiform =
  SigRnd
    "generateSignedIntegerSequences"
    GenSigIntegerSequencesMultiformParams
    [[Int]]
    GenIntegerSequencesMultiformParams

type GenSigDecimalFractions =
  SigRnd
    "generateSignedDecimalFractions"
    GenSigDecimalFractionsParams
    [Double]
    GenDecimalFractionsParams

type GenSigGaussians =
  SigRnd
    "generateSignedGaussians"
    GenSigGaussiansParams
    [Double]
    GenGaussiansParams

type GenSigStrings =
  SigRnd "generateSignedStrings" GenSigStringsParams [Text] GenStringsParams

type GenSigUUIDs =
  SigRnd "generateSignedUUIDs" GenSigUUIDsParams [UUID] GenUUIDsParams

type GenSigBlobs =
  SigRnd "generateSignedBlobs" GenSigBlobsParams [Blob] GenBlobsParams

type GetResult =
   JsonRpc "getResult" GetResultParams Value GetResultResponse

type CreateTickets =
  JsonRpc "createTickets" CreateTicketsParams Value CreateTicketsResponse

type RevealTickets =
  JsonRpc "revealTickets" RevealTicketsParams Value RevealTicketsResponse

type ListTickets =
  JsonRpc "listTickets" ListTicketsParams Value [TicketInfoResponse]

type GetTicket =
   JsonRpc "getTicket" GetTicketParams Value TicketInfoResponse

type VerifySignature =
   JsonRpc "verifySignature" VerifySignatureParams Value VerifySignatureResponse

type GetUsage =
  JsonRpc "getUsage" GetUsageParams Value UsageResponse

type RpcAPI =
       GenIntegers
  :<|> GenIntegerSequences
  :<|> GenIntegerSequencesMultiform
  :<|> GenDecimalFractions
  :<|> GenGaussians
  :<|> GenStrings
  :<|> GenUUIDs
  :<|> GenBlobs
  :<|> GenSigIntegers
  :<|> GenSigIntegerSequences
  :<|> GenSigIntegerSequencesMultiform
  :<|> GenSigDecimalFractions
  :<|> GenSigGaussians
  :<|> GenSigStrings
  :<|> GenSigUUIDs
  :<|> GenSigBlobs
  :<|> GetResult
  :<|> CreateTickets
  :<|> RevealTickets
  :<|> ListTickets
  :<|> GetTicket
  :<|> VerifySignature
  :<|> GetUsage

type JsonRpcAPI =
  "json-rpc" :> "4" :> "invoke" :> RawJsonRpc JSON RpcAPI

-- | Type representing Binary Large OBjects (BLOBs).
newtype Blob = Blob
  { unBlob :: ByteString
  } deriving (Eq, Generic, Show)

instance FromJSON Blob where

  parseJSON = withText "Blob" (pure . Blob . encodeUtf8)

instance ToJSON Blob where

  toJSON = String . decodeUtf8 . unBlob
  toEncoding = unsafeToEncoding . fromByteString . unBlob

-- | Type representing signed data.
data SignedData = SignedData
  { sd_licenseData :: Maybe LicenseData
  , sd_userData    :: Maybe Object
  , sd_ticketId    :: Maybe TicketId
  } deriving (Eq, Generic, Show)

instance ToJSON SignedData where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 3}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 3}

instance FromJSON SignedData where

  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = drop 3}

-- | Type representing data required by the Signed API for certain licences.
newtype LicenseData = LicenseData
  { ld_maxPayoutValue :: CurrencyAmount
  } deriving (Eq, Generic, Show)

instance ToJSON LicenseData where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 3}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 3}

instance FromJSON LicenseData where

  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = drop 3}

-- | Type representing monetary amounts.
data CurrencyAmount = CurrencyAmount
  { ca_currency :: Currency
  , ca_amount   :: Double
  } deriving (Eq, Generic, Show)

instance ToJSON CurrencyAmount where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 3}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 3}

instance FromJSON CurrencyAmount where

  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = drop 3}

-- | Type representing currencies recognised by the Signed API.
data Currency
  = USD -- ^ United State dollar
  | EUR -- ^ Euro
  | GBP -- ^ British pound
  | BTC -- ^ Bitcoin cryptocurrency
  | ETH -- ^ Ether cryptocurrency
  deriving (Eq, Generic, Show)

instance ToJSON Currency

instance FromJSON Currency

-- | Type representing the IDs of unique single-use tickets.
newtype TicketId = TicketId
  { unTicketId :: ByteString
  } deriving (Eq, Generic, Show)

instance ToJSON TicketId where

  toJSON = String . decodeUtf8 . unTicketId
  toEncoding = unsafeToEncoding . fromByteString . unTicketId

instance FromJSON TicketId where

  parseJSON = withText "TicketId" (pure . TicketId . encodeUtf8)

-- | Type representing \'seeds\' used to generate random data from historical,
-- pregenerated randomization.
data Seed
  = DateSeed Day
    -- | A seed based on a past date or the current date.
  | IdSeed Text
    -- | A seed based on an id of 1 to 64 characters in length.
  deriving (Eq, Generic, Show)

-- | Type representing errors form 'mkSeedFromId'.
data MkSeedError
  = FutureDate
    -- ^ The date for an date seed cannot be a future date.
  | NullId
    -- ^ The text for an id seed cannot be null.
  | OversizedId
    -- ^ The text for an id seen cannot be longer than 64 characters.
  deriving (Eq, Show)

-- | Construct a seed from a date. Given the current date, checks that the date
-- is a past date or the current date.
mkSeedfromDate ::
     Day
     -- ^ The current date (not verified).
  -> Day
     -- ^ A past date or the current date.
  -> Either MkSeedError Seed
mkSeedfromDate today date
  | date <= today = Right (DateSeed date)
  | otherwise = Left FutureDate

-- | Construct a seed from an id. Checks that the id is between 1 to 64
-- characters in length.
mkSeedFromId :: Text -> Either MkSeedError Seed
mkSeedFromId t
  | T.null t = Left NullId
  | T.length t > 64 = Left OversizedId
  | otherwise = Right (IdSeed t)

instance ToJSON Seed where

  toJSON (DateSeed day) = Object $ KM.singleton "date" (toJSON day)
  toJSON (IdSeed identifier) = Object $ KM.singleton "id" (toJSON identifier)

instance FromJSON Seed where

  parseJSON = withObject "Seed" $ \obj ->
    DateSeed <$> obj .: "date" <|> IdSeed <$> obj .: "id"

-- | Type representing parameters to the generateIntegers API method.
data GenIntegersParams = GenIntegersParams
  { gip_apiKey                    :: ApiKey
  , gip_n                         :: Int
  , gip_min                       :: Int
  , gip_max                       :: Int
  , gip_replacement               :: Bool
  , gip_base                      :: Int
  , gip_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenIntegersParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

instance FromJSON GenIntegersParams where

  parseJSON = genericParseJSON $ customOptions 4

-- | Type representing parameters to the generateSignedIntegers API method.
data GenSigIntegersParams = GenSigIntegersParams
  { sgip_params :: GenIntegersParams
  , sgip_data   :: SignedData
  } deriving (Eq, Show)

sigParamsToJSON ::
     (ToJSON a1, ToJSON a2)
  => t
  -> (t -> a1)
  -> (t -> a2)
  -> Value
sigParamsToJSON p pParams pData =
  case (toJSON $ pParams p, toJSON $ pData p) of
    (Object o_params, Object o_data) -> Object (o_params <> o_data)
    _ -> error "error"

instance ToJSON GenSigIntegersParams where

  toJSON p = sigParamsToJSON p sgip_params sgip_data

instance FromJSON GenSigIntegersParams where

  parseJSON v = do
    sgip_params <- parseJSON v
    sgip_data <- parseJSON v
    pure GenSigIntegersParams {..}

-- | Type representing parameters to the generateIntegerSequences API method.
data GenIntegerSequencesParams = GenIntegerSequencesParams
  { gisp_apiKey                    :: ApiKey
  , gisp_n                         :: Int
  , gisp_length                    :: Int
  , gisp_min                       :: Int
  , gisp_max                       :: Int
  , gisp_replacement               :: Bool
  , gisp_base                      :: Int
  , gisp_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenIntegerSequencesParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 5}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 5}

customOptions :: Int -> Options
customOptions n = defaultOptions
  { fieldLabelModifier = \l -> case drop n l of
      "apiKey" -> "hashedApiKey"
      l' -> l'
  }

instance FromJSON GenIntegerSequencesParams where

  parseJSON = genericParseJSON $ customOptions 5

-- | Type representing parameters to the generateSignedIntegerSequences API
-- method for non-multiform sequences.
data GenSigIntegerSequencesParams = GenSigIntegerSequencesParams
  { sgisp_params :: GenIntegerSequencesParams
  , sgisp_data   :: SignedData
  } deriving (Eq, Show)

instance ToJSON GenSigIntegerSequencesParams where

  toJSON :: GenSigIntegerSequencesParams -> Value
  toJSON p = sigParamsToJSON p sgisp_params sgisp_data

instance FromJSON GenSigIntegerSequencesParams where

  parseJSON v = do
    sgisp_params <- parseJSON v
    sgisp_data <- parseJSON v
    pure GenSigIntegerSequencesParams {..}

-- | Type representing parameters to the generateIntegerSequences API method for
-- multiform sequences.
data GenIntegerSequencesMultiformParams = GenIntegerSequencesMultiformParams
  { gismp_apiKey                    :: ApiKey
  , gismp_n                         :: Int
  , gismp_length                    :: [Int]
  , gismp_min                       :: Boundary
  , gismp_max                       :: Boundary
  , gismp_replacement               :: Bool
  , gismp_base                      :: Int
  , gismp_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

-- | Type representing boundaries of multiform @generateIntegerSequences@.
data Boundary
  = Fixed Int        -- ^ Fixed boundary for all sequences.
  | Multiform [Int]  -- ^ List of boundaries for each sequence.
  deriving (Eq, Generic, Show)

instance ToJSON Boundary where
  toJSON (Fixed b) = toJSON b
  toJSON (Multiform bs) = toJSON bs
  toEncoding (Fixed b) = toEncoding b
  toEncoding (Multiform bs) = toEncoding bs

instance FromJSON Boundary where

  parseJSON = genericParseJSON defaultOptions {sumEncoding = UntaggedValue}

instance ToJSON GenIntegerSequencesMultiformParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 6}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 6}

instance FromJSON GenIntegerSequencesMultiformParams where

  parseJSON = genericParseJSON $ customOptions 6

-- | Type representing parameters to the generateSignedIntegerSequences API
-- method for multiform sequences.
data GenSigIntegerSequencesMultiformParams =
  GenSigIntegerSequencesMultiformParams
    { sgismp_params :: GenIntegerSequencesMultiformParams
    , sgismp_data   :: SignedData
    } deriving (Eq, Show)

instance ToJSON GenSigIntegerSequencesMultiformParams where

  toJSON p = sigParamsToJSON p sgismp_params sgismp_data

instance FromJSON GenSigIntegerSequencesMultiformParams where

  parseJSON v = do
    sgismp_params <- parseJSON v
    sgismp_data <- parseJSON v
    pure GenSigIntegerSequencesMultiformParams {..}

-- | Type representing parameters to the @generateDecimalFractions@ API method.
data GenDecimalFractionsParams = GenDecimalFractionsParams
  { gdfp_apiKey                    :: ApiKey
  , gdfp_n                         :: Int
  , gdfp_decimalPlaces             :: Int
  , gdfp_replacement               :: Bool
  , gdfp_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenDecimalFractionsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 5}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 5}

instance FromJSON GenDecimalFractionsParams where

  parseJSON = genericParseJSON $ customOptions 5

-- | Type representing parameters to the @generateSignedDecimalFractions@ API
-- method.
data GenSigDecimalFractionsParams = GenSigDecimalFractionsParams
    { sgdfp_params :: GenDecimalFractionsParams
    , sgdfp_data   :: SignedData
    } deriving (Eq, Show)

instance ToJSON GenSigDecimalFractionsParams where

  toJSON p = sigParamsToJSON p sgdfp_params sgdfp_data

instance FromJSON GenSigDecimalFractionsParams where

  parseJSON v = do
    sgdfp_params <- parseJSON v
    sgdfp_data <- parseJSON v
    pure GenSigDecimalFractionsParams {..}

-- | Type representing parameters to the @generateGaussianss@ API method.
data GenGaussiansParams = GenGaussiansParams
  { ggp_apiKey                    :: ApiKey
  , ggp_n                         :: Int
  , ggp_mean                      :: Double
  , ggp_standardDeviation         :: Double
  , ggp_significantDigits         :: Int
  , ggp_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenGaussiansParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

instance FromJSON GenGaussiansParams where

  parseJSON = genericParseJSON $ customOptions 4

-- | Type representing parameters to the @generateSignedGaussianss@ API method.
data GenSigGaussiansParams = GenSigGaussiansParams
  { sggp_params :: GenGaussiansParams
  , sggp_data   :: SignedData
  } deriving (Eq, Show)

instance ToJSON GenSigGaussiansParams where

  toJSON p = sigParamsToJSON p sggp_params sggp_data

instance FromJSON GenSigGaussiansParams where

  parseJSON v = do
    sggp_params <- parseJSON v
    sggp_data <- parseJSON v
    pure GenSigGaussiansParams {..}

-- | Type representing parameters to the @generateStrings@ API method.
data GenStringsParams = GenStringsParams
  { gsp_apiKey                    :: ApiKey
  , gsp_n                         :: Int
  , gsp_length                    :: Int
  , gsp_characters                :: [Char]
  , gsp_replacement               :: Bool
  , gsp_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenStringsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

instance FromJSON GenStringsParams where

  parseJSON = genericParseJSON $ customOptions 4

-- | Type representing parameters to the @generateSignedStrings@ API method.
data GenSigStringsParams = GenSigStringsParams
  { sgsp_params :: GenStringsParams
  , sgsp_data   :: SignedData
  } deriving (Eq, Show)

instance ToJSON GenSigStringsParams where

  toJSON p = sigParamsToJSON p sgsp_params sgsp_data

instance FromJSON GenSigStringsParams where

  parseJSON v = do
    sgsp_params <- parseJSON v
    sgsp_data <- parseJSON v
    pure GenSigStringsParams {..}

-- | Type representing parameters to the @generateUUIDs@ API method.
data GenUUIDsParams = GenUUIDsParams
  { gup_apiKey                    :: ApiKey
  , gup_n                         :: Int
  , gup_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenUUIDsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

instance FromJSON GenUUIDsParams where

  parseJSON = genericParseJSON $ customOptions 4

-- | Type representing parameters to the @generateSignedUUIDs@ API method.
data GenSigUUIDsParams = GenSigUUIDsParams
  { sgup_params :: GenUUIDsParams
  , sgup_data   :: SignedData
  } deriving (Eq, Show)

instance ToJSON GenSigUUIDsParams where

  toJSON p = sigParamsToJSON p sgup_params sgup_data

instance FromJSON GenSigUUIDsParams where

  parseJSON v = do
    sgup_params <- parseJSON v
    sgup_data <- parseJSON v
    pure GenSigUUIDsParams {..}

-- | Type representing parameters to the @generateBlobs@ API method.
data GenBlobsParams = GenBlobsParams
  { gbp_apiKey                    :: ApiKey
  , gbp_n                         :: Int
  , gbp_size                      :: Int
  , gbp_format                    :: BlobFormat
  , gbp_pregeneratedRandomization :: Maybe Seed
  } deriving (Eq, Generic, Show)

instance ToJSON GenBlobsParams where
  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}
  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

instance FromJSON GenBlobsParams where

  parseJSON = genericParseJSON $ customOptions 4

-- | Type representing BLOB formats.
data BlobFormat
  = Base64
  | Hex
  deriving (Eq, Generic, Show)

instance ToJSON BlobFormat where

  toJSON = genericToJSON defaultOptions {constructorTagModifier = map toLower}

  toEncoding =
    genericToEncoding defaultOptions {constructorTagModifier = map toLower}

instance FromJSON BlobFormat where

  parseJSON =
    genericParseJSON defaultOptions {constructorTagModifier = map toLower}

-- | Type representing parameters to the @generateSignedBlobs@ API method.
data GenSigBlobsParams = GenSigBlobsParams
  { sgbp_params :: GenBlobsParams
  , sgbp_data   :: SignedData
  } deriving (Eq, Show)

instance ToJSON GenSigBlobsParams where

  toJSON p = sigParamsToJSON p sgbp_params sgbp_data

instance FromJSON GenSigBlobsParams where

  parseJSON v = do
    sgbp_params <- parseJSON v
    sgbp_data <- parseJSON v
    pure GenSigBlobsParams {..}

data GetResultParams = GetResultParams
  { grp_apiKey       :: Key
  , grp_serialNumber :: Int
  } deriving (Eq, Generic, Show)

instance ToJSON GetResultParams where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data CreateTicketsParams = CreateTicketsParams
  { ctp_apiKey     :: Key
  , ctp_n          :: Int
  , ctp_showResult :: Bool
  } deriving (Eq, Generic, Show)

instance ToJSON CreateTicketsParams where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data RevealTicketsParams = RevealTicketsParams
  { rtp_apiKey     :: Key
  , rtp_ticketId   :: TicketId
  } deriving (Eq, Generic, Show)

instance ToJSON RevealTicketsParams where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

data ListTicketsParams = ListTicketsParams
  { ltp_apiKey     :: Key
  , ltp_ticketType :: TicketType
  } deriving (Eq, Generic, Show)

instance ToJSON ListTicketsParams where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

-- | Type representing types of tickets to list.
data TicketType
  = Singleton
    -- ^ No previous or next tickets.
  | Head
    -- ^ No previous ticket but next ticket.
  | Tail
    -- ^ Previous ticket but no next ticket.
  deriving (Eq, Generic, Show)

instance ToJSON TicketType where

  toJSON = genericToJSON defaultOptions {constructorTagModifier = map toLower}

  toEncoding =
    genericToEncoding defaultOptions  {constructorTagModifier = map toLower}

-- | Type representing parameters to the @getTicket@ API method.
newtype GetTicketParams = GetTicketParams
  { gtp_ticketId :: TicketId
  } deriving (Eq, Generic, Show)

instance ToJSON GetTicketParams where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

-- | Type representing parameters to the @getTicket@ API method.
data VerifySignatureParams = VerifySignatureParams
  { vsp_random    :: Value
  , vsp_signature :: Signature
  } deriving (Eq, Generic, Show)

instance ToJSON VerifySignatureParams where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 4}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 4}

-- | Type representing signatures.
newtype Signature = Signature
  { unSignature :: ByteString
  } deriving (Eq, Show)

instance FromJSON Signature where

  parseJSON = withText "Signature" (pure . Signature . encodeUtf8)

instance ToJSON Signature where

  toJSON = String . decodeUtf8 . unSignature
  toEncoding = unsafeToEncoding . fromByteString . unSignature

-- | Type representing types of tickets to list.
newtype GetUsageParams = GetUsageParams
  { usep_apiKey :: Key
  } deriving (Eq, Generic, Show)

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

-- |Type representing responses from methods of the Signed API yielding random
-- data.
data SignedRandomResponse a b = SignedRandomResponse
  { randomResponse :: RandomResponse a
  , method         :: Method
  , params         :: b
  , license        :: Object
  , licenseData    :: Maybe LicenseData
  , userData       :: Maybe Object
  , ticketData     :: Maybe TicketData
  , serialNumber   :: Int
  , signature      :: Signature
  , cost           :: CurrencyAmount
    -- ^ The cost of the request charged to the RANDOM.ORG account associated
    -- with the API key used in the request.
  } deriving (Eq, Show)

-- | Type representing methods of the Signed API generating random data.
data Method
  = GenerateSignedIntegers
  | GenerateSignedIntegerSequences
  | GenerateSignedDecimalFractions
  | GenerateSignedGaussians
  | GenerateSignedStrings
  | GenerateSignedUUIDs
  | GenerateSignedBlobs
  deriving (Eq, Generic, Show)

instance ToJSON Method where

  toJSON = genericToJSON defaultOptions {constructorTagModifier = firstToLower}

  toEncoding =
    genericToEncoding defaultOptions {constructorTagModifier = firstToLower}

instance FromJSON Method where

  parseJSON =
    genericParseJSON  defaultOptions {constructorTagModifier = firstToLower}

firstToLower :: String -> String
firstToLower "" = ""
firstToLower (x:xs) = toLower x : xs

-- |Type representing data about tickets.
data TicketData = TicketData
  { td_ticketId         :: TicketId
  , td_previousTicketId :: Maybe TicketId
    -- ^ The previous ticket, if any, in the same chain as this ticket.
  , td_nextTicketId     :: Maybe TicketId
    -- ^ The next ticket, if any, in the same chain as this ticket.
  } deriving (Eq, Generic, Show)

instance ToJSON TicketData where

  toJSON = genericToJSON defaultOptions {fieldLabelModifier = drop 3}

  toEncoding = genericToEncoding defaultOptions {fieldLabelModifier = drop 3}

instance FromJSON TicketData where

  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = drop 3}

instance (FromJSON a, FromJSON b) => FromJSON (SignedRandomResponse a b) where

  parseJSON = withObject "random.org signed response" $ \obj -> do
    random <- obj .: "random"
    method <- random .: "method"
    params <- obj .: "random"
    randomData <- random .: "data"
    license <- random .: "license"
    licenseData <- random .: "licenseData"
    userData <- random .: "userData"
    ticketData <- random .: "ticketData"
    completionTime <- random  .: "completionTime"
    serialNumber <- random .: "serialNumber"
    signature <- obj .: "signature"
    cost <- CurrencyAmount USD <$> obj .: "cost"
    bitsUsed <- obj .: "bitsUsed"
    bitsLeft <- obj .: "bitsLeft"
    requestsLeft <- obj .: "requestsLeft"
    advisoryDelay <- obj .: "advisoryDelay"
    let randomResponse = RandomResponse {..}
    pure SignedRandomResponse {..}

toJSONRandom :: (ToJSON a, ToJSON b) => SignedRandomResponse a b -> Value
toJSONRandom srr =
  let paramsKeyMap = case toJSON $ params srr of
        Object paramsKeyMap' -> paramsKeyMap'
        _ -> error "toJSONTandon: no params object!"
      hashedApiKey = case KM.lookup "apiKey" paramsKeyMap of
        Just hashedApiKey' -> hashedApiKey'
        Nothing -> error "toJSONRandom: no apiKey!"
      otherParams = KM.delete "apiKey" paramsKeyMap
      rr = randomResponse srr
  in  Object
        $  KM.singleton "method" (toJSON $ method srr)
        <> KM.singleton "hashedApiKey" hashedApiKey
        <> otherParams
        <> KM.singleton "data" (toJSON $ randomData rr)
        <> KM.singleton "license" (toJSON $ license srr)
        <> KM.singleton "licenseData" (toJSON $ licenseData srr)
        <> KM.singleton "userData" (toJSON $ userData srr)
        <> KM.singleton "ticketData" (toJSON $ ticketData srr)
        <> KM.singleton "completionTime" (toJSON $ DateTime $ completionTime rr)
        <> KM.singleton "serialNumber"  (toJSON $ serialNumber srr)

-- |Type representing responses from the method of the Signed API yielding
-- new tickets.
newtype CreateTicketsResponse = CreateTicketsResponse [TicketResponse]
  deriving (Eq, FromJSON, Generic, Show)

-- |Type representing ticket responses from the Signed API.
data TicketResponse = TicketResponse
  { tr_ticketData       :: TicketData
  , tr_creationTime     :: UTCTime
  } deriving (Eq, Show)

instance FromJSON TicketResponse where

  parseJSON v = do
    tr_ticketData <- parseJSON v
    withObject
      "TicketResponse"
      ( \obj -> do
          tr_creationTime <- obj .: "creationTime"
          pure TicketResponse {..}
      )
      v

-- |Type representing responses from the method of the Signed API revealing
-- tickets.
newtype RevealTicketsResponse = RevealTicketsResponse Int
  deriving (Eq, Show)

instance FromJSON RevealTicketsResponse where

  parseJSON = withObject "RevealTicketsResponse" $ \obj ->
    RevealTicketsResponse <$> obj .: "ticketCount"

-- | Type representing responses from the @listTickets@ or @getTicket@ API
-- methods.
data TicketInfoResponse = TicketInfoResponse
  { ltr_ticketResponse :: TicketResponse
  , ltr_hashedApiKey   :: ApiKey
  , ltr_showResult     :: Bool
  , ltr_usedTime       :: Maybe UTCTime
  , ltr_expirationTime :: Maybe UTCTime
  , ltr_serialNumber   :: Maybe Int
  } deriving (Eq, Show)

instance FromJSON TicketInfoResponse where

  parseJSON v = do
    ltr_ticketResponse <- parseJSON v
    withObject
      "ListTicketRespone"
      ( \obj -> do
          ltr_hashedApiKey <- obj .: "hashedApiKey"
          ltr_showResult <- obj .: "showResult"
          ltr_usedTime <- obj .: "usedTime"
          ltr_expirationTime <- obj .: "expirationTime"
          ltr_serialNumber <- obj .: "serialNumber"
          pure TicketInfoResponse {..}
      )
      v

-- | Type representing responses from the @verifySignature@ API method.
newtype VerifySignatureResponse = VerifySignatureResponse
  { vsr_authenticity :: Bool
  } deriving (Eq, Generic, Show)

instance FromJSON VerifySignatureResponse where

   parseJSON =
      genericParseJSON defaultOptions {fieldLabelModifier = drop 4}

-- | Types representing responses from the @getResult@ API method.
data GetResultResponse
  = Integers (SignedRandomResponse [Int] GenIntegersParams)
  | IntegerSequences (SignedRandomResponse [[Int]] GenIntegerSequencesParams)
  | IntegerSequencesMultiform
      (SignedRandomResponse [[Int]] GenIntegerSequencesMultiformParams)
  | DecimalFractions (SignedRandomResponse [Double] GenDecimalFractionsParams)
  | Gaussians (SignedRandomResponse [Double] GenGaussiansParams)
  | Strings (SignedRandomResponse [Text] GenStringsParams)
  | UUIDs (SignedRandomResponse [UUID] GenUUIDsParams)
  | Blobs (SignedRandomResponse [Blob] GenBlobsParams)
  deriving (Eq, Generic, Show)

instance FromJSON GetResultResponse where

  parseJSON = genericParseJSON defaultOptions {sumEncoding = UntaggedValue}

-- |Type representing responses from the method of the Basic and Signed API
-- yielding information about the API usage.
data UsageResponse = UsageResponse
  { ur_status        :: Status
  , ur_creationTime  :: UTCTime
  , ur_bitsLeft      :: Int
  , ur_requestsLeft  :: Int
  , ur_totalBits     :: Int
  , ur_totalRequests :: Int
  } deriving (Eq, Generic, Show)

instance FromJSON UsageResponse where

  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = drop 3}

-- | Type representing the statuses of API keys.
data Status
  = Running
    -- ^ The API key is running.
  | Stopped
    -- ^ The API key is stopped.
  deriving (Eq, Generic, Show)

instance ToJSON Status where

   toJSON = genericToJSON defaultOptions {constructorTagModifier = map toLower}

   toEncoding =
      genericToEncoding defaultOptions {constructorTagModifier = map toLower}

instance FromJSON Status where

   parseJSON =
      genericParseJSON  defaultOptions {constructorTagModifier = map toLower}

api :: Proxy JsonRpcAPI
api = Proxy

randomDotOrgApi :: BaseUrl
randomDotOrgApi = BaseUrl Https "api.random.org" 443 ""

-- |Type representing API keys.
newtype Key = Key
  { unKey :: ByteString
  } deriving (Eq, Show)

instance ToJSON Key where

  toJSON = String . decodeUtf8 . unKey
  toEncoding = unsafeToEncoding . fromByteString . unKey

instance FromJSON Key where

   parseJSON = withText "Key" (pure . Key . encodeUtf8)

-- | Type representing API keys or hashed API keys.
data ApiKey
  = HashedApiKey ByteString
  | ApiKey Key
  deriving (Eq, Show)

instance ToJSON ApiKey where

  toJSON (HashedApiKey hashedApiKey) = String $ decodeUtf8 hashedApiKey
  toJSON (ApiKey apiKey) = toJSON apiKey

  toEncoding (HashedApiKey hashedApiKey) =
    unsafeToEncoding $ fromByteString hashedApiKey
  toEncoding (ApiKey apiKey) = toEncoding apiKey

-- | Parsing of JSON will prefer the v'HashedApiKey' data constructor to the
-- v'ApiKey' data constructor. That is because the responses from the Signed
-- API include hashed API keys.
instance FromJSON ApiKey where

  parseJSON = withText "ApiKey" (pure . HashedApiKey . encodeUtf8)

-- |This method generates true random integers within a user-defined range. If
-- successful, the function yields the random data and the advised delay in
-- milliseconds.
genIntegers ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of integers requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([Int], Int))
genIntegers mgr key = genWithSeedIntegers mgr key Nothing

-- |This method generates true random integers within a user-defined range.
genIntegers' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of integers requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [Int]))
genIntegers' mgr key = genWithSeedIntegers' mgr key Nothing

-- |This method generates true random integers within a user-defined range. If
-- successful, the function yields the random data and the advised delay in
-- milliseconds.
genWithSeedIntegers ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of integers requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([Int], Int))
genWithSeedIntegers mgr key mSeed replacement n rangeMin rangeMax =
  toMaybe <$> genWithSeedIntegers' mgr key mSeed replacement n rangeMin rangeMax

-- |This method generates true random integers within a user-defined range.
genWithSeedIntegers' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of integers requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [Int]))
genWithSeedIntegers' mgr key mSeed replacement n rangeMin rangeMax = runClientM
  (generateIntegers params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenIntegersParams
    { gip_apiKey                    = ApiKey key
    , gip_n                         = n
    , gip_min                       = rangeMin
    , gip_max                       = rangeMax
    , gip_replacement               = replacement
    , gip_base                      = 10
    , gip_pregeneratedRandomization = mSeed
    }

generateIntegers :: GenIntegersParams -> ClientM (RndResponse [Int])

-- |This method generates true random integers within a user-defined range.
genSignedIntegers ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of integers requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (ClientSigResponse [Int] GenIntegersParams)
genSignedIntegers mgr key = genWithSeedSignedIntegers mgr key Nothing

-- |This method generates true random integers within a user-defined range.
genWithSeedSignedIntegers ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of integers requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (ClientSigResponse [Int] GenIntegersParams)
genWithSeedSignedIntegers
    mgr
    key
    mSeed
    mLicenseData
    mUserData
    mTicketId
    replacement
    n
    rangeMin
    rangeMax
  = runClientM
      (generateSignedIntegers params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigIntegersParams
    { sgip_params =
        GenIntegersParams
          { gip_apiKey                    = ApiKey key
          , gip_n                         = n
          , gip_min                       = rangeMin
          , gip_max                       = rangeMax
          , gip_replacement               = replacement
          , gip_base                      = 10
          , gip_pregeneratedRandomization = mSeed
          }
    , sgip_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedIntegers ::
     GenSigIntegersParams
  -> ClientM (SigRndResponse [Int] GenIntegersParams)

-- |This method generates sequences of true random integers within a
-- user-defined range. If successful, the function yields the random data and
-- the advised delay in milliseconds.
genIntegerSequences ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([[Int]], Int))
genIntegerSequences mgr key = genWithSeedIntegerSequences mgr key Nothing

-- |This method generates sequences of true random integers within a
-- user-defined range.
genIntegerSequences' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [[Int]]))
genIntegerSequences' mgr key = genWithSeedIntegerSequences' mgr key Nothing

-- |This method generates sequences of true random integers within a
-- user-defined range. If successful, the function yields the random data and
-- the advised delay in milliseconds.
genWithSeedIntegerSequences ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Maybe ([[Int]], Int))
genWithSeedIntegerSequences mgr key mSeed replacement n l rangeMin rangeMax =
  toMaybe <$>
    genWithSeedIntegerSequences' mgr key mSeed replacement n l rangeMin rangeMax

-- |This method generates sequences of true random integers within a
-- user-defined range.
genWithSeedIntegerSequences' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (Either ClientError (RndResponse [[Int]]))
genWithSeedIntegerSequences' mgr key mSeed replacement n l rangeMin rangeMax =
  runClientM
    (generateIntegerSequences params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
    (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
    (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenIntegerSequencesParams
    { gisp_apiKey                    = ApiKey key
    , gisp_n                         = n
    , gisp_length                    = l
    , gisp_min                       = rangeMin
    , gisp_max                       = rangeMax
    , gisp_replacement               = replacement
    , gisp_base                      = 10
    , gisp_pregeneratedRandomization = mSeed
    }

generateIntegerSequences ::
     GenIntegerSequencesParams
  -> ClientM (RndResponse [[Int]])

-- |This method generates sequences of true random integers within a
-- user-defined range.
genSignedIntegerSequences ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (ClientSigResponse [[Int]] GenIntegerSequencesParams)
genSignedIntegerSequences mgr key =
  genWithSeedSignedIntegerSequences mgr key Nothing

-- |This method generates sequences of true random integers within a
-- user-defined range.
genWithSeedSignedIntegerSequences ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> Int
     -- ^ The length of the sequence. Must be in the range [1, 10,000].
  -> Int
     -- ^ The lower boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> Int
     -- ^ The upper boundary for the range from which the random integers will
     -- be picked. Must be within the range [-1,000,000,000, 1,000,000,000].
  -> IO (ClientSigResponse [[Int]] GenIntegerSequencesParams)
genWithSeedSignedIntegerSequences
    mgr
    key
    mSeed
    mLicenseData
    mUserData
    mTicketId
    replacement
    n
    l
    rangeMin
    rangeMax
  = runClientM
      (generateSignedIntegerSequences params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigIntegerSequencesParams
    { sgisp_params =
        GenIntegerSequencesParams
          { gisp_apiKey                    = ApiKey key
          , gisp_n                         = n
          , gisp_length                    = l
          , gisp_min                       = rangeMin
          , gisp_max                       = rangeMax
          , gisp_replacement               = replacement
          , gisp_base                      = 10
          , gisp_pregeneratedRandomization = mSeed
          }
    , sgisp_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedIntegerSequences ::
     GenSigIntegerSequencesParams
  -> ClientM (SigRndResponse [[Int]] GenIntegerSequencesParams)

-- |This method generates multiform sequences of true random integers within a
-- user-defined range. If successful, the function yields the random data and
-- the advised delay in milliseconds.
genIntegerSequencesMultiform ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacment?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> [Int]
     -- ^ The lengths of the sequences. Each must be in the range [1, 10,000].
  -> Boundary
     -- ^ The lower boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> Boundary
     -- ^ The upper boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> IO (Maybe ([[Int]], Int))
genIntegerSequencesMultiform mgr key =
  genWithSeedIntegerSequencesMultiform mgr key Nothing

-- |This method generates multiform sequences of true random integers within a
-- user-defined range.
genIntegerSequencesMultiform' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> [Int]
     -- ^ The lengths of the sequences. Each must be in the range [1, 10,000].
  -> Boundary
     -- ^ The lower boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> Boundary
     -- ^ The upper boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> IO (Either ClientError (RndResponse [[Int]]))
genIntegerSequencesMultiform' mgr key =
  genWithSeedIntegerSequencesMultiform' mgr key Nothing

-- |This method generates multiform sequences of true random integers within a
-- user-defined range. If successful, the function yields the random data and
-- the advised delay in milliseconds.
genWithSeedIntegerSequencesMultiform ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> [Int]
     -- ^ The lengths of the sequences. Each must be in the range [1, 10,000].
  -> Boundary
     -- ^ The lower boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> Boundary
     -- ^ The upper boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> IO (Maybe ([[Int]], Int))
genWithSeedIntegerSequencesMultiform
    mgr
    key
    mSeed
    replacement
    n
    ls
    rangeMin
    rangeMax
  = toMaybe <$>
      genWithSeedIntegerSequencesMultiform'
        mgr
        key
        mSeed
        replacement
        n
        ls
        rangeMin
        rangeMax

-- |This method generates multiform sequences of true random integers within a
-- user-defined range.
genWithSeedIntegerSequencesMultiform' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> [Int]
     -- ^ The lengths of the sequences. Each must be in the range [1, 10,000].
  -> Boundary
     -- ^ The lower boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> Boundary
     -- ^ The upper boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range [-1,000,000,000,
     -- 1,000,000,000].
  -> IO (Either ClientError (RndResponse [[Int]]))
genWithSeedIntegerSequencesMultiform'
    mgr
    key
    mSeed
    replacement
    n
    ls
    rangeMin
    rangeMax
  = runClientM
      (generateIntegerSequencesMultiform params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenIntegerSequencesMultiformParams
    { gismp_apiKey                    = ApiKey key
    , gismp_n                         = n
    , gismp_length                    = ls
    , gismp_min                       = rangeMin
    , gismp_max                       = rangeMax
    , gismp_replacement               = replacement
    , gismp_base                      = 10
    , gismp_pregeneratedRandomization = mSeed
    }

generateIntegerSequencesMultiform ::
     GenIntegerSequencesMultiformParams
  -> ClientM (RndResponse [[Int]])

-- |This method generates multiform sequences of true random integers within a
-- user-defined range.
genSignedIntegerSequencesMultiform ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> [Int]
     -- ^ The lengths of the sequences. Each must be in the range [1, 10,000].
  -> Boundary
     -- ^ The lower boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range
     -- [-1,000,000,000, 1,000,000,000].
  -> Boundary
     -- ^ The upper boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range
     -- [-1,000,000,000, 1,000,000,000].
  -> IO (ClientSigResponse [[Int]] GenIntegerSequencesMultiformParams)
genSignedIntegerSequencesMultiform mgr key =
  genWithSeedSignedIntegerSequencesMultiform mgr key Nothing

-- |This method generates multiform sequences of true random integers within a
-- user-defined range.
genWithSeedSignedIntegerSequencesMultiform ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of sequences requested. Must be in the range [1, 10,000].
  -> [Int]
     -- ^ The lengths of the sequences. Each must be in the range [1, 10,000].
  -> Boundary
     -- ^ The lower boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range
     -- [-1,000,000,000, 1,000,000,000].
  -> Boundary
     -- ^ The upper boundary (or boundaries) for the range from which the random
     -- integers will be picked. Must be within the range
     -- [-1,000,000,000, 1,000,000,000].
  -> IO (ClientSigResponse [[Int]] GenIntegerSequencesMultiformParams)
genWithSeedSignedIntegerSequencesMultiform
    mgr
    key
    mSeed
    mLicenseData
    mUserData
    mTicketId
    replacement
    n
    ls
    rangeMin
    rangeMax
  = runClientM
      (generateSignedIntegerSequencesMultiform params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigIntegerSequencesMultiformParams
    { sgismp_params =
        GenIntegerSequencesMultiformParams
          { gismp_apiKey                    = ApiKey key
          , gismp_n                         = n
          , gismp_length                    = ls
          , gismp_min                       = rangeMin
          , gismp_max                       = rangeMax
          , gismp_replacement               = replacement
          , gismp_base                      = 10
          , gismp_pregeneratedRandomization = mSeed
          }
    , sgismp_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedIntegerSequencesMultiform ::
     GenSigIntegerSequencesMultiformParams
  -> ClientM (SigRndResponse [[Int]] GenIntegerSequencesMultiformParams)

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places. If successful, the function yields the random data and the advised
-- delay in milliseconds.
genDecimalFractions ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of decimal fractions requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The number of decimal places. Must be within the range [1, 14].
  -> IO (Maybe ([Double], Int))
genDecimalFractions mgr key = genWithSeedDecimalFractions mgr key Nothing

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places.
genDecimalFractions' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of decimal fractions requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The number of decimal places. Must be within the range [1, 14].
  -> IO (Either ClientError (RndResponse [Double]))
genDecimalFractions' mgr key = genWithSeedDecimalFractions' mgr key Nothing

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places. If successful, the function yields the random data and the advised
-- delay in milliseconds.
genWithSeedDecimalFractions ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of decimal fractions requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The number of decimal places. Must be within the range [1, 14].
  -> IO (Maybe ([Double], Int))
genWithSeedDecimalFractions mgr key mSeed replacement n dps =
  toMaybe <$> genWithSeedDecimalFractions' mgr key mSeed replacement n dps

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places.
genWithSeedDecimalFractions' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of decimal fractions requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The number of decimal places. Must be within the range [1, 14].
  -> IO (Either ClientError (RndResponse [Double]))
genWithSeedDecimalFractions' mgr key mSeed replacement n dps = runClientM
  (generateDecimalFractions params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenDecimalFractionsParams
    { gdfp_apiKey                    = ApiKey key
    , gdfp_n                         = n
    , gdfp_decimalPlaces             = dps
    , gdfp_replacement               = replacement
    , gdfp_pregeneratedRandomization = mSeed
    }

generateDecimalFractions ::
     GenDecimalFractionsParams
  -> ClientM (RndResponse [Double])

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places.
genSignedDecimalFractions ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of decimal fractions requested. Must be in the range
     -- [1, 10,000].
  -> Int
     -- ^ The number of decimal places. Must be within the range [1, 14].
  -> IO (ClientSigResponse [Double] GenDecimalFractionsParams)
genSignedDecimalFractions mgr key =
  genWithSeedSignedDecimalFractions mgr key Nothing

-- |This method generates true random decimal fractions from a uniform
-- distribution across the interval [0, 1) with a user-defined number of decimal
-- places.
genWithSeedSignedDecimalFractions ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of decimal fractions requested. Must be in the range
     -- [1, 10,000].
  -> Int
     -- ^ The number of decimal places. Must be within the range [1, 14].
  -> IO (ClientSigResponse [Double] GenDecimalFractionsParams)
genWithSeedSignedDecimalFractions
    mgr
    key
    mSeed
    mLicenseData
    mUserData
    mTicketId
    replacement
    n
    dps
  = runClientM
      (generateSignedDecimalFractions params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigDecimalFractionsParams
    { sgdfp_params =
        GenDecimalFractionsParams
          { gdfp_apiKey                    = ApiKey key
          , gdfp_n                         = n
          , gdfp_decimalPlaces             = dps
          , gdfp_replacement               = replacement
          , gdfp_pregeneratedRandomization = mSeed
          }
    , sgdfp_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedDecimalFractions ::
     GenSigDecimalFractionsParams
  -> ClientM (SigRndResponse [Double] GenDecimalFractionsParams)

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.  If
-- successful, the function yields the random data and the advised delay in
-- milliseconds.
genGaussians ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The number of random numbers requested. Must be in the range [1,
     -- 10,000].
  -> Double
     -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double
     -- ^ The standard deviation. Must be in the range [-1,000,000, 1,000,000].
  -> Int
     -- ^ The number of significant digits. Must be within the range [2, 14].
  -> IO (Maybe ([Double], Int))
genGaussians mgr key = genWithSeedGaussians mgr key Nothing

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.
genGaussians' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The number of random numbers requested. Must be in the range [1,
     -- 10,000].
  -> Double
     -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double
     -- ^ The standard deviation. Must be in the range [-1,000,000, 1,000,000].
  -> Int
     -- ^ The number of significant digits. Must be within the range [2, 14].
  -> IO (Either ClientError (RndResponse [Double]))
genGaussians' mgr key = genWithSeedGaussians' mgr key Nothing

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.  If
-- successful, the function yields the random data and the advised delay in
-- milliseconds.
genWithSeedGaussians ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Int      -- ^ The number of random numbers requested. Must be in the range
              --   [1, 10,000].
  -> Double   -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double   -- ^ The standard deviation. Must be in the range [-1,000,000,
              --   1,000,000].
  -> Int      -- ^ The number of significant digits. Must be within the range
              --   [2, 14].
  -> IO (Maybe ([Double], Int))
genWithSeedGaussians mgr key mSeed n mean sd sds =
  toMaybe <$> genWithSeedGaussians' mgr key mSeed n mean sd sds

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.
genWithSeedGaussians' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Int
     -- ^ The number of random numbers requested. Must be in the range [1,
     -- 10,000].
  -> Double
     -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double
     -- ^ The standard deviation. Must be in the range [-1,000,000, 1,000,000].
  -> Int
     -- ^ The number of significant digits. Must be within the range [2, 14].
  -> IO (Either ClientError (RndResponse [Double]))
genWithSeedGaussians' mgr key mSeed n mean sd sds = runClientM
  (generateGaussians params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenGaussiansParams
    { ggp_apiKey                    = ApiKey key
    , ggp_n                         = n
    , ggp_mean                      = mean
    , ggp_standardDeviation         = sd
    , ggp_significantDigits         = sds
    , ggp_pregeneratedRandomization = mSeed
    }

generateGaussians :: GenGaussiansParams -> ClientM (RndResponse [Double])

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.
genSignedGaussians ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Int
     -- ^ The number of random numbers requested. Must be in the range
     -- [1, 10,000].
  -> Double
     -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double
     -- ^ The standard deviation. Must be in the range [-1,000,000, 1,000,000].
  -> Int
     -- ^ The number of significant digits. Must be within the range [2, 14].
  -> IO (ClientSigResponse [Double] GenGaussiansParams)
genSignedGaussians mgr key = genWithSeedSignedGaussians mgr key Nothing

-- |This method generates true random numbers from a Gaussian distribution (also
-- known as a normal distribution). The method uses a Box-Muller Transform to
-- generate the Gaussian distribution from uniformly distributed numbers.
genWithSeedSignedGaussians ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Int
     -- ^ The number of random numbers requested. Must be in the range
     -- [1, 10,000].
  -> Double
     -- ^ The mean. Must be in the range [-1,000,000, 1,000,000].
  -> Double
     -- ^ The standard deviation. Must be in the range [-1,000,000, 1,000,000].
  -> Int
     -- ^ The number of significant digits. Must be within the range [2, 14].
  -> IO (ClientSigResponse [Double] GenGaussiansParams)
genWithSeedSignedGaussians
    mgr
    key
    mSeed
    mLicenseData
    mUserData
    mTicketId
    n
    mean
    sd
    sds
  = runClientM
      (generateSignedGaussians params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigGaussiansParams
    { sggp_params =
        GenGaussiansParams
          { ggp_apiKey                    = ApiKey key
          , ggp_n                         = n
          , ggp_mean                      = mean
          , ggp_standardDeviation         = sd
          , ggp_significantDigits         = sds
          , ggp_pregeneratedRandomization = mSeed
          }
    , sggp_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedGaussians ::
     GenSigGaussiansParams
  -> ClientM (SigRndResponse [Double] GenGaussiansParams)

-- |This method generates true random strings. If successful, the function
-- yields the random data and the advised delay in milliseconds.
genStrings ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of random strings requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The length of each string. Must be in the range [1, 32].
  -> [Char]
     -- ^ The set of characters that are allowed to occur in the random strings.
     -- The maximum number of characters is 128.
  -> IO (Maybe ([Text], Int))
genStrings mgr key = genWithSeedStrings mgr key Nothing

-- |This method generates true random strings.
genStrings' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of random strings requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The length of each string. Must be in the range [1, 32].
  -> [Char]
     -- ^ The set of characters that are allowed to occur in the random strings.
     -- The maximum number of characters is 128.
  -> IO (Either ClientError (RndResponse [Text]))
genStrings' mgr key = genWithSeedStrings' mgr key Nothing

-- |This method generates true random strings. If successful, the function
-- yields the random data and the advised delay in milliseconds.
genWithSeedStrings ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of random strings requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The length of each string. Must be in the range [1, 32].
  -> [Char]
     -- ^ The set of characters that are allowed to occur in the random strings.
     -- The maximum number of characters is 128.
  -> IO (Maybe ([Text], Int))
genWithSeedStrings mgr key mSeed replacement n l cs =
  toMaybe <$> genWithSeedStrings' mgr key mSeed replacement n l cs

-- |This method generates true random strings.
genWithSeedStrings' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of random strings requested. Must be in the range [1,
     -- 10,000].
  -> Int
     -- ^ The length of each string. Must be in the range [1, 32].
  -> [Char]
     -- ^ The set of characters that are allowed to occur in the random strings.
     -- The maximum number of characters is 128.
  -> IO (Either ClientError (RndResponse [Text]))
genWithSeedStrings' mgr key mSeed replacement n l cs = runClientM
  (generateStrings params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenStringsParams
    { gsp_apiKey                    = ApiKey key
    , gsp_n                         = n
    , gsp_length                    = l
    , gsp_characters                = cs
    , gsp_replacement               = replacement
    , gsp_pregeneratedRandomization = mSeed
    }

generateStrings :: GenStringsParams -> ClientM (RndResponse [Text])

-- |This method generates true random strings.
genSignedStrings ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of random strings requested. Must be in the range
     -- [1, 10,000].
  -> Int
     -- ^ The length of each string. Must be in the range [1, 32].
  -> [Char]
     -- ^ The set of characters that are allowed to occur in the random strings.
     -- The maximum number of characters is 128.
  -> IO (ClientSigResponse [Text] GenStringsParams)
genSignedStrings mgr key = genWithSeedSignedStrings mgr key Nothing

-- |This method generates true random strings.
genWithSeedSignedStrings ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Bool
     -- ^ With replacement?
  -> Int
     -- ^ The number of random strings requested. Must be in the range
     -- [1, 10,000].
  -> Int
     -- ^ The length of each string. Must be in the range [1, 32].
  -> [Char]
     -- ^ The set of characters that are allowed to occur in the random strings.
     -- The maximum number of characters is 128.
  -> IO (ClientSigResponse [Text] GenStringsParams)
genWithSeedSignedStrings
    mgr
    key
    mSeed
    mLicenseData
    mUserData
    mTicketId
    replacement
    n
    l
    cs
  = runClientM
      (generateSignedStrings params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
      (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigStringsParams
    { sgsp_params =
        GenStringsParams
          { gsp_apiKey                    = ApiKey key
          , gsp_n                         = n
          , gsp_length                    = l
          , gsp_characters                = cs
          , gsp_replacement               = replacement
          , gsp_pregeneratedRandomization = mSeed
          }
    , sgsp_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedStrings ::
     GenSigStringsParams
  -> ClientM (SigRndResponse [Text] GenStringsParams)

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122. If successful, the
-- function yields the random data and the advised delay in milliseconds.
genUUIDs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The number of random UUIDs requested. Must be in the range [1,
     -- 10,000].
  -> IO (Maybe ([UUID], Int))
genUUIDs mgr key = genWithSeedUUIDs mgr key Nothing

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122.
genUUIDs' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The number of random UUIDs requested. Must be in the range [1,
     -- 10,000].
  -> IO (Either ClientError (RndResponse [UUID]))
genUUIDs' mgr key = genWithSeedUUIDs' mgr key Nothing

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122. If successful, the
-- function yields the random data and the advised delay in milliseconds.
genWithSeedUUIDs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Int
     -- ^ The number of random UUIDs requested. Must be in the range [1,
     -- 10,000].
  -> IO (Maybe ([UUID], Int))
genWithSeedUUIDs mgr key mSeed n = toMaybe <$> genWithSeedUUIDs' mgr key mSeed n

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122.
genWithSeedUUIDs' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Int
     -- ^ The number of random UUIDs requested. Must be in the range [1,
     -- 10,000].
  -> IO (Either ClientError (RndResponse [UUID]))
genWithSeedUUIDs' mgr key mSeed n = runClientM
  (generateUUIDs params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenUUIDsParams
    { gup_apiKey                    = ApiKey key
    , gup_n                         = n
    , gup_pregeneratedRandomization = mSeed
    }

generateUUIDs :: GenUUIDsParams -> ClientM (RndResponse [UUID])

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122.
genSignedUUIDs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Int
     -- ^ The number of random UUIDs requested. Must be in the range
     -- [1, 10,000].
  -> IO (ClientSigResponse [UUID] GenUUIDsParams)
genSignedUUIDs mgr key = genWithSeedSignedUUIDs mgr key Nothing

-- |This method generates true random version 4 Universally Unique IDentifiers
-- (UUIDs) in accordance with section 4.4 of RFC 4122.
genWithSeedSignedUUIDs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Int
     -- ^ The number of random UUIDs requested. Must be in the range
     -- [1, 10,000].
  -> IO (ClientSigResponse [UUID] GenUUIDsParams)
genWithSeedSignedUUIDs mgr key mSeed mLicenseData mUserData mTicketId n =
  runClientM
    (generateSignedUUIDs params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
    (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
    (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigUUIDsParams
    { sgup_params =
        GenUUIDsParams
          { gup_apiKey                    = ApiKey key
          , gup_n                         = n
          , gup_pregeneratedRandomization = mSeed
          }
    , sgup_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedUUIDs ::
     GenSigUUIDsParams
  -> ClientM (SigRndResponse [UUID] GenUUIDsParams)

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
-- If successful, the function yields the random data and the advised delay in
-- milliseconds.
genBlobs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The number of random BLOBs requested. Must be in the range [1, 100].
  -> Int
     -- ^ The size of each blob, measured in bytes. Must be in the range [1,
     -- 131,072].
  -> BlobFormat
     -- ^ The format of the BLOBs.
  -> IO (Maybe ([Blob], Int))
genBlobs mgr key = genWithSeedBlobs mgr key Nothing

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
genBlobs' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The number of random BLOBs requested. Must be in the range [1, 100].
  -> Int
     -- ^ The size of each blob, measured in bytes (not bits). Must be in the
     -- range [1, 131,072].
  -> BlobFormat
     -- ^ The format of the BLOBs.
  -> IO (Either ClientError (RndResponse [Blob]))
genBlobs' mgr key = genWithSeedBlobs' mgr key Nothing

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
-- If successful, the function yields the random data and the advised delay in
-- milliseconds.
genWithSeedBlobs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Int
     -- ^ The number of random BLOBs requested. Must be in the range [1, 100].
  -> Int
     -- ^ The size of each blob, measured in bytes. Must be in the range [1,
     -- 131,072].
  -> BlobFormat
     -- ^ The format of the BLOBs.
  -> IO (Maybe ([Blob], Int))
genWithSeedBlobs mgr key mSeed n s f =
  toMaybe <$> genWithSeedBlobs' mgr key mSeed n s f

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
genWithSeedBlobs' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Int
     -- ^ The number of random BLOBs requested. Must be in the range [1, 100].
  -> Int
     -- ^ The size of each blob, measured in bytes (not bits). Must be in the
     -- range [1, 131,072].
  -> BlobFormat
     -- ^ The format of the BLOBs.
  -> IO (Either ClientError (RndResponse [Blob]))
genWithSeedBlobs' mgr key mSeed n s f = runClientM
  (generateBlobs params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenBlobsParams
    { gbp_apiKey                    = ApiKey key
    , gbp_n                         = n
    , gbp_size                      = s * 8
    , gbp_format                    = f
    , gbp_pregeneratedRandomization = mSeed
    }

generateBlobs :: GenBlobsParams -> ClientM (RndResponse [Blob])

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
genSignedBlobs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Int
     -- ^ The number of random BLOBs requested. Must be in the range [1, 100].
  -> Int
     -- ^ The size of each blob, measured in bytes (not bits). Must be in the
     -- range [1, 131,072].
  -> BlobFormat
     -- ^ The format of the BLOBs.
  -> IO (ClientSigResponse [Blob] GenBlobsParams)
genSignedBlobs mgr key = genWithSeedSignedBlobs mgr key Nothing

-- |This method generates true random Binary Large OBjects (BLOBs). The total
-- size of all BLOBs requested must not exceed 131,072 bytes (128 kilobytes).
genWithSeedSignedBlobs ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Maybe Seed
     -- ^ The optional seed.
  -> Maybe LicenseData
     -- ^ Data, if any, of relevance to the license that is associated with the
     -- API key.
  -> Maybe Object
     -- ^ Optional user data to be included in the signed response.
  -> Maybe TicketId
     -- ^ Optional unique ticket ID. Can be used only once.
  -> Int
     -- ^ The number of random BLOBs requested. Must be in the range [1, 100].
  -> Int
     -- ^ The size of each blob, measured in bytes (not bits). Must be in the
     -- range [1, 131,072].
  -> BlobFormat
     -- ^ The format of the BLOBs.
  -> IO (ClientSigResponse [Blob] GenBlobsParams)
genWithSeedSignedBlobs mgr key mSeed mLicenseData mUserData mTicketId n s f =
  runClientM
    (generateSignedBlobs params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
    (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
    (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GenSigBlobsParams
    { sgbp_params =
        GenBlobsParams
          { gbp_apiKey                    = ApiKey key
          , gbp_n                         = n
          , gbp_size                      = s * 8
          , gbp_format                    = f
          , gbp_pregeneratedRandomization = mSeed
          }
    , sgbp_data =
        SignedData mLicenseData mUserData mTicketId
    }

generateSignedBlobs ::
     GenSigBlobsParams
  -> ClientM (SigRndResponse [Blob] GenBlobsParams)

-- |Helper function to help simplify method functions
toMaybe :: Either ClientError (RndResponse a) -> Maybe (a, Int)
toMaybe (Right (Result _ result')) =
  Just (randomData result', advisoryDelay result')
toMaybe _                          = Nothing

-- | Retrieve a previously generated result from its serial number.
getResult ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key.
  -> Int
     -- ^ The serial number.
  -> IO (Either ClientError (JsonRpcResponse Value GetResultResponse))
getResult mgr key serialNumber = runClientM
  (getResult' params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GetResultParams
    { grp_apiKey = key
    , grp_serialNumber = serialNumber
    }

getResult' ::
     GetResultParams
  -> ClientM (JsonRpcResponse Value GetResultResponse)

-- | Create unique tickets for use with the Signed API.
createTickets ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key
  -> Int
     -- ^ The number of tickets requested. Must be in the range [1, 50].
  -> Bool
     -- ^ Make full information about the ticket available?
  -> IO [TicketResponse]
createTickets mgr key n showResult =
  createTickets' mgr key n showResult >>= \case
    Right (Result _ (CreateTicketsResponse ticketResponses)) ->
      pure ticketResponses
    _ -> pure []

-- | Create unique tickets for use with the Signed API.
createTickets' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key
  -> Int
     -- ^ The number of tickets requested. Must be in the range [1, 50].
  -> Bool
     -- ^ Make full information about the ticket available?
  -> IO (Either ClientError (JsonRpcResponse Value CreateTicketsResponse))
createTickets' mgr key n showResult = runClientM
  (createTickets'' params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = CreateTicketsParams
    { ctp_apiKey = key
    , ctp_n = n
    , ctp_showResult = showResult
    }

createTickets'' ::
     CreateTicketsParams
  -> ClientM (JsonRpcResponse Value CreateTicketsResponse)

-- | This method enables other methods to reveal greater information about the
-- given ticket.
revealTickets ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key
  -> TicketId
     -- ^ The ticketId to reveal.
  -> IO (Maybe Int)
revealTickets mgr key ticketId =
  revealTickets' mgr key ticketId >>= \case
    Right (Result _ (RevealTicketsResponse ticketCount)) ->
      pure $ Just ticketCount
    _ -> pure Nothing

-- | This method enables other methods to reveal greater information about the
-- given ticket.
revealTickets' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key
  -> TicketId
     -- ^ The ticketId to reveal.
  -> IO (Either ClientError (JsonRpcResponse Value RevealTicketsResponse))
revealTickets' mgr key ticketId = runClientM
  (revealTickets'' params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = RevealTicketsParams
    { rtp_apiKey = key
    , rtp_ticketId = ticketId
    }

revealTickets'' ::
     RevealTicketsParams
  -> ClientM (JsonRpcResponse Value RevealTicketsResponse)

-- | This method enables other methods to reveal greater information about the
-- given ticket.
listTickets ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key
  -> TicketType
     -- ^ The type of tickets to obtain information about.
  -> IO [TicketInfoResponse]
listTickets mgr key ticketType =
  listTickets' mgr key ticketType >>= \case
    Right (Result _ listTicketsResponses) ->
      pure listTicketsResponses
    _ -> pure []

-- | This method enables other methods to reveal greater information about the
-- given ticket.
listTickets' ::
     Manager
     -- ^ The connection manager.
  -> Key
     -- ^ The API key
  -> TicketType
     -- ^ The type of tickets to obtain information about.
  -> IO (Either ClientError (JsonRpcResponse Value [TicketInfoResponse]))
listTickets' mgr key ticketType = runClientM
  (listTickets'' params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = ListTicketsParams
    { ltp_apiKey = key
    , ltp_ticketType = ticketType
    }

listTickets'' ::
     ListTicketsParams
  -> ClientM (JsonRpcResponse Value [TicketInfoResponse])

-- | This method yields information about the given ticket.
getTicket ::
     Manager
     -- ^ The connection manager.
  -> TicketId
     -- ^ The ticket to obtain information about.
  -> IO (Maybe TicketInfoResponse)
getTicket mgr ticketId =
  getTicket' mgr ticketId >>= \case
    Right (Result _ ticketInfoResponse) ->
      pure $ Just ticketInfoResponse
    _ -> pure Nothing

-- | This method yields information about the given ticket.
getTicket' ::
     Manager
     -- ^ The connection manager.
  -> TicketId
     -- ^ The ticket to obtain information about.
  -> IO (Either ClientError (JsonRpcResponse Value TicketInfoResponse))
getTicket' mgr ticketId = runClientM (getTicket'' params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GetTicketParams
    { gtp_ticketId = ticketId
    }

getTicket'' ::
     GetTicketParams
  -> ClientM (JsonRpcResponse Value TicketInfoResponse)

-- | This method verifies a response from the Signed API.
verifySignedResponse ::
     (ToJSON a, ToJSON b)
  => Manager
     -- ^ The connection manager.
  -> SignedRandomResponse a b
     -- ^ The ticket to obtain information about.
  -> IO (Maybe Bool)
verifySignedResponse mgr srr =
   verifySignedResponse' mgr srr >>= \case
    Right (Result _ vsr) ->
      pure $ Just $ vsr_authenticity vsr
    _ -> pure Nothing

-- | This method verifies a response from the Signed API.
verifySignedResponse' ::
     (ToJSON a, ToJSON b)
  => Manager
     -- ^ The connection mannager.
  -> SignedRandomResponse a b
     -- ^ The ticket to obtain information about.
  -> IO (Either ClientError (JsonRpcResponse Value VerifySignatureResponse))
verifySignedResponse' mgr srr = runClientM
  (verifySignature params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = VerifySignatureParams
    { vsp_random = toJSONRandom srr
    , vsp_signature = signature srr
    }

verifySignature ::
     VerifySignatureParams
  -> ClientM (JsonRpcResponse Value VerifySignatureResponse)

-- |This method returns information related to the usage of a given API key.
getUsage ::
     Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key
  -> IO (Maybe UsageResponse)
getUsage mgr key =
  getUsage' mgr key >>= \case
    Right (Result _ usageResponse) -> pure $ Just usageResponse
    _ -> pure Nothing

-- |This method returns information related to the usage of a given API key.
getUsage' ::
     Manager  -- ^ The connection manager.
  -> Key      -- ^ The API key
  -> IO (Either ClientError (JsonRpcResponse Value UsageResponse))
getUsage' mgr key = runClientM
  (getUsage'' params)
-- middleware supported from servant-client-0.20.2
#if MIN_VERSION_servant_client(0,20,2)
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest id)
#else
  (ClientEnv mgr randomDotOrgApi Nothing defaultMakeClientRequest)
#endif
 where
  params = GetUsageParams
             { usep_apiKey = key
             }

getUsage'' :: GetUsageParams -> ClientM (JsonRpcResponse Value UsageResponse)

generateIntegers
  :<|> generateIntegerSequences
  :<|> generateIntegerSequencesMultiform
  :<|> generateDecimalFractions
  :<|> generateGaussians
  :<|> generateStrings
  :<|> generateUUIDs
  :<|> generateBlobs
  :<|> generateSignedIntegers
  :<|> generateSignedIntegerSequences
  :<|> generateSignedIntegerSequencesMultiform
  :<|> generateSignedDecimalFractions
  :<|> generateSignedGaussians
  :<|> generateSignedStrings
  :<|> generateSignedUUIDs
  :<|> generateSignedBlobs
  :<|> getResult'
  :<|> createTickets''
  :<|> revealTickets''
  :<|> listTickets''
  :<|> getTicket''
  :<|> verifySignature
  :<|> getUsage''
  = client api
