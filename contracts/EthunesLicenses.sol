// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./EthunesSongs.sol";
import "./EthunesAccessControl.sol";


contract EthunesLicenses is ERC1155 {

    event LicenseIssued(
        uint256 tokenId,
        uint256 songId,
        address indexed issuer,
        address indexed licensee
    );

    event LicenseCategoryUpdated(uint256 indexed categoryId, bytes categoryURI);
    
    // Token name
    string public name = "EthunesLicenses";

    // Token symbol
    string public symbol = "ETL"; 

    struct License {
        uint256 songId;
        uint256 categoryId;
        uint256 purposeId;
        uint256 totalSupply;
        uint256 availableSupply;
    }
    // LicenseCategoryId => LicenseCategory metadata
    mapping(uint256 => string) public licenseCategories;

    EthunesSongs public ethunesSongs;
    EthunesAccessControl public ethunesAccessControl;

    // TODO constructor should take ERC721's address
    constructor(EthunesSongs _ethunesSongs, EthunesAccessControl _ethunesAccessControl) ERC1155("https://ethunes.com/api/licenses/{id}.json") {
        ethunesSongs = _ethunesSongs;
        ethunesAccessControl = _ethunesAccessControl;
    }

    /**
     * @dev decode from license's tokenId to license struct
     */
    function decode(uint256 _tokenId) public pure returns (uint256 songId, uint32 categoryId, uint8 purposeId) {
        // first byte is the purpose id, next 4 bytes is the categoryId and the remaining is the songId 
        return ( _tokenId >> 40, uint32(_tokenId << 216 >> 224), uint8 (_tokenId << 248 >> 248) );
    }

    /**
     * @dev encode license details into tokenId
     */
    function encode(License calldata license) public pure returns (uint256 tokenId) {
       return (uint256(license.songId) << 40) + (uint256(license.categoryId) << 8) + uint256(license.purposeId); 
    }

    /**
     * @dev mint iff owner owns this ERC721 token
     */
    function mint(address _licenseHolder, License calldata _license, uint256 _amount) external {
        // Check to caller owns the ERC721
        // License memory license = decode(tokenId);
        require(ethunesSongs.ownerOf(_license.songId) == _msgSender() ||
        ethunesAccessControl.hasContractWhitelistRole(_msgSender()), "permission denied");
        _mint(_licenseHolder, encode(_license), _amount, "");
    }

    /**
     * @dev Admin can add a new/update gatefory
     */
    function updateCategory(uint256 _categoryId, string calldata _uri) external {
        require(ethunesAccessControl.hasAdminRole(_msgSender()),"caller not admin.");
        licenseCategories[_categoryId] = _uri;
        emit LicenseCategoryUpdated(_categoryId, bytes(_uri));
    }
}