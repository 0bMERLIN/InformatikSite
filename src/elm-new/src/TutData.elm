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
  ]


tutcard0 : Card msg
tutcard0 =
  { title = "Programmstruktur"
  , code = Highlighting.highlight Highlighting.syntax
  """mod ModulA
  def x = 10
  def y = 20
end

mod Start
  def z = ModulA.x + ModulA.y
end;"""
  , explanation =
  """Ein Programm in Dot besteht immer aus
modulen, die einzelne Definitionen enthalten. Module
fangen mit dem Wort 'mod' an und hören bei 'end' auf.
Man kann ihre Inhalte aus anderen Modulen auch mit
'.' nutzen.
Nach dem letzten Modul im Programm steht immer ein ';'.
In diesen Modulen werden drei Variablen definiert:
'x' mit einem Wert von zehn, 'y' mit einem wert von 20
und 'z', welches die Summe von 'x' und 'y' enthält."""
  }


tutcard1 : Card msg
tutcard1 =
  { title = "Funktionen"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  -- das hier ist ein Kommentar

  -- funktion, die x als input
  -- nimmt und x + 1 zurückgibt
  def plusEins = fn x => x + 1

  -- funktion, die eine andere
  -- funktion f und einen
  -- wert x als input hat und
  -- das ergebnis von f(x) zurückgibt.
  def anwenden = fn f x => f x

  def n = anwenden plusEins 1
  -- ^ sollte 2 sein
end;"""
  , explanation =
  """In Dot gibt es auch Funktionen.
  Diese nehmen jeweils einige Inputs (oder parameter)
  und produzieren ein Ergebnis.
  Funktionen sind auch Werte, genauso wie z.B. Zahlen.
  Das heißt, dass eine Funktion z.B.
  eine andere Funktion als Input nehmen und auch
  eine andere Funktion zurückgeben kann."""
  }


tutcard2 : Card msg
tutcard2 =
  { title = "Andere Werte"
  , code = Highlighting.highlight Highlighting.syntax
  """mod Start
  def str = "das hier ist einfach nur text (ein string).
    \n bedeutet dasselbe wie <br> in html"
  def n = 20 -- eine zahl

  -- symbole sind wie strings,
  -- aber dafür gedacht bestimmte
  -- fälle zu kennzeichnen.
  -- hier zeigt es, dass etwas
  -- zutrifft.
  def symboleSindToll = :wahr

  -- objekt
  def herbertsInfos =
  { :name, "herbert",
    :nachname, "herbertius",
    :passwort, "herberti123"
  }

  -- liste
  def l = [1, 2, 3, 4]
end;"""
  , explanation =
  """Es gibt verschiedene Datenstrukturen.
  Es gibt einfache Strukturen wie Zahlen,
  Strings (Text) und Symbole. Man kann
  auch Listen und Objekte nutzen.
  Objekte sind dafür da immer gleich
  viele Sachen zu beinhalten. Zum
  Beispiel Benutzerdaten.
  In Listen kann man viele
  ähnliche Datenstrukturen
  speichern. Also z.B. eine liste
  von Zahlen.
  """
  }


tutcard3 : Card msg
tutcard3 =
  { title = "Pattern matching"
  , code = Highlighting.highlight Highlighting.syntax
  """pattern matching:

mod Start
  def infos =
  { :name, "herbert",
    :nachname, "herbertius",
    :passwort, "herberti123"
  }

  -- Ein Match Statement gleicht einen Wert mit
  -- Mustern (oder patterns) ab. Wenn ein Pattern zum
  -- Wert passt, dann wird das Stück vom Programm,
  -- das nach dem '=>' steht ausgeführt. Match Statements
  -- fangen mit dem Wort 'match' an, danach folgt
  -- der Wert mit dem verglichen wird. Nach 'with'
  -- folgen die Patterns, die jeweils mit '|' abgetrennt
  -- werden und das ganze wird mit dem Wort 'end' abgeschlossen
  def _ = match 1 + 1 with
      2 => IO.print "alles normal!"
    | 3 => IO.print "?"
  end
  
  -- hier werden herberts accountdaten
  -- abgeglichen, um seinen nachnamen
  -- herauszufinden (_ bedeutet ignorieren,
  -- ein klein geschriebener
  -- variablenname bedeutet 'was hier im objekt
  -- ist mit diesem namen abspeichern')
  def _ = match infos with
    { :name, _, :nachname, name, :passwort, _ } =>
      IO.print (String.concat "herberts nachname:  " name)
  end
  
end;"""
  , explanation = ""
  }