// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BaseStrategy} from "@octant-core/core/BaseStrategy.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IMorphoV2 {
    struct MarketParams {
        address loanToken;
        address collateralToken;
        address oracle;
        address irm;
        uint256 lltv;
    }

    // Minimal surface for supply/withdraw and reading supply balances
    function supply(MarketParams calldata market, uint256 assets, address onBehalf, bytes calldata data)
        external
        returns (uint256 shares);

    function withdraw(MarketParams calldata market, uint256 assets, address receiver, address owner)
        external
        returns (uint256 shares);

    // Common view to fetch a user's supplied assets in a market
    function supplyBalance(address user, bytes32 id) external view returns (uint256 suppliedAssets);
}

contract MorphoV2YieldDonatingStrategy is BaseStrategy {
    using SafeERC20 for ERC20;

    IMorphoV2 public immutable morpho;
    address public immutable loanToken;
    address public immutable collateralToken;
    address public immutable oracle;
    address public immutable irm;
    uint256 public immutable lltv;
    bytes32 public immutable marketId;

    constructor(
        address _morpho,
        IMorphoV2.MarketParams memory _market,
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
        morpho = IMorphoV2(_morpho);
        loanToken = _market.loanToken;
        collateralToken = _market.collateralToken;
        oracle = _market.oracle;
        irm = _market.irm;
        lltv = _market.lltv;
        marketId = keccak256(abi.encode(_market.loanToken, _market.collateralToken, _market.oracle, _market.irm, _market.lltv));

        // Approve loan token (asset) to Morpho for supplies
        ERC20(_asset).forceApprove(_morpho, type(uint256).max);
    }

    function _deployFunds(uint256 _amount) internal override {
        if (_amount == 0) return;
        IMorphoV2.MarketParams memory mp =
            IMorphoV2.MarketParams({loanToken: loanToken, collateralToken: collateralToken, oracle: oracle, irm: irm, lltv: lltv});
        morpho.supply(mp, _amount, address(this), "");
    }

    function _freeFunds(uint256 _amount) internal override {
        if (_amount == 0) return;
        IMorphoV2.MarketParams memory mp =
            IMorphoV2.MarketParams({loanToken: loanToken, collateralToken: collateralToken, oracle: oracle, irm: irm, lltv: lltv});
        morpho.withdraw(mp, _amount, address(this), address(this));
    }

    function _harvestAndReport() internal override returns (uint256 _totalAssets) {
        uint256 deployed = morpho.supplyBalance(address(this), marketId);
        uint256 idle = ERC20(address(asset)).balanceOf(address(this));
        _totalAssets = deployed + idle;
    }

    function _emergencyWithdraw(uint256 _amount) internal override {
        IMorphoV2.MarketParams memory mp =
            IMorphoV2.MarketParams({loanToken: loanToken, collateralToken: collateralToken, oracle: oracle, irm: irm, lltv: lltv});
        if (_amount == type(uint256).max) {
            // Withdraw as much as possible; pass max to request full position
            morpho.withdraw(mp, type(uint256).max, address(this), address(this));
            return;
        }
        if (_amount > 0) {
            morpho.withdraw(mp, _amount, address(this), address(this));
        }
    }
}


