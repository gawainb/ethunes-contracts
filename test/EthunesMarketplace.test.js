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
const EthunesSongs = artifacts.require("EthunesSongs");
const EthunesAccessControl = artifacts.require("EthunesAccessControl")
const EthunesMarketplace = artifacts.require("EthunesMarketplace");


contract(
  "EthunesLicenses",
  ([admin, creator, songOwner, holder, platform, ...restOfAccounts]) => {
    const SONG_1 = new BN("1");
    const CATEGORY_1 = new BN("1");
    const PURPOSE_1 = new BN("1");

    const ONE_ETH = ether(new BN("1"));
    const TEN_LICENSES = new BN("10");
    
    const SUPPLY = new BN("10")
    const LICENSE_DETAILS_111 = {
      songId: SONG_1.toString(),
      categoryId: CATEGORY_1.toString(),
      purposeId: PURPOSE_1.toString(),
      totalSupply: SUPPLY.toString(),
      availableSupply: new BN("0").toString()
    };
    const NUMBER_10 = new BN("10");

    const CATEGORY_1_URI = "CATEGORY_1";
    const SONG_1_URI = "SONG_URI_12"

    beforeEach(async () => {
      this.accessControl = await EthunesAccessControl.new({ from: admin });
      this.ethunesSongs = await EthunesSongs.new(this.accessControl.address, {
        from: creator,
      });
      this.ethunesLicenses = await EthunesLicenses.new(
        this.ethunesSongs.address,
        this.accessControl.address,
        { from: creator }
      );

      this.ethunesMarketpalce = await EthunesMarketplace.new(
        this.accessControl.address,
        this.ethunesSongs.address,
        this.ethunesLicenses.address,
        platform,
        {from: admin}
      )

      //TODO: CHANGE THIS TO MARKETPLACE
      await this.accessControl.addContractWhitelistRole(this.ethunesMarketpalce.address, { from: admin })

      expect(await this.accessControl.hasContractWhitelistRole(this.ethunesMarketpalce.address)).to.be.true;
      

    });

    describe("should be able to publish song and issue license", async () => {
      it("should mint song- 721", async () => {
        await this.ethunesMarketpalce.publishSongAndLicense(SONG_1_URI, [CATEGORY_1], [PURPOSE_1], [ONE_ETH], { from: songOwner });

        const SONG_1_OWNER = await this.ethunesSongs.ownerOf(SONG_1)
        expect(SONG_1_OWNER).to.be.equal(songOwner)
      });

      it("should list license", async () => {
        const logs = await this.ethunesMarketpalce.publishSongAndLicense(
          SONG_1_URI,
          [CATEGORY_1],
          [PURPOSE_1],
          [ONE_ETH],
          { from: songOwner }
        );

        expectEvent(logs, "EthunesLicenseAdded", {
          price: ONE_ETH,
          publisher: songOwner
        });

        
      });
    });

     describe("should be able to purchase license", async () => {
       beforeEach(async () => {
         await this.ethunesMarketpalce.publishSongAndLicense(
           SONG_1_URI,
           [CATEGORY_1],
           [PURPOSE_1],
           [ONE_ETH],
           { from: songOwner }
         );

         const SONG_1_OWNER = await this.ethunesSongs.ownerOf(SONG_1);
         expect(SONG_1_OWNER).to.be.equal(songOwner);
       });
       it("should mint license-1155", async () => {
         const songOwnerBalanceBefore = await balance.current(songOwner)
         await this.ethunesMarketpalce.purchaseLicense(
           SONG_1,
           CATEGORY_1,
           PURPOSE_1,
           TEN_LICENSES,
           { from: holder, value: ONE_ETH }
         );

         const licenseId = await this.ethunesLicenses.encode(
           LICENSE_DETAILS_111
         );

         const holderBalance = await this.ethunesLicenses.balanceOf(
           holder,
           licenseId
         );

        const songOwnerBalanceAfter = await balance.current(songOwner);

         expect(holderBalance).to.be.bignumber.equal(TEN_LICENSES);
         // check songOwner balance
         expect(songOwnerBalanceAfter).to.be.bignumber.equal(songOwnerBalanceBefore.add(ONE_ETH));

       });
     });

    
  }
);
