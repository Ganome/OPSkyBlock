--[[ Helpers ]]--

-- Skin mod detection
local skin_mod

local skin_mods = {"skinsdb", "skins", "u_skins", "simple_skins", "wardrobe"}

for _, mod in pairs(skin_mods) do
	local path = minetest.get_modpath(mod)
	if path then
		skin_mod = mod
	end
end

local function get_player_skin(player)
	local name = player:get_player_name()
	local armor_tex = ""
	if minetest.global_exists("armor") then
		-- Filter out helmet (for bike helmet) and boots/shield (to not mess up UV mapping)
		local function filter(str, find)
			for _,f in pairs(find) do
				str = str:gsub("%^"..f.."_(.-.png)", "")
			end
			return str
		end
		armor_tex = filter("^"..armor.textures[name].armor, {"shields_shield", "3d_armor_boots", "3d_armor_helmet"})
	end
	-- Return the skin with armor (if applicable)
	if skin_mod == "skinsdb" then
		return "[combine:64x32:0,0="..skins.get_player_skin(minetest.get_player_by_name(name))["_texture"]..armor_tex
	elseif (skin_mod == "skins" or skin_mod == "simple_skins") and skins.skins[name] then
		return skins.skins[name]..".png"..armor_tex
	elseif skin_mod == "u_skins" and u_skins.u_skins[name] then
		return u_skins.u_skins[name]..".png"..armor_tex
	elseif skin_mod == "wardrobe" and wardrobe.playerSkins and wardrobe.playerSkins[name] then
		return wardrobe.playerSkins[name]..armor_tex
	end
	local skin = player:get_properties().textures[1]
	-- If we just have 3d_armor enabled make sure we get the player skin properly
	if minetest.global_exists("armor") then
		skin = armor:get_player_skin(name)
	end
	return skin..armor_tex
end

-- Keep track of attached players (for leaveplayer)
local attached = {}

-- Terrain checkers
local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "liquid") ~= 0
end

local function is_bike_friendly(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "crumbly") == 0 or minetest.get_item_group(nn, "bike_friendly") ~= 0
end

-- Maths
local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

-- Custom hand
minetest.register_node("bike:hand", {
	description = "",
	-- No interaction on a bike :)
	range = 0,
	on_place = function(itemstack, placer, pointed_thing)
		return ItemStack("bike:hand "..itemstack:get_count())
	end,
	-- Copy default:hand looks so it doesnt look as weird when the hands are switched
	wield_image = minetest.registered_items[""].wield_image,
	wield_scale = minetest.registered_items[""].wield_scale,
	node_placement_prediction = "",
})

--[[ Bike ]]--

-- Default textures (overidden when mounted)
local default_tex = {
	"metal_grey.png",
	"gear.png",
	"metal_blue.png",
	"leather.png",
	"chain.png",
	"metal_grey.png",
	"leather.png",
	"metal_black.png",
	"metal_black.png",
	"blank.png",
	"tread.png",
	"gear.png",
	"spokes.png",
	"tread.png",
	"spokes.png",
}

-- Entity
local bike = {
	physical = true,
	-- Warning: Do not change the position of the collisionbox top surface,
	-- lowering it causes the bike to fall through the world if underwater
	collisionbox = {-0.5, -0.4, -0.5, 0.5, 0.8, 0.5},
	collide_with_objects = false,
	visual = "mesh",
	mesh = "bike.b3d",
	textures = default_tex,
	stepheight = 0.6,
	driver = nil,
	old_driver = {},
	v = 0,		  -- Current velocity
	last_v = 0,   -- Last velocity
	max_v = 6.9,   -- Max velocity
	fast_v = 0,   -- Fast adder
	f_speed = 30, -- Frame speed
	last_y = nil, -- Last height
	up = false,	  -- Are we going up?
	timer = 0,
	removed = false
}

