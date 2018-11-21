module Taskwarrior.Api exposing (get_request, send_request, get_timew_status)

import Http
import Json.Decode          as Decode
import Json.Decode.Pipeline as Decode
import Json.Encode          as Encode
import Json.Encode.Extra    as Encode

import Config
import Utils.Json.Decode    as Decode
import Utils.Json.Encode    as Encode
import Taskwarrior.Model exposing (Task, TaskListResponse, TwCommand(..))

decode_task : Decode.Decoder Task
decode_task =
    Decode.decode Task
        |> Decode.required "description" Decode.string
        |> Decode.required "uuid"        Decode.string
        |> Decode.required "id"          Decode.int
        |> Decode.required "urgency"     Decode.float
        |> Decode.optional "scheduled"   (Decode.map Just Decode.date) Nothing
        |> Decode.optional "due"         (Decode.map Just Decode.date) Nothing
        |> Decode.optional "start"       (Decode.map Just Decode.date) Nothing
        |> Decode.optional "project"     Decode.string ""
        |> Decode.optional "task_url"    Decode.string ""

decode_tasks : Decode.Decoder TaskListResponse
decode_tasks =
    Decode.decode TaskListResponse
        |> Decode.optional "filter"  Decode.string ""
        |> Decode.required "tasks"  (Decode.list  decode_task)

encode_task : Task -> Encode.Value
encode_task t = Encode.object [ ("uuid",      Encode.string                    t.uuid     )
                              , ("scheduled", Encode.maybe Encode.date_iso_utc t.scheduled)
                              ]

cmd_to_string : TwCommand -> String
cmd_to_string cmd = case cmd of
    Modify -> "mod"
    Done   -> "done"
    Start  -> "start"
    Stop   -> "stop"

encode_with_cmd : Task -> TwCommand -> Encode.Value
encode_with_cmd t cmd = Encode.object [ ("task",    encode_task t)
                                      , ("command", Encode.string (cmd_to_string cmd))
                                      ]


tasks_url = Config.api_url ++ "/tasks"
timew_url = Config.api_url ++ "/timew"

get_request : String -> Http.Request TaskListResponse
get_request filter =
    let url = String.join ""
              (tasks_url :: (if String.isEmpty filter then [] else ["?filter=", filter]))
    in
        Http.get url decode_tasks

send_request : TwCommand -> Task -> Http.Request String
send_request cmd t = Http.post tasks_url
                    (Http.stringBody "application/json" <| Encode.encode 0 <| encode_with_cmd t cmd)
                    (Decode.field "status" Decode.string)

get_timew_status : Http.Request Bool
get_timew_status = Http.get timew_url (Decode.field "enabled" Decode.bool)
