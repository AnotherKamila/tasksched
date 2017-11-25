module NextTaskPage exposing (view)

import Material.Layout as Layout
import Html            exposing (Html, text)

import Model exposing (Model, Msg(..))
import Taskwarrior.Model as Taskwarrior
import Taskwarrior.Utils as Taskwarrior

view : Model -> Html Msg
view model = Layout.render Mdl model.mdl
    [ Layout.fixedHeader, Layout.transparentHeader ]
    { header = []
    , drawer = []
    , tabs   = ([],[])
    , main   = view_next model.tasks
    }

view_next : List Taskwarrior.Task -> List (Html Msg)
view_next tasks =
    case (Taskwarrior.next tasks) of
        Nothing -> [text "No next task"]
        Just t  -> [text (t.description)]
