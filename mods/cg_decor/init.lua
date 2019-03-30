cg_decor = {}

--------------------------------------------------------------------------------------------
-- Mulch -----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_node("cg_decor:mulch", {
	description = "Dirt with Mulch",
	tiles = {"cg_decor_mulch.png", "default_dirt.png", "default_dirt.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1},
	drop = 'cg_decor:mulch',--'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})



--------------------------------------------------------------------------------------------
-- Flowers ---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

function cg_decor.register_flower(name, desc, texture, sel_box) --global flower register
	if not sel_box or sel_box == "" then
		sel_box = { -0.5, -0.5, -0.5, 0.5, -0.3, 0.5 }
	end
	minetest.register_node("cg_decor:"..name, {
		description = desc,
		drawtype = "mesh",
		mesh = "cg_decor_tree_leaves.obj",
		tiles = { texture },
		inventory_image = texture,
		wield_image = texture,
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		groups = {snappy=3,flammable=2,flower=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = sel_box,
		},
	})
end

cg_decor.register_flower("lilly_of_the_valley", "Lilly of the valley", "cg_decor_lotv.png")

minetest.register_node("cg_decor:sunflower", {
	description = "Sunflower",
	drawtype = "mesh",
	mesh = "cg_decor_sunflower.obj",
	tiles = { "cg_decor_sunflower.png" },
	inventory_image = "cg_decor_sunflower_inv.png",
	wield_image = "cg_decor_sunflower_inv.png",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	paramtype = "light",
	walkable = true,
	groups = {snappy=3,flammable=2,flower=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.1, -0.5, -0.1, 0.1, 1.6, 0.1 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -0.1, -0.5, -0.1, 0.1, 1.6, 0.1 },
	},
})

minetest.register_node("cg_decor:window_sill", {
	description = "Window sill",
	tiles = {"cg_decor_siding_wall.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.625, -0.625, -0.5625, 0.625, -0.4375, -0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.625, -0.625, 0.5, 0.625, -0.4375, 0.5625},
		}
	},
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("cg_decor:wall", {
	description = "Dryall",
	tiles = {"cg_decor_siding_wall.png"},
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

--------------------------------------------------------------------------------------------
-- Blocks ----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

if minetest.get_modpath("homedecor") then

end

local roof_list = {
	{"Red",           "#900000:150"},
	{"Green",         "#006500:200"},
	{"Dark_grey",     "#202020:200"},
	{"Silver",        "#b0b0b0:175"},
	{"Rusty",         "#ffffff:150"},
}

for i in ipairs(roof_list) do
	local desc = roof_list[i][1]
	local color = desc:lower()
	local value = roof_list[i][2]
	local extra = ""
	if color == "rusty" then extra = "^cg_decor_metalroof_overlay_rusty.png" end

	minetest.register_node("cg_decor:metal_roof_"..color, {
		description = "Metal Roof ("..desc..")",
		drawtype = "mesh",
		mesh = "cg_decor_metalroof.obj",
		tiles = {"(cg_decor_bg.png^[colorize:"..value..")^cg_decor_metalroof_overlay.png"..extra},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5,  -0.5, 0.5, -0.25, 0.5},
				{-0.5, -0.25, -0.25, 0.5,     0, 0.5},
				{-0.5,     0,     0, 0.5,  0.25, 0.5},
				{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5}
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5,  -0.5, 0.5, -0.25, 0.5},
				{-0.5, -0.25, -0.25, 0.5,     0, 0.5},
				{-0.5,     0,     0, 0.5,  0.25, 0.5},
				{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5}
			}
		},
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		on_place = minetest.rotate_node,
		sounds = default.node_sound_wood_defaults()
	})

	minetest.register_node("cg_decor:metal_roof_"..color.."_corner", {
		description = "Metal Roof Corner ("..desc..")",
		drawtype = "mesh",
		mesh = "cg_decor_metalroof_corner.obj",
		tiles = {"(cg_decor_bg.png^[colorize:"..value..")^cg_decor_metalroof_overlay.png"..extra},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5,  -0.5,   0.5, -0.25, 0.5},
				{-0.5, -0.25, -0.25,  0.25,     0, 0.5},
				{-0.5,     0,     0,     0,  0.25, 0.5},
				{-0.5,  0.25,  0.25, -0.25,   0.5, 0.5}
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5,  -0.5,  -0.5,   0.5, -0.25, 0.5},
				{-0.5, -0.25, -0.25,  0.25,     0, 0.5},
				{-0.5,     0,     0,     0,  0.25, 0.5},
				{-0.5,  0.25,  0.25, -0.25,   0.5, 0.5}
			}
		},
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		on_place = minetest.rotate_node,
		sounds = default.node_sound_wood_defaults()
	})

	minetest.register_node("cg_decor:metal_roof_"..color.."_valley", {
		description = "Metal Roof Valley ("..desc..")",
		drawtype = "mesh",
		mesh = "cg_decor_metalroof_valley.obj",
		tiles = {"(cg_decor_bg.png^[colorize:"..value..")^cg_decor_metalroof_overlay.png"..extra},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5,  -0.5,  0.5, -0.25, 0.5},
				{-0.5, -0.5, -0.25,  0.5,     0, 0.5},
				{-0.5, -0.5,  -0.5, 0.25,     0, 0.5},
				{-0.5,    0,  -0.5,    0,  0.25, 0.5},
				{-0.5,    0,     0,  0.5,  0.25, 0.5},
				{-0.5, 0.25,  0.25,  0.5,   0.5, 0.5},
				{-0.5, 0.25,  -0.5, -0.25,  0.5, 0.5},
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5,  -0.5,  0.5, -0.25, 0.5},
				{-0.5, -0.5, -0.25,  0.5,     0, 0.5},
				{-0.5, -0.5,  -0.5, 0.25,     0, 0.5},
				{-0.5,    0,  -0.5,    0,  0.25, 0.5},
				{-0.5,    0,     0,  0.5,  0.25, 0.5},
				{-0.5, 0.25,  0.25,  0.5,   0.5, 0.5},
				{-0.5, 0.25,  -0.5, -0.25,  0.5, 0.5},
			}
		},
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		on_place = minetest.rotate_node,
		sounds = default.node_sound_wood_defaults()
	})

