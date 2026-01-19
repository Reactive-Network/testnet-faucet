# Reactive Faucet App

## Overview

Reactive Faucet App bridges Ethereum/Base Sepolia with Reactive Testnet through a two-contract architecture. When a user sends testing ETH to one of the faucet contracts deployed on Ethereum/Base Sepolia, they interact with their paired Reactive contracts. Once the request is verified and processed, the user receives lReact tokens on Reactive Testnet.

More on [Reactive Faucet →](https://dev.reactive.network/reactive-mainnet#get-testnet-react)

## Contracts

- **Ethereum/Base Sepolia Contract:** [ReactiveFaucetL1](https://github.com/Reactive-Network/testnet-faucet/blob/main/src/faucet/ReactiveFaucetL1.sol) handles Ether payment requests, defines a maximum payout per request, and emits `PaymentRequest` events containing details of the transaction.

- **Reactive Contract:** [ReactiveFaucet](https://github.com/Reactive-Network/testnet-faucet/blob/main/src/faucet/ReactiveFaucet.sol) operates on Reactive Network. Subscribes to events on Ethereum/Base Sepolia, processes callbacks, and distributes lReact to the appropriate receivers based on external `PaymentRequest` events.

## Deployment & Testing

Make sure the following environment variables are correctly configured before proceeding:

* `CHAIN_ID` — `11155111` for Ethereum Sepolia and `84532` for Base Sepolia
* `SEPOLIA_RPC` — RPC URL for Ethereum Sepolia, (see [Ethereum Sepolia](https://chainlist.org/chain/11155111))
* `SEPOLIA_PRIVATE_KEY` — Ethereum Sepolia private key
* `BASE_RPC` — RPC URL for Base Sepolia, (see [Base Sepolia](https://chainlist.org/chain/84532))
* `BASE_PRIVATE_KEY` — Base Sepolia private key
* `REACTIVE_RPC` — RPC URL for Reactive Testnet (see [Reactive Docs](https://dev.reactive.network/reactive-mainnet#lasna-testnet))
* `REACTIVE_PRIVATE_KEY` — Reactive Testnet private key

### Step 1

Skip the first step and export the pre-deployed `SEPOLIA_FAUCET_L1_ADDR` for Ethereum Sepolia or `BASE_FAUCET_L1_ADDR` Base Sepolia:

```bash
export SEPOLIA_FAUCET_L1_ADDR=0x9b9BB25f1A81078C544C829c5EB7822d747Cf434
export BASE_FAUCET_L1_ADDR=0x2afaFD298b23b62760711756088F75B7409f5967
```

#### Ethereum Sepolia

To deploy the `ReactiveFaucetL1` contract to Ethereum Sepolia:

```bash
forge create --broadcast --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/faucet/ReactiveFaucetL1.sol:ReactiveFaucetL1 --constructor-args 1ether
```

Assign the `Deployed to` address from the response to `SEPOLIA_FAUCET_L1_ADDR`.

#### Base Sepolia

To deploy the `ReactiveFaucetL1` contract to Base Sepolia:

```bash
forge create --broadcast --rpc-url $BASE_RPC --private-key $BASE_PRIVATE_KEY src/faucet/ReactiveFaucetL1.sol:ReactiveFaucetL1 --constructor-args 1ether
```

Assign the `Deployed to` address from the response to `BASE_FAUCET_L1_ADDR`.

### Step 2

Active Reactive contract addresses:

```bash
export REACTIVE_SEPOLIA_ADDR=0x43CaD7A98C05Bd105A337B2EDEF9d4BeBcdFEFaE
export REACTIVE_BASE_ADDR=0x08e63f0780C85b9FA97C3AA7A07FbA88168cF443
```

Deploy the Reactive contract for Ethereum Sepolia and assign the `Deployed to` address from the response to `REACTIVE_SEPOLIA_ADDR`.

```bash
forge create --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucet.sol:ReactiveFaucet --value 100000ether --constructor-args 11155111 $SEPOLIA_FAUCET_L1_ADDR 500ether 1000000
```

#### Base Sepolia

Deploy the Reactive contract for Base Sepolia and assign the `Deployed to` address from the response to `REACTIVE_BASE_ADDR`.

```bash
forge create --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucet.sol:ReactiveFaucet --value 100000ether --constructor-args 84532 $BASE_FAUCET_L1_ADDR 500ether 1000000
```

### Step 3

#### Ethereum Sepolia

Test the faucet on Ethereum Sepolia:

```bash
cast send $SEPOLIA_FAUCET_L1_ADDR --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.1ether
```

This should result in receiving 10 lReact.

#### Base Sepolia

Test the faucet on Base Sepolia:

```bash
cast send $BASE_FAUCET_L1_ADDR --rpc-url $BASE_RPC --private-key $BASE_PRIVATE_KEY --value 0.1ether
```

This should result in receiving 10 lReact.

### Optional Steps

#### Ethereum Sepolia

To pause the Reactive contract:

```bash
cast send $REACTIVE_SEPOLIA_ADDR "pause()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

To resume the Reactive contract:

```bash
cast send $REACTIVE_SEPOLIA_ADDR "resume()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

Provide additional funds to the Reactive contract if needed:

```bash
cast send $REACTIVE_SEPOLIA_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 10000ether
```

#### Base Sepolia

To pause the Reactive contract:

```bash
cast send $REACTIVE_BASE_ADDR "pause()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

To resume the Reactive contract:

```bash
cast send $REACTIVE_BASE_ADDR "resume()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

Provide additional funds to the Reactive contract if needed:

```bash
cast send $REACTIVE_BASE_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 10000ether
```