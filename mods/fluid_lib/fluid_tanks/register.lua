
fluid_tanks.register_tank("fluid_tanks:tank", {
	description = "Fluid Tank",
	capacity = 8000,
	accepts = true,
})

minetest.register_craft({
	output = "fluid_tanks:tank",
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "default:steel_ingot", "default:glass"},
		{"default:glass", "default:glass", "default:glass"},
	}
})
