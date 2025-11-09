// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.25;

import "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";

import {MorphoV2YieldDonatingStrategy as Strategy, IMorphoV2, ERC20} from "../../strategies/yieldDonating/MorphoV2YieldDonatingStrategy.sol";
import {IStrategyInterface} from "../../interfaces/IStrategyInterface.sol";
import {ITokenizedStrategy} from "@octant-core/core/interfaces/ITokenizedStrategy.sol";
import {YieldDonatingTokenizedStrategy} from "@octant-core/strategies/yieldDonating/YieldDonatingTokenizedStrategy.sol";

contract MorphoYieldDonatingSetup is Test {
    ERC20 public asset;
    IStrategyInterface public strategy;

    address public user = address(10);
    address public keeper = address(4);
    address public management = address(1);
    address public dragonRouter = address(3);
    address public emergencyAdmin = address(5);

    bool public enableBurning = true;
    address public tokenizedStrategyAddress;

    IMorphoV2.MarketParams public market;
    address public morphoCore;
    bool public configOk;

    uint256 public decimals;
    uint256 public maxFuzzAmount;
    uint256 public minFuzzAmount = 10_000;

    function setUp() public virtual {
        address testAssetAddress = vm.envAddress("TEST_ASSET_ADDRESS");
        require(testAssetAddress != address(0), "TEST_ASSET_ADDRESS not set");
        asset = ERC20(testAssetAddress);
        decimals = asset.decimals();
        maxFuzzAmount = 1_000_000 * 10 ** decimals;

        morphoCore = vm.envAddress("MORPHO_CORE");
        address loanToken = vm.envAddress("MORPHO_LOAN_TOKEN");
        address collateralToken = vm.envAddress("MORPHO_COLLATERAL_TOKEN");
        address oracle = vm.envAddress("MORPHO_ORACLE");
        address irm = vm.envAddress("MORPHO_IRM");
        uint256 lltv = vm.envOr("MORPHO_LLTV", uint256(0));

        if (
            morphoCore == address(0) ||
            loanToken == address(0) ||
            collateralToken == address(0) ||
            oracle == address(0) ||
            irm == address(0) ||
            lltv == 0
        ) {
            configOk = false;
            return;
        }
        configOk = true;

        market = IMorphoV2.MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: oracle,
            irm: irm,
            lltv: lltv
        });

        tokenizedStrategyAddress = address(new YieldDonatingTokenizedStrategy());

        strategy = IStrategyInterface(
            address(
                new Strategy(
                    morphoCore,
                    market,
                    address(asset),
                    "Morpho YieldDonating",
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


