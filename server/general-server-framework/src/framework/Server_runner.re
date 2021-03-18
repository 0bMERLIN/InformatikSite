open Server_sig
open JSON_decoder

module Config_decoderT = {
  type baseDir = {
    path : string,
    cType : string
  }
  type config = {
    baseDirs : array(baseDir),
    defaultRedirect : string
  }
  type t = config
  let constructBaseDir = (basePath, cType, name) =>
    { path: basePath ++ "/" ++ name
    , cType: cType
    }
} module Config_decoder = Decoder(Config_decoderT)

module Server_runner = (S : ServerS) => {
  open Node_interface

  let rec last = xs => switch xs {
    | [x] => Some(x)
    | [_,...rest] => last(rest)
    | [] => None
  };

  let run = () => {
    let config = Config_decoder.decode(Node_fs.readFileAsUtf8Sync(S.configPath))
    
    Node_interface.run_http_server
    ( S.on_post
    , S.on_get
    , S.init
    , S.port
    , S.report
    , config.defaultRedirect )
  }
}