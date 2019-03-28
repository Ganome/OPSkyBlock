
fluid_lib.register_extractor_node("fluid_transfer:fluid_transfer_pump", {
	description = "Fluid Transfer Pump\nPunch to start pumping",
	tiles = {"fluid_transfer_pump.png"},
	drawtype = "mesh",
	mesh = "fluid_transfer_pump.obj",
	groups = {oddly_breakable_by_hand = 1, cracky = 1},
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.4375, -0.5000, 0.4375, 0.4375, 0.000},
			{-0.1875, -0.1875, 0.000, 0.1875, 0.1875, 0.5000}
		}
	}
})

fluid_lib.register_transfer_node("fluid_transfer:fluid_duct", {
	description = "Fluid Duct",
	tiles = {"fluid_transfer_duct.png"},
	groups = {oddly_breakable_by_hand = 1, cracky = 1}
})

