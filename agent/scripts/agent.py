#!/usr/bin/python3
import time
from brownie import accounts, convert, DemandBid
from threading import Thread

import requests

class Agent(Thread):

    def __init__(self, num, password,  ec2_dns, daytime, rounds):
        Thread.__init__(self)
        self.num = num
        self.ec2_dns = ec2_dns
        self.password = password
        self.daytime = daytime
        self.rounds = rounds
        self.prediction = None

    def get_prediction(self):
        # headers = {
        #     'Content-Type': 'application/json',
        # }
        # data = '{"dataset_size": "100"}'
        # response = requests.post(ec2_dns, headers=headers, data=data)
        # self.prediction = int(response.content)
        self.prediction = 4100

    def submit_bet(self, amount):
        bet = bytes(DemandBid[0].returnKeccak256OfEncoded(self.prediction, self.password))
        eth_amount = '{0} ether'.format(amount)
        DemandBid[0].submitBet.transact(bet, {'value':eth_amount,'from':accounts[self.num]})

        print('Agent {0} submitted a bet of {1} for for prediction {2} on day {3}'.format(
            self.num, eth_amount, self.prediction, DemandBid[0].getCurrentDay()
        ))

    def reveal_bet(self):
        DemandBid[0].revealBet(self.prediction, self.password, {'from': accounts[self.num]})

        print('Agent {0} revealed their bet on day {1}'.format(self.num, DemandBid[0].getCurrentDay()))

    def calculate_reward(self):
        DemandBid[0].calculateReward({'from': accounts[self.num]})
        print('Agent {0} calculated reward on day {1}'.format(
            self.num, DemandBid[0].getCurrentDay()
        ))

    def receive_reward(self, day):
        reward = DemandBid[0].getRewardAmount(day, {'from': accounts[self.num]})
        DemandBid[0].withdraw({'from': accounts[self.num]})

        print('Agent {0} received a reward of {1} ether on day {2}'.format(
            self.num, reward, DemandBid[0].getCurrentDay()
        ))
        # print('Agent {0} has balance {1}'.format(self.num, accounts[self.num].balance()))

    def run(self):
        day = 0
        while self.rounds:
            # Day 0
            self.get_prediction()
            self.submit_bet(5)

            # time.sleep(self.daytime*23/24)
            self.reveal_bet()
            time.sleep(self.daytime)

            # Day 1
            time.sleep(self.daytime)

            #Day 2
            self.calculate_reward()
            time.sleep(self.daytime*4/24)
            self.receive_reward(day)
            time.sleep(self.daytime*20/24)

            day += 3
            self.rounds -= 1


class Oracle(Agent):

    def __init__(self, num, password, daytime, rounds, settlements):
        assert num == 0
        Thread.__init__(self)
        self.num = num
        self.password = password
        self.daytime = daytime
        self.rounds = rounds
        self.i = 0
        self.settlements = settlements

    def set_settlement(self, settlement):
        DemandBid[0].setSettlementValue(settlement, {'from': accounts[0]})

        print('The oracle has set the settlement value at: {0}'.format(settlement))

    def run(self):
        time.sleep(self.daytime*2)
        while self.rounds and self.i < len(self.settlements):
            self.set_settlement(self.settlements[self.i])
            print(DemandBid[0].getSettlementValue(0, {'from': accounts[0]}))
            self.i += 1
            self.rounds -= 1
            time.sleep(self.daytime)
            DemandBid[0].updateTotalPotFor2DaysAgoRound({'from': accounts[0]})
