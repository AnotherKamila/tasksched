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
        , main   = view_next model
        }
    ] |> Options.div [Options.cs "daily-photo"]

header : Model -> Html Msg
header model =
    [ Layout.spacer
    , Button.render Mdl [10,0] model.mdl
        [ Button.link "#", Button.icon ]
        [ Icon.i "list" ]
    ]
    |> Layout.row [Options.css "opacity" "0.2"]


view_next : Model -> List (Html Msg)
view_next model =
    case Taskwarrior.next model.tasks of
        Nothing -> [ text "No next task" ]
        Just t  -> [ pretty_task model t |> Options.div [Options.cs "next-task"] ]

pretty_task : Model -> Taskwarrior.Task -> List (Html Msg)
pretty_task model t =
    [ text t.project
    , Html.h2 [] [text t.description]
    , Button.render Mdl [10,1] model.mdl
        [ Button.fab, Button.ripple, Button.colored ] -- TODO handle onClick
        [ Icon.i "done" ]
    ]
