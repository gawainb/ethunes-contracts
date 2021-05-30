const EthunesAccessControl = artifacts.require("EthunesAccessControl");

module.exports = async function (deployer, network) {
  deployer.deploy(EthunesAccessControl);

  const accessControl = await EthunesAccessControl.deployed();

  await accessControl.addAdminRole(
    "0x3f6E1320ae93Aa88bb435E1e680a2a6dd3cAA2D5",
  );

   await accessControl.addAdminRole(
     "0x79c86C0452c999B1959b1147109cDc2db7E138D0",
   );
};