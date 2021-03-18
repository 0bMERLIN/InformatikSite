port module Editor exposing (main)


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
import BrightnessPort exposing (..)






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
    , brightnessMode : BrightnessMode
    , brightnessModeBtnEnabled : Bool
    }





type Msg
    = Run
    | UpdateCode String
    | ResetInterpreterMsg
    | ToggleBrightnessMode
    | BrightnessModeBtnReEnable





------------------------------------------- EDITOR HELPERS ----------------------------------
mkEditorElem : Html a -> Html a
mkEditorElem e = div [ attribute "class" "editor-elem" ] [e]








------------------------------------------- VIEW --------------------------------------------
materialIcon : List (Attribute msg) -> String -> Html msg
materialIcon clss s = div ([class "material-icons"] ++ clss) [ text s ]




brightnessIconOf : BrightnessMode -> Html msg
brightnessIconOf bmode = case bmode of
  Dark -> materialIcon [] "brightness_2"
  Light -> materialIcon [] "wb_sunny"
  Blue -> materialIcon [] "brightness_4"




viewBrightnessBtn : Model -> Html Msg
viewBrightnessBtn model =
  if model.config.isRunnable
  then button
    [ id "brightness-btn", onClick ToggleBrightnessMode, class "noselect", Attr.disabled (not model.brightnessModeBtnEnabled) ]
    [ brightnessIconOf model.brightnessMode ]
  else div [ ] [ ]




viewRunBtn : Model -> Html Msg
viewRunBtn model =
  if model.config.isRunnable
  then button
    [ id "run-btn", class "noselect", onClick Run ]
    [ case model.interpreterMsg of
      InterpreterMsg.Ignore -> materialIcon [] "play_arrow_outline"
      _ -> materialIcon [] "stop_outline" ]
  else div [] []




brightnessModeAsClass : BrightnessMode -> String
brightnessModeAsClass bmode = case bmode of
  Dark -> "brightness-dark"
  Light -> "brightness-light"
  Blue -> "brightness-blue"



view : Model -> Html Msg
view model = div [class "editor-wrapper"]
    [ div [ class ("brightness-mode display-none " ++ brightnessModeAsClass model.brightnessMode) ] []
    , viewRunBtn model
    , viewBrightnessBtn model
    , fieldset [ class "editor" ]
    [ textarea
        [ id "code-input"
        , class "input"
        , spellcheck False
        , onFocus ResetInterpreterMsg
        , onInput UpdateCode
        , readonly (not model.config.isEditable)
        , value model.code
        , placeholder "write your code here..." ] []
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
    if model.interpreterMsg == InterpreterMsg.Ignore then
      let interpreterRes
            = Interpreter.interpret "" (model.stdLibCode ++ "\n\n" ++ model.code)
      in ( { model | interpreterMsg = interpreterRes }
          , Cmd.none)
    else update ResetInterpreterMsg model


  UpdateCode code ->
    let highlightedCode = Highlighting.highlight
          model.syntax
          code
    in ( { model | codeHighlighted = highlightedCode
        , code = code }
        , if model.config.neverSave
        then Cmd.none
        else SaveCode.save code )



  ResetInterpreterMsg ->
    ({model | interpreterMsg = InterpreterMsg.empty }
    , Cmd.none)



  ToggleBrightnessMode ->
    let newModel = { model | brightnessMode = toggleBrightness model.brightnessMode, brightnessModeBtnEnabled = False }
    in ( newModel
    , onBrightnessChange <| brightnessModeAsClass <| newModel.brightnessMode
    )
  

  BrightnessModeBtnReEnable ->
    ( { model | brightnessModeBtnEnabled = True
      }
    , Cmd.none
    )





toggleBrightness : BrightnessMode -> BrightnessMode
toggleBrightness bmode = case bmode of
  Dark -> Light
  Light -> Blue
  Blue -> Dark



------------------------------------------- INIT -------------------------------------------
type alias InitFlags
 ={ code : String
  , conf : Config
  , stdLibCode : String
  , brightnessModeS : String
  }




init : InitFlags -> (Model, Cmd Msg)
init flgs = update (UpdateCode flgs.code)
  ({ code = ""
  ,  codeHighlighted = div [] []
  ,  syntax = Highlighting.syntax
  ,  interpreterMsg = InterpreterMsg.empty
  ,  config = flgs.conf
  ,  stdLibCode = flgs.stdLibCode
  ,  brightnessMode = readBrMode flgs.brightnessModeS
  ,  brightnessModeBtnEnabled = True
  })




readBrMode : String -> BrightnessMode
readBrMode s = case s of
  "brightness-blue" -> Blue
  "brightness-dark" -> Dark
  "brightness-light" -> Light
  _ -> Light



------------------------------------------- MAIN -------------------------------------------
main : Program InitFlags Model Msg
main = Browser.element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


port onBrightnessBtnReEnable : (Int -> msg) -> Sub msg

subscriptions :  model -> Sub Msg
subscriptions _ = Sub.batch
  [ onBrightnessBtnReEnable (\_ -> BrightnessModeBtnReEnable)
  ]