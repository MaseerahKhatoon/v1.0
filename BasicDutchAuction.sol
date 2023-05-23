//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract BasicDutchAuction {
    address payable public immutable owner;
    uint256 public immutable reservePrice;
    uint256 public immutable numBlocksAuctionOpen;
    uint256 public immutable offerPriceDecrement;

    uint256 public immutable startBlock;
    uint256 public initialPrice;
    address public winner;

    constructor(uint256 _reservePrice, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement) {
        owner = payable(msg.sender);
        reservePrice = _reservePrice;
        numBlocksAuctionOpen = _numBlocksAuctionOpen;
        offerPriceDecrement = _offerPriceDecrement;
        startBlock = block.number;

        initialPrice = reservePrice + (numBlocksAuctionOpen * offerPriceDecrement);
    }

    function getCurrentPrice() public view returns (uint256) {
        uint256 blocksElapsed = block.number - startBlock;
        if (blocksElapsed >= numBlocksAuctionOpen) {
            return reservePrice;
        } else {
            return initialPrice - (blocksElapsed * offerPriceDecrement);
        }
    }

    function bid() public payable returns(address) {
        require(winner == address(0), "Auction has already concluded");

        //Checking number of blocks which have elapsed since the start
        uint256 blocksElapsed = block.number - startBlock;
        //Throw error if auction has expired already
        require(blocksElapsed <= numBlocksAuctionOpen, "Auction expired");

        //Get the current accepted price as per dutch auction rules
        uint256 currentPrice = getCurrentPrice();
        //Throw error if the gwei value sent is less than the current accepted price
        require(
            msg.value >= currentPrice,
            "The wei value sent is not acceptable"
        );

        //Since there is no actual asset to transfer on-chain
        //we set the bidder's address as winner and stop the auction
        //Transfer the bid amount to owner
        winner = msg.sender;
        owner.transfer(msg.value);

        return winner;
    }

}
