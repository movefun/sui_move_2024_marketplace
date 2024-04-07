module movefans::sui_marketplace_tests {
    //==============================================================================================
    // Dependencies
    //==============================================================================================
    use sui::{coin, balance};
    use sui::sui::SUI;
    use sui::url;
    use std::string;

    use movefans::sui_marketplace::{Shop, ShopOwnerCapability, PurchasedItem};
    use movefans::sui_marketplace::{ENotShopOwner, EItemIsNotListed};
    use movefans::sui_marketplace::{withdraw_from_shop, purchase_item, add_item, create_shop};
    use movefans::sui_marketplace::{get_shop_uid, get_shop_balance, get_shop_items, unlist_item};
    use movefans::sui_marketplace::{get_purchased_item_id, get_shop_owner_cap_shop};
    use movefans::sui_marketplace::{get_item_id, get_item_title, get_item_description, get_item_price, 
        get_item_total_supply, get_item_available, get_item_url, get_item_listed, get_item_category};

    #[test_only]
    use sui::test_scenario;
    #[test_only]
    use sui::test_utils::assert_eq;

    #[test]
    public fun test_create_shop() {
        let shop_owner = @0xa;

        let mut scenario_val = test_scenario::begin(shop_owner);
        let scenario = &mut scenario_val;

        {
            create_shop(shop_owner, test_scenario::ctx(scenario));
        };
        let tx = test_scenario::next_tx(scenario, shop_owner);
        let expected_events_emitted = 1;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );

        {
            let shop_owner_cap = test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let shop = test_scenario::take_shared<Shop>(scenario);

            assert_eq(get_shop_owner_cap_shop(&shop_owner_cap), sui::object::uid_to_inner(get_shop_uid(&shop)));
            
            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        let tx = test_scenario::end(scenario_val);
        let expected_events_emitted = 0;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );
    }

    #[test]
    public fun test_add_item() {
        let shop_owner = @0xa;

        let mut scenario_val = test_scenario::begin(shop_owner);
        let scenario = &mut scenario_val;

        {
            create_shop(shop_owner, test_scenario::ctx(scenario));
        };

        {
            let expected_title = b"title";
            let expected_description = b"description";
            let expected_url = b"url";
            let expected_price = 1000000000; // 1 SUI
            let expected_category = 3;
            let expected_supply = 34;
            test_scenario::next_tx(scenario, shop_owner);
            {
                let shop_owner_cap  = 
                    test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
                let mut shop = test_scenario::take_shared<Shop>(scenario);

                add_item(
                    &mut shop, 
                    &shop_owner_cap,
                    expected_title, 
                    expected_description, 
                    expected_url, 
                    expected_price, 
                    expected_supply, 
                    expected_category
                );

                test_scenario::return_to_sender(scenario, shop_owner_cap);
                test_scenario::return_shared(shop);
            };

            test_scenario::next_tx(scenario, shop_owner);
            {

                let expected_item_length = 1;

                let shop = test_scenario::take_shared<Shop>(scenario);

                assert_eq(vector::length(get_shop_items(&shop)), expected_item_length);

                let item_id = 0;
                let item_ref = vector::borrow(get_shop_items(&shop), item_id);

                assert_eq(get_item_id(item_ref), item_id);
                assert_eq(get_item_title(item_ref), string::utf8(expected_title));
                assert_eq(get_item_description(item_ref), string::utf8(expected_description));
                assert_eq(get_item_url(item_ref), url::new_unsafe_from_bytes(expected_url));
                assert_eq(get_item_price(item_ref), expected_price);
                assert_eq(get_item_category(item_ref), expected_category);
                assert_eq(get_item_total_supply(item_ref), expected_supply);
                assert_eq(get_item_available(item_ref), expected_supply);
                assert_eq(get_item_listed(item_ref), true);

                test_scenario::return_shared(shop);
            };
        };

        {
            let expected_title = b"rzx";
            let expected_description = b"desc...";
            let expected_url = b"url...";
            let expected_price = 45000000000; // 45 SUI
            let expected_category = 2;
            let expected_supply = 1;
            test_scenario::next_tx(scenario, shop_owner);
            {
                let shop_owner_cap  = 
                    test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
                let mut shop = test_scenario::take_shared<Shop>(scenario);

                add_item(
                    &mut shop, 
                    &shop_owner_cap,
                    expected_title, 
                    expected_description, 
                    expected_url, 
                    expected_price, 
                    expected_supply, 
                    expected_category
                );

                test_scenario::return_to_sender(scenario, shop_owner_cap);
                test_scenario::return_shared(shop);
            };

            test_scenario::next_tx(scenario, shop_owner);
            {
                let expected_item_length = 2;
                let shop = test_scenario::take_shared<Shop>(scenario);

                assert_eq(vector::length(get_shop_items(&shop)), expected_item_length);

                let item_id = 1;
                let item_ref = vector::borrow(get_shop_items(&shop), item_id);

                assert_eq(get_item_id(item_ref), item_id);
                assert_eq(get_item_title(item_ref), string::utf8(expected_title));
                assert_eq(get_item_description(item_ref), string::utf8(expected_description));
                assert_eq(get_item_url(item_ref), url::new_unsafe_from_bytes(expected_url));
                assert_eq(get_item_price(item_ref), expected_price);
                assert_eq(get_item_category(item_ref), expected_category);
                assert_eq(get_item_total_supply(item_ref), expected_supply);
                assert_eq(get_item_available(item_ref), expected_supply);
                assert_eq(get_item_listed(item_ref), true);

                test_scenario::return_shared(shop);
            };
        };

        {
            let expected_title = b"shoes";
            let expected_description = b"just do it";
            let expected_url = b"photo.com";
            let expected_price = 200000000; // .2 SUI
            let expected_category = 1;
            let expected_supply = 2;
            test_scenario::next_tx(scenario, shop_owner);
            {
                let shop_owner_cap  = 
                    test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
                let mut shop = test_scenario::take_shared<Shop>(scenario);

                add_item(
                    &mut shop, 
                    &shop_owner_cap,
                    expected_title, 
                    expected_description, 
                    expected_url, 
                    expected_price, 
                    expected_supply, 
                    expected_category
                );

                test_scenario::return_to_sender(scenario, shop_owner_cap);
                test_scenario::return_shared(shop);
            };

            test_scenario::next_tx(scenario, shop_owner);
            {

                let expected_item_length = 3;

                let shop = test_scenario::take_shared<Shop>(scenario);

                assert_eq(vector::length(get_shop_items(&shop)), expected_item_length);

                let item_id = 2;
                let item_ref = vector::borrow(get_shop_items(&shop), item_id);

                assert_eq(get_item_id(item_ref), item_id);
                assert_eq(get_item_title(item_ref), string::utf8(expected_title));
                assert_eq(get_item_description(item_ref), string::utf8(expected_description));
                assert_eq(get_item_url(item_ref), url::new_unsafe_from_bytes(expected_url));
                assert_eq(get_item_price(item_ref), expected_price);
                assert_eq(get_item_category(item_ref), expected_category);
                assert_eq(get_item_total_supply(item_ref), expected_supply);
                assert_eq(get_item_available(item_ref), expected_supply);
                assert_eq(get_item_listed(item_ref), true);

                test_scenario::return_shared(shop);
            };
        };

        test_scenario::end(scenario_val);
    }

    #[test, expected_failure(abort_code = ENotShopOwner)]
    public fun test_add_item_failure() {
        let user1 = @0xa;
        let user2 = @0xb;

        let mut scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;

        {
            create_shop(user2, test_scenario::ctx(scenario));
            create_shop(user1, test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, user2);

        {
            let shop_owner_cap_of_user_2  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop_of_user_1 = test_scenario::take_shared<Shop>(scenario);
            
            add_item(
                &mut shop_of_user_1, 
                &shop_owner_cap_of_user_2,
                b"title", 
                b"description", 
                b"url", 
                1000000000, // 1 SUI
                34, 
                3
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap_of_user_2);
            test_scenario::return_shared(shop_of_user_1);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_purchase_item() {
        let shop_owner = @0xa;
        let buyer = @0xb;

        let mut scenario_val = test_scenario::begin(shop_owner);
        let scenario = &mut scenario_val;

        {
            create_shop(shop_owner, test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);

            add_item(
                &mut shop, 
                &shop_owner_cap,
                b"title", 
                b"description", 
                b"url", 
                1000000000, // 1 SUI
                34, 
                3
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        let tx = test_scenario::next_tx(scenario, buyer);
        let expected_events_emitted = 1;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );

        {
            let mut shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            let price = get_item_price(item_ref);
            let quantity_to_buy = 1;

            let mut payment_coin = sui::coin::mint_for_testing<SUI>(
                price * quantity_to_buy, 
                test_scenario::ctx(scenario)
            );


            purchase_item(
                &mut shop, 
                get_item_id(item_ref), 
                quantity_to_buy, 
                buyer, 
                &mut payment_coin, 
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(shop);

            coin::destroy_zero(payment_coin);
        };
        let tx = test_scenario::next_tx(scenario, buyer);
        let expected_events_emitted = 1;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );

        {
            let shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            let expected_total_supply = 34;
            let expected_quantity_purchased = 1;

            assert_eq(get_item_available(item_ref), expected_total_supply - expected_quantity_purchased);
            assert_eq(balance::value(get_shop_balance(&shop)), get_item_price(item_ref));
            assert_eq(get_item_listed(item_ref), true);

            let purchased_item = test_scenario::take_from_sender<PurchasedItem>(scenario);
            assert_eq(get_purchased_item_id(&purchased_item), get_item_id(item_ref));

            assert_eq(
                vector::length(&test_scenario::ids_for_sender<PurchasedItem>(scenario)), 
                1
            );

            test_scenario::return_shared(shop);
            test_scenario::return_to_sender(scenario, purchased_item);
        };
        let tx = test_scenario::end(scenario_val);
        let expected_events_emitted = 0;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );
    }

    #[test, expected_failure(abort_code = EItemIsNotListed)]
    public fun test_purchase_item_failure() {
        let shop_owner = @0xa;
        let buyer = @0xb;

        let mut scenario_val = test_scenario::begin(shop_owner);
        let scenario = &mut scenario_val;

        {
            create_shop(shop_owner, test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);

            add_item(
                &mut shop, 
                &shop_owner_cap,
                b"title", 
                b"description", 
                b"url", 
                1000000000, // 1 SUI
                34, 
                3
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            unlist_item(
                &mut shop, 
                &shop_owner_cap,
                get_item_id(item_ref)
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        test_scenario::next_tx(scenario, buyer);

        {
            let mut shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            let price = get_item_price(item_ref);
            let quantity_to_buy = 1;

            let mut payment_coin = sui::coin::mint_for_testing<SUI>(
                price * quantity_to_buy, 
                test_scenario::ctx(scenario)
            );

            purchase_item(
                &mut shop, 
                get_item_id(item_ref), 
                quantity_to_buy, 
                buyer, 
                &mut payment_coin, 
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(shop);

            coin::destroy_zero(payment_coin);
        };
        test_scenario::next_tx(scenario, buyer);

        {
            let shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            let expected_total_supply = 34;
            let expected_quantity_purchased = 1;

            assert_eq(get_item_available(item_ref), expected_total_supply - expected_quantity_purchased);
            assert_eq(balance::value(get_shop_balance(&shop)), get_item_price(item_ref));
            assert_eq(get_item_listed(item_ref), true);

            let purchased_item = test_scenario::take_from_sender<PurchasedItem>(scenario);
            assert_eq(get_purchased_item_id(&purchased_item), get_item_id(item_ref));

            test_scenario::return_shared(shop);
            test_scenario::return_to_sender(scenario, purchased_item);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_unlist_item() {
        let shop_owner = @0xa;

        let mut scenario_val = test_scenario::begin(shop_owner);
        let scenario = &mut scenario_val;

        {
            create_shop(shop_owner, test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);

            add_item(
                &mut shop, 
                &shop_owner_cap,
                b"title", 
                b"description", 
                b"url", 
                1000000000, // 1 SUI
                34, 
                3
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            unlist_item(
                &mut shop, 
                &shop_owner_cap,
                get_item_id(item_ref)
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        let tx = test_scenario::next_tx(scenario, shop_owner);
        let expected_events_emitted = 1;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );

        {
            let shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);
            assert_eq(get_item_listed(item_ref), false);

            test_scenario::return_shared(shop);
        };
        let tx = test_scenario::end(scenario_val);
        let expected_events_emitted = 0;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );
    }

    #[test]
    public fun test_withdraw_from_shop() {
        let shop_owner = @0xa;
        let buyer = @0xb;
        let recipient = @0xc;

        let mut scenario_val = test_scenario::begin(shop_owner);
        let scenario = &mut scenario_val;

        {
            create_shop(shop_owner, test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);

            add_item(
                &mut shop, 
                &shop_owner_cap,
                b"title", 
                b"description", 
                b"url", 
                1000000000, // 1 SUI
                34, 
                3
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };
        test_scenario::next_tx(scenario, buyer);

        {
            let mut shop = test_scenario::take_shared<Shop>(scenario);
            let item_id = 0;
            let item_ref = vector::borrow(get_shop_items(&shop), item_id);

            let price = get_item_price(item_ref);

            let mut payment_coin = sui::coin::mint_for_testing<SUI>(
                price, 
                test_scenario::ctx(scenario)
            );

            purchase_item(
                &mut shop, 
                get_item_id(item_ref), 
                1, 
                buyer, 
                &mut payment_coin, 
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(shop);

            coin::destroy_zero(payment_coin);
        };
        test_scenario::next_tx(scenario, shop_owner);

        {
            let shop_owner_cap  = 
                test_scenario::take_from_sender<ShopOwnerCapability>(scenario);
            let mut shop = test_scenario::take_shared<Shop>(scenario);

            let withdrawal_amount = balance::value(get_shop_balance(&shop));

            withdraw_from_shop(
                &mut shop, 
                &shop_owner_cap,
                withdrawal_amount,
                recipient,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario, shop_owner_cap);
            test_scenario::return_shared(shop);
        };

        let tx = test_scenario::next_tx(scenario, shop_owner);
        let expected_events_emitted = 1;
        assert_eq(
            test_scenario::num_user_events(&tx),
            expected_events_emitted
        );

        {
            let expected_shop_balance = 0;
            let shop = test_scenario::take_shared<Shop>(scenario);
            assert_eq(balance::value(get_shop_balance(&shop)), expected_shop_balance);

            test_scenario::return_shared(shop);
        };

        test_scenario::next_tx(scenario, recipient);
        {

            let expected_amount = 1000000000;
            let coin = test_scenario::take_from_sender<coin::Coin<SUI>>(scenario);
            assert_eq(coin::value(&coin), expected_amount);

            test_scenario::return_to_sender(scenario, coin);
        };
        test_scenario::end(scenario_val);
    }
}