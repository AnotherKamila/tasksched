module Taskwarrior exposing (Task, decode_task, decode_tasks)

import Json.Decode          exposing (Decoder, int, string, float, list, map)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Date                 exposing (Date)
import Result               exposing (Result)
import Utils.Json.Decode    exposing (date)

type alias Task =
    { description : String
    , uuid        : String
    , id          : Int
    , urgency     : Float
    , scheduled   : Maybe Date
    , due         : Maybe Date
    , project     : String
    }

decode_task : Decoder Task
decode_task =
    decode Task
        |> required "description" string
        |> required "uuid"        string
        |> required "id"          int
        |> required "urgency"     float
        |> optional "scheduled"   (map Just date) Nothing
        |> optional "due"         (map Just date) Nothing
        |> optional "project"     string ""

decode_tasks : Decoder (List Task)
decode_tasks = list decode_task
