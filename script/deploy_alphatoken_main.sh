#!/bin/bash
set -e

DEFAULT_ADMIN=0x7aD974BB753058715eE277516d2E14c4cFdbd4C6
PAUSER=0xe441690c351b4d0F9A4Cac1B7F61ce84ff43fb1b
UPGRADER=0xD90CCeB7Ce568E72182cE6497FCa03a14AAb9b6A

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
    --fork-url "https://mainnet.infura.io/v3/$INFURA_API_KEY" \
    --chain-id 1 \
    -vvv \
    --with-gas-price 10gwei \
    --verify --retries 60

echo "Deployment complete."
