import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, web3 } from 'hardhat';

describe("kucocoin", async () => {

	let owner: SignerWithAddress;
	let kucoin: Contract;

	beforeEach (async function () {
		[owner] = await ethers.getSigners();
		const kucoinFactory = await ethers.getContractFactory("KucoinERC20");
		kucoin = await kucoinFactory.deploy();
	});
	
  it("Should do sometings", async function () {
    let tx = await kucoin.balanceOf(owner.address);
    console.log(tx);
  });
});