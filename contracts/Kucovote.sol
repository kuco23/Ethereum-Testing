// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Kucovote {

    struct Request {
        address sender;
        string request;
    }

    struct Vote {
        bytes32 merkleHash;
        bytes32 randomHash;
        uint roundid;
    }

    struct Reveal {
        address sender;
        bytes32 votehash;
        uint roundid;
    }

    event NewRequest(address sender, string request);

    mapping(address => bool) hasVoted;
    mapping(address => Vote) votes;
    
    Reveal[] reveals;
    mapping(bytes32 => uint) revealCount;

    uint requestdur = 2 hours;
    uint votedur = 1 hours;
    uint revealdur = 1 hours;
    uint requestend;
    uint voteend;
    uint revealend;
    uint roundid = 0;

    constructor() { 
        init();
    }

    modifier requestPeriod() {
        require(block.timestamp < requestend);
        _;
    }

    modifier votePeriod() {
        require(block.timestamp >= requestend && block.timestamp < voteend);
        _;
    }

    modifier revealPeriod() {
        require(block.timestamp >= voteend && block.timestamp < revealend);
        _;
    }

    function init() private {
        delete reveals;
        requestend = block.timestamp + requestdur;
        voteend = requestend + votedur;
        revealend = voteend + revealdur;
        roundid++;
    }

    function request(string calldata req) external {
        if (block.timestamp >= voteend) init();
        require(block.timestamp < requestend);
        emit NewRequest(msg.sender, req);
    }

    // can vote multiple times
    function vote(bytes32 merkleHash, bytes32 randomHash) external votePeriod {
        if (hasVoted[msg.sender] == false) {
            hasVoted[msg.sender] = true;
            votes[msg.sender] = Vote(merkleHash, randomHash, roundid);
        }
    }

    function reveal(bytes32 revealedMerkle, bytes32 revealedRandom) revealPeriod external {
        require(hasVoted[msg.sender]);
        hasVoted[msg.sender] = false;
        Vote memory _vote = votes[msg.sender];
        require(_vote.roundid == roundid);
        bytes32 randomHash = keccak256(abi.encodePacked(revealedRandom));
        require(_vote.randomHash == randomHash, "indexed vote random hash does not match with the revealed hash");
        bytes32 merkleHash = keccak256(abi.encodePacked(revealedMerkle, revealedRandom));
        require(_vote.merkleHash == merkleHash, "indexed vote merkle hash does not match with the revealed hash");
        reveals.push(Reveal(msg.sender, revealedMerkle, roundid));

        if (revealCount[revealedMerkle] == 0)
            revealCount[revealedMerkle] = 1;
        else 
            revealCount[revealedMerkle] += 1;
    }

    function getWinningHash() external view returns (bytes32) {
        uint winningHashCount = 0;
        bytes32 winningHash;
        for (uint i = 0; i < reveals.length; i++) {
            Reveal memory _reveal = reveals[i];
            uint count = revealCount[_reveal.votehash];
            if (winningHashCount < count) {
                winningHashCount = count;
                winningHash = _reveal.votehash;
            }
        }
        return winningHash;
    }
}