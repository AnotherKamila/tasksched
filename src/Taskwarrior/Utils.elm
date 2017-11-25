module Taskwarrior.Utils exposing
    ( partition_scheduled
    , sort_by_scheduled
    , next
    )

import Maybe.Extra       as Maybe
import List              exposing (sortBy, length, partition, map, head)
import Utils.Date        exposing (maybedate2cmp)
import Taskwarrior.Model exposing (Task)

partition_scheduled : List Task -> (List Task, List Task)
partition_scheduled = partition (.scheduled >> Maybe.isJust)

sort_by_scheduled : List Task -> List Task
sort_by_scheduled = sortBy (\t -> (t.scheduled |> maybedate2cmp, -1*t.urgency))

next : List Task -> Maybe Task
next = sort_by_scheduled >> head
