module Main exposing (main)


-- HTML imports / UI stuff
import Browser
import Html                    exposing (..)
import Html.Events             exposing (onInput, onClick, onFocus)
import Html.Attributes as Attr exposing (..)
import Html.Parser

-- syntax highlighting related stuff
import Highlighting
import Parser
import Parser exposing (getChompedString, Parser, (|.))

-- interpreter stuff
import InterpreterMsg exposing (InterpreterMsg)
import Interpreter
import LanguageParser exposing (Exp(..), Lit(..), Pattern(..))
import Either
import Dict
import LanguageParser exposing (lit)

-- misc
import SaveCode








------------------------------------------- TYPES -------------------------------------------
type alias Config =
    { neverSave   : Bool
    , isEditable  : Bool
    , isRunnable  : Bool
    }






type alias Model =
    { code : String
    , codeHighlighted : Html Msg
    , syntax : List (Parser Highlighting.Token)
    , interpreterMsg : InterpreterMsg.InterpreterMsg
    , config : Config
    , stdLibCode : String
    }





type Msg
    = Run
    | UpdateCode String
    | ResetInterpreterMsg





------------------------------------------- EDITOR HELPERS ----------------------------------
mkEditorElem : Html a -> Html a
mkEditorElem e = div [ attribute "class" "editor-elem" ] [e]








------------------------------------------- VIEW --------------------------------------------
view : Model -> Html Msg
view model = div []
    [ if model.config.isRunnable then button [ id "run-btn"
             , class "responsive-btn-1 noselect"
             , onClick Run ]
             [ text "run" ]
      else
        div [] []
    , fieldset [ class "editor" ]
    [ textarea
        [ id "code-input"
        , class "input"
        , spellcheck False
        , onFocus ResetInterpreterMsg
        , onInput UpdateCode
        , readonly (not model.config.isEditable)
        , value model.code
        , placeholder "write your code here... (tutorial on 'home' page)" ] []
    , output
        [ id "code-output"
        , attribute "role" "status"
        , class "highlighted-output" ]
        [ model.codeHighlighted ] ]
    , InterpreterMsg.showHtml model.interpreterMsg
    ]






--------------------------------------------- UPDATE -------------------------------------------
update : Msg -> Model -> (Model, Cmd msg)
update msg model = case msg of
    Run ->
        let interpreterRes = Interpreter.interpret "" (model.stdLibCode ++ "\n\n" ++ model.code)
        in ( { model | interpreterMsg = interpreterRes }
           , Cmd.none)




    UpdateCode code ->
        let highlightedCode = Highlighting.highlight
             model.syntax
             code
        in  ( { model | codeHighlighted = highlightedCode
              , code = code }
            , if model.config.neverSave
              then Cmd.none
              else SaveCode.save code )



    ResetInterpreterMsg ->
        ({model | interpreterMsg = InterpreterMsg.empty }
        , Cmd.none)





------------------------------------------- INIT -------------------------------------------
init : (String, Config, String) -> (Model, Cmd Msg)
init (code, conf, stdlibCode) = update (UpdateCode code)
    ({ code = ""
    ,  codeHighlighted = div [] []
    ,  syntax = Highlighting.syntax
    ,  interpreterMsg = InterpreterMsg.empty
    ,  config = conf
    ,  stdLibCode = stdlibCode
    })







------------------------------------------- MAIN -------------------------------------------
main : Program (String, Config, String) Model Msg
main = Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }