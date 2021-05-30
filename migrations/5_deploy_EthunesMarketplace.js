const EthunesAccessControl = artifacts.require("EthunesAccessControl");
const EthunesSongs = artifacts.require("EthunesSongs");
const EthunesLicenses = artifacts.require("EthunesLicenses");
const EthunesMarketplace = artifacts.require("EthunesMarketplace");

module.exports = async function (deployer, network, accounts) {
    const platform = "0x79c86C0452c999B1959b1147109cDc2db7E138D0"
    console.log("ETHUNES SONGS", EthunesSongs.address);
    console.log("ETHUNES LICENSE", EthunesLicenses.address);
    console.log("ETHUNES ACCESSCONTROL", EthunesAccessControl.address);
  await deployer.deploy(
    EthunesMarketplace,
    EthunesAccessControl.address,
    EthunesSongs.address,
    EthunesLicenses.address,
    platform,
    {
      from: accounts[0],
    }
  );
  const marketpalce = await EthunesMarketplace.deployed()
  const accessControl = await EthunesAccessControl.deployed()

    await accessControl.addContractWhitelistRole(marketpalce.address);
    await marketpalce.publishSongAndLicense(
      "http://ipfs.infura.io/ipfs/QmZidCZsJNc15nuwnPV8dtutSk1sNXdrMY2rGWMQsgxpFo",
      [1],
      [1],
      ["1000000000000000000"],
      { from: accounts[0] }
    );
  
  await marketpalce.listNewLicense(
    1,
    2,
    1,
    "1000000000000000000",
    { from: accounts[0] }
  );
  
  await marketpalce.publishSongAndLicense(
    "http://ipfs.infura.io/ipfs/QmSfneNH87pYNggu34nGK8WXBPDA3kVg7zFeaBpgm9th27",
    [1],
    [1],
    ["1000000000000000000"],
    { from: accounts[0] }
  );

  await marketpalce.listNewLicense(2, 2, 1, "1000000000000000000", {
    from: accounts[0],
  });
};
