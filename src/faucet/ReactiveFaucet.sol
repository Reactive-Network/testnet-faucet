// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.29;

import { AbstractReactive } from "../../lib/reactive-lib-omni/src/base/AbstractReactive.sol";

contract ReactiveFaucet is AbstractReactive {

    uint256 private constant PAYMENT_REQUEST_TOPIC_0 = 0x8e191feb68ec1876759612d037a111be48d8ec3db7f72e4e7d321c2c8008bd0d;
    uint256 private constant EXCHANGE_RATE_FACTOR = 10000;

    address public immutable owner;
    uint256 public immutable chainId;
    address public immutable l1;
    uint256 public max_payout;
    uint256 public exchangeRate;
    uint256 public gasReserve;
    bool public paused;

    event Dispensed(address indexed receiver, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, 'Unauthorized');
        _;
    }

    constructor(
        uint256 _chainId,
        address _l1,
        uint256 _max_payout,
        uint256 _exchangeRate,
        uint256 _gasReserve
    ) payable {
        owner = msg.sender;
        chainId = _chainId;
        l1 = _l1;
        max_payout = _max_payout;
        exchangeRate = _exchangeRate;
        gasReserve = _gasReserve;
        SYSTEM.subscribe(chainId, l1, PAYMENT_REQUEST_TOPIC_0, REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE);
    }

    function react(LogRecord calldata log) external onlySystem {
        if (paused) return;

        address payable receiver = payable(address(uint160(log.topic1)));
        uint256 adjustedAmount = (log.topic2 * exchangeRate) / EXCHANGE_RATE_FACTOR;

        require(adjustedAmount <= max_payout, 'Max payout exceeded');
        // Never pay out the balance the system needs to charge this contract for gas.
        require(adjustedAmount + gasReserve <= address(this).balance, 'Not enough funds');

        // call instead of transfer: smart-wallet receivers need more than 2300 gas.
        (bool ok,) = receiver.call{value: adjustedAmount}('');
        require(ok, 'Transfer failed');

        emit Dispensed(receiver, adjustedAmount);
    }

    function pause() external onlyOwner {
        require(!paused, 'Already paused');
        SYSTEM.unsubscribe(chainId, l1, PAYMENT_REQUEST_TOPIC_0, REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE);
        paused = true;
    }

    function resume() external payable onlyOwner {
        require(paused, 'Not paused');
        _coverDebt();
        SYSTEM.subscribe(chainId, l1, PAYMENT_REQUEST_TOPIC_0, REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE);
        paused = false;
    }

    /// @notice Tops up (optionally) and settles any debt to the system contract so react() fires again.
    function coverDebt() external payable onlyOwner {
        _coverDebt();
    }

    function setMaxPayout(uint256 _max_payout) external onlyOwner {
        max_payout = _max_payout;
    }

    function setExchangeRate(uint256 _exchangeRate) external onlyOwner {
        exchangeRate = _exchangeRate;
    }

    function setGasReserve(uint256 _gasReserve) external onlyOwner {
        gasReserve = _gasReserve;
    }

    function withdraw(address payable to, uint256 amount) external onlyOwner {
        (bool ok,) = to.call{value: amount}('');
        require(ok, 'Transfer failed');
    }
}