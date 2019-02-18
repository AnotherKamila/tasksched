module NextTaskPage exposing (view)

import Navigation
import Maybe.Extra       as Maybe
import Html.Attributes   as Html
import Material.Button   as Button
import Material.Color    as Color
import Material.Icon     as Icon
import Material.Layout   as Layout
import Material.Options  as Options
import Taskwarrior.Model as Taskwarrior exposing (TwCommand(..))
import Taskwarrior.Utils as Taskwarrior

import Html  exposing    (Html, text)
import Model exposing    (Model, Msg(..))
import TaskView exposing (pretty_task_description)

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
        [ Options.onClick ToggleNext, Button.icon ]
        [ Icon.i "list" ]
    ]
    |> Layout.row [Options.css "opacity" "0.6"]


view_next : Model -> List (Html Msg)
view_next model =
    case Taskwarrior.next model.tasks of
        Nothing -> [ text "No next task." ]
        Just t  -> [ pretty_task model t |> Options.div [Options.cs "next-task"] ]

pretty_task : Model -> Taskwarrior.Task -> List (Html Msg)
pretty_task model t =
    let
        (start_icon, cmd) = if Maybe.isJust t.started then ("pause", Stop) else ("play_arrow", Start)
        start_button = Button.render Mdl [10,1] model.mdl
            [ Button.fab, Button.minifab, Color.background Color.white, Options.onClick (SendCmd cmd t) ]
            [ Icon.i start_icon ]
        done_button = Button.render Mdl [10,2] model.mdl
            [ Button.fab, Button.ripple, Button.colored, Options.onClick (SendCmd Done t) ]
            [ Icon.i "done" ]
    in
        [ text t.project
        , Html.h2 [] [pretty_task_description t]
        ] ++
        [done_button] ++
        (if model.timew then [Html.br [] [], Html.br [] [], start_button] else [])
