-- Defines Task and knows how to parse it from JSON.
module Taskwarrior exposing (..)

import Json.Decode          exposing (Decoder, int, string, float, list, map, field)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode          as Encode
import Json.Encode.Extra    as Encode
import Date                 exposing (Date)
import Result               exposing (Result)
import Http

import Config
import Utils.Json.Decode    exposing (date)
import Utils.Json.Encode    exposing (date_iso_utc)

type alias Uuid = String

type alias Task =
    { description : String
    , uuid        : Uuid
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

encode_task : Task -> Encode.Value
encode_task t = Encode.object [ ("uuid",      Encode.string                  t.uuid     )
                              , ("scheduled", Encode.maybe date_iso_utc t.scheduled)
                              ]

get_request    = Http.get  Config.api_url decode_tasks
send_request t = Http.post Config.api_url
                    (Http.stringBody "application/json" <| Encode.encode 0 <| encode_task t)
                    (field "status" string)
