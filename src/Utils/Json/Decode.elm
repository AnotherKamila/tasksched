module Utils.Json.Decode exposing (..)

import Date
import Date.Extra
import Json.Decode exposing (Decoder, andThen, string, succeed, fail)

from_Maybe : Maybe a -> Decoder a
from_Maybe x =
    case x of
        Just a -> succeed a
        Nothing -> fail "Nothing found in Maybe"

date : Decoder Date.Date
date = string |> andThen (Date.Extra.fromIsoString >> from_Maybe)
