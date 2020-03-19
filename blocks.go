package ledger

type Block struct {
	Hash     string
	Previous *Block
	Next     *Block
}

type Ledger struct {
	Genesis *Block
}
