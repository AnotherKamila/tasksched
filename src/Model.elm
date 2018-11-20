module Model exposing (Model, Msg(..), init, update_filter, parse_hash, toggle_next)

import Date
import Http
import Material
import Navigation
import Date.Extra     as Date
import Html5.DragDrop as DragDrop

import Taskwarrior.Model as Taskwarrior
import Utils.Date

type alias UrlState =
    { next : Bool
    , filter: String
    }

type alias Model =
    { tasks    : List Taskwarrior.Task
    , zoom     : Date.Interval
    , now      : Date.Date
    , err      : String
    , urlState : UrlState
    , timew    : Bool
    -- Boilerplate
    , dragDrop : DragDrop.Model Dragged DroppedOnto
    , mdl      : Material.Model -- for Mdl components
    }


type Msg = NewTasks      (Result Http.Error (List Taskwarrior.Task))
         | SentTasks     (Result Http.Error String)
         | NewNow        Date.Date
         | NewZoom       Date.Interval
         | RefreshWanted
         | NewFilter     String
         | NewUrl        Navigation.Location
         | NewTimew      (Result Http.Error Bool)
         | SendCmd       Taskwarrior.TwCommand Taskwarrior.Task
         | ToggleNext
         | DragDropMsg   (DragDrop.Msg Dragged DroppedOnto)
         -- Boilerplate
         | Mdl (Material.Msg Msg) -- internal Mdl messages


-- we will be dragging tasks to dates
type alias Dragged     = Taskwarrior.Task
type alias DroppedOnto = Maybe Date.Date -- Maybe because we can also unschedule


parse_hash : String -> UrlState
parse_hash hash =
    let next         = (String.startsWith "#next" hash)
        filter_parts = (Maybe.withDefault []
                            (List.tail (String.split "?" hash)))
        filter = (String.join "?" filter_parts)
    in
      UrlState next filter

put_hash : UrlState -> Cmd msg
put_hash urlState =
    let hash = String.join ""
               [ "#"
               , (if urlState.next then "next" else "")
               , (if String.isEmpty urlState.filter then "" else "?")
               , urlState.filter
               ]
    in
        Navigation.modifyUrl hash

update_filter : Model -> String -> Cmd Msg
update_filter model f =
    let urlState = model.urlState
    in put_hash {urlState | filter = f}

toggle_next : Model -> Cmd Msg
toggle_next model =
    let urlState = model.urlState
    in put_hash {urlState | next = not urlState.next}

-- INIT --

init : Navigation.Location -> Model
init location =
    { tasks    = []
    , zoom     = Date.Day
    , now      = Utils.Date.date_0
    , err      = ""
    , urlState = parse_hash location.hash
    , timew    = False
    -- Boilerplate
    , dragDrop = DragDrop.init
    , mdl      = Material.model
    }
