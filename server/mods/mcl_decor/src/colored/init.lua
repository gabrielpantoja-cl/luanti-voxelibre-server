-- mcl_decor/src/colored/init.lua

local S, include = ...

local colors = {
	white = {
		wooltile = "wool_white",
		armchair_desc = S("White Armchair"),
		curtains_desc = S("White Curtains"),
		planks_desc = S("White Planks"),
		fence_desc = S("White Fence"),
		fence_gate_desc = S("White Fence Gate"),
		dye = "white",
		colorgroup = "unicolor_white",
		hexcolor = "#D0D6D7",
	},
	grey = {
		wooltile = "wool_dark_grey",
		armchair_desc = S("Grey Armchair"),
		curtains_desc = S("Grey Curtains"),
		planks_desc = S("Grey Planks"),
		fence_desc = S("Grey Fence"),
		fence_gate_desc = S("Grey Fence Gate"),
		dye = "dark_grey",
		colorgroup = "unicolor_darkgrey",
		hexcolor = "#383B40"
	},
	silver = {
		wooltile = "wool_grey",
		armchair_desc = S("Light Grey Armchair"),
		curtains_desc = S("Light Grey Curtains"),
		planks_desc = S("Light Grey Planks"),
		fence_desc = S("Light Grey Fence"),
		fence_gate_desc = S("Light Grey Fence Gate"),
		dye = "grey",
		colorgroup = "unicolor_grey",
		hexcolor = "#808176"
	},
	black = {
		wooltile = "wool_black",
		armchair_desc = S("Black Armchair"),
		curtains_desc = S("Black Curtains"),
		planks_desc = S("Black Planks"),
		fence_desc = S("Black Fence"),
		fence_gate_desc = S("Black Fence Gate"),
		dye = "black",
		colorgroup = "unicolor_black",
		hexcolor = "#080A0F"
	},
	red = {
		wooltile = "wool_red",
		armchair_desc = S("Red Armchair"),
		curtains_desc = S("Red Curtains"),
		planks_desc = S("Red Planks"),
		fence_desc = S("Red Fence"),
		fence_gate_desc = S("Red Fence Gate"),
		dye = "red",
		colorgroup = "unicolor_red",
		hexcolor = "#922222"
	},
	yellow = {
		wooltile = "wool_yellow",
		armchair_desc = S("Yellow Armchair"),
		curtains_desc = S("Yellow Curtains"),
		planks_desc = S("Yellow Planks"),
		fence_desc = S("Yellow Fence"),
		fence_gate_desc = S("Yellow Fence Gate"),
		dye = "yellow",
		colorgroup = "unicolor_yellow",
		hexcolor = "#F1B115"
	},
	green = {
		wooltile = "wool_dark_green",
		armchair_desc = S("Green Armchair"),
		curtains_desc = S("Green Curtains"),
		planks_desc = S("Green Planks"),
		fence_desc = S("Green Fence"),
		fence_gate_desc = S("Green Fence Gate"),
		dye = "dark_green",
		colorgroup = "unicolor_dark_green",
		hexcolor = "#4B5E25"
	},
	cyan = {
		wooltile = "wool_cyan",
		armchair_desc = S("Cyan Armchair"),
		curtains_desc = S("Cyan Curtains"),
		planks_desc = S("Cyan Planks"),
		fence_desc = S("Cyan Fence"),
		fence_gate_desc = S("Cyan Fence Gate"),
		dye = "cyan",
		colorgroup = "unicolor_cyan",
		hexcolor = "#157B8C"
	},
	blue = {
		wooltile = "wool_blue",
		armchair_desc = S("Blue Armchair"),
		curtains_desc = S("Blue Curtains"),
		planks_desc = S("Blue Planks"),
		fence_desc = S("Blue Fence"),
		fence_gate_desc = S("Blue Fence Gate"),
		dye = "blue",
		colorgroup = "unicolor_blue",
		hexcolor = "#2E3093"
	},
	magenta = {
		wooltile = "wool_magenta",
		armchair_desc = S("Magenta Armchair"),
		curtains_desc = S("Magenta Curtains"),
		planks_desc = S("Magenta Planks"),
		fence_desc = S("Magenta Fence"),
		fence_gate_desc = S("Magenta Fence Gate"),
		dye = "magenta",
		colorgroup = "unicolor_red_violet",
		hexcolor = "#AB31A2"
	},
	orange = {
		wooltile = "wool_orange",
		armchair_desc = S("Orange Armchair"),
		curtains_desc = S("Orange Curtains"),
		planks_desc = S("Orange Planks"),
		fence_desc = S("Orange Fence"),
		fence_gate_desc = S("Orange Fence Gate"),
		dye = "orange",
		colorgroup = "unicolor_orange",
		hexcolor = "#E26501"
	},
	purple = {
		wooltile = "wool_violet",
		armchair_desc = S("Purple Armchair"),
		curtains_desc = S("Purple Curtains"),
		planks_desc = S("Purple Planks"),
		fence_desc = S("Purple Fence"),
		fence_gate_desc = S("Purple Fence Gate"),
		dye = "violet",
		colorgroup = "unicolor_violet",
		hexcolor = "#67209F"
	},
	brown = {
		wooltile = "wool_brown",
		armchair_desc = S("Brown Armchair"),
		curtains_desc = S("Brown Curtains"),
		planks_desc = S("Brown Planks"),
		fence_desc = S("Brown Fence"),
		fence_gate_desc = S("Brown Fence Gate"),
		dye = "brown",
		colorgroup = "unicolor_dark_orange",
		hexcolor = "#623C20"
	},
	pink = {
		wooltile = "wool_pink",
		armchair_desc = S("Pink Armchair"),
		curtains_desc = S("Pink Curtains"),
		planks_desc = S("Pink Planks"),
		fence_desc = S("Pink Fence"),
		fence_gate_desc = S("Pink Fence Gate"),
		dye = "pink",
		colorgroup = "unicolor_light_red",
		hexcolor = "#D56790"
	},
	lime = {
		wooltile = "mcl_wool_lime",
		armchair_desc = S("Lime Armchair"),
		curtains_desc = S("Lime Curtains"),
		planks_desc = S("Lime Planks"),
		fence_desc = S("Lime Fence"),
		fence_gate_desc = S("Lime Fence Gate"),
		dye = "green",
		colorgroup = "unicolor_green",
		hexcolor = "#60AB19"
	},
	light_blue = {
		wooltile = "mcl_wool_light_blue",
		armchair_desc =  S("Light Blue Armchair"),
		curtains_desc =  S("Light Blue Curtains"),
		planks_desc =  S("Light Blue Planks"),
		fence_desc = S("Light Blue Fence"),
		fence_gate_desc = S("Light Blue Fence Gate"),
		dye =  "lightblue",
		colorgroup = "unicolor_light_blue",
		hexcolor = "#258CC8",
	},
}

local files = {
	"armchairs",
	"curtains",
	"dyed_wood",
}

for color, tbl in pairs(colors) do
	include(files, {"src", "colored"}, color, tbl, S)
end
