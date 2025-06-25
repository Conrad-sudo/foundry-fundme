# 💸 FundMe - Crowdfunding Smart Contract with Real-Time ETH/USD Conversion

## 🧾 Overview

**FundMe** is a decentralized crowdfunding smart contract written in Solidity. It uses **Chainlink's ETH/USD price feed** to ensure that each contribution meets a **minimum USD value**, regardless of ETH price fluctuations. This allows the campaign to maintain consistent contribution thresholds over time.

---

## 🧩 Cloning & Installing with Foundry

### ✅ Step Install Foundry (if not already installed)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

### ✅ Clone the Project

```bash
git clone https://github.com/Conrad-sudo/foundry-fundme
cd foundry-fundme
```

---

### ✅ Install Dependencies

Refer to the `Makefile` for dependencies

Run:

```bash
make install
```

If this project uses Chainlink and other external dependencies via Git submodules or GitHub packages, they'll be fetched now.

> ⚠️ If the `lib` directory or `foundry.toml` is missing, run `forge init` before this step, or check that it's included in the repo.

---

## 🚀 Features

- ✅ **Minimum USD Threshold**: Each contribution must meet a specified USD amount, converted from ETH in real time.
- 🔗 **Chainlink Integration**: Uses `AggregatorV3Interface` to fetch ETH/USD price data securely and reliably.
- 👥 **Funder Tracking**: Stores each funder’s contribution and maintains a list of funders.
- 🔐 **Owner-Only Withdrawals**: Only the contract owner can withdraw funds once the campaign ends.
- 🔁 **Reactivatable**: The contract can be reactivated to restart fundraising rounds.
- 💰 **Automatic Acceptance**: Accepts ETH directly via `receive()` and `fallback()` functions.

---

## 🧠 How It Works

### Deployment

```solidity
constructor(uint256 minimumUSD, address _priceFeed)
```

| Parameter    | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `minimumUSD` | Minimum USD amount required to fund (converted to 18 decimals) |
| `_priceFeed` | Chainlink ETH/USD price feed address for your network          |

📍 Example (Sepolia testnet):

```solidity
new FundMe(50, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
```

> This sets the minimum contribution to \$50 (in ETH equivalent at current market rate).

---

### Funding the Contract

```solidity
function fund() public payable
```

- Users call `fund()` or send ETH directly to the contract.
- Contribution is only accepted if `msg.value` converted to USD ≥ `MINIMUM_USD`.
- Contributions are tracked in `s_addressToFunds` and `s_funders`.

---

### Withdrawing Funds

```solidity
function withdraw() public isOwner returns (bool)
```

- Only the owner can call this function.
- Transfers the full contract balance to the owner.
- Clears all funder records and sets funding status to `inactive`.

---

### Reactivating the Contract

```solidity
function reactivateFunding() public isOwner
```

- Allows the owner to restart the campaign.
- Sets status from `inactive` to `active`.

---

## 📊 Chainlink Price Feed

- **Aggregator**: ETH/USD
- **Network**: Sepolia Testnet
- **Address**: `0x694AA1769357215DE4FAC081bf1f309aDC325306`

> You can replace the price feed address with one appropriate to your network. [See full list of Chainlink price feeds](https://docs.chain.link/data-feeds/price-feeds/addresses).

---

## 🔍 Read Functions

| Function                     | Returns                                         |
| ---------------------------- | ----------------------------------------------- |
| `getFunder(uint256 index)`   | Address of a funder by index                    |
| `getAddressToFunds(address)` | Total amount contributed by a funder            |
| `getFunderArrayLength()`     | Total number of funders                         |
| `getOwner()`                 | Address of the contract owner                   |
| `getStatus()`                | Current funding status (`active` or `inactive`) |

---

## 🧱 State Variables

- `owner`: Immutable owner set at deployment.
- `MINIMUM_USD`: Minimum USD contribution required (with 18 decimals).
- `s_funders`: List of all funder addresses.
- `s_addressToFunds`: Mapping of funders to their contributions.
- `status`: Enum indicating current fundraising state.
- `priceFeed`: Chainlink ETH/USD feed.

---

## 🧰 Dependencies

- `PriceConverter.sol` (local library)
- `AggregatorV3Interface` from Chainlink

Your `PriceConverter` library should implement a function like:

```solidity
function convertEthAmountToUSD(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256)
```

---

## ⚠️ Security Considerations

- ✅ Follows the [CEI pattern](https://fravoll.github.io/solidity-patterns/checks_effects_interactions.html) in withdrawal.
- ✅ Validates `msg.sender` in `isOwner` modifier.
- ⚠️ No reentrancy guard — recommended if you plan to extend.
- ⚠️ Make sure the `PriceConverter` cannot be manipulated (e.g. avoid using unreliable price feeds).

---

## 📄 License

MIT © 2025

---
