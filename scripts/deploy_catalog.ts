import { ethers } from 'hardhat';
import {
  IRMRKCatalog,
  LightmCatalogDeployedEvent,
} from '../typechain-types/contracts/implementations/LightmCatalogImplementer';
import { getCatalogPartId } from './libraries/catalog';
import { id } from 'ethers/lib/utils';

export const Slot = 1;
export const Fixed = 2;

/**
 * @notice By giving `lightmUniversalFactoryAddress` in param object, you will deploy catalog through `LightmUniversalFactory`,
 * the catalog deployed by factory will be indexed by graph node and displayable on Lightm UI.
 * If you don't provide `lightmUniversalFactoryAddress`, you won't be able to see the catalog on Lightm UI,
 * because we can not index this catalog contract.
 */
export async function deployCatalog({
  metadataURI,
  type_,
  lightmUniversalFactoryAddress,
  parts,
}: {
  metadataURI: string;
  type_: string;
  lightmUniversalFactoryAddress?: string;
  parts?: IRMRKCatalog.IntakeStructStruct[];
}) {
  const signer = (await ethers.getSigners())[0];

  async function deployCatalog() {
    if (lightmUniversalFactoryAddress) {
      const lightmUniversalFacotry = await ethers.getContractAt(
        'LightmUniversalFactory',
        lightmUniversalFactoryAddress,
      );

      const tx = await lightmUniversalFacotry.deployCatalog(metadataURI, type_);
      const txR = await tx.wait();
      const { events } = txR;
      const catalogDeployedEventTopic = id('LightmCatalogDeployed()');

      if (events) {
        for (let i = 0; i < events.length; i++) {
          const { address, topics } = events[i] as LightmCatalogDeployedEvent;

          if (topics[0] === catalogDeployedEventTopic) {
            const catalogAddress = address;
            const catalog = await ethers.getContractAt('LightmCatalogImplementer', catalogAddress);

            return catalog;
          }
        }
      } else {
        throw new Error('No catalog deployed event detected');
      }
    } else {
      const CatalogFactory = await ethers.getContractFactory('LightmCatalogImplementer', signer);

      const catalog = await CatalogFactory.deploy(metadataURI, type_);
      await catalog.deployed();

      return catalog;
    }
  }

  const catalog = (await deployCatalog())!;

  console.log('Deploy catalog successfully, address is', catalog.address);

  if (parts) {
    const tx = await catalog.addPartList(parts);
    await tx.wait();
  }

  return catalog.address;
}

// Why we design partId in this way: https://lightm.notion.site/Recommended-allocation-way-for-Part-ID-of-Catalog-1e471ff9f38f49c191f68db6845bc353
const part0: IRMRKCatalog.IntakeStructStruct = {
  partId: getCatalogPartId(1, 1, 0),
  part: {
    itemType: Fixed,
    z: 1,
    equippable: [],
    metadataURI: 'ipfs://bafkreifpjb6ezuidaln2vz63ma4cxedewjhu73omepcd4asv35nuzv7blq',
  },
};

const part1: IRMRKCatalog.IntakeStructStruct = {
  partId: getCatalogPartId(2, 1, 1),
  part: {
    itemType: Slot,
    z: 1,
    equippable: [],
    metadataURI: 'ipfs://bafkreihfdwwxn6ugoswbp7or34ue4nyziqw6smb755l2xqsvsisxhorih4',
  },
};

const part2: IRMRKCatalog.IntakeStructStruct = {
  partId: getCatalogPartId(3, 1, 1),
  part: {
    itemType: Slot,
    z: 1,
    equippable: [],
    metadataURI: 'ipfs://bafkreidaahujz2pjf6xzpcpctrms6gjxtrbomdz7oce7rdtyafrxm7uawi',
  },
};

// deployCatalog({
//   metadataURI: 'ipfs://bafkreifkv3gdauc756ln4tvgv23eo4yjdkrbbfqghlsvrx6w5equu5l2xy',
//   type_: 'image',
//   lightmUniversalFactoryAddress: process.env.LIGHTM_UNIVERSAL_FACTORY_ADDRESS,
//   parts: [part0, part1, part2],
// });
