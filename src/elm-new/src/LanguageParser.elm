module LanguageParser exposing (..)


-- parser
import Parser
import Parser exposing (Parser, Step(..), Problem(..), (|.), (|=), succeed, oneOf, chompIf, spaces)

-- data
import Dict
import List.Extra
import Set exposing (Set)
import Parser exposing (backtrackable)
import Browser.Navigation exposing (back)
import Parser





------------------------------------------- TYPES -------------------------------------------
type Prog
    = Prog (List Module)


type Module
    = Module String (List Definition)


type Definition
    = Def String Exp


type Exp
    = EApp Exp Exp
    | ELam String Exp
    | ELit Lit
    | EArith ArithType Exp Exp
    | EObj (List Exp)
    | EVar String
    | EMatch Exp (List (Pattern, Exp))
    | ELetrec String Exp Exp
    | ELet String Exp Exp
    | EBuiltin String Exp
    | EModuleAccess String String


type ArithType
    = BAdd
    | BSub
    | BMul
    | BDiv
    | BLess
    | BGreater


type Lit
    = LNum Float
    | LChar Char
    | LSymbol String


type Pattern
    = PLit Lit
    | PVar String
    | PObj (List Pattern)


type alias Closure =
    { getEnv : Env
    , getParam : String
    , getBody : Exp
    }


type alias Env =
    { values  : RuntimeValueEnv
    , modules : RuntimeModuleEnv
    }


type alias RuntimeModuleEnv = Dict.Dict String RuntimeValueEnv


type alias RuntimeValueEnv = Dict.Dict String Val


type Val
    = VClosure Closure
    | VLit Lit
    | VObj (List Val)



-------------------------------------------------------------------- HELPERS --------------------------------------------------------------------
pairApply : (a -> b -> c) -> (a, b) -> c
pairApply f (a, b) = f a b



listToVObj : List Val -> Val
listToVObj l = case l of
    []      -> VObj []
    x :: xs -> VObj [x, listToVObj xs]




listToEObj : List Exp -> Exp
listToEObj l = case l of
    []      -> EObj []
    x :: xs -> EObj [x, listToEObj xs]





listToPObj : List Pattern -> Pattern
listToPObj l = case l of
    []      -> PObj []
    x :: xs -> PObj [x, listToPObj xs]





headWithAlt : a -> List a -> a
headWithAlt alt l = case l of
    []     -> alt
    x :: _ -> x




deadEndsToString : List Parser.DeadEnd -> String
deadEndsToString deadEnds = case deadEnds of
    [] -> "syntax error"
    deadEnd :: _ ->
        "syntax error in line "
        ++ String.fromInt deadEnd.row
        ++ ", column "
        ++ String.fromInt deadEnd.col
        ++ ":\n"
        ++ problemToString deadEnd.problem






-- Parser.problemToString doesn't work
problemToString : Problem -> String
problemToString p = case p of
    Expecting s        -> "expecting " ++ s
    ExpectingInt       -> "expecting an integer"
    ExpectingHex       -> "expecting a hexadecimal number"
    ExpectingOctal     -> "expecting an octal number"
    ExpectingBinary    -> "expecting a binary number"
    ExpectingFloat     -> "expecting a float"
    ExpectingNumber    -> "expecting a number"
    ExpectingVariable  -> "expecting a variable name"
    ExpectingSymbol s  -> "expecting symbol " ++ s
    ExpectingKeyword k -> "expecting keyword " ++ k
    ExpectingEnd       -> "expecting end of input"
    UnexpectedChar     -> "unexpected character"
    Problem ps         -> ps
    BadRepeat          -> "bad repeat"




convertToApps : Exp -> List Exp -> Exp
convertToApps f aS =
    case List.Extra.foldr1
         (\a b -> EApp b a)
         (List.reverse <| f :: aS)
    of
        Just x -> x
        Nothing -> f






