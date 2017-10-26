#!/usr/bin/env node

const http = require('http')
const url  = require('url');
const {spawn} = require('child_process');

const PORT = 5000
const ALLOW_CORS = "http://localhost:8000"
const ALWAYS_FILTER="+READY"

const export_tasks = (filter, {on_data, on_exit}) => {
    const f = `${ALWAYS_FILTER} ${filter || ''}`
    const tw = spawn('task', [f, 'export', 'rc.json.array=on'])
    tw.stdout.on('data', on_data)
    tw.on('exit', on_exit)
}

const import_tasks = ({on_exit}) => {
    const tw = spawn('task', ['import', 'rc.json.array=on', 'rc.recurrence.confirmation=no'])
    tw.on('exit', on_exit)
    return { on_data: (c) => tw.stdin.write(c), on_end: () => tw.stdin.end() }
}

const send_err = (code, signal) => signal || code ? `{"error": "${signal || code}"}` : ''

const request_handler = (request, response) => {
    response.setHeader('Access-Control-Allow-Origin', ALLOW_CORS)
    switch (request.method) {
        case "GET":
            export_tasks(url.parse(request.url, true).query.filter, {
                on_data: (chunk) => response.write(chunk),
                on_exit: (c, s)  => response.end(send_err(c, s))
            })
            break;
        case "POST":
            const {on_data, on_end} = import_tasks({on_exit: (c, s) => response.end(send_err(c, s))})
            request.on('data', on_data)
            request.on('end', on_end)
            break;
        default:
            response.statusCode = 405 // method not allowed
            response.end()
    }
}

const server = http.createServer(request_handler)

server.listen(PORT, (err) => {
    if (err) console.log(err)
    else console.log(`listening on ${PORT}`)
})