minetest.register_node("cg_decor:metal_roof_"..color.."_flat", {
		description = "Metal Roof Flat ("..desc..")",
		drawtype = "mesh",
		mesh = "cg_decor_metalroof_flat.obj",
		tiles = {"(cg_decor_bg.png^[colorize:"..value..")^cg_decor_metalroof_overlay.png"..extra},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5,  -0.5,  0.5, -0.4, 0.5},
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5,  -0.5,  0.5, -0.4, 0.5},
			}
		},
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		on_place = minetest.rotate_node,
		sounds = default.node_sound_wood_defaults()
	})

end

minetest.register_craft({
	output = 'cg_decor:floor_block_white 4',
	recipe = {
		{'default:clay', 'default:clay'},
		{'default:clay', 'default:clay'},
	}
})

minetest.register_craft({
	output = 'cg_decor:tile_white 4',
	recipe = {
		{'cg_decor:floor_block_white', 'cg_decor:floor_block_white'},
		{'cg_decor:floor_block_white', 'cg_decor:floor_block_white'},
	}
})

local color_list = {
	{"Red",           "#900000:150"},
	{"Yellow",        "#f0f000:150"},
	{"Green",         "#005000:150"},
	{"Blue",          "#001080:175"},
	{"Violet",        "#500090:150"},
	{"Black",         "#000000:200"},
	{"Dark_grey",     "#202020:200"},
	{"Grey",          "#b0b0b0:175"},
	{"White",         "#ffffff:150"},
	{"Orange",        "#a04000:185"},
}

local ore_list = {
	{"coal"}, 
	{"iron"}, 
	{"copper"}, 
	{"mese"}, 
	{"gold"}, 
	{"diamond"}
}