-- Dismont the player
local function dismount_player(bike, exit)
	bike.object:set_velocity({x = 0, y = 0, z = 0})
	-- Make the bike empty again
	bike.object:set_properties({textures = default_tex})
	bike.v = 0

	if bike.driver then
		attached[bike.driver:get_player_name()] = nil
		bike.driver:set_detach()
		-- Reset original player properties
		bike.driver:set_properties({visual_size=bike.old_driver["vsize"]})
		bike.driver:set_eye_offset(bike.old_driver["eye_offset"].offset_first, bike.old_driver["eye_offset"].offset_third)
		bike.driver:hud_set_flags(bike.old_driver["hud"])
		bike.driver:get_inventory():set_stack("hand", 1, bike.driver:get_inventory():get_stack("old_hand", 1))
		-- Is the player leaving? If so, dont do this stuff or Minetest will have a fit
		if not exit then
			local pos = bike.driver:get_pos()
			pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
			bike.driver:set_pos(pos)
		end
		bike.driver = nil
	end
end

-- Mounting
function bike.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if not self.driver then
		attached[clicker:get_player_name()] = true
		-- Make integrated player appear
		self.object:set_properties({
			textures = {
				"metal_grey.png",
				"gear.png",
				"metal_blue.png",
				"leather.png",
				"chain.png",
				"metal_grey.png",
				"leather.png",
				"metal_black.png",
				"metal_black.png",
				get_player_skin(clicker).."^helmet.png",
				"tread.png",
				"gear.png",
				"spokes.png",
				"tread.png",
				"spokes.png",
			},
		})
		-- Save the player's properties that we need to change
		self.old_driver["vsize"] = clicker:get_properties().visual_size
		self.old_driver["eye_offset"] = clicker:get_eye_offset()
		self.old_driver["hud"] = clicker:hud_get_flags()
		clicker:get_inventory():set_stack("old_hand", 1, clicker:get_inventory():get_stack("hand", 1))
		-- Change the hand
		clicker:get_inventory():set_stack("hand", 1, "bike:hand")
		local attach = clicker:get_attach()
		if attach and attach:get_luaentity() then
			local luaentity = attach:get_luaentity()
			if luaentity.driver then
				luaentity.driver = nil
			end
			clicker:set_detach()
		end
		self.driver = clicker
		-- Set new properties and hide HUD
		clicker:set_properties({visual_size = {x=0,y=0}})
		clicker:set_attach(self.object, "body", {x = 0, y = 10, z = 5}, {x = 0, y = 0, z = 0})
		clicker:set_eye_offset({x=0,y=-3,z=10},{x=0,y=0,z=5})
		clicker:hud_set_flags({
			hotbar = false,
			wielditem = false,
		})
		-- Look forward initially
		clicker:set_look_horizontal(self.object:get_yaw())
	end
end

function bike.on_activate(self, staticdata, dtime_s)
	self.object:set_acceleration({x = 0, y = -9.8, z = 0})
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
	-- We aren't going up yet
	self.last_y = 0
end

function bike.get_staticdata(self)
	return tostring(self.v)
end

function bike.on_punch(self, puncher)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end
	if not self.driver then
		local inv = puncher:get_inventory()
		-- We can only carry one bike
		if not inv:contains_item("main", "bike:bike") then
			local leftover = inv:add_item("main", "bike:bike")
			-- if no room in inventory add the bike to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:get_pos(), leftover)
			end
		else
			-- Turn it into raw materials
			if not (creative and creative.is_enabled_for(puncher:get_player_name())) then
				local ctrl = puncher:get_player_control()
				if not ctrl.sneak then
					minetest.chat_send_player(puncher:get_player_name(), "Warning: Destroying the bike gives you only some resources back. If you are sure, hold sneak while destroying the bike.")
					return
				end
				local leftover = inv:add_item("main", "default:steel_ingot 6")
				-- if no room in inventory add the iron to the world
				if not leftover:is_empty() then
					minetest.add_item(self.object:get_pos(), leftover)
				end
			end
		end
		self.removed = true
		-- Delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
	end
