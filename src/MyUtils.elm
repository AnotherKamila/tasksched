module MyUtils exposing (..)

import Date
import Date.Extra
import List.Extra
import Json.Decode          exposing (Decoder, string, succeed, fail, andThen)

split_at_indices : List Int -> String -> List String
split_at_indices is s =
    let slices = List.map2 String.slice (0::is) is
        last = List.Extra.last is |> Maybe.withDefault 0
    in (List.map (\f -> f s) slices) ++ [String.dropLeft last s]

intersperse_lists : List a -> List a -> List a
intersperse_lists xs ys = List.map2 (\a b -> [a,b]) xs ys |> List.concat

is_Just : Maybe a -> Bool
is_Just x =
    case x of
        Just _  -> True
        Nothing -> False

from_Maybe : Maybe a -> Decoder a
from_Maybe x =
    case x of
        Just a -> succeed a
        Nothing -> fail "Nothing found in Maybe"

maybe2list x =
    case x of
        Just  x -> [x]
        Nothing -> []

empty2list x = if String.isEmpty x then [] else [x]

decode_date : Decoder Date.Date
decode_date = string |> andThen (Date.Extra.fromIsoString >> from_Maybe)
