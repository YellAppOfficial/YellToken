// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../../access/Ownable.sol";


/**
 * @dev This can be used to impose a limit on the amount that can be transferred within a single transaction (Also known as anti-whale)
 * It should be de-activated once certain liquidity levels are reached and it is done to make it difficult for whales to buy or sell big amounts early on
 */
contract AntiWhale is Ownable { 
    uint256 private _threshold;
    bool private _isActivated;

    function getTransactionLimitActivated() public view returns (bool) {
        return _isActivated;
    }

    function setTransactionLimitActivated(bool isActivated) public onlyOwner {
        require(_isActivated != isActivated, "Anti-whale status unchanged");
        _isActivated = isActivated;
    }

    function getTransactionLimit() public view returns (uint256) {
        return _threshold;
    }

    function setTransactionLimit(uint256 threshold) public onlyOwner {
        _threshold = threshold;
    }

    function isWithinLimit(uint256 amount) public view returns (bool) {
        return msg.sender == owner() || !_isActivated || amount <= _threshold;
    }
}
