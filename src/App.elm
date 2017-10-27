module App exposing (..)

import Html exposing (..)
import Http
import Date exposing (Date)
import Task
import Maybe.Extra as Maybe
import Json.Decode as Decode
import Material
import Material.Scheme
import Material.Color  as Color
import Material.Layout as Layout
import Html5.DragDrop  as DragDrop

import Taskwarrior
import TaskListViews
import Utils.Date exposing (date_0)


-- MODEL

type alias Model =
    { tasks    : List Taskwarrior.Task
    , zoomlvl  : Float
    , now      : Date
    , err      : String
    , dragDrop : DragDrop.Model Taskwarrior.Task (Maybe Date) -- DragDrop: we will be dragging tasks to dates
    -- Boilerplate
    , mdl      : Material.Model -- for Mdl components
    }


-- UPDATE

type Msg = NewTasks  (Result Http.Error (List Taskwarrior.Task))
         | SentTasks (Result Http.Error String)
         | NewNow Date
         | DragDropMsg (DragDrop.Msg Taskwarrior.Task (Maybe Date))

         -- Boilerplate
         | Mdl (Material.Msg Msg) -- internal Mdl messages

-- TODO move this from here
schedule_task tasks t date =
    {t | scheduled = date} :: (List.filter ((/=) t) tasks)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- TODO handle errors :D
        NewTasks    (Ok new)  -> ({model | tasks = model.tasks ++ new},                      Cmd.none)
        SentTasks   (Ok msg)  -> (if String.isEmpty msg then model else {model | err = msg}, Cmd.none)
        NewTasks    (Err err) -> ({model | err = toString err},                              Cmd.none)
        SentTasks   (Err err) -> ({model | err = toString err},                              Cmd.none)
        NewNow      date      -> ({model | now = date},                                      Cmd.none)

        DragDropMsg m ->
            let (dragdrop, result) = DragDrop.update m model.dragDrop
                (new_tasks, cmd) = case result of
                    Nothing     -> (model.tasks,                    Cmd.none)
                    Just (t, d) -> (schedule_task model.tasks t d, send_task {t | scheduled = d})
            in ({model | dragDrop = dragdrop, tasks = new_tasks}, cmd)

        Mdl m -> Material.update Mdl m model -- Mdl action handler


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Layout.subs Mdl model.mdl


-- COMMANDS

get_now : Cmd Msg
get_now = Task.perform NewNow Date.now

get_tasks : Cmd Msg
get_tasks = Http.send NewTasks Taskwarrior.get_request

send_task : Taskwarrior.Task -> Cmd Msg
send_task t = Http.send SentTasks (Taskwarrior.send_request t)

-- INIT

model : Model
model =
    { tasks = []
    , zoomlvl = 1
    , now = date_0
    , err = ""
    -- Boilerplate
    , dragDrop = DragDrop.init
    , mdl = Material.model -- initial model for Mdl components
    }

init : (Model, Cmd Msg)
init = (model, Cmd.batch [get_now, get_tasks])

-- VIEW


view : Model -> Html Msg
view model =
    let dropped_date = DragDrop.getDropId model.dragDrop
    in Material.Scheme.topWithScheme Color.BlueGrey Color.Red <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedDrawer
            ]
            { header = []
            , drawer = [text "TODO"]
            , tabs   = ([],[])
            , main   = [view_body model (Maybe.join dropped_date)]
            }


view_body : Model -> Maybe Date -> Html Msg
view_body model dropped_date =
    div []
        [ TaskListViews.view { now = model.now
                             , zoomlvl = model.zoomlvl
                             , tasks = model.tasks
                             , dropped_date = dropped_date
                             , dndMsg = DragDropMsg
                             }
        , text model.err
        ]
