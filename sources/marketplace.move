/* 
    # sui move 2024 marketplace module

    > NOTE: sui version >= 1.22.0 and the edition = " 2024.beta ".

    - This module is a marketplace where users can create shops and sell items. 
    - Every shop is a global shared object that is managed by the shop owner, which is designated by the ownership of the shop owner capability. 
    - The shop owner can add items to their shop, unlist items, and withdraw the profit from their shop. 
    - Users can purchase items from shops and will receive a purchased item receipt for each item purchased.

    ## Structs

    ### (1) Shops 
        - A Shop is a global shared object that is managed by the shop owner. 
        - The shop object holds items and the balance of SUI coins in the shop. 
    
    ### (2) Shop ownership:
        - Ownership of the Shop object is represented by holding the shop owner capability object.  
        - The shop owner has the ability to add items to the shop, unlist items, and withdraw from the shop. 

    ## Functions
    ### (1) create_shop: Create a shop
        Creates a new shop for the recipient and emits a ShopCreated event.


    ### (2) add_item: Adding items to a shop: 
        The shop owner can add items to their shop with the add_item function.

    ### (3) purchase_item: Purchasing an item
        Anyone has the ability to purchase an item that is listed. 
        When an item is purchased, the buyer will receive a separate purchased item receipt for each item purchased. 
        The purchased item receipt is a object that is owned by the buyer and is used to represent a purchased item.

    ### (4) unlist_item: Unlisting an item
        The shop owner can unlist an item from their shop with the unlist_item function. 
        When an item is unlisted, it will no longer be available for purchase.

    ### (5) withdraw_from_shop: Withdrawing from a shop: 
        The shop owner can withdraw SUI from their shop with the withdraw_from_shop function. The shop 
        owner can withdraw any amount from their shop that is equal to or below the total amount in 
        the shop. The amount withdrawn will be sent to the recipient address specified.    
*/
module movefans::sui_marketplace {
    //==============================================================================================
    // Dependencies
    //==============================================================================================
    use sui::event;
    use sui::sui::SUI;
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::{coin, balance::{Self, Balance}};

    //==============================================================================================
    // Error codes 
    //==============================================================================================
    // error code for not shop owner
    const ENotShopOwner: u64 = 1;
    // error code for invalid withdrawal amount
    const EInvalidWithdrawalAmount: u64 = 2;
    // error code for invalid quantity
    const EInvalidQuantity: u64 = 3;
    // error code for insufficient payment
    const EInsufficientPayment: u64 = 4;
    // error code for invalid item id
    const EInvalidItemId: u64 = 5;
    // error code for invalid price
    const EInvalidPrice: u64 = 6;
    // error code for invalid supply
    const EInvalidSupply: u64 = 7;
    // error code for item is not listed
    const EItemIsNotListed: u64 = 8;

    //==============================================================================================
    // Structs 
    //==============================================================================================

    /*
        The shop struct represents a shop in the marketplace. A shop is a global shared object that
        is managed by the shop owner. The shop owner is designated by the ownership of the shop
        owner capability. 
        @param id - The object id of the shop object.
        @param shop_owner_cap - The object id of the shop owner capability.
        @param balance - The balance of SUI coins in the shop.
        @param items - The items in the shop.
        @param item_count - The number of items in the shop. Including items that are not listed or 
            sold out.
    */
	public struct Shop has key {
		id: UID,
        shop_owner_cap: ID,
		balance: Balance<SUI>,
		items: vector<Item>,
        item_count: u64
	}

    /*
        The shop owner capability struct represents the ownership of a shop. The shop
        owner capability is a object that is owned by the shop owner and is used to manage the shop.
        @param id - The object id of the shop owner capability object.
        @param shop - The object id of the shop object.
    */
    public struct ShopOwnerCapability has key {
        id: UID,
        shop: ID,
    }

    /*
        The item struct represents an item in a shop. An item is a product that can be purchased
        from a shop.
        @param id - The id of the item object. This is the index of the item in the shop's items
            vector.
        @param title - The title of the item.
        @param description - The description of the item.
        @param price - The price of the item (price per each quantity).
        @param url - The url of item image.
        @param listed - Whether the item is listed. If the item is not listed, it will not be 
            available for purchase.
        @param category - The category of the item.
        @param total_supply - The total supply of the item.
        @param available - The available supply of the item. Will be less than or equal to the total
            supply and will start at the total supply and decrease as items are purchased.
    */
    public struct Item has store {
		id: u64,
		title: String,
		description: String,
		price: u64,
		url: Url,
        listed: bool,
        category: u8,
        total_supply: u64,
        available: u64
	}

    /*
        The purchased item struct represents a purchased item receipt. A purchased item receipt is
        a object that is owned by the buyer and is used to represent a purchased item.
        @param id - The object id of the purchased item object.
        @param shop_id - The object id of the shop object.
        @param item_id - The id of the item object.
    */
    public struct PurchasedItem has key {
        id: UID,
        shop_id: ID, 
        item_id: u64
    }

