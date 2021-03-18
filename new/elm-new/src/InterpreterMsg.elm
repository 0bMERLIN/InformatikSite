module InterpreterMsg exposing (..)


-- highlighter
import Highlighting exposing (toHtml)
import Highlighting exposing (formatForDiv)

-- html
import Html.Attributes exposing (class)
import Html            exposing (Html, div)




------------------------------------ TYPES ------------------------------------
type InterpreterMsg
  = Error String
  | Output String
  | Ignore




------------------------------------ FUNCTIONS --------------------------------
empty : InterpreterMsg
empty = Ignore



showHtml : InterpreterMsg -> Html msg
showHtml msg = case msg of
    Error s -> div
      [ class "popup-msg err-msg noselect" ]
      [ toHtml (formatForDiv s) ]
    Output s-> div
      [ class "popup-msg out-msg noselect" ]
      [ toHtml (formatForDiv s) ]
    Ignore  -> div
      [ class "popup-msg remove-msg" ]
      [ ]