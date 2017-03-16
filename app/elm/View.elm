module View exposing (..)

import Html exposing (Html, Attribute, a, button, div, img, input, label, p, span, i, text)
import Html.Attributes exposing (class, href, src, type_, placeholder)
import Html.Events exposing (onClick, onInput)
import Msgs exposing (Msg)
import Models exposing (Model, Address, ContractInfo, Settlement, Wei, PartyModel, BrehonModel, FilePath, Stage(..))


view : Model -> Html Msg
view model =
    div [ class "main-container lg-h4 md-h4 sm-h4 clearfix" ]
        [ contractDetailView model
        , div [ class "col col-8" ]
            [ div [ class "party-list flex flex-wrap" ]
                [ partyView model.partyA "images/partyA.png" model
                , partyView model.partyB "images/partyB.png" model
                ]
            , div [ class "brehon-list flex flex-wrap flex-column" ]
                [ brehonView model.primaryBrehon "images/partyPrimaryBrehon.png" model.loadedAccount
                , brehonView model.secondaryBrehon "images/partySecondaryBrehon.png" model.loadedAccount
                , brehonView model.tertiaryBrehon "images/partyTertiaryBrehon.png" model.loadedAccount
                ]
            ]
        , div [ class "col col-2" ] [ text "log" ]
        ]


contractDetailView : Model -> Html Msg
contractDetailView model =
    let
        showProposedSettlement =
            model.contractInfo.stage /= Completed
    in
        div [ class "contract-detail p2 col col-2" ]
            [ div []
                [ text "Contract Deployed At: "
                , textAddress model.contractInfo.deployedAt
                ]
            , div []
                [ text "Loaded Account: "
                , textAddress model.loadedAccount
                ]
            , div []
                [ text "Total Deposits: "
                , text model.totalDeposits
                , text " Wei"
                ]
            , div []
                [ text "Contract Stage: "
                , text (toString model.contractInfo.stage)
                ]
            , div []
                [ text "Transaction Amount : "
                , text model.contractInfo.transactionAmount
                ]
            , div []
                [ text "Parties Accepted : "
                , text (toString model.contractInfo.partiesAccepted)
                ]
            , div []
                [ text "Brehons Accepted : "
                , text (toString model.contractInfo.brehonsAccepted)
                ]
            , div []
                [ proposedSettlementView model.contractInfo.proposedSettlement
                    |> conditionalBlock showProposedSettlement
                ]
            ]


canPartyStartContract : PartyModel -> ContractInfo -> Bool
canPartyStartContract party contractInfo =
    (contractInfo.partiesAccepted && contractInfo.brehonsAccepted)
        && contractInfo.stage
        == Negotiation
        && party.struct.contractAccepted


canPartyProposeSettlement : PartyModel -> ContractInfo -> Bool
canPartyProposeSettlement party contractInfo =
    contractInfo.stage
        /= Negotiation
        && contractInfo.stage
        /= Completed


canPartyAcceptSettlement : PartyModel -> ContractInfo -> Bool
canPartyAcceptSettlement party contractInfo =
    case contractInfo.proposedSettlement of
        Nothing ->
            False

        Just settlement ->
            settlement.proposingPartyAddr
                /= party.struct.addr
                && contractInfo.stage
                /= Completed


canDepositIntoContract : PartyModel -> ContractInfo -> Bool
canDepositIntoContract party contractInfo =
    party.struct.contractAccepted
        && contractInfo.stage
        /= Completed


partyView : PartyModel -> FilePath -> Model -> Html Msg
partyView party profileImage model =
    let
        ownerView =
            model.loadedAccount == party.struct.addr

        canDeposit =
            ownerView
                && canDepositIntoContract party model.contractInfo

        canStartContract =
            ownerView
                && canPartyStartContract party model.contractInfo

        canProposeSettlement =
            ownerView
                && canPartyProposeSettlement party model.contractInfo

        canAcceptSettlement =
            ownerView
                && canPartyAcceptSettlement party model.contractInfo

        viewClass ownerView cssClass =
            case ownerView of
                True ->
                    cssClass ++ " white bg-maroon border-gray"

                False ->
                    cssClass
    in
        div
            [ "party-view mx-auto max-width-1 border rounded m1 p2"
                |> viewClass ownerView
                |> class
            ]
            [ text "Party"
            , div [ class "block p1" ]
                [ img [ src profileImage ] []
                , text "Address: "
                , textAddress party.struct.addr
                ]
            , div [ class "block p1" ]
                [ contractAcceptanceView party.struct.contractAccepted ownerView (Msgs.AcceptContractByParty party)
                ]
            , div [ class "deposit-block block my1 p1" ]
                [ div [ class "my1" ]
                    [ text "Deposit: "
                    , text party.struct.deposit
                    , text " Wei"
                    ]
                , depositView party
                ]
                |> conditionalBlock canDeposit
            , div
                [ class "block my1 p1" ]
                [ startContractView party
                ]
                |> conditionalBlock canStartContract
            , div
                [ class "block my2 p1 border" ]
                [ label [ class "label label-title bg-maroon h4" ] [ text "Settlement" ]
                , proposeSettlementView party
                ]
                |> conditionalBlock canProposeSettlement
            , div
                [ class "block my2 p1 border" ]
                [ acceptSettlementView party model.contractInfo.proposedSettlement
                ]
                |> conditionalBlock (ownerView && canAcceptSettlement)
            ]