    //==============================================================================================
    // Event structs - DO NOT MODIFY
    //==============================================================================================

    /*
        Event to be emitted when a shop is created.
        @param shop_id - The id of the shop object.
        @param shop_owner_cap_id - The id of the shop owner capability object.
    */
    public struct ShopCreated has copy, drop {
        shop_id: ID,
        shop_owner_cap_id: ID,
    }

    /*
        Event to be emitted when an item is added to a shop.
        @param item - The id of the item object.
    */
    public struct ItemAdded has copy, drop {
        shop_id: ID,
        item: u64,
    }

    /*
        Event to be emitted when an item is purchased.
        @param item - The id of the item object.
        @param quantity - The quantity of the item purchased.
        @param buyer - The address of the buyer.
    */
    public struct ItemPurchased has copy, drop {
        shop_id: ID,
        item_id: u64, 
        quantity: u64,
        buyer: address,
    }

    /*
        Event to be emitted when an item is unlisted.
        @param item - The id of the item object.
    */
    public struct ItemUnlisted has copy, drop {
        shop_id: ID,
        item_id: u64
    }

    /*
        Event to be emitted when a shop owner withdraws from their shop.
        @param shop_id - The id of the shop object.
        @param amount - The amount withdrawn.
        @param recipient - The address of the recipient of the withdrawal.
    */
    public struct ShopWithdrawal has copy, drop {
        shop_id: ID,
        amount: u64,
        recipient: address
    }

    //==============================================================================================
    // Functions
    //==============================================================================================

	/*
        Creates a new shop for the recipient and emits a ShopCreated event.
        @param recipient - The address of the recipient of the shop.
        @param ctx - The transaction context.
	*/
	public fun create_shop(recipient: address, ctx: &mut TxContext) {
        let shop_uid = object::new(ctx); 
        let shop_owner_cap_uid = object::new(ctx); 

        let shop_id = object::uid_to_inner(&shop_uid);
        let shop_owner_cap_id = object::uid_to_inner(&shop_owner_cap_uid);

        transfer::transfer(ShopOwnerCapability {
            id: shop_owner_cap_uid,
            shop: shop_id
         }, recipient);

        transfer::share_object(Shop {
            id: shop_uid,
            shop_owner_cap: shop_owner_cap_id,
            balance: balance::zero<SUI>(),
            items: vector::empty(),
            item_count: 0,
        });

        event::emit(ShopCreated{
           shop_id, 
           shop_owner_cap_id
        })
	}

    /*
        Adds a new item to the shop and emits an ItemAdded event. Abort if the shop owner capability
        does not match the shop, if the price is not above 0, or if the supply is not above 0.
        @param shop - The shop to add the item to.
        @param shop_owner_cap - The shop owner capability of the shop.
        @param title - The title of the item.
        @param description - The description of the item.
        @param url - The url of the item.
        @param price - The price of the item.
        @param supply - The initial supply of the item.
        @param category - The category of the item.
        @param ctx - The transaction context.
    */
    public fun add_item(
        shop: &mut Shop,
        shop_owner_cap: &ShopOwnerCapability, 
        title: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        price: u64, 
        supply: u64, 
        category: u8
    ) {
        assert!(shop.shop_owner_cap== object::uid_to_inner(&shop_owner_cap.id), ENotShopOwner);
        assert!(price>0, EInvalidPrice);
        assert!(supply>0, EInvalidSupply);

        let item_id = shop.items.length();

        let item = Item{
            id: item_id,
            title: string::utf8(title),
            description:string::utf8(description),
            price: price,
            url: url::new_unsafe_from_bytes(url),
            listed: true,
            category: category,
            total_supply: supply,
            available: supply,
        };

        shop.items.push_back(item);
        shop.item_count = shop.item_count + 1;

        event::emit(ItemAdded{
            shop_id: shop_owner_cap.shop, 
            item: item_id
        });
    }

    /*
        Unlists an item from the shop and emits an ItemUnlisted event. Abort if the shop owner 
        capability does not match the shop or if the item id is invalid.
        @param shop - The shop to unlist the item from.
        @param shop_owner_cap - The shop owner capability of the shop.
        @param item_id - The id of the item to unlist.
    */
    public fun unlist_item(
        shop: &mut Shop,
        shop_owner_cap: &ShopOwnerCapability,
        item_id: u64
    ) {
        assert!(shop.shop_owner_cap== object::uid_to_inner(&shop_owner_cap.id), ENotShopOwner);
        assert!(item_id <= shop.items.length(), EInvalidItemId);
        assert!(item_id <= shop.items.length(), EInvalidItemId);

        shop.items[item_id].listed = false;

        event::emit(ItemUnlisted {
           shop_id: shop_owner_cap.shop,
           item_id: item_id
        })
    }

