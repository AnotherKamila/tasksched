module Main exposing (main)

import Html
import Navigation

import Model
import Update
import View
import Subscriptions

main = Navigation.program Model.NewUrl
    { init   = \location -> (Model.init location, Update.init)
    , update = Update.update
    , view   = View.view
    , subscriptions = Subscriptions.subscriptions
    }
