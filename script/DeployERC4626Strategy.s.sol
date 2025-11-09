// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {ERC4626YieldDonatingStrategy} from "src/strategies/yieldDonating/ERC4626YieldDonatingStrategy.sol";
import {YieldDonatingTokenizedStrategy} from "@octant-core/strategies/yieldDonating/YieldDonatingTokenizedStrategy.sol";

contract DeployERC4626Strategy is Script {
    function run() external {
        address vault = vm.envAddress("ERC4626_VAULT");
        address asset = vm.envAddress("ASSET");
        string memory name = vm.envString("STRATEGY_NAME");
        address management = vm.envAddress("MANAGEMENT");
        address keeper = vm.envAddress("KEEPER");
        address emergencyAdmin = vm.envAddress("EMERGENCY_ADMIN");
        address donation = vm.envAddress("DONATION_ADDRESS");
        bool enableBurning = vm.envBool("ENABLE_BURNING");

        vm.startBroadcast();
        address tokenized = address(new YieldDonatingTokenizedStrategy());
        ERC4626YieldDonatingStrategy strategy = new ERC4626YieldDonatingStrategy(
            vault,
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

        console2.log("ERC4626 strategy:", address(strategy));
        console2.log("Tokenized impl:", tokenized);
    }
}


