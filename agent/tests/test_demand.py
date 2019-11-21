import time
import pytest

daytime = 3

@pytest.fixture(scope="module", autouse=True)
def set_up(DemandBid, accounts):
    assert accounts[0].balance() == "100 ether"
    assert accounts[1].balance() == "100 ether"
    assert len(accounts) == 10
    accounts[0].deploy(DemandBid, 3)

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass

def test_account0_paid_gas(accounts):
    assert accounts[0].balance() < "100 ether"
    assert accounts[1].balance() == "100 ether"


def test_contract_has_no_money(DemandBid, accounts):
    assert DemandBid[0].balance() == "0 ether"


def test_submitBet(DemandBid, accounts):
    prediction = 3000
    password = 'Hello'
    bet = bytes(DemandBid[0].returnKeccak256OfEncoded(prediction, password))
    DemandBid[0].submitBet.transact(bet, {'value':'5 ether','from': accounts[1]})
    assert DemandBid[0].balance() == "5 ether"
    assert accounts[1].balance() < "95 ether"

def test_intermediate_steps(DemandBid, accounts):
    prediction = 3000
    password = 'Hello'
    bet = bytes(DemandBid[0].returnKeccak256OfEncoded(prediction, password))
    DemandBid[0].submitBet.transact(bet, {'value':'5 ether','from': accounts[1]})
    time.sleep(daytime*23/24)
    DemandBid[0].revealBet(prediction, password)
    DemandBid[0].getRevealedBet({'from': accounts[1]})

    time.sleep(daytime)
    DemandBid[0].setSettlementValue(3000, {'from': accounts[0]})
    DemandBid[0].calculateReward({'from': accounts[1]})
    value = DemandBid[0].getRewardAmount(0,{'from': accounts[1]})
    assert value == "5 ether"
    assert DemandBid[0].balance() == "5 ether"
    assert accounts[1].balance() < "95 ether"

def test_withdraw(DemandBid, accounts):
    prediction = 3000
    password = 'Hello'
    bet = bytes(DemandBid[0].returnKeccak256OfEncoded(prediction, password))
    DemandBid[0].submitBet.transact(bet, {'value':'5 ether','from': accounts[1]})
    time.sleep(daytime*23/24)
    DemandBid[0].revealBet(prediction, password)
    time.sleep(daytime/24)
    time.sleep(daytime)
    DemandBid[0].setSettlementValue(3000, {'from': accounts[0]})
    DemandBid[0].calculateReward({'from': accounts[1]})
    time.sleep(daytime*3/24)
    DemandBid[0].withdraw({'from': accounts[1]})
    assert DemandBid[0].balance() == "0 ether"
    assert accounts[1].balance() > "99 ether"
