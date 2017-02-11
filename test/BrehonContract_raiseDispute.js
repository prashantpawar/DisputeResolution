const R = require('ramda');

const BrehonContract = artifacts.require("./BrehonContract.sol");
const defaults = require('../config/deployment_settings.js').defaults;

const contractHelpers = require('../lib/contractHelpers.js');
const startContract = contractHelpers.startContract;
const getMinimumContractAmt = contractHelpers.getMinimumContractAmt;
const PartyStruct = contractHelpers.PartyStruct;
const BrehonStruct = contractHelpers.BrehonStruct;

const raiseDispute = R.curry(function raiseDispute(disputing_party_addr, brehonContract) {
  return brehonContract.raiseDispute({
    from: disputing_party_addr
  });
});

const startContractAndRaiseDispute = R.curry(function startContractAndRaiseDispute(party_contributions, starting_party_addr, disputing_party_addr, brehonContract) {
    return startContract(party_contributions)(starting_party_addr)(brehonContract)
      .then(() => {
          return raiseDispute(disputing_party_addr)(brehonContract);
      });
});

contract('BrehonContract should allow partyA to raise the dispute', (accounts) => {
  it('when partyA deposited the funds', () => {
    var brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContractAndRaiseDispute(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults)
        }], defaults.partyA_addr, defaults.partyA_addr))
      .then(() => {
        return brehonContract.stage.call().then((stage) => {
            assert.equal(stage.valueOf(), 2, "stage is not set to Stages.Dispute");
        });
      })
      .catch((err) => {
        console.log(err);
        assert.isNull(err, "Exception was thrown when partyA tried to raise a dispute");
      });
  });
});

contract('BrehonContract should allow partyB to raise the dispute', (accounts) => {
  it('when partyB deposited the funds', () => {
    var brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContract([{
        addr: defaults.partyB_addr,
        value:getMinimumContractAmt(defaults)}])(defaults.partyB_addr))
      .then(() => {
        return brehonContract.raiseDispute({
            from: defaults.partyB_addr
        })
      })
      .then(() => {
        return brehonContract.stage.call().then((stage) => {
            assert.equal(stage.valueOf(), 2, "stage is not set to Stages.Dispute");
        });
      })
      .catch((err) => {
        assert.isNull(err, "Exception was thrown when partyB tried to raise a dispute");
      });
  });
});

contract('BrehonContract should allow partyA to raise the dispute', (accounts) => {
  it('when partyB deposited the funds', () => {
    var brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContract([{
        addr: defaults.partyB_addr,
        value: getMinimumContractAmt(defaults)}])(defaults.partyB_addr))
      .then(() => {
        return brehonContract.raiseDispute({
            from: defaults.partyA_addr
        })
      })
      .then(() => {
        return brehonContract.stage.call().then((stage) => {
            assert.equal(stage.valueOf(), 2, "stage is not set to Stages.Dispute");
        });
      })
      .catch((err) => {
        assert.isNull(err, "Exception was thrown when partyA tried to raise a dispute");
      });
  });
});

contract('BrehonContract should allow partyB to raise the dispute', (accounts) => {
  it('when partyA deposited the funds', () => {
    var brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContract([{
        addr: defaults.partyA_addr,
        value: getMinimumContractAmt(defaults)}])(defaults.partyA_addr))
      .then(() => {
        return brehonContract.raiseDispute({
            from: defaults.partyB_addr
        })
      })
      .then(() => {
        return brehonContract.stage.call().then((stage) => {
            assert.equal(stage.valueOf(), 2, "stage is not set to Stages.Dispute");
        });
      })
      .catch((err) => {
        assert.isNull(err, "Exception was thrown when partyB tried to raise a dispute");
      });
  });
});

contract('BrehonContract raiseDispute should only be raised at Execution stage', (accounts) => {
  it('by preventing it from being raised at Negotiaton stage', () => {
    var brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(() => {
        return brehonContract.raiseDispute({from: defaults.partyA_addr});
      })
      .catch((err) => {
        assert.isNotNull(err, "Exception was not thrown when raiseDispute was triggerred at the Negotiation stage");
      });
  });

  it('by preventing it from being raised at Dispute stage', () => {
    var brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(() => {
        return brehonContract.raiseDispute({from: defaults.partyA_addr});
      })
      .catch((err) => {
        assert.isNotNull(err, "Exception was not thrown when raiseDispute was triggerred at the Negotiation stage");
      });
  });
});

contract('BrehonContract raiseDispute should not be raised by unauthorized addresses', (accounts) => {
});
