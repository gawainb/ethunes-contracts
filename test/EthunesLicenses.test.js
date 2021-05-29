const {
  BN,
  constants,
  expectEvent,
  expectRevert,
  ether,
  balance,
  time,
} = require("@openzeppelin/test-helpers");
const { ZERO_ADDRESS } = require("@openzeppelin/test-helpers/src/constants");
const { expect } = require("chai");

const EthunesLicenses = artifacts.require("EthunesLicenses");

contract(
  "EthunesLicenses",
  ([creator, songOwner, licensee, ...restOfAccounts]) => {
    const SONG_12 = new BN("12");
    const CATEGORY_1 = new BN("1");
    const PURPOSE_1 = new BN("1");
    const LICENSE_1211 = new BN("1211");
    const LICENSE_DETAILS_1211 = {
      songId: SONG_12.toString(),
      categoryId: CATEGORY_1.toString(),
      purposeId: PURPOSE_1.toString(),
    };
    const NUMBER_10 = new BN("10");

    beforeEach(async () => {
      this.ethunesLicenses = await EthunesLicenses.new({ from: creator });
    });

    describe("Validate setup", async () => {
      it("should have name and symbol", async () => {
        expect(await this.ethunesLicenses.name()).to.be.equal(
          "EthunesLicenses"
        );
        expect(await this.ethunesLicenses.symbol()).to.be.equal("ETL");
      });
    });

    describe("Issuing license", async () => {
      it("should mint", async () => {
        const oldBalance = await this.ethunesLicenses.balanceOf(
          licensee,
          LICENSE_1211
        );
        const logs = await this.ethunesLicenses.mint(
          licensee,
          LICENSE_DETAILS_1211,
          NUMBER_10,
          { from: songOwner }
        );
        // licensee should have n more licenses
        const expectedBalance = oldBalance.add(NUMBER_10);
        const newBalance = await this.ethunesLicenses.balanceOf(
          licensee,
          LICENSE_1211
        );
        expect(newBalance).to.be.bignumber.equal(expectedBalance);
        expectEvent(logs, "TransferSingle", {
          operator: songOwner,
          from: ZERO_ADDRESS,
          to: licensee,
          id: LICENSE_1211,
          value: NUMBER_10,
        });
      });
    });

    describe("Lookup license details [decode]", async () => {
      it("should return the right details", async () => {
        const license = await this.ethunesLicenses.decode(LICENSE_1211);
        expect(license.songId).to.be.bignumber.equal(SONG_12);
        expect(license.categoryId).to.be.bignumber.equal(CATEGORY_1);
        expect(license.purposeId).to.be.bignumber.equal(PURPOSE_1);
      });
    });

    describe("Get licenseId (tokenId) from license details [encode]", async () => {
      it("should return the right id", async () => {
        const licenseId = await this.ethunesLicenses.encode(LICENSE_DETAILS_1211);
        expect(licenseId).to.be.bignumber.equal(LICENSE_1211);
      });
    });
  }
);
