module Update exposing (update, init)

import Date
import Material
import Date.Extra as Date
import Html5.DragDrop as DragDrop

import Model exposing (Model, Msg(..))
import Commands
import Taskwarrior
import Utils.Date


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- TODO handle errors :D like, everywhere :D
        NewTasks  (Ok new)  -> ({model | tasks = model.tasks ++ new}, Cmd.none)
        SentTasks (Ok msg)  -> ({model | err   = msg},                Cmd.none)
        NewTasks  (Err err) -> ({model | err   = toString err},       Cmd.none)
        SentTasks (Err err) -> ({model | err   = toString err},       Cmd.none)
        NewNow    date      -> ({model | now   = date},               Cmd.none)

        DragDropMsg m -> dropped m model
        Mdl         m -> Material.update Mdl m model -- Mdl action handler

init_model : Model
init_model =
    { tasks    = []
    , zoomlvl  = Date.Day
    , now      = Utils.Date.date_0
    , err      = ""
    -- Boilerplate
    , dragDrop = DragDrop.init
    , mdl      = Material.model
    }

init : (Model, Cmd Msg)
init = (init_model, Cmd.batch [Commands.get_now, Commands.get_tasks])


dropped : DragDrop.Msg Taskwarrior.Task (Maybe Date.Date) -> Model -> (Model, Cmd Msg)
dropped msg model =
    let (dragdrop, result) = DragDrop.update msg model.dragDrop
        (new_tasks, cmd)   = case result of
            Nothing     -> (model.tasks,                   Cmd.none)
            Just (t, d) -> (schedule_task model.tasks t d, Commands.send_task {t | scheduled = d})
    in ({model | dragDrop = dragdrop, tasks = new_tasks}, cmd)


-- TODO move this from here, maybe?
schedule_task tasks t date =
    {t | scheduled = date} :: (List.filter ((/=) t) tasks)
