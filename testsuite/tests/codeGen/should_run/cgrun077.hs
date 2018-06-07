{-# OPTIONS_GHC -mavx #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
-- !!! test the broadcastFloatX4# operation for broadcasting
-- and tests the unpackFloatX4# operation as well

import GHC.Exts

main :: IO ()
main
  = case unpackFloatX4# (broadcastFloatX4# 1.5#) of
      (# a, b, c, d #) -> print (F# a, F# b, F# c, F# d)
