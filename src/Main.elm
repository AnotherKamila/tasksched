module Main exposing (main)

import Html exposing (..)
import Http
import Date exposing (Date)
import Json.Decode as Decode
import Material
import Material.Scheme
import Material.Color as Color
import Material.Layout as Layout

import Taskwarrior
import Config
import TaskListViews

main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
    { tasks    : List Taskwarrior.Task
    , zoomlvl  : Float
    , err      : String

    -- Boilerplate
    , mdl      : Material.Model                     -- model for Mdl components
    --, dragDrop : Html5.DragDrop.Model DragId DropId -- model for DragDrop
    }


-- UPDATE

type Msg = NewTasks (Result Http.Error (List Taskwarrior.Task))
         --| Unschedule Task
         --| Schedule Task Date
         | Mdl (Material.Msg Msg) -- Boilerplate: internal Mdl messages


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewTasks (Ok new_tasks) ->
            ({ model | tasks = model.tasks ++ new_tasks }, Cmd.none)
        NewTasks (Err err) ->
            ({model | err = toString err }, Cmd.none) -- TODO retry
        --Schedule task date ->
        --Unschedule task ->

        Mdl m -> Material.update Mdl m model -- Boilerplate: Mdl action handler



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Layout.subs Mdl model.mdl


-- HTTP

get_tasks : Cmd Msg
get_tasks =
    let request = Http.get Config.api_url Taskwarrior.decode_tasks
    in Http.send NewTasks request


-- VIEW

view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.BlueGrey Color.Red <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedDrawer
            ]
            { header = []
            , drawer = [text "TODO"]
            , tabs   = ([],[])
            , main   = [view_body model]
            }


view_body : Model -> Html Msg
view_body model =
    div [] [TaskListViews.view model.zoomlvl model.tasks, text model.err]


-- INIT

model =
    { tasks = []
    , zoomlvl = 1
    , err = ""
    , mdl = Material.model -- Boilerplate: initial model for Mdl components
    }

init : (Model, Cmd Msg)
init = (model, get_tasks)
