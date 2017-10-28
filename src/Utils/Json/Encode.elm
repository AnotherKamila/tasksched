module Utils.Json.Encode exposing (..)

import Date
import Date.Extra
import String.Extra as String
import Json.Encode  as Encode

date_iso_utc : Date.Date -> Encode.Value
date_iso_utc = Date.Extra.toUtcIsoString >> String.replace ".000" "" >> Encode.string
