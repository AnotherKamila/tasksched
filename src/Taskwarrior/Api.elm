module Taskwarrior.Api exposing (decode_task, decode_tasks, encode_task, get_request, send_request)

import Result
import Http
import Json.Decode          as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode          as Encode
import Json.Encode.Extra    as Encode

import Config
import Utils.Json.Decode    as Decode
import Utils.Json.Encode    as Encode
import Taskwarrior exposing (Task)

decode_task : Decode.Decoder Task
decode_task =
    Decode.decode Task
        |> Decode.required "description" Decode.string
        |> Decode.required "uuid"        Decode.string
        |> Decode.required "id"          Decode.int
        |> Decode.required "urgency"     Decode.float
        |> Decode.optional "scheduled"   (Decode.map Just Decode.date) Nothing
        |> Decode.optional "due"         (Decode.map Just Decode.date) Nothing
        |> Decode.optional "project"     Decode.string ""

decode_tasks : Decode.Decoder (List Task)
decode_tasks = Decode.list decode_task

encode_task : Task -> Encode.Value
encode_task t = Encode.object [ ("uuid",      Encode.string                    t.uuid     )
                              , ("scheduled", Encode.maybe Encode.date_iso_utc t.scheduled)
                              ]

get_request    = Http.get  Config.api_url decode_tasks
send_request t = Http.post Config.api_url
                    (Http.stringBody "application/json" <| Encode.encode 0 <| encode_task t)
                    (Decode.field "status" Decode.string)
