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

        //increment total_pot with the bet amount
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
    function withdraw() public {
        currentDay = (now - secondInit) / auctionLength;
        require(currentDay > 1, "No available withdraws yet");

        getReward();

        if (!agent_details[msg.sender][currentDay-2].claimed) {
            uint ytdReward = agent_details[msg.sender][currentDay--].reward;

            // only needs to transfer the funds if reward > 0
            if (ytdReward > 0) {
                //transfer rewards to the agent
            (msg.sender).transfer((ytdReward));

            //deduct the withdraw amount from today's total_pot
            round_info[currentDay-2].total_pot -= ytdReward;
            }

        }

    }

    // call this function if there is leftover total_pot from yesterday's
    // can call this function first after settlement_value for today is called
    function updateTotalPotFor2DaysAgoRound() public {
        currentDay = (now - secondInit) / auctionLength;
        require(currentDay > 2, "Can only update after day2");

        // only needs to update the pot if there is leftover
        if (round_info[currentDay-3].total_pot > 0) {

            // update total_pot with leftover
            round_info[currentDay-2].total_pot += round_info[currentDay-3].total_pot;
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
  // owner of the contract can should call this at midnight of day1
  function setSettlementValue(uint value) public {

      require (msg.sender == owner, "Only owner of the contract can call this function");

    // settlementValue = get_settlement_from_energy_supplier();
    currentDay = (now - secondInit) / auctionLength;


    require(currentDay > 1, "Cannot set settlement value yet");

    //this function needs to be called by owner every midnight

    round_info[(currentDay-2)].settlement_value = value;
    round_info[(currentDay-2)].higherInterval = findHighestInterval();
    round_info[(currentDay-2)].lowerInterval = findLowestInterval();
    round_info[(currentDay-2)].settlement_is_set = true;
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

  // shift bytes by 32 bits
  function shiftLeft(bytes32 a, uint n) private pure returns (bytes32) {
      uint shifted = uint(a) * 2 ** n;
      return bytes32(shifted);
  }

  // get the last 28 bytes
  function getPasswordFromHash() private {

  }

  //need sorted list for how close the
  function checkIfInsideInterval() private returns (bool) {
      currentDay = (now - secondInit) / auctionLength;
      require (currentDay > 1);

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
      require (currentDay > 1);

      uint difference_from_settlement_value = differenceFromSettlementValue();

      uint _relativeness = (1 / difference_from_settlement_value) * agent_details[msg.sender][currentDay-2].betAmount;

      //maybe needs to have a parameter name relative

      agent_details[msg.sender][currentDay-2].relativeness = _relativeness;
      round_info[currentDay-2].sum_relativeness += _relativeness;

  }

  // find the difference between prediction and the actual settlement value
  // needs to check for 0 (exact number for guess and settlement_value)
  // if exactly then make equal to 1
  function differenceFromSettlementValue() private returns (uint) {

      currentDay = (now - secondInit) / auctionLength;

      require (currentDay > 1);

      uint difference_from_settlement_value;

      if (round_info[currentDay-2].settlement_value == agent_details[msg.sender][currentDay-2].prediction) {
          difference_from_settlement_value = 1;
      } else if (round_info[currentDay-2].settlement_value > agent_details[msg.sender][currentDay-2].prediction) {
          difference_from_settlement_value = round_info[currentDay-2].settlement_value - agent_details[msg.sender][currentDay-2].prediction;
      } else {
          difference_from_settlement_value = agent_details[msg.sender][currentDay-2].prediction - round_info[currentDay-2].settlement_value;
      }
      return difference_from_settlement_value;
  }

  // Can only calculate the reward on the day you withdraw
  // call in withdraw
  function getReward() private {
      currentDay = (now - secondInit) / auctionLength;

      uint _reward = (agent_details[msg.sender][currentDay-2].relativeness / round_info[currentDay-2].sum_relativeness) * round_info[currentDay-2].total_pot;
      agent_details[msg.sender][currentDay-2].reward = _reward;
  }

  // calculate rewards should be called after settlement_value is set after midnight
  // this should be called asap
  function calculateReward() public {
      currentDay = (now - secondInit) / auctionLength;

      // checkIfInsideInterval
      if (checkIfInsideInterval()) {
          //calculate parameter for relativeness and sum_relativeness
          calculateRelativeBetAndCloseness();


      } else {
          //if not inside the interval then agent do not get a reward
          agent_details[msg.sender][currentDay-2].reward = 0;
      }
  }




}
