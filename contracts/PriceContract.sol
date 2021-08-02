// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "smartcontractkit/chainlink-brownie-contracts@1.1.1/contracts/src/v0.6/ChainlinkClient.sol";
import "smartcontractkit/chainlink-brownie-contracts@1.1.1/contracts/src/v0.6/vendor/Ownable.sol";
import "smartcontractkit/chainlink-brownie-contracts@1.1.1/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceContract is ChainlinkClient {

    AggregatorV3Interface internal priceFeed;
    bool public priceFeedGreater;
    int256 public price;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    constructor(address _oracle, string memory _jobId, uint256 _fee, address _link, address AggregatorAddress) public {
        priceFeed = AggregatorV3Interface(AggregatorAddress);
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
    }

    /**
     * Return the latest price from Price Feed
     */ 
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

     /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, int256 _price) public recordChainlinkFulfillment(_requestId) {
        price = _price;
        priceFeedGreater = (getLatestPrice() > price);
    }

    function requestPriceData() public returns (bytes32 requestId) {
         Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD");
        request.add("path", "RAW.BTC.USD.PRICE");
        
        // Multiply the result by 1000000000000000000 to remove decimals
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

}