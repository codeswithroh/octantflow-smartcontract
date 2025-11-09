# Octant Yield‑Donating Strategy (Aave v3 USDC) — Sepolia

Minimal yield‑donating strategy: deposits USDC into Aave v3, and on report() mints all profit as new shares to a donation address (public goods). Optional loss protection can burn donation shares first.

## Setup (short)
- Prereqs: Foundry, a Sepolia RPC, a funded EOA.
- .env (example):
```env
ETH_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
ASSET=0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
AAVE_POOL=0x6Ae43d3271fF6888e7Fc43Fd7321a503fF738951
STRATEGY_NAME="USDC AaveV3 YieldDonating (Sepolia)"
MANAGEMENT=0xYourEOA
KEEPER=0xYourEOA
EMERGENCY_ADMIN=0xYourEOA
DONATION_ADDRESS=0xYourEOA
ENABLE_BURNING=true
PRIVATE_KEY=your_private_key
```
- Deploy:
```sh
forge script script/DeployAaveStrategy.s.sol:DeployAaveStrategy \
  --rpc-url $ETH_RPC_URL --broadcast --private-key $PRIVATE_KEY
```

## Deployment Addresses (Sepolia)
- Strategy: 0x23674a694Af9A162719122494e389F7Fb37e4E38
- Tokenized Implementation: 0xD1C169580A912C66278c3cFB1C70d1B83C86A42b
- Aave v3 Pool: 0x6Ae43d3271fF6888e7Fc43Fd7321a503fF738951
- USDC: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238

## Testing (short)
```sh
forge test
```

## Tracks Applied
- Best use of a Yield‑Donating Strategy
- Best use of Aave v3
- Public Goods & Social Impact
- Best Code Quality (optional)

## Public Goods & Social Impact
- What kinds of public goods? Open‑ended: Web3 causes (Protocol Guild, open‑source, defense funds), traditional charities (Wikipedia, disaster relief, environment), or your creative ideas.
- How do donations work? The strategy’s profit is realized on report() and automatically minted as shares to the configured donation address via the YieldDonatingTokenizedStrategy. Donated yields are then directed to public goods causes.

---


