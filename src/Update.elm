module Update exposing (update, init)

import Date
import Date.Extra as Date
import Material
import Task
import Http
import Html5.DragDrop as DragDrop

import Model exposing (Model, Msg(..))
import Utils.Date
import Taskwarrior
import Taskwarrior.Api


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- TODO handle errors :D like, everywhere :D
        NewTasks  (Ok new)  -> ({model | tasks = model.tasks ++ new}, Cmd.none)
        SentTasks (Ok msg)  -> ({model | err   = msg},                Cmd.none)
        NewTasks  (Err err) -> ({model | err   = toString err},       Cmd.none)
        SentTasks (Err err) -> ({model | err   = toString err},       Cmd.none)
        NewNow    date      -> ({model | now   = date},               Cmd.none)
        NewZoom   zoom      -> ({model | zoom  = zoom},               Cmd.none)
        DragDropMsg m -> dropped m model
        Mdl         m -> Material.update Mdl m model -- Mdl action handler

dropped : DragDrop.Msg Taskwarrior.Task (Maybe Date.Date) -> Model -> (Model, Cmd Msg)
dropped msg model =
    let (dragdrop, result) = DragDrop.update msg model.dragDrop
        (new_tasks, cmd)   = case result of
            Nothing     -> (model.tasks,                   Cmd.none)
            Just (t, d) -> (schedule_task model.tasks t d, send_task {t | scheduled = d})
    in ({model | dragDrop = dragdrop, tasks = new_tasks}, cmd)


-- TODO move this from here, maybe?
schedule_task tasks t date =
    {t | scheduled = date} :: (List.filter ((/=) t) tasks)


-- COMMANDS --

get_tasks : Cmd Msg
get_tasks = Http.send NewTasks Taskwarrior.Api.get_request

send_task : Taskwarrior.Task -> Cmd Msg
send_task t = Http.send SentTasks (Taskwarrior.Api.send_request t)

get_now : Cmd Msg
get_now = Task.perform NewNow Date.now


-- INIT --

init : Cmd Msg
init = Cmd.batch [get_now, get_tasks]
