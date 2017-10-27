module Utils.String exposing (..)

import List.Extra

split_at_indices : List Int -> String -> List String
split_at_indices is s =
    let slices = List.map2 String.slice (0::is) is
        last = List.Extra.last is |> Maybe.withDefault 0
    in (List.map (\f -> f s) slices) ++ [String.dropLeft last s]
