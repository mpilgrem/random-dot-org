{-# LANGUAGE BangPatterns               #-}
{-# LANGUAGE TupleSections              #-}

{-|
Module      : System.Random.Atmospheric.Api.DateTime
Description : Date and time format used by the RANDOM.ORG Core API (Release 4)
Copyright   : Copyright 2024 Mike Pilgrem (except as indicated)
License     : BSD-3-Clause
Maintainer  : public@pilgrem.com
Stability   : Experimental
Portability : Portable

The output of the [RANDOM.ORG](https://random.org) Core API (Release 4) uses a
date and time format that is allowed by RFC 3999 but not permitted by ISO 8601.

This module has no connection with Randomness and Integrity Services Limited or
its affilates or the RANDOM.ORG domain.
-}

module System.Random.Atmospheric.Api.DateTime
  ( DateTime (..)
  ) where

import           Data.Aeson.Encoding ( encodingToLazyByteString )
import           Data.Aeson.Encoding.Internal ( Encoding' (..) )
import           Data.Aeson.Types ( ToJSON (..), Value (..) )
import           Data.ByteString.Builder ( Builder, char7, char8, integerDec)
import           Data.ByteString.Builder.Prim
                   ( BoundedPrim, (>$<), (>*<), condB, emptyB
                   , liftFixedToBounded, primBounded
                   )
import qualified Data.ByteString.Builder.Prim as BP
import qualified Data.ByteString.Lazy as L
import           Data.Char ( chr )
import           Data.Int ( Int64 )
import           Data.Text ( Text )
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Data.Time.Calendar ( Day, toGregorian )
import           Data.Time.Clock ( DiffTime, UTCTime (..) )
import           Data.Time.Clock.Compat ( diffTimeToPicoseconds )

-- | Type representing UTC date and times but with a different 'ToJSON'
-- instance that uses a version of ISO 8601 modified to use an alternative
-- allowed by RFC 3999.
newtype DateTime = DateTime
  { unDateTime :: UTCTime
  }

instance ToJSON DateTime where

  toJSON  = stringEncoding . Encoding . quote . utcTime . unDateTime

  toEncoding = Encoding . quote . utcTime . unDateTime

-- | Modified version of ISO 8601 to use an alternative allowed by RFC 3999.
dayTime :: Day -> TimeOfDay64 -> Builder
dayTime d t = day d <> delimiter <> timeOfDay64 t
 where
  delimiter = char7 ' '
  -- ISO 8601 requires the delimiter to be 'T' but RFC 3999 allows the
  -- delimiter to be ' '.
{-# INLINE dayTime #-}

--------------------------------------------------------------------------------
-- The following is based on module Data.Aeson.Encoding.Builder of the package
-- aeson-2.2.3.0, copyright 2011 MailRank, Inc. and 2013 Simon Meier.
--------------------------------------------------------------------------------

-- | Encode something to a JSON string.
stringEncoding :: Encoding' Text -> Value
stringEncoding = String
  . T.dropAround (== '"')
  . T.decodeLatin1
  . L.toStrict
  . encodingToLazyByteString
{-# INLINE stringEncoding #-}

-- | Add quotes surrounding a builder
quote :: Builder -> Builder
quote b = char8 '"' <> b <> char8 '"'

utcTime :: UTCTime -> Builder
utcTime (UTCTime d s) = dayTime d (diffTimeOfDay64 s) <> char7 'Z'
{-# INLINE utcTime #-}

day :: Day -> Builder
day dd =
     encodeYear yr
  <> primBounded (ascii6 ('-', (mh, (ml, ('-', (dh, dl)))))) ()
 where
  (yr,m,d)    = toGregorian dd
  !(T mh ml)  = twoDigits m
  !(T dh dl)  = twoDigits d
{-# INLINE day #-}

-- | Used in encoding day, month, quarter
encodeYear :: Integer -> Builder
encodeYear y
  | y >= 1000 = integerDec y
  | y >= 0    = primBounded (ascii4 (padYear y)) ()
  | y >= -999 = primBounded (ascii5 ('-', padYear (- y))) ()
  | otherwise = integerDec y
 where
  padYear y' =
      let (ab, c) = fromIntegral y' `quotRem` 10
          (a, b) = ab `quotRem` 10
      in  ('0', (digit a, (digit b, digit c)))
{-# INLINE encodeYear #-}

ascii4 :: (Char, (Char, (Char, Char))) -> BoundedPrim a
ascii4 cs = liftFixedToBounded $ const cs >$<
  BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7
{-# INLINE ascii4 #-}

ascii5 :: (Char, (Char, (Char, (Char, Char)))) -> BoundedPrim a
ascii5 cs = liftFixedToBounded $ const cs >$<
  BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7
{-# INLINE ascii5 #-}

ascii6 :: (Char, (Char, (Char, (Char, (Char, Char))))) -> BoundedPrim a
ascii6 cs = liftFixedToBounded $ const cs >$<
  BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7
{-# INLINE ascii6 #-}

ascii8 ::
     (Char, (Char, (Char, (Char, (Char, (Char, (Char, Char)))))))
  -> BoundedPrim a
ascii8 cs = liftFixedToBounded $ const cs >$<
  BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7 >*< BP.char7 >*<
  BP.char7 >*< BP.char7
{-# INLINE ascii8 #-}

twoDigits :: Int -> T
twoDigits a = T (digit hi) (digit lo)
 where
  (hi, lo) = a `quotRem` 10

digit :: Int -> Char
digit x = chr (x + 48)

data T = T {-# UNPACK #-} !Char {-# UNPACK #-} !Char

timeOfDay64 :: TimeOfDay64 -> Builder
timeOfDay64 (TOD h m s)
  | frac == 0 = hhmmss -- omit subseconds if 0
  | otherwise = hhmmss <> primBounded showFrac frac
 where
  hhmmss =
    primBounded (ascii8 (hh, (hl, (':', (mh, (ml, (':', (sh, sl)))))))) ()
  !(T hh hl)  = twoDigits h
  !(T mh ml)  = twoDigits m
  !(T sh sl)  = twoDigits (fromIntegral real)
  (real,frac) = s `quotRem` pico
  showFrac = ('.',) >$< (liftFixedToBounded BP.char7 >*< trunc12)
  trunc12 = (`quotRem` micro) >$<
            condB (\(_, y) -> y == 0) (fst >$< trunc6) (digits6 >*< trunc6)
  digits6 = ((`quotRem` milli) . fromIntegral) >$< (digits3 >*< digits3)
  trunc6  = ((`quotRem` milli) . fromIntegral) >$<
            condB (\(_, y) -> y == 0) (fst >$< trunc3) (digits3 >*< trunc3)
  digits3 = (`quotRem` 10) >$< (digits2 >*< digits1)
  digits2 = (`quotRem` 10) >$< (digits1 >*< digits1)
  digits1 = liftFixedToBounded (digit >$< BP.char7)
  trunc3  = condB (== 0) emptyB $
            (`quotRem` 100) >$< (digits1 >*< trunc2)
  trunc2  = condB (== 0) emptyB $
            (`quotRem` 10)  >$< (digits1 >*< trunc1)
  trunc1  = condB (== 0) emptyB digits1

  pico       = 1000000000000 -- number of picoseconds  in 1 second
  micro      =       1000000 -- number of microseconds in 1 second
  milli      =          1000 -- number of milliseconds in 1 second

data TimeOfDay64 = TOD {-# UNPACK #-} !Int
                       {-# UNPACK #-} !Int
                       {-# UNPACK #-} !Int64

posixDayLength :: DiffTime
posixDayLength = 86400

diffTimeOfDay64 :: DiffTime -> TimeOfDay64
diffTimeOfDay64 t
  | t >= posixDayLength = TOD 23 59 (60000000000000 + pico (t - posixDayLength))
  | otherwise = TOD (fromIntegral h) (fromIntegral m) s
 where
  (h, mp) = pico t `quotRem` 3600000000000000
  (m, s)  = mp `quotRem` 60000000000000
  pico   = fromIntegral . diffTimeToPicoseconds