-------------------------------------------------------------------- HELPER PARSERS --------------------------------------------------------------------
between : Parser a -> Parser b -> Parser c -> Parser c
between p1 p2 middle = Parser.succeed identity
    |. p1
    |= middle
    |. p2




anyCharExcept : Char -> Parser String
anyCharExcept c = Parser.getChompedString <| chompIf ((/=) c)




anyChar : Parser Char
anyChar = Parser.map
    (String.toList >> headWithAlt ' ')
    (Parser.getChompedString <| chompIf (\_ -> True))





-------------------------------------------------------------------- COMMENTS / WHITESPACE --------------------------------------------------------------------
comment : Parser String
comment = Parser.getChompedString
       <| Parser.lineComment "--"




comments : Parser ()
comments = succeed ()
    |. Parser.sequence
    { start = ""
    , separator = ""
    , end = ""
    , spaces = spaces
    , item = comment
    , trailing = Parser.Forbidden
    }




whitespace : Parser ()
whitespace =
    oneOf
    [ comments
    , spaces
    ]




-------------------------------------------------------------------- LITERALS --------------------------------------------------------------------
eObj : Parser Exp
eObj = succeed EObj
    |= Parser.sequence
    { start     = "{"
    , separator = ","
    , end       = "}"
    , spaces    = whitespace
    , item      = exp
    , trailing = Parser.Forbidden
    }





stringChar : Parser String
stringChar =
    oneOf
    [ succeed "\"" |. Parser.symbol "\\\""
    , succeed "\n" |. Parser.symbol "\\n"
    , anyCharExcept '\"'
    ]


string : Parser String
string = Parser.succeed String.concat
    |= Parser.sequence
    { start     = "\""
    , separator = ""
    , end       = "\""
    , spaces    =  succeed ()
    , item      = stringChar
    , trailing = Parser.Forbidden
    }






char : Parser Char
char = succeed identity
    |. Parser.symbol "\'"
    |= anyChar
    |. Parser.symbol "\'"





num : Parser Float
num =
    oneOf
    [ Parser.float
    , succeed negate
        |= backtrackable
        (succeed identity
        |. Parser.symbol "-"
        |= Parser.float)
    ]




lit : Parser Lit
lit =
    oneOf
    [ succeed LNum |= num
    , succeed LChar |= char
    , symbol
    ]





elit : Parser Exp
elit =
    oneOf
    [ Parser.map listToEObj (list (Parser.lazy (\_ -> exp)))
    , eObj
    , succeed ELit |= lit
    , succeed (String.toList >> List.map (LChar >> ELit) >> listToEObj) |= string
    ]





-------------------------------------------------------------------- SYNTACTIC SUGAR --------------------------------------------------------------------
list : Parser a -> Parser (List a)
list elem = Parser.sequence
    { start     = "["
    , separator = ","
    , end       = "]"
    , spaces    = whitespace
    , item      = elem
    , trailing  = Parser.Forbidden
    }





-------------------------------------------------------------------- VARIABLES / NAMES --------------------------------------------------------------------
reservedWords : List String
reservedWords =
    [ "let"
    , "in"
    , "match"
    , "with"
    , "fn"
    , "write"
    , "mod"
    , "def"
    , "end"
    , "stringof"
    ]






reservedSymbols : List String
reservedSymbols =
    [ "=>"
    , "="
    , "{"
    , "}"
    , ","
    , ";"
    , "|"
    , "["
    , "]"
    ]




varCharUpper : Char -> Bool
varCharUpper c = Char.isUpper c
         || c == 'Ä'
         || c == 'Ö'
         || c == 'Ü'
         || c == 'E'
         || c == '_'




varCharLower : Char -> Bool
varCharLower c = Char.isLower c
    || c == 'ä'
    || c == 'ö'
    || c == 'ü'
    || c == 'e'
    || c == '_'




