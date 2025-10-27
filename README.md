# Strategy Templates for Octant

This repository provides templates for creating strategies compatible with Octant's ecosystem using [Foundry](https://book.getfoundry.sh/). It supports **YieldDonating** strategies adapted for Octant's public goods funding model.

## Strategy Types

### YieldDonating Strategies (`src/strategies/yieldDonating/`)
- **Purpose**: Donate yield generated from productive assets to public goods funding
- **Profit Distribution**: Profits are minted as shares to a designated `dragonRouter` address instead of charging performance fees
- **Loss Protection**: When enabled, the strategy can burn shares from the dragonRouter to cover losses and protect users
- **Use Case**: Traditional yield strategies (Aave, Compound, Yearn vaults) that donate their yield to Octant


## Key Differences from Standard Yearn Strategies

This repository is adapted from Yearn V3 tokenized strategies for Octant's ecosystem:

- ❌ **No Performance Fees**: Strategies don't charge performance fees to users
- ✅ **Profit Donation**: All profits are donated to Octant's dragonRouter for public goods funding
- ✅ **Loss Protection**: Optional burning of dragon shares to protect users from losses

## Repository Structure

```
src/
├── strategies/
│   └── yieldDonating/
│       ├── YieldDonatingStrategy.sol        # Template for yield harvesting strategies
│       └── YieldDonatingStrategyFactory.sol
├── interfaces/
│   └── IStrategyInterface.sol
└── test/
    └── yieldDonating/                       # Tests for YieldDonating pattern
        ├── YieldDonatingSetup.sol           # Base setup for YieldDonating tests
        ├── YieldDonatingOperation.t.sol     # Main operation tests
        ├── YieldDonatingFunctionSignature.t.sol # Function signature collision tests
        └── YieldDonatingShutdown.t.sol      # Shutdown and emergency tests
```

## Getting Started

For YieldDonating strategies, you need to override three core functions:
- `_deployFunds`: Deploy assets into yield-generating positions
- `_freeFunds`: Withdraw assets from positions  
- `_harvestAndReport`: Harvest rewards and report total assets

Optional overrides include `_tend`, `_tendTrigger`, `availableDepositLimit`, `availableWithdrawLimit` and `_emergencyWithdraw`.

## How to start

### Requirements

- First you will need to install [Foundry](https://book.getfoundry.sh/getting-started/installation).
NOTE: If you are on a windows machine it is recommended to use [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- Install [Node.js](https://nodejs.org/en/download/package-manager/)

### Clone this repository

```sh
git clone --recursive https://github.com/golemfoundation/octant-v2-tokenized-strategy-foundry-mix

cd octant-v2-tokenized-strategy-foundry-mix

yarn
```

### Set your environment Variables

Use the `.env.example` template to create a `.env` file and store the environment variables. You will need to populate the `RPC_URL` for the desired network(s). RPC url can be obtained from various providers, including [Ankr](https://www.ankr.com/rpc/) (no sign-up required) and [Infura](https://infura.io/).

Use .env file

1. Make a copy of `.env.example`
2. Add the value for `ETH_RPC_URL` and other example vars
     NOTE: If you set up a global environment variable, that will take precedence.

### Build the project

```sh
make build
```

Run tests

```sh
make test
```

## Strategy Implementation Guide

### YieldDonating Pattern

For strategies that harvest external rewards and donate them to public goods funding.

**Example Use Cases:**
- Aave lending strategies
- Compound lending strategies
- Yearn vault strategies
- Any strategy that earns separate reward tokens

**Key Implementation Points:**
```solidity
function _deployFunds(uint256 _amount) internal override {
    // Deploy assets into yield source
    // Example: aavePool.supply(address(asset), _amount, address(this), 0);
}

function _freeFunds(uint256 _amount) internal override {
    // Withdraw assets from yield source
    // Example: aavePool.withdraw(address(asset), _amount, address(this));
}

function _harvestAndReport() internal override returns (uint256 _totalAssets) {
    // 1. Claim rewards from yield source
    // 2. Sell rewards for base asset (optional)
    // 3. Return accurate total assets including loose balance
    // 4. Profits will automatically be minted to dragonRouter
}
```


## Strategy Pattern Details

### YieldDonating Pattern

Designed for strategies that:
1. Deploy assets into external yield sources (Aave, Compound, etc.)
2. Harvest external rewards or interest
3. Donate all profits by minting shares to dragonRouter
4. Optionally protect against losses by burning dragonRouter shares

**Key Features:**
- No performance fees charged to users
- All yield goes to public goods funding
- Loss protection through dragon share burning
- Compatible with any yield source that provides separate rewards


## Testing

### YieldDonating Strategy Tests
- **Profit Distribution**: Verify profits are minted to dragonRouter
- **Loss Protection**: Test dragon share burning during losses
- **Harvest Functionality**: Test reward claiming and asset accounting
- **Dragon Router Management**: Test address updates and cooldowns


Run tests:

```sh
# All tests
make test

# YieldDonating tests
make test-contract contract=YieldDonatingOperation
make test-contract contract=YieldDonatingFunctionSignature
make test-contract contract=YieldDonatingShutdown

# With traces for debugging
make trace
```

## Current Implementation Status


## Dependencies

This repository uses octant-v2-core from GitHub:
```bash
forge install golemfoundation/octant-v2-core
```

The strategies inherit from `BaseStrategy` available in octant-v2-core and use the TokenizedStrategy pattern for vault functionality.


## Example Implementations

### YieldDonating: Morpho Compounder Strategy
```solidity
function _deployFunds(uint256 _amount) internal override {
    IERC4626(compounderVault).deposit(_amount, address(this));
}

function _harvestAndReport() internal view override returns (uint256 _totalAssets) {
    // get strategy's balance in the vault
    uint256 shares = IERC4626(compounderVault).balanceOf(address(this));
    uint256 vaultAssets = IERC4626(compounderVault).convertToAssets(shares);

    // include idle funds as per BaseStrategy specification
    uint256 idleAssets = IERC20(asset).balanceOf(address(this));

    _totalAssets = vaultAssets + idleAssets;

    return _totalAssets;
}
```


## Contract Verification

Once deployed and verified, strategies will need TokenizedStrategy function verification on Etherscan:

1. Navigate to the contract's /#code page on Etherscan
2. Click "More Options" → "is this a proxy?"
3. Click "Verify" → "Save"

This adds all TokenizedStrategy functions to the contract interface.

## CI/CD

This repo uses GitHub Actions for:
- **Lint**: Code formatting and style checks
- **Test**: Automated test execution
- **Slither**: Static analysis for security issues
- **Coverage**: Test coverage reporting

Add `ETH_RPC_URL` secret to enable test workflows. See [GitHub Actions docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets) for setup.

## Contributing

When implementing strategies:
1. Implement the required override functions
2. Add comprehensive tests
3. Test profit donation and loss protection mechanisms

For questions or support, please open an issue or reach out to the Octant team.