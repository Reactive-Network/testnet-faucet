# Reactive Faucet App

## Overview

The Reactive Faucet App bridges Ethereum Sepolia and Reactive Testnet through a two-contract architecture. When a user sends Sepolia ETH to the faucet contract deployed on Sepolia, this contract communicates with its paired contract on the Reactive Network. Once the request is verified and processed, the user receives REACT tokens on the Reactive Testnet.

More on [Reactive Faucet →](https://dev.reactive.network/reactive-mainnet#get-testnet-react)

## Contracts

- **Sepolia Contract:** [ReactiveFaucetL1](https://github.com/Reactive-Network/testnet-faucet/blob/main/src/faucet/ReactiveFaucetL1.sol) handles Ether payment requests, defines a maximum payout per request, and emits `PaymentRequest` events containing details of the transaction.

- **Reactive Contract:** [ReactiveFaucet](https://github.com/Reactive-Network/testnet-faucet/blob/main/src/faucet/ReactiveFaucet.sol) operates on the Reactive Network. It subscribes to events on the Sepolia chain, processes callbacks, and distributes REACT to the appropriate receivers based on external `PaymentRequest` events.

## Deployment & Testing

Make sure the following environment variables are correctly configured before proceeding:

* `SEPOLIA_RPC` — RPC URL for Ethereum Sepolia, (see [Chainlist](https://chainlist.org/chain/11155111))
* `SEPOLIA_PRIVATE_KEY` — Ethereum Sepolia private key
* `REACTIVE_RPC` — RPC URL for Reactive Testnet (see [Reactive Docs](https://dev.reactive.network/reactive-mainnet#lasna-testnet))
* `REACTIVE_PRIVATE_KEY` — Reactive Testnet private key

### Step 1

Skip the first step and export the pre-deployed `REACTIVE_FAUCET_L1_ADDR` for Ethereum Sepolia:

```bash
export REACTIVE_FAUCET_L1_ADDR=0x9b9BB25f1A81078C544C829c5EB7822d747Cf434
```

Should you need to deploy the `ReactiveFaucetL1` contract to Ethereum Sepolia, do it as follows:

```bash
forge create --broadcast --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY src/faucet/ReactiveFaucetL1.sol:ReactiveFaucetL1 --constructor-args 1ether
```

Assign the `Deployed to` address from the response to `REACTIVE_FAUCET_L1_ADDR`.

### Step 2

Currently active reactive contract address:

```bash
export REACTIVE_FAUCET_ADDR=0xafE114cF8c95A45351f90C9deF22A8B4efC72Ff2
```

Deploy the `ReactiveFaucet` contract to the Reactive Network and assign the `Deployed to` address from the response to `REACTIVE_FAUCET_ADDR`.

```bash
forge create --broadcast --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY src/faucet/ReactiveFaucet.sol:ReactiveFaucet --value 10000ether --constructor-args $REACTIVE_FAUCET_L1_ADDR 50ether 50000
```

### Step 3

Test the faucet:

```bash
cast send $REACTIVE_FAUCET_L1_ADDR --rpc-url $SEPOLIA_RPC --private-key $SEPOLIA_PRIVATE_KEY --value 0.01ether
```

This should result in receiving 0.05 REACT.

### Optional Steps

To pause the reactive contract:

```bash
cast send $REACTIVE_FAUCET_ADDR "pause()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

To resume the reactive contract:

```bash
cast send $REACTIVE_FAUCET_ADDR "resume()" --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY
```

Provide additional funds to the reactive contract if needed:

```bash
cast send $REACTIVE_FAUCET_ADDR --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY --value 1000ether
```