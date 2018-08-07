{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}

module Main where

import Data.Int
import Data.List
import GHC.Prim
import GHC.Exts


-- Having a wrapper gives us two things:
-- * it's easier to test everything (no need for code using raw primops)
-- * we test the deriving mechanism for Int64#
data TestInt64 = T64 Int64#
    deriving (Eq, Ord)

mkT64 :: Int -> TestInt64
mkT64 (I# a) = T64 (narrowInt64# a)

main :: IO ()
main = do
    let input = [ (a, b) | a <- allInt64, b <- allInt64 ]

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

-- testing across the entire Int64 range blows the memory,
-- hence choosing a smaller range
allInt64 :: [Int]
allInt64 = [ -50 .. 50 ]
