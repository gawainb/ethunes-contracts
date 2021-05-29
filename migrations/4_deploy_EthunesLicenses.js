const EthunesAccessControl = artifacts.require("EthunesAccessControl");
const EthunesSongs = artifacts.require("EthunesSongs");
const EthunesLicenses = artifacts.require("EthunesLicenses");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(EthunesLicenses,EthunesSongs.address, EthunesAccessControl.address, {
    from: accounts[0],
  });
};
