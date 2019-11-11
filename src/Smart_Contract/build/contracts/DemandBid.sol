pragma solidity 0.5.11;

contract DemandBid {

    //address of the owner of this contract
    address owner;

    //length of round (24 hours, 00:00 - 23:59:59:99)
    uint public auctionLength;

    //uint256 is the date
    mapping (address => mapping (uint => Bet_Info)) agent_details;
    mapping (uint => Round) round_info;

    //initialises day = 0
    uint currentDay = 0;
    uint secondInit;

    constructor(uint _auctionLength) public {
        secondInit = now;
        auctionLength = _auctionLength;

        //set owner of this contract ot be whi initialises this contract
        owner = msg.sender;
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
    // Log when keccak256 is hashed
    event keccak256Hash(bytes32 hashes);
    // Log when prediction hash is hashed
    event HashPrediction(bytes32 hash_prediction);


    // https://emn178.github.io/online-tools/keccak_256.html
    // Agent needs to go to this website to hash the bet first
    // Bet can only be submitted from 00.00-23.00 of day0
    function submitBet(bytes32 _blindedBid) public payable {

        require (msg.value > 0, "The bet amount needs to be greater than 0");

        //check if currentDay is today
        if (((now - secondInit) / auctionLength) != currentDay) {

              currentDay = (now - secondInit) / auctionLength;
              //calculate rewards for previous day
        }

        // take modulus to find the seconds left in today
        uint today_current_second = (now - secondInit) % auctionLength;
        //require (today_current_second <= (23 / 24) * auctionLength, "Only accept bet before 23.00.00");


        agent_details[msg.sender][currentDay].betAmount = msg.value;
        //agent_details[msg.sender][currentDay].prediction = _prediction;
        agent_details[msg.sender][currentDay].hash_prediction = _blindedBid;

        // PS needs to initialise the reward = 0 after getting commit reveal scheme to work
        agent_details[msg.sender][currentDay].reward = msg.value;

        agent_details[msg.sender][currentDay].claimed = false;
        round_info[currentDay].total_pot += msg.value;
        round_info[currentDay].number_of_players += 1;
        emit BetSubmission(msg.sender, msg.value, currentDay);


    }

    function getTodayHash() public returns (bytes32) {
        currentDay = (now - secondInit) / auctionLength;
        return agent_details[msg.sender][currentDay].hash_prediction;
    }

    function getYesterdayHash() public returns (bytes32) {
        currentDay = (now - secondInit) / auctionLength;
        return agent_details[msg.sender][currentDay--].hash_prediction;
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

      require (msg.sender == owner, "Only owner of the contract can call this function");

    // settlementValue = get_settlement_from_energy_supplier();
    currentDay = (now - secondInit) / auctionLength;


    require(currentDay > 1, "Cannot set settlement value yet");

    //this function needs to be called by owner every midnight

    round_info[(currentDay-2)].settlement_value = 4200;
    round_info[(currentDay-2)].higherInterval = findHighestInterval();
    round_info[(currentDay-2)].lowerInterval = findLowestInterval();
  }

  // byte32 of prediction+password
  // first 4 bytes limit to be for prediction, 28 bytes for password
  function revealBet(bytes32  stringAndPassword) public returns (bool) {
      currentDay = (now - secondInit) / auctionLength;

      //require (today_current_second >= (23 / 24) * auctionLength && today_current_second <= auctionLength, "Can only reveal bet from 11pm-12pm");

        //keccak256 the sring and password

        //convert stringAndPassword to bytes memory
        bytes memory stringAndPassword_bytes = abi.encodePacked(stringAndPassword);

        bytes32 hash = keccak256(stringAndPassword_bytes);
        emit keccak256Hash(hash);
        emit HashPrediction(agent_details[msg.sender][currentDay].hash_prediction);

        //compare the hash with hash_prediction when submit bet
        if (hash == agent_details[msg.sender][currentDay].hash_prediction) {
            uint _prediction = getPredictionFromHash(stringAndPassword);

            //set the real prediction value
            agent_details[msg.sender][currentDay].prediction = _prediction;

            emit predictionMatchesHash(_prediction);

            agent_details[msg.sender][currentDay].bet_hashes_correct = true;

        }

        agent_details[msg.sender][currentDay--].bet_hashes_correct = false;

        return false;

  }

  // needs to write new function for byte32 slicing (mask)
  // slice the first 4 bytes
  // get first 32 bits
  function getPredictionFromHash(bytes32 stringAndPassword) private pure returns (uint) {
      //mask
      uint n = 32;
      bytes32 nOnes = bytes32(2 ** n - 1);
      bytes32 mask = shiftLeft(nOnes, 256 - n);
      bytes32 prediction_in_bytes32 =  stringAndPassword & mask;
      return uint(prediction_in_bytes32);
  }

  function shiftLeft(bytes32 a, uint n) private pure returns (bytes32) {
      uint shifted = uint(a) * 2 ** n;
      return bytes32(shifted);
  }

  // get the last 28 bytes
  function getPasswordFromHash() private {

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
