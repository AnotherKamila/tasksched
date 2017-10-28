module Commands exposing (..)

import Date
import Task
import Http

import Model exposing (Model, Msg(..))
import Taskwarrior

-- TODO maybe this shouldn't exist and should go to whoever actually provides the commands, like Taskwarrior
get_now : Cmd Msg
get_now = Task.perform NewNow Date.now

get_tasks : Cmd Msg
get_tasks = Http.send NewTasks Taskwarrior.get_request

send_task : Taskwarrior.Task -> Cmd Msg
send_task t = Http.send SentTasks (Taskwarrior.send_request t)
