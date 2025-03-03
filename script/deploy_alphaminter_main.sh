#!/bin/bash
set -e

DEFAULT_ADMIN=0x7aD974BB753058715eE277516d2E14c4cFdbd4C6
ORACLE=0x3d84F1b998d6CaD13A7249396F1121AA19C5AA37
MINTER=0x43B70167D43CA3d9786B2FBA5Cc1bCB18eFC17d9 # This MINTER value here is different from ALPHA_MINTER: ALPHA_MINTER references the AlphaMinter smart contract, whereas the MINTER here references the address that invokes the minting operaton on the AlphaMinter smart contract.

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
    --fork-url "https://mainnet.infura.io/v3/$INFURA_API_KEY" \
    --chain-id 1 \
    -vvv \
    --with-gas-price 10gwei \
    --verify --retries 60

echo "Deployment complete."