for i in ipairs(color_list) do
	local desc = color_list[i][1]
	local color = desc:lower()
	local value = color_list[i][2]

	stairs.register_stair("carpeted_wood_"..color, "cg_decor:carpetblock_wood_"..color,
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"cg_decor_carpet.png^[colorize:"..value,
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")"},
		"Carpeted Wooden Stair",
		default.node_sound_defaults())

	stairs.register_slab("carpeted_wood_"..color, "cg_decor:carpetblock_wood_"..color,
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"cg_decor_carpet.png^[colorize:"..value,
		"default_wood.png",
		"default_wood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")",
		"default_wood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")",
		"default_wood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")",
		"default_wood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")"},
		"Carpeted Wooden Slab",
		default.node_sound_defaults())

	stairs.register_stair("carpeted_junglewood_"..color, "cg_decor:carpetblock_junglewood_"..color,
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"cg_decor_carpet.png^[colorize:"..value,
		"default_junglewood.png",
		"default_junglewood.png",
		"default_junglewood.png",
		"default_junglewood.png",
		"default_junglewood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")"},
		"Carpeted Wooden Stair",
		default.node_sound_defaults())

	stairs.register_slab("carpeted_junglewood_"..color, "cg_decor:carpetblock_junglewood_"..color,
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"cg_decor_carpet.png^[colorize:"..value,
		"default_junglewood.png",
		"default_junglewood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")",
		"default_junglewood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")",
		"default_junglewood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")",
		"default_junglewood.png^(cg_decor_carpet_overlay.png^[colorize:"..value..")"},
		"Carpeted Wooden Slab",
		default.node_sound_defaults())

	minetest.register_node("cg_decor:carpet_"..color, {
		description = "Carpet layer ("..desc..")",
		tiles = {"cg_decor_carpet.png^[colorize:"..value },
		paramtype = "light",
		drawtype = "nodebox",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.4875, 0.5
		}},
		groups = {choppy=2,oddly_breakable_by_hand=2,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("cg_decor:carpetblock_"..color, {
		description = "Carpet or drywall("..desc..")",
		tiles = {"cg_decor_carpet.png^[colorize:"..value, "cg_decor_siding_wall.png" },
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5125, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("cg_decor:carpetblock_wood_"..color, {
		description = "Carpet on Wood ("..desc..")",
		tiles = {"cg_decor_carpet.png^[colorize:"..value, "default_wood.png" },
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5125, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("cg_decor:carpetblock_junglewood_"..color, {
		description = "Carpet on Junglewood ("..desc..")",
		tiles = {"cg_decor_carpet.png^[colorize:"..value, "default_junglewood.png" },
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5125, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("cg_decor:siding_"..color, {
		description = "Siding "..desc,
		tiles = {"cg_decor_siding_top.png^[colorize:"..value, "cg_decor_siding_top.png^[colorize:"..value.."^[transformR180",
				 "cg_decor_siding.png^[colorize:"..value, "cg_decor_siding.png^[colorize:"..value, 
				 "cg_decor_siding_wall.png", "cg_decor_siding.png^[colorize:"..value},
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.5, -0.5, -0.375, 0.5, 0.5, 0.5},
					{-0.5, -0.459958, -0.4375, 0.5, -0.172287, -0.375},
					{-0.5, 0.203899, -0.4375, 0.5, 0.5, -0.375},
					{-0.5, -0.12803, -0.4375, 0.5, 0.165964, -0.375},
		}},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("cg_decor:siding_"..color.."_insidecorner", {
		description = "Siding inside corner"..desc,
		tiles = {"cg_decor_siding.png^[colorize:"..value, "cg_decor_siding.png^[colorize:"..value, 
				 "cg_decor_siding_wall.png", "cg_decor_siding.png^[colorize:"..value.."^(cg_decor_corner_overlay.png^[transformR180)",
				 "cg_decor_siding_wall.png", "cg_decor_siding.png^[colorize:"..value.."^cg_decor_corner_overlay.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_node("cg_decor:siding_"..color.."_corner", {
		description = "Siding corner "..desc,
		tiles = {"cg_decor_siding_corner_top.png^[colorize:"..value, "cg_decor_siding_corner_top.png^[colorize:"..value.."^[transformR270", 
				 "cg_decor_siding.png^[colorize:"..value.."^cg_decor_corner_overlay2.png",     "cg_decor_siding.png^[colorize:"..value.."^(cg_decor_corner_overlay.png^[transformR180)", 
				 "cg_decor_siding.png^[colorize:"..value.."^(cg_decor_corner_overlay2.png^[transformR180)",     "cg_decor_siding.png^[colorize:"..value.."^cg_decor_corner_overlay.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {{-0.375, -0.5, -0.375, 0.5, 0.5, 0.5},
					{-0.375, -0.459958, -0.4375, 0.5, -0.172287, -0.375},
					{-0.375, 0.203899, -0.4375, 0.5, 0.5, -0.375},
					{-0.375, -0.12803, -0.4375, 0.5, 0.165964, -0.375},
					{-0.4375, 0.203899, -0.4375, -0.375, 0.5, 0.5},
					{-0.4375, -0.12803, -0.4375, -0.375, 0.165964, 0.5},
					{-0.4375, -0.456797, -0.4375, -0.375, -0.172287, 0.5},
					{-0.5, -0.5, -0.5, -0.3125, 0.5, -0.375}, 
					{-0.5, -0.5, -0.5, -0.375, 0.5, -0.3125},
		}},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},
		groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})

	minetest.register_craft( {
		type = "shapeless",
		output = 'cg_decor:floor_block_'..color,
		recipe = { 'cg_decor:floor_block_white', 'dye:'..color},
	})

	minetest.register_craft( {
		type = "shapeless",
		output = 'cg_decor:tile_'..color,
		recipe = { 'cg_decor:tile_white', 'dye:'..color},
	})

	minetest.register_craft({
		output = 'cg_decor:tile_'..color..' 4',
		recipe = {
			{'cg_decor:floor_block_'..color, 'cg_decor:floor_block_'..color},
			{'cg_decor:floor_block_'..color, 'cg_decor:floor_block_'..color},
		}
	})

	minetest.register_node("cg_decor:floor_block_"..color, {
		description = desc.." Decrotive floor block",
		tiles = {"cg_decor_floor_block.png^[colorize:"..value},
		groups = {cracky=3, stone=1},
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_node("cg_decor:tile_"..color, {
		description = desc.." Decrotive tile",
		tiles = {"cg_decor_floor_tile.png^[colorize:"..value},
		groups = {cracky=3, stone=1},
		sounds = default.node_sound_stone_defaults(),
	})

	if minetest.get_modpath("stairs") then

		stairs.register_stair_and_slab("decor_block_"..color, "cg_decor:floor_block_"..color,
			{cracky=3},
			{"cg_decor_floor_block.png^[colorize:"..value},
			desc.." Decrotive floor block Stair",
			desc.." Decrotive floor block Slab",
			default.node_sound_stone_defaults())

		stairs.register_slab("decor_tile_"..color, "cg_decor:tile_"..color,
			{cracky=3},
			{"cg_decor_floor_tile.png^[colorize:"..value},
			desc.." Decrotive tile Slab",
			default.node_sound_stone_defaults())

	end

	for i in ipairs(ore_list) do
		local ore = ore_list[i][1]
		local craft_ore = ore.."_lump"
		if ore == "mese" then craft_ore = "mese_crystal" end

		minetest.register_node("cg_decor:tile_"..color.."_"..ore, {
			description = desc.." Decrotive "..ore.." tile",
			tiles = {"cg_decor_floor_tile.png^[colorize:"..value.."^default_mineral_"..ore..".png"},
			groups = {cracky=3, stone=1},
			sounds = default.node_sound_stone_defaults(),
		})

		if minetest.get_modpath("stairs") then

			stairs.register_slab("decor_tile_"..color.."_"..ore, "cg_decor:tile_"..color.."_"..ore,
				{cracky=3},
				{"cg_decor_floor_tile.png^[colorize:"..value.."^default_mineral_"..ore..".png"},
				desc.." Decrotive "..ore.." tile Slab",
				default.node_sound_stone_defaults())

		end

		minetest.register_craft( {
			type = "shapeless",
			output = 'cg_decor:tile_'..color..'_'..ore,
			recipe = {'cg_decor:tile_'..color, 'default:'..craft_ore},
		})
	end
end

--------------------------------------------------------------------------------------------
-- Fences ----------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

local material_list = {
	{"Steel",       "default_steel_block.png",   "default:steelblock"  },
	{"Copper",      "default_copper_block.png",  "default:copperblock" },
	{"Gold",        "default_gold_block.png",    "default:goldblock"   },
	{"Diamond",     "default_diamond_block.png", "default:diamondblock"},
	{"Mese",        "default_mese_block.png",    "default:mese"        },
	{"Bronze",      "default_bronze_block.png",  "default:bronzeblock" },
	{"Jungle_wood", "default_junglewood.png",    "default:junglewood"  },
	{"Acacia_wood", "default_acacia_wood.png",    "default:acaciawood"  },
	{"Obsidian",    "default_obsidian.png",      "default:obsidian"    },
}

for i in ipairs(material_list) do
	local desc = material_list[i][1]
	local material = desc:lower()
	local texture = material_list[i][2]
	local craft_material = material_list[i][3]

	minetest.register_node("cg_decor:fence_"..material, {
		description = desc.." Fence",
		drawtype = "fencelike",
		tiles = {texture},
		inventory_image = "default_fence_overlay.png^"..texture..
						  "^default_fence_overlay.png^[makealpha:255,126,126^cg_decor_fence_overlay.png",
		wield_image = "default_fence_overlay.png^"..texture..
					  "^default_fence_overlay.png^[makealpha:255,126,126^cg_decor_fence_overlay.png",
		paramtype = "light",
		is_ground_content = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
		},
		groups = {choppy=2,oddly_breakable_by_hand=2,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("steel") then -- register rusted steel fence if "steel" mod is loaded
	minetest.register_node("cg_decor:fence_steel_rusted", {
		description = "Rusted Steel Fence",
		drawtype = "fencelike",
		tiles = {"steel_rusted.png"},
		inventory_image = "default_fence_overlay.png^steel_rusted.png"..
						  "^default_fence_overlay.png^[makealpha:255,126,126^cg_decor_fence_overlay.png",
		wield_image = "default_fence_overlay.png^steel_rusted.png"..
					  "^default_fence_overlay.png^[makealpha:255,126,126^cg_decor_fence_overlay.png",
		paramtype = "light",
		is_ground_content = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/7, -1/2, -1/7, 1/7, 1/2, 1/7},
		},
		groups = {choppy=2,oddly_breakable_by_hand=2,flammable=2},
		sounds = default.node_sound_wood_defaults(),
	})
end

--------------------------------------------------------------------------------------------
-- Trees and bushes ------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

function cg_decor.register_tree(treename, tree_image, drop) --global tree register
	local drop_lg, drop_sm
	if drop and drop ~= "" then
		minetest.register_node("cg_decor:"..drop, {
			description = drop,
			drawtype = "plantlike",
			visual_scale = 0.8,
			tiles = {"cg_decor_"..drop..".png"},
			inventory_image = "cg_decor_"..drop..".png",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			is_ground_content = true,
			groups = {fleshy=3,dig_immediate=3,flammable=2,attached_node=1,not_in_creative_inventory=1},
			on_use = minetest.item_eat(1),
			selection_box = {
				type = "fixed",
				fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
			},
			sounds = default.node_sound_leaves_defaults()
		})
	end

	if not drop then 
		drop_sm = "cg_decor:"..treename.."_tree"
		drop_lg = "cg_decor:"..treename.."_tree_large"
	else
		drop_sm  = "cg_decor:"..drop.." 2"
		drop_lg  = "cg_decor:"..drop.." 4"
	end

	minetest.register_node("cg_decor:"..treename.."_tree", {
		description = treename.." tree",
		drawtype = "plantlike",
		visual_scale = 1.0,
		tiles = {tree_image},
		inventory_image = tree_image,
		wield_image = tree_image,
		paramtype = "light",
		walkable = false,
		is_ground_content = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("cg_decor:"..treename.."_tree_large", {
		description = "Large "..treename.." tree",
		drawtype = "plantlike",
		visual_scale = 1.5,
		tiles = {tree_image},
		inventory_image = tree_image,
		wield_image = tree_image,
		paramtype = "light",
		walkable = false,
		is_ground_content = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("cg_decor:"..treename.."_tree_extralarge", {
		description = "Extra large "..treename.." tree",
		drawtype = "plantlike",
		visual_scale = 1.9,
		tiles = {tree_image},
		inventory_image = tree_image,
		wield_image = tree_image,
		paramtype = "light",
		walkable = false,
		is_ground_content = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("cg_decor:"..treename.."_leaves", {
		drawtype = "mesh",
		mesh = "cg_decor_tree_leaves.obj",
		waving = 1,
		visual_scale = 1.5,
		tiles = {"cg_decor_"..treename.."_leaves.png"},
		paramtype = "light",
		walkable = false,
		climbable = true,
		is_ground_content = false,
		collision_box = {
			type = "fixed",
			fixed = {-0.2, -0.2, -0.2, 0.2, 0.5, 0.2}
		},
		groups = {snappy=3, leafdecay=2, flammable=2, leaves=1},
		drop = {
			max_items = 3,
			items = {{items = {drop_sm},}}
		},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("cg_decor:"..treename.."_leaves_large", {
		drawtype = "mesh",
		mesh = "cg_decor_tree_leaves.obj",
		waving = 1,
		visual_scale = 2.5,
		tiles = {"cg_decor_"..treename.."_leaves.png"},
		paramtype = "light",
		walkable = false,
		climbable = true,
		is_ground_content = false,
		groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
		drop = {
			max_items = 5,
			items = {{items = {drop_lg},}}
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.2, -0.2, -0.2, 0.2, 1.2, 0.2}
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}
		},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_abm({
		nodenames = {"cg_decor:"..treename.."_tree"},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			local nu =  minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
			local node2 = minetest.get_node({x = pos.x, y = pos.y+1, z = pos.z})
			local node3 = minetest.get_node({x = pos.x, y = pos.y+2, z = pos.z})
			local node4 = minetest.get_node({x = pos.x, y = pos.y+3, z = pos.z})
			local is_soil = minetest.get_item_group(nu, "soil")
			if is_soil == 0 then
				minetest.remove_node(pos)
				minetest.spawn_item(pos, "cg_decor:"..treename.."_tree")
				return
			end
	        if (node2.name == "air" or node2.name == "ignore") and (node3.name == "air" or node3.name == "ignore")
	        	and (node4.name == "air" or node4.name == "ignore") then
	        	minetest.add_node(pos, { name = "cg_decor:tree_trunk_base" })
	        	minetest.add_node({x = pos.x, y = pos.y+1, z = pos.z}, { name = "cg_decor:tree_trunk" })
	        	minetest.add_node({x = pos.x, y = pos.y+2, z = pos.z}, { name = "cg_decor:"..treename.."_leaves" })
	        else
	        	minetest.remove_node(pos)
				minetest.spawn_item(pos, "cg_decor:"..treename.."_tree")
	        	return
	        end
		end
	})

	minetest.register_abm({
		nodenames = {"cg_decor:"..treename.."_tree_large"},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			local nu =  minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
			local node2 = minetest.get_node({x = pos.x, y = pos.y+1, z = pos.z})
			local node3 = minetest.get_node({x = pos.x, y = pos.y+2, z = pos.z})
			local node4 = minetest.get_node({x = pos.x, y = pos.y+3, z = pos.z})
			local node5 = minetest.get_node({x = pos.x, y = pos.y+4, z = pos.z})
			local is_soil = minetest.get_item_group(nu, "soil")
			if is_soil == 0 then
				minetest.remove_node(pos)
				minetest.spawn_item(pos, "cg_decor:"..treename.."_tree_large")
				return
			end
	        if (node2.name == "air" or node2.name == "ignore") and (node3.name == "air" or node3.name == "ignore") 
	        	and (node4.name == "air" or node4.name == "ignore") and (node5.name == "air" or node5.name == "ignore") then
	        	minetest.add_node(pos, { name = "cg_decor:tree_trunk_base" })
	        	minetest.add_node({x = pos.x, y = pos.y+1, z = pos.z}, { name = "cg_decor:tree_trunk" })
	        	minetest.add_node({x = pos.x, y = pos.y+2, z = pos.z}, { name = "cg_decor:"..treename.."_leaves_large" })
	        else
	        	minetest.remove_node(pos)
				minetest.spawn_item(pos, "cg_decor:"..treename.."_tree_large")
	        	return
	        end
		end
	})

	minetest.register_abm({
		nodenames = {"cg_decor:"..treename.."_tree_extralarge"},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			local nu =  minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
			local node2 = minetest.get_node({x = pos.x, y = pos.y+1, z = pos.z})
			local node3 = minetest.get_node({x = pos.x, y = pos.y+2, z = pos.z})
			local node4 = minetest.get_node({x = pos.x, y = pos.y+3, z = pos.z})
			local node5 = minetest.get_node({x = pos.x, y = pos.y+4, z = pos.z})
			local node6 = minetest.get_node({x = pos.x, y = pos.y+5, z = pos.z})
			local is_soil = minetest.get_item_group(nu, "soil")
			if is_soil == 0 then
				minetest.remove_node(pos)
				minetest.spawn_item(pos, "cg_decor:"..treename.."_tree_extralarge")
				return
			end
	        if (node2.name == "air" or node2.name == "ignore") and (node3.name == "air" or node3.name == "ignore") 
	        	and (node4.name == "air" or node4.name == "ignore") and (node5.name == "air" or node5.name == "ignore") 
	        	and (node6.name == "air" or node6.name == "ignore") then
	        	minetest.add_node(pos, { name = "cg_decor:tree_trunk_base" })
	        	minetest.add_node({x = pos.x, y = pos.y+1, z = pos.z}, { name = "cg_decor:tree_trunk" })
	        	minetest.add_node({x = pos.x, y = pos.y+2, z = pos.z}, { name = "cg_decor:tree_trunk" })
	        	minetest.add_node({x = pos.x, y = pos.y+3, z = pos.z}, { name = "cg_decor:"..treename.."_leaves_large" })
	        else
	        	minetest.remove_node(pos)
				minetest.spawn_item(pos, "cg_decor:"..treename.."_tree_extralarge")
	        	return
	        end
		end
	})

end

--------------------------------------------------------------------------------------------

function cg_decor.register_bush(name, scale, drop) --global bush register
	if drop and drop ~= "" then
		minetest.register_node("cg_decor:"..drop, {
			description = drop,
			drawtype = "plantlike",
			visual_scale = 0.8,
			tiles = {"cg_decor_"..drop..".png"},
			inventory_image = "cg_decor_"..drop..".png",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			is_ground_content = true,
			groups = {fleshy=3,dig_immediate=3,flammable=2,attached_node=1,not_in_creative_inventory=1},
			on_use = minetest.item_eat(1),
			selection_box = {
				type = "fixed",
				fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
			},
			sounds = default.node_sound_leaves_defaults()
		})

	end
	if not drop then 
		drop = "cg_decor:"..name.."_bush"
	else
		drop = "cg_decor:"..drop.." 2"
	end

	minetest.register_node("cg_decor:"..name.."_bush", {
		description = "Large "..name.." Bush",
		drawtype = "mesh",
		mesh = "cg_decor_tree_leaves.obj",
		waving = 1,
		visual_scale = scale,
		tiles = {"cg_decor_"..name.."_leaves.png"},
		wield_image = "cg_decor_"..name.."_leaves.png",
		inventory_image = "cg_decor_"..name.."_leaves.png",
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, flammable=2},
		drop = {
			max_items = 2,
			items = {{items = {drop},}}
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.2, -0.2, -0.2, 0.2, 0.5, 0.2}
		},
		sounds = default.node_sound_leaves_defaults(),
	})

end

--------------------------------------------------------------------------------------------

cg_decor.register_tree("regular", "cg_decor_tree.png")
cg_decor.register_tree("dogwood", "cg_decor_dogwood_tree.png")
cg_decor.register_tree("japanese_maple", "cg_decor_jp_maple_tree.png")
cg_decor.register_tree("cherry", "cg_decor_cherry_tree.png", "cherry")
cg_decor.register_tree("crape_myrtle", "cg_decor_crape_myrtle_tree.png")
cg_decor.register_tree("african_tulip", "cg_decor_african_tulip_tree.png")

cg_decor.register_bush("regular", 1.5)
cg_decor.register_bush("blackberry", 1.5, "blackberry")

--------------------------------------------------------------------------------------------
-- Hydrangeas ------------------------------------------------------------------------------

local hydrangea_list = { --some colors are listed more than once to create a more realistic color pattern
	{"White",       "#ffffff:150"},
	{"purple",      "#5030a0:180"},
	{"Blue",        "#3060c0:200"},
	{"light pink",  "#f0a0a0:200"},
	{"White",       "#ffffff:150"},
	{"pink",        "#f06060:200"},
	{"light purple","#9070c0:150"},
	{"light blue",  "#80a0ff:170"},
	{"light pink",  "#f0a0a0:200"},
	{"light purple","#9070c0:150"},
	{"White",       "#ffffff:150"},
	{"light blue",  "#80a0ff:170"},
	{"dark purple", "#500090:200"},
	{"dark blue",   "#001080:200"}
}

for i in ipairs(hydrangea_list) do
	local value = hydrangea_list[i][2]
	local desc,desc_sm
	if i == 1 then 
		desc = "Hydrangea"
		desc_sm = "Hydrangea small"
	else 
		desc = ""
		desc_sm = "" 
	end
	minetest.register_node("cg_decor:hydrangea_bush"..i, {
		description = desc,
		drawtype = "mesh",
		mesh = "cg_decor_tree_leaves.obj",
		waving = 1,
		visual_scale = 1.5,
		tiles = {"cg_decor_leaves.png^(cg_decor_hydrangea.png^[colorize:"..value..")"},
		wield_image = "cg_decor_leaves.png^(cg_decor_hydrangea.png^[colorize:"..value..")",
		inventory_image = "cg_decor_leaves.png^(cg_decor_hydrangea.png^[colorize:"..value..")",
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, flammable=2},
		drop = {
			max_items = 2,
			items = {{items = {"cg_decor:hydrangea_bush1"},}}
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.2, -0.2, -0.2, 0.2, 0.5, 0.2}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			minetest.add_node(pos, { name = "cg_decor:hydrangea_bush"..math.random(1,14)})
		end,
	})

	minetest.register_node("cg_decor:hydrangea_bushsmall"..i, {
		description = desc_sm,
		drawtype = "mesh",
		mesh = "cg_decor_tree_leaves.obj",
		waving = 1,
		visual_scale = 0.8,
		tiles = {"cg_decor_leaves.png^(cg_decor_hydrangea.png^[colorize:"..value..")"},
		wield_image = "cg_decor_leaves.png^(cg_decor_hydrangea.png^[colorize:"..value..")",
		inventory_image = "cg_decor_leaves.png^(cg_decor_hydrangea.png^[colorize:"..value..")",
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, flammable=2},
		drop = {
			max_items = 2,
			items = {{items = {"cg_decor:hydrangea_bushsmall1"},}}
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.2, -0.2, -0.2, 0.2, 0.5, 0.2}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			minetest.add_node(pos, { name = "cg_decor:hydrangea_bushsmall"..math.random(1,14)})
		end,
	})
end

--------------------------------------------------------------------------------------------

minetest.register_node("cg_decor:tree_medium", {
	description = "Medium tree",
	drawtype = "plantlike",
	visual_scale = 1.6,
	tiles = {"cg_decor_tree.png"},
	inventory_image = "cg_decor_tree.png",
	wield_image = "cg_decor_tree.png",
	paramtype = "light",
	walkable = true,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, 1.0, 0.1}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, 1.0, 0.1}
	},
	groups = {snappy=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:tree_small", {
	description = "Small tree",
	drawtype = "plantlike",
	visual_scale = 1.3,
	tiles = {"cg_decor_tree.png"},
	inventory_image = "cg_decor_tree.png",
	wield_image = "cg_decor_tree.png",
	paramtype = "light",
	walkable = true,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, 0.7, 0.1}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, 0.7, 0.1}
	},
	groups = {snappy=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:tree_xsmall", {
	description = "Extra small tree",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"cg_decor_tree.png"},
	inventory_image = "cg_decor_tree.png",
	wield_image = "cg_decor_tree.png",
	paramtype = "light",
	walkable = true,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.05, -0.5, -0.05, 0.05, 0.2, 0.05}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.05, -0.5, -0.05, 0.05, 0.2, 0.05}
	},
	groups = {snappy=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

--tree trunk nodes

minetest.register_node("cg_decor:redwood_tree", {
	description = "Redwood Tree",
	tiles = {"cg_decor_redwood_tree_top.png", "cg_decor_redwood_tree_top.png", "cg_decor_redwood_tree.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,redwood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("cg_decor:tree_trunk", {
	drawtype = "mesh",
	mesh = "cg_decor_small_tree.obj",
	tiles = {"cg_decor_tree_trunk.png"},
	paramtype = "light",
	is_ground_content = true,
	climbable = true,
    selection_box = {
            type = "fixed",
            fixed = { -0.125, -0.5, -0.125, 0.125, 0.5, 0.125 },
    },
    collision_box = {
            type = "fixed",
            fixed = { -0.125, -0.5, -0.125, 0.125, 0.5, 0.125 },
    },
    drop = {
		max_items = 1,
		items = {{items = {'default:stick 2'},}}
	},
	groups = {snappy=3,flammable=2,leafdecay=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:tree_trunk_base", {
	drawtype = "mesh",
	mesh = "cg_decor_small_tree.obj",
	tiles = {"cg_decor_tree_trunk.png"},
	paramtype = "light",
	is_ground_content = true,
	climbable = true,
    selection_box = {
            type = "fixed",
            fixed = { -0.125, -0.5, -0.125, 0.125, 0.5, 0.125 },
    },
    collision_box = {
            type = "fixed",
            fixed = { -0.125, -0.5, -0.125, 0.125, 0.5, 0.125 },
    },
    drop = {
		max_items = 1,
		items = {{items = {'default:stick 2'},}}
	},
	groups = {snappy=3,flammable=2,tree=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:jungleleaves", {
	drawtype = "allfaces_optional",
	use_texture_alpha = true,
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_jungleleaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=5, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'cg_decor:jungleleaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:sapling_jungle", {
	description = "Jungle Sapling",
	drawtype = "plantlike",
	visual_scale = 1.5,
	tiles = {"cg_decor_junglesapling.png"},
	inventory_image = "cg_decor_junglesapling.png",
	wield_image = "cg_decor_junglesapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:sapling_redwood", {
	description = "Redwood Sapling",
	drawtype = "plantlike",
	visual_scale = 1.9,
	tiles = {"cg_decor_redwood_sapling.png"},
	inventory_image = "cg_decor_redwood_sapling.png",
	wield_image = "cg_decor_redwood_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:redwood_leaves", {
	description = "Redwood Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"cg_decor_redwood_leaves.png"},
	paramtype = "light",
	climbable = true,
	is_ground_content = false,
	groups = {snappy=3, rwldecay=6, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'cg_decor:sapling_redwood'},
				rarity = 500,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'cg_decor:redwood_leaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_node("cg_decor:leaves", {
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, leafdecay=4, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'cg_decor:leaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:sapling", {
	description = "Sapling",
	drawtype = "plantlike",
	visual_scale = 1.5,
	tiles = {"cg_decor_sapling.png"},
	inventory_image = "cg_decor_sapling.png",
	wield_image = "cg_decor_sapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("cg_decor:sapling_apple", {
	description = "Sapling",
	drawtype = "plantlike",
	visual_scale = 1.5,
	tiles = {"cg_decor_applesapling.png"},
	inventory_image = "cg_decor_applesapling.png",
	wield_image = "cg_decor_applesapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

--------------------------------------------------------------------------------------------

local air_node = minetest.get_content_id("air")
local ignore_node = minetest.get_content_id("ignore")
local tree_node = minetest.get_content_id("default:tree")
local jtree_node = minetest.get_content_id("default:jungletree")
local dleaf_node = minetest.get_content_id("default:leaves")
local leaf_node = minetest.get_content_id("cg_decor:leaves")
local jleaf_node = minetest.get_content_id("cg_decor:jungleleaves")
local djleaf_node = minetest.get_content_id("default:jungleleaves")
local apple_node = minetest.get_content_id("default:apple")

function cg_decor.grow_tree(data, a, pos, is_apple_tree)

    local height = math.random(8, 14)
    if is_apple_tree == true then height = 5 end  
    for x_area = -3, 3 do
    for y_area = -2, 3 do
    for z_area = -3, 3 do
        if math.random(1,30) < 23 and math.abs(x_area) + math.abs(z_area) < 5 
        	and math.abs(x_area) + math.abs(y_area) < 5 and math.abs(z_area) + math.abs(y_area) < 5 then  
            local area_l = a:index(pos.x+x_area, pos.y+height+y_area-1, pos.z+z_area)  
            if data[area_l] == air_node or data[area_l] == ignore_node then    
                if is_apple_tree and math.random(1, 50) <=  10 then  
                    data[area_l] = apple_node  
                else 
                    data[area_l] = leaf_node 
                end
            end
        end       
    end
    end
    end
    for tree_h = 0, height-1 do  
        local area_t = a:index(pos.x, pos.y+tree_h, pos.z)  
        if data[area_t] == air_node or data[area_t] == rleaf_node or data[area_t] == ignore_node
		or data[area_t] == leaf_node or data[area_t] == jleaf_node or data[area_t] == dleaf_node 
		or data[area_t] == djleaf_node or data[area_t] == apple_node then
            data[area_t] = tree_node   
        end
    end
end

function cg_decor.grow_jungletree(data, a, pos)
        
    local height = math.random(11, 20)
    for x_area = -5, 5 do
    for y_area = -4, 4 do
    for z_area = -5, 5 do
        if math.random(1,30) < 23 and math.abs(x_area) + math.abs(z_area) < 8  
        	and math.abs(x_area) + math.abs(y_area) < 8 and math.abs(z_area) + math.abs(y_area) < 8 then  
            local area_l = a:index(pos.x+x_area, pos.y+height+y_area-1, pos.z+z_area)  
            if data[area_l] == air_node or data[area_l] == ignore_node then   
                data[area_l] = jleaf_node 
            end  
        end       
    end
    end
    end
    for tree_h = 0, height-1 do  
        local area_t = a:index(pos.x, pos.y+tree_h, pos.z)  
        if data[area_t] == air_node or data[area_t] == rleaf_node or data[area_t] == ignore_node
		or data[area_t] == leaf_node or data[area_t] == jleaf_node or data[area_t] == dleaf_node 
		or data[area_t] == djleaf_node then    
            data[area_t] = jtree_node    
        end
    end
    for roots_x = -1, 1 do
    for roots_z = -1, 1 do
        if math.random(1, 3) >= 2 then 
            if a:contains(pos.x+roots_x, pos.y-1, pos.z+roots_z) and data[a:index(pos.x+roots_x, pos.y-1, pos.z+roots_z)] == air_node then
                data[a:index(pos.x+roots_x, pos.y-1, pos.z+roots_z)] = jtree_node
            elseif a:contains(pos.x+roots_x, pos.y, pos.z+roots_z) and data[a:index(pos.x+roots_x, pos.y, pos.z+roots_z)] == air_node then
                data[a:index(pos.x+roots_x, pos.y, pos.z+roots_z)] = jtree_node
            end
        end
    end
    end
end

function cg_decor.grow_redwood(data, a, pos)

    local rtree_node = minetest.get_content_id("cg_decor:redwood_tree")
	local rleaf_node = minetest.get_content_id("cg_decor:redwood_leaves")    
    local height = math.random(40, 60)
    local giant = math.random(1,72)
    if giant == (15 or 28) then --random giant redwoods
    	height = math.random(70, 90) 
    elseif giant == 36 then 
    	height = math.random(90, 120)
    end 
    for x_area = -8, 8 do
    for y_area = -12, 12 do
    for z_area = -8, 8 do
        if math.random(1,30) < 20 and math.abs(x_area) + math.abs(z_area) < 14  
        	and math.abs(x_area) + math.abs(y_area) < 17 and math.abs(z_area) + math.abs(y_area) < 17 then  
            local area_l = a:index(pos.x+x_area, pos.y+height+y_area-5, pos.z+z_area)  
            if data[area_l] == air_node or data[area_l] == ignore_node then 
            	if math.random(1, 30) >= 28 and math.abs(x_area)  < 5  
        		and math.abs(z_area) < 5 and math.abs(y_area) < 9 then
            		data[area_l] = rtree_node 
            	else
                	data[area_l] = rleaf_node 
                end
            end  
        end       
    end
    end
    end
    for tree_h = -5, height-1 do  
    	for x_dir = -1, 1 do
    	for z_dir = -1, 1 do
    		if math.abs(x_dir) + math.abs(z_dir) == 1 then 
		        local area_t = a:index(pos.x+x_dir, pos.y+tree_h, pos.z+z_dir)  
		        if data[area_t] == air_node or data[area_t] == rleaf_node or data[area_t] == ignore_node
		        or data[area_t] == leaf_node or data[area_t] == jleaf_node or data[area_t] == dleaf_node 
		        or data[area_t] == djleaf_node then   
		            data[area_t] = rtree_node    
		        end
		    elseif x_dir == 0 and z_dir == 0 and tree_h > 0 then
		    	local area_a = a:index(pos.x+x_dir, pos.y+tree_h, pos.z+z_dir) 
		        data[area_a] = air_node
		    end
		end
	    end
    end
    local area_tt = a:index(pos.x, pos.y+height, pos.z) 
	data[area_tt] = rtree_node
end

function cg_decor.can_grow_on(pos, type)
	local nu =  minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
	local is_type = minetest.get_item_group(nu, type)
	if is_type == 0 then
		return true
	end 
end

function cg_decor.add_tree_to_map(vm, data)
	vm:set_data(data)
	vm:write_to_map(data)
	vm:update_map()
end

minetest.register_abm({
	nodenames = {"cg_decor:sapling"},
	interval = 1,
	chance = 5,
	action = function(pos, node)
		cg_decor.can_grow_on(pos, "soil")
		minetest.remove_node(pos)
		minetest.log("action", "A decor sapling grows into a tree at "..minetest.pos_to_string(pos))
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map({x=pos.x-16, y=pos.y, z=pos.z-16}, {x=pos.x+16, y=pos.y+16, z=pos.z+16})
		local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
		local data = vm:get_data()
		cg_decor.grow_tree(data, a, pos, false)
		cg_decor.add_tree_to_map(vm, data)
	end
})

minetest.register_abm({
	nodenames = {"cg_decor:sapling_apple"},
	interval = 1,
	chance = 5,
	action = function(pos, node)
		cg_decor.can_grow_on(pos, "soil")
		minetest.remove_node(pos)
		minetest.log("action", "A decor apple sapling grows into a tree at "..minetest.pos_to_string(pos))
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map({x=pos.x-16, y=pos.y, z=pos.z-16}, {x=pos.x+16, y=pos.y+26, z=pos.z+16})
		local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
		local data = vm:get_data()
		cg_decor.grow_tree(data, a, pos, true)
		cg_decor.add_tree_to_map(vm, data)
	end
})

minetest.register_abm({
	nodenames = {"cg_decor:sapling_jungle"},
	interval = 1,
	chance = 5,
	action = function(pos, node)
		cg_decor.can_grow_on(pos, "soil")
		minetest.remove_node(pos)
		minetest.log("action", "A jungle decor sapling grows into a tree at "..minetest.pos_to_string(pos))
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map({x=pos.x-16, y=pos.y-1, z=pos.z-16}, {x=pos.x+16, y=pos.y+16, z=pos.z+16})
		local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
		local data = vm:get_data()
		cg_decor.grow_jungletree(data, a, pos)
		cg_decor.add_tree_to_map(vm, data)
	end
})

minetest.register_abm({
	nodenames = {"cg_decor:sapling_redwood"},
	interval = 1,
	chance = 5,
	action = function(pos, node)
		cg_decor.can_grow_on(pos, "soil")
		minetest.remove_node(pos)
		minetest.log("action", "A redwood sapling grows into a tree at "..minetest.pos_to_string(pos))
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map({x=pos.x-24, y=pos.y-7, z=pos.z-24}, {x=pos.x+24, y=pos.y+140, z=pos.z+24})
		local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
		local data = vm:get_data()
		cg_decor.grow_redwood(data, a, pos)
		cg_decor.add_tree_to_map(vm, data)
	end
})

minetest.register_abm({
	nodenames = {"group:rwldecay"},
	neighbors = {"air", "group:liquid"},
	interval = 5,
	chance = 2,
	action = function(pos, node, _, _)
		local pos1 = {x=pos.x, y=pos.y-1, z=pos.z}
		local node = minetest.get_node(pos)
		local node_under = minetest.get_node(pos1)
		local decay = minetest.registered_nodes[node.name].groups.rwldecay
		local nodes_around = minetest.find_node_near(pos, decay, {"ignore", "group:redwood"})
		if not decay or decay == 0 then
			return
		elseif decay ~= 1 and nodes_around then
			return
		else
		if  minetest.get_item_group(node_under.name, "rerwood") >= 1 then
			return
		else
			itemstacks = minetest.get_node_drops(node.name)
			for _, itemname in ipairs(itemstacks) do
				if itemname ~= node.name then
					local p_drop = {
						x = pos.x - 0.5 + math.random(),
						y = pos.y - 0.5 + math.random(),
						z = pos.z - 0.5 + math.random(),
					}
					minetest.add_item(p_drop, itemname)
				end
			end
			minetest.remove_node(pos)
			nodeupdate(pos)
		end
		end
	end
})