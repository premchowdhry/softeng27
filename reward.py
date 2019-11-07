import json
import time
from web3 import Web3

ganache_url = "HTTP://127.0.0.1:7545"

web3 = Web3(Web3.HTTPProvider(ganache_url))
web3.eth.defaultAccount = web3.eth.accounts[2]

abi = json.loads('[{"constant":false,"inputs":[],"name":"getBet","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"auctionEnd","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"beneficiary","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"getPot","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"closed","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"moneyInTheContract","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"account","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"auctionEnded","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"getSettlementValue","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"}],"name":"submitBet","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[],"name":"setSettlementValue","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"_biddingTime","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"accountAddress","type":"address"},{"indexed":false,"name":"prediction","type":"uint256"}],"name":"BetSubmission","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"}],"name":"AuctionEnded","type":"event"}]')

bytecode = '608060405273cfc7496aa1a52acfe5bdb51a4dbdcaa86b84573f6000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550735e6595e972ee1c672cfdba71602945343fa0ce8d600160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055503480156100b957600080fd5b506040516020806108b3833981018060405260208110156100d957600080fd5b8101908080519060200190929190505050804201600281905550611068600981905550506107a78061010c6000396000f3fe6080604052600436106100c4576000357c01000000000000000000000000000000000000000000000000000000009004806359c0ef041161008157806359c0ef04146101ff5780635dab24201461022a57806386433374146102815780639accc4f214610298578063a82aeb58146102c3578063bfb294b2146102f1576100c4565b806320835e8c146100c95780632a24f46c146100f457806338af3eed1461011f5780633ccfd60b14610176578063403c9fa8146101a5578063597e1fb5146101d0575b600080fd5b3480156100d557600080fd5b506100de610308565b6040518082815260200191505060405180910390f35b34801561010057600080fd5b50610109610352565b6040518082815260200191505060405180910390f35b34801561012b57600080fd5b50610134610358565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561018257600080fd5b5061018b61037d565b604051808215151515815260200191505060405180910390f35b3480156101b157600080fd5b506101ba610425565b6040518082815260200191505060405180910390f35b3480156101dc57600080fd5b506101e561042f565b604051808215151515815260200191505060405180910390f35b34801561020b57600080fd5b50610214610442565b6040518082815260200191505060405180910390f35b34801561023657600080fd5b5061023f610448565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561028d57600080fd5b5061029661046e565b005b3480156102a457600080fd5b506102ad6105ad565b6040518082815260200191505060405180910390f35b6102ef600480360360208110156102d957600080fd5b81019080803590602001909291905050506105b7565b005b3480156102fd57600080fd5b50610306610707565b005b6000600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000154905090565b60025481565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6000600954600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000154141561041d573373ffffffffffffffffffffffffffffffffffffffff166108fc6008549081150290604051600060405180830381858888f19350505050158015610413573d6000803e3d6000fd5b5060019050610422565b600090505b90565b6000600854905090565b600360009054906101000a900460ff1681565b60085481565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b60025442101515156104e8576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260168152602001807f41756374696f6e206e6f742079657420656e6465642e0000000000000000000081525060200191505060405180910390fd5b600360009054906101000a900460ff16151515610550576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260238152602001806107596023913960400191505060405180910390fd5b6001600360006101000a81548160ff021916908315150217905550610573610707565b7f45806e512b1f4f10e33e8b3cb64d1d11d998d8c554a95e0841fc1c701278bd5d60026040518082815260200191505060405180910390a1565b6000600954905090565b6002544211151515610631576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260168152602001807f41756374696f6e20616c726561647920656e6465642e0000000000000000000081525060200191505060405180910390fd5b80600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000181905550346008600082825401925050819055506001600560008282829054906101000a900460ff160192506101000a81548160ff021916908360ff1602179055503373ffffffffffffffffffffffffffffffffffffffff167f6d53986a353eef11b465aaea3b50728324ccadd2ba64f63bd4b3096aa76c1426346040518082815260200191505060405180910390a250565b611068600981905550610718610722565b61072061073d565b565b601460095481151561073057fe5b0460095403600781905550565b601460095481151561074b57fe5b046009540160068190555056fe61756374696f6e456e642068617320616c7265616479206265656e2063616c6c65642ea165627a7a723058208dc685e68be343add4343b8aa571de10eff97df6f22a623a28fe13bb29f183c20029'



AggregrateDemandBid = web3.eth.contract(abi=abi, bytecode=bytecode)

tx_hash = AggregrateDemandBid.constructor(1).transact()


tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)


contract = web3.eth.contract (
    address = tx_receipt.contractAddress,
    abi = abi
)

contract.functions.submitBet(4200).transact({'from': "0x2A6CC74AFB9D19EfDa92108C860D15837d2373e4", 'value': web3.toWei("2", "ether") })
print(contract.functions.getPot().call())
time.sleep(3)
contract.functions.setSettlementValue()
print(contract.functions.getBet().call())
print(contract.functions.getSettlementValue().call())
print(contract.functions.withdraw().call())

#print(web3.isConnected())

#account1 = "0x7E88bcAF063A1E9866652E3599DEbc37AADDB02E"
#account2 = "0xCC3cbB8cF0C4C6B323A3a70eEc6e9e563Ce68c72"

#account1_private_key = "c2d61369e983fa79adeae38a41d39200805e977d351f5aa87b4665724773c6be"


#build transction
#tx = {
#    'nonce':  web3.eth.getTransactionCount(account1),
#    'to': account2,
#    'value': web3.toWei(1, 'ether'),
#    'gas': 2000000,
#    'gasPrice': web3.toWei(50, 'gwei')
#}

#sign transaction
#signed_tx = web3.eth.account.signTransaction(tx, account1_private_key)
#tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