proposeSettlementView : PartyModel -> Html Msg
proposeSettlementView party =
    div [ class "propose-settlement" ]
        [ label [ class "label" ] [ text "Award for Party A" ]
        , input
            [ class "input"
            , placeholder "0 Wei"
            , onInput Msgs.SettlementPartyAFieldChanged
            ]
            []
        , label [ class "label" ] [ text "Award for Party B" ]
        , input
            [ class "input"
            , placeholder "0 wei"
            , onInput Msgs.SettlementPartyBFieldChanged
            ]
            []
        , button
            [ class "btn btn-primary"
            , onClick (Msgs.ProposeSettlement party)
            ]
            [ text "Propose Settlement" ]
        ]


acceptSettlementView : PartyModel -> Maybe Settlement -> Html Msg
acceptSettlementView party proposedSettlement =
    case proposedSettlement of
        Nothing ->
            div [] []

        Just settlement ->
            div [ class "accept-settlement" ]
                [ label [ class "label h4" ]
                    [ text "Award for Party A: "
                    , text settlement.settlementPartyA
                    ]
                , label [ class "label h4" ]
                    [ text "Award for Party B: "
                    , text settlement.settlementPartyB
                    ]
                , button
                    [ class "btn btn-primary"
                    , onClick (Msgs.AcceptSettlement party)
                    ]
                    [ text "Accept Settlement" ]
                ]


proposedSettlementView : Maybe Settlement -> Html Msg
proposedSettlementView proposedSettlement =
    case proposedSettlement of
        Nothing ->
            div [] []

        Just settlement ->
            div []
                [ div []
                    [ text "Proposing Party: "
                    , textAddress settlement.proposingPartyAddr
                    ]
                , div []
                    [ text "Award Party A: "
                    , text settlement.settlementPartyA
                    ]
                , div []
                    [ text "Award Party B: "
                    , text settlement.settlementPartyB
                    ]
                ]


brehonView : BrehonModel -> FilePath -> Address -> Html Msg
brehonView brehon profileImage loadedAccount =
    let
        ownerView =
            loadedAccount == brehon.struct.addr

        viewClass ownerView cssClass =
            case ownerView of
                True ->
                    cssClass ++ " white bg-maroon border-gray"

                False ->
                    cssClass
    in
        div
            [ "brehon-view mx-auto max-width-1 border rounded m1 p2"
                |> viewClass ownerView
                |> class
            ]
            [ text "Brehon"
            , div [ class "block" ]
                [ img [ src profileImage ] []
                , p [] [ text "Address: " ]
                , textAddress brehon.struct.addr
                ]
            , contractAcceptanceView brehon.struct.contractAccepted ownerView (Msgs.AcceptContractByBrehon brehon)
            ]


startContractView : PartyModel -> Html Msg
startContractView party =
    a
        [ class "btn btn-big btn-primary block center rounded h2 black bg-yellow"
        , href "#"
        , onClick (Msgs.StartContract party)
        ]
        [ text "Start Contract" ]


depositView : PartyModel -> Html Msg
depositView party =
    div [ class "deposit-funds my1 clearfix flex" ]
        [ input
            [ class "input mb0 mr2"
            , placeholder "0 Wei"
            , type_ "number"
            , onInput Msgs.DepositFieldChanged
            ]
            []
        , a
            [ class "btn center rounded white bg-olive"
            , href "#"
            , onClick (Msgs.DepositFunds party)
            ]
            [ text "Deposit" ]
        ]


contractAcceptanceView : Bool -> Bool -> Msg -> Html Msg
contractAcceptanceView isContractAccepted ownerView messageDispatch =
    case isContractAccepted of
        True ->
            p []
                [ i [ class "fa fa-check-circle mr1 green" ] []
                , text "Contract Accepted"
                ]

        False ->
            if ownerView then
                div [ class "fit" ]
                    [ button
                        [ class "btn btn-primary btn-big block mx-auto"
                        , type_ "button"
                        , onClick (messageDispatch)
                        ]
                        [ text "Accept Contract" ]
                    ]
            else
                p []
                    [ i [ class "fa fa-minus-square mr1 red" ] []
                    , text "Contract Not Accepted"
                    ]


textAddress : Address -> Html Msg
textAddress address =
    case address of
        Nothing ->
            span [ class "" ]
                [ text "<Unassigned>"
                ]

        Just val ->
            span [ class "address char-10" ]
                [ text val
                ]


conditionalBlock : Bool -> Html Msg -> Html Msg
conditionalBlock flag htmlEl =
    case flag of
        True ->
            htmlEl

        False ->
            text ""