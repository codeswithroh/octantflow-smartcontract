// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {YieldDonatingStrategy} from "src/strategies/yieldDonating/YieldDonatingStrategy.sol";
import {YieldDonatingTokenizedStrategy} from "@octant-core/strategies/yieldDonating/YieldDonatingTokenizedStrategy.sol";

contract DeployAaveStrategy is Script {
    function run() external {
        address aavePool = vm.envAddress("AAVE_POOL");
        address asset = vm.envAddress("ASSET");
        string memory name = vm.envString("STRATEGY_NAME");
        address management = vm.envAddress("MANAGEMENT");
        address keeper = vm.envAddress("KEEPER");
        address emergencyAdmin = vm.envAddress("EMERGENCY_ADMIN");
        address donation = vm.envAddress("DONATION_ADDRESS");
        bool enableBurning = vm.envBool("ENABLE_BURNING");

        vm.startBroadcast();
        address tokenized = address(new YieldDonatingTokenizedStrategy());
        YieldDonatingStrategy strategy = new YieldDonatingStrategy(
            aavePool,
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

        console2.log("Aave strategy:", address(strategy));
        console2.log("Tokenized impl:", tokenized);
    }
}


