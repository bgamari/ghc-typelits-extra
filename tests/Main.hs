{-# LANGUAGE DataKinds, TypeOperators #-}

{-# OPTIONS_GHC -fplugin GHC.TypeLits.Normalise #-}
{-# OPTIONS_GHC -fplugin GHC.TypeLits.KnownNat.Solver #-}
{-# OPTIONS_GHC -fplugin GHC.TypeLits.Extra.Solver #-}

import Data.List (isInfixOf)
import Data.Proxy
import Data.Type.Bool
import Control.Exception
import Test.Tasty
import Test.Tasty.HUnit

import ErrorTests

import GHC.TypeLits
import GHC.TypeLits.Extra

test1 :: Proxy (GCD 6 8) -> Proxy 2
test1 = id

test2 :: Proxy ((GCD 6 8) + x) -> Proxy (x + (GCD 10 8))
test2 = id

test3 :: Proxy (CLog 3 10) -> Proxy 3
test3 = id

test4 :: Proxy ((CLog 3 10) + x) -> Proxy (x + (CLog 2 7))
test4 = id

test5 :: Proxy (CLog x (x^y)) -> Proxy y
test5 = id

test6 :: Integer
test6 = natVal (Proxy :: Proxy (CLog 6 8))

test7 :: Integer
test7 = natVal (Proxy :: Proxy (CLog 3 10))

test8 :: Integer
test8 = natVal (Proxy :: Proxy ((CLog 2 4) * (3 ^ (CLog 2 4))))

test9 :: Integer
test9 = natVal (Proxy :: Proxy (Max (CLog 2 4) (CLog 4 20)))

test10 :: Proxy (Div 9 3) -> Proxy 3
test10 = id

test11 :: Proxy (Div 9 4) -> Proxy 2
test11 = id

test12 :: Proxy (Mod 9 3) -> Proxy 0
test12 = id

test13 :: Proxy (Mod 9 4) -> Proxy 1
test13 = id

test14 :: Integer
test14 = natVal (Proxy :: Proxy (Div 9 3))

test15 :: Integer
test15 = natVal (Proxy :: Proxy (Mod 9 4))

test16 :: Proxy (LCM 18 7) -> Proxy 126
test16 = id

test17 :: Integer
test17 = natVal (Proxy :: Proxy (LCM 18 7))

test18 :: Proxy ((LCM 6 4) + x) -> Proxy (x + (LCM 3 4))
test18 = id

test19 :: Integer
test19 = natVal (Proxy :: Proxy (FLog 3 1))

test20 :: Proxy (FLog 3 1) -> Proxy 0
test20 = id

test21 :: Integer
test21 = natVal (Proxy :: Proxy (CLog 3 1))

test22 :: Proxy (CLog 3 1) -> Proxy 0
test22 = id

test23 :: Integer
test23 = natVal (Proxy :: Proxy (Log 3 1))

test24 :: Integer
test24 = natVal (Proxy :: Proxy (Log 3 9))

test25 :: Proxy (Log 3 9) -> Proxy 2
test25 = id

test26 :: Proxy (b ^ (Log b y)) -> Proxy y
test26 = id

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "ghc-typelits-natnormalise"
  [ testGroup "Basic functionality"
    [ testCase "GCD 6 8 ~ 2" $
      show (test1 Proxy) @?=
      "Proxy"
    , testCase "forall x . GCD 6 8 + x ~ x + GCD 10 8" $
      show (test2 Proxy) @?=
      "Proxy"
    , testCase "CLog 3 10 ~ 3" $
      show (test3 Proxy) @?=
      "Proxy"
    , testCase "forall x . CLog 3 10 + x ~ x + CLog 2 7" $
      show (test4 Proxy) @?=
      "Proxy"
    , testCase "forall x>1 . CLog x (x^y) ~ y" $
      show (test5 Proxy) @?=
      "Proxy"
    , testCase "KnownNat (CLog 6 8) ~ 2" $
      show test6 @?=
      "2"
    , testCase "KnownNat (CLog 3 10) ~ 3" $
      show test7 @?=
      "3"
    , testCase "KnownNat ((CLog 2 4) * (3 ^ (CLog 2 4)))) ~ 18" $
      show test8 @?=
      "18"
    , testCase "KnownNat (Max (CLog 2 4) (CLog 4 20)) ~ 3" $
      show test9 @?=
      "3"
    , testCase "Div 9 3 ~ 3" $
      show (test10 Proxy) @?=
      "Proxy"
    , testCase "Div 9 4 ~ 2" $
      show (test11 Proxy) @?=
      "Proxy"
    , testCase "Mod 9 3 ~ 0" $
      show (test12 Proxy) @?=
      "Proxy"
    , testCase "Mod 9 4 ~ 1" $
      show (test13 Proxy) @?=
      "Proxy"
    , testCase "KnownNat (Div 9 3) ~ 3" $
      show test14 @?=
      "3"
    , testCase "KnownNat (Mod 9 4) ~ 1" $
      show test15 @?=
      "1"
    , testCase "LCM 18 7 ~ 126" $
      show (test16 Proxy) @?=
      "Proxy"
    , testCase "KnownNat (LCM 18 7) ~ 126" $
      show test17 @?=
      "126"
    , testCase "forall x . LCM 3 4 + x ~ x + LCM 6 4" $
      show (test18 Proxy) @?=
      "Proxy"
    , testCase "KnownNat (FLog 3 1) ~ 0" $
      show test19 @?=
      "0"
    , testCase "FLog 3 1 ~ 0" $
      show (test20 Proxy) @?=
      "Proxy"
    , testCase "KnownNat (CLog 3 1) ~ 0" $
      show test21 @?=
      "0"
    , testCase "CLog 3 1 ~ 0" $
      show (test22 Proxy) @?=
      "Proxy"
    , testCase "KnownNat (Log 3 1) ~ 0" $
      show test23 @?=
      "0"
    , testCase "KnownNat (Log 3 9) ~ 2" $
      show test24 @?=
      "2"
    , testCase "Log 3 9 ~ 2" $
      show (test25 Proxy) @?=
      "Proxy"
    , testCase "forall x>1 . x ^ (Log x y) ~ y" $
      show (test26 Proxy) @?=
      "Proxy"
    ]
  , testGroup "errors"
    [ testCase "GCD 6 8 /~ 4" $ testFail1 `throws` testFail1Errors
    , testCase "GCD 6 8 + x /~ x + GCD 9 6" $ testFail2 `throws` testFail2Errors
    , testCase "CLog 3 10 /~ 2" $ testFail3 `throws` testFail3Errors
    , testCase "CLog 3 10 + x /~ x + CLog 2 9" $ testFail4 `throws` testFail4Errors
    , testCase "CLog 0 4 /~ 100" $ testFail5 `throws` testFail5Errors
    , testCase "CLog 1 4 /~ 100" $ testFail5 `throws` testFail5Errors
    , testCase "CLog 4 0 /~ 0" $ testFail7 `throws` testFail7Errors
    , testCase "CLog 1 (1^y) /~ y" $ testFail8 `throws` testFail8Errors
    , testCase "CLog 0 (0^y) /~ y" $ testFail9 `throws` testFail9Errors
    , testCase "No instance (KnownNat (CLog 1 4))" $ testFail10 `throws` testFail10Errors
    , testCase "No instance (KnownNat (CLog 4 4 - CLog 2 4))" $ testFail11 `throws` testFail11Errors
    , testCase "Div 4 0 /~ 4" $ testFail12 `throws` testFail12Errors
    , testCase "Mod 4 0 /~ 4" $ testFail13 `throws` testFail13Errors
    , testCase "FLog 0 4 /~ 100" $ testFail14 `throws` testFail14Errors
    , testCase "FLog 1 4 /~ 100" $ testFail15 `throws` testFail15Errors
    , testCase "FLog 4 0 /~ 0" $ testFail16 `throws` testFail16Errors
    , testCase "GCD 6 8 /~ 4" $ testFail17 `throws` testFail17Errors
    , testCase "GCD 6 8 + x /~ x + GCD 9 6" $ testFail18 `throws` testFail18Errors
    , testCase "No instance (KnownNat (Log 3 0))" $ testFail19 `throws` testFail19Errors
    , testCase "No instance (KnownNat (Log 3 10))" $ testFail20 `throws` testFail20Errors
    ]
  ]

-- | Assert that evaluation of the first argument (to WHNF) will throw
-- an exception whose string representation contains the given
-- substrings.
throws :: a -> [String] -> Assertion
throws v xs = do
  result <- try (evaluate v)
  case result of
    Right _ -> assertFailure "No exception!"
    Left (TypeError msg) ->
      if all (`isInfixOf` msg) xs
         then return ()
         else assertFailure msg
