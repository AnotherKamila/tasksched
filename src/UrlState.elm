module UrlState exposing (UrlState, url_state, update_filter, toggle_next)

import Model exposing (Model, Msg)

import Navigation exposing (Location)


type alias UrlState =
    { next : Bool
    , filter: String
    }

parse_hash : String -> UrlState
parse_hash hash =
    let next         = (String.startsWith "#next" hash)
        filter_parts = (Maybe.withDefault []
                            (List.tail (String.split "?" hash)))
        filter = (String.join "?" filter_parts)
    in
      UrlState next filter

url_state : Model -> UrlState
url_state model = parse_hash model.url.hash

put_hash : UrlState -> Cmd msg
put_hash urlState =
    let hash = String.join ""
               [ "#"
               , (if urlState.next then "next" else "")
               , (if String.isEmpty urlState.filter then "" else "?")
               , urlState.filter
               ]
    in
        Navigation.modifyUrl hash

update_filter : Model -> String -> Cmd Msg
update_filter model f =
    let urlState = url_state model
    in put_hash {urlState | filter = f}

toggle_next : Model -> Cmd Msg
toggle_next model =
    let urlState = url_state model
    in put_hash {urlState | next = not urlState.next}
