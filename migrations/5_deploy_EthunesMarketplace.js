const EthunesAccessControl = artifacts.require("EthunesAccessControl");
const EthunesSongs = artifacts.require("EthunesSongs");
const EthunesLicenses = artifacts.require("EthunesLicenses");
const EthunesMarketplace = artifacts.require("EthunesMarketplace");

module.exports = async function (deployer, network, accounts) {
    const platform = "0x79c86C0452c999B1959b1147109cDc2db7E138D0"
  await deployer.deploy(
    EthunesMarketplace,
    EthunesSongs.address,
    EthunesAccessControl.address,
    EthunesLicenses.address,
    platform,
    {
      from: accounts[0],
    }
  );
    const marketpalce = await EthunesMarketplace.deployed()

    await marketpalce.publishSongAndLicense(
        "SONG_URI_1",
        [1],
        [1],
        ["1000000000000000000"],
    )
};
