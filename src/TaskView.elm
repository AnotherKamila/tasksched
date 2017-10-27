module TaskView exposing (..)

import Date.Extra
import Html exposing (..)
import Material
import Material.Button as Button
import Material.Card as Card
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Grid exposing (cell, size, Device(All))
import Material.Options as Options exposing (css)

import Taskwarrior exposing (Task)
import Utils.Maybe exposing (maybe2list, empty2list)

view_task task =
    let options = [Color.text Color.white, css "padding" "0.5em"]
    in Card.view
            [ css "margin" "1em auto"
            , css "width" "90%"
            , Color.background Color.primary
            , Elevation.e2
            ]
            [ Card.title options [text task.description]
            , Card.text  options [text (task_details task)]
            ]

fmtdate = Date.Extra.toFormattedString "MMM d"

task_details t =
    let due  = Maybe.map (\x -> "due " ++ fmtdate x) t.due |> maybe2list
        proj = t.project |> empty2list
    in due ++ proj |> String.join " • "
