port module BrightnessPort exposing
  ( onBrightnessChange
  , BrightnessMode(..)
  )


type BrightnessMode
  = Dark
  | Light
  | Blue


port onBrightnessChange : String -> Cmd msg