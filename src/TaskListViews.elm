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

import Taskwarrior exposing (Task)
import TaskView
import Utils.Date  exposing (just_date, zoomlvl2interval, maybedate2cmp, make_buckets, date_0)
import Utils.List  exposing (bucketize_by)
import Utils.Maybe exposing (is_Just)

view : Float -> List Task -> Html msg
view zoomlvl tasks =
    let (sch, unsch) = partition (.scheduled >> is_Just) tasks
        (uns1, uns2) = unsch |> sortBy .urgency |> reverse |> splitAt ((length unsch)//2)
        unsch_htmls  = [uns1, uns2] |> map (view_unscheduled  >> cell [size All 4, css "margin" "0"])
        sch_html     = sch          |> view_scheduled zoomlvl |> cell [size All 4]
    in grid [css "padding" "0"] (sch_html :: unsch_htmls)

view_unscheduled : List Task -> List (Html msg)
view_unscheduled = map TaskView.view_task

view_scheduled : Float -> List Task -> List (Html msg)
view_scheduled zoomlvl tasks =
    let interval = zoomlvl2interval zoomlvl
    in tasks
    |> sortBy (.scheduled >> maybedate2cmp)
    |> buckets interval
    |> map (view_bucket interval)

view_bucket : Interval -> (Date, List Task) -> Html msg
view_bucket interval (bucket, tasks) = div [] (bucket_header interval bucket :: map TaskView.view_task tasks)

bucket_header : Interval -> Date -> Html msg
bucket_header interval bucket = div [Typo.caption, Typo.uppercase, Typo.right] [text (fmtdate interval bucket)]

fmtdate interval =
    case interval of
        Hour -> Date.Extra.toFormattedString "HH a"
        _    -> Date.Extra.toFormattedString "MMM d"



greater_than_bucket : Date -> Task -> Bool
greater_than_bucket b t =
    case Date.Extra.compare b (get_sch t) of
        LT -> True
        _  -> False


buckets : Interval -> List Task -> List (Date, List Task)
buckets interval tasks =
    bucketize_by (greater_than_bucket) (date_0 :: (make_buckets interval now 47)) tasks -- TODO

now = Date.Extra.fromCalendarDate 2017 Oct 27 -- TODO


get_sch = .scheduled >> just_date

equal_to_bucket : Interval -> Date -> Task -> Bool
equal_to_bucket interval a b = Date.Extra.equalBy interval a (get_sch b)

