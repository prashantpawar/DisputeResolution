module Parties.Models exposing (..)

type alias Party =
  {
    addr : Address
  , deposit : Int
  , contractAccepted : Bool
  }

partyA : Party
partyA = Party "" 0 False

type alias Address =
  String
