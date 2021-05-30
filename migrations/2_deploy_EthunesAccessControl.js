const EthunesAccessControl = artifacts.require("EthunesAccessControl");

module.exports = async function (deployer, network) {
  await deployer.deploy(EthunesAccessControl);

  const accessControl = await EthunesAccessControl.deployed();

  //Emma
  await accessControl.addAdminRole(
    "0x3f6E1320ae93Aa88bb435E1e680a2a6dd3cAA2D5",
  );

  //Mehrad
  await accessControl.addAdminRole(
    "0x79c86C0452c999B1959b1147109cDc2db7E138D0",
  );

  //Shahin
   await accessControl.addAdminRole(
     "0x5a529B8775C4c7dF754cFa1d62B94F7fC296017E"
   );

  //Sven
   await accessControl.addAdminRole(
     "0xfb265906D73848dc07fB9C7F7eF75C7438E165B7"
   );
};