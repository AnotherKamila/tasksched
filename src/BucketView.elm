module BucketView exposing (..)

import Html exposing (..)
import Date exposing (Date)
import Date.Extra exposing (Interval(..))
import Html5.DragDrop as DragDrop
import Material.Color as Color
import Material.Options as Options exposing (css)
import Material.Typography as Typo

import Taskwarrior exposing (Task, Uuid)
import Date.Human  exposing (format_day_or_time, has_time)
import TaskView
import Utils.Date  exposing (date_0)

-- TODO refactor: buckets shouldn't know about Task, it should just be a container for more Html

view : (DragDrop.Msg Task (Maybe Date) -> m) -> Maybe Date -> Date -> Interval -> ((Date,Date), List Task) -> Html m
view dndMsg active_drop now interval ((b, e), tasks) =
    let highlight =
        case active_drop of
            Nothing     -> []
            Just (date) -> if date == b then [Color.background Color.accent] else []
    in
        Options.div ((css "min-height" "2em")::highlight)
            (bucket_header now interval b :: (List.map (TaskView.view dndMsg) tasks))
        |> List.singleton |> Html.div (DragDrop.droppable dndMsg (Just b))

bucket_header : Date -> Interval -> Date -> Html msg
bucket_header now interval bucket =
    let format_bucket date = if date == date_0 then "now" else format_day_or_time now date
        color = if (bucket /= now) && (has_time bucket) then Color.primary else Color.accent
    in Options.div
        [Typo.caption, Typo.uppercase, Typo.right, Color.text color]
        [text (format_bucket bucket)]