    /*
        Purchases an item from the shop and emits an ItemPurchased event. Abort if the item id is
        invalid, the payment coin is insufficient, if the item is unlisted, or the shop does not 
        have enough available supply. Emit an ItemUnlisted event if the last item(s) are purchased.
        @param shop - The shop to purchase the item from.
        @param item_id - The id of the item to purchase.
        @param quantity - The quantity of the item to purchase.
        @param recipient - The address of the recipient of the item.
        @param payment_coin - The payment coin for the item.
        @param ctx - The transaction context.
    */
    public fun purchase_item(
        shop: &mut Shop, 
        item_id: u64,
        quantity: u64,
        recipient: address,
        payment_coin: &mut coin::Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(item_id <= shop.items.length(), EInvalidItemId);
        
        let item = &mut shop.items[item_id];
        
        assert!(item.available >= quantity, EInvalidQuantity);

        let value = payment_coin.value();
        let total_price = item.price * quantity;
        assert!(value >= total_price, EInsufficientPayment);

        assert!(item.listed == true, EItemIsNotListed);

        item.available = item.available - quantity;

        let paid = payment_coin.split(total_price, ctx);

        coin::put(&mut shop.balance, paid);

        let mut i = 0_u64;

        while (i < quantity) {
            let purchased_item_uid = object::new(ctx);

            transfer::transfer(PurchasedItem {
                id: purchased_item_uid,
                shop_id: object::uid_to_inner(&shop.id),
                item_id: item_id }, recipient);

            i = i+1;
        };

        event::emit(ItemPurchased {
            shop_id: object::uid_to_inner(&shop.id),
            item_id: item_id,
            quantity: quantity,
            buyer: recipient,
        });

        if (item.available == 0 ) {
            event::emit(ItemUnlisted{
                shop_id: object::uid_to_inner(&shop.id),
                item_id: item_id,
            });

            vector::borrow_mut(&mut shop.items, item_id).listed = false;
        }
    }

    /*
        Withdraws SUI from the shop to the recipient and emits a ShopWithdrawal event. Abort if the 
        shop owner capability does not match the shop or if the amount is invalid.
        @param shop - The shop to withdraw from.
        @param shop_owner_cap - The shop owner capability of the shop.
        @param amount - The amount to withdraw.
        @param recipient - The address of the recipient of the withdrawal.
        @param ctx - The transaction context.
    */
    public fun withdraw_from_shop(
        shop: &mut Shop,
        shop_owner_cap: &ShopOwnerCapability,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        
        assert!(shop.shop_owner_cap== object::uid_to_inner(&shop_owner_cap.id), ENotShopOwner);
        
        assert!(amount > 0 && amount <= shop.balance.value(), EInvalidWithdrawalAmount);

        let take_coin = coin::take(&mut shop.balance, amount, ctx);
        
        transfer::public_transfer(take_coin, recipient);
        
        event::emit(ShopWithdrawal{
            shop_id: object::uid_to_inner(&shop.id),
            amount: amount,
            recipient: recipient
        });
    }

    // getters for the shop struct
    public fun get_shop_uid(shop: &Shop): &UID {
        &shop.id
    }

    public fun get_shop_owner_cap(shop: &Shop): ID {
        shop.shop_owner_cap
    }

    public fun get_shop_balance(shop: &Shop):  &Balance<SUI> {
        &shop.balance
    }

    public fun get_shop_items(shop: &Shop):  &vector<Item> {
        &shop.items
    }

    public fun get_shop_item_count(shop: &Shop): u64{
        shop.item_count
    }

    // getters for the shop owner capability struct
    public fun get_shop_owner_cap_uid(shop_owner_cap: &ShopOwnerCapability): &UID {
        &shop_owner_cap.id
    }

    public fun get_shop_owner_cap_shop(shop_owner_cap: &ShopOwnerCapability): ID {
        shop_owner_cap.shop
    }

    // getters for the item struct
    public fun get_item_id(item: &Item): u64 {
        item.id
    }

    public fun get_item_title(item: &Item): String {
        item.title
    }

    public fun get_item_description(item: &Item): String {
        item.description
    }

    public fun get_item_price(item: &Item): u64{
        item.price
    }

    public fun get_item_total_supply(item: &Item): u64{
        item.total_supply
    }

    public fun get_item_available(item: &Item): u64{
        item.available
    }

    public fun get_item_url(item: &Item): Url{
        item.url
    }

    public fun get_item_listed (item: &Item): bool {
        item.listed
    }

    public fun get_item_category(item: &Item): u8{
        item.category
    }

    // getters for the purchased item struct
    public fun get_purchased_item_shop_id(purchased_item: &PurchasedItem): ID {
        purchased_item.shop_id
    }

    public fun get_purchased_item_id(purchased_item: &PurchasedItem): u64 {    
        purchased_item.item_id
    }
}