varCharAlphanum : Char -> Bool
varCharAlphanum c = Char.isAlphaNum c
    || c == 'ä'
    || c == 'ö'
    || c == 'ü'
    || c == 'e'
    || c == '_'




variableName : Parser String
variableName = Parser.variable
    { start    = \c -> varCharLower c
    , inner    = \c -> varCharUpper c || varCharAlphanum c || varCharLower c
    , reserved = Set.fromList reservedWords
    }





moduleName : Parser String
moduleName = Parser.variable
    { start    = \c -> varCharUpper c
    , inner    = \c -> varCharUpper c || varCharAlphanum c || varCharLower c
    , reserved = Set.fromList reservedWords
    }





symbolName : Parser String
symbolName = Parser.variable
    { start    = (==) ':'
    , inner    = \c -> varCharUpper c || varCharAlphanum c || varCharLower c
    , reserved = Set.fromList reservedWords
    }





moduleAccess : Parser Exp
moduleAccess = succeed EModuleAccess
    |= moduleName
    |. Parser.symbol "."
    |= variableName





variable : Parser Exp
variable = Parser.succeed EVar
        |= variableName




symbol : Parser Lit
symbol = Parser.succeed LSymbol
      |= symbolName




-------------------------------------------------------------------- BUILTINS --------------------------------------------------------------------
ioWrite : Parser Exp
ioWrite = Parser.succeed EBuiltin
    |= succeed "write" |. Parser.keyword "write"
    |. whitespace
    |= exp

stringof : Parser Exp
stringof = Parser.succeed EBuiltin
    |= succeed "stringof" |. Parser.keyword "stringof"
    |. whitespace
    |= exp

builtin : Parser Exp
builtin = oneOf
    [ ioWrite
    , stringof
    ]


-------------------------------------------------------------------- LET --------------------------------------------------------------------



plet : Parser Exp
plet = Parser.succeed ELetrec
    |. Parser.keyword "let"
    |. whitespace
    |= variableName
    |. whitespace
    |. Parser.symbol "="
    |. whitespace
    |= exp
    |. whitespace
    |. Parser.keyword "in"
    |. whitespace
    |= exp




parametersAndArrow : Parser (List String)
parametersAndArrow = Parser.sequence
  { start = ""
  , separator = ""
  , end = "=>"
  , spaces = whitespace
  , item = variableName
  , trailing = Parser.Forbidden
  }



flip : (a -> b -> c) -> b -> a -> c
flip f a b = f b a



lambda : Parser Exp
lambda = Parser.succeed (\ps b -> List.foldl ELam b <| List.reverse ps)
    |. Parser.keyword "fn"
    |. whitespace
    |= parametersAndArrow
    |. whitespace
    |= exp



-------------------------------------------------------------------- PATTERN MATCHING --------------------------------------------------------------------
patternObj : Parser Pattern
patternObj = Parser.succeed PObj |=
    Parser.sequence
    { start     = "{"
    , separator = ","
    , end       = "}"
    , spaces    = whitespace
    , item      = Parser.lazy (\_ -> pattern)
    , trailing  = Parser.Forbidden
    }


pattern : Parser Pattern
pattern =
    oneOf
    [ Parser.map listToPObj (list (Parser.lazy (\_ -> pattern)))
    , patternObj
    , succeed PVar |= variableName
    , succeed PLit |= lit
    , succeed (String.toList >> List.map (LChar >> PLit) >> listToPObj) |= string
    ]


matchesInner : Parser (Pattern, Exp)
matchesInner = succeed Tuple.pair
    |= pattern
    |. whitespace
    |. Parser.symbol "=>"
    |. whitespace
    |= exp


matchesHelper : Parser (List (Pattern, Exp))
matchesHelper = Parser.sequence
    { start     = ""
    , separator = "|"
    , end       = "end"
    , spaces    = whitespace
    , item      = Parser.lazy (\_ -> matchesInner)
    , trailing  = Parser.Forbidden
    }


