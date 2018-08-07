{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnliftedFFITypes #-}

module Main where

import GHC.Exts

foreign import ccall "add_all_word64"
    add_all_word64
        :: Word64# -> Word64# -> Word64# -> Word64# -> Word64#
        -> Word64# -> Word64# -> Word64# -> Word64# -> Word64#
        -> Word64#

main :: IO ()
main = do
    let a = narrowWord64# 0##
        b = narrowWord64# 1##
        c = narrowWord64# 2##
        d = narrowWord64# 3##
        e = narrowWord64# 4##
        f = narrowWord64# 5##
        g = narrowWord64# 6##
        h = narrowWord64# 7##
        i = narrowWord64# 8##
        j = narrowWord64# 9##
        x = W# (extendWord64# (add_all_word64 a b c d e f g h i j))
    print x
