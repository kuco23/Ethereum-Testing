import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { contract, ethers, web3 } from 'hardhat';
import { randomInt } from 'crypto';
import { keccak256 } from 'ethers/lib/utils';

async function increaseTime(time: number) {
  await ethers.provider.send('evm_increaseTime', [time]);
  await ethers.provider.send('evm_mine', []);
}

contract('kutso', async accounts => {

  describe("kutso", async () => {

    let signers : SignerWithAddress[]
    let kutso: Contract;
  
    beforeEach (async function () {
      signers = await ethers.getSigners();
      const kutsoFactory = await ethers.getContractFactory("KuTso");
      kutso = await kutsoFactory.deploy();
    });
    
    it("Should price submit", async function () {
      let n = 2;
      let prices = [];
      for (let i = 0; i < n; i++) prices.push(randomInt(100));
      
      let randoms = [];
      for (let i = 0; i < n; i++) {
        randoms.push(web3.utils.keccak256(randomInt(10**6).toString()));
        let hash = keccak256(web3.utils.encodePacked(prices[i].toString(), randoms[i])!);
        await kutso.connect(signers[i]).submit(hash, 0);
      } 
      increaseTime(60);
      for (let i = 0; i < n; i++) {
        let tx = kutso.connect(signers[i]).reveal(prices[i], randoms[i], 0);
        await expect(tx).to.emit(kutso, "RevealApproved").withArgs(accounts[i], prices[i]);
      }
      
    });
  });
  
})