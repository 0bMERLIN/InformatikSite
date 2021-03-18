open Framework.ServerFramework


module Server : ServerS = {
  open Server_helpers

  type model = | Model

  let port = 80
  let init = Model
  let configPath = "../config.json"
  
  let report = _ => ()
  
  let on_post = (_, _, model) => model

  let on_get = (path, model) => respFromRequestedFile(path, configPath, model)
}

module Server_runner = Server_runner(Server)
let _ = Server_runner.run ()