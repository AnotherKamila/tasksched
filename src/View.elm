module View exposing (view)

import Date
import Material.Layout
import Material.Scheme
import Date.Extra       as Date
import Maybe.Extra      as Maybe
import Material.Color   as Color
import Html5.DragDrop   as DragDrop
import Html             exposing (Html, text)
import Material.Options exposing (css, div, onClick)

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


header model =
    [ Material.Layout.row []
        [ Material.Layout.title [] [Html.text ("Tasks by " ++ zoom_name model.zoom)]
        ]
    ]

drawer model =
    let zooms       = [Date.Hour, Date.Day, Date.Week, Date.Month]
        mlink m t o = Material.Layout.link (onClick m :: o) [text t]
        active      = [Color.text Color.accent, css "font-weight" "bold"]
    in
        [ Material.Layout.title [] [text "Tasks"]
        , divider [css "margin" "-1px 0"] []
        , Material.Layout.navigation []
            (zooms |> List.map (\z -> mlink (NewZoom z) (zoom_name z) (if model.zoom == z then active else [Material.Options.nop])))
        ]

zoom_name z = toString z ++ "s"

divider opts =
    Material.Options.styled Html.hr (css "border-color" "#ddd" :: opts)
