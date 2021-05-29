const {
  BN,
  constants,
  expectEvent,
  expectRevert,
  ether,
  balance,
  time,
} = require("@openzeppelin/test-helpers");
const { expect } = require("chai");

contract("", ([...restOfAccounts]) => {
  const TOKEN_1 = new BN("1");
  const TOKEN_2 = new BN("2");
  const ZERO_ETH = ether(new BN("0"));
  const ONE_ETH = ether(new BN("1"));
  const ONE = new BN("1");
  const IPFSHASH_1 = "TEST1";
  const IPFSHASH_2 = "123ABC";
});
