# sui move 2024 marketplace module

> NOTE: sui version >= 1.22.0 and the edition = " 2024.beta ".

## Introduce

- This module is a marketplace where users can create shops and sell items. 
- Every shop is a global shared object that is managed by the shop owner, which is designated by the ownership of the shop owner capability. 
- The shop owner can add items to their shop, unlist items, and withdraw the profit from their shop. 
- Users can purchase items from shops and will receive a purchased item receipt for each item purchased.

## Structs

### 1. Shops 
- A Shop is a global shared object that is managed by the shop owner. 
- The shop object holds items and the balance of SUI coins in the shop. 

### 2. Shop ownership:
- Ownership of the Shop object is represented by holding the shop owner capability object.  
- The shop owner has the ability to add items to the shop, unlist items, and withdraw from the shop. 

## Functions
### 1. create_shop: Create a shop
- Creates a new shop for the recipient and emits a ShopCreated event.


### 2. add_item: Adding items to a shop: 
- The shop owner can add items to their shop with the add_item function.

### 3. purchase_item: Purchasing an item
- Anyone has the ability to purchase an item that is listed. 
- When an item is purchased, the buyer will receive a separate purchased item receipt for each item purchased. 
- The purchased item receipt is a object that is owned by the buyer and is used to represent a purchased item.

### 4. unlist_item: Unlisting an item
- The shop owner can unlist an item from their shop with the unlist_item function. 
- When an item is unlisted, it will no longer be available for purchase.

### 5. withdraw_from_shop: Withdrawing from a shop: 
- The shop owner can withdraw SUI from their shop with the withdraw_from_shop function. The shop 
- owner can withdraw any amount from their shop that is equal to or below the total amount in 
- the shop. The amount withdrawn will be sent to the recipient address specified.

## UNITTEST
```bash
$ sui --version
sui 1.22.0-0362997459

$ sui move test
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING sui_marketplace
Running Move unit tests
[ PASS    ] 0x0::sui_marketplace_tests::test_add_item
[ PASS    ] 0x0::sui_marketplace_tests::test_add_item_failure
[ PASS    ] 0x0::sui_marketplace_tests::test_create_shop
[ PASS    ] 0x0::sui_marketplace_tests::test_purchase_item
[ PASS    ] 0x0::sui_marketplace_tests::test_purchase_item_failure
[ PASS    ] 0x0::sui_marketplace_tests::test_unlist_item
[ PASS    ] 0x0::sui_marketplace_tests::test_withdraw_from_shop
Test result: OK. Total tests: 7; passed: 7; failed: 0
```

## Deployment

### 1. Create new address
> address alias: `movefans`
```bash
$ sui client new-address ed25519 movefans
╭────────────────────────────────────────────────────────────────────────────────────────────╮
│ Created new keypair and saved it to keystore.                                              │
├────────────────┬───────────────────────────────────────────────────────────────────────────┤
│ alias          │ movefans                                                                  │
│ address        │ 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8        │
│ keyScheme      │ ed25519                                                                   │
│ recoveryPhrase │ ......                                                                    │
╰────────────────┴───────────────────────────────────────────────────────────────────────────╯

export MOVE_FANS=0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8
```

### 2. switch to `movefans` address
```bash
$ sui client switch --address movefans
Active address switched to 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8
```

### 3. Get gas coins
```bash
$ sui client faucet
Request successful. It can take up to 1 minute to get the coin. Run sui client gas to check your gas coins.
```

### 4. Check gas coins
```bash
$ sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x5bec36e98e598b5be489e870d3335b8f0efec36cd6271ddd3b9f9ca459976ecf │ 1000000000         │ 1.00             │
│ 0xdd5f330e4ed105c19e9813917dafe8a9fbb7644b1255a1849e89fa42cdc97b46 │ 1000000000         │ 1.00             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

### 5. Publish 
```bash
$ sui client publish --gas-budget 100000000

