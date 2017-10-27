module Utils.Maybe exposing (..)

is_Just : Maybe a -> Bool
is_Just x =
    case x of
        Just _  -> True
        Nothing -> False

maybe2list : Maybe a -> List a
maybe2list x =
    case x of
        Just  x -> [x]
        Nothing -> []

empty2list : String -> List String
empty2list x = if String.isEmpty x then [] else [x]
