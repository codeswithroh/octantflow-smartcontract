// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.25;

import "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

import {SparkYieldDonatingStrategy as Strategy, ERC20} from "../../strategies/yieldDonating/SparkYieldDonatingStrategy.sol";
import {IStrategyInterface} from "../../interfaces/IStrategyInterface.sol";
import {ITokenizedStrategy} from "@octant-core/core/interfaces/ITokenizedStrategy.sol";
import {YieldDonatingTokenizedStrategy} from "@octant-core/strategies/yieldDonating/YieldDonatingTokenizedStrategy.sol";

contract SparkYieldDonatingSetup is Test {
    ERC20 public asset;
    IStrategyInterface public strategy;

    address public user = address(10);
    address public keeper = address(4);
    address public management = address(1);
    address public dragonRouter = address(3);
    address public emergencyAdmin = address(5);

    bool public enableBurning = true;
    address public tokenizedStrategyAddress;
    address public sparkPool;

    uint256 public decimals;
    uint256 public maxFuzzAmount;
    uint256 public minFuzzAmount = 10_000;

    function setUp() public virtual {
        address testAssetAddress = vm.envAddress("TEST_ASSET_ADDRESS");
        require(testAssetAddress != address(0), "TEST_ASSET_ADDRESS not set");
        asset = ERC20(testAssetAddress);
        decimals = asset.decimals();
        maxFuzzAmount = 1_000_000 * 10 ** decimals;

        sparkPool = vm.envAddress("SPARK_POOL");
        if (sparkPool == address(0)) {
            // No configuration; tests will no-op
            return;
        }

        tokenizedStrategyAddress = address(new YieldDonatingTokenizedStrategy());

        strategy = IStrategyInterface(
            address(
                new Strategy(
                    sparkPool,
                    address(asset),
                    "Spark YieldDonating",
                    management,
                    keeper,
                    emergencyAdmin,
                    dragonRouter,
                    enableBurning,
                    tokenizedStrategyAddress
                )
            )
        );
    }

    function mintAndDepositIntoStrategy(IStrategyInterface _strategy, address _user, uint256 _amount) public {
        airdrop(asset, _user, _amount);
        vm.prank(_user);
        asset.approve(address(_strategy), _amount);
        vm.prank(_user);
        _strategy.deposit(_amount, _user);
    }

    function airdrop(ERC20 _asset, address _to, uint256 _amount) public {
        uint256 balanceBefore = _asset.balanceOf(_to);
        deal(address(_asset), _to, balanceBefore + _amount);
    }
}


