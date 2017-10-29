module Model exposing (Model, Msg(..), init)

import Date
import Http
import Material
import Date.Extra     as Date
import Html5.DragDrop as DragDrop

import Taskwarrior
import Utils.Date


type alias Model =
    { tasks    : List Taskwarrior.Task
    , zoomlvl  : Date.Interval
    , now      : Date.Date
    , err      : String

    -- Boilerplate
    , dragDrop : DragDrop.Model Dragged DroppedOnto
    , mdl      : Material.Model -- for Mdl components
    }


type Msg = NewTasks    (Result Http.Error (List Taskwarrior.Task))
         | SentTasks   (Result Http.Error String)
         | NewNow      Date.Date
         | DragDropMsg (DragDrop.Msg Dragged DroppedOnto)
         -- Boilerplate
         | Mdl (Material.Msg Msg) -- internal Mdl messages


-- we will be dragging tasks to dates
type alias Dragged     = Taskwarrior.Task
type alias DroppedOnto = Maybe Date.Date


-- INIT --

init : Model
init =
    { tasks    = []
    , zoomlvl  = Date.Day
    , now      = Utils.Date.date_0
    , err      = ""
    -- Boilerplate
    , dragDrop = DragDrop.init
    , mdl      = Material.model
    }
