module Main exposing (main)

import Html
import Navigation

import Model
import UrlState exposing (url_state)
import Update
import View
import Subscriptions

program_init : Navigation.Location -> (Model.Model, Cmd Model.Msg)
program_init location =
    let model = Model.init location
    in (model, Update.refresh (url_state model))

main = Navigation.program Model.NewUrl
    { init   = program_init
    , update = Update.update
    , view   = View.view
    , subscriptions = Subscriptions.subscriptions
    }
