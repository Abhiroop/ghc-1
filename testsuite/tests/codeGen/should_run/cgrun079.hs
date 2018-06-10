{-# OPTIONS_GHC -mavx #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
-- !!! test arithmetic vector operations

import GHC.Exts

data FloatX4 = FX4# FloatX4#

instance Show FloatX4 where
  show (FX4# f) = case (unpackFloatX4# f) of
    (# a, b, c, d #) -> show ((F# a), (F# b), (F# c), (F# d))


main :: IO ()
main = print (FX4# (plusFloatX4# (broadcastFloatX4# 1.3#) (broadcastFloatX4# 2.2#)))
