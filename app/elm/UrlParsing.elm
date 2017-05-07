module UrlParsing exposing (..)

import UrlParser as Url exposing (..)


type Route
    = Create
    | Contract


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Create (s "create")
        , Url.map Contract (s "contract")
        ]