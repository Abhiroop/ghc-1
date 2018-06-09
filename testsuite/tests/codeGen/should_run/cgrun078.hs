{-# OPTIONS_GHC -mavx #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
-- !!! test the lifting of unlifted vector types and
-- defining various typeclass instances for the lifted types

import GHC.Exts

data FloatX4 = FX4# FloatX4#

instance Show FloatX4 where
  show (FX4# f) = case (unpackFloatX4# f) of
    (# a, b, c, d #) -> show ((F# a), (F# b), (F# c), (F# d))


instance Eq FloatX4 where
  (FX4# a) == (FX4# b)
    = case (unpackFloatX4# a) of
        (# a1, a2, a3, a4 #) ->
          case (unpackFloatX4# b) of
            (# b1, b2, b3, b4 #) -> (F# a1) == (F# b1) &&
                                    (F# a2) == (F# b2) &&
                                    (F# a3) == (F# b3) &&
                                    (F# a4) == (F# b4)

main :: IO ()
main = do
  print (FX4# (broadcastFloatX4# 1.5#))
  print $ (FX4# (broadcastFloatX4# 1.5#)) == (FX4# (broadcastFloatX4# 2.5#))
  print $ (FX4# (broadcastFloatX4# 3.5#)) == (FX4# (broadcastFloatX4# 3.5#))
