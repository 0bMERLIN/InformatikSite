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
  """mod Start
  -- einfach ein objekt mit herberts accountdaten
  def herbertsInfos =
  { :name, "herbert",
    :nachname, "herbertius",
    :passwort, "herberti123"
  }

  -- wir vergleichen herbertsInfos mit einem Pattern,
  -- also einem Muster oder einer Schablone.
  -- der Unterstrich _ bedeutet "ignoriere das hier;
  -- hier ist etwas, aber ist mir egal was".
  -- wenn man einen Wert wie hier ein symbol
  -- in einem Pattern schreibt, dann
  -- heißt das: vergleiche den wert hier
  -- mit dem wert der im objekt an dieser stelle ist.
  -- so stellen wir sicher, das wir auch
  -- ein objekt haben, das herberts daten
  -- enthält, also sein passwort usw.
  -- das 'p' ganz am ende, vor dem =>
  -- bedeutet, dass wir den Wert in herbertsInfos
  -- an dieser Position in die variable p speichern
  -- p sollte wenn wir es nach dem => nutzen
  -- "herberti123" enthalten
  def nurPasswort = match herbertsInfos with
    {:name, _, :nachname, _, :passwort, p}
      => p -- p ist hier das ergebnis des match
           -- statements und auch folglich der wert
           -- in nurPassword
  end

  def x = 1

  -- man kann auch zahlen im match statement vergleichen
  -- außerdem kann man auch mehrere Patterns haben,
  -- gegen die man vergleicht. wenn ein pattern passt,
  -- dann wird der diesem zugeordnete rückgabewert aus-
  -- gewählt. die anderen werden garnicht erst berechnet
  def einsOderZwei = match x with
      1 => "ist eins"
    | 2 => "ist zwei"
    | _ => "ist irgendetwas anderes"
  end
end;"""
  , explanation = ""
  }

tutcard5 : Card msg
tutcard5 =
  { title = "Extra Infos zu Listen und Strings"
  , code = Highlighting.highlight Highlighting.syntax
    """mod Start
  def liste = [1, 2, 3, 4, 5]

  -- so ist List.head auch implementiert
  def erstesElement = match liste with
    -- eine lehre list ist ein lehres objekt
    {} => "liste ist leer"

    -- listen sind objekte die
    -- jeweils das element und das nächste
    -- objekt mit einem element etc. haben
    {}
  end
end;"""
  , explanation =
  """Zwar ist Dot eigentlich nur eine Art
  Spielzeug und ist auch einfach zu langsam,
  um ordentliche Sachen zu machen. Trotzdem
  lassen sich so einige Algorithmen in Dot
  ausprobieren. Dafür ist die Standard Library da,
  in der alle möglichen Funktionen und Algorithmen
  geschrieben sind. Hier ist eine Liste mit allen
  StdLib-Funktionen:"""
  }