...
│ Published Objects:                                                                               │
│  ┌──                                                                                             │
│  │ PackageID: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20                 │
│  │ Version: 1                                                                                    │
│  │ Digest: 7Rz8LTZszQdH6bMFPAjXugfUPDtsBEyDF6928CPab28H                                          │
│  │ Modules: sui_marketplace                                                                      │
│  └──                                                                                             │
...

export PACKAGE_ID=0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20
```

### 6. Create a new shop
```bash
$ sui client call --function create_shop --package $PACKAGE_ID --module sui_marketplace --args $MOVE_FANS --gas-budget 10000000

...
│ Created Objects:                                                                                                         │
│  ┌──                                                                                                                     │
│  │ ObjectID: 0x8859cf9f1113382d39e26885708faa5d405b39409fbeed3d24b1812408c327d5                                          │
│  │ Sender: 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8                                            │
│  │ Owner: Account Address ( 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8 )                         │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::ShopOwnerCapability  │
│  │ Version: 775513                                                                                                       │
│  │ Digest: HzezJXVzCxQ7i2TUY7LPdHbpQ2x1AuYMkHUxdTtR9Njn                                                                  │
│  └──                                                                                                                     │
│  ┌──                                                                                                                     │
│  │ ObjectID: 0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008                                          │
│  │ Sender: 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8                                            │
│  │ Owner: Shared                                                                                                         │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::Shop                 │
│  │ Version: 775513                                                                                                       │
│  │ Digest: DWLBgkRXSfPssSPR5Q83NvPe7o45fQqFQbTNE7UwckDX                                                                  │
│  └──                                                                                                                     │
...

export SHOP_ID=0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008
export SHOP_OWNER_CAP=0x8859cf9f1113382d39e26885708faa5d405b39409fbeed3d24b1812408c327d5
```

### 7. Add item

- **Add item1**

```bash
export TITLE=title001
export DESCRIPTION=desc001
export URL=url001
export PRICE=18
export SUPPLY=100
export CATEGORY=1

$ sui client call --function add_item --package $PACKAGE_ID --module sui_marketplace --args $SHOP_ID $SHOP_OWNER_CAP $TITLE $DESCRIPTION $URL $PRICE $SUPPLY $CATEGORY --gas-budget 10000000

╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                     │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                         │
│  │ EventID: CGrHhWMbAS1BdinJwqBRTKL6AtwQUfdqGUSs8zseBCt5:0                                                   │
│  │ PackageID: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20                             │
│  │ Transaction Module: sui_marketplace                                                                       │
│  │ Sender: 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8                                │
│  │ EventType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::ItemAdded │
│  │ ParsedJSON:                                                                                               │
│  │   ┌─────────┬────────────────────────────────────────────────────────────────────┐                        │
│  │   │ item    │ 0                                                                  │                        │
│  │   ├─────────┼────────────────────────────────────────────────────────────────────┤                        │
│  │   │ shop_id │ 0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008 │                        │
│  │   └─────────┴────────────────────────────────────────────────────────────────────┘                        │
│  └──                                                                                                         │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```


- **Add item2**

```bash
export TITLE=title002
export DESCRIPTION=desc002
export URL=url002
export PRICE=28
export SUPPLY=200
export CATEGORY=2

$ sui client call --function add_item --package $PACKAGE_ID --module sui_marketplace --args $SHOP_ID $SHOP_OWNER_CAP $TITLE $DESCRIPTION $URL $PRICE $SUPPLY $CATEGORY --gas-budget 10000000

╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                     │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                         │
│  │ EventID: 54e8C4ytnmBKGDyRcX6i6k7aDDPp19GiLg3391CTzhpA:0                                                   │
│  │ PackageID: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20                             │
│  │ Transaction Module: sui_marketplace                                                                       │
│  │ Sender: 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8                                │
│  │ EventType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::ItemAdded │
│  │ ParsedJSON:                                                                                               │
│  │   ┌─────────┬────────────────────────────────────────────────────────────────────┐                        │
│  │   │ item    │ 1                                                                  │                        │
│  │   ├─────────┼────────────────────────────────────────────────────────────────────┤                        │
│  │   │ shop_id │ 0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008 │                        │
│  │   └─────────┴────────────────────────────────────────────────────────────────────┘                        │
│  └──                                                                                                         │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 8. Purchase item

> create `customer` to purchase item
>
> ```bash
> $ sui client new-address ed25519 customer
> $ sui client switch --address customer
> Active address switched to 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615
> $ sui client faucet
> Request successful. It can take up to 1 minute to get the coin. Run sui client gas to check your gas coins.
> ```


```bash
$ export CUSTOMER=0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615

$ export ITEM_ID=0
$ export QUANTITY=5
$ export COIN=0x5bbddfdaced03a379910f43fa5f2f12a8f31238367bdd288f51c409c25a2ae21

$ sui client call --function purchase_item --package $PACKAGE_ID --module sui_marketplace --args $SHOP_ID $ITEM_ID $QUANTITY $CUSTOMER $COIN --gas-budget 100000000

╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                         │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                             │
│  │ EventID: 8fo4RdcAmJ1kwSunoNtAFkvSUY5LQeeE7Bs39odVSSFX:0                                                       │
│  │ PackageID: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20                                 │
│  │ Transaction Module: sui_marketplace                                                                           │
│  │ Sender: 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615                                    │
│  │ EventType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::ItemPurchased │
│  │ ParsedJSON:                                                                                                   │
│  │   ┌──────────┬────────────────────────────────────────────────────────────────────┐                           │
│  │   │ buyer    │ 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615 │                           │
│  │   ├──────────┼────────────────────────────────────────────────────────────────────┤                           │
│  │   │ item_id  │ 0                                                                  │                           │
│  │   ├──────────┼────────────────────────────────────────────────────────────────────┤                           │
│  │   │ quantity │ 5                                                                  │                           │
│  │   ├──────────┼────────────────────────────────────────────────────────────────────┤                           │
│  │   │ shop_id  │ 0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008 │                           │
│  │   └──────────┴────────────────────────────────────────────────────────────────────┘                           │
│  └──                                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

- **Consumer got 5 items**

```bash
│ Created Objects:                                                                                                   │
│  ┌──                                                                                                               │
│  │ ObjectID: 0x153148acf66c23e361ca633fa5c98c5b84c174204246a2f17487fc503536816e                                    │
│  │ Sender: 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615                                      │
│  │ Owner: Account Address ( 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615 )                   │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::PurchasedItem  │
│  │ Version: 918397                                                                                                 │
│  │ Digest: 6vSQ4ojfJgu4EJNWWF7nzC67wmjiUAZBLVQPaveNxr44                                                            │
│  └──                                                                                                               │
│  ┌──                                                                                                               │
│  │ ObjectID: 0x80dc7e6249127c94220774b7ac884d30ee09fb566ea7d123991e5cc87edd1850                                    │
│  │ Sender: 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615                                      │
│  │ Owner: Account Address ( 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615 )                   │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::PurchasedItem  │
│  │ Version: 918397                                                                                                 │
│  │ Digest: 3XPbA7PJ4JRdsroJmK4za7kEahQup88rMyK9LMANiZuU                                                            │
│  └──                                                                                                               │
│  ┌──                                                                                                               │
│  │ ObjectID: 0xadd032c772a18303d56a23d5d79b9276da12a807b0d9a9aa50de38824e165d22                                    │
│  │ Sender: 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615                                      │
│  │ Owner: Account Address ( 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615 )                   │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::PurchasedItem  │
│  │ Version: 918397                                                                                                 │
│  │ Digest: E2BZHBpS7aJKzz8x2UQTvHnFyBH4ge93E1nkEPqRGFra                                                            │
│  └──                                                                                                               │
│  ┌──                                                                                                               │
│  │ ObjectID: 0xc56fcaaf2f34056dada9474e7394da0cab4edf1b11e9dd263ce91bc85c36e468                                    │
│  │ Sender: 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615                                      │
│  │ Owner: Account Address ( 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615 )                   │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::PurchasedItem  │
│  │ Version: 918397                                                                                                 │
│  │ Digest: 8nct8F1WwvCWRCCyFsJMP1Xccw2T1FgWeC3YYZx7eVvL                                                            │
│  └──                                                                                                               │
│  ┌──                                                                                                               │
│  │ ObjectID: 0xd7e1afe754e64a694ce6f9312fbf21cf680dc793f7d3106cb3eef4c7e0a9fbc5                                    │
│  │ Sender: 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615                                      │
│  │ Owner: Account Address ( 0x41b88e5d5113940fd6518affe993ceb3379fcbca08b02cd3c0bac82596abf615 )                   │
│  │ ObjectType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::PurchasedItem  │
│  │ Version: 918397                                                                                                 │
│  │ Digest: CJYRUstu3ErddDYwy1H7ed2cPEaCdrAd8v1951peT5Fz                                                            │
│  └──                                                                                                               │
```

### 9. Unlist item

> switch to `MoveFans` address

```bash
export ITEM_ID=1

