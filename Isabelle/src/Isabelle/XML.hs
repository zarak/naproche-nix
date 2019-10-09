{- generated by Isabelle -}

{-  Title:      Isabelle/XML.hs
    Author:     Makarius
    LICENSE:    BSD 3-clause (Isabelle)

Untyped XML trees and representation of ML values.

See also "$ISABELLE_HOME/src/Pure/PIDE/xml.ML".
-}

module Isabelle.XML (Attributes, Body, Tree(..), wrap_elem, unwrap_elem, content_of)
where

import Isabelle.Library
import qualified Isabelle.Properties as Properties
import qualified Isabelle.Markup as Markup
import qualified Isabelle.Buffer as Buffer


{- types -}

type Attributes = Properties.T
type Body = [Tree]
data Tree = Elem (Markup.T, Body) | Text String


{- wrapped elements -}

wrap_elem :: ((Markup.T, Body), [Tree]) -> Tree
wrap_elem (((a, atts), body1), body2) =
  Elem (("xml_elem", ("xml_name", a) : atts), Elem (("xml_body", []), body1) : body2)

unwrap_elem :: Tree -> Maybe ((Markup.T, Body), [Tree])
unwrap_elem
  (Elem (("xml_elem", ("xml_name", a) : atts), Elem (("xml_body", []), body1) : body2)) =
  Just (((a, atts), body1), body2)
unwrap_elem _ = Nothing


{- text content -}

add_content :: Tree -> Buffer.T -> Buffer.T
add_content tree =
  case unwrap_elem tree of
    Just (_, ts) -> fold add_content ts
    Nothing ->
      case tree of
        Elem (_, ts) -> fold add_content ts
        Text s -> Buffer.add s

content_of :: Body -> String
content_of body = Buffer.empty |> fold add_content body |> Buffer.content


{- string representation -}

encode :: Char -> String
encode '<' = "&lt;"
encode '>' = "&gt;"
encode '&' = "&amp;"
encode '\'' = "&apos;"
encode '\"' = "&quot;"
encode c = [c]

instance Show Tree where
  show tree =
    Buffer.empty |> show_tree tree |> Buffer.content
    where
      show_tree (Elem ((name, atts), [])) =
        Buffer.add "<" #> Buffer.add (show_elem name atts) #> Buffer.add "/>"
      show_tree (Elem ((name, atts), ts)) =
        Buffer.add "<" #> Buffer.add (show_elem name atts) #> Buffer.add ">" #>
        fold show_tree ts #>
        Buffer.add "</" #> Buffer.add name #> Buffer.add ">"
      show_tree (Text s) = Buffer.add (show_text s)

      show_elem name atts =
        unwords (name : map (\(a, x) -> a ++ "=\"" ++ show_text x ++ "\"") atts)

      show_text = concatMap encode
