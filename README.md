# Wrapped ERC20 Token for the Alpha Token

This repository provides an ERC20 token implementation (the **AlphaToken**) and a dedicated minter contract (the **AlphaMinter**), both developed with Foundry and OpenZeppelin.

## Running Unit Tests

Use the Foundry CLI to run the unit tests:

```shell
forge test
```

## Deployment and interaction

Deployment and interaction scripts have been added to the `script` folder. Before they can be used, an `.env` file needs to be created in the project root folder. The `.env.sample` file contains an example of how that file can look like.