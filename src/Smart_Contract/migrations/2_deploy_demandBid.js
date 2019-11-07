var DemandBid = artifacts.require("DemandBid", "DateTime");

module.exports = function(deployer) {
  deployer.deploy(DemandBid, 100);
};
