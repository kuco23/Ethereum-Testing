import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { randomInt } from 'crypto';
import { Contract } from 'ethers';
import { ethers, web3 } from 'hardhat';

const hour = 60 * 60;

async function increaseTime(time: number) {
  /* const blockNumBefore = await provider.getBlockNumber();
  const blockBefore = await provider.getBlock(blockNumBefore); */
  
  await ethers.provider.send('evm_increaseTime', [time]);
  await ethers.provider.send('evm_mine', []);
  
  /* const blockNumAfter = await provider.getBlockNumber();
  const blockAfter = await provider.getBlock(blockNumAfter); */
}

describe("kucovote", async function () {

	let owner: SignerWithAddress;
	let kucovote: Contract;

	beforeEach (async function () {
		[owner] = await ethers.getSigners();
		const kucovoteFactory = await ethers.getContractFactory("Kucovote");
		kucovote = await kucovoteFactory.deploy();
    kucovote.provider
	});
	
  it("Should correctly do RVR (request, vote, reveal)", async function () {

    let request = 'I sent 10BTC from addr 0x0 to 0x0';
    let reqpromise = kucovote.request(request);
    
    await expect(reqpromise).to.emit(kucovote, "NewRequest").withArgs(owner.address, request);

    increaseTime(2 * hour);

    let BTCTX = '10BTC was sent from addr 0x0 to addr 0x0 at time t';
    let random = web3.utils.keccak256(randomInt(1000).toString());
    let merkle = web3.utils.keccak256(BTCTX);
    
    let merklehash = web3.utils.keccak256(web3.utils.encodePacked(merkle, random)!);
    let randomhash = web3.utils.keccak256(random);

    await kucovote.vote(merklehash, randomhash);
    let voteid: number = await kucovote.getVoteIndex();

    increaseTime(hour);

    await kucovote.reveal(voteid, merkle, random);

    increaseTime(hour);

    let winninghash = await kucovote.getWinningHash();
    expect(merkle == winninghash);

  });

  it.only("Should calculate the root", async function() {
    let a = 10;
    let r = 3; 
    let m = await kucovote.nthRoot(a, r, 3, 5);

    console.log(m / 10e9);
  })
  
});