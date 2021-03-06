port module Web3.BrehonAPI exposing (..)

import Models
    exposing
        ( Address
        , Event
        , Settlement
        , Awards
        , Parties
        , Party
        , PartyModel
        , Brehon
        , BrehonModel
        , Brehons
        , Wei
        )


port requestAccounts : Int -> Cmd msg


port receiveAccounts : (List Address -> msg) -> Sub msg


port requestContractInfo : Int -> Cmd msg


port receiveContractInfo : (( Address, Int, Wei, Wei, Int, Address, Maybe Awards ) -> msg) -> Sub msg


port requestAllParties : Int -> Cmd msg


port receiveAllParties : (Parties -> msg) -> Sub msg


port requestAllBrehons : Int -> Cmd msg


port receiveAllBrehons : (Brehons -> msg) -> Sub msg


port requestAcceptContractByParty : Party -> Cmd msg


port requestAcceptContractByBrehon : Brehon -> Cmd msg


port requestDepositFunds : ( PartyModel, String ) -> Cmd msg


port requestConsoleLog : String -> Cmd msg


port requestStartContract : Address -> Cmd msg


port requestProposeSettlement : ( Address, Wei, Wei ) -> Cmd msg


port requestProposedSettlement : Int -> Cmd msg


port receiveProposedSettlement : (Maybe Settlement -> msg) -> Sub msg


port requestAcceptSettlement : ( Address, Wei, Wei ) -> Cmd msg


port requestAllEvents : Int -> Cmd msg


port receiveExecutionStartedEvent : (( Int, Address, Address, Wei ) -> msg) -> Sub msg


port receiveSettlementProposedEvent : (( Int, Address, Address, Wei, Wei ) -> msg) -> Sub msg


port receiveDisputeResolvedEvent : (( Int, Address, Wei, Wei ) -> msg) -> Sub msg


port receiveContractDisputedEvent : (( Address, Address ) -> msg) -> Sub msg


port receiveAppealPeriodStartedEvent : (( String, Address, Wei, Wei ) -> msg) -> Sub msg


port receiveAppealRaisedEvent : (( Address, Address ) -> msg) -> Sub msg


port receiveSecondAppealRaisedEvent : (( Address, Address ) -> msg) -> Sub msg


port receiveFundsClaimedEvent : (( Address, Wei ) -> msg) -> Sub msg


port requestRaiseDispute : Address -> Cmd msg


port requestRaiseAppeal : Address -> Cmd msg


port requestRaiseSecondAppeal : Address -> Cmd msg


port requestAdjudicate : ( Address, Wei, Wei ) -> Cmd msg


port receiveAwards : (Maybe Awards -> msg) -> Sub msg


port requestWithdrawFunds : Address -> Cmd msg
