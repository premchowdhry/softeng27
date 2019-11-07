pragma solidity 0.5.11;

contract AggregrateDemandBid {
  //Beneficiary is the account that holds all the bids
  address public beneficiary = 0xcfc7496aa1a52ACfE5bdB51A4dbDcAa86B84573F;
  address public account = 0x5e6595e972EE1C672CfdbA71602945343fA0ce8D;
  //time periods in seconds or seconds since 1970-01-01
  uint public auctionEnd;

  //Current state of market (open[true]/close[false])
  //By default initialized to false
  bool public closed;

  address payable[] public players;

  //storing prediction amount corresponding to an address
  mapping (address => Agent_Details) agent_predictions;

  mapping (uint => mapping (address => Agent_Details)) agent_predictions_daily;

  //incrementor starting from when initializing the contract
  uint day_increment = 1;

  //number of bets
  uint8 private agentCount;
  uint private highestInterval;
  uint private lowestInterval;
  uint public moneyInTheContract;

  //settlement value (actual consumption)
  uint settlementValue;

  struct Agent_Details {
    uint guess;
    uint reward;
    bool claimed;
  }

  //create a simple
  constructor (
    uint _biddingTime
    //address payable _beneficiary
  ) public {
    //beneficiary = _beneficiary;
    auctionEnd = now + _biddingTime;
  }

  // Log the event about a bet submission being made by an address and its prediction
  event BetSubmission(address indexed accountAddress, uint prediction);
  // Calculate the shares that agent won
  event AuctionEnded(uint day_number, uint amount);

  //event Transfer(address indexed _from, address indexed _to, uint256 _value);



  //Only allowed to play if he didn't already play
  //Bid on the auction with the value send together with this transaction
  function submitBet(uint _guess) public payable {



    //No arguments are necessary, all

    //Check if the player already exist
    require(!checkPlayerExists(msg.sender));

    //Revert the call if the bidding period is over.
    require (now <= auctionEnd, "Auction already ended.");

    //rejct payment of 0 ether
    require (msg.value > 0);



    //set agent predictionss
    agent_predictions[msg.sender].guess =  _guess;

    //add the adress of the player to the players array
    players.push(msg.sender);

    moneyInTheContract += msg.value;

    agentCount += 1;

    emit BetSubmission(msg.sender, msg.value);

  }

  //Agent could withdraw the bid at the end of the day
  function withdraw() public returns (bool) {



    //the bet still has time left
    if (now < auctionEnd) return false;


    if (agent_predictions[msg.sender].guess >= lowestInterval &&
    agent_predictions[msg.sender].guess <= highestInterval &&
    !agent_predictions[msg.sender].claimed) {
        // &&closed
      (msg.sender).transfer(2 ether);
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

  //return the day that the auction is in right now
  function getDayCount() public view returns (uint) {
      return day_increment;
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

    emit AuctionEnded(day_increment, 2);
  }

  function findHighestInterval() private {
    highestInterval = settlementValue + settlementValue / 20;
  }

  function findLowestInterval() private {
    lowestInterval = settlementValue - settlementValue / 20;
  }

  function findNumberOfAgentWithinInterval() private returns (uint) {

  }

  function findMoneyShare() private returns (uint) {
    return getPot() / findNumberOfAgentWithinInterval();
  }

  function getPot() public view returns (uint) {
      return moneyInTheContract;
  }

  //get settlementValue from energy supplier and set the settlement Value
  function setSettlementValue() public {
    //settlementValue = get_settlement_from_energy_supplier();
    settlementValue = 4200;
    findLowestInterval();
    findHighestInterval();
  }

  //Check if a player is exist or not
  //If the players is found in the players array, then true is returned
  //False return if noone is found
  function checkPlayerExists(address player) public view returns (bool) {
    for (uint256 i = 0; i < players.length; i++) {
      if (players[i] == player) return true;
    }
    return false;
  }

  function resetDaily() private {

  }
}
