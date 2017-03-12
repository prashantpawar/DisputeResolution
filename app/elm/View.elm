module View exposing (..)

import Html exposing (Html, Attribute, a, button, div, img, input, p, span, i, text)
import Html.Attributes exposing (class, href, src, type_, placeholder)
import Html.Events exposing (onClick, onInput)
import Msgs exposing (Msg)
import Models exposing (Model, Address, Wei, PartyModel, BrehonModel, FilePath, Stage(..))


view : Model -> Html Msg
view model =
    div [ class "main-container lg-h4 md-h4 sm-h4" ]
        [ contractDetailView model
        , div [ class "party-list flex flex-wrap" ]
            [ partyView model.partyA "images/partyA.png" model
            , partyView model.partyB "images/partyB.png" model
            ]
        , div [ class "brehon-list flex flex-wrap flex-column" ]
            [ brehonView model.primaryBrehon "images/partyPrimaryBrehon.png" model.loadedAccount
            , brehonView model.secondaryBrehon "images/partySecondaryBrehon.png" model.loadedAccount
            , brehonView model.tertiaryBrehon "images/partyTertiaryBrehon.png" model.loadedAccount
            ]
        ]


contractDetailView : Model -> Html Msg
contractDetailView model =
    div [ class "contract-detail p2" ]
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
        ]


partyView : PartyModel -> FilePath -> Model -> Html Msg
partyView party profileImage model =
    let
        ownerView =
            model.loadedAccount == party.struct.addr

        canStartContract =
            model.contractInfo.partiesAccepted
                == True
                && model.contractInfo.brehonsAccepted
                == True
                && model.contractInfo.stage
                == Negotiation
                && party.struct.contractAccepted
                == True

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
            , div [ class "block" ]
                [ img [ src profileImage ] []
                , text "Address: "
                , textAddress party.struct.addr
                ]
            , div [ class "block" ]
                [ contractAcceptanceView party.struct.contractAccepted ownerView (Msgs.AcceptContractByParty party)
                ]
            , div [ class "deposit-block block my1" ]
                [ div [ class "my1" ]
                    [ text "Deposit: "
                    , text party.struct.deposit
                    , text " Wei"
                    ]
                , depositView ownerView party
                ]
            , div [ class "block" ]
                [ startContractView party ownerView canStartContract
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


startContractView : PartyModel -> Bool -> Bool -> Html Msg
startContractView party ownerView canStartContract =
    case ownerView && canStartContract of
        True ->
            a
                [ class "btn btn-big btn-primary block center rounded h2 black bg-yellow"
                , href "#"
                , onClick (Msgs.StartContract party)
                ]
                [ text "Start Contract" ]

        False ->
            text ""


depositView : Bool -> PartyModel -> Html Msg
depositView ownerView party =
    case ownerView && party.struct.contractAccepted of
        True ->
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

        False ->
            div [] []


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
