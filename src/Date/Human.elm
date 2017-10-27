module Date.Human exposing (..)

import Date        exposing (..)
import Date.Extra  exposing (..)

is_past : Date -> Date -> Bool
is_past now date =
    case Date.Extra.compare date now of
        LT -> True
        _  -> False

has_time : Date -> Bool
has_time date =
    case (hour date, minute date, second date) of
        (0,0,0) -> False
        _       -> True

format_day : Date -> Date -> String
format_day now date =
    case diff Day now date of
        (-1) -> "today"
        0    -> "tomorrow"
        (-2) -> "yesterday"
        n    -> toFormattedString (if 0 < n && n < 7 then "EEEE" else "MMMM d") date

format_hour : Date -> Date -> String
format_hour now date =
    if diff Minute now date < 5 then "now" else toFormattedString "h a" date

format_month _ = toFormattedString "MMMM"

format : Interval -> Date -> Date -> String
format precision now date =
    case precision of
        Hour  -> format_hour  now date
        Month -> format_month now date
        _     -> format_day   now date

format_day_or_time : Date -> Date -> String
format_day_or_time now date = format (if has_time date then Hour else Day) now date