end

-- Animations
local function bike_anim(self)
	-- The `self.object:get_animation().y ~= <frame>` is to check if the animation is already running
	if self.driver then
		local ctrl = self.driver:get_player_control()
		-- Wheely
		if ctrl.jump then
			-- We are moving
			if self.v > 0 then
				if self.object:get_animation().y ~= 79 then
					self.object:set_animation({x=59,y=79}, self.f_speed + self.fast_v, 0, true)
				end
				return
			-- Else we are not
			else
				if self.object:get_animation().y ~= 59 then
					self.object:set_animation({x=59,y=59}, self.f_speed + self.fast_v, 0, true)
				end
				return
			end
		end
		-- Left or right tilt, but only if we arent doing a wheely
		if ctrl.left then
			if self.object:get_animation().y ~= 58 then
				self.object:set_animation({x=39,y=58}, self.f_speed + self.fast_v, 0, true)
			end
			return
		elseif ctrl.right then
			if self.object:get_animation().y ~= 38 then
				self.object:set_animation({x=19,y=38}, self.f_speed + self.fast_v, 0, true)
			end
			return
		end
	end
	-- If none of that, then we are just moving forward
	if self.v > 0 then
		if self.object:get_animation().y ~= 18 then
			self.object:set_animation({x=0,y=18}, 30, 0, true)
		end
		return
	-- Or not
	else
		if self.object:get_animation().y ~= 0 then
			self.object:set_animation({x=0,y=0}, 0, 0, false)
		end
	end
end

-- Run every tick
function bike.on_step(self, dtime)
	-- Player checks
	if self.driver then
		-- Is the actual player somehow still visible?
		if self.driver:get_properties().visual_size ~= {x=0,y=0} then
			self.driver:set_properties({visual_size = {x=0,y=0}})
		end

		-- Has the player left?
		if not attached[self.driver:get_player_name()] then
			dismount_player(self, true)
		end
	end

	-- Have we come to a sudden stop?
	if math.abs(self.last_v - self.v) > 3 then
		-- And is Minetest not being dumb
		if not self.up then
			self.v = 0
			-- If so, dismount
			if self.driver then
				dismount_player(self)
			end
		end
	end

	self.last_v = self.v

	self.timer = self.timer + dtime;
	if self.timer >= 0.5 then
		-- Recording y values to check if we are going up
		self.last_y = self.object:get_pos().y
		self.timer = 0
	end

	-- Are we going up?
	if self.last_y < self.object:get_pos().y then
		self.up = true
	else
		self.up = false
	end

	-- Run animations
	bike_anim(self)

	-- Are we falling?
	if self.object:get_velocity().y < -10 and self.driver ~= nil then
		-- If so, dismount
		dismount_player(self)
		return
	end

	local current_v = get_v(self.object:get_velocity()) * get_sign(self.v)
	self.v = (current_v + self.v*3) / 4
	if self.driver then
		local ctrl = self.driver:get_player_control()
		local yaw = self.object:get_yaw()
		local agility = 0

		-- Sneak dismount
		if ctrl.sneak then
			dismount_player(self)
		end

		if self.v > 0.4 then
			agility = 1/math.sqrt(self.v)
		else
			agility = 1.58
		end

		-- Forward
		if ctrl.up then
			-- Are we going fast?
			if ctrl.aux1 then
				if self.fast_v ~= 5 then
					self.fast_v = 5
				end
			else
				if self.fast_v > 0 then
					self.fast_v = self.fast_v - 0.05 * agility
				end
			end
			self.v = self.v + 0.2 + (self.fast_v*0.1) * agility
		-- Brakes
		elseif ctrl.down then
			self.v = self.v - 0.5 * agility
			if self.fast_v > 0 then
				self.fast_v = self.fast_v - 0.05 * agility
			end
		-- Nothin'
		else
			self.v = self.v - 0.05 * agility
			if self.fast_v > 0 then
				self.fast_v = self.fast_v - 0.05 * agility
			end
		end

		-- Wheely will change this
		local turn_speed = 1

		-- Are we doing a wheely?
		if ctrl.jump then
			turn_speed = 2
		else
			turn_speed = 1
		end

		-- Turning
		if ctrl.left then
			self.object:set_yaw(yaw + (turn_speed + dtime) * 0.06 * agility)
		elseif ctrl.right then
			self.object:set_yaw(yaw - (turn_speed + dtime) * 0.06 * agility)
		end
	end
	-- Movement
	local velo = self.object:get_velocity()
	if self.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		self.object:move_to(self.object:get_pos())
		return
	end
	local s = get_sign(self.v)
	if s ~= get_sign(self.v) then
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if self.v > self.max_v + self.fast_v then
		self.v = self.max_v + self.fast_v
	elseif self.v < 0 then
		self.v = 0
	end

	local p = self.object:get_pos()
	if is_water(p) then
		self.v = self.v / 1.3
	end

	-- Can we ride good here?
	if not is_bike_friendly({x=p.x, y=p.y + self.collisionbox[2] - 0.05, z=p.z}) then
		self.v = self.v / 1.05
	end

	local new_velo
	new_velo = get_velocity(self.v, self.object:get_yaw(), self.object:get_velocity().y)
	self.object:move_to(self.object:get_pos())
	self.object:set_velocity(new_velo)
