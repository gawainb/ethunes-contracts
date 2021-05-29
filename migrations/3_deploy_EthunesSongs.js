const EthunesAccessControl = artifacts.require("EthunesAccessControl");
const EthunesSongs = artifacts.require("EthunesSongs");

module.exports = async function (deployer, network, accounts) {
  
    await deployer.deploy(EthunesSongs, EthunesAccessControl.address, {
      from: accounts[0],
    });
};
