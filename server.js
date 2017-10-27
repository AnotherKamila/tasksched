#!/usr/bin/env node

const http = require('http')
const url  = require('url');
const {spawn} = require('child_process');

const PORT = 5000
// const ALLOW_CORS = '*'
const ALLOW_CORS = 'http://localhost:8000'
const ALWAYS_FILTER='+PENDING'

const export_tasks = (filter, {on_data, on_exit}) => {
    const f = `${ALWAYS_FILTER} ${filter || ''}`
    const tw = spawn('task', [f, 'export', 'rc.json.array=on'])
    tw.stdout.on('data', on_data)
    tw.on('exit', on_exit)
}

const import_task = ({on_exit}) => {
    // Not using task import because it eats values not present in the imported data and we REALLY DON'T want that.
    let in_buf = ''
    let c = 0, s = null
    const do_it = () => {
        const task = JSON.parse(in_buf)
        if (!task.uuid || task.uuid.length != 36) return on_exit(0, "UUID not present or invalid")
        const cmd = [task.uuid, 'mod', 'scheduled:'+(task.scheduled || '')]
        const tw = spawn('task', cmd)
        console.log("[import] running command: task " + cmd.join(' '))
        tw.on('exit', on_exit)
    }

    return { on_data: (c) => in_buf += c, on_end: do_it }
}

const send_status = (code, status) => `{"status": "${status || code || ''}"}`

const request_handler = (request, response) => {
    response.setHeader('Access-Control-Allow-Origin',  ALLOW_CORS)
    switch (request.method) {
        case 'GET':
            export_tasks(url.parse(request.url, true).query.filter, {
                on_data: (chunk) => response.write(chunk),
                on_exit: (c, s)  => response.end(c || s ? send_status(c, s) : '')
            })
            break;
        case 'POST':
            const {on_data, on_end} = import_task({on_exit: (c, s) => response.end(send_status(c, s))})
            request.on('data', on_data)
            request.on('end', on_end)
            break;
        case 'OPTIONS':
            response.setHeader('Allow', 'GET,POST,OPTIONS')
            response.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
            response.setHeader('Access-Control-Allow-Headers', 'Content-Type, User-Agent, Cache-Control');
            response.end()
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
