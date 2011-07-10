http = require 'http'

request = exports.request = (method, path, body, callback) ->
  if match = path.match(/^(https?):\/\/([^\/]+?)(\/.+)/)
    headers = { Host: match[2], 'Content-Type': 'application/json', 'User-Agent': ua }
    port = if match[1] == 'https' then 443 else 80
    client = http.createClient(port, match[2], port == 443)
    path = match[3]

    if typeof(body) is 'function' and not callback
      callback = body
      body = null

    if method is 'POST' and body
      body = JSON.stringify body if typeof body isnt 'string'
      headers['Content-Length'] = body.length

    req = client.request(method, path, headers)

    req.on 'response', (response) ->
      if response.statusCode is 200
        data = ''
        response.setEncoding('utf8')
        response.on 'data', (chunk) ->
          data += chunk
        response.on 'end', ->
          if callback
            try
              body = JSON.parse(data)
            catch e
              body = data
            callback body
      else if response.statusCode is 302
        request(method, path, body, callback)
      else
        console.log "#{response.statusCode}: #{path}"
        response.setEncoding('utf8')
        response.on 'data', (chunk) ->
          console.log chunk.toString()
        process.exit(1)
  req.write(body) if method is 'POST' and body
  req.end()


