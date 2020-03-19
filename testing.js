let newCoin = new Blockchain();

newCoin.createTransactions(new Transaction('address1', 'addres2', 100));
newCoin.createTransactions(new Transaction('address2', 'addres1', 50));

console.log('\nStarting the miner...')
newCoin.minePendingTransactions('xavier-address');

console.log('\nBalance of Xavier is ', newCoin.getBalanceOfAddress('xavier-address'));

console.log('\nStarting the miner...')
newCoin.minePendingTransactions('xavier-address');

console.log('\nBalance of Xavier is ', newCoin.getBalanceOfAddress('xavier-address'));

console.log('\nStarting the miner...')
newCoin.minePendingTransactions('xavier-address');

console.log('\nBalance of Xavier is ', newCoin.getBalanceOfAddress('xavier-address'));


// console.log("Mining block 1...")
// newCoin.addBlock(new Block(1, "10/07/2017", {amount: 4}));
// console.log("Mining block 2...")
// newCoin.addBlock(new Block(2, "12/07/2017", {amount: 10}));


// console.log("Is blockchain valid? " + newCoin.isChainValid());
// newCoin.chain[1].data = { amount: 100};
// console.log("Is blockchain valid? " + newCoin.isChainValid());
//console.log(JSON.stringify(newCoin, null, 4));
