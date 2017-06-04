module Models exposing (..)

import Time.DateTime as DateTime exposing (DateTime, dateTime)
import Time as Time exposing (Time, now)
import UrlParsing exposing (Route)


zeroWei : Wei
zeroWei =
    "0"


initContractModel : ContractModel
initContractModel =
    ContractModel
        initContractInfo
        0
        []
        Nothing
        zeroWei
        zeroWei
        zeroWei
        zeroWei
        (PartyModel (Party Nothing zeroWei False))
        (PartyModel (Party Nothing zeroWei False))
        (BrehonModel (Brehon Nothing False zeroWei zeroWei) Nothing)
        (BrehonModel (Brehon Nothing False zeroWei zeroWei) Nothing)
        (BrehonModel (Brehon Nothing False zeroWei zeroWei) Nothing)


initContractInfo : ContractInfo
initContractInfo =
    ContractInfo Nothing Negotiation zeroWei zeroWei False False Nothing Nothing Nothing 0 False Nothing Nothing


initContractCreatorModel : ContractCreatorModel
initContractCreatorModel =
    ContractCreatorModel
        (Just "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1")
        (Just "0xffcf8fdee72ac11b5c542428b35eef5769c409f0")
        "500"
        "Party A agrees to sell Party B a 1996 Rolex watch for 500 Wei."
        (Just "0x22d491bde2303f2f43325b2108d26f1eaba1e32b")
        "10"
        "100"
        (Just "0xe11ba2b4d45eaed5996cd0823791e0c93114882d")
        "10"
        "100"
        (Just "0xd03ea8624c8c5987235048901fb614fdca89b117")
        "10"
        "100"


type alias Model =
    { history : List (Maybe Route)
    , currentRoute : Maybe Route
    , creatorModel : ContractCreatorModel
    , contractModel : ContractModel
    }


type alias ContractCreatorModel =
    { partyA : Address
    , partyB : Address
    , transactionAmount : Wei
    , termsAndConditions : String
    , primaryBrehonAddr : Address
    , primaryBrehonFixedFee : Wei
    , primaryBrehonDisputeFee : Wei
    , secondaryBrehonAddr : Address
    , secondaryBrehonFixedFee : Wei
    , secondaryBrehonDisputeFee : Wei
    , tertiaryBrehonAddr : Address
    , tertiaryBrehonFixedFee : Wei
    , tertiaryBrehonDisputeFee : Wei
    }


type alias ContractModel =
    { contractInfo : ContractInfo
    , currentTimestamp : Time
    , eventLog : List Event
    , loadedAccount : Address
    , depositField : Wei
    , totalDeposits : Wei
    , settlementPartyAField : Wei
    , settlementPartyBField : Wei
    , partyA : PartyModel
    , partyB : PartyModel
    , primaryBrehon : BrehonModel
    , secondaryBrehon : BrehonModel
    , tertiaryBrehon : BrehonModel
    }


type alias ContractInfo =
    { deployedAt : Address
    , stage : Stage
    , transactionAmount : Wei
    , minimumContractAmt : Wei
    , partiesAccepted : Bool
    , brehonsAccepted : Bool
    , proposedSettlement : Maybe Settlement
    , appealPeriodStart : Maybe DateTime
    , appealPeriodEnd : Maybe DateTime
    , appealPeriodInDays : Int
    , appealPeriodInProgress : Bool
    , awards : Maybe Awards
    , activeBrehon : Address
    }


type alias Settlement =
    { proposingPartyAddr : Address
    , settlementPartyA : Wei
    , settlementPartyB : Wei
    }


type alias Awards =
    { awardPartyA : Wei
    , awardPartyB : Wei
    }


type alias PartyModel =
    { struct : Party
    }


type alias BrehonModel =
    { struct : Brehon
    , awards : Maybe Awards
    }


type alias Party =
    { addr : Address
    , deposit : Wei
    , contractAccepted : Bool
    }


type alias Brehon =
    { addr : Address
    , contractAccepted : Bool
    , fixedFee : Wei
    , disputeFee : Wei
    }


type alias Address =
    Maybe String


type alias FilePath =
    String


type alias Wei =
    String


type alias Parties =
    { partyA : Party
    , partyB : Party
    , totalDeposits : Wei
    }


type alias Brehons =
    { primaryBrehon : Brehon
    , secondaryBrehon : Brehon
    , tertiaryBrehon : Brehon
    }


type Stage
    = Negotiation
    | Execution
    | Dispute
    | Resolved
    | AppealPeriod
    | Appeal
    | SecondAppealPeriod
    | SecondAppeal
    | Completed


type Event
    = ExecutionStartedEvent Int Address Address Wei
    | SettlementProposedEvent Int Address Address Wei Wei
    | DisputeResolvedEvent Int Address Wei Wei
    | ContractDisputedEvent Address Address
    | AppealPeriodStartedEvent DateTime Address Wei Wei
    | AppealRaisedEvent Address Address
    | SecondAppealRaisedEvent Address Address
    | FundsClaimedEvent Address Wei


type AppealLevel
    = First
    | Second
