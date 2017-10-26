import Html exposing (..)
import Http
import Date exposing (Date)
import Json.Decode as Decode


main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- CONSTANTS

api_url = "//localhost:5000"


-- MODEL

type alias Task =
    { description : String
    , uuid  : String
    --, sch   : Maybe Date
    --, due   : Maybe Date
    --, attrs : Dict String String
    }

type alias Model =
    { tasks : List Task
    , err   : String
    }


-- UPDATE

type Msg = NewTasks (Result Http.Error (List Task))
         --| Unschedule Task
         --| Schedule Task Date

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewTasks (Ok new_tasks) ->
            ({ model | tasks = model.tasks ++ new_tasks }, Cmd.none)
        NewTasks (Err err) ->
            ({model | err = toString err }, Cmd.none) -- TODO retry
        --Schedule task date ->
        --Unschedule task ->


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none


-- HTTP

get_tasks : Cmd Msg
get_tasks =
    let request = Http.get api_url decode_tasks
    in Http.send NewTasks request

decode_tasks : Decode.Decoder (List Task)
decode_tasks = Decode.list decode_task

decode_task : Decode.Decoder Task
decode_task =
    Decode.map2 Task (Decode.field "description" Decode.string) (Decode.field "uuid" Decode.string)
    -- TODO check out http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline

-- VIEW

view : Model -> Html Msg
view model =
    div [] (
        [h1 [] [text "Tasks"]] ++
        (List.map viewTask model.tasks) ++
        [div [] [text model.err]]
    )

viewTask task =
    div [] [ text task.description ]


-- INIT

init : (Model, Cmd Msg)
init = ({tasks = [], err = ""}, get_tasks)
