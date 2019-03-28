--- Minetest API method. Adds definition to minetest.registered_chatcommands.
-- @param cmd the string - commnad name
-- @param chatcommand definition the table
minetest.register_chatcommand("mp", {
	params = "<command> [<item name> <amount>]",
	description = "Marketplace commands, type '/mp help' for more help.",
	privs = { interact = true },
	func = function(caller, param)
		local params = {}
		for substring in param:gmatch("%S+") do
			table.insert(params, substring)
		end
		-- print("caller", dump(caller))
		-- print("params", dump(params))

		--
		-- find
		--
		if params[1] == "find" then
			-- item name is missing from param[2]
			if not params[2] then
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You need to write the item name you want to find. example: /mp find default:stone. See some suggestion from the store: ")..x_marketplace.store_get_random()
			end

			local items = x_marketplace.store_find(params[2])

			if not items then
				return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: Oops there is no item like this in the store. Check out other items in the store: ")..x_marketplace.store_get_random()
			end

			return true, minetest.colorize(x_marketplace.colors.cyan, items)

		--
		-- show balance
		--
		elseif params[1] == "balance" then
			local balance = x_marketplace.get_player_balance(caller)

			-- check for number sanity, positive number
			if not balance or
				 x_marketplace.isnan(balance) or
				 not x_marketplace.isfinite(balance) then

				local player = minetest.get_player_by_name(caller)
				player:set_attribute("balance", 0)
				balance = 0
			end

			return true, minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: Your balance is: "..balance.." BitGold")

		--
		-- sell hand
		--
		elseif params[1] == "sellhand" then
			local player = minetest.get_player_by_name(caller)

			local player_pos = player:get_pos()
			--local find_signs = x_marketplace.find_signs(player:get_pos(), "/mp sell", "x_marketplace:sign_wall_mese")

			--if not find_signs then
				--return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: There are no Mese Signs around you with text '/mp sell' on them. Transaction cancelled.")
			--end

			local hand = player:get_wielded_item()
			local item_name = hand:get_name()
			local store_item = x_marketplace.store_list[item_name]

			-- item exists in the store
			if store_item then
				local item_count = hand:get_count()
				local itemstack = ItemStack(item_name)

				-- check for number sanity, positive number
				if x_marketplace.isnan(item_count) or
					 not x_marketplace.isfinite(item_count) then
					item_count = 1
				end

				if item_count > itemstack:get_stack_max() then
					item_count = itemstack:get_stack_max()
				end


				local sell_price = store_item.sell * item_count
				local new_balance, msg = x_marketplace.set_player_balance(caller, sell_price)

				if msg == "above" then
					return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: You will go above the maximum balance if you sell this item. Transaction cancelled.")
				end

				player:set_wielded_item(ItemStack(""))

				minetest.sound_play("x_marketplace_gold", {
					object = player,
					max_hear_distance = 10,
					gain = 1.0
				})

				return true, minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: You sold "..item_count.." item(s) of "..item_name.." for "..sell_price.." BitGold. Your new balance is: "..new_balance.." BitGold")
			else
			-- item does not exists in the store
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You cannot sell this item. Search in store for items you can sell, example: /mp find stone. See some suggestion from the store: ")..x_marketplace.store_get_random()
			end

		--
		-- info hand
		--
		elseif params[1] == "infohand" then
			local player = minetest.get_player_by_name(caller)
			local hand = player:get_wielded_item()
			local item_name = hand:get_name()
			local item_count = hand:get_count()
			local store_item = x_marketplace.store_list[item_name]

			-- item exists in the store
			if store_item then
				local itemstack = ItemStack(item_name)

				if item_count > itemstack:get_stack_max() then
					item_count = itemstack:get_stack_max()
				end

				local sell_price = store_item.sell * item_count

				return true, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: "..item_name.." buy: "..store_item.buy.." sell: "..store_item.sell..". You can sell the item(s) you are holding for: "..sell_price.." BitGold. example: /mp sellhand")
			else
			-- item does not exists in the store
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: This item is not in store. See some suggestion from the store: ")..x_marketplace.store_get_random()
			end

		--
		-- buy hand
		--
		elseif params[1] == "buyhand" then
			local player = minetest.get_player_by_name(caller)

			local find_signs = x_marketplace.find_signs(player:get_pos(), "/mp buy", "x_marketplace:sign_wall_diamond")

			--if not find_signs then
			--	return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: There are no Diamond Signs around you with text '/mp buy' on them. Transaction cancelled.")
			--end

			local hand = player:get_wielded_item()
			local item_name = hand:get_name()
			local store_item = x_marketplace.store_list[item_name]

			-- item exists in the store
			if store_item then
				local amount = tonumber(params[2])
				local inv = player:get_inventory("main")
				local itemstack = ItemStack(item_name)

				-- check for number sanity, positive number
				if not amount or
					 x_marketplace.isnan(amount) or
					 not x_marketplace.isfinite(amount) or
					 amount <= 0 then

					amount = 1
				end

				if amount > itemstack:get_stack_max() then
					amount = itemstack:get_stack_max()
				end

				itemstack:set_count(amount)

				local buy_price = amount * store_item.buy
				local new_balance = x_marketplace.set_player_balance(caller, buy_price * -1)

				-- not enough money
				if not new_balance then
					return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You don't have enought BitGold. Price for "..amount.." item(s) of "..item_name.." is "..buy_price.." BitGold, but your current balance is: "..x_marketplace.get_player_balance(caller).." BitGold")
				end

				-- drop items what doesn't fit in the inventory
				local leftover_item = inv:add_item("main", itemstack)
				if leftover_item:get_count() > 0 then
					local p = table.copy(player:get_pos())
					p.y = p.y + 1.2
					local obj = minetest.add_item(p, leftover_item)

					if obj then
						local dir = player:get_look_dir()
						dir.x = dir.x * 2.9
						dir.y = dir.y * 2.9 + 2
						dir.z = dir.z * 2.9
						obj:set_velocity(dir)
						obj:get_luaentity().dropped_by = caller
					end
				end

				minetest.sound_play("x_marketplace_gold", {
					object = player,
					max_hear_distance = 10,
					gain = 1.0
				})

				return true, minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: You bought "..amount.." item(s) of "..item_name.." for "..buy_price.." BitGold. Your new balance is: "..new_balance.." BitGold")
			else
			-- item does not exists in the store
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: This item is not in store. See some suggestion from the store: ")..x_marketplace.store_get_random()
			end

		--
		-- sell inventory
		--
		elseif params[1] == "sellinv" then
			params[2] = x_marketplace.normalize_nodename(params[2])

			-- item name is missing from param[2]
			if not params[2] then
				return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: You need to write the item name you want to sell. example: /mp sellinv default:stone. See some suggestion from the store: ")..x_marketplace.store_get_random()
			end

			local player = minetest.get_player_by_name(caller)
			local find_signs = x_marketplace.find_signs(player:get_pos(), "/mp sell", "x_marketplace:sign_wall_mese")

		--	if not find_signs then
				--return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: There are no Mese Signs around you with text '/mp sell' on them. Transaction cancelled.")
			--end

			local store_item = x_marketplace.store_list[params[2]]

			-- item exists in the store
			if store_item then
				local inv = player:get_inventory("main")
				local itemstack = ItemStack(params[2])
				local balance = x_marketplace.get_player_balance(caller)
				local amount = 0
				local over_max_balance = false

				for k, v in ipairs(inv:get_list("main")) do
					if v:get_name() == params[2] then
						local amount_to_remove = v:get_count()

						if amount_to_remove > itemstack:get_stack_max() then
							amount_to_remove = itemstack:get_stack_max()
						end

						amount = amount + amount_to_remove

						if (balance + amount * store_item.sell) > x_marketplace.max_balance then
							amount = amount - amount_to_remove
							over_max_balance = true
							break
						else
							inv:remove_item("main", v)
						end
					end
				end

				local sell_price = amount * store_item.sell
				local new_balance = x_marketplace.set_player_balance(caller, sell_price)

				if amount == 0 then
					return false, minetest.chat_send_player(caller, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: You have nothing to sell in your inventory."))
				end

				if over_max_balance then
					minetest.chat_send_player(caller, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: We couldn't buy all your items without going above your maximum balance."))
				end

				minetest.sound_play("x_marketplace_gold", {
					object = player,
					max_hear_distance = 10,
					gain = 1.0
				})

				return true, minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: You sold "..amount.." item(s) of "..params[2].." for "..sell_price.." BitGold. Your new balance is: "..x_marketplace.get_player_balance(caller).." BitGold")
			else
			-- item does not exists in the store
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You cannot sell this item. Search in store for items you can sell, example: /mp find stone. See some suggestion from the store: ")..x_marketplace.store_get_random()
			end

		--
		-- buy inventory
		--
		elseif params[1] == "buyinv" then
			params[2] = x_marketplace.normalize_nodename(params[2])

			-- item name is missing from param[2]
			if not params[2] then
				return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: You need to write the item name you want to buy. example: /mp buyinv default:stone, or check out other items in the store: ")..x_marketplace.store_get_random()
			end

			local player = minetest.get_player_by_name(caller)
			local find_signs = x_marketplace.find_signs(player:get_pos(), "/mp buy", "x_marketplace:sign_wall_diamond")

			--if not find_signs then
				--return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: There are no Diamond Signs around you with text '/mp buy' on them. Transaction cancelled.")
			--end

			local store_item = x_marketplace.store_list[params[2]]

			if store_item then
				local itemstack = ItemStack(params[2])
				local inv = player:get_inventory("main")
				local amount = 0
				itemstack:set_count(itemstack:get_stack_max())

				for k, v in ipairs(inv:get_list("main")) do
					if v:get_name() == "" and v:get_count() == 0 then
						amount = amount + itemstack:get_count()
					end
				end

				if amount == 0 then
					return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: You don't have empty space in your inventory. Transaction cancelled.")
				end

				local buy_price = amount * store_item.buy
				local new_balance = x_marketplace.set_player_balance(caller, buy_price * -1)

				-- not enough money
				if not new_balance then
					return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You don't have enought BitGold. Price for "..amount.." item(s) of "..params[2].." is "..buy_price.." BitGold, but your current balance is: "..x_marketplace.get_player_balance(caller).." BitGold.")
				end

				for k, v in ipairs(inv:get_list("main")) do
					if v:get_name() == "" and v:get_count() == 0 then
						inv:add_item("main", itemstack)
					end
				end

				minetest.sound_play("x_marketplace_gold", {
					object = player,
					max_hear_distance = 10,
					gain = 1.0
				})

				return true, minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: You bought "..amount.." item(s) of "..params[2].." for "..buy_price.." BitGold. Your new balance is: "..new_balance.." BitGold")

			else
			-- item not in store
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: This item is not in store, check out other items from the store: ")..x_marketplace.store_get_random()
			end

		--
		-- buy
		--
		elseif params[1] == "buy" then
			local amount = tonumber(params[3])
			params[2] = x_marketplace.normalize_nodename(params[2])

			-- check for param[2] - item name
			if not params[2] then
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You need to write the item name you want to buy. example: /mp buy default:stone 10, or check out other items in the store: ")..x_marketplace.store_get_random()
			end

			-- find sign
			local player = minetest.get_player_by_name(caller)
			local find_signs = x_marketplace.find_signs(player:get_pos(), "/mp buy", "x_marketplace:sign_wall_diamond")

			--if not find_signs then
				--return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: There are no Diamond Signs around you with text '/mp buy' on them. Transaction cancelled.")
			--end

			-- item not in store
			if not x_marketplace.store_list[params[2]] then
				return false, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: This item is not in store, check out other items from the store: ")..x_marketplace.store_get_random()
			end

			-- check for param[3] - amount
			local itemstack = ItemStack(params[2])

			-- check for number sanity, positive number
			if not amount or
				 x_marketplace.isnan(amount) or
				 not x_marketplace.isfinite(amount) or
				 amount <= 0 then

				amount = 1
			end

			if amount > itemstack:get_stack_max() then
				amount = itemstack:get_stack_max()
			end

			itemstack:set_count(amount)

			-- add items to main inventory
			local store_item = x_marketplace.store_list[params[2]]
			local inv = player:get_inventory("main")

			local buy_price = amount * store_item.buy
			local new_balance = x_marketplace.set_player_balance(caller, buy_price * -1)

			-- not enough money
			if not new_balance then
				return false, minetest.colorize(x_marketplace.colors.red, "MARKET PLACE: You don't have enought BitGold. Price for "..amount.." item(s) of "..params[2].." is "..buy_price.." BitGold, but your current balance is: "..x_marketplace.get_player_balance(caller).." BitGold")
			end

			-- drop items what doesn't fit in the inventory
			local leftover_item = inv:add_item("main", itemstack)
			if leftover_item:get_count() > 0 then
				local p = table.copy(player:get_pos())
				p.y = p.y + 1.2
				local obj = minetest.add_item(p, leftover_item)

				if obj then
					local dir = player:get_look_dir()
					dir.x = dir.x * 2.9
					dir.y = dir.y * 2.9 + 2
					dir.z = dir.z * 2.9
					obj:set_velocity(dir)
					obj:get_luaentity().dropped_by = caller
				end
			end

			minetest.sound_play("x_marketplace_gold", {
				object = player,
				max_hear_distance = 10,
				gain = 1.0
			})

			return true, minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: You bought "..amount.." item(s) of "..params[2].." for "..buy_price.." BitGold. Your new balance is: "..new_balance.." BitGold")

		--
		-- top 5 richest
		--
		elseif params[1] == "top" then
			local players = minetest.get_connected_players()
			local temp_tbl = {}

			for k, v in ipairs(players) do
				local pname = v:get_player_name()
				local balance = x_marketplace.get_player_balance(pname)
				table.insert(temp_tbl, { name = pname, balance = tonumber(balance) })
			end

			table.sort(temp_tbl, function(a, b) return a.balance > b.balance end)

			local msg = "MARKET PLACE: \n"
			local length = 5

			if length > #temp_tbl then
				length = #temp_tbl
			end

			for i = 1, length do
				msg = msg..i..". "..temp_tbl[i].name.."\n"
			end

			-- print(dump(temp_tbl))
			return true, minetest.colorize(x_marketplace.colors.yellow, msg)

		--
		-- help
		--
		elseif params[1] == "help" then
			local msg =
			minetest.colorize(x_marketplace.colors.cyan, "/mp find").." <item name>, find item in store\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp balance")..", show your current balance in BitGold\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp sellhand")..", sell item(s) currently holding in hand, you must be near Mese Sign with text '/mp sell' on it\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp buyhand").." [<amount>], buy <amount> of item(s) currently holding in hand, when <amount> is not provided then amount is 1, you must be near Diamond Sign with text '/mp buy' on it\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp infohand")..", show more information about the item(s) you are currently holding in hand from the store\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp buy").." <item name> [<amount>], buy <amount> of <item name> from store, if <amount> is not provided then amount is 1, you must be near Diamond Sign with text '/mp buy' on it\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp sellinv").." <item name>, sell all items <item name> from the 'main' inventory list, you must be near Mese Sign with text '/mp sell' on it\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp buyinv").." <item name>, buy full inventory of items <item name>, empty slots in the 'main' inventory are required, you must be near Diamond Sign with text '/mp buy' on it\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp top")..", show top 5 richest players currently online\n"..
			minetest.colorize(x_marketplace.colors.cyan, "/mp help")..", print out this help\n"

			-- print(msg)
			return true, msg
		end
	end
})
