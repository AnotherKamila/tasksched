module TaskListViews exposing (..)

import BucketView
import TaskView
import Date.Extra        as Date
import List.Extra        as List
import Maybe.Extra       as Maybe
import Html5.DragDrop    as DragDrop
import Taskwarrior.Utils as Taskwarrior
import Taskwarrior.Model as Taskwarrior
import Material.Options  as Options exposing (css)
import Date          exposing (Date)
import List          exposing (sortBy, reverse, length, partition, map, head)
import Html          exposing (Html, text, div)
import Material.Grid exposing (grid, cell, size, Device(..))
import Utils.Date    exposing (just_date, maybedate2cmp, make_buckets, date_0, date_inf)
import Utils.List    exposing (bucketize_by)

-- TODO this whole thing badly needs refactoring

type alias DndMsg msg = DragDrop.Msg Taskwarrior.Task (Maybe Date) -> msg

type alias MyModel msg =
    { tasks        : List Taskwarrior.Task
    , now          : Date
    , zoom         : Date.Interval
    , dropped_date : Maybe Date
    , dndMsg       : DndMsg msg
    }

view : MyModel msg -> Html msg
view model =
    let (sch, unsch) = Taskwarrior.partition_scheduled model.tasks
        (uns1, uns2) = unsch |> sortBy .urgency |> reverse |> List.splitAt ((length unsch)//2)
        unsch_htmls  = [uns1, uns2] |> map (view_unscheduled model.dndMsg >> List.singleton >> cell [size All 4, css "margin" "0"])
        sch_html     = sch          |> view_scheduled model |> cell [size All 4]
    in grid [css "padding" "0"] (sch_html :: unsch_htmls)

view_scheduled : MyModel msg -> List Taskwarrior.Task -> List (Html msg)
view_scheduled model tasks =
    tasks
    |> Taskwarrior.sort_by_scheduled
    |> buckets model.now model.zoom
    |> map (BucketView.view model.dndMsg model.dropped_date model.now model.zoom)


in_bucket : (Date,Date) -> Taskwarrior.Task -> Bool
in_bucket (b,e) t =
    case Date.compare (t.scheduled |> just_date) e of
        LT -> True
        _  -> False

make_buckets : Date -> Date.Interval -> List (Date,Date)
make_buckets now interval =
    let from = Date.add interval -1  now |> Date.ceiling interval
        till = Date.add interval 147 now
        bs   = Date.range interval 1 from till
    in List.zip (date_0 :: bs) (bs ++ [date_inf])

buckets : Date -> Date.Interval -> List Taskwarrior.Task -> List ((Date, Date), List Taskwarrior.Task)
buckets now interval tasks = bucketize_by (in_bucket) (make_buckets now interval) tasks

view_unscheduled : DndMsg msg -> List Taskwarrior.Task -> Html msg
view_unscheduled dndMsg = map (TaskView.view dndMsg) >> div (DragDrop.droppable dndMsg Nothing)
