// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EthunesLicenses is ERC1155 {
    
    // Token name
    string public name = "EthunesLicenses";

    // Token symbol
    string public symbol = "ETL";

    event LicenseIssued(
        uint256 tokenId,
        uint256 songId,
        address indexed issuer,
        address indexed licensee
    );

    struct License {
        uint256 songId;
        uint256 categoryId;
        uint256 purposeId;
    }

    // Mapping of tokenId to license details
    // might not need this since we can just decode it
    // mapping (uint256 => License) internal licenses;

    // TODO constructor should take ERC721's address
    constructor() ERC1155("https://ethunes.com/api/licenses/{id}.json") {}

    /**
     * @dev decode from license's tokenId to license struct
     */
    function decode(uint256 tokenId) public pure returns (License memory license) {
        // Last two digits are categoryId and purposeId respectively (we won't have over 10 of each)
        // The remaing digits are songId
        return License(tokenId / 100, tokenId % 100 / 10, tokenId % 10);
        // return License(tokenId.div(100), tokenId.mod(100).div(10), tokenId.mod(10));
    }

    /**
     * @dev mint iff owner owns this ERC721 token
     */
    function mint(address licensee, uint256 tokenId, uint256 number) external {
        // Check to caller owns the ERC721
        // License memory license = decode(tokenId);
        // require(EthunesSongs.ownerOf(license.songId) === _msgSender, "permission denied");
        _mint(licensee, tokenId, number, "");
    }

}