// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BaseStrategy} from "@octant-core/core/BaseStrategy.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @dev Spark pool interface mirrors Aave V3 pool shape we use
interface ISparkPool {
    struct ReserveConfigurationMap {
        uint256 data;
    }
    struct ReserveData {
        ReserveConfigurationMap configuration;
        uint128 liquidityIndex;
        uint128 currentLiquidityRate;
        uint128 variableBorrowIndex;
        uint128 currentVariableBorrowRate;
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        uint16 id;
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint128 accruedToTreasury;
        uint128 unbacked;
        uint128 isolationModeTotalDebt;
    }

    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function getReserveData(address asset) external view returns (ReserveData memory);
}

contract SparkYieldDonatingStrategy is BaseStrategy {
    using SafeERC20 for ERC20;

    ISparkPool public immutable sparkPool;

    constructor(
        address _sparkPool,
        address _asset,
        string memory _name,
        address _management,
        address _keeper,
        address _emergencyAdmin,
        address _donationAddress,
        bool _enableBurning,
        address _tokenizedStrategyAddress
    )
        BaseStrategy(
            _asset,
            _name,
            _management,
            _keeper,
            _emergencyAdmin,
            _donationAddress,
            _enableBurning,
            _tokenizedStrategyAddress
        )
    {
        sparkPool = ISparkPool(_sparkPool);
        ERC20(_asset).forceApprove(_sparkPool, type(uint256).max);
    }

    function _deployFunds(uint256 _amount) internal override {
        if (_amount == 0) return;
        sparkPool.supply(address(asset), _amount, address(this), 0);
    }

    function _freeFunds(uint256 _amount) internal override {
        if (_amount == 0) return;
        sparkPool.withdraw(address(asset), _amount, address(this));
    }

    function _harvestAndReport() internal override returns (uint256 _totalAssets) {
        ISparkPool.ReserveData memory rd = sparkPool.getReserveData(address(asset));
        address aToken = rd.aTokenAddress;
        uint256 deployed = aToken == address(0) ? 0 : ERC20(aToken).balanceOf(address(this));
        uint256 idle = ERC20(address(asset)).balanceOf(address(this));
        _totalAssets = deployed + idle;
    }

    function _emergencyWithdraw(uint256 _amount) internal override {
        if (_amount == type(uint256).max) {
            sparkPool.withdraw(address(asset), type(uint256).max, address(this));
            return;
        }
        if (_amount > 0) {
            sparkPool.withdraw(address(asset), _amount, address(this));
        }
    }
}


