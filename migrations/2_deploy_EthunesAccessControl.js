const EthunesAccessControl = artifacts.require("EthunesAccessControl");

module.exports = async function (deployer, network, accounts) {
  deployer.deploy(EthunesAccessControl, { from: accounts[0] });
};