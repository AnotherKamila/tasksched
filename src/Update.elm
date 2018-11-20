module Update exposing (update, refresh)

import Date
import Material
import Task
import Http
import Html5.DragDrop as DragDrop

import Model exposing    (Model, Msg(..))
import UrlState exposing (UrlState, url_state, update_filter, toggle_next)
import Taskwarrior.Model as Tw
import Taskwarrior.Api   as Tw
import Taskwarrior.Utils as Tw


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- TODO handle errors :D like, everywhere :D
        NewTasks  (Ok new)  -> ({model | tasks = new},                 Cmd.none)
        NewTimew  (Ok b)    -> ({model | timew = b},                   Cmd.none)
        SentTasks (Ok msg)  -> ({model | err   = msg},                 refresh (url_state model))
        NewTasks  (Err err) -> ({model | err   = toString err},        Cmd.none)
        NewTimew  (Err err) -> ({model | err   = toString err},        Cmd.none)
        SentTasks (Err err) -> ({model | err   = toString err},        refresh (url_state model))
        NewNow    date      -> ({model | now   = date},                Cmd.none)
        NewZoom   zoom      -> ({model | zoom  = zoom},                Cmd.none)
        NewFilter f         -> ( model,                                update_filter model f)
        NewUrl    url       -> ({model | url = url},                   refresh (url_state {model | url = url}))
        SendCmd   cmd t     -> ( model,                                send_cmd cmd t)
        RefreshWanted       -> ( model,                                refresh (url_state model))
        ToggleNext          -> ( model,                                toggle_next model)
        DragDropMsg m       ->   dropped m model
        Mdl         m       ->   Material.update Mdl m model -- Mdl action handler

dropped : DragDrop.Msg Tw.Task (Maybe Date.Date) -> Model -> (Model, Cmd Msg)
dropped msg model =
    let (dragdrop, result) = DragDrop.update msg model.dragDrop
        (new_tasks, cmd)   = case result of
            Nothing     -> (model.tasks, Cmd.none)
            Just (t, d) -> let new = {t | scheduled = d} in (Tw.mod new model.tasks, send_task new)
    in ({model | dragDrop = dragdrop, tasks = new_tasks}, cmd)

-- COMMANDS --

get_tasks : String -> Cmd Msg
get_tasks filter = Http.send NewTasks (Tw.get_request filter)

get_now : Cmd Msg
get_now = Task.perform NewNow Date.now

get_timew : Cmd Msg
get_timew = Http.send NewTimew Tw.get_timew_status

refresh : UrlState -> Cmd Msg
refresh urlState = Cmd.batch [get_now, get_tasks urlState.filter, get_timew]

send_cmd : Tw.TwCommand -> Tw.Task -> Cmd Msg
send_cmd cmd t = Http.send SentTasks (Tw.send_request cmd t)

send_task : Tw.Task -> Cmd Msg
send_task t = send_cmd Tw.Modify t
