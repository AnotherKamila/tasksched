module Update exposing (update, init)

import Date
import Material
import Task
import Http
import Html5.DragDrop as DragDrop

import Model exposing (Model, Msg(..))
import Taskwarrior.Model as Tw
import Taskwarrior.Api   as Tw
import Taskwarrior.Utils as Tw


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- TODO handle errors :D like, everywhere :D
        NewTasks  (Ok new)  -> ({model | tasks = new},                 Cmd.none)
        SentTasks (Ok msg)  -> ({model | err   = msg},                 Cmd.none)
        NewTasks  (Err err) -> ({model | err   = toString err},        Cmd.none)
        SentTasks (Err err) -> ({model | err   = toString err},        Cmd.none)
        NewNow    date      -> ({model | now   = date},                Cmd.none)
        NewZoom   zoom      -> ({model | zoom  = zoom},                Cmd.none)
        NewUrl    url       -> ({model | url   = url},                 Cmd.none)
        RefreshWanted       -> ( model,                                refresh )
        MarkDone  t         -> ({model | tasks = Tw.rm t model.tasks}, send_done t)
        DragDropMsg m -> dropped m model
        Mdl         m -> Material.update Mdl m model -- Mdl action handler

dropped : DragDrop.Msg Tw.Task (Maybe Date.Date) -> Model -> (Model, Cmd Msg)
dropped msg model =
    let (dragdrop, result) = DragDrop.update msg model.dragDrop
        (new_tasks, cmd)   = case result of
            Nothing     -> (model.tasks, Cmd.none)
            Just (t, d) -> let new = {t | scheduled = d} in (Tw.mod new model.tasks, send_task new)
    in ({model | dragDrop = dragdrop, tasks = new_tasks}, cmd)

-- COMMANDS --

get_tasks : Cmd Msg
get_tasks = Http.send NewTasks Tw.get_request

send_task : Tw.Task -> Cmd Msg
send_task t = Http.send SentTasks (Tw.send_request t)

send_done : Tw.Task -> Cmd Msg
send_done t = Http.send SentTasks (Tw.send_done_request t)

get_now : Cmd Msg
get_now = Task.perform NewNow Date.now

refresh : Cmd Msg
refresh = Cmd.batch [get_now, get_tasks]

-- INIT --

init : Cmd Msg
init = refresh
