core.register_node("mypark:swings",{
	description = "Swings",
	tiles = {"mypark_swings.png"},
	drawtype = "mesh",
	mesh = "mypark_swings.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1, -0.5, -0.5, -0.9, 2, 0.5},
			{0.9, -0.5, -0.5, 1, 2, 0.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1, -0.5, -0.5, -0.9, 2, 0.5},
			{0.9, -0.5, -0.5, 1, 2, 0.5}
		}
	},
})
core.register_node("mypark:bench",{
	description = "Bench",
	tiles = {"mypark_bench.png"},
	drawtype = "mesh",
	mesh = "mypark_bench.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 1, 0, 0.4},
			{-0.5, 0, 0.15, 1, 0.5, 0.4}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 1, 0, 0.4},
			{-0.5, 0, 0.15, 1, 0.5, 0.4}
		}
	},
})
core.register_node("mypark:birdbath",{
	description = "Birdbath",
	tiles = {"mypark_birdbath.png"},
	drawtype = "mesh",
	mesh = "mypark_birdbath.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.35, -0.5, -0.35, 0.35, 0.25, 0.35}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.35, -0.5, -0.35, 0.35, 0.25, 0.35}
		}
	},
})
core.register_node("mypark:sign",{
	description = "Park Sign",
	tiles = {"mypark_sign.png"},
	drawtype = "mesh",
	mesh = "mypark_sign.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.05, 0.5, 0.25, 0.15}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.05, 0.5, 0.25, 0.15}
		}
	},
})
core.register_node("mypark:pond",{
	description = "Pond",
	tiles = {"mypark_pond.png"},
	drawtype = "mesh",
	mesh = "mypark_pond.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, -0.4, 1.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, -0.4, 1.5}
		}
	},
})
core.register_node("mypark:pond2",{
	description = "Pond 2",
	tiles = {"mypark_pond2.png"},
	drawtype = "mesh",
	mesh = "mypark_pond2.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, -0.4, 1.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, -0.4, 1.5}
		}
	},
})
core.register_node("mypark:slide",{
	description = "Slide",
	tiles = {"mypark_slide.png"},
	drawtype = "mesh",
	mesh = "mypark_slide.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		}
	},
})
core.register_node("mypark:sandbox",{
	description = "Sandbox",
	tiles = {"mypark_sandbox.png"},
	drawtype = "mesh",
	mesh = "mypark_sandbox.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, 1, 1.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, 1, 1.5}
		}
	},
})
core.register_node("mypark:fountain",{
	description = "Fountain",
	tiles = {"mypark_fountain.png"},
	drawtype = "mesh",
	mesh = "mypark_fountain.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, 1, 1.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, 1, 1.5}
		}
	},
})
core.register_node("mypark:fence",{
	description = "Fence",
	tiles = {"mypark_fence.png"},
	drawtype = "mesh",
	mesh = "mypark_fence.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45}
		}
	},
})
core.register_node("mypark:fence_corner",{
	description = "Fence Corner",
	tiles = {"mypark_fence.png"},
	drawtype = "mesh",
	mesh = "mypark_fence_corner.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45},
			{0.5, -0.5, -0.5, 0.45, 0.5, 0.5}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45},
			{0.5, -0.5, -0.5, 0.45, 0.5, 0.5}
		}
	},
})
core.register_node("mypark:fence_icorner",{
	description = "Fence Inside Corner",
	tiles = {"mypark_fence.png"},
	drawtype = "mesh",
	mesh = "mypark_fence_icorner.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{0.5, -0.5, 0.5, 0.45, 0.5, 0.45}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{0.5, -0.5, 0.5, 0.45, 0.5, 0.45}
		}
	},
})
core.register_node("mypark:fence_gate",{
	description = "Fence Gate",
	tiles = {"mypark_fence.png"},
	drawtype = "mesh",
	mesh = "mypark_fence_gate.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, -0.3, 1.5, 0.45},
			{1.5, -0.5, 0.5, 1.3, 1.5, 0.45},
			{-0.5, 1.2, 0.5, 1.5, 1.5, 0.45},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, -0.3, 1.5, 0.45},
			{1.5, -0.5, 0.5, 1.3, 1.5, 0.45},
		}
	},
})
if core.get_modpath("lucky_block") then
	lucky_block:add_blocks({
		{"dro", {"mypark:swings"}, 1},
		{"dro", {"mypark:bench"}, 1},
		{"dro", {"mypark:birdbath"}, 1},
		{"dro", {"mypark:sign"}, 1},
		{"dro", {"mypark:pond"}, 1},
		{"dro", {"mypark:pond2"}, 1},
		{"dro", {"mypark:slide"}, 1},
		{"dro", {"mypark:sandbox"}, 1},
		{"dro", {"mypark:fountain"}, 1},
	})
end
