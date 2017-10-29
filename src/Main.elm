module Main exposing (main)

import Html

import Model
import Update
import View
import Subscriptions

main = Html.program
    { init   = (Model.init, Update.init)
    , update = Update.update
    , view   = View.view
    , subscriptions = Subscriptions.subscriptions
    }