end

-- Check for stray bike hand
minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	if inv:get_stack("hand", 1):get_name() == "bike:hand" then
		inv:set_stack("hand", 1, inv:get_stack("old_hand", 1))
	end
end)

-- Player is leaving (doesn't matter if they are on a bike or not)
minetest.register_on_leaveplayer(function(player)
	attached[player:get_player_name()] = nil
end)

-- Dismount all players on server shutdown
minetest.register_on_shutdown(function()
	for _, e in pairs(minetest.luaentities) do
		if (e.driver ~= nil) then
			dismount_player(e, true)
		end
	end
end)

-- Automatically dismount corpses
minetest.register_on_dieplayer(function(player)
	attached[player:get_player_name()] = nil
end)

-- Register the entity
minetest.register_entity("bike:bike", bike)

-- Craftitem
minetest.register_craftitem("bike:bike", {
	description = "bike",
	inventory_image = "bike_inventory.png",
	wield_scale = {x = 3, y = 3, z = 2},
	groups = {flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end

		player_pos = placer:get_pos()
		bike = minetest.add_entity({x=player_pos.x, y=player_pos.y+0.5, z=player_pos.z}, "bike:bike")
		if bike then
			if placer then
				bike:set_yaw(placer:get_look_horizontal())
			end
			local player_name = placer and placer:get_player_name() or ""
			if not (creative and creative.is_enabled_for and
					creative.is_enabled_for(player_name)) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})

-- Crafting things
minetest.register_craftitem("bike:wheel", {
	description = "Bike Wheel",
	inventory_image = "bike_wheel.png",
})

minetest.register_craftitem("bike:handles", {
	description = "Bike Handles",
	inventory_image = "bike_handles.png",
})

if minetest.get_modpath("technic") ~= nil then
	minetest.register_craft({
		output = "bike:wheel 2",
		recipe = {
			{"", "technic:rubber", ""},
			{"technic:rubber", "default:steel_ingot", "technic:rubber"},
			{"", "technic:rubber", ""},
		},
	})
else
	minetest.register_craft({
		output = "bike:wheel 2",
		recipe = {
			{"", "group:wood", ""},
			{"group:wood", "default:steel_ingot", "group:wood"},
			{"", "group:wood", ""},
		},
	})
end

minetest.register_craft({
	output = "bike:handles",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"group:wood", "", "group:wood"},
	},
})

minetest.register_craft({
	output = "bike:bike",
	recipe = {
		{"bike:handles", "", "group:wood"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"bike:wheel", "", "bike:wheel"},
	},
})
