#!/bin/bash
set -e

DEFAULT_ADMIN=0x91CaD8e9440328CCc73466A660FCBbA317071395
ORACLE=0xAe1875D0Ab8D2BD8e46c1Ce4844D9DbA03E3a966
MINTER=0x91CaD8e9440328CCc73466A660FCBbA317071395 # This MINTER value here is different from ALPHA_MINTER: ALPHA_MINTER references the AlphaMinter smart contract, whereas the MINTER here references the address that invokes the minting operaton on the AlphaMinter smart contract.

[ -f .env ] && source .env || { echo ".env file not found"; exit 1; }
if [ -z "$INFURA_API_KEY" ]; then
  echo "Error: INFURA_API_KEY is not set in your .env file." >&2
  exit 1
fi
if [ -z "$ALPHA_TOKEN" ]; then
  echo "Error: ALPHA_TOKEN is not set in your .env file." >&2
  exit 1
fi

read -s -p "Enter PRIVATE_KEY: " PRIVATE_KEY
echo

export PRIVATE_KEY
export ALPHA_TOKEN
export DEFAULT_ADMIN
export ORACLE
export MINTER

forge script script/AlphaMinter.s.sol:AlphaMinterScript \
    --broadcast \
    --fork-url "https://sepolia.infura.io/v3/$INFURA_API_KEY" \
    --chain-id 11155111 \
    -vvv \
    --with-gas-price 10gwei

echo "Deployment complete."
