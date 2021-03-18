module Responses = {
  include Server_sig

  open Server_runner
  open Node_fs
  open Config_decoderT
  
  let htmlResponse_200 = markup => {
    jsonString : markup,
    responseCode : 200,
    contentType : "text/html"
  }

  let response_200 = (s, cType) => {
    jsonString : s,
    responseCode : 200,
    contentType : cType
  }

  let emptyResponse_404 = {
    jsonString : "",
    responseCode : 404,
    contentType : "application/json"
  }

  let baseDirResponse_200 = selectedFileName =>
    ( response_200(readFileAsUtf8Sync(selectedFileName.path)
    , selectedFileName.cType))
  
  let jsonResponse = data => response_200(data, "application/json")
}

module File_readers = {
  open Server_runner
  open List
  open Node_fs
  open Config_decoderT
  open Responses

  let getAvailableFileNames = baseDir => {
    let nameIsFileNotDir = name => String.contains(name, '.')
    let availFileNames = filter(nameIsFileNotDir, Array.to_list(readdirSync(baseDir.path)))
    let makeBaseDir = constructBaseDir(baseDir.path, baseDir.cType)
    map(makeBaseDir, availFileNames)
  }

  let comparePaths = (urlPath, relPath) =>
    Js.String.indexOf(urlPath, "/" ++ relPath) != -1
  
  let respFromRequestedFile = (path, configPath, model) => {
    let config = Config_decoder.decode(readFileAsUtf8Sync(configPath))
    let baseDirs = Array.to_list(config.baseDirs)
    let availableNames = concat(map(getAvailableFileNames, baseDirs))
    switch (filter(nameData => comparePaths(path, nameData.path), availableNames)) {
    | [ selectedFileName, ..._ ] => (baseDirResponse_200(selectedFileName), model)
    | [] => (emptyResponse_404, model)
    }
  }
}

module Server_helpers = {
  include Responses
  include File_readers
}