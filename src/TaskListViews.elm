module TaskListViews exposing (..)

import List exposing (sortBy, reverse, length, partition, map)
import List.Extra exposing (splitAt)
import Html exposing (Html)
import Material.Options as Options exposing (css, div)
import Material.Grid exposing (grid, cell, size, Device(..))

import Taskwarrior exposing (Task)
import MyUtils exposing (..)
import TaskView

view : List Task -> Html msg
view tasks =
    let (sch, unsch) = partition (.scheduled >> is_Just) tasks
        (uns1, uns2) = unsch |> sortBy .urgency |> reverse |> splitAt ((length unsch)//2)
        htmls        = [view_scheduled sch, view_unscheduled uns1, view_unscheduled uns2]
    in grid [] (map (cell [ size All 4 ]) htmls)

view_scheduled : List Task -> List (Html msg)
view_scheduled = map TaskView.view_task

view_unscheduled : List Task -> List (Html msg)
view_unscheduled = map TaskView.view_task
