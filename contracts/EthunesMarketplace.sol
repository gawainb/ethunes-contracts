// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

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
        string uri,
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

    
}