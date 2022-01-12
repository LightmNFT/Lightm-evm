// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.9;

import "../RMRK/RMRKCore.sol";

//Minimal public implementation of RMRKCore for testing.

contract RMRKCoreMock is RMRKCore {

  constructor(
    string memory name_,
    string memory symbol_,
    string memory resourceName
  ) RMRKCore (
    name_,
    symbol_,
    resourceName
  ) {}

  function doMint(address to, uint256 tokenId) external {
    _mint(to, tokenId);
  }

  function doMintNest(address to, uint256 tokenId, uint256 destId, string calldata data) external {
    _mint(to, tokenId, destId, data);
  }

}
