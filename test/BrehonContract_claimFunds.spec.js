const BigNumber = require('bignumber.js');

const BrehonContract = artifacts.require('./BrehonContract.sol');
const defaults = require('../config/deployment_settings.js').defaults;

const contractHelpers = require('../lib/contractHelpers.js');

const startContract = contractHelpers.startContract;
const fastForwardTime = contractHelpers.fastForwardTime;
const assertError = contractHelpers.assertError;
const assertNoError = contractHelpers.assertNoError;
const assertNoErrorWithMsg = assertNoError(false, 'No Exception must be thrown');
const startContractAndRaiseDispute = contractHelpers.startContractAndRaiseDispute;
const verifyEvent = contractHelpers.verifyEvent;
const getMinimumContractAmt = contractHelpers.getMinimumContractAmt;
const getSplitForPrimaryBrehon = contractHelpers.getPercentageSplit(defaults, 0);


/**
 * Spec:
 * + Must use verifyEvent method
 * + Error verification should happen via assertError
 * - Must check for all stages
 **/

contract('BrehonContract claimFunds should only be allowed at one of the conflict resolved stages', () => {
  it('by preventing it from being called at Negotiation stage', () => {
    let brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyB_addr });
      })
      .catch(assertError('Exception was not thrown when claimFunds was triggered during the Negotiation state'));
  });
});

contract('BrehonContract claimFunds should only be allowed at one of the conflict resolved stages', () => {
  it('by preventing it from being called at Execution stage', () => {
    let brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContract(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyA_addr))
      .catch(assertNoErrorWithMsg)
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyB_addr });
      })
      .catch(assertError('Exception was not thrown when claimFunds was triggered during the Execution state'));
  });
});

contract('BrehonContract should allow partyA to be able to withdraw funds', () => {
  const settlement = {
    partyA: getSplitForPrimaryBrehon(60),
    partyB: getSplitForPrimaryBrehon(40),
  };
  const sufficientTime = 60 * 60 * 24 * 5;
  it('after appealPeriod', () => {
    let brehonContract;
    let startingBalance;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContractAndRaiseDispute(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyA_addr, defaults.partyA_addr))
      .catch(assertNoErrorWithMsg)
      .then(function adjudicate() {
        return brehonContract.adjudicate(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.primaryBrehon_addr });
      })
      .then(() => {
        startingBalance = web3.eth.getBalance(defaults.partyA_addr);
      })
      .catch(assertNoErrorWithMsg)
      .then(fastForwardTime(web3, sufficientTime))
      .catch(assertNoErrorWithMsg)
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyA_addr });
      })
      .then(verifyEvent('FundsClaimed', {
        claimingParty: defaults.partyA_addr,
        amount: settlement.partyA,
      }))
      .then((result) => {
        const newBalance = web3.eth.getBalance(defaults.partyA_addr);
        const tx = web3.eth.getTransaction(result.tx);
        const block = web3.eth.getBlock(tx.blockNumber);
        const gasPaid = new BigNumber(block.gasUsed).mul(tx.gasPrice);
        assert.isTrue(startingBalance.minus(gasPaid).plus(settlement.partyA).eq(newBalance));
      })
      .catch(assertNoErrorWithMsg);
  });
});

contract('BrehonContract should not allow partyA to be able to withdraw funds', () => {
  const settlement = {
    partyA: getSplitForPrimaryBrehon(60),
    partyB: getSplitForPrimaryBrehon(40),
  };
  const insufficientTime = 60 * 60 * 24 * 2;
  it('before appealPeriod', () => {
    let brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContractAndRaiseDispute(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyA_addr, defaults.partyA_addr))
      .catch(assertNoErrorWithMsg)
      .then(function adjudicate() {
        return brehonContract.adjudicate(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.primaryBrehon_addr });
      })
      .catch(assertNoErrorWithMsg)
      .then(fastForwardTime(web3, insufficientTime))
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyA_addr });
      })
      .catch(assertError('Exception was not thrown when claimFunds was triggered before the appealPeriod was over'));
  });
});

contract('BrehonContract should allow partyB to be able to withdraw funds', () => {
  const settlement = {
    partyA: getSplitForPrimaryBrehon(60),
    partyB: getSplitForPrimaryBrehon(40),
  };
  const sufficientTime = 60 * 60 * 24 * 5;
  it('after appealPeriod', () => {
    let brehonContract;
    let startingBalance;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContractAndRaiseDispute(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyA_addr, defaults.partyA_addr))
      .catch(assertNoErrorWithMsg)
      .then(function adjudicate() {
        return brehonContract.adjudicate(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.primaryBrehon_addr });
      })
      .then(() => {
        startingBalance = web3.eth.getBalance(defaults.partyB_addr);
      })
      .catch(assertNoErrorWithMsg)
      .then(fastForwardTime(web3, sufficientTime))
      .catch(assertNoErrorWithMsg)
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyB_addr });
      })
      .then(verifyEvent('FundsClaimed', {
        claimingParty: defaults.partyB_addr,
        amount: settlement.partyB,
      }))
      .then((result) => {
        const newBalance = web3.eth.getBalance(defaults.partyB_addr);
        const tx = web3.eth.getTransaction(result.tx);
        const block = web3.eth.getBlock(tx.blockNumber);
        const gasPaid = new BigNumber(block.gasUsed).mul(tx.gasPrice);
        assert.isTrue(startingBalance.minus(gasPaid).plus(settlement.partyB).eq(newBalance));
      })
      .catch(assertNoErrorWithMsg);
  });
});

