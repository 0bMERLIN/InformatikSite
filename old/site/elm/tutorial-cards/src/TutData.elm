module TutData exposing (..)

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


----------------------------------------- TYPES -----------------------------------------
type alias Card msg =
  { title : String
  , code : Html msg
  , explanation : String
  }




----------------------------------------- DATA -----------------------------------------
tutcards : List (Card msg)
tutcards =
  [ tutcard0
  , tutcard1
  , tutcard2
  , tutcard3
  , tutcard4
  , tutcard5
  ]


tutcard0 : Card msg
tutcard0 =
  { title = "Programmstruktur"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def x = 10
  def y = 20
  def z = x + y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
In diesem Modul werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welche die Summe von 'x' und 'y' enthält."""
  }


tutcard1 : Card msg
tutcard1 =
  { title = "Funktionen"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def x = 10
  def y = 20
  def z = x + y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
In diesem Modul werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welche die Summe von 'x' und 'y' enthält."""
  }


tutcard2 : Card msg
tutcard2 =
  { title = "Funktionen"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def x = 10
  def y = 20
  def z = x + y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
In diesem Modul werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welche die Summe von 'x' und 'y' enthält."""
  }


tutcard3 : Card msg
tutcard3 =
  { title = "Funktionen"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def x = 10
  def y = 20
  def z = x + y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
In diesem Modul werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welche die Summe von 'x' und 'y' enthält."""
  }

tutcard4 : Card msg
tutcard4 =
  { title = "Funktionen"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def x = 10
  def y = 20
  def z = x + y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
In diesem Modul werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welche die Summe von 'x' und 'y' enthält."""
  }


tutcard5 : Card msg
tutcard5 =
  { title = "Funktionen"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def x = 10
  def y = 20
  def z = x + y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
In diesem Modul werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welche die Summe von 'x' und 'y' enthält."""
  }