settings = {};
settings.spawnpos = {x=63,y=2,z=-77}

minetest.register_chatcommand("spawn", {
	description = "Move player back to spawn",
	privs = {
		interact = true
	},
	
	func = function(name, param)
		local player = minetest.get_player_by_name(name); --if player then player:set_hp(0) end
		player:set_pos(settings.spawnpos)
	end
})
