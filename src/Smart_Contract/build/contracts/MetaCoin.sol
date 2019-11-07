pragma solidity 0.5.3;

contract MetaCoin {
  address creator;
  mapping (address => uint) prediction;
  mapping (address => uint8) balances;
  uint actual_prediction;
  //uint8 private agentCount;

  DATETYPE DATE

  // Log the event about a bet submission being made by an address and its prediction
  event LogBetSubmission(address indexed accountAddress, uint prediction);

  //event Transfer(address indexed _from, address indexed _to, uint256 _value);

  function MetaCoin() {
    creator = msg.sender;
    mock_enroll();
  }

  //make the initial balance of this agent 10 ether
  //@return The balance of the agent after initialises
  function mock_enroll() public return (uint) {
    balances[msg.sender] = 10;
    return balances[msg.sender];
  }

  function submitBet() public returns(bool) {
    //check if the address of msg.sender has enough balances
    //if yes then set the predict to that address
    bool sufficient_balance = false;

    // or could use require instead of if statement
    if (address.balances[msg.sender] > 0) {
      sufficient_balance = true;
      prediction[msg.sender] = msg.value;
      emit LogBetSubmission(msg.sender, predict);
      balances[msg.sender] -= 1;
    }

    timestamp
    //DATE = currentDATE + 1
    //return sendCoin(MARKETPLACE, 1);

    return sufficient_balance;
  }

  //return the balances of the agent after the result
  function getResult() public returns(uint8) {
    if (rewarded) {

      //agent gets 2 coin if guess correctly
      balances[msg.sender] += 2;
    }

    return balances[msg.sender];
  }


  function rewarded() public returns(bool) {
    return (prediction[msg.sender] == actual_prediction);
  }

  // @return The balance of the agent
  function balance() public view returns (uint8) {
    return balances[msg.sender];
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

  function
}
