{- generated by Isabelle -}

{-  Title:      Isabelle/Properties.hs
    Author:     Makarius
    LICENSE:    BSD 3-clause (Isabelle)

Property lists.

See also "$ISABELLE_HOME/src/Pure/General/properties.ML".
-}

module Isabelle.Properties (Entry, T, defined, get, put, remove)
where

import qualified Data.List as List


type Entry = (String, String)
type T = [Entry]

defined :: T -> String -> Bool
defined props name = any (\(a, _) -> a == name) props

get :: T -> String -> Maybe String
get props name = List.lookup name props

put :: Entry -> T -> T
put entry props = entry : remove (fst entry) props

remove :: String -> T -> T
remove name props =
  if defined props name then filter (\(a, _) -> a /= name) props
  else props
