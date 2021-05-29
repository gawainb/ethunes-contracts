const EthunesLicenses = artifacts.require("EthunesLicenses");

module.exports = async function (deployer, network) {
  deployer.deploy(EthunesLicenses);
};
