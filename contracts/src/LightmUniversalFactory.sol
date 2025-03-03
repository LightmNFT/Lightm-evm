// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.15;

import "./Diamond.sol";

import {LightmInit} from "./LightmInit.sol";
import {LightmCatalogImplementer} from "../implementations/LightmCatalogImplementer.sol";

import "./interfaces/ILightmUniversalFactory.sol";

contract LightmUniversalFactory is ILightmUniversalFactory {
    string private constant VERSION = "0.5.0-alpha";

    address private immutable _validatorLibAddress;
    address private immutable _maRenderUtilsAddress;
    address private immutable _equippableRenderUtilsAddress;
    address private immutable _diamondCutFacetAddress;
    address private immutable _diamondLoupeFacetAddress;
    address private immutable _nestableFacetAddress;
    address private immutable _multiAssetFacetAddress;
    address private immutable _equippableFacetAddress;
    address private immutable _rmrkEquippableFacetAddress;
    address private immutable _collectionMetadataFacetAddress;
    address private immutable _initContractAddress;
    address private immutable _implContractAddress;
    address private immutable _mintModuleAddress;

    IDiamondCut.FacetCut[] private _cuts;

    constructor(ConstructParams memory params) {
        _validatorLibAddress = params.validatorLibAddress;
        _maRenderUtilsAddress = params.maRenderUtilsAddress;
        _equippableRenderUtilsAddress = params.equippableRenderUtilsAddress;
        _diamondCutFacetAddress = params.diamondCutFacetAddress;
        _diamondLoupeFacetAddress = params.diamondLoupeFacetAddress;
        _nestableFacetAddress = params.nestableFacetAddress;
        _multiAssetFacetAddress = params.multiAssetFacetAddress;
        _equippableFacetAddress = params.equippableFacetAddress;
        _rmrkEquippableFacetAddress = params.rmrkEquippableFacetAddress;
        _collectionMetadataFacetAddress = params.collectionMetadataFacetAddress;
        _initContractAddress = params.initContractAddress;
        _implContractAddress = params.implContractAddress;
        _mintModuleAddress = params.mintModuleAddress;

        IDiamondCut.FacetCut[] memory facetCuts = params.cuts;
        for (uint256 i; i < facetCuts.length; ) {
            _cuts.push(facetCuts[i]);

            // gas saving
            unchecked {
                i++;
            }
        }
    }

    function version() external pure returns (string memory) {
        return VERSION;
    }

    function cuts() external view returns (IDiamondCut.FacetCut[] memory) {
        return _cuts;
    }

    function validatorLibAddress() external view returns (address) {
        return _validatorLibAddress;
    }

    function maRenderUtilsAddress() external view returns (address) {
        return _maRenderUtilsAddress;
    }

    function equippableRenderUtilsAddress() external view returns (address) {
        return _equippableRenderUtilsAddress;
    }

    function nestableFacetAddress() external view returns (address) {
        return _nestableFacetAddress;
    }

    function multiAssetFacetAddress() external view returns (address) {
        return _multiAssetFacetAddress;
    }

    function equippableFacetAddress() external view returns (address) {
        return _equippableFacetAddress;
    }

    function rmrkEquippableFacetAddress() external view returns (address) {
        return _rmrkEquippableFacetAddress;
    }

    function collectionMetadataAddress() external view returns (address) {
        return _collectionMetadataFacetAddress;
    }

    function initContractAddress() external view returns (address) {
        return _initContractAddress;
    }

    function implContractAddress() external view returns (address) {
        return _implContractAddress;
    }

    function mintModuleAddress() external view returns (address) {
        return _mintModuleAddress;
    }

    function deployCollection(
        bytes32 salt,
        LightmInit.InitStruct calldata initStruct,
        CustomInitStruct calldata customInitStruct
    ) external {
        Diamond instance = salt != bytes32(0)
            ? new Diamond{salt: salt}(address(this), _diamondCutFacetAddress)
            : new Diamond(address(this), _diamondCutFacetAddress);

        address instanceAddress = address(instance);

        IDiamondCut.FacetCut[] memory customCuts = customInitStruct.cuts;
        address customInitAddress = customInitStruct.initAddress;
        bytes memory customInitData = customInitStruct.initCallData;

        bool isCustomized = customCuts.length > 0 ||
            customInitAddress != address(0);

        emit LightmCollectionCreated(
            instanceAddress,
            msg.sender,
            salt,
            isCustomized,
            customInitStruct
        );

        IDiamondCut(instanceAddress).diamondCut(
            _cuts,
            _initContractAddress,
            abi.encodeWithSelector(
                LightmInit.init.selector,
                initStruct,
                msg.sender
            )
        );

        if (isCustomized) {
            IDiamondCut(instanceAddress).diamondCut(
                customCuts,
                customInitAddress,
                customInitData
            );
        }
    }

    function deployCatalog(string calldata metadataURI, string calldata type_)
        external
    {
        LightmCatalogImplementer instance = new LightmCatalogImplementer(
            metadataURI,
            type_
        );

        instance.transferOwnership(msg.sender);
    }
}
