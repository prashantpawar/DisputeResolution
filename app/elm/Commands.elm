module Commands exposing (..)

import Models exposing (Address)
import Msgs exposing (Msg)
import Web3.BrehonAPI exposing (..)


loadWeb3Accounts : Cmd Msg
loadWeb3Accounts =
    requestAccounts 0


loadDeployedAt : Cmd Msg
loadDeployedAt =
    requestDeployedAt 0


loadAllParties : Cmd Msg
loadAllParties =
    requestAllParties 0


loadAllBrehons : Cmd Msg
loadAllBrehons =
    requestAllBrehons 0


acceptContract : Address -> Cmd Msg
acceptContract addr =
    requestAcceptContract addr
