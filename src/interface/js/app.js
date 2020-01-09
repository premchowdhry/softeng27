
var settlemenData = [0];

App = {
  //const contract_address: 0x4344b7298B07CbdB065a4B29eb000A808E4f1d6E,
  web3Provider: null,
  contracts: {},
  account: 0x10,

  init: async function() {
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
      return App.render();
    });

    //return App.bindEvents();
  },

//   bindEvents: function() {
//     $(document).on('click', '.btn-adopt', App.handleAdopt);
//   },

   render: function() {
     var predictionInstance;
     var results = $("#pastdata");

     // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

      // Load contract data
      App.contracts.DemandBid.deployed().then(function(instance) {
        predictionInstance = instance;

        return predictionInstance.getCurrentDay();
      }).then(function(currentDay) {
          results.empty();
          var index = 0;

          for (var i = 1; i < currentDay; i++) {
            var settlement;
            var total_pot;
          //   var betAmount = 10;
          //   predictionInstance.agent_details(App.account)(i).then(function(bet) {
          //   betAmount = bet[0];
          //   //var prediction = bet[1];
          //   console.log(bet[0]);
          // });
          predictionInstance.round_info(i).then(function(r) {
          settlement = r[0];
          total_pot = r[3];
          index++;

          // Render the Result
           var template = "<tr><th>" + index + "</th><td>" + total_pot + "</td><td>" + settlement +   "</td></tr>";
           results.append(template);
        });
      }

      
        // var ctxL = document.getElementById("myChart").getContext('2d');
        // var c = new Chart(ctxL {
        //   type = 'line',
        //   data: {
        //     lables:[10,20,30,40],
        //     datasets:[{
        //       data:[10,10,10,10],
        //       label:"settlement value",
        //       borderColor: "#3e95cd",
        //       fill: false
        //     }]
        //   },
        //   options: {
        //     title:{
        //       display:true,
        //       text:'how did settlement values change'
        //     }
        //   }
        // });
        //$("#myChart").html(c);
      }).catch(function(error) {
        console.warn(error);
      });
      }
};



$(function() {
  $(window).load(function() {
    App.init();
  });

  Highcharts.chart('myChart', {

    chart: {
      scrollablePlotArea: {
        minWidth: 200
      }
    },

    // data: {
    //   csvURL: 'https://cdn.jsdelivr.net/gh/highcharts/highcharts@v7.0.0/samples/data/analytics.csv',
    //   beforeParse: function (csv) {
    //     return csv.replace(/\n\n/g, '\n');
    //   }
    // },

    title: {
      text: 'Daily Energy usage'
    },

    subtitle: {
      text: 'Source: SoftEng27 Analytics'
    },

    xAxis: {
      title:{
        text:'date'
      }
      // tickInterval: 7 * 24 * 3600 * 1000, // one week
      // tickWidth: 0,
      // gridLineWidth: 1,
      // labels: {
      //   align: 'left',
      //   x: 3,
      //   y: -3
      // }
    },

    yAxis: [{ // left y axis
      title: {
        text: 'energy price'
      }
    //   labels: {
    //     align: 'left',
    //     x: 3,
    //     y: 16,
    //     format: '{value:.,0f}'
    //   },
    //   showFirstLabel: false
    // }, { // right y axis
    //   linkedTo: 0,
    //   gridLineWidth: 0,
    //   opposite: true,
    //   title: {
    //     text: null
    //   },
    //   labels: {
    //     align: 'right',
    //     x: -3,
    //     y: 16,
    //     format: '{value:.,0f}'
    //   },
    //   showFirstLabel: false
    }],

    legend: {
      layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle'
    },
    //
    // tooltip: {
    //   shared: true,
    //   crosshairs: true
    // },

    // plotOptions: {
    //   series: {
    //     cursor: 'pointer',
    //     point: {
    //       events: {
    //         click: function (e) {
    //           hs.htmlExpand(null, {
    //             pageOrigin: {
    //               x: e.pageX || e.clientX,
    //               y: e.pageY || e.clientY
    //             },
    //             headingText: this.series.name,
    //             maincontentText: Highcharts.dateFormat('%A, %b %e, %Y', this.x) + ':<br/> ' +
    //               this.y + ' sessions',
    //             width: 200
    //           });
    //         }
    //       }
    //     },
    //     marker: {
    //       lineWidth: 1
    //     }
    //   }
    // },

    series: [{
      name: 'Settlement Values',
      data:[10,20,30,40]
    }, {
      name: 'Your Predictions',
      data:[10,15,20,25]
    }],
    responsive: {
      rules: [{
          condition: {
              maxWidth: 500
          },
          chartOptions: {
              legend: {
                  layout: 'horizontal',
                  align: 'center',
                  verticalAlign: 'bottom'
              }
          }
      }]
  }
  });


});
