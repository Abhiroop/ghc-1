{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnliftedFFITypes #-}

module Main where

import GHC.Exts

foreign import ccall "add_all_int64"
    add_all_int64
        :: Int64# -> Int64# -> Int64# -> Int64# -> Int64#
        -> Int64# -> Int64# -> Int64# -> Int64# -> Int64#
        -> Int64#

main :: IO ()
main = do
    let a = narrowInt64# 0#
        b = narrowInt64# 1#
        c = narrowInt64# 2#
        d = narrowInt64# 3#
        e = narrowInt64# 4#
        f = narrowInt64# 5#
        g = narrowInt64# 6#
        h = narrowInt64# 7#
        i = narrowInt64# 8#
        j = narrowInt64# 9#
        x = I# (extendInt64# (add_all_int64 a b c d e f g h i j))
    print x
