// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./EthunesSongs.sol";
import "./EthunesAccessControl.sol";
import "./EthunesLicenses.sol";

contract EthunesMarketplace is AccessControl, ReentrancyGuard {
    event EthunesLicensePurchased(
        uint256 indexed licenseId,
        address indexed publisher,
        address indexed holder,
        uint256 price
    );

    event EthunesLicenseAdded(
        uint256 indexed LicenseId,
        // uint256 indexed songId,
        address indexed publisher,
        uint256 price
    );

    event EthunesSongPublished(
        uint256 indexed songId,
        address indexed publisher,
        string uri
    );

    uint256 public constant ONE_HUNDRED_PERCENTAGE = 10000;
    // 5.00%
    uint256 public publisherRoyaltyPercentage = 500;

    struct LicenseListing {
        address payable originalPublisher;
        uint256 price;
    }

    // LicenseId => LicenseListing
    mapping(uint256 => LicenseListing) public licenseListings;

    // songId => songCreator
    mapping(uint256 => address) public songCreators;

    address payable platform;

    EthunesAccessControl public ethunesAccessControl;
    EthunesSongs public ethunesSongs;
    EthunesLicenses public ethunesLicenses;

    constructor(
        EthunesAccessControl _ethunesAccessControl,
        EthunesSongs _ethunesSongs,
        EthunesLicenses _ethunesLicenses,
        address payable _platform
    ) {
        ethunesAccessControl = _ethunesAccessControl;
        ethunesSongs = _ethunesSongs;
        ethunesLicenses = _ethunesLicenses;
        platform = _platform;
    }

    /**
     * @dev publishes songs and licesnse
     */
    // TODO: TOTAL SUPPLY
    function publishSongAndLicense(
        string memory _songURI,
        uint256[] calldata _licenseCategories,
        uint256[] calldata _licensePurposes,
        uint256[] calldata _prices
    ) external {
        require(
            _licenseCategories.length == _licensePurposes.length &&
                _licenseCategories.length == _prices.length,
            "mistmatching input length."
        );

        uint256 songId = ethunesSongs.mint(_msgSender(), _songURI);

        for (uint256 i = 0; i < _licenseCategories.length; i++) {
            listNewLicense(
                songId,
                _licenseCategories[i],
                _licensePurposes[i],
                _prices[i]
            );
        }
        emit EthunesSongPublished(songId, _msgSender(), _songURI);
    }

    function listNewLicense(
        uint256 _songId,
        uint256 _licenseCategory,
        uint256 _licensePurpose,
        uint256 _price
    ) public {
        require(ethunesSongs.ownerOf(_songId) == _msgSender(), "wrong owner");
        //TODO
        // check category
        EthunesLicenses.License memory license =
            EthunesLicenses.License({
                songId: _songId,
                categoryId: _licenseCategory,
                purposeId: _licensePurpose,
                totalSupply: 0,
                availableSupply: 0
            });

        licenseListings[ethunesLicenses.encode(license)] = LicenseListing({
            originalPublisher: payable(_msgSender()),
            price: _price
        });

        emit EthunesLicenseAdded(
            ethunesLicenses.encode(license),
            _msgSender(),
            _price
        );
    }

    function purchaseLicense(
        uint256 _songId,
        uint256 _licenseCategory,
        uint256 _licensePurpose,
        uint256 _quantity
    ) external payable {
        require(ethunesSongs._exists(_songId), "song not exists");
        EthunesLicenses.License memory license =
            EthunesLicenses.License({
                songId: _songId,
                categoryId: _licenseCategory,
                purposeId: _licensePurpose,
                totalSupply: 0,
                availableSupply: 0
            });
        uint256 licenseId = ethunesLicenses.encode(license);

        LicenseListing storage listing = licenseListings[licenseId];
        address songOwner = ethunesSongs.ownerOf(_songId);
        require(
            listing.originalPublisher == songOwner && listing.originalPublisher != address(0) ,
            "owner of song changed"
        );

        require(_quantity > 0, "invalid quantity.");
        // If license has price
        if (listing.price > 0) {
            require(msg.value == listing.price, "value not matching price");
            (bool hasPaid, ) =
            payable(songOwner).call{value: msg.value}("");
            require(hasPaid, "failed to pay songOwner");
        }

        ethunesLicenses.mint(_msgSender(), license, _quantity);


        emit EthunesLicensePurchased(
            licenseId,
            songOwner,
            _msgSender(),
            msg.value
        );
    }
}
