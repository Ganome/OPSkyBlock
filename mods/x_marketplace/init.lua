-- Definitions made by this mod that other mods can use too
-- @module x_marketplace
-- @author SaKeL
x_marketplace = {}
x_marketplace.max_balance = 100000000 -- one million
x_marketplace.colors = {
	["yellow"] = "#FFEB3B", -- info
	["green"] = "#4CAF50", -- success
	["red"] = "#f44336", -- error
	["cyan"] = "#00BCD4" -- terminal info
}

local path = minetest.get_modpath("x_marketplace")

dofile(path.."/store_list.lua")
dofile(path.."/api.lua")
dofile(path.."/chatcommands.lua")
dofile(path.."/nodes.lua")

print ("[Mod] x_marketplace loaded")
