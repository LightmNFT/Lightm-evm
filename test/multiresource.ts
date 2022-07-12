import { ethers } from 'hardhat';
import { expect } from 'chai';
import { RMRKMultiResourceMock } from '../typechain';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import shouldBehaveLikeMultiResource from './behavior/multiresource';

describe('MultiResource', async () => {
  let token: RMRKMultiResourceMock;

  let owner: SignerWithAddress;
  let addrs: any[];

  const name = 'RmrkTest';
  const symbol = 'RMRKTST';

  beforeEach(async function () {
    const [signersOwner, ...signersAddr] = await ethers.getSigners();
    owner = signersOwner;
    addrs = signersAddr;

    const Token = await ethers.getContractFactory('RMRKMultiResourceMock');
    token = await Token.deploy(name, symbol);
    await token.deployed();
    this.token = token;
  });

  describe('Init', async function () {
    it('Name', async function () {
      expect(await token.name()).to.equal(name);
    });

    it('Symbol', async function () {
      expect(await token.symbol()).to.equal(symbol);
    });
  });

  describe('Issuer', async function () {
    it('can set and get issuer', async function () {
      const newIssuerAddr = addrs[1].address;
      expect(await this.token.getIssuer()).to.equal(owner.address);

      await this.token.setIssuer(newIssuerAddr);
      expect(await this.token.getIssuer()).to.equal(newIssuerAddr);
    });

    it('cannot set issuer if not issuer', async function () {
      const newIssuer = addrs[1];
      await expect(
        this.token.connect(newIssuer).setIssuer(newIssuer.address),
      ).to.be.revertedWithCustomError(this.token, 'RMRKOnlyIssuer');
    });
  });

  shouldBehaveLikeMultiResource();
});
