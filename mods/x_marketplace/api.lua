--- Returns true if given value is a finite number; otherwise false or nil if value is not of type string nor number.
function x_marketplace.isfinite(value)
	if type(value) == "string" then
		value = tonumber(value)
		if value == nil then return nil end
	elseif type(value) ~= "number" then
		return nil
	end
	return value > -math.huge and value < math.huge
end

--- Returns true if given value is not a number (NaN); otherwise false or nil if value is not of type string nor number.
function x_marketplace.isnan(value)
	if type(value) == "string" then
		value = tonumber(value)
		if value == nil then return nil end
	elseif type(value) ~= "number" then
		return nil
	end
	return value ~= value
end

--- rounds a number to the nearest decimal places
-- @local
local function round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

local function string_endswith(full, part)
	return full:find(part, 1, true) == #full - #part + 1
end

--- Normalize nodename string without mod prefix and return nodename with mod prefix. This function was borrowed from WorldEdit mod.
-- @param nodename name of the node as a string, can be without the mod prefix
-- @return nil if node doesn't exists or nodename with mode prefix
-- @see https://github.com/Uberi/Minetest-WorldEdit
function x_marketplace.normalize_nodename(nodename)
	if not nodename then
		return false
	end

	nodename = nodename:gsub("^%s*(.-)%s*$", "%1") -- strip spaces
	if nodename == "" then return nil end

	local fullname = ItemStack({name=nodename}):get_name() -- resolve aliases
	if minetest.registered_nodes[fullname] or fullname == "air" then -- full name
		return fullname
	end
	for key, value in pairs(minetest.registered_nodes) do
		if string_endswith(key, ":" .. nodename) then -- matches name (w/o mod part)
			return key
		end
	end
end

--- Search items in marketplace object
-- @param string the string
-- @return string with found items, if no items found returns boolean false
function x_marketplace.store_find(string)
	local found = ""
	local str = x_marketplace.normalize_nodename(string)

	if not str then
		return false
	end

	for k, v in pairs(x_marketplace.store_list) do
		if string.find(k, str) then
			found = found..k.." buy: "..string.format("%.2f", v.buy).." sell: "..string.format("%.2f", v.sell).."\n"
		end
	end

	if found == "" then
		found = false
	end

	return found
end

--- Get random items from the store
-- @param number the integer
-- @return string with found items
function x_marketplace.store_get_random(number)
	local keys, i, suggest = {}, 1, ""
	local how_many = number or 5

	for k, v in pairs(x_marketplace.store_list) do
		keys[i] = k
		i = i + 1
	end

	for i = 1, how_many do
		suggest = suggest.."\n"..keys[math.random(1, #keys)]
	end

	return suggest
end

--- Get players balance of BitGold
-- @param name the string of player name
-- @return string the current balance
function x_marketplace.get_player_balance(name)
	if not name then
		return ""
	end

	local player = minetest.get_player_by_name(name)
	local balance = player:get_attribute("balance") or 0
	return balance
end

--- Set players balance of BitGold
-- @param name the string of player name
-- @param amount the number of what should be added/deducted (if negative) from players balance
-- @return string the balance info message, returns false if not enough funds
function x_marketplace.set_player_balance(name, amount)
	if not name or not amount then
		return ""
	end
	local player = minetest.get_player_by_name(name)
	local balance = player:get_attribute("balance") or 0
	local new_balance = balance + amount

	if new_balance < 0 then
		return false, "below"
	end

	if new_balance > x_marketplace.max_balance then
		return false, "above"
	end

	player:set_attribute("balance", new_balance)

	return new_balance
end

function x_marketplace.find_signs(player_pos, text, sign)
	local pos0 = vector.subtract(player_pos, 2)
	local pos1 = vector.add(player_pos, 2)
	local positions = minetest.find_nodes_in_area(pos0, pos1, sign)
	local found = false

	if #positions <= 0 then
		return false
	end

	for k, v in pairs(positions) do
		local sign_meta = minetest.get_meta(v)
		local sign_text = sign_meta:get_string("text"):trim()

		if sign_text == text then
			found = true
			break
		end
	end

	return found
end

minetest.register_craftitem("x_marketplace:head", {
	description = "head",
	inventory_image = "x_marketplace_head-front.png",
	wield_image = "x_marketplace_head-front.png",
	stack_max = 1,
	wield_scale = {x=1.5, y=1.5, z=6},
	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)

			if node.name == "x_marketplace:sign_wall_bones" then
				local node_meta = minetest.get_meta(pointed_thing.under)

				if node_meta:get_string("text"):trim() == "/mp sellhead" then
					local stack_meta = itemstack:to_table().meta
					local stack_meta_value = tonumber(stack_meta.value)
					local stack_meta_owner = stack_meta.owner

					if not stack_meta_value then
						itemstack:take_item()
						return itemstack
					end

					-- sell item
					local new_balance = x_marketplace.set_player_balance(user:get_player_name(), stack_meta_value)

					if new_balance then
						minetest.sound_play("x_marketplace_gold", {
							object = user,
							max_hear_distance = 10,
							gain = 1.0
						})

						minetest.chat_send_player(user:get_player_name(), minetest.colorize(x_marketplace.colors.green, "MARKET PLACE: You sold "..stack_meta_owner.." head for "..stack_meta_value.." BitGold. Your new balance is: "..new_balance.." BitGold"))

						itemstack:take_item()
					else
						minetest.chat_send_player(user:get_player_name(), minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: You will go above the maximum balance if you sell this item. Transaction cancelled."))
					end

				end

			else
				minetest.chat_send_player(user:get_player_name(), minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: If you want to sell the head, you have to punch Bones Sign with text '/mp sellhead' on it."))
			end
		end

		return itemstack
	end,
})

minetest.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	local balance = tonumber(x_marketplace.get_player_balance(player_name))
	local lost_value, new_balance

	if balance then
		-- no money, nothing to loose
		if balance == 0 then
			return
		-- almost no money, drop everything
		elseif balance <= 10 then
			lost_value = balance
		-- loose between 5-10% from balance
		else
			lost_value = (balance / 100) * math.random(5, 10)
		end

		lost_value = round(lost_value, 2)

		new_balance = x_marketplace.set_player_balance(player_name, lost_value * -1)

		local pos = vector.round(player:getpos())
		local itemstack = ItemStack("x_marketplace:head")
		local meta = itemstack:get_meta()
		local item_description = minetest.registered_items["x_marketplace:head"]["description"]

		meta:set_string("owner", player_name)
		meta:set_string("value", lost_value)
		meta:set_string("description", player_name.." "..item_description.."\nvalue: "..lost_value.." BitGold")

		local obj = minetest.add_item(pos, itemstack)
		if obj then
			obj:set_velocity({
				x = math.random(-10, 10) / 9,
				y = 5,
				z = math.random(-10, 10) / 9,
			})
		end

		minetest.chat_send_player(player_name, minetest.colorize(x_marketplace.colors.yellow, "MARKET PLACE: When you died you lost "..lost_value.." BitGold"))
	end
end)
