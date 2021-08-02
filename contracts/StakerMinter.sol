pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/BEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";
import "./EDIPI.sol";
//SPDX-License-Identifier: MIT

/**
 * @title Staking Token (EDIPI)
 * @notice Implements a basic BEP20 staking token with incentive distribution.
 */
contract StakerMinter is Ownable{
    // configure EDIPI
    uint256 public lockPeriod = 1 seconds;
    uint256 public APY = 12; // 12% return per year for staking EDIPI
    uint256 public oneYear = 365 days; //12% return per year for staking EDIPI
    uint256 public maxSupply = 1000_000_000 * 1e18; // 365 days //12% return per year for staking EDIPI

    // book keeping
    uint256 public totalEdipiStaked;
    uint256 public totalEdipiReward;
    address[] public stakeHolders;
    mapping(address => bool) public isStakeHolder;
    mapping(address => EdipiOrder[]) public edipiOrders;
    EDIPI eDIPI;

    struct EdipiOrder {
        uint256 amount; // amount of token staked
        uint256 startDate; // start date for stake
    }

    // events
    event Stake(uint256 amount);
    event Unstake(uint256 stakedAmount, uint256 stakedTime, uint256 reward);
    event HarvestedReward(
        uint256 stakedAmount,
        uint256 stakedTime,
        uint256 reward
    );

    // utility settings
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using SafeBEP20 for EDIPI;

    // functions
    constructor(EDIPI _eDIPI) public {
        eDIPI=_eDIPI;
    }

    function createStake(uint256 _amount) public {
        if (!isStakeHolder[msg.sender]) stakeHolders.push(msg.sender);
        isStakeHolder[msg.sender] = true;

        EdipiOrder[] storage userEdipiOrders = edipiOrders[msg.sender];
        eDIPI.safeTransferFrom(msg.sender, address(this), _amount);
        totalEdipiStaked = totalEdipiStaked.add(_amount);
        EdipiOrder memory stakingOrder = EdipiOrder(_amount, now);
        userEdipiOrders.push(stakingOrder);
        emit Stake(_amount);
    }

    function removeStake() public {
        EdipiOrder[] storage userEdipiOrders = edipiOrders[msg.sender];
        uint256 length = userEdipiOrders.length;
        require(length > 0, "no order");
        uint256 reward = 0;

        for (uint256 i = 0; i < length; i++) {
            EdipiOrder storage order = userEdipiOrders[i];
            if (order.amount != 0 && now > order.startDate.add(lockPeriod)) {
                reward = getReward(order.amount, order.startDate);
                totalEdipiReward = totalEdipiReward.add(reward);
                eDIPI.mint(msg.sender, reward);
                safeEDIPITransfer(msg.sender, order.amount);
                totalEdipiStaked = totalEdipiStaked.sub(order.amount);
                emit Unstake(order.amount, now.sub(order.startDate), reward);
                order.amount = 0;
            }
        }
    }

    function harvestReward() public {
        harvestReward(msg.sender);
    }

    function harvestReward(address _user) public {
        EdipiOrder[] storage userEdipiOrders = edipiOrders[_user];
        uint256 length = userEdipiOrders.length;
        require(length > 0, "no order");
        uint256 reward = 0;

        for (uint256 i = 0; i < length; i++) {
            EdipiOrder storage order = userEdipiOrders[i];
            if (order.amount != 0 && now > order.startDate.add(lockPeriod)) {
                reward = getReward(order.amount, order.startDate);
                totalEdipiReward = totalEdipiReward.add(reward);
                eDIPI.mint(_user, reward);
                emit HarvestedReward(
                    order.amount,
                    now.sub(order.startDate),
                    reward
                );
                order.startDate = now;
            }
        }
    }

    function distributeRewardToAll() public onlyOwner {
        for (uint256 i = 0; i < stakeHolders.length; i++) {
            harvestReward(stakeHolders[i]);
        }
    }

    // reading functions
    function stakeOf() external view returns (uint256) {
        return stakeOf(msg.sender);
    }

    function stakeOf(address _user) public view returns (uint256) {
        EdipiOrder[] storage userEdipiOrders = edipiOrders[_user];
        uint256 length = userEdipiOrders.length;
        uint256 stakes = 0;

        for (uint256 i = 0; i < length; i++) {
            EdipiOrder storage order = userEdipiOrders[i];
            stakes = stakes.add(order.amount);
        }

        return stakes;
    }

    function rewardOf() external view returns (uint256) {
        return rewardOf(msg.sender);
    }

    function rewardOf(address _user) public view returns (uint256) {
        EdipiOrder[] storage userEdipiOrders = edipiOrders[_user];
        uint256 length = userEdipiOrders.length;
        uint256 reward = 0;

        for (uint256 i = 0; i < length; i++) {
            EdipiOrder storage order = userEdipiOrders[i];
            if (order.amount != 0 && now > order.startDate.add(lockPeriod)) {
                reward = reward.add(getReward(order.amount, order.startDate));
            }
        }

        return reward;
    }

    // maths
    function getReward(uint256 _amount, uint256 _startDate)
        internal
        view
        returns (uint256)
    {
        uint256 stakedTime = now.sub(_startDate);
        uint256 lockPeriodsPassed = stakedTime.div(lockPeriod);
        uint256 stakedTimeForReward = lockPeriodsPassed.mul(lockPeriod);
        uint256 reward =
            _amount.mul(stakedTimeForReward).mul(APY).div(100).div(oneYear);

        return reward;
    }

    // utility functions
    
    function safeEDIPITransfer(address _to, uint256 _amount) internal {
        eDIPI.safeTransfer(_to, _amount);
    }

    function balanceOf() external view returns (uint256) {
        return eDIPI.balanceOf(msg.sender);
    }

    // setters
    function setlockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockPeriod = _lockPeriod;
    }

    function setAPY(uint256 _APY) public onlyOwner {
        APY = _APY;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    // getters
    function getStakeHolders() public view returns (address[] memory) {
        return stakeHolders;
    }

    //prevent locking of assets
    function transferBEP20(IBEP20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }
}