$ sui client call --function unlist_item --package $PACKAGE_ID --module sui_marketplace --args $SHOP_ID $SHOP_OWNER_CAP $ITEM_ID --gas-budget 500000000

╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                        │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                            │
│  │ EventID: GLeQT7dcZtLRvrF5m9uVQgKiUYH7Wy4cGFFnbY6PmV9h:0                                                      │
│  │ PackageID: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20                                │
│  │ Transaction Module: sui_marketplace                                                                          │
│  │ Sender: 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8                                   │
│  │ EventType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::ItemUnlisted │
│  │ ParsedJSON:                                                                                                  │
│  │   ┌─────────┬────────────────────────────────────────────────────────────────────┐                           │
│  │   │ item_id │ 1                                                                  │                           │
│  │   ├─────────┼────────────────────────────────────────────────────────────────────┤                           │
│  │   │ shop_id │ 0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008 │                           │
│  │   └─────────┴────────────────────────────────────────────────────────────────────┘                           │
│  └──                                                                                                            │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 10. Withdraw from shop

```bash
export AMOUNT=10

sui client call --function withdraw_from_shop --package $PACKAGE_ID --module sui_marketplace --args $SHOP_ID $SHOP_OWNER_CAP $AMOUNT $MOVE_FANS --gas-budget 100000000

╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                          │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                              │
│  │ EventID: 3PRCWLY5cQy3dCK574S3npBsK6JmmnvL3Jca9VxHJQZL:0                                                        │
│  │ PackageID: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20                                  │
│  │ Transaction Module: sui_marketplace                                                                            │
│  │ Sender: 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8                                     │
│  │ EventType: 0x41824b65c050e1809cb2319d66cdeab49689ec7860dc87e3554cc38de538aa20::sui_marketplace::ShopWithdrawal │
│  │ ParsedJSON:                                                                                                    │
│  │   ┌───────────┬────────────────────────────────────────────────────────────────────┐                           │
│  │   │ amount    │ 10                                                                 │                           │
│  │   ├───────────┼────────────────────────────────────────────────────────────────────┤                           │
│  │   │ recipient │ 0x77083d27beec05358aff1356c1826fc582ae381440c028646b817705aabca3a8 │                           │
│  │   ├───────────┼────────────────────────────────────────────────────────────────────┤                           │
│  │   │ shop_id   │ 0xa5392a400fc3a7db5204310bccd734b55eda0ca88c6d51e88eb65cd215372008 │                           │
│  │   └───────────┴────────────────────────────────────────────────────────────────────┘                           │
│  └──                                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```