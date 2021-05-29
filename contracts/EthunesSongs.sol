// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title Ethunes songs NFT contract
 * @author Mehrad, Emma, Sven, Shahin
 * @dev ERC721 NFT contract for Ethunes songs
 */
contract EthunesSongs is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;

    // Token name
    string public override name = "Ethunes";

    // Token symbol
    string public override symbol = "ETU";

    // Burn/Dead address
    address private constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    string public constant BASE_URL = "https://ipfs.infura.io/ipfs/";

    // Mapping from token ID to owner address
    mapping(uint256 => address) private owners;

    // Mapping owner address to token count
    mapping(address => uint256) private balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private operatorApprovals;

    // Mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;

    constructor() {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            _interfaceId == type(IERC721).interfaceId ||
            _interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address _owner) public view override returns (uint256) {
        require(
            _owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return balances[_owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 _tokenId) public view override returns (address) {
        address owner = owners[_tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory uri = tokenURIs[_tokenId];

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, uri))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal pure returns (string memory) {
        return BASE_URL;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address _to, uint256 _tokenId) public override {
        address owner = ownerOf(_tokenId);
        require(_to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(_to, _tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 _tokenId)
        public
        view
        override
        returns (address)
    {
        require(
            _exists(_tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return tokenApprovals[_tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address _operator, bool _approved)
        public
        override
    {
        require(_operator != _msgSender(), "ERC721: approve to caller");

        operatorApprovals[_msgSender()][_operator] = _approved;
        emit ApprovalForAll(_msgSender(), _operator, _approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        return operatorApprovals[_owner][_operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(_from, _to, _tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public override {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal {
        _transfer(_from, _to, _tokenId);
        require(
            _checkOnERC721Received(_from, _to, _tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 _tokenId) public view returns (bool) {
        address owner = owners[_tokenId];
        return owner != address(0) && owner != DEAD_ADDRESS;
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address _spender, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        require(
            _exists(_tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(_tokenId);
        return (_spender == owner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(owner, _spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address _to, uint256 _tokenId) internal {
        _safeMint(_to, _tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal {
        _mint(_to, _tokenId);
        require(
            _checkOnERC721Received(address(0), _to, _tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0) && _to != DEAD_ADDRESS, "ERC721: mint to the zero address");
        require(!_exists(_tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), _to, _tokenId);

        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 _tokenId) internal {
        address owner = ownerOf(_tokenId);

        _beforeTokenTransfer(owner, address(0), _tokenId);

        // Clear approvals
        _approve(address(0), _tokenId);

        balances[owner] -= 1;
        delete owners[_tokenId];

        emit Transfer(owner, address(0), _tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        require(
            ownerOf(_tokenId) == _from,
            "ERC721: transfer of token that is not own"
        );
        require(_to != address(0) && _to != DEAD_ADDRESS, "ERC721: transfer to the zero address");

        _beforeTokenTransfer(_from, _to, _tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), _tokenId);

        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address _to, uint256 _tokenId) internal {
        tokenApprovals[_tokenId] = _to;
        emit Approval(ownerOf(_tokenId), _to, _tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param _from address representing the previous owner of the given token ID
     * @param _to target address that will receive the tokens
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (_to.isContract()) {
            try
                IERC721Receiver(_to).onERC721Received(
                    _msgSender(),
                    _from,
                    _tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(_to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}
}
