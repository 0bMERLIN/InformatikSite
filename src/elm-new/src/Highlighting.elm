module Highlighting exposing (..)

-- parser
import Parser exposing (Parser, Step, loop, oneOf, succeed, getChompedString, (|=), (|.))
import Parser exposing (chompIf)
import Parser exposing (symbol)
import LanguageParser

-- html
import Html exposing (Html, div, text)
import Html.Parser
import Html.Parser.Util

-- data
import Set


------------------------------------------- HELPERS -------------------------------------------
colors =
    { keywordColor = "#E74C3C"
    , literalColor = "#2DAF4A"
    , symbolColor  = "#E78F3C"
    , commentColor = "#277E85"
    }




-- lang specific syntax
syntax : List (Parser Token)
syntax =
    [-- comments
      commentWithTag (colorTag colors.commentColor)
    ]  -- keywords
    ++ List.map (keywordWithTag (colorTag colors.keywordColor)) LanguageParser.reservedWords
       -- symbols / operators
    ++ List.map (operatorWithTag (colorTag colors.keywordColor)) LanguageParser.reservedSymbols
      -- literals
    ++
    [ floatWithTag   (colorTag colors.literalColor)
    , stringWithTag  (colorTag colors.literalColor)
    , charWithTag    (colorTag colors.literalColor)
      -- names
    , parseIdentifierWithTag [] spanTag
    , symbolWithTag  (colorTag colors.symbolColor)
    ]



--------------------------------------------- TYPES ---------------------------------------------
type alias Tag = (String, String)

type alias Token = (String, Tag)



------------------------------------------- UTILITIES -------------------------------------------
zip : List a -> List b -> List (a, b)
zip a b = List.map2 Tuple.pair a b





spanTag : Tag
spanTag =
    ( "<span>"
    , "</span>"
    )




colorTag : String -> Tag
colorTag color = ("<span style=\"color:" ++ color ++ ";\">", "</span>")





formatForDiv : String -> String
formatForDiv s = String.replace ">" "&gt;"
              >> String.replace "<" "&lt;"
              >> String.replace "\n" "<br>"
              >> String.replace " " "&nbsp;"
              <| s




toHtml : String -> Html msg
toHtml rawHtml =
    let innerHtml = case Html.Parser.run rawHtml of
            Ok nodes -> Html.Parser.Util.toVirtualDom nodes
            Err _    -> []
    in
        div [] innerHtml








------------------------------------------- HIGHLIGHTER -------------------------------------------
parseTokens : List (Parser Token) -> Parser (List Token)
parseTokens tokParsers =
    loop
        []
        <| parseTokensHelper tokParsers




parseTokensHelper : List (Parser Token)
                 -> List Token
                 -> Parser (Step (List Token) (List Token))
parseTokensHelper tokParsers revToks =
    oneOf
    [ succeed
        (\tok -> Parser.Loop (tok :: revToks))
        |= oneOf (tokParsers ++ [parseAny])
    , succeed () |> Parser.map (\_ -> Parser.Done (List.reverse revToks))
    ]




applyTag : Token -> String
applyTag (s, (start, end))
    =  start
    ++ formatForDiv s
    ++ end





highlight : List (Parser Token) -> String -> Html msg
highlight tokParsers code =
    case Parser.run (parseTokens tokParsers) code of
        Err _ -> text code
        Ok tokens -> toHtml <| String.concat (List.map applyTag tokens)








------------------------------------------- CUSTOM PARSERS -------------------------------------------
-- basis
parseAny : Parser Token
parseAny = Parser.map
    (\c -> (c, spanTag))
    (getChompedString
        <| chompIf (\_ -> True))






parseStringInner : Parser String
parseStringInner = Parser.map String.concat (loop [] parseStringInnerHelper)






parseStringInnerHelper : List String
                       -> Parser (Step (List String) (List String))
parseStringInnerHelper revChars = oneOf
    [ Parser.succeed (\_ -> Parser.Loop ("\\\"" :: revChars))
        |= Parser.backtrackable (Parser.symbol "\\" |. Parser.symbol "\"")
    , Parser.symbol "\""
        |> Parser.map (\_ -> Parser.Done (List.reverse revChars))
    , succeed (\c -> Parser.Loop (c :: revChars))
        |= getChompedString parseAny
    ]






parseString : Parser String
parseString = Parser.succeed
    (\s -> "\"" ++ s ++ "\"")
    |. Parser.symbol "\""
    |= parseStringInner






parseIdentifier : List String -> Parser String
parseIdentifier reservedWords =
    Parser.variable
    { start     = Char.isLower
    , inner     = \c -> Char.isAlphaNum c || c == '_'
    , reserved  = Set.fromList reservedWords
    }


-- with tags
keywordWithTag : Tag -> String -> Parser Token
keywordWithTag tag s = Parser.backtrackable (Parser.map (\_ -> (s, tag)) (Parser.keyword s))






floatWithTag : Tag -> Parser Token
floatWithTag tag = Parser.backtrackable (Parser.map (\f -> (f, tag)) (getChompedString Parser.float))





stringWithTag : Tag -> Parser Token
stringWithTag tag = Parser.backtrackable (Parser.map (\s -> (s, tag)) parseString)





parseIdentifierWithTag : List String -> Tag -> Parser Token
parseIdentifierWithTag reservedWords tag = Parser.backtrackable
    (Parser.map (\s -> (s, tag))
    (parseIdentifier reservedWords))






symbolWithTag : Tag -> Parser Token
symbolWithTag tag = Parser.backtrackable (Parser.map (\f -> (f, tag)) LanguageParser.symbolName)






commentWithTag : Tag -> Parser Token
commentWithTag tag = Parser.backtrackable (Parser.map (\f -> (f, tag)) LanguageParser.comment)






charWithTag : Tag -> Parser Token
charWithTag tag = Parser.backtrackable
    (Parser.map (\c -> ("\'" ++ String.fromChar c ++ "\'", tag)) LanguageParser.char)





operatorWithTag : Tag -> String -> Parser Token
operatorWithTag tag s = Parser.backtrackable
    (Parser.map (\c -> (c, tag)) (getChompedString <| Parser.symbol s))