#!/usr/bin/python3
import time
from brownie import *

daytime = 5

def main():
    accounts[0].deploy(DemandBid, daytime)
    prediction = 100
    password = 'there'
    password2 = 'theree'
    bet = bytes(DemandBid[0].returnKeccak256OfEncoded(prediction, password))
    print(bet)

    DemandBid[0].submitBet.transact(bet, {'value':'5 ether','from': accounts[1]})

    time.sleep(daytime*23/24)

    result = DemandBid[0].revealBet(prediction, password)
    print(type(result))

    time.sleep(daytime/24)
    time.sleep(daytime)

    DemandBid[0].setSettlementValue(0, {'from': accounts[0]})
    DemandBid[0].calculateReward({'from': accounts[1]})
    value = DemandBid[0].getRewardAmount(0,{'from': accounts[1]})

    print(value)

    time.sleep(daytime*3/24)

    DemandBid[0].withdraw({'from': accounts[1]})

    print(DemandBid[0].balance())
    print(accounts[0].balance())
    print(accounts[1].balance())
