module Interpreter exposing (..)

-- parser
import LanguageParser exposing ( Env
                               , RuntimeValueEnv
                               , RuntimeModuleEnv
                               , Definition(..)
                               , Module(..)
                               , Prog(..)
                               , Exp(..)
                               , Val(..)
                               , Lit(..)
                               , Pattern(..)
                               , ArithType(..)
                               , listToVObj
                               )
import Parser

-- data
import Either exposing (Either(..), andThen, partition, foldr, isRight)
import List.Extra
import Dict

-- other utils
import InterpreterMsg exposing (InterpreterMsg(..))
import String
import Bootstrap.Spinner exposing (srMessage)



------------------------------------------------ TYPES -----------------------------------------------
type alias IOBuffer = String




type alias Evaluator inp env out
    =  inp
    -> IOBuffer
    -> env
    -> Either String out


------------------------------------------- HELPERS -------------------------------------------
-- utils --
boolToLit : Bool -> Lit
boolToLit b = case b of
    True  -> LSymbol ":true"
    False -> LSymbol ":false"




extendEnvValues : String -> Val -> Env -> Env
extendEnvValues name val env = { env | values = Dict.insert name val env.values }




envValLookup : String -> Env -> Maybe Val
envValLookup name env = Dict.get name env.values




litToStr : Lit -> String
litToStr l = case l of
    LNum n -> String.fromFloat n
    LChar c -> "\'" ++ String.fromChar c ++ "\'"
    LSymbol s -> s




valToStr : Val -> String
valToStr v = case v of
    VClosure _ -> "<<anonymous function>>"
    VLit l -> litToStr l
    VObj vs -> "{" ++ (String.join ", " <| List.map valToStr vs) ++ "}"





resToStr : Either String Val -> String
resToStr r = case r of
    Left err -> "error: " ++ err
    Right v -> valToStr v





sequence : List (Either a b) -> Either a (List b)
sequence es =
    let (ls, rs) = partition es
    in case (ls, rs) of
        ([], [])         -> Right []
        (err :: errs, _) -> Left err
        ([], _)          -> Right rs




foldr1 : (a -> a -> a) -> List a -> a -> a
foldr1 f l alt = case List.Extra.foldr1 f l of
    Just x  -> x
    Nothing -> alt




strToVList : String -> Val
strToVList = (String.toList >> List.map (LChar >> VLit) >> listToVObj)






------------------------------------------- MAIN EVALUATOR -------------------------------------------
interpret : IOBuffer -> String -> InterpreterMsg
interpret initIOBuf code =
    case
        Parser.run
        LanguageParser.parse
        code
    of
        Err deadEnds -> Error (LanguageParser.deadEndsToString [])
        Ok p         -> case evalModules p initIOBuf Dict.empty of
            Left err         -> Error err
            Right (e, ioBuf) -> Output ioBuf






------------------------------------------- MODULE EVAL -------------------------------------------
evalModule : Evaluator Module Env (RuntimeValueEnv, IOBuffer)
evalModule (Module _ definitions) ioBuf env = evalDefs definitions ioBuf env





evalModules : Evaluator Prog RuntimeModuleEnv (RuntimeModuleEnv, IOBuffer)
evalModules prog ioBuf env = case prog of
    Prog [] -> Right (env, ioBuf)
    Prog (Module name defs :: ms) -> case
            evalModule
            (Module name defs)
            ioBuf
            { values = Dict.empty
            , modules = env }
        of
        Left err -> Left err
        Right (mval, mIOBuf) -> evalModules
            (Prog ms)
            mIOBuf
            (Dict.insert name mval env)





evalDefs : Evaluator (List Definition) Env (RuntimeValueEnv, IOBuffer)
evalDefs definitions ioBuf env = case definitions of
    [] -> Right (env.values, ioBuf)
    (Def dname dexp) :: defs -> case
            evalExp
            (EApp eFix <| ELam dname dexp)
            ioBuf
            env
        of
        Left err -> Left err
        Right (dval, dIOBuf) -> case
            evalDefs
            defs
            dIOBuf
            (extendEnvValues dname dval env) of
            Left err -> Left err
            Right (vs, buf) -> Right (Dict.insert dname dval vs, buf)





------------------------------------------- EXP EVALUATION -----------------------------------------
-- unification algorithm (HM-type -inference-ish).
-- The substitutions are just value environments here
unify : Val -> Pattern -> Either String RuntimeValueEnv
unify v p = case (v, p) of
    -- literals
    (VLit l, PVar s) -> Right <| Dict.singleton s <| VLit l
    (VLit a, PLit b) ->
        if
            a == b
        then
            Right Dict.empty
        else
            Left "can't match two different values"

    -- objects
    (VObj vs, PVar s) -> Right (Dict.singleton s (VObj vs))

    (VObj vs, PObj ps) ->
        if
            List.length vs /= List.length ps
        then
            Left "can't unify patterns of different shapes"
        else
            (sequence
            <| List.map (\(a, b) -> unify a b)
            <| List.Extra.zip vs ps)
            |> andThen (\envs ->
            Right <| foldr1 Dict.union envs Dict.empty)

    (VClosure c, PVar s) -> Right (Dict.singleton s (VClosure c))

    (_, _)          -> Left "can't unify patterns of different shapes"





