{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

module Main where

import Data.Word
import Data.Bits
import Data.List
import GHC.Prim
import GHC.Exts

main :: IO ()
main = do

    --
    -- Check if passing Word64# on the stack works (16 parameter function will
    -- need to use stack for some of the them)
    --
    let input =
            [ ( (a + 0), (a + 1), (a + 2), (a + 3),
                (a + 4), (a + 5), (a + 6), (a + 7),
                (a + 8), (a + 9), (a + 10), (a + 11),
                (a + 12), (a + 13), (a + 14), (a + 15) )
            | a <- allWord64
            ]
        expected =
            [ toWord64
                  (a + b + c + d + e + f + g + h +
                   i + j + k + l + m + n + o + p)
            | (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) <- input
            ]
        actual =
            [ addMany a b c d e f g h i j k l m n o p
            | (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) <- input
            ]
    checkResults "passing Word64# on the stack" input expected actual

    --
    -- notWord64#
    --
    let input = allWord64
        expected = [ toWord64 (complement a) | a <- input ]
        actual = [ apply1 notWord64# a | a <- input ]
    checkResults "notWord64#" input expected actual

    --
    -- plusWord64#
    --
    let input = [ (a, b) | a <- allWord64, b <- allWord64 ]
        expected = [ toWord64 (a + b) | (a, b) <- input ]
        actual = [ apply2 plusWord64# a b | (a, b) <- input ]
    checkResults "plusWord64#" input expected actual

    --
    -- subWord64#
    --
    let input = [ (a, b) | a <- allWord64, b <- allWord64 ]
        expected = [ toWord64 (a - b) | (a, b) <- input ]
        actual = [ apply2 subWord64# a b | (a, b) <- input ]
    checkResults "subWord64#" input expected actual

    --
    -- timesWord64#
    --
    let input = [ (a, b) | a <- allWord64, b <- allWord64 ]
        expected = [ toWord64 (a * b) | (a, b) <- input ]
        actual = [ apply2 timesWord64# a b | (a, b) <- input ]
    checkResults "timesWord64#" input expected actual

    --
    -- remWord64#
    --
    let input =
            -- Don't divide by 0.
            [ (a, b) | a <- allWord64, b <- allWord64 , b /= 0 ]
        expected = [ toWord64 (a `rem` b) | (a, b) <- input ]
        actual = [ apply2 remWord64# a b | (a, b) <- input ]
    checkResults "remWord64#" input expected actual

    --
    -- quotWord64#
    --
    let input =
            [ (a, b) | a <- allWord64, b <- allWord64, b /= 0 ]
        expected = [ toWord64 (a `quot` b) | (a, b) <- input ]
        actual = [ apply2 quotWord64# a b | (a, b) <- input ]
    checkResults "quotWord64#" input expected actual

    --
    -- quotRemWord64#
    --
    let input =
            [ (a, b) | a <- allWord64, b <- allWord64, b /= 0 ]
        expected =
            [ (toWord64 q, toWord64 r)  | (a, b) <- input
            , let (q, r) = a `quotRem` b
            ]
        actual = [ apply3 quotRemWord64# a b | (a, b) <- input ]
    checkResults "quotRemWord64#" input expected actual


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

toWord64 :: Word -> Word
toWord64 a = fromIntegral (fromIntegral a :: Word64)

addMany#
    :: Word64# -> Word64# -> Word64# -> Word64#
    -> Word64# -> Word64# -> Word64# -> Word64#
    -> Word64# -> Word64# -> Word64# -> Word64#
    -> Word64# -> Word64# -> Word64# -> Word64#
    -> Word64#
addMany# a b c d e f g h i j k l m n o p =
    a `plusWord64#` b `plusWord64#` c `plusWord64#` d `plusWord64#`
    e `plusWord64#` f `plusWord64#` g `plusWord64#` h `plusWord64#`
    i `plusWord64#` j `plusWord64#` k `plusWord64#` l `plusWord64#`
    m `plusWord64#` n `plusWord64#` o `plusWord64#` p
{-# NOINLINE addMany# #-}

addMany
    :: Word -> Word -> Word -> Word
    -> Word -> Word -> Word -> Word
    -> Word -> Word -> Word -> Word
    -> Word -> Word -> Word -> Word
    -> Word
addMany (W# a) (W# b) (W# c) (W# d)
        (W# e) (W# f) (W# g) (W# h)
        (W# i) (W# j) (W# k) (W# l)
        (W# m) (W# n) (W# o) (W# p)
            = W# (extendWord64# word64)
  where
    !word64 =
        addMany#
            (narrowWord64# a) (narrowWord64# b) (narrowWord64# c) (narrowWord64# d)
            (narrowWord64# e) (narrowWord64# f) (narrowWord64# g) (narrowWord64# h)
            (narrowWord64# i) (narrowWord64# j) (narrowWord64# k) (narrowWord64# l)
            (narrowWord64# m) (narrowWord64# n) (narrowWord64# o) (narrowWord64# p)
{-# NOINLINE addMany #-}

-- Convenient and also tests higher order functions on Word64#
apply1 :: (Word64# -> Word64#) -> Word -> Word
apply1 opToTest (W# a) = W# (extendWord64# (opToTest (narrowWord64# a)))
{-# NOINLINE apply1 #-}

apply2 :: (Word64# -> Word64# -> Word64#) -> Word -> Word -> Word
apply2 opToTest (W# a) (W# b) =
    let (# sa, sb #) = (# narrowWord64# a, narrowWord64# b #)
        r = opToTest sa sb
    in W# (extendWord64# r)
{-# NOINLINE apply2 #-}

apply3
  :: (Word64# -> Word64# -> (# Word64#, Word64# #)) -> Word -> Word -> (Word, Word)
apply3 opToTest (W# a) (W# b) =
    let (# sa, sb #) = (# narrowWord64# a, narrowWord64# b #)
        (# ra, rb #) = opToTest sa sb
    in (W# (extendWord64# ra), W# (extendWord64# rb))
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
