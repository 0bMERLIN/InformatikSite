type reply = {
  jsonString : string,
  responseCode : int,
  contentType : string
}

type path = string;
type body = string;

module type ServerS = {
  type model

  let port : int
  let on_get : path => model => (reply, model)
  let on_post : path => body => model => model
  let report : model => unit
  let init : model
  let configPath : string
}