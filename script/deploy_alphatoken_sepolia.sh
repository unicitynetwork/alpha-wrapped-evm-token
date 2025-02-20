#!/bin/bash
set -e

DEFAULT_ADMIN=0x91CaD8e9440328CCc73466A660FCBbA317071395
PAUSER=0x91CaD8e9440328CCc73466A660FCBbA317071395
UPGRADER=0x91CaD8e9440328CCc73466A660FCBbA317071395

[ -f .env ] && source .env || { echo ".env file not found"; exit 1; }
if [ -z "$INFURA_API_KEY" ]; then
  echo "Error: INFURA_API_KEY is not set in your .env file." >&2
  exit 1
fi

read -s -p "Enter PRIVATE_KEY: " PRIVATE_KEY
echo

export PRIVATE_KEY
export DEFAULT_ADMIN
export PAUSER
export UPGRADER

forge script script/AlphaToken.s.sol:AlphaTokenScript \
    --broadcast \
    --fork-url "https://sepolia.infura.io/v3/$INFURA_API_KEY" \
    --chain-id 11155111 \
    -vvv \
    --with-gas-price 10gwei 

echo "Deployment complete."
