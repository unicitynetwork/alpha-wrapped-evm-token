#!/bin/bash
set -e

[ -f .env ] && source .env || { echo ".env file not found"; exit 1; }
if [ -z "$INFURA_API_KEY" ]; then
    echo "Error: INFURA_API_KEY is not set in your .env file." >&2
    exit 1
fi
if [ -z "$ALPHA_MINTER" ]; then
    echo "Error: ALPHA_MINTER contract address is not set in your .env file." >&2
    exit 1
fi

read -s -p "Enter PRIVATE_KEY: " PRIVATE_KEY
echo

read -p "Enter recipient address: " TO_ADDRESS
read -p "Enter amount to mint (in wei): " AMOUNT

echo "Minting tokens..."
cast send $ALPHA_MINTER \
    "mint(address,uint256)" \
    $TO_ADDRESS \
    $AMOUNT \
    --private-key $PRIVATE_KEY \
    --rpc-url "https://sepolia.infura.io/v3/$INFURA_API_KEY" \
    --chain-id 11155111 \
    --gas-price 10gwei

echo "Mint transaction complete."

MINTED_SO_FAR=$(cast call $ALPHA_MINTER \
    "getMintedSoFar(address)" \
    $TO_ADDRESS \
    --rpc-url "https://sepolia.infura.io/v3/$INFURA_API_KEY")

echo "Total minted for $TO_ADDRESS: $MINTED_SO_FAR"