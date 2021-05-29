// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EthunesLicenses is ERC1155 {

    event LicenseIssued(
        uint256 tokenId,
        uint256 songId,
        address indexed issuer,
        address indexed licensee
    )

    struct License {
        uint256 songId,
        uint256 categoryId,
        uint256 purposeId
    }

    // Mapping of tokenId to license details
    mapping (uint256 => License) internal licenses;

    constructor() ERC1155("https://ethunes.com/api/licenses/{id}.json") {}

    /**
     * @dev decode from license's tokenId to license struct
     */
    function decode(uint256 tokenId) public view returns (License license) {
        // Last two digits are categoryId and purposeId respectively (we won't have over 10 of each)
        // The remaing digits are songId
        return License(tokenId / 100, tokenId % 100 / 10, tokenId % 10);
        // return License(tokenId.div(100), tokenId.mod(100).div(10), tokenId.mod(10));
    }


}