module View exposing (view)

import Material.Button
import Material.Layout
import Material.Scheme
import Date.Extra       as Date
import Maybe.Extra      as Maybe
import Material.Color   as Color
import Material.Icon    as Icon
import Html5.DragDrop   as DragDrop
import Html             exposing (Html, text)
import Material.Options exposing (cs, css, div, onClick)

import Model exposing (Model, Msg(..))
import TaskListViews

view : Model -> Html.Html Msg
view model =
    Material.Scheme.topWithScheme Color.BlueGrey Color.Red <|
        Material.Layout.render Mdl
            model.mdl
            [ Material.Layout.fixedDrawer
            --, Material.Layout.transparentHeader
            , Material.Layout.fixedHeader
            ]
            { header = header model
            , drawer = drawer model
            , tabs   = ([],[])
            , main   = [view_body model]
            }


-- BODY --

view_body : Model -> Html.Html Msg
view_body model =
    let dropped_date = DragDrop.getDropId model.dragDrop |> Maybe.join
    in div []
        [ TaskListViews.view { now = model.now
                             , zoom = model.zoom
                             , tasks = model.tasks
                             , dropped_date = dropped_date
                             , dndMsg = DragDropMsg
                             }
        , text model.err
        ]


-- HEADER --

header model =
    [ Material.Layout.row [] (
            [ Material.Layout.title [] [Html.text ("Tasks by " ++ zoom_name model.zoom)]
            , Material.Layout.spacer
            ] ++ (rightbuttons model)
        )
    ]

rightbuttons model =
    [ Material.Button.render Mdl [1,0] model.mdl
        [ Material.Options.onClick RefreshWanted, Material.Button.icon ]
        [ Icon.i "refresh" ]
    ]

--menu model = Material.Menu.render Mdl [1,0] model.mdl
--    [ Material.Menu.bottomRight ]
--    [ Material.Menu.item [ Material.Menu.onSelect RefreshWanted ] [ Html.text "Refresh tasks" ]
--    ]

-- DRAWER --

zooms = [Date.Hour, Date.Day, Date.Week, Date.Month] -- The zoom selection menu

drawer model =
    let zoom_is_active z = if model.zoom == z then active else [Material.Options.nop]
        zoomlink z       = mlink (NewZoom z) (zoom_name z) (zoom_is_active z)
        zooms_nav = zooms |> List.map zoomlink
    in
        [ Material.Layout.title [] [text "Tasks"]
        , divider [css "margin" "-1px 0"] []
        , Material.Layout.navigation []
            zooms_nav
        ]


-- HELPERS --

mlink msg txt o = Material.Layout.link (onClick msg :: o) [text txt]
active = [cs "is-active", Color.text Color.accent, css "font-weight" "bold"] -- TODO put CSS into CSS
zoom_name z = toString z ++ "s"
divider opts = Material.Options.styled Html.hr (css "border-color" "#ddd" :: opts)
