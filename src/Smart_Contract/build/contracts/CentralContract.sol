pragma solidity 0.5.3;

contract CentralContract {

  uint actual_consumption;
  uint agentCount;
  mapping (address => uint) public prediction;
  mapping (address => uint256) public balances;

  function incrementCount() internal {
    agentCount += 1;
  }

  function buyToken() public {
    balances[msg.sender] += 1;
  }

  




}
