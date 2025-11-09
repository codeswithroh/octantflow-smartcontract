// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console2.sol";
import {MorphoYieldDonatingSetup as Setup, IStrategyInterface, ERC20} from "./MorphoYieldDonatingSetup.sol";

contract MorphoYieldDonatingShutdownTest is Setup {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_shutdownCanWithdraw(uint256 _amount) public {
        if (!configOk) return;
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);

        mintAndDepositIntoStrategy(strategy, user, _amount);
        assertEq(strategy.totalAssets(), _amount, "!totalAssets");

        skip(30 days);

        vm.prank(emergencyAdmin);
        strategy.shutdownStrategy();
        assertEq(strategy.totalAssets(), _amount, "!totalAssets");

        uint256 balanceBefore = asset.balanceOf(user);
        vm.prank(user);
        strategy.redeem(_amount, user, user);
        assertGe(asset.balanceOf(user), balanceBefore + _amount, "!final balance");
    }

    function test_emergencyWithdraw_maxUint(uint256 _amount) public {
        if (!configOk) return;
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);

        mintAndDepositIntoStrategy(strategy, user, _amount);
        assertEq(strategy.totalAssets(), _amount, "!totalAssets");

        skip(30 days);

        vm.prank(emergencyAdmin);
        strategy.shutdownStrategy();
        assertEq(strategy.totalAssets(), _amount, "!totalAssets");

        vm.prank(emergencyAdmin);
        strategy.emergencyWithdraw(type(uint256).max);

        uint256 balanceBefore = asset.balanceOf(user);
        vm.prank(user);
        strategy.redeem(_amount, user, user);
        assertGe(asset.balanceOf(user), balanceBefore + _amount, "!final balance");
    }
}


