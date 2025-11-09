// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console2.sol";
import {SparkYieldDonatingSetup as Setup, IStrategyInterface, ITokenizedStrategy, ERC20} from "./SparkYieldDonatingSetup.sol";

contract SparkYieldDonatingOperationTest is Setup {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_setupStrategyOK() public {
        if (sparkPool == address(0)) return;
        console2.log("address of spark strategy", address(strategy));
        assertTrue(address(0) != address(strategy));
        assertEq(strategy.asset(), address(asset));
        assertEq(strategy.management(), management);
        assertEq(ITokenizedStrategy(address(strategy)).dragonRouter(), dragonRouter);
        assertEq(strategy.keeper(), keeper);
    }

    function test_profitableReport(uint256 _amount) public {
        if (sparkPool == address(0)) return;
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);
        uint256 _timeInDays = 30;

        mintAndDepositIntoStrategy(strategy, user, _amount);
        assertEq(strategy.totalAssets(), _amount, "!totalAssets");

        skip(_timeInDays * 1 days);
        vm.prank(keeper);
        (uint256 profit, uint256 loss) = strategy.report();
        assertGt(profit, 0, "!profit");
        assertEq(loss, 0, "!loss");

        uint256 dragonRouterShares = strategy.balanceOf(dragonRouter);
        assertGt(dragonRouterShares, 0, "!dragon shares");

        uint256 balanceBefore = asset.balanceOf(user);
        vm.prank(user);
        strategy.redeem(_amount, user, user);
        assertGe(asset.balanceOf(user), balanceBefore + _amount, "!final balance");
    }

    function test_tendTrigger(uint256 _amount) public {
        if (sparkPool == address(0)) return;
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);

        (bool trigger, ) = strategy.tendTrigger();
        assertTrue(!trigger);

        mintAndDepositIntoStrategy(strategy, user, _amount);
        (trigger, ) = strategy.tendTrigger();
        assertTrue(!trigger);

        skip(30 days);
        (trigger, ) = strategy.tendTrigger();
        assertTrue(!trigger);

        vm.prank(keeper);
        strategy.report();
        (trigger, ) = strategy.tendTrigger();
        assertTrue(!trigger);

        vm.prank(user);
        strategy.redeem(_amount, user, user);
        (trigger, ) = strategy.tendTrigger();
        assertTrue(!trigger);
    }
}


