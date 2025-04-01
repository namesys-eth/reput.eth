# Reput.eth (RPT) - Reputation Token

Reput.eth is an unique ERC20 token that implements a reputation-based system with inverse incentives.


## Key Features

- **Dual Reputation System**: Tracks both positive and negative reputation
- **Reputation Mechanism**: When tokens are transferred:
  - Sender gains positive reputation (plus += amount/3)
  - Receiver gets negative reputation (minus += amount)
- **Transfer Limit**: Maximum 100,000 tokens per transfer
- **Airdrop Function**: Allows distributing initial balance to multiple addresses
- **Standard ERC20 Interface**: Compatible with existing ERC20 infrastructure

## Technical Details

- **Token Name**: REPUT.ETH
- **Token Symbol**: RPT
- **Decimals**: 18
- **Initial Balance**: 1,000,000,000 RPT
- **Transfer Limit**: 100,000 RPT
- **Total Supply**: Maximum uint256 (2^256 - 1)

## Reputation Calculation

- **Initial Balance**: 1 billion tokens (initBal)
- **Effective Balance**: (initBal - minus[account]) + plus[account]
- **Net Reputation**: plus[account] - minus[account] (can be negative)

## How It Works

In the Reputeth system, the dynamics are reversed from traditional tokens:

1. **Sending is Beneficial**: When you send tokens, you gain positive reputation (1/3 of amount)
2. **Receiving is Harmful**: When you receive tokens, you gain negative reputation (full amount)
3. **Game Theory**: This creates an interesting dynamic where users want to send tokens to damage others' reputation while improving their own

This creates a new social dynamic for reputation management where sending tokens becomes a way to both improve your standing and potentially impact others negatively.

## Foundry

This project uses Foundry for development and testing:

- **Forge**: Ethereum testing framework
- **Cast**: Tool for interacting with EVM smart contracts
- **Anvil**: Local Ethereum node

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

```shell
$ forge script script/DeployReputeth.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```


## License

WTFPL.ETH
