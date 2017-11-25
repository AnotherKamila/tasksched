module NextTaskPage exposing (view)

import Navigation
import Html.Attributes   as Html
import Material.Button   as Button
import Material.Icon     as Icon
import Material.Layout   as Layout
import Material.Options  as Options
import Taskwarrior.Model as Taskwarrior
import Taskwarrior.Utils as Taskwarrior

import Html  exposing (Html, text)
import Model exposing (Model, Msg(..))

background_url = "https://source.unsplash.com/daily?nature"

view : Model -> Html Msg
view model =
    [ Layout.render Mdl model.mdl
        [ Layout.fixedHeader, Layout.transparentHeader ]
        { header = [header model]
        , drawer = []
        , tabs   = ([],[])
        , main   = view_next model.tasks
        }
    ] |> Options.div [Options.cs "daily-photo"]

header : Model -> Html Msg
header model =
    [ Layout.spacer
    , Button.render Mdl [10,0] model.mdl
        [ Button.link "#", Button.icon ]
        [ Icon.i "close" ]
    ]
    |> Layout.row [Options.css "opacity" "0.2"]


view_next : List Taskwarrior.Task -> List (Html Msg)
view_next tasks =
    case Taskwarrior.next tasks of
        Nothing -> [text "No next task"]
        Just t  -> [text (t.description)]
