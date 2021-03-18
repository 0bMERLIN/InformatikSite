open Framework.ServerFramework


module Shortcuts_decoderT = {
  type shortcut = {
    name : string,
    query : list(string)
  }
  type shortcuts = list(shortcut)
  type t = shortcuts
  
} module Shortcuts_decoder = Decoder(Shortcuts_decoderT)


module New_cmd_decoderT = {
  type t = { cmd : string }
} module New_cmd_decoder = Decoder(New_cmd_decoderT)


module Chat_hist_decoderT = {
  type t = { chatHistChange : string }
} module Chat_hist_decoder = Decoder(Chat_hist_decoderT)


module Server : ServerS = {
  open Server_helpers
  open Shortcuts_decoderT

  type model = {
    chatHist : string,
    cmdQueue: list(string),
    cmdShortcuts: shortcuts,
    cmdShortcutsStr: string
  }

  let port = 80
  let shortcutsJSON_Text = Node_fs.readFileAsUtf8Sync("../shortcuts.json")
  let shortcuts = Shortcuts_decoder.decode(shortcutsJSON_Text)
  let init = { chatHist : "", cmdQueue : [], cmdShortcuts : shortcuts, cmdShortcutsStr : shortcutsJSON_Text }
  let configPath = "../config.json"
  
  let report = _ => ()
  
  let on_post = (path, body, model) => switch (path) {
    | "/post/chat-hist" => {
      let chatHistChange = Chat_hist_decoder.decode(body).chatHistChange;
      { ...model, chatHist : model.chatHist ++ chatHistChange }
    }
    | "/post/new-cmd" => {
      let newCmd = New_cmd_decoder.decode(body).cmd;
      { ...model, cmdQueue : List.cons(newCmd, model.cmdQueue) }
    }

    | _ => model
  }

  let encodeList : ('a => string) => list('a) => string = (encodeElem, list) =>
    "[" ++ List.fold_left((a, b) => encodeElem(a) ++ "," ++ encodeElem(b), List.hd(list), List.tl(list)) ++ "]"

  let on_get = (path, model) => switch (path) {
    | "/get/new-cmds" => (jsonResponse("{ \"data\" : " ++ encodeList(str => "\"" ++ str ++ "\"", model.cmdQueue) ++ "}"), model)

    | "/get/chat-hist" => (jsonResponse("{ \"data\" : " ++ "\"" ++ model.chatHist ++ "\"" ++ "}"), model)

    | "/get/cmd-shortcuts" => (jsonResponse("{ \"data\" : " ++ model.cmdShortcutsStr ++ "}"), model)

    | _ => respFromRequestedFile(path, configPath, model)
  }
}

module Server_runner = Server_runner(Server)
let _ = Server_runner.run ()