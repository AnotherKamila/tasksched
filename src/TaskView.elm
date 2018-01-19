module TaskView exposing (..)

import Date.Extra  as Date
import Maybe.Extra as Maybe
import Html exposing (..)
import Html.Attributes as Html exposing (href)
import Date exposing (Date)
import Html5.DragDrop as DragDrop
import Material.Card as Card
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Icon as Icon
import Material.Options as Options exposing (cs, css)

import Taskwarrior.Model exposing (Task, Uuid)
import Utils.String exposing (emptyToList)

view : (DragDrop.Msg Task (Maybe Date) -> m) -> Task -> Html m
view dndMsg task =
    let options = [cs "task-card", Color.text Color.white, css "padding" "0.5em"]
    in (Card.view
            [ css "margin" "1em auto"
            , css "width" "90%"
            , Color.background Color.primary
            , Elevation.e2
            ]
            [ Card.title options [pretty_task_description task]
            , Card.text  options [text (task_details task)]
            ] )
    |> div (DragDrop.draggable dndMsg task) << List.singleton

fmtdate : Date -> String
fmtdate = Date.toFormattedString "MMM d"

task_details : Task -> String
task_details t =
    let due  = Maybe.map (\x -> "due " ++ fmtdate x) t.due |> Maybe.toList
        proj = t.project |> emptyToList
    in due ++ proj |> String.join " • "

pretty_task_description : Task -> Html msg
pretty_task_description t =
    let link =
        if t.task_url == "" then []
        else [ text " ", Html.a [ Html.href t.task_url ] [ Icon.i "launch" ] ]
    in Html.span [] (text t.description :: link)
