// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {MorphoV2YieldDonatingStrategy, IMorphoV2} from "src/strategies/yieldDonating/MorphoV2YieldDonatingStrategy.sol";
import {YieldDonatingTokenizedStrategy} from "@octant-core/strategies/yieldDonating/YieldDonatingTokenizedStrategy.sol";

contract DeployMorphoStrategy is Script {
    function run() external {
        address morpho = vm.envAddress("MORPHO_CORE");
        address loanToken = vm.envAddress("MORPHO_LOAN_TOKEN");
        address collateralToken = vm.envAddress("MORPHO_COLLATERAL_TOKEN");
        address oracle = vm.envAddress("MORPHO_ORACLE");
        address irm = vm.envAddress("MORPHO_IRM");
        uint256 lltv = vm.envUint("MORPHO_LLTV");

        address asset = vm.envAddress("ASSET");
        string memory name = vm.envString("STRATEGY_NAME");
        address management = vm.envAddress("MANAGEMENT");
        address keeper = vm.envAddress("KEEPER");
        address emergencyAdmin = vm.envAddress("EMERGENCY_ADMIN");
        address donation = vm.envAddress("DONATION_ADDRESS");
        bool enableBurning = vm.envBool("ENABLE_BURNING");

        IMorphoV2.MarketParams memory market = IMorphoV2.MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: oracle,
            irm: irm,
            lltv: lltv
        });

        vm.startBroadcast();
        address tokenized = address(new YieldDonatingTokenizedStrategy());
        MorphoV2YieldDonatingStrategy strategy = new MorphoV2YieldDonatingStrategy(
            morpho,
            market,
            asset,
            name,
            management,
            keeper,
            emergencyAdmin,
            donation,
            enableBurning,
            tokenized
        );
        vm.stopBroadcast();

        console2.log("Morpho strategy:", address(strategy));
        console2.log("Tokenized impl:", tokenized);
    }
}


