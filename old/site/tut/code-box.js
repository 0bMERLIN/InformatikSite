let initCodeBox = codeBoxID => code => {
    // configure app
    let config =
        { neverSave: true
        , isEditable: false
        , isRunnable: false }
    
    
    // create app
    let app = Elm.Main.init({
        node: document.getElementById(codeBoxID),
        flags: [code, config, ""]
    })
}