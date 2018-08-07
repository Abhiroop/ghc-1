{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}

module Main where

import Data.Word
import Data.List
import GHC.Prim
import GHC.Exts


-- Having a wrapper gives us two things:
-- * it's easier to test everything (no need for code using raw primops)
-- * we test the deriving mechanism for Word64#
data TestWord64 = T64 Word64#
    deriving (Eq, Ord)

mkT64 :: Word -> TestWord64
mkT64 (W# a) = T64 (narrowWord64# a)

main :: IO ()
main = do
    let input = [ (a, b) | a <- allWord64, b <- allWord64 ]

    --
    -- (==)
    --
    let expected = [ a == b | (a, b) <- input ]
        actual = [ mkT64 a == mkT64 b | (a, b) <- input ]
    checkResults "(==)" input expected actual

    --
    -- (/=)
    --
    let expected = [ a /= b | (a, b) <- input ]
        actual = [ mkT64 a /= mkT64 b | (a, b) <- input ]
    checkResults "(/=)" input expected actual

    --
    -- (<)
    --
    let expected = [ a < b | (a, b) <- input ]
        actual = [ mkT64 a < mkT64 b | (a, b) <- input ]
    checkResults "(<)" input expected actual

    --
    -- (>)
    --
    let expected = [ a > b | (a, b) <- input ]
        actual = [ mkT64 a > mkT64 b | (a, b) <- input ]
    checkResults "(>)" input expected actual

    --
    -- (<=)
    --
    let expected = [ a <= b | (a, b) <- input ]
        actual = [ mkT64 a <= mkT64 b | (a, b) <- input ]
    checkResults "(<=)" input expected actual

    --
    -- (>=)
    --
    let expected = [ a >= b | (a, b) <- input ]
        actual = [ mkT64 a >= mkT64 b | (a, b) <- input ]
    checkResults "(>=)" input expected actual

checkResults
    :: (Eq a, Eq b, Show a, Show b) => String -> [a] -> [b] -> [b] -> IO ()
checkResults test inputs expected actual =
    case findIndex (\(e, a) -> e /= a) (zip expected actual) of
        Nothing -> putStrLn $ "Pass: " ++ test
        Just i -> error $
            "FAILED: " ++ test ++ " for input: " ++ show (inputs !! i)
              ++ " expected: " ++ show (expected !! i)
              ++ " but got: " ++ show (actual !! i)

-- testing across the entire Word64 range blows the memory,
-- hence choosing a smaller range
allWord64 :: [Word]
allWord64 = [ 0 .. 100 ]
