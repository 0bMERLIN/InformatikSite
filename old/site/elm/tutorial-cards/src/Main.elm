module Main exposing (main)


-- HTML imports / UI stuff
import Browser
import Html                    exposing (..)
import Html.Events             exposing (onInput, onClick, onFocus)
import Html.Attributes as Attr exposing (..)
import Html.Parser


-- data
import TutData


------------------------------------------- MODEL -------------------------------------------
type alias Model =
    { cards : List (TutData.Card Msg)
    }




--------------------------------------------- MSG -------------------------------------------
type Msg
    = Init



------------------------------------------- VIEW --------------------------------------------
viewCard : TutData.Card Msg -> Html Msg
viewCard c = div [class "card"]
  [ div [class "heading"] [text c.title]
  , div [class "explanation"] [text c.explanation]
  , div [class "code"] [c.code]
  ]


view : Model -> Html Msg
view model = div [id "cards-container", class "cards-container"] [ div [class "cards"] <| List.map viewCard model.cards ]




--------------------------------------------- UPDATE ----------------------------------------
update : Msg -> Model -> (Model, Cmd msg)
update msg model = case msg of
    Init ->
      ( model
      , Cmd.none
      )




------------------------------------------- INIT --------------------------------------------
init : () -> (Model, Cmd Msg)
init _ = update Init <|
  { cards = TutData.tutcards
  }




------------------------------------------- MAIN -------------------------------------------
main : Program () Model Msg
main = Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }