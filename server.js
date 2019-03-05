#!/usr/bin/env node

const body_parser = require('body-parser')
const cors        = require('cors')
const express     = require('express')
const proxy       = require('express-http-proxy');
const {spawn}     = require('child_process');
const readline    = require('readline')

const PORT          = process.env.PORT || 5000
const TASK          = 'task'
const TASKOPTS      = ['rc.gc=off', 'rc.json.array=on']
const DEVSERVER     = 'http://localhost:8000' // Proxies this from /dev (and allows CORS)
const ALWAYS_FILTER = '(+PENDING or (+WAITING +SCHEDULED))'

const api = express()
api.use(body_parser.json())
api.use(cors({origin: DEVSERVER}))

api.get('/tasks', (req, res) => {
    let filter = req.query.filter
    // This bit is terrible.
    // But the alternative is having everything again in memory.
    let filter_s = (filter) ? ("\"filter\":\"" + filter + "\",") : ""
    res.write("{" + filter_s + "\"tasks\":")
    export_filtered_tasks(filter, {
        on_data: (chunk) => res.write(chunk),
        on_exit: (c, s)  => {
            res.write("}") &&
            res.end(c || s ? format_status(c, s) : '')
        }
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


const export_filtered_tasks = (filter, callbacks) => {
    tw_active_filter({
        on_exit: (f) => export_tasks(`${f} ${filter || ''}`, callbacks)
    })
}

const export_tasks = (filter, {on_data, on_exit}) => {
    const f = `${ALWAYS_FILTER} ${filter || ''}`
    const tw = spawn_tw([f, 'export'])
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

    rl.on('close', () => {
        if (!response_sent) on_exit(false)
    })
}

const spawn_tw = (opts) => {
    return spawn(TASK, TASKOPTS.concat(opts))
}

const tw_get = (dom, {on_exit}) => {
    const tw = spawn_tw(['_get', dom]).stdout
    let output = ''
    tw.on('data', (data) => {
        if (data) output += data.toString()
    })
    tw.on('close', () => {
        on_exit(output.trim())
    })
}

const tw_active_context = ({on_exit}) => {
    // Get active context name
    tw_get('rc.context', {on_exit})
}

const tw_context_filter = (context, {on_exit}) => {
    // Get the filter associated with a given context

    if (!context) return on_exit('')

    tw_get(`rc.context.${context}`, {
        on_exit: (f) =>
            on_exit((f) ? `(${f})` : '')
    })
}

const tw_active_context_filter = ({on_exit}) => {
    // Get active context filter
    tw_active_context({
        on_exit: (context) =>
            tw_context_filter(context, {on_exit})
    })
}

const tw_report_filter = (report, {on_exit}) => {
    // Get the filter associated with a given report
    tw_get(`rc.report.${report}.filter`, {
        on_exit: (f) => on_exit((f) ? `(${f})` : '')
    })
}

const tw_active_filter = ({on_exit}) => {
    // Get the combination of:
    // Current context filter AND next report filter
    tw_report_filter('next', {
        on_exit: (report_f) =>
            tw_active_context_filter({
                on_exit: (context_f) => on_exit(`${context_f} ${report_f}`)
            })
    })
}
