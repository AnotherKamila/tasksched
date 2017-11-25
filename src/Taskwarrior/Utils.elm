module Taskwarrior.Utils exposing
    ( partition_scheduled
    , sort_by_scheduled
    , next
    , rm
    , mod
    )

import Maybe.Extra       as Maybe
import List              exposing (sortBy, partition, filter, head)
import Utils.Date        exposing (maybedate2cmp)
import Taskwarrior.Model exposing (Task)

partition_scheduled : List Task -> (List Task, List Task)
partition_scheduled = partition (.scheduled >> Maybe.isJust)

sort_by_scheduled : List Task -> List Task
sort_by_scheduled = sortBy (\t -> (t.scheduled |> maybedate2cmp, -1*t.urgency))

next : List Task -> Maybe Task
next tasks = let (s, u) = partition_scheduled tasks in (sort_by_scheduled s) ++ (sort_by_scheduled u) |> head

rm : Task -> List Task -> List Task
rm old tasks = filter (\t -> t.uuid /= old.uuid) tasks

mod : Task -> List Task -> List Task
mod t tasks = t :: (rm t tasks)
