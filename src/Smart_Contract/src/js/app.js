App = {
  const contract_address: 0x4344b7298B07CbdB065a4B29eb000A808E4f1d6E,
  web3Provider: null,
  contracts: {},

  init: async function() {
    // Load pets. load contract data
    // $.getJSON('../pets.json', function(data) {
    //   var petsRow = $('#petsRow');
    //   var petTemplate = $('#petTemplate');

    //   for (i = 0; i < data.length; i ++) {
    //     petTemplate.find('.panel-title').text(data[i].name);
    //     petTemplate.find('img').attr('src', data[i].picture);
    //     petTemplate.find('.pet-breed').text(data[i].breed);
    //     petTemplate.find('.pet-age').text(data[i].age);
    //     petTemplate.find('.pet-location').text(data[i].location);
    //     petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

    //     petsRow.append(petTemplate.html());
    //   }
    // });

     return await App.initWeb3();
  },

  initWeb3: async function() {

     // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {

     $.getJSON('DemandBid.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      App.contracts.DemandBid = TruffleContract(data);

      // Set the provider for our contract
      App.contracts.DemandBid.setProvider(App.web3Provider);

      // Use our contract to retrieve information

    });
    return App.render();
    //return App.bindEvents();
  },

//   bindEvents: function() {
//     $(document).on('click', '.btn-adopt', App.handleAdopt);
//   },

   render: function() {
     var predictionInstance;
     //var loader = $("#loader");
     var content = $("#content");

     //loader.show();
     //content.hide();
     // Load account data
      // web3.eth.getCoinbase(function(err, account) {
      //   if (err === null) {
      //     App.account = account;
      //     $("#accountAddress").html("Your Account: " + account);
      //   }
      // });

      // Load contract data
      App.contracts.DemandBid.deployed().then(function(instance) {
        DemandBidInstance = instance;
        //return DemandBidInstance.getNow();
      }).then(function() {
        var results = $("#pastData");
        results.empty();
        var template = "<tr><th>" + 100 + "</th><td>" + 100 + "</td><td>" + 100 + "</td></tr>"
        results.append(template);
        results.append(template);
        results.append(template);
        results.append(template);

        //loader.hide();
        //content.show();
      }).catch(function(error) {
        console.warn(error);
      });
      }





//   handleAdopt: function(event) {
//     event.preventDefault();

//     var petId = parseInt($(event.target).data('id'));

//     /*
//      * Replace me...
//      */
//   }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
