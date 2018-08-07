{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

module Main where

import Data.Int
import Data.List
import GHC.Prim
import GHC.Exts

main :: IO ()
main = do

    --
    -- Check if passing Int64# on the stack works (16 parameter function will
    -- need to use stack for some of the them)
    --
    let input =
            [ ( (a + 0), (a + 1), (a + 2), (a + 3),
                (a + 4), (a + 5), (a + 6), (a + 7),
                (a + 8), (a + 9), (a + 10), (a + 11),
                (a + 12), (a + 13), (a + 14), (a + 15) )
            | a <- allInt64
            ]
        expected =
            [ toInt64
                  (a + b + c + d + e + f + g + h +
                   i + j + k + l + m + n + o + p)
            | (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) <- input
            ]
        actual =
            [ addMany a b c d e f g h i j k l m n o p
            | (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) <- input
            ]
    checkResults "passing Int64# on the stack" input expected actual

    --
    -- negateInt64#
    --
    let input = allInt64
        expected = [ toInt64 (negate a) | a <- input ]
        actual = [ apply1 negateInt64# a | a <- input ]
    checkResults "negateInt64#" input expected actual

    --
    -- plusInt64#
    --
    let input = [ (a, b) | a <- allInt64, b <- allInt64 ]
        expected = [ toInt64 (a + b) | (a, b) <- input ]
        actual = [ apply2 plusInt64# a b | (a, b) <- input ]
    checkResults "plusInt64#" input expected actual

    -- --
    -- -- subInt64#
    -- --
    let input = [ (a, b) | a <- allInt64, b <- allInt64 ]
        expected = [ toInt64 (a - b) | (a, b) <- input ]
        actual = [ apply2 subInt64# a b | (a, b) <- input ]
    checkResults "subInt64#" input expected actual

    --
    -- timesInt64#
    --
    let input = [ (a, b) | a <- allInt64, b <- allInt64 ]
        expected = [ toInt64 (a * b) | (a, b) <- input ]
        actual = [ apply2 timesInt64# a b | (a, b) <- input ]
    checkResults "timesInt64#" input expected actual

    --
    -- remInt64#
    --
    let input =
            [ (a, b) | a <- allInt64, b <- allInt64
            -- Don't divide by 0 or cause overflow
            , b /= 0, not (a == -32768 && b == -1)
            ]
        expected = [ toInt64 (a `rem` b) | (a, b) <- input ]
        actual = [ apply2 remInt64# a b | (a, b) <- input ]
    checkResults "remInt64#" input expected actual

    --
    -- quotInt64#
    --
    let input =
            [ (a, b) | a <- allInt64, b <- allInt64
            , b /= 0, not (a == -32768 && b == -1)
            ]
        expected = [ toInt64 (a `quot` b) | (a, b) <- input ]
        actual = [ apply2 quotInt64# a b | (a, b) <- input ]
    checkResults "quotInt64#" input expected actual

    --
    -- quotRemInt64#
    --
    let input =
            [ (a, b) | a <- allInt64, b <- allInt64
            , b /= 0, not (a == -32768 && b == -1)
            ]
        expected =
            [ (toInt64 q, toInt64 r)  | (a, b) <- input
            , let (q, r) = a `quotRem` b
            ]
        actual = [ apply3 quotRemInt64# a b | (a, b) <- input ]
    checkResults "quotRemInt64#" input expected actual


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

toInt64 :: Int -> Int
toInt64 a = fromIntegral (fromIntegral a :: Int64)

addMany#
    :: Int64# -> Int64# -> Int64# -> Int64#
    -> Int64# -> Int64# -> Int64# -> Int64#
    -> Int64# -> Int64# -> Int64# -> Int64#
    -> Int64# -> Int64# -> Int64# -> Int64#
    -> Int64#
addMany# a b c d e f g h i j k l m n o p =
    a `plusInt64#` b `plusInt64#` c `plusInt64#` d `plusInt64#`
    e `plusInt64#` f `plusInt64#` g `plusInt64#` h `plusInt64#`
    i `plusInt64#` j `plusInt64#` k `plusInt64#` l `plusInt64#`
    m `plusInt64#` n `plusInt64#` o `plusInt64#` p
{-# NOINLINE addMany# #-}

addMany
    :: Int -> Int -> Int -> Int
    -> Int -> Int -> Int -> Int
    -> Int -> Int -> Int -> Int
    -> Int -> Int -> Int -> Int
    -> Int
addMany (I# a) (I# b) (I# c) (I# d)
        (I# e) (I# f) (I# g) (I# h)
        (I# i) (I# j) (I# k) (I# l)
        (I# m) (I# n) (I# o) (I# p)
            = I# (extendInt64# int64)
  where
    !int64 = addMany#
                (narrowInt64# a) (narrowInt64# b) (narrowInt64# c) (narrowInt64# d)
                (narrowInt64# e) (narrowInt64# f) (narrowInt64# g) (narrowInt64# h)
                (narrowInt64# i) (narrowInt64# j) (narrowInt64# k) (narrowInt64# l)
                (narrowInt64# m) (narrowInt64# n) (narrowInt64# o) (narrowInt64# p)
{-# NOINLINE addMany #-}

-- Convenient and also tests higher order functions on Int64#
apply1 :: (Int64# -> Int64#) -> Int -> Int
apply1 opToTest (I# a) = I# (extendInt64# (opToTest (narrowInt64# a)))
{-# NOINLINE apply1 #-}

apply2 :: (Int64# -> Int64# -> Int64#) -> Int -> Int -> Int
apply2 opToTest (I# a) (I# b) =
    let (# sa, sb #) = (# narrowInt64# a, narrowInt64# b #)
        r = opToTest sa sb
    in I# (extendInt64# r)
{-# NOINLINE apply2 #-}

apply3 :: (Int64# -> Int64# -> (# Int64#, Int64# #)) -> Int -> Int -> (Int, Int)
apply3 opToTest (I# a) (I# b) =
    let (# sa, sb #) = (# narrowInt64# a, narrowInt64# b #)
        (# ra, rb #) = opToTest sa sb
    in (I# (extendInt64# ra), I# (extendInt64# rb))
{-# NOINLINE apply3 #-}

instance
        (Eq a, Eq b, Eq c, Eq d, Eq e, Eq f, Eq g, Eq h,
         Eq i, Eq j, Eq k, Eq l, Eq m, Eq n, Eq o, Eq p)
      => Eq (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) where
    (a1, b1, c1, d1, e1, f1, g1, h1, i1, j1, k1, l1, m1, n1, o1, p1) ==
        (a2, b2, c2, d2, e2, f2, g2, h2, i2, j2, k2, l2, m2, n2, o2, p2) =
            a1 == a2 && b1 == b2 && c1 == c2 && d1 == d2 &&
            e1 == e2 && f1 == f2 && g1 == g2 && h1 == h2 &&
            i1 == i2 && j1 == j2 && k1 == k2 && l1 == l2 &&
            m1 == m2 && n1 == n2 && o1 == o2 && p1 == p2

instance
        (Show a, Show b, Show c, Show d, Show e, Show f, Show g, Show h,
         Show i, Show j, Show k, Show l, Show m, Show n, Show o, Show p)
      => Show (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) where
    show (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) =
        "(" ++ show a ++ "," ++ show b ++ "," ++ show c ++ "," ++ show d ++
        "," ++ show e ++ "," ++ show f ++ "," ++ show g ++ "," ++ show h ++
        "," ++ show i ++ "," ++ show j ++ "," ++ show k ++ "," ++ show l ++
        "," ++ show m ++ "," ++ show n ++ "," ++ show o ++ "," ++ show p ++
        ")"