contract('BrehonContract should not allow partyB to be able to withdraw funds', () => {
  const settlement = {
    partyA: getSplitForPrimaryBrehon(60),
    partyB: getSplitForPrimaryBrehon(40),
  };
  const insufficientTime = 60 * 60 * 24 * 2;
  it('before appealPeriod', () => {
    let brehonContract;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContractAndRaiseDispute(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyA_addr, defaults.partyA_addr))
      .catch(assertNoErrorWithMsg)
      .then(function adjudicate() {
        return brehonContract.adjudicate(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.primaryBrehon_addr });
      })
      .catch(assertNoErrorWithMsg)
      .then(fastForwardTime(web3, insufficientTime))
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyB_addr });
      })
      .catch(assertError('Exception was not thrown when claimFunds was triggered before the appealPeriod was over'));
  });
});

contract('BrehonContract should allow partyA to withdraw funds after a settlement', () => {
  const settlement = {
    partyA: getSplitForPrimaryBrehon(60),
    partyB: getSplitForPrimaryBrehon(40),
  };
  it('at Execution stage', () => {
    let brehonContract;
    let startingBalance;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContract(
        [{
          addr: defaults.partyA_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyA_addr))
      .catch(assertNoErrorWithMsg)
      .then(function proposeSettlement() {
        return brehonContract.proposeSettlement(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.partyB_addr });
      })
      .catch(assertNoErrorWithMsg)
      .then(function acceptSettlement() {
        return brehonContract.acceptSettlement(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.partyA_addr });
      })
      .catch(assertNoErrorWithMsg)
      .then(() => {
        startingBalance = web3.eth.getBalance(defaults.partyA_addr);
      })
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyA_addr });
      })
      .then(verifyEvent('FundsClaimed', {
        claimingParty: defaults.partyA_addr,
        amount: settlement.partyA,
      }))
      .then((result) => {
        const newBalance = web3.eth.getBalance(defaults.partyA_addr);
        const tx = web3.eth.getTransaction(result.tx);
        const block = web3.eth.getBlock(tx.blockNumber);
        const gasPaid = new BigNumber(block.gasUsed).mul(tx.gasPrice);
        assert.isTrue(startingBalance.minus(gasPaid).plus(settlement.partyA).eq(newBalance));
      })
      .catch(function handleException(err) {
        console.error(err);
        assert.isNull(err, 'Exception was thrown when partyA tried to accept settlement');
      });
  });
});

contract('BrehonContract should allow partyB to withdraw funds after a settlement', () => {
  const settlement = {
    partyA: getSplitForPrimaryBrehon(40),
    partyB: getSplitForPrimaryBrehon(60),
  };
  it('at Execution stage', () => {
    let brehonContract;
    let startingBalance;
    return BrehonContract.deployed()
      .then(function captureReference(instance) {
        brehonContract = instance;
        return instance;
      })
      .then(startContract(
        [{
          addr: defaults.partyB_addr,
          value: getMinimumContractAmt(defaults),
        }], defaults.partyB_addr))
      .catch(assertNoErrorWithMsg)
      .then(function proposeSettlement() {
        return brehonContract.proposeSettlement(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.partyA_addr });
      })
      .catch(assertNoErrorWithMsg)
      .then(function acceptSettlement() {
        return brehonContract.acceptSettlement(
          settlement.partyA,
          settlement.partyB,
          { from: defaults.partyB_addr });
      })
      .catch(assertNoErrorWithMsg)
      .then(() => {
        startingBalance = web3.eth.getBalance(defaults.partyB_addr);
      })
      .then(function claimFunds() {
        return brehonContract.claimFunds({ from: defaults.partyB_addr });
      })
      .then(verifyEvent('FundsClaimed', {
        claimingParty: defaults.partyB_addr,
        amount: settlement.partyB,
      }))
      .then((result) => {
        const newBalance = web3.eth.getBalance(defaults.partyB_addr);
        const tx = web3.eth.getTransaction(result.tx);
        const block = web3.eth.getBlock(tx.blockNumber);
        const gasPaid = new BigNumber(block.gasUsed).mul(tx.gasPrice);
        assert.isTrue(startingBalance.minus(gasPaid).plus(settlement.partyB).eq(newBalance));
      })
      .catch(function handleException(err) {
        console.error(err);
        assert.isNull(err, 'Exception was thrown when partyB tried to accept settlement');
      });
  });
});
