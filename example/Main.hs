{-# LANGUAGE LambdaCase #-}

{-|
Module      : Main
Description : Example of use of Haskell bindings to the random.org Basic API
              (Release 4)
Copyright   : Copyright 2022 Mike Pilgrem
License     : BSD-3-Clause
Maintainer  : public@pilgrem.com
Stability   : Experimental
Portability : Portable

Example of use of Haskell bindings to the [random.org](https://random.org) Basic
API (Release 4). The example assumes the existence of an environment variable
@RANDOM_DOT_ORG_API_KEY@ that contains an API key for the Basic API.

This module has no connection with Randomness and Integrity Services Ltd or
its affilates.
-}

module Main where

import System.Environment (lookupEnv)

import Network.HTTP.Client (newManager)
import Network.HTTP.Client.TLS (tlsManagerSettings)

import System.Random.Atmospheric as TRNG (BlobFormat (Base64), Boundary (Fixed),
  Key (Key), generateIntegers, generateIntegerSequences,
  generateIntegerSequencesMultiform, generateDecimalFractions,
  generateGaussians, generateStrings, generateUUIDs, generateBlobs)

main :: IO ()
main = do
 lookupEnv "RANDOM_DOT_ORG_API_KEY" >>= \case
   Nothing -> putStrLn $
     "No random.org API key found in the environment. Set environment " <>
     "variable RANDOM_DOT_ORG_API_KEY to the API key."
   Just apiKey' -> do
     mgr <- newManager tlsManagerSettings
     let apiKey = Key apiKey'
     process ( "generateIntegers"
             , generateIntegers mgr apiKey 10 0 1000000 )
     process ( "generateIntegerSequences"
             , generateIntegerSequences mgr apiKey 10 4 0 1000000 )
     process ( "generateIntegerSequencesMultiform"
             , generateIntegerSequencesMultiform
                 mgr apiKey 5 [1, 2, 3, 4, 5] (Fixed 0) (Fixed 1000000) )
     process ( "generateDecimalFractions"
             , generateDecimalFractions mgr apiKey 10 6 )
     process ( "generateGaussians"
             , generateGaussians mgr apiKey 10 0.0 1.0 6 )
     process ( "generateStrings"
             , generateStrings mgr apiKey 10 8 ['A' .. 'Z'] )
     process ( "generateUUIDs"
             , generateUUIDs mgr apiKey 10 )
     process ( "generateBlobs"
             , generateBlobs mgr apiKey 10 16 Base64)
 where
  process :: Show a => (String, IO (Maybe (a, Int))) -> IO ()
  process (name, action) = do
    putStrLn $ name <> ":"
    action >>= \case
      Just (randomData, _) -> print randomData
      Nothing -> putStrLn "Error! No data."
