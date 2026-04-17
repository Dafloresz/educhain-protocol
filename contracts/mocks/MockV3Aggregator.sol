// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title MockV3Aggregator
 * @notice Mock do Chainlink AggregatorV3Interface para testes locais.
 *         Replica a interface exata do Chainlink sem dependência de fork.
 */
contract MockV3Aggregator {
    uint8  public decimals;
    int256 public latestAnswer;
    uint256 public latestTimestamp;
    uint80  private _roundId;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals      = _decimals;
        latestAnswer  = _initialAnswer;
        latestTimestamp = block.timestamp;
        _roundId      = 1;
    }

    function updateAnswer(int256 _answer) external {
        latestAnswer    = _answer;
        latestTimestamp = block.timestamp;
        _roundId++;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80  roundId,
            int256  answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80  answeredInRound
        )
    {
        return (_roundId, latestAnswer, latestTimestamp, latestTimestamp, _roundId);
    }

    function getRoundData(uint80 /*_roundId*/)
        external
        view
        returns (
            uint80  roundId,
            int256  answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80  answeredInRound
        )
    {
        return (_roundId, latestAnswer, latestTimestamp, latestTimestamp, _roundId);
    }
}
