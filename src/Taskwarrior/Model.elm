module Taskwarrior.Model exposing (Uuid, Task)

import Date

type alias Uuid = String

type alias Task =
    { description : String
    , uuid        : Uuid
    , id          : Int
    , urgency     : Float
    , scheduled   : Maybe Date.Date
    , due         : Maybe Date.Date
    , project     : String
    , task_url    : String
    }
