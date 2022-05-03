// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Kucovote {

    struct Request {
        address sender;
        string request;
    }

    struct Vote {
        address sender;
        bytes32 merkleHash;
        bytes32 randomHash;
    }

    struct Reveal {
        address sender;
        bytes32 votehash;
    }

    event NewRequest(address sender, string request);

    uint roundId = 0;

    Request[] requests;
    Vote[] votes;
    Reveal[] reveals;
    mapping(bytes32 => uint) revealCount;

    uint requestdur = 3 hours;
    uint votedur = 2 hours;
    uint revealdur = 1 hours;
    uint requestend;
    uint voteend;
    uint revealend;

    constructor() { 
        prepareNewRound();
        roundId = 0;
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

    modifier checkNewRound() {
        if (block.timestamp > revealend) {
            // countReveals();
            prepareNewRound();
        }
        _;
    }

    function prepareNewRound() private {
        delete requests;
        delete votes;
        delete reveals;
        requestend = block.timestamp + requestdur;
        voteend = requestend + votedur;
        revealend = voteend + revealdur;
        roundId++;
    }

    function request(string calldata req) external requestPeriod {
        emit NewRequest(msg.sender, req);
    }

    // can vote multiple times
    function vote(bytes32 merkleHash, bytes32 randomHash) external votePeriod {
        votes.push(Vote(msg.sender, merkleHash, randomHash));
    }

    function reveal(uint i, bytes32 revealedMerkle, bytes32 revealedRandom) revealPeriod external {
        Vote memory _vote = votes[i];
        require(_vote.sender == msg.sender, "indexed vote sender does not match with contract caller");
        bytes32 randomHash = keccak256(abi.encodePacked(revealedRandom));
        require(_vote.randomHash == randomHash, "indexed vote random hash does not match with the revealed hash");
        bytes32 merkleHash = keccak256(abi.encodePacked(revealedMerkle, revealedRandom));
        require(_vote.merkleHash == merkleHash, "indexed vote merkle hash does not match with the revealed hash");
        reveals.push(Reveal(msg.sender, revealedMerkle));

        if (revealCount[revealedMerkle] == 0)
            revealCount[revealedMerkle] = 1;
        else 
            revealCount[revealedMerkle] += 1;
        
        delete votes[i];
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

    function getVoteIndex() external view returns (uint) {
        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].sender == msg.sender) return i;
        }
        return 0;
    }
}