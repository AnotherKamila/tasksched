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
        NewTimew  (Ok b)    -> ({model | timew = b},                   Cmd.none)
        SentTasks (Ok msg)  -> ({model | err   = msg},                 refresh )
        NewTasks  (Err err) -> ({model | err   = toString err},        Cmd.none)
        NewTimew  (Err err) -> ({model | err   = toString err},        Cmd.none)
        SentTasks (Err err) -> ({model | err   = toString err},        refresh )
        NewNow    date      -> ({model | now   = date},                Cmd.none)
        NewZoom   zoom      -> ({model | zoom  = zoom},                Cmd.none)
        NewFilter f         -> (model,                 Cmd.none) -- TODO
        NewUrl    url       -> ({model | url   = url},                 Cmd.none)
        SendCmd   cmd t     -> ( model,                                send_cmd cmd t)
        RefreshWanted       -> ( model,                                refresh )
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

get_now : Cmd Msg
get_now = Task.perform NewNow Date.now

get_timew : Cmd Msg
get_timew = Http.send NewTimew Tw.get_timew_status

refresh : Cmd Msg
refresh = Cmd.batch [get_now, get_tasks, get_timew]

send_cmd : Tw.TwCommand -> Tw.Task -> Cmd Msg
send_cmd cmd t = Http.send SentTasks (Tw.send_request cmd t)

send_task : Tw.Task -> Cmd Msg
send_task t = send_cmd Tw.Modify t

-- INIT --

init : Cmd Msg
init = refresh
