{-# OPTIONS_GHC -mavx #-}
{-# OPTIONS_GHC -msse4 #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
-- !!! test the broadcastFloatX4# operation for broadcasting
-- and tests the unpackFloatX4# operation as well

import GHC.Exts

main :: IO ()
main = do
    case unpackFloatX4# (broadcastFloatX4# 1.5#) of
        (# a, b, c, d #) -> print (F# a, F# b, F# c, F# d)
    case unpackFloatX4# (packFloatX4# (# 4.5#,7.8#, 2.3#, 6.5# #)) of
        (# a, b, c, d #) -> print (F# a, F# b, F# c, F# d)
