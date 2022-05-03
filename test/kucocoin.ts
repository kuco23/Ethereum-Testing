import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';

describe("kucocoin", async function () {

	let owner: SignerWithAddress;
	let kucoin: Contract;

	beforeEach (async function () {
		[owner] = await ethers.getSigners();
		const kucoinFactory = await ethers.getContractFactory("Kucocoin");
		kucoin = await kucoinFactory.deploy();
	});
	
  it("Should do sometings", async function () {
		
    console.log(await owner.getAddress());
    let balance = await kucoin.getBalance();
    console.log(balance);
 		
    expect(balance).to.equal(100000);
  });

  it("Should use keccak256", async function () {
	  const data = "neki";
	  let kckdata = await kucoin.hash(data);
	  console.log(kckdata);
  })
});