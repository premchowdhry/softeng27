pragma solidity 0.5.3;

contract AggregrateDemandBid {
  //Beneficiary is the account that holds all the bids
  address public beneficiary;
  //time periods in seconds or seconds since 1970-01-01
  uint public auctionEnd;

  //Current state of market (open[true]/close[false])
  //By default initialized to false
  bool public closed;

  //storing prediction amount corresponding to an address
  mapping (address => Agent_Details) agent_predictions;
  //number of bets
  uint8 private agentCount;
  uint private highestInterval;
  uint private lowestInterval;

  //settlement value (actual consumption)
  uint settlementValue;

  struct Agent_Details {
    uint guess;
    uint reward;
    bool claimed;
  }

  //create a simple
  constructor {
    uint _biddingTime,
    address payable _beneficiary
  } public {
    beneficiary = _beneficiary;
    auctionEnd = now + _biddingTime;
  }

  // Log the event about a bet submission being made by an address and its prediction
  event BetSubmission(address indexed accountAddress, uint prediction);
  // Calculate the shares that agent won
  event AuctionEnded(uint amount);

  //event Transfer(address indexed _from, address indexed _to, uint256 _value);

  /*
  //calculates the money gain after settement value is found
  //if an agent wins, they get double the amount of the bet placed
  function payout() public payable {
      if (game.agent.guess == settlementValue) {
        game.agent.address.transfer(game.betAmount * 2);
      }
  }*/

  //Bid on the auction with the value send together with this transaction
  function submitBet() public payable {
    //No arguments are necessary, all

    //Revert the call if the bidding period is over.
    require (now <= auctionEnd, "Auction already ended.");

    agent_predictions[msg.sender].guess =  msg.value;

    agentCount += 1;

    emit BetSubmission(msg.sender, msg.value);

  }

  //Agent could withdraw the bid at the end of the day
  function withdraw() public returns (bool) {

    if (agent_predictions[msg.sender].guess >= lowestInterval &&
    agent_predictions[msg.sender].guess <= highestInterval &&
    !agent_predictions[msg.sender].claimed && closed) {
      msg.sender.send(2);
      agent_predictions[msg.sender].claimed = true;
      return true;
    }
    /*uint amount = agent_predictions[msg.sender].reward;
    if (amount > 0) {
      agent_predictions[msg.sender].reward = 0;
      msg.sender.send(amount);
      agent_predictions[msg.sender].claimed = true;
      return true;

    }*/
    return false;
  }

  //End the auction and calculates which agent gets the rewards
  function auctionEnded() public {
    require(now >= auctionEnd, "Auction not yet ended.");
    require(!closed, "auctionEnd has already been called.");

    closed = true;
    //call findClosestToSettlement to find the value for the address closest to
    //the settlement value and it's bet
    //uint money_share = findMoneyShare();
    setSettlementValue();

    emit AuctionEnded(2);
  }

  function findHighestInterval() private {
    highestInterval = settlementValue + 0.05 * settlementValue;
  }

  function findLowestInterval() private {
    lowestInterval = settlementValue - 0.05 * settlementValue;
  }

  function findNumberOfAgentWithinInterval() private returns (uint) {

  }

  function findMoneyShare() private returns (uint) {
    return getPot() / findNumberOfAgentWithinInterval();
  }

  function getPot() private returns (uint) {
      return agentCount;
  }

  function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
    if (balances[msg.sender] < amount) return false;
    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    emit Transfer(msg.sender, receiver, amount);
    return true;
  }

  function getBalanceInEth(address addr) public view returns(uint){
    return ConvertLib.convert(getBalance(addr),2);
  }

  function getBalance(address addr) public view returns(uint) {
    return balances[addr];
  }

  //get settlementValue from energy supplier and set the settlement Value
  function setSettlementValue() public {
    //settlementValue = get_settlement_from_energy_supplier();
    settlementValue = 4200;
    findLowestInterval();
    findHighestInterval();
  }
}
