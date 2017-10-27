module TaskView exposing (..)

import Date.Extra  as Date
import Maybe.Extra as Maybe
import Html exposing (..)
import Date exposing (Date)
import Html5.DragDrop as DragDrop
import Material.Card as Card
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Options as Options exposing (css)

import Taskwarrior exposing (Task, Uuid)
import Utils.String exposing (emptyToList)

view : (DragDrop.Msg Task (Maybe Date) -> m) -> Task -> Html m
view dndMsg task =
    let options = [Color.text Color.white, css "padding" "0.5em"]
    in (Card.view
            [ css "margin" "1em auto"
            , css "width" "90%"
            , Color.background Color.primary
            , Elevation.e2
            ]
            [ Card.title options [text task.description]
            , Card.text  options [text (task_details task)]
            ] )
    |> div (DragDrop.draggable dndMsg task) << List.singleton


fmtdate = Date.toFormattedString "MMM d"

task_details t =
    let due  = Maybe.map (\x -> "due " ++ fmtdate x) t.due       |> Maybe.toList
        sch  = Maybe.map (\x -> "sch " ++ fmtdate x) t.scheduled |> Maybe.toList
        proj = t.project |> emptyToList
    in due ++ sch ++ proj |> String.join " • "
