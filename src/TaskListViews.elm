module TaskListViews exposing (..)

import Date exposing (Date, Month(..)) -- TODO remove month
import Date.Extra exposing (Interval(..))
import List exposing (sortBy, reverse, length, partition, map, head)
import List.Extra exposing (splitAt, groupWhile)
import Html exposing (Html, text)
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options exposing (css, div)
import Material.Typography as Typo
import Material.Elevation as Elevation
import Material.Color as Color

import Taskwarrior exposing (Task)
import TaskView
import Utils.Date  exposing (just_date, zoomlvl2interval, maybedate2cmp, make_buckets, date_0)
import Utils.List  exposing (bucketize_by)
import Utils.Maybe exposing (is_Just)
import Date.Human  exposing (format_day_or_time, has_time)

-- TODO this whole thing badly needs refactoring

view : Date -> Float -> List Task -> Html msg
view now zoomlvl tasks =
    let (sch, unsch) = partition (.scheduled >> is_Just) tasks
        (uns1, uns2) = unsch |> sortBy .urgency |> reverse |> splitAt ((length unsch)//2)
        unsch_htmls  = [uns1, uns2] |> map (view_unscheduled >> cell [size All 4, css "margin" "0"])
        sch_html     = sch          |> view_scheduled zoomlvl now |> cell [size All 4]
    in grid [css "padding" "0"] (sch_html :: unsch_htmls)

view_unscheduled : List Task -> List (Html msg)
view_unscheduled = map TaskView.view_task

view_scheduled : Float -> Date -> List Task -> List (Html msg)
view_scheduled zoomlvl now tasks =
    let interval = zoomlvl2interval zoomlvl
    in tasks
    |> sortBy (.scheduled >> maybedate2cmp)
    |> buckets now interval
    |> map (view_bucket now interval)

view_bucket : Date -> Interval -> (Date, List Task) -> Html msg
view_bucket now interval (bucket, tasks) =
    div [css "min-height" "2em"]
        (bucket_header now interval bucket :: map TaskView.view_task tasks)

bucket_header : Date -> Interval -> Date -> Html msg
bucket_header now interval bucket =
    let format_bucket date = if date == date_0 then "overdue" else format_day_or_time now date
    in div
        [Typo.caption, Typo.uppercase, Typo.right, Color.text (if has_time bucket then Color.primary else Color.accent)]
        [text (format_bucket bucket)]

greater_than_bucket : Date -> Task -> Bool
greater_than_bucket b t =
    case Date.Extra.compare b (get_sch t) of
        LT -> True
        _  -> False

num_buckets = 147 -- TODO make it depend on zoom maybe, or dynamic if feeling fancy

buckets : Date -> Interval -> List Task -> List (Date, List Task)
buckets now interval tasks =
    let till = Date.Extra.add interval num_buckets now
    in bucketize_by (greater_than_bucket) (date_0 :: (Date.Extra.range interval 1 now till)) tasks


get_sch = .scheduled >> just_date

equal_to_bucket : Interval -> Date -> Task -> Bool
equal_to_bucket interval a b = Date.Extra.equalBy interval a (get_sch b)