----- main evalExp -----
-- fixpoint combinator
eFix : Exp
eFix =
    let f = ELam "g"
         <| EApp (EVar "G") (ELam "x"
         <| EApp (EApp (EVar "g") (EVar "g")) (EVar "x"))
    in ELam "G" <| EApp f f


-- this could be more terse and readable
-- with do-notation and monad transformers
-- (that thing that elm doesn't have, because of "stylistic choices"... FUCK YOUUUUU)
evalExp : Evaluator Exp Env (Val, IOBuffer)
evalExp exp ioBuf env = case exp of
    EApp f a ->
        evalExp a ioBuf env  |> andThen (\(aVal, aIOBuf) ->

        evalExp f aIOBuf env |> andThen (\(fVal, fIOBuf) ->

        case fVal of
            VClosure fVal2 -> evalExp
                fVal2.getBody
                fIOBuf
                (extendEnvValues fVal2.getParam aVal fVal2.getEnv)
            _ -> Left "cannot use literal value as function"))




    ELetrec s v b ->
        evalExp (ELet s (EApp eFix <| ELam s v) b) ioBuf env



    ELet s v b ->
        evalExp v ioBuf env |> andThen (\(vV, vIOBuf) ->

        let env2 = extendEnvValues s vV env in

        evalExp b vIOBuf env2)



    ELam p b -> Right
        (VClosure
        { getEnv = env
        , getParam = p
        , getBody = b }
        , ioBuf)





    ELit l -> Right (VLit l, ioBuf)





    EObj es ->
        List.map (\e -> evalExp e ioBuf env) es |> sequence |> andThen (\vs ->

        -- IO from the inside of Objects is ignored for now
        -- TODO: fix this
        Right ( VObj (List.map Tuple.first vs)
              , ioBuf))




    EVar s -> case envValLookup s env of
        Just v  -> Right (v, ioBuf)
        Nothing -> Left ("unbound name " ++ s)





    EModuleAccess mname vname ->
        case Dict.get mname env.modules of
            Nothing -> Left ("unbound module " ++ mname)
            Just mod -> case Dict.get vname mod of
                Nothing -> Left ("module " ++ mname ++ " does not have a value named " ++ vname ++ " in it")
                Just v -> Right (v, ioBuf)




    EMatch v cases ->
        evalExp v ioBuf env |> andThen (\(vVal, vIOBuf) ->

        let patts = List.map Tuple.first cases in
        let ress = List.map Tuple.second cases in

        let envs = List.map (unify vVal) patts in

        let valS = valToStr vVal in

        let message
              = "incomplete pattern (\""
              ++ String.left 5 valS
              ++ (if String.length valS > 5 then "...\"" else "\"")
              ++ " missing)"
        in
        (Either.fromMaybe message
            <| List.head
            <| List.filter (Tuple.first >> isRight)
            <| List.Extra.zip envs ress)
        |> andThen (\finalCase ->

        Tuple.first finalCase |> andThen (\finalSub ->

        let finalRes = Tuple.second finalCase in

        evalExp finalRes vIOBuf
            { env | values = Dict.union finalSub env.values })))




    EBuiltin name e -> case name of
        "write" -> 
            evalExp e ioBuf env |> andThen (\(v, newIOBuf) -> case v of
            VLit (LChar c) -> Right
                ( VLit <| LSymbol ":nothing"
                , newIOBuf ++ String.fromChar c)
            _ -> Left "can't write non-character value")
        "stringof" ->
            evalExp e ioBuf env |> andThen (\(v, newIOBuf) ->
                Right
                    ( strToVList (valToStr v), newIOBuf )
            )
        _ -> Left ("unknown builtin" ++ name)



    EArith t expA expB ->
        evalExp expA ioBuf env |> andThen (\(valA, ioBufA) ->

        evalExp expB ioBufA env |> andThen (\(valB, ioBufB) ->

        case (valA, valB) of
            (VLit (LNum a), VLit (LNum b)) -> case t of
                BAdd     -> Right (VLit (LNum (a + b)), ioBufB)
                BSub     -> Right (VLit (LNum (a - b)), ioBufB)
                BMul     -> Right (VLit (LNum (a * b)), ioBufB)
                BDiv     -> Right (VLit (LNum (a / b)), ioBufB)
                BLess    -> Right (VLit (boolToLit (a < b)), ioBufB)
                BGreater -> Right (VLit (boolToLit (a > b)), ioBufB)
            _ -> Left "can't do arithmetic on non-number values"))