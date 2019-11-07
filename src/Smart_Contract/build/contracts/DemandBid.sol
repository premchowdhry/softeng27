pragma solidity 0.4.26;
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./DateTime.sol";

contract DemandBid {
    //length of round (24 hours, 00:00 - 23:59:59:99)
    uint public auctionLength;

    DateTime date = new DateTime();
    //SafeMath safeMath = new SafeMath();

    //uint256 is the date
    mapping (address => mapping (uint => Bet_Info)) agent_details;
    mapping (uint => Round) round_info;

    //initialises day = 0
    uint currentDay = 0;
    uint secondInit;

    constructor(uint _auctionLength) public {
        secondInit = now;
        auctionLength = _auctionLength;
    }

    struct Round {
        uint date;
        uint number_of_players;
        uint total_pot;
        uint settlement_value;
        uint higherInterval;
        uint lowerInterval;
        uint number_agent_inside_interval;
        uint sum_relativeness;
        bool settlement_is_set;
    }

    struct Bet_Info {
        uint betAmount;
        uint prediction;
        bytes32 hash_prediction;
        uint reward;
        bool claimed;
        bool bet_hashes_correct;
        bool insideInterval;
        uint relativeness;
    }



    // Log the event about a bet submission being made by an address and its prediction
    event BetSubmission(address indexed accountAddress, uint prediction, uint dayNumber);
    // Calculate the shares that agent won
    event AuctionEnded(uint day_number, uint amount);
    // Log when the hashes match and the prediction value
    event predictionMatchesHash(uint prediction_value);
    //
    event keccak256Hash(bytes32 hashes);

    event HashPrediction(bytes32 hash_prediction);


    //https://emn178.github.io/online-tools/keccak_256.html
    //Agent needs to go to this website to hash the bet first
    function submitBet(bytes32 _blindedBid) public payable {

        require (msg.value > 0, "The bet amount needs to be greater than 0");


        //check if
        if (((now - secondInit) / auctionLength) != currentDay) {

              currentDay = (now - secondInit) / auctionLength;
              //calculate rewards for previous day

        }


        agent_details[msg.sender][currentDay].betAmount = msg.value;
        //agent_details[msg.sender][currentDay].prediction = _prediction;
        agent_details[msg.sender][currentDay].hash_prediction = _blindedBid;

        // PS needs to initialise the reward = 0 after getting commit reveal scheme to work
        agent_details[msg.sender][currentDay].reward = msg.value;

        agent_details[msg.sender][currentDay].claimed = false;
        round_info[currentDay].total_pot += msg.value;
        round_info[currentDay].number_of_players += 1;
        emit BetSubmission(msg.sender, msg.value, currentDay);

        //for testing
        //nextDay();


    }

    function getTodayHash() public returns (bytes32) {
        currentDay = (now - secondInit) / auctionLength;
        return agent_details[msg.sender][currentDay].hash_prediction;
    }

    function getYesterdayHash() public returns (bytes32) {
        currentDay = (now - secondInit) / auctionLength;
        return agent_details[msg.sender][currentDay--].hash_prediction;
    }

    //Only use for testing
    function nextDay() public {
        //add 86400sec to now - secondInit
        currentDay = (now - secondInit + 1 days) / auctionLength;
        setSettlementValue();
    }

    function getNow() public returns (uint) {
        uint x = now;
        return x;
    }

    //withdraw function can only be called on day2
    function withdraw(uint _prediction) public {

        //uint total_sum = 0;
        // currentDay = (now - secondInit) / auctionLength;
        // for (uint i = currentDay; i >= 0; i--) {
        //     if (!agent_details[msg.sender][i].claimed) {
        //         (msg.sender).transfer(agent_details[msg.sender][i].reward);
        //     } else {
        //         /*if (agent_details[msg.sender][i].bet_hashes_correct) {

        //         }*/
        //         //total_sum =  SafeMath.add(agent_details[msg.sender][i].reward, total_sum);
        //         //agent_details[msg.sender][i].claimed = true;

        //         break;
        //     }
        // }

        /*if (total_sum >= 0) {
            (msg.sender).transfer(1 ether);
        }*/


        //(msg.sender).transfer(1 ether);

        currentDay = (now - secondInit) / auctionLength;

        if (!agent_details[msg.sender][currentDay--].claimed) {
            uint ytdReward = agent_details[msg.sender][currentDay--].reward;

            (msg.sender).transfer((ytdReward));
        }

    }

    function withdrawWithout() public {
        currentDay = (now - secondInit) / auctionLength;
        require(currentDay > 1, "No available withdraws yet");

        //check whether the settlement_value for the day has been set
        //if the settlement value has not been set = it has been call the first time for that day
        if (!round_info[currentDay-2].settlement_is_set) {

            setSettlementValue();
            round_info[currentDay-2].settlement_is_set = true;
        }

        //then just need to compare the bet with the intervals
        if (checkIfInsideInterval()) {
            //create a sorted list for storing the closest bet to the actual settlement value

        }

    }

    // return the rewardAmount of the msg.sender on the day specify
    function getRewardAmount(uint day) public view returns (uint) {
        return agent_details[msg.sender][day].reward;
    }

    // return the day that the auction is in right now
    function getDayCount() public view returns (uint) {
      return (now - secondInit) / auctionLength;
    }

    // using 5% interval
    function findHighestInterval() private returns (uint) {
        currentDay = (now - secondInit) / auctionLength;
        return round_info[currentDay].settlement_value + round_info[currentDay].settlement_value / 20;
    }

    function findLowestInterval() private returns (uint) {
        currentDay = (now - secondInit) / auctionLength;
        return round_info[currentDay].settlement_value - round_info[currentDay].settlement_value / 20;
    }

  // get settlementValue from energy supplier and set the settlement Value
  // also calculate the highest and lowest interval
  // starting from day0, settlement_value is set on day2
  function setSettlementValue() public {
    // settlementValue = get_settlement_from_energy_supplier();
    currentDay = (now - secondInit) / auctionLength;

    require(currentDay > 1, "Cannot set settlement value yet");

    round_info[(currentDay-2)].settlement_value = 4200;
    round_info[(currentDay-2)].higherInterval = findHighestInterval();
    round_info[(currentDay-2)].lowerInterval = findLowestInterval();
  }

  //user needs to insert the length of their guess value that is inside the _predictionAndPassword
  //get the prediction by the first _guessLength in _predictionAndPassword
  //revealBet is called on day 1;
  function revealBet(uint _guessLength, string memory _predictionAndPassword) public returns (bool) {

      currentDay = (now - secondInit) / auctionLength;
      require(currentDay > 0, "Cannot reveal bet at this time");

      emit keccak256Hash(keccak256(_predictionAndPassword));
      emit HashPrediction(agent_details[msg.sender][currentDay--].hash_prediction);

      //check if the keccak of the _predictionAndPassword is the same as the one inserted in submitBet
      if (keccak256(_predictionAndPassword) == agent_details[msg.sender][currentDay--].hash_prediction) {

        uint _prediction = hashSlicing(_guessLength, _predictionAndPassword);

        //set the real prediction value
        agent_details[msg.sender][currentDay--].prediction = _prediction;

        emit predictionMatchesHash(_prediction);
        agent_details[msg.sender][currentDay--].bet_hashes_correct = true;
        return true;

      }

      agent_details[msg.sender][currentDay--].bet_hashes_correct = false;

      return false;

  }

  /*function returnKeccak256(string) public pure returns (bytes32) {
      return keccak256(string);
  }*/

  //returns the prediction from the _predictionAndPassword string(bytes32)
  //by slicing the string using index
  function hashSlicing(uint _index, string  _string) private pure returns (uint) {

        //slice string
        bytes memory a = new bytes(_index);
        for(uint i=0;i<=_index-1;i++){
            a[i] = bytes(_string)[i];
        }

        //convert string to uint
        uint result = stringToUint(string(a));
        return result;
  }

  function getSlice(uint begin, uint end, string text) private pure returns (string) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);
    }

  //convert string to uint
  function stringToUint(string _s) private pure returns (uint result) {
      bytes memory b = bytes(_s);
      result = 0;
      for (uint i = 0; i < b.length; i++) {
          if (b[i] >= 48 && b[i] <= 57) {
              result = result * 10 + (uint(b[i]) - 48);
          }
      }
      return result;
  }

  function uintToString(uint v) private pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

  /*//Attach the string _predictionHash to the end of the prediction and see if it has the same
  function revealBet(uint _prediction, string memory _password) public {

      require (now / auctionLength != currentDay);

      //check whether the hash prediction inserted when the bet submitted is the same
      //as the string concat of prediction + predictionHash
      //e.g. 4200Hello123

      string memory predictionStr;

      string hashStr;  = predictionStr.toSlice().concat(_password.toSlice());

      if (agent_details[msg.sender][currentDay--].hash_prediction == keccak256(hashStr)) {
          agent_details[msg.sender][currentDay--].prediction = _prediction;
          agent_details[msg.sender][currentDay--].bet_hashes_correct = true;

      } else {
          //if the hashes do not match then set the agent prediction to equal to 0 instead
          agent_details[msg.sender][currentDay--].prediction = 0;
          agent_details[msg.sender][currentDay--].bet_hashes_correct = false;
      }

  }*/

  //need sorted list for how close the
  //?? call this function when calling withdraw function ??
  function checkIfInsideInterval() private returns (bool) {
      currentDay = (now - secondInit) / auctionLength;
      if (agent_details[msg.sender][currentDay-2].prediction <= round_info[currentDay-2].higherInterval &&
      agent_details[msg.sender][currentDay-2].prediction >= round_info[currentDay-2].lowerInterval) {
          agent_details[msg.sender][currentDay-2].insideInterval = true;
          round_info[currentDay-2].number_agent_inside_interval += 1;
          return true;
      }
      return false;

  }

  //calculate the relativeness value and set the relativeness in the struct at the end
  //calculate by the inverse of the differences between the settlement_value and the guess
  //then multiply it with the betAmount
  function calculateRelativeBetAndCloseness() private {
      currentDay = (now - secondInit) / auctionLength;
      uint difference_from_settlement_value = differenceFromSettlementValue();

      uint _relativeness = (1 / difference_from_settlement_value) * agent_details[msg.sender][currentDay-2].betAmount;

      //maybe needs to have a parameter name relative

      agent_details[msg.sender][currentDay-2].relativeness = _relativeness;
      round_info[currentDay-2].sum_relativeness += _relativeness;

  }

  // find the difference between prediction and the actual settlement value
  function differenceFromSettlementValue() private returns (uint) {
      uint difference_from_settlement_value;
      if (round_info[currentDay-2].settlement_value > agent_details[msg.sender][currentDay-2].prediction) {
          difference_from_settlement_value = round_info[currentDay-2].settlement_value - agent_details[msg.sender][currentDay-2].prediction;
      } else {
          difference_from_settlement_value = agent_details[msg.sender][currentDay-2].prediction - round_info[currentDay-2].settlement_value;
      }
      return difference_from_settlement_value;
  }

  //Can only calculate the reward on the day you withdraw
  function calculateReward() private {
      currentDay = (now - secondInit) / auctionLength;
      uint _reward = (agent_details[msg.sender][currentDay-2].relativeness / round_info[currentDay-2].sum_relativeness) * round_info[currentDay-2].total_pot;
      agent_details[msg.sender][currentDay-2].reward = _reward;
  }


}
