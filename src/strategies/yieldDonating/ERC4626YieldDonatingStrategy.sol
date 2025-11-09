// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BaseStrategy} from "@octant-core/core/BaseStrategy.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    function balanceOf(address account) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
}

contract ERC4626YieldDonatingStrategy is BaseStrategy {
    using SafeERC20 for ERC20;

    address public immutable vault;

    constructor(
        address _vault,
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
        vault = _vault;
        ERC20(_asset).forceApprove(_vault, type(uint256).max);
    }

    function _deployFunds(uint256 _amount) internal override {
        if (_amount == 0) return;
        IERC4626(vault).deposit(_amount, address(this));
    }

    function _freeFunds(uint256 _amount) internal override {
        if (_amount == 0) return;
        uint256 sharesToRedeem = _amount == type(uint256).max ? IERC4626(vault).balanceOf(address(this)) : 0;
        if (sharesToRedeem == 0) {
            sharesToRedeem = IERC4626(vault).balanceOf(address(this));
        }
        if (sharesToRedeem > 0) {
            IERC4626(vault).redeem(sharesToRedeem, address(this), address(this));
        }
    }

    function _harvestAndReport() internal override returns (uint256 _totalAssets) {
        uint256 sharesHeld = IERC4626(vault).balanceOf(address(this));
        uint256 deployed = sharesHeld == 0 ? 0 : IERC4626(vault).convertToAssets(sharesHeld);
        uint256 idle = ERC20(address(asset)).balanceOf(address(this));
        _totalAssets = deployed + idle;
    }

    function _emergencyWithdraw(uint256 _amount) internal override {
        uint256 sharesHeld = IERC4626(vault).balanceOf(address(this));
        if (_amount == type(uint256).max) {
            if (sharesHeld > 0) {
                IERC4626(vault).redeem(sharesHeld, address(this), address(this));
            }
            return;
        }
        if (sharesHeld > 0) {
            IERC4626(vault).redeem(sharesHeld, address(this), address(this));
        }
    }
}


