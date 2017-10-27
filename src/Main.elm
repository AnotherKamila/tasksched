module Main exposing (main)

import Html exposing (..)
import Http
import Date exposing (Date)
import Task
import Json.Decode as Decode
import Material
import Material.Scheme
import Material.Color as Color
import Material.Layout as Layout
import Html5.DragDrop as DragDrop

import App

main = Html.program
    { init   = App.init
    , view   = App.view
    , update = App.update
    , subscriptions = App.subscriptions
    }
