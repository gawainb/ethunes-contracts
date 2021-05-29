// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./EthunesSongs.sol";

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
        uint256 totalSupply;
        uint256 availableSupply;
    }

    EthunesSongs public ethunesSongs;

    // TODO constructor should take ERC721's address
    constructor(EthunesSongs _ethunesSongs) ERC1155("https://ethunes.com/api/licenses/{id}.json") {
        ethunesSongs = _ethunesSongs;
    }

    /**
     * @dev decode from license's tokenId to license struct
     */
    function decode(uint256 _tokenId) public pure returns (uint256 songId, uint256 categoryId, uint256 purposeId) {
        // Last two digits are categoryId and purposeId respectively (we won't have over 10 of each)
        // The remaing digits are songId
        return (_tokenId / 100, _tokenId % 100 / 10, _tokenId % 10);
        // return License(tokenId.div(100), tokenId.mod(100).div(10), tokenId.mod(10));
    }

    /**
     * @dev encode license details into tokenId
     */
    function encode(License calldata license) public pure returns (uint256 tokenId) {
        return license.songId * 100 + license.categoryId * 10 + license.purposeId;
    }

    /**
     * @dev mint iff owner owns this ERC721 token
     */
    function mint(address _licenseHolder, License calldata _license, uint256 _amount) external {
        // Check to caller owns the ERC721
        // License memory license = decode(tokenId);
        require(ethunesSongs.ownerOf(_license.songId) == _msgSender(), "permission denied");
        _mint(_licenseHolder, encode(_license), _amount, "");
    }

}