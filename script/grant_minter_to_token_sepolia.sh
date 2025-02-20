#!/bin/bash
set -e

[ -f .env ] && source .env || { echo ".env file not found"; exit 1; }
if [ -z "$INFURA_API_KEY" ]; then
  echo "Error: INFURA_API_KEY is not set in your .env file." >&2
  exit 1
fi

read -s -p "Enter PRIVATE_KEY: " PRIVATE_KEY
echo

export PRIVATE_KEY
export ALPHA_TOKEN
export ALPHA_MINTER

forge script script/GrantMinterRole.s.sol:GrantMinterRoleScript \
    --broadcast \
    --fork-url "https://sepolia.infura.io/v3/$INFURA_API_KEY" \
    --chain-id 11155111 \
    -vvv \
    --with-gas-price 10gwei

echo "GrantMinterRole invocation complete."
