module Node_interface = {
  let run_http_server = [%raw {|

(on_post, on_get, init, port, report, defaultRedirect) => {
  const http = require('http')
  const readable = require('stream').readable;

  
  let currModel = init

  let serverFn = (req, res) => {
    handle(req, res, currModel, handlerCallback)
  }

  let handlerCallback = model => {
    currModel = model
    report (model)
  }

  let handle = (req, res, model, handlerCallback) => {
    switch (req.method) {
      case "post": case "POST":
        return handlePost(req, res, model, handlerCallback)
      case "get": case "GET":
        return handleGet(req, res, model, handlerCallback)
    }
  }

  let readJSONPost = (req, res, callback) => {
    let body = '';
    req.on('data', chunk => { body += chunk.toString() })
    req.on('end', () => { callback(body); res.end('ok') })
  }

  let handlePost = (req, res, model, handlerCallback) => {
    readJSONPost(req, res, jsonDataStr => {
      let newModel = on_post(req.url, jsonDataStr, model)
      handlerCallback(newModel)
    })
  }

  let streamFromString = raw => {
    const Readable = require('stream').Readable;
    const s = new Readable();
    s._read = function noop() {};
    s.push(raw);
    s.push(null);
    return s;
  }

  let handleGet = (req, res, model, handlerCallback) => {
    let [response, newModel] = on_get (req.url, model)

    res.writeHead(response.responseCode, { 'content-type': response.contentType })
    res.end(response.jsonString)

    handlerCallback(newModel)
  }

  let redirect = (response, newUrl) => {
    response.writeHead(302 , { "Location" : newUrl } )
    response.end()
  }
  
  let server = http.createServer(serverFn)
  server.listen(port)

  console.log(`Ready on port ${port}`)
}
  |}]

  let clear_console : unit => unit = [%raw {|
    () => console.clear()
  |}]

  let clear_then_print_int = n => { clear_console (); print_int (n) }
}