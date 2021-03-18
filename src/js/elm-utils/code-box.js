let initCodeBox = codeBoxID => code => {
    // configure app
    let config =
        { neverSave: true
        , isEditable: false
        , isRunnable: false }
    
    let flgs
      ={ code: code
       , conf: config
       , stdLibCode : ""
       , brightnessModeS : ""
       }
    
    // create app
    let app = Elm.Editor.init({
        node: document.getElementById(codeBoxID),
        flags: flgs
    })
}