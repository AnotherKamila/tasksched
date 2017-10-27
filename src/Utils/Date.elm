module Utils.Date exposing (..)

import Date        exposing (Date, Month(Jan))
import Date.Extra  exposing (Interval(..), equalBy)

date_0 : Date
date_0 = Date.Extra.fromCalendarDate 1970 Jan 1

date_inf : Date
date_inf = Date.Extra.fromCalendarDate 2038 Jan 1 -- TODO update by 2038 ;-)

just_date = Maybe.withDefault date_0

maybedate2cmp = Maybe.map Date.toTime >> Maybe.withDefault 0

-- Contract: requires zoomlvl > 0!
zoomlvl2interval : Float -> Interval
zoomlvl2interval lvl =
    let distance = 1/lvl |> ceiling
    in case distance of
        1 -> Hour
        2 -> Day
        3 -> Week
        _ -> Month

-- Contract: count is non-negative
make_buckets : Date.Extra.Interval -> Date.Date -> Int -> List (Date.Date)
make_buckets interval start count =
    case count of
        0 -> []
        n -> start :: (make_buckets interval (Date.Extra.add interval 1 start) (count-1))