matches : Parser (List (Pattern, Exp))
matches = succeed identity
    |= matchesHelper
    |. whitespace


match : Parser Exp
match = succeed EMatch
    |. Parser.keyword "match"
    |. whitespace
    |= exp
    |. whitespace
    |. Parser.keyword "with"
    |= matches


-------------------------------------------------------------------- MAIN EXPRESSION PARSER --------------------------------------------------------------------
parenExp : Parser Exp
parenExp = succeed identity
    |. Parser.symbol "("
    |. whitespace
    |= Parser.lazy (\_ -> exp)
    |. whitespace
    |. Parser.symbol ")"


expInner : Parser Exp
expInner =
    oneOf
    [ builtin
    , plet
    , parenExp
    , lambda
    , match
    , variable
    , moduleAccess
    , elit
    ]


expCallHelper : List Exp -> Parser (Step (List Exp) (List Exp))
expCallHelper revExps =
    oneOf
    [ Parser.backtrackable <| succeed (\e -> Loop (e :: revExps))
    |. whitespace
    |= expInner
    , succeed ()
    |> Parser.map (\_ -> Done (List.reverse revExps))
    ]



binOp : Parser ArithType -> Parser (ArithType, Exp)
binOp op = succeed Tuple.pair
    |. whitespace
    |= op
    |. whitespace
    |= exp


operator : Parser ArithType
operator =
    oneOf
    [ succeed BAdd |. Parser.symbol "+"
    , succeed BSub |. Parser.symbol "-"
    , succeed BMul |. Parser.symbol "*"
    , succeed BDiv |. Parser.symbol "/"
    , succeed BLess |. Parser.symbol "<"
    , succeed BGreater |. Parser.symbol ">"
    ]


expOperatorHelper : List (ArithType, Exp)
                 -> Parser (Step
                    (List (ArithType, Exp))
                    (List (ArithType, Exp)))
expOperatorHelper revOps =
    oneOf
    [ Parser.backtrackable <| succeed (\e -> Loop (e :: revOps))
    |= binOp operator
    , succeed (Done (List.reverse revOps))
    ]


expHelper : Parser Exp
expHelper =
    succeed (\e es -> convertToApps e es)
    |= Parser.lazy (\_ -> expInner)
    |= Parser.loop [] expCallHelper


convOps : Exp -> List (ArithType, Exp) -> Exp
convOps startExp ops = case ops of
        [] -> startExp
        (op, expr) :: [] -> EArith op startExp expr
        (op1, expr1) :: (op2, expr2) :: rest -> EArith
            op1
            expr1
            (convOps expr2 ((op2, expr2) :: rest))


exp : Parser Exp
exp = succeed (\e ops -> convOps e ops)
    |= expHelper
    |= Parser.loop [] expOperatorHelper



-------------------------------------------------------------------- MODULE PARSER --------------------------------------------------------------------
definition : Parser Definition
definition = succeed Def
    |. Parser.keyword "def"
    |. whitespace
    |= variableName
    |. whitespace
    |. Parser.symbol "="
    |. whitespace
    |= exp
    |. whitespace


moduleDefinitions : Parser (List Definition)
moduleDefinitions = Parser.sequence
    { start     = ""
    , separator = ""
    , end       = "end"
    , spaces    = whitespace
    , item      = definition
    , trailing  = Parser.Forbidden
    }


pmodule : Parser Module
pmodule = succeed Module
    |. Parser.keyword "mod"
    |. whitespace
    |= moduleName
    |. whitespace
    |= moduleDefinitions



-------------------------------------------------------------------- PROGRAM PARSER
prog : Parser Prog
prog = succeed Prog |= Parser.sequence
    { start     = ""
    , separator = ""
    , end       = ";"
    , spaces    = whitespace
    , item      = pmodule
    , trailing  = Parser.Forbidden
    }


parse : Parser Prog
parse = succeed identity
    |. whitespace
    |= prog
    |. whitespace
    |. Parser.end