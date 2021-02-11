{- generated by Isabelle -}

{-  Title:      Isabelle/Markup.hs
    Author:     Makarius
    LICENSE:    BSD 3-clause (Isabelle)

Quasi-abstract markup elements.

See also "$ISABELLE_HOME/src/Pure/PIDE/markup.ML".
-}

{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

module Isabelle.Markup (
  T, empty, is_empty, properties,

  nameN, name, xnameN, xname, kindN,

  bindingN, binding, entityN, entity, defN, refN,

  completionN, completion, no_completionN, no_completion,

  lineN, end_lineN, offsetN, end_offsetN, fileN, idN, positionN, position,

  expressionN, expression,

  citationN, citation,

  pathN, path, urlN, url, docN, doc,

  markupN, consistentN, unbreakableN, indentN, widthN,
  blockN, block, breakN, break, fbreakN, fbreak, itemN, item,

  wordsN, words,

  tfreeN, tfree, tvarN, tvar, freeN, free, skolemN, skolem, boundN, bound, varN, var,
  numeralN, numeral, literalN, literal, delimiterN, delimiter, inner_stringN, inner_string,
  inner_cartoucheN, inner_cartouche,
  token_rangeN, token_range,
  sortingN, sorting, typingN, typing, class_parameterN, class_parameter,

  antiquotedN, antiquoted, antiquoteN, antiquote,

  paragraphN, paragraph, text_foldN, text_fold,

  keyword1N, keyword1, keyword2N, keyword2, keyword3N, keyword3, quasi_keywordN, quasi_keyword,
  improperN, improper, operatorN, operator, stringN, string, alt_stringN, alt_string,
  verbatimN, verbatim, cartoucheN, cartouche, commentN, comment, comment1N, comment1,
  comment2N, comment2, comment3N, comment3,

  forkedN, forked, joinedN, joined, runningN, running, finishedN, finished,
  failedN, failed, canceledN, canceled, initializedN, initialized, finalizedN, finalized,
  consolidatedN, consolidated,

  writelnN, writeln, stateN, state, informationN, information, tracingN, tracing,
  warningN, warning, legacyN, legacy, errorN, error, reportN, report, no_reportN, no_report,

  intensifyN, intensify,
  Output, no_output)
where

import Prelude hiding (words, error, break)

import Isabelle.Library
import qualified Isabelle.Properties as Properties
import qualified Isabelle.Value as Value


{- basic markup -}

type T = (String, Properties.T)

empty :: T
empty = ("", [])

is_empty :: T -> Bool
is_empty ("", _) = True
is_empty _ = False

properties :: Properties.T -> T -> T
properties more_props (elem, props) =
  (elem, fold_rev Properties.put more_props props)

markup_elem :: String -> T
markup_elem name = (name, [])

markup_string :: String -> String -> String -> T
markup_string name prop = \s -> (name, [(prop, s)])


{- misc properties -}

nameN :: String
nameN = "name"

name :: String -> T -> T
name a = properties [(nameN, a)]

xnameN :: String
xnameN = "xname"

xname :: String -> T -> T
xname a = properties [(xnameN, a)]

kindN :: String
kindN = "kind"


{- formal entities -}

bindingN :: String
bindingN = "binding"
binding :: T
binding = markup_elem bindingN

entityN :: String
entityN = "entity"
entity :: String -> String -> T
entity kind name =
  (entityN,
    (if null name then [] else [(nameN, name)]) ++ (if null kind then [] else [(kindN, kind)]))

defN :: String
defN = "def"

refN :: String
refN = "ref"


{- completion -}

completionN :: String
completionN = "completion"
completion :: T
completion = markup_elem completionN

no_completionN :: String
no_completionN = "no_completion"
no_completion :: T
no_completion = markup_elem no_completionN


{- position -}

lineN, end_lineN :: String
lineN = "line"
end_lineN = "end_line"

offsetN, end_offsetN :: String
offsetN = "offset"
end_offsetN = "end_offset"

fileN, idN :: String
fileN = "file"
idN = "id"

positionN :: String
positionN = "position"
position :: T
position = markup_elem positionN


{- expression -}

expressionN :: String
expressionN = "expression"

expression :: String -> T
expression kind = (expressionN, if kind == "" then [] else [(kindN, kind)])


{- citation -}

citationN :: String
citationN = "citation"
citation :: String -> T
citation = markup_string nameN citationN


{- external resources -}

pathN :: String
pathN = "path"
path :: String -> T
path = markup_string pathN nameN

urlN :: String
urlN = "url"
url :: String -> T
url = markup_string urlN nameN

docN :: String
docN = "doc"
doc :: String -> T
doc = markup_string docN nameN


{- pretty printing -}

markupN, consistentN, unbreakableN, indentN :: String
markupN = "markup"
consistentN = "consistent"
unbreakableN = "unbreakable"
indentN = "indent"

widthN :: String
widthN = "width"

blockN :: String
blockN = "block"
block :: Bool -> Int -> T
block c i =
  (blockN,
    (if c then [(consistentN, Value.print_bool c)] else []) ++
    (if i /= 0 then [(indentN, Value.print_int i)] else []))

breakN :: String
breakN = "break"
break :: Int -> Int -> T
break w i =
  (breakN,
    (if w /= 0 then [(widthN, Value.print_int w)] else []) ++
    (if i /= 0 then [(indentN, Value.print_int i)] else []))

fbreakN :: String
fbreakN = "fbreak"
fbreak :: T
fbreak = markup_elem fbreakN

itemN :: String
itemN = "item"
item :: T
item = markup_elem itemN


{- text properties -}

wordsN :: String
wordsN = "words"
words :: T
words = markup_elem wordsN


{- inner syntax -}

tfreeN :: String
tfreeN = "tfree"
tfree :: T
tfree = markup_elem tfreeN

tvarN :: String
tvarN = "tvar"
tvar :: T
tvar = markup_elem tvarN

freeN :: String
freeN = "free"
free :: T
free = markup_elem freeN

skolemN :: String
skolemN = "skolem"
skolem :: T
skolem = markup_elem skolemN

boundN :: String
boundN = "bound"
bound :: T
bound = markup_elem boundN

varN :: String
varN = "var"
var :: T
var = markup_elem varN

numeralN :: String
numeralN = "numeral"
numeral :: T
numeral = markup_elem numeralN

literalN :: String
literalN = "literal"
literal :: T
literal = markup_elem literalN

delimiterN :: String
delimiterN = "delimiter"
delimiter :: T
delimiter = markup_elem delimiterN

inner_stringN :: String
inner_stringN = "inner_string"
inner_string :: T
inner_string = markup_elem inner_stringN

inner_cartoucheN :: String
inner_cartoucheN = "inner_cartouche"
inner_cartouche :: T
inner_cartouche = markup_elem inner_cartoucheN


token_rangeN :: String
token_rangeN = "token_range"
token_range :: T
token_range = markup_elem token_rangeN


sortingN :: String
sortingN = "sorting"
sorting :: T
sorting = markup_elem sortingN

typingN :: String
typingN = "typing"
typing :: T
typing = markup_elem typingN

class_parameterN :: String
class_parameterN = "class_parameter"
class_parameter :: T
class_parameter = markup_elem class_parameterN


{- antiquotations -}

antiquotedN :: String
antiquotedN = "antiquoted"
antiquoted :: T
antiquoted = markup_elem antiquotedN

antiquoteN :: String
antiquoteN = "antiquote"
antiquote :: T
antiquote = markup_elem antiquoteN


{- text structure -}

paragraphN :: String
paragraphN = "paragraph"
paragraph :: T
paragraph = markup_elem paragraphN

text_foldN :: String
text_foldN = "text_fold"
text_fold :: T
text_fold = markup_elem text_foldN


{- outer syntax -}

keyword1N :: String
keyword1N = "keyword1"
keyword1 :: T
keyword1 = markup_elem keyword1N

keyword2N :: String
keyword2N = "keyword2"
keyword2 :: T
keyword2 = markup_elem keyword2N

keyword3N :: String
keyword3N = "keyword3"
keyword3 :: T
keyword3 = markup_elem keyword3N

quasi_keywordN :: String
quasi_keywordN = "quasi_keyword"
quasi_keyword :: T
quasi_keyword = markup_elem quasi_keywordN

improperN :: String
improperN = "improper"
improper :: T
improper = markup_elem improperN

operatorN :: String
operatorN = "operator"
operator :: T
operator = markup_elem operatorN

stringN :: String
stringN = "string"
string :: T
string = markup_elem stringN

alt_stringN :: String
alt_stringN = "alt_string"
alt_string :: T
alt_string = markup_elem alt_stringN

verbatimN :: String
verbatimN = "verbatim"
verbatim :: T
verbatim = markup_elem verbatimN

cartoucheN :: String
cartoucheN = "cartouche"
cartouche :: T
cartouche = markup_elem cartoucheN

commentN :: String
commentN = "comment"
comment :: T
comment = markup_elem commentN


{- comments -}

comment1N :: String
comment1N = "comment1"
comment1 :: T
comment1 = markup_elem comment1N

comment2N :: String
comment2N = "comment2"
comment2 :: T
comment2 = markup_elem comment2N

comment3N :: String
comment3N = "comment3"
comment3 :: T
comment3 = markup_elem comment3N


{- command status -}

forkedN, joinedN, runningN, finishedN, failedN, canceledN,
  initializedN, finalizedN, consolidatedN :: String
forkedN = "forked"
joinedN = "joined"
runningN = "running"
finishedN = "finished"
failedN = "failed"
canceledN = "canceled"
initializedN = "initialized"
finalizedN = "finalized"
consolidatedN = "consolidated"

forked, joined, running, finished, failed, canceled,
  initialized, finalized, consolidated :: T
forked = markup_elem forkedN
joined = markup_elem joinedN
running = markup_elem runningN
finished = markup_elem finishedN
failed = markup_elem failedN
canceled = markup_elem canceledN
initialized = markup_elem initializedN
finalized = markup_elem finalizedN
consolidated = markup_elem consolidatedN


{- messages -}

writelnN :: String
writelnN = "writeln"
writeln :: T
writeln = markup_elem writelnN

stateN :: String
stateN = "state"
state :: T
state = markup_elem stateN

informationN :: String
informationN = "information"
information :: T
information = markup_elem informationN

tracingN :: String
tracingN = "tracing"
tracing :: T
tracing = markup_elem tracingN

warningN :: String
warningN = "warning"
warning :: T
warning = markup_elem warningN

legacyN :: String
legacyN = "legacy"
legacy :: T
legacy = markup_elem legacyN

errorN :: String
errorN = "error"
error :: T
error = markup_elem errorN

reportN :: String
reportN = "report"
report :: T
report = markup_elem reportN

no_reportN :: String
no_reportN = "no_report"
no_report :: T
no_report = markup_elem no_reportN

intensifyN :: String
intensifyN = "intensify"
intensify :: T
intensify = markup_elem intensifyN


{- output -}

type Output = (String, String)

no_output :: Output
no_output = ("", "")
