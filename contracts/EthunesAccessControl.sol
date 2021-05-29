// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract EthunesAccessControl is AccessControl {

    event NewAdminAdded(address indexed admin);

    event AdminRemoved(address indexed admin);

    event Contract(address indexed admin);

    bytes32 public constant CONTRACT_WHITELIST_ROLE = keccak256(
        "CONTRACT_WHITELIST_ROLE"
    );

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function addContractWhitelistRole(address _address) public  {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "EthunesAccessControl: Caller must be admin.");
        require(
            !hasContractWhitelistRole(_address),
            "EthunesAccessControl: Address has contractWhitelist role"
        );
        grantRole(CONTRACT_WHITELIST_ROLE, _address);
    }

    function removeContractWhitelistRole(address _address)
        public
        
    {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "EthunesAccessControl: Caller must be admin.");
        require(
            hasContractWhitelistRole(_address),
            "EthunesAccessControl: Address must have contractWhitelist role"
        );
        revokeRole(CONTRACT_WHITELIST_ROLE, _address);
    }

    function hasContractWhitelistRole(address _address)
        public
        view
        returns (bool)
    {
        return hasRole(CONTRACT_WHITELIST_ROLE, _address);
    }

    /**
     * @dev add admin role
     */
    function addAdminRole(address _address) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "EthunesAccessControl: Caller must be admin.");
        grantRole(DEFAULT_ADMIN_ROLE, _address);
        emit NewAdminAdded(_address);
    }

    /**
     * @dev remove admin role
     */
    function removeAdminRole(address _address) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "EthunesAccessControl: Caller must be admin.");
        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRemoved(_address);
    }
}
