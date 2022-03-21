{-# LANGUAGE LambdaCase       #-}

{-|
Module      : Main
Description : Example of use of Haskell bindings to the RANDOM.ORG Core API
              (Release 4)
Copyright   : Copyright 2024 Mike Pilgrem
License     : BSD-3-Clause
Maintainer  : public@pilgrem.com
Stability   : Experimental
Portability : Portable

Example of use of Haskell bindings to the [RANDOM.ORG](https://random.org) Core
API (Release 4). The example assumes the existence of an environment variable
@RANDOM_DOT_ORG_API_KEY@ that contains an API key for the Core API.

This module has no connection with Randomness and Integrity Services Limited or
its affilates or the RANDOM.ORG domain.
-}

module Main
  ( main
  ) where

import           Data.Aeson.Types ( ToJSON )
import           Data.ByteString.Char8 ( pack )
import           Data.Functor ( void )
import           Network.HTTP.Client ( Manager, newManager )
import           Network.HTTP.Client.TLS ( tlsManagerSettings )
import           Servant.Client.JsonRpc ( JsonRpcResponse (..) )
import           System.Environment ( lookupEnv )
import           System.Random.Atmospheric.Api
                   ( BlobFormat (Base64), Boundary (Fixed), ClientSigResponse
                   , Key (..), RandomResponse (..), SignedRandomResponse (..)
                   , TicketData (..), TicketInfoResponse (..)
                   , TicketResponse (..), TicketType (..), UsageResponse (..)
                   , createTickets, genBlobs, genDecimalFractions, genGaussians
                   , genIntegers, genIntegerSequences
                   , genIntegerSequencesMultiform, genSignedBlobs
                   , genSignedDecimalFractions, genSignedGaussians
                   , genSignedIntegers, genSignedIntegerSequences
                   , genSignedIntegerSequencesMultiform, genSignedStrings
                   , genSignedUUIDs, genStrings, genUUIDs, getResult, getTicket
                   , getUsage, listTickets, revealTickets, verifySignedResponse
                   )

main :: IO ()
main = do
  lookupEnv "RANDOM_DOT_ORG_API_KEY" >>= \case
    Nothing -> putStrLn
      "No RANDOM.ORG API key found in the environment. Set environment \
      \variable RANDOM_DOT_ORG_API_KEY to the API key."
    Just apiKey' -> do
      mgr <- newManager tlsManagerSettings
      let apiKey = Key $ pack apiKey'
      putStrLn "getUsage:"
      mUsageResponseStart <- getUsage mgr apiKey
      case mUsageResponseStart of
        Just usageResponse -> print usageResponse
        Nothing -> putStrLn "Error! No usage information."
      blankLine
      processBasic
        "genIntegers (with replacement)"
        (genIntegers mgr apiKey True 3 0 1000000)
      processBasic
        "genIntegers (without replacement)"
        (genIntegers mgr apiKey False 52 1 52)
      processBasic
        "genIntegerSequences"
        (genIntegerSequences mgr apiKey True 3 2 0 1000000)
      processBasic
        "genIntegerSequencesMultiform"
        ( genIntegerSequencesMultiform
             mgr apiKey True 3 [1, 2, 3] (Fixed 0) (Fixed 1000000)
        )
      processBasic
        "genDecimalFractions"
        (genDecimalFractions mgr apiKey True 3 6)
      processBasic
        "genGaussians"
        (genGaussians mgr apiKey 3 0.0 1.0 6)
      processBasic
        "genStrings"
        (genStrings mgr apiKey True 3 8 ['A' .. 'Z'])
      processBasic
        "genUUIDs"
        (genUUIDs mgr apiKey 3)
      processBasic
        "genBlobs"
        (genBlobs mgr apiKey 3 16 Base64)
      ticketIds <-
        map (td_ticketId . tr_ticketData) <$> createTickets mgr apiKey 9 False
      putStrLn $ "ticket Ids: " <> show ticketIds
      ticketIds' <-
        map (td_ticketId . tr_ticketData . ltr_ticketResponse) <$>
          listTickets mgr apiKey Singleton
      putStrLn $ "Head ticket Ids: " <> show ticketIds'
      processSig
        mgr
        "genSignedIntegers"
        ( genSignedIntegers
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ head ticketIds)
            True
            3
            0
            1000000
        )
      processSig
        mgr
        "genSignedIntegerSequences"
        ( genSignedIntegerSequences
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 1)
            True
            3
            2
            0
            1000000
        )
      processSig
        mgr
        "genSignedIntegerSequencesMultiform"
        ( genSignedIntegerSequencesMultiform
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 2)
            True
            3
            [1, 2, 3]
            (Fixed 0)
            (Fixed 1000000)
        )
      processSig
        mgr
        "genSignedDecimalFractions"
        ( genSignedDecimalFractions
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 3)
            True
            3
            6
        )
      processSig
        mgr
        "genSignedGaussians"
        ( genSignedGaussians
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 4)
            3
            0.0
            1.0
            6
        )
      processSig
        mgr
        "genSignedStrings"
        ( genSignedStrings
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 5)
            True
            3
            8
            ['A' .. 'Z']
        )
      processSig
        mgr
        "genSignedUUIDs"
        ( genSignedUUIDs
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 6)
            3
        )
      mSerialNumber <- processSig'
        mgr
        "genSignedBlobs"
        ( genSignedBlobs
            mgr
            apiKey
            Nothing
            Nothing
            (Just $ ticketIds !! 7)
            3
            16
            Base64
        )
      revealTickets mgr apiKey (head ticketIds) >>= \case
        Just ticketCount ->
          putStrLn $ "Revealed " <> show ticketCount <> " ticket(s)."
        Nothing -> putStrLn "Error! No ticket revelation."
      blankLine
      getTicket mgr (head ticketIds) >>= \case
        Just ticketInfoResponse ->
          putStrLn $ "getTicket: " <> show ticketInfoResponse
        Nothing -> putStrLn "Error! No ticket information."
      blankLine
      case mSerialNumber of
        Just sn -> do
          putStrLn $ "Repeat serial number: " <> show sn
          getResult mgr apiKey sn >>= \case
            Right (Result _ result) -> print result
            _ -> putStrLn "Error! No result."
        Nothing -> putStrLn "Error! No serial number."
      blankLine
      putStrLn "getUsage:"
      mUsageResponseEnd <- getUsage mgr apiKey
      case mUsageResponseEnd of
        Just usageResponse -> print usageResponse
        Nothing -> putStrLn "Error! No usage information."
      blankLine
      case (mUsageResponseStart, mUsageResponseEnd) of
        (Just urStart, Just urEnd) -> do
          let totalBitsUsed = ur_bitsLeft urStart - ur_bitsLeft urEnd
          putStrLn $ "Bits used: " <> show totalBitsUsed
        _ -> pure ()
 where
  blankLine :: IO ()
  blankLine = putStr "\n"
  processBasic :: Show a => String -> IO (Maybe (a, Int)) -> IO ()
  processBasic name action = do
    putStrLn $ name <> ":"
    action >>= \case
      Just (rd, _) -> print rd
      Nothing -> putStrLn "Error! No data."
    putStr "\n"
  processSig ::
       (Show a, Show b, ToJSON a, ToJSON b)
    => Manager
    -> String
    -> IO (ClientSigResponse a b)
    -> IO ()
  processSig mgr name action = void $ processSig' mgr name action
  processSig' ::
       (Show a, Show b, ToJSON a, ToJSON b)
    => Manager
    -> String
    -> IO (ClientSigResponse a b)
    -> IO (Maybe Int)
  processSig' mgr name action = do
    putStrLn $ name <>":"
    mSerialNumber <- action >>= \case
      Right (Result _ result) -> do
        let sn = serialNumber result
        putStrLn $ "Serial number: " <> show sn
        print $ randomData $ randomResponse result
        verifySignedResponse mgr result >>= \case
          Just vsr -> putStrLn $ "Verified: " <> show vsr
          Nothing -> putStrLn "Error! Could not perform verification."
        pure $ Just sn
      Right result -> do
        putStrLn "Error! No data."
        print result
        pure Nothing
      Left err -> do
        putStrLn "Error! No data."
        print err
        pure Nothing
    blankLine
    pure mSerialNumber
