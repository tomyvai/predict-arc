// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PredictionMarket {
    address public owner;

    struct Market {
        string question;
        bool resolved;
        bool outcome; 
        uint256 totalYes;
        uint256 totalNo;
        mapping(address => uint256) yesBets;
        mapping(address => uint256) noBets;
    }

    Market[] public markets;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function createMarket(string memory _question) public onlyOwner {
        Market storage newMarket = markets.push();
        newMarket.question = _question;
        newMarket.resolved = false;
    }

    function bet(uint256 _marketId, bool _prediction) public payable {
        require(_marketId < markets.length, "Market does not exist");
        require(!markets[_marketId].resolved, "Market already resolved");
        require(msg.value > 0, "Bet amount must be > 0");

        if (_prediction) {
            markets[_marketId].yesBets[msg.sender] += msg.value;
            markets[_marketId].totalYes += msg.value;
        } else {
            markets[_marketId].noBets[msg.sender] += msg.value;
            markets[_marketId].totalNo += msg.value;
        }
    }

    function resolveMarket(uint256 _marketId, bool _outcome) public onlyOwner {
        require(!markets[_marketId].resolved, "Market already resolved");
        markets[_marketId].resolved = true;
        markets[_marketId].outcome = _outcome;
    }

    function claimWinnings(uint256 _marketId) public {
        Market storage market = markets[_marketId];
        require(market.resolved, "Market not resolved yet");
        
        uint256 amountToClaim;
        if (market.outcome) {
            amountToClaim = market.yesBets[msg.sender];
            market.yesBets[msg.sender] = 0;
        } else {
            amountToClaim = market.noBets[msg.sender];
            market.noBets[msg.sender] = 0;
        }
        
        require(amountToClaim > 0, "No winnings to claim");
        payable(msg.sender).transfer(amountToClaim);
    }
}
