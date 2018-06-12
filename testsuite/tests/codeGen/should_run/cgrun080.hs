{-# OPTIONS_GHC -msse4 #-}
{-# OPTIONS_GHC -mavx #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
-- !!! test the packing of four floats into a vector

import GHC.Exts

data FloatX4 = FX4# FloatX4#

instance Show FloatX4 where
  show (FX4# f) = case (unpackFloatX4# f) of
    (# a, b, c, d #) -> show ((F# a), (F# b), (F# c), (F# d))


main :: IO ()
main = do
  print (FX4# (packFloatX4# (# 9.2#, 8.15#, 7.0#, 6.4# #)))
