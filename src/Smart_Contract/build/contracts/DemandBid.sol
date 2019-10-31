pragma solidity 0.5.11;
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./DateTime.sol";

contract DemandBid {
    //length of round (24 hours, 00:00 - 23:59:59:99)
    uint public auctionLength = 86400;

    DateTime date = new DateTime();
    SafeMath safeMath = new SafeMath();

    //uint256 is the date
    mapping (address => mapping (uint => Bet_Info)) agent_details;
    mapping (uint => Round) round_info;
    uint256 currentDay = date.getDay(now);


    struct Round {
        uint date;
        uint number_of_players;
        uint total_pot;
        uint settlement_value;
        uint higherInterval;
        uint lowerInterval;
    }

    struct Bet_Info {
        uint betAmount;
        uint prediction;
        bytes32 hash_prediction;
        uint reward;
        bool claimed;
        bool bet_hashes_correct;
    }



    // Log the event about a bet submission being made by an address and its prediction
    event BetSubmission(address indexed accountAddress, uint prediction, uint dayNumber);
    // Calculate the shares that agent won
    event AuctionEnded(uint day_number, uint amount);


    //https://emn178.github.io/online-tools/keccak_256.html
    //Agent needs to go to this website to hash the bet first
    function submitBet(bytes32 _blindedBid) public payable {

        require (msg.value > 0, "The bet amount needs to be greater than 0");


        //check if
        /*if ((now / auctionLength) != currentDay) {

              currentDay += 1;
              //calculate rewards for previous day

        }*/


        agent_details[msg.sender][currentDay].betAmount = msg.value;
        //agent_details[msg.sender][currentDay].prediction = _prediction;
        agent_details[msg.sender][currentDay].hash_prediction = _blindedBid;
        agent_details[msg.sender][currentDay].reward = msg.value;
        agent_details[msg.sender][currentDay].claimed = false;
        round_info[currentDay].total_pot += msg.value;
        round_info[currentDay].number_of_players += 1;
        emit BetSubmission(msg.sender, msg.value, currentDay);



        //for testing
        nextDay();


    }

    function nextDay() public {
        currentDay = currentDay + 1 days;
        setSettlementValue();
    }


    function withdraw() public {

        uint total_sum = 0;
        for (uint i = currentDay - 1 days; i >= 0; i =  i - 1 days) {
            if (agent_details[msg.sender][i].claimed) {
                break;
            } else {
                /*if (agent_details[msg.sender][i].bet_hashes_correct) {

                }*/
                total_sum =  SafeMath.add(agent_details[msg.sender][i].reward, total_sum);
                agent_details[msg.sender][i].claimed = true;

            }
        }

        if (total_sum >= 0) {
            (msg.sender).transfer(1 ether);
        }


        //(msg.sender).transfer(1 ether);


    }

    function getRewardAmount() public view returns (uint) {
        return agent_details[msg.sender][0].reward;

    }

    //return the day that the auction is in right now
    function getDayCount() public view returns (uint) {
      return currentDay;
    }

    function findHighestInterval() private returns (uint) {
        return round_info[currentDay].settlement_value + round_info[currentDay].settlement_value / 20;
    }

    function findLowestInterval() private returns (uint) {
        return round_info[currentDay].settlement_value - round_info[currentDay].settlement_value / 20;
    }

  //get settlementValue from energy supplier and set the settlement Value
  function setSettlementValue() public {
    //settlementValue = get_settlement_from_energy_supplier();
    round_info[currentDay- 1 days].settlement_value = 4200;
    round_info[currentDay--].higherInterval = findHighestInterval();
    round_info[currentDay--].lowerInterval = findLowestInterval();
  }


  /*//Attach the string _predictionHash to the end of the prediction and see if it has the same
  function revealBet(uint _prediction, string memory _password) public {

      require (now / auctionLength != currentDay);

      //check whether the hash prediction inserted when the bet submitted is the same
      //as the string concat of prediction + predictionHash
      //e.g. 4200Hello123

      string predictionStr;

      string hashStr = predictionStr.toSlice().concat(_password.toSlice());

      if (agent_details[msg.sender][currentDay--].hash_prediction == keccak256(hashStr)) {
          agent_details[msg.sender][currentDay--].prediction = _prediction;
          agent_details[msg.sender][currentDay--].bet_hashes_correct = true;

      } else {
          //if the hashes do not match then set the agent prediction to equal to 0 instead
          agent_details[msg.sender][currentDay--].prediction = 0;
          agent_details[msg.sender][currentDay--].bet_hashes_correct = false;
      }

  }*/





}
