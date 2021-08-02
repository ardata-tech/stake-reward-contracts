pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/BEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";
//SPDX-License-Identifier: MIT

/**
 * @title Staking Token (EDIPI)
 * @notice Implements a basic BEP20 staking token with incentive distribution.
 */
contract EDIPI is IBEP20, BEP20("EDIPI Token", "EDIPI") {
    uint256 public maxSupply = 1000_000_000 * 1e18;

    // functions
    constructor() public {
        _mint(msg.sender, 500_000 * 1e18);
    }

    function mint(address _to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        if (totalSupply() < maxSupply) {
            _mint(_to, amount);
            return true;
        }
        return false;
    }

}
