#!/usr/bin/env node

const body_parser = require('body-parser')
const cors        = require('cors')
const express     = require('express')
const proxy       = require('express-http-proxy');
const {spawn}     = require('child_process');
const readline    = require('readline')

const PORT          = process.env.PORT || 5000
const TASK          = 'task'
const TASKOPTS      = ['rc.gc=off']
const DEVSERVER     = 'http://localhost:8000' // Proxies this from /dev (and allows CORS)

const api = express()
api.use(body_parser.json())
api.use(cors({origin: DEVSERVER}))

api.get('/tasks', (req, res) => {
    export_filtered_tasks(req.query.filter, {
        on_data: (chunk) => res.write(chunk),
        on_exit: (c, s)  => res.end(c || s ? format_status(c, s) : '')
    })
})

api.post('/tasks', (req, res) => {
    import_task(req.body, {on_exit: (c, s) => res.end(format_status(c, s))})
})

api.get('/timew', (req, res) => {
    check_timew({
        on_exit: (timew_present) => res.json({enabled: timew_present})
    })
})

const server = express()
server.use(express.static('.'))
server.use('/api', api)
server.use('/dev', proxy(DEVSERVER))

server.listen(PORT, () => console.log(`listening on port ${PORT}`))


const read_active_filter = ({on_filter}) => {
    // Step 1: See if there is an active context
    const tw_context = readline.createInterface({
        input: spawn_tw(['_get', 'rc.context']).stdout
    })
    let context = ''
    tw_context.on('line', (line) => {
        if (!context && line) context = line
    })
    tw_context.on('close', (line) => {
        // Step 2: If there is an active context, get its filter.
        //         If not, get the filter for the "next" report.
        let cmd = ['_get']
        if (context)
            cmd.push('rc.context.' + context)
        else
            cmd.push('rc.report.next.filter')

        const tw_filter = readline.createInterface({
            input: spawn_tw(cmd).stdout
        })

        let filter = ''
        tw_filter.on('line', (line) => {
            if (!filter && line) filter = line
        })
        tw_filter.on('close', (line) => {
            // Execute callback with obtained filter
            on_filter(filter)
        })
    })
}


const export_filtered_tasks = (filter, callbacks) => {
    // If a filter is already passed, don't bother checking taskwarrior's
    if (filter)
        return export_tasks(filter, callbacks)

    read_active_filter({on_filter: (f) => export_tasks(f, callbacks)})
}


const export_tasks = (filter, {on_data, on_exit}) => {
    let cmd = ['rc.json.array=on']
    if (filter)
        cmd.push(filter)
    cmd.push('export')
    const tw = spawn_tw(cmd)
    tw.stdout.on('data', on_data)
    tw.on('exit', on_exit)
}

const import_task = ({command, task}, {on_exit}) => {
    // Not using task import because it eats values not present in the imported data and we REALLY DON'T want that.

    if (!task.uuid || task.uuid.length != 36) return on_exit(0, "UUID not present or invalid")
    let cmd = [task.uuid, 'rc.recurrence.confirmation=no']

    // Check command is in whitelist
    if (!['mod', 'done', 'start', 'stop'].includes(command))
        return on_exit(0, "Unsupported command");

    cmd.push(command);

    // Special case for modified attributes
    if (command == 'mod') {
        for (var attr in task) if (task.hasOwnProperty(attr) && attr != 'uuid') cmd.push(attr+':'+(task[attr] || ''))
    }

    const tw = spawn_tw(cmd)
    console.log("[import] running command: task " + cmd.join(' '))
    tw.on('exit', on_exit)
}

const format_status = (code, status) => `{"status": "${status || code || ''}"}`

const check_timew = ({on_exit}) => {
    const tw = spawn_tw(['diagnostics'])
    const rl = readline.createInterface({
        input: tw.stdout
    })

    let response_sent = false

    rl.on('line', (line) => {
        if (line.includes('on-modify.timewarrior')) {
            on_exit(true)
            response_sent = true
        }
    })

    rl.on('close', (line) => {
        if (!response_sent) on_exit(false)
    })
}

const spawn_tw = (opts) => {
    return spawn(TASK, TASKOPTS.concat(opts))
}
