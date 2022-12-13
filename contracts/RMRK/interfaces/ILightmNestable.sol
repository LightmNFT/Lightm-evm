// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.15;

import {IRMRKNestable} from "./IRMRKNestable.sol";

interface ILightmNestableExtension {
    function hasChild(
        uint256 tokenId,
        address childContract,
        uint256 childTokenId
    )
        external
        view
        returns (
            bool found,
            bool isPending,
            uint256 index
        );

    function reclaimChild(
        uint256 tokenId,
        address childAddress,
        uint256 childTokenId
    ) external;

    function transferChild(
        uint256 tokenId,
        address to,
        uint256 destinationId,
        address childContractAddress,
        uint256 childTokenId,
        bool isPending,
        bytes memory data
    ) external;

    function acceptChild(
        uint256 tokenId,
        address childContractAddress,
        uint256 childTokenId
    ) external;

    function nestTransfer(
        address to,
        uint256 tokenId,
        uint256 destinationId
    ) external;
}
