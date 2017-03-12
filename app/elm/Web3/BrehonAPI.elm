port module Web3.BrehonAPI exposing (..)

import Models exposing (Address, ContractInfo, Parties, Party, PartyModel, Brehon, BrehonModel, Brehons, Wei)


port requestAccounts : Int -> Cmd msg


port receiveAccounts : (List Address -> msg) -> Sub msg


port requestContractInfo : Int -> Cmd msg


port receiveContractInfo : (( Address, Int, Wei ) -> msg) -> Sub msg


port requestAllParties : Int -> Cmd msg


port receiveAllParties : (Parties -> msg) -> Sub msg


port requestAllBrehons : Int -> Cmd msg


port receiveAllBrehons : (Brehons -> msg) -> Sub msg


port requestAcceptContractByParty : Party -> Cmd msg


port requestAcceptContractByBrehon : Brehon -> Cmd msg


port requestDepositFunds : ( PartyModel, String ) -> Cmd msg


port requestConsoleLog : String -> Cmd msg
