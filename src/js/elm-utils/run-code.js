let stdLib =
`
mod List
  def reduce = fn f l => match l with
      [h]    => h
    | {h, t} => f h (reduce f t)
  end

  def map = fn f xs => match xs with
    [] => []
  | {h, t} => {f h, map f t}
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

  def atIndex = fn n xs =>
    match { n, xs } with
      { 0, {hd, _} } => {:just, hd}
      | {_, {_, tl}} => atIndex (n - 1) tl
      | {_, {}} => {:nothing}
    end

  def transformNth = fn idx f l =>
    match l with
      [] => []
      | {hd, tl} =>
        match idx with
          0 => {f hd, tl}
          | _ => {hd, transformNth (idx - 1) f tl}
        end
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

  def and = fn a b => match {a, b} with
    {:true, :true} => :true
    | _ => :false
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
    | _ => print "type error:\n'IO.print' can only print strings"
  end

  def println = fn s => print (String.concat s "\n")
end

mod BrainfuckToJS
  def compile = fn progStr =>
    match progStr with
        {'+', tl} => {"mem[mp] += 1;\n", compile tl}
      | {'-', tl} => {"mem[mp] -= 1;\n", compile tl}
      | {'>', tl} => {"mp++;\n", compile tl}
      | {'<', tl} => {"mp--;\n", compile tl}
      | {'[', tl} =>
        match compileLoop tl with
          {js, rest} => String.concatL {js, rest}
        end
      | {} => {}
    end
end
`

let saveBrightness = b => localStorage.setItem("brightness-mode", b)

let convNull = (defaultV, nl) => (nl === null)
  ? defaultV
  : nl

let CodeEditor_main = () => {
    // configure app
    let config =
        { neverSave: false
        , isEditable: true
        , isRunnable: true }

    // get last saved state
    let storedState = localStorage.getItem('editor-state-backup')
    let storedBMode = localStorage.getItem("brightness-mode")
    let flgs
      ={ code: convNull("", storedState)
       , conf: config
       , stdLibCode : stdLib
       , brightnessModeS : convNull("", storedBMode)
       }

    // create app
    let app = Elm.Editor.init( {
        node: document.getElementById("elm-app"),
        flags: flgs
    } )

    // subscribe to app / set callbacks for ports
    app.ports.save.subscribe( code => localStorage.setItem('editor-state-backup', code) )
    app.ports.onBrightnessChange
      .subscribe( newBrightnessMode =>
        { saveBrightness(newBrightnessMode);

          let btnTimeout = 300
          // reenable button after some time
          setTimeout(_ => app.ports.onBrightnessBtnReEnable.send(0), btnTimeout)
          // wait some time before updating the style to let saveBrightness finish
          setTimeout(_ => updateStyleVars(), btnTimeout / 2)
      } )
}