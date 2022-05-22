// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract KuTso {

    uint256 constant epochDur = 1 minutes;
    uint256 epochStart;
    uint256 epochId = 0;

    struct PriceSubmition {
        bytes32 priceHash;
    }

    struct RevealSubmition {
        address sender;
        uint256 epochId;
        uint256 price;
    }

    mapping(uint256 => mapping(address => PriceSubmition)) submitionsByEpoch;
    mapping(uint256 => uint256[]) pricesByEpoch;
    mapping(uint256 => uint256) medianByEpoch;

    event RevealApproved(address sender, uint256 price);
    event EpochMedian(uint256 epoch, uint256 median);

    constructor() { 
        epochStart = block.timestamp;
    } 

    modifier update() {
        uint256 epoch = (block.timestamp - epochStart) / epochDur;
        if (epochId != epoch) {
            uint256 median = _median(epochId);
            emit EpochMedian(epochId, median);
            epochId = epoch;
        }
        _;
    }

    function submit(bytes32 priceHash, uint256 epoch) external update {
        require(epoch == epochId);
        submitionsByEpoch[epoch][msg.sender] = PriceSubmition(priceHash);
    }

    function reveal(uint256 price, bytes32 random, uint256 epoch) external update {
        require(epoch + 1 == epochId); // sender reveals data sent in the previous epoch
        PriceSubmition storage submition = submitionsByEpoch[epoch][msg.sender];
        bytes32 priceHash = keccak256(abi.encodePacked(price, random));
        require(priceHash == submition.priceHash);
        pricesByEpoch[epochId].push(price);
        emit RevealApproved(msg.sender, price);
        delete submitionsByEpoch[epoch][msg.sender]; // sender can only reveal once 
    }

    function _median(uint256 epoch) internal view returns(uint256) {
        uint256[] storage prices = pricesByEpoch[epoch];
        uint256 median;
        for (uint256 i = 0; i < prices.length; i++) {
            // calculate the median (e.g. with quickselect)
        }
        return median;
    }
}