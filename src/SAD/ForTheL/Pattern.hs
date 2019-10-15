{-
Authors: Andrei Paskevich (2001 - 2008), Steffen Frerix (2017 - 2018)

Pattern parsing and pattern state management.
-}

{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

module SAD.ForTheL.Pattern
  ( nvr
  , newPrdPattern
  , addExpr
  , unnamedNotion
  , avr
  , newNotionPattern
  ) where


import Control.Monad.State.Class (put, gets)

import SAD.ForTheL.Base

import SAD.Parser.Base
import SAD.Parser.Combinators
import SAD.Parser.Token
import SAD.Parser.Primitives

import SAD.Data.Formula

import qualified Data.Set as Set

import Data.List
import Data.Char
import Control.Applicative
import Control.Monad
import Data.Text.Lazy (Text)
import qualified Data.Text.Lazy as Text

-- add expressions to the state of ForTheL

giveId :: Bool -> Int -> Formula -> Formula
giveId p n t = t {trmId = if p then specialId n else (trmId t)}

incId :: Enum p => Bool -> p -> p
incId p n = if p then succ n else n

addExpr :: Formula -> Formula -> Bool -> FState -> FTL Formula

addExpr t@Trm{trmName = TermUnaryAdjective _, trmArgs = vs} f p st
  = put ns >> return nf
  where
    n = idCount st
    (pt, nf) = extractWordPattern st (giveId p n t) f
    fm  = substs nf $ map varName vs
    ns  = st { adjectiveExpr = (pt, fm) : adjectiveExpr st, idCount = incId p n}

addExpr t@Trm{trmName = TermUnaryVerb _, trmArgs = vs} f p st
  = put ns >> return nf
  where
    n = idCount st
    (pt, nf) = extractWordPattern st (giveId p n t) f
    fm = substs nf $ map varName vs
    ns = st {verExpr = (pt, fm) : verExpr st, idCount = incId p n}

addExpr t@Trm{trmName = TermMultiAdjective _, trmArgs = vs} f p st
  = put ns >> return nf
  where
    n = idCount st
    ((hp:tp), nf) = extractWordPattern st (giveId p n t) f
    pt = hp : Word [] : Vr : tp
    fm = substs nf $ map varName vs
    ns = st {adjectiveExpr = (pt, fm) : adjectiveExpr st, idCount = incId p n}

addExpr t@Trm{trmName = TermMultiVerb _, trmArgs = vs} f p st
  = put ns >> return nf
  where
    n = idCount st
    ((hp:tp), nf) = extractWordPattern st (giveId p n t) f
    pt = hp : Word [] : Vr : tp
    fm = substs nf $ map varName vs
    ns = st {verExpr = (pt, fm) : verExpr st, idCount = incId p n}

addExpr t@Trm{trmName = TermNotion _, trmArgs = vs} f p st
  = put ns >> return nf
  where
    n = idCount st
    (pt, nf) = extractWordPattern st (giveId p n t) f
    fm = substs nf $ map varName vs
    ns = st {notionExpr = (pt, fm) : notionExpr st, idCount = incId p n}

addExpr Trm{trmName= TermEquality, trmArgs = [v, t@Trm {trmName = TermNotion rs}]} f p st
  = put ns >> return nf
  where
    n = idCount st
    vs = trmArgs t
    (pt, nf) = extractWordPattern st (giveId p n t {trmName = TermThe rs}) f
    fm = substs nf $ map varName (v:vs)
    ns = st {notionExpr = (pt, fm) : notionExpr st, idCount = incId p n}

addExpr Trm{trmName = TermEquality, trmArgs = [_, t]} eq@Trm {trmName = TermEquality} p st =
  put nn >> return (zEqu v nf)
  where
    [v, f] = trmArgs eq
    vs = trmArgs t
    n = idCount st
    (pt, nf) = extractSymbPattern (giveId p n t) f
    fm = substs nf $ map varName vs
    -- classification of pattern
    csm = lsm && rsm; lsm = notVr (head pt); rsm = notVr (last pt)
    notVr Vr = False; notVr _ = True
    -- add to the right category
    ns | csm = st {cfnExpr = (pt, fm) : cfnExpr st}
       | lsm = st {lfnExpr = (init pt, fm) : lfnExpr st}
       | rsm = st {rfnExpr = (tail pt, fm) : rfnExpr st}
       | otherwise = st {ifnExpr = (init (tail pt), fm) : ifnExpr st}
    -- increment id counter
    nn = ns {idCount = incId p n}

addExpr t@Trm{trmName = s, trmArgs = vs} f p st =
  put nn >> return nf
  where
    n = idCount st
    (pt, nf) = extractSymbPattern (giveId p n t) f
    fm = substs nf $ map varName vs
    -- classification of pattern
    csm = lsm && rsm; lsm = notVr (head pt); rsm = notVr (last pt)
    notVr Vr = False; notVr _ = True
    -- add the pattern to the right category
    ns | csm = st {cprExpr = (pt, fm) : cprExpr st}
       | lsm = st {lprExpr = (init pt, fm) : lprExpr st}
       | rsm = st {rprExpr = (tail pt, fm) : rprExpr st}
       | otherwise = st {iprExpr = (init (tail pt), fm) : iprExpr st}
    -- check if pattern is a symbolic notion
    snt = not lsm && elem (varName $ head vs) (declNames mempty nf)
    -- and add it there as well if so (and increment id counter)
    nn | snt = ns {symbNotionExpr = (tail pt,fm) : symbNotionExpr st, idCount = incId p n}
       | otherwise = ns {idCount = incId p n}






-- pattern extraction

extractWordPattern :: FState -> Formula -> Formula -> ([Pattern], Formula)
extractWordPattern st t@Trm {trmName = s, trmArgs = vs} f = (pt, nf)
  where
    pt = map getPattern ws
    nt = t {trmName = pr $ getName pt}
    nf = replace nt t {trmId = NewId} f
    (pr, ws) = fmap Text.words $ termSplit s
    dict = strSyms st

    getPattern "." = Nm
    getPattern "#" = Vr
    getPattern w = Word $ foldl' union [w] $ filter (elem w) dict

    getName (Word (t:_):ls) = case Text.uncons t of
      Just (c, cs) -> Text.cons (toUpper c) cs <> getName ls
      Nothing -> getName ls
    getName (_:ls) = getName ls
    getName [] = ""


extractSymbPattern :: Formula -> Formula -> ([Pattern], Formula)
extractSymbPattern t@Trm {trmName = TermName s, trmArgs = vs} f = (pt, nf)
  where
    pt = map getPattern (Text.words s)
    nt = t {trmName = TermSymbolic $ getName pt}
    nf = replace nt t {trmId = NewId} f

    getPattern "#" = Vr
    getPattern w = Symbol w

    getName (Symbol s:ls) = symEncode s <> getName ls
    getName (Vr:ls) = symEncode "." <> getName ls
    getName [] = ""




-- New patterns


newPrdPattern :: FTL Formula -> FTL Formula
newPrdPattern tvr = multi </> unary </> newSymbPattern tvr
  where
    unary = do
      v <- tvr; (t, vs) <- unaryAdj -|- unaryVerb
      return $ zTrm NewId t (v:vs)
    multi = do
      (u,v) <- liftM2 (,) tvr (comma >> tvr);
      (t, vs) <- multiAdj -|- multiVerb
      return $ zTrm NewId t (u:v:vs)

    unaryAdj = do is; (t, vs) <- patHead wlexem tvr; return (TermUnaryAdjective t, vs)
    multiAdj = do is; (t, vs) <- patHead wlexem tvr; return (TermMultiAdjective t, vs)
    unaryVerb = do (t, vs) <- patHead wlexem tvr; return (TermUnaryVerb t, vs)
    multiVerb = do (t, vs) <- patHead wlexem tvr; return (TermMultiVerb t, vs)

newNotionPattern :: FTL Formula
                 -> FTL (Formula, PosVar)
newNotionPattern tvr = (notion <|> fun) </> unnamedNotion tvr
  where
    notion = do
      an; (t, v:vs) <- patName wlexem tvr
      return (zTrm NewId (TermNotion t) (v:vs), PosVar (varName v) (varPosition v))
    fun = do
      the; (t, v:vs) <- patName wlexem tvr
      return (zEqu v $ zTrm NewId (TermNotion t) vs, PosVar (varName v) (varPosition v))

unnamedNotion :: FTL Formula
                 -> FTL (Formula, PosVar)
unnamedNotion tvr = (notion <|> fun) </> (newSymbPattern tvr >>= equ)
  where
    notion = do
      an; (t, v:vs) <- patNoName wlexem tvr
      return (zTrm NewId (TermNotion t) (v:vs), PosVar (varName v) (varPosition v))
    fun = do
      the; (t, v:vs) <- patNoName wlexem tvr
      return (zEqu v $ zTrm NewId (TermNotion t) vs, PosVar (varName v) (varPosition v))
    equ t = do v <- hidden; return (zEqu (pVar v) t, v)


newSymbPattern :: FTL Formula -> FTL Formula
newSymbPattern tvr = left -|- right
  where
    left = do
      (t, vs) <- patHead slexem tvr
      return $ zTrm NewId (TermName t) vs
    right = do
      (t, vs) <- patTail slexem tvr
      guard $ not $ null $ tail $ Text.words t
      return $ zTrm NewId (TermName t) vs


-- pattern parsing


patHead :: Parser st Text
          -> Parser st a -> Parser st (Text, [a])
patHead lxm tvr = do
  l <- Text.unwords <$> chain lxm
  (ls, vs) <- opt ("", []) $ patTail lxm tvr
  return (l <> " " <> ls, vs)


patTail :: Parser st Text
          -> Parser st a -> Parser st (Text, [a])
patTail lxm tvr = do
  v <- tvr
  (ls, vs) <- opt ("", []) $ patHead lxm tvr
  return ("# " <> ls, v:vs)


patName :: FTL Text
          -> FTL Formula -> FTL (Text, [Formula])
patName lxm tvr = do
  l <- Text.unwords <$> chain lxm
  n <- nam
  (ls, vs) <- opt ("", []) $ patHead lxm tvr
  return (l <> " . " <> ls, n:vs)
  where
    nam :: FTL Formula
    nam = do
      n <- fmap (const Top) nvr </> avr
      guard $ isVar n;
      return n


patNoName :: FTL Text
            -> FTL Formula -> FTL (Text, [Formula])
patNoName lxm tvr = do
  l <- Text.unwords <$> chain lxm; n <- fmap pVar hidden
  (ls, vs) <- opt ("", []) $ patShort lxm tvr
  return (l <> " . " <> ls, n:vs)
  where
    --patShort is a kind of buffer that ensures that a variable does not directly
    --follow the name of the notion
    patShort lxm tvr = do
      l <- lxm; (ls, vs) <- patTail lxm tvr
      return (l <> " " <> ls, vs)



-- In-pattern lexemes and variables

wlexem :: FTL Text
wlexem = do
  l <- wlx
  guard $ Text.all isAlpha l
  return $ Text.toCaseFold l

slexem :: FTL Text
slexem = slex -|- wlx
  where
    slex = tokenPrim isSymb
    isSymb t =
      let tk = showToken t
      in case Text.uncons tk of
        Just (c, "") -> guard (c `elem` symChars) >> return tk
        _ -> Nothing

wlx :: FTL Text
wlx = failing nvr >> tokenPrim isWord
  where
    isWord t =
      let tk = showToken t; ltk = Text.toCaseFold tk
      in guard (Text.all isAlphaNum tk && ltk `Set.notMember` keylist) >> return tk
    keylist = Set.fromList ["a","an","the","is","are","be"]

nvr :: FTL Formula
nvr = do
  v <- var
  dvs <- getDecl
  tvs <- gets tvrExpr
  guard $ posVarName v `elem` dvs || any (elem (posVarName v) . fst) tvs
  return $ pVar v

avr :: Parser st Formula
avr = do
  v <- var;
  guard $ Text.null $ Text.tail $ deVar $ posVarName v
  return $ pVar v
  where
    deVar (VarConstant s) = s
    deVar _ = error "SAD.ForTheL.Pattern.avr: other variable"
