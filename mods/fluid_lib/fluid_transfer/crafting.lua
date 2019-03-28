
-- Duct
minetest.register_craft({
	output = "fluid_transfer:fluid_duct 8",
	recipe = {
		{"default:glass",  "default:glass",  "default:glass"},
		{"", "", ""},
		{"default:glass",  "default:glass",  "default:glass"},
	}
})

-- Pump
minetest.register_craft({
	output = "fluid_transfer:fluid_transfer_pump",
	recipe = {
		{"",  "fluid_transfer:fluid_duct",  ""},
		{"default:glass", "default:mese_crystal", "default:glass"},
		{"default:stone",  "default:stone",  "default:stone"},
	}
})
