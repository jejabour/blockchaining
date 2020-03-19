# Blocks are connected through hashing
# unique digital fingerprint - transaction + previous blocks hash

from Block import Block

blockchain = []

genesis_block = Block("Chancellor on the brink...", ["Satoshi send 1 BTC to Ivan",
                                                    "Maria sent 5 BTC to Jenny",
                                                    "Satoshi sent 5 BTC to Hal Finney"])

second_block = Block(genesis_block.block_hash, ["Ivan sent 5 BTC to Liz",
                                                "Jenny sent 5 BTC to Karen"])

third_block = Block(second_block.block_hash, ["Jerry sent 32 BTC to John",
                                                "jeff sent 7 BTC to Paul"])


print("Block hash: Genesis Block")
print(genesis_block.block_hash)

print("Block hash: Second Block")
print(second_block.block_hash)

print("Block hash: Third Block")
print(third_block.block_hash)

