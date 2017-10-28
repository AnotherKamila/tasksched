module View exposing (view)

import Html
import Date
import Material.Layout
import Material.Scheme
import Maybe.Extra    as Maybe
import Material.Color as Color
import Html5.DragDrop as DragDrop

import Model exposing (Model, Msg(..))
import TaskListViews

view : Model -> Html.Html Msg
view model =
    let dropped_date = DragDrop.getDropId model.dragDrop
    in Material.Scheme.topWithScheme Color.BlueGrey Color.Red <|
        Material.Layout.render Mdl
            model.mdl
            [ Material.Layout.fixedDrawer
            ]
            { header = []
            , drawer = [Html.text "TODO"]
            , tabs   = ([],[])
            , main   = [view_body model (Maybe.join dropped_date)]
            }


view_body : Model -> Maybe Date.Date -> Html.Html Msg
view_body model dropped_date =
    Html.div []
        [ TaskListViews.view { now = model.now
                             , zoomlvl = model.zoomlvl
                             , tasks = model.tasks
                             , dropped_date = dropped_date
                             , dndMsg = DragDropMsg
                             }
        , Html.text model.err
        ]
