let stdLib =
`
mod List
  def reduce = fn f l => match l with
      [h]    => h
    | {h, t} => f h (reduce f t)
  end

  def concat = fn a b => match {a, b} with
      {{}, b} => b
    | {a, {}} => a
    | {{h, t}, b} => { h, concat t b }
  end

  def head = fn l => match l with
    {h, t} => h
  end

  def tail = fn l => match l with
    {h, t} => t
  end

  def atIndex = fn n xs => match n with
      0 => head xs
    | _ => atIndex (n - 1) (tail xs)
  end
end

mod Ctrl
  def if = fn c t f => match c with
      :true  => t {}
    | :false => f {}
  end
end

mod String
  def concat = fn a b => match {a, b} with
      {"", b} => b
    | {a, ""} => a
    | {{h, t}, b} => { h, concat t b }
  end

  def concatL = fn ss =>
    List.reduce concat ss
end

mod Func
  def flip = fn f a b => f b a

  def const = fn a b => a

  def id = fn x => x
end

mod Bool
  def or = fn a b => match {a, b} with
      {:true, _} => :true
    | {_, :true} => :true
    | {_, _}     => :false
  end
end

mod Pair
  def fst = fn p => match p with
    {a, b} => a
  end

  def snd = fn p => match p with
    {a, b} => b
  end
end

mod Number
  def pow = fn a b => match b with
      0 => 1
    | 1 => a
    | _ => a * (pow a (b - 1))
  end

  def show = fn x => stringof x

  def eq = fn a b => Ctrl.if (Bool.or (a < b) (a > b))
    (Func.const :false)
    (Func.const :true)
end

mod IO
  def print = fn s => match s with
      "" => {}
    | { h , t } => let _ = write h in print t
  end

  def println = fn s => print (String.concat s "\n")
end
`

let main = () => {
    // configure app
    let config =
        { neverSave: false
        , isEditable: true
        , isRunnable: true }

    // get last saved state
    let storedState = localStorage.getItem('editor-state-backup')
    let initState = storedState == null ? ["", config, stdLib] : [storedState, config, stdLib]

    // create app
    let app = Elm.Main.init({
        node: document.getElementById("elm-app"),
        flags: initState
    })

    // subscribe to app / set callbacks for ports
    app.ports.save.subscribe(function(code) {
        localStorage.setItem('editor-state-backup', code)
    })
}