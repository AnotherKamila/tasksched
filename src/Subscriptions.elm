module Subscriptions exposing (subscriptions)

import Material.Layout

import Model exposing (Model, Msg(..))

subscriptions : Model -> Sub Msg
subscriptions model = Material.Layout.subs Mdl model.mdl
