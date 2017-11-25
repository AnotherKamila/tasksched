#!/usr/bin/env node

const body_parser = require('body-parser')
const cors        = require('cors')
const express     = require('express')
const proxy       = require('express-http-proxy');
const {spawn}     = require('child_process');

const PORT          = process.env.PORT || 5000
const TASK          = 'task'
const TASKOPTS      = ['rc.gc=off']
const DEVSERVER     = 'http://localhost:8000' // Proxies this from /dev (and allows CORS)
const ALWAYS_FILTER = '(+PENDING or (+WAITING +SCHEDULED))'

const api = express()
api.use(body_parser.json())
api.use(cors({origin: DEVSERVER}))

api.get('/', (req, res) => {
    export_tasks(req.query.filter, {
        on_data: (chunk) => res.write(chunk),
        on_exit: (c, s)  => res.end(c || s ? format_status(c, s) : '')
    })
})

api.post('/', (req, res) => {
    import_task(req.body, {on_exit: (c, s) => res.end(format_status(c, s))})
})

const server = express()
server.use(express.static('.'))
server.use('/api', api)
server.use('/dev', proxy(DEVSERVER))

server.listen(PORT, () => console.log(`listening on port ${PORT}`))


const export_tasks = (filter, {on_data, on_exit}) => {
    const f = `${ALWAYS_FILTER} ${filter || ''}`
    const tw = spawn(TASK, TASKOPTS.concat(['rc.json.array=on', f, 'export']))
    tw.stdout.on('data', on_data)
    tw.on('exit', on_exit)
}

const import_task = (task, {on_exit}) => {
    // Not using task import because it eats values not present in the imported data and we REALLY DON'T want that.

    if (!task.uuid || task.uuid.length != 36) return on_exit(0, "UUID not present or invalid")
    let cmd = []
    if (task.done) {
        cmd = [task.uuid, 'done']
    } else {
        cmd = [task.uuid, 'mod']
        for (var attr in task) if (task.hasOwnProperty(attr) && attr != 'uuid') cmd.push(attr+':'+(task[attr] || ''))
    }
    const tw = spawn(TASK, TASKOPTS.concat(cmd))
    console.log("[import] running command: task " + cmd.join(' '))
    tw.on('exit', on_exit)
}

const format_status = (code, status) => `{"status": "${status || code || ''}"}`
