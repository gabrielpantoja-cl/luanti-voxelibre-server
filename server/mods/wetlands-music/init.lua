-- Wetlands Music - Custom music discs for Wetlands server
-- Author: Gabriel Pantoja
-- License: GPL v3.0

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Register custom music discs using VoxeLibre's jukebox API
-- mcl_jukebox.register_record(title, author, identifier, image, sound)

-- Wetlands Custom Disc 1: Karu Beats
mcl_jukebox.register_record(
	"Karu Beats",                          -- title
	"Wetlands Music Collection",           -- author
	"wetlands_karu_beats",                 -- identifier
	"wetlands_music_record_karu_beats.png", -- texture image
	"wetlands_music_karu_beats"            -- sound file (without .ogg extension)
)

minetest.log("action", "[wetlands_music] Mod loaded successfully with custom music discs")

-- Future discs can be registered here following the same pattern
-- Example:
-- mcl_jukebox.register_record(
--     "Disc Title",
--     "Artist Name",
--     "unique_identifier",
--     "wetlands_music_record_identifier.png",
--     "wetlands_music_sound_file"
-- )

-- Wetlands Custom Disc 2: Battleship
mcl_jukebox.register_record(
	"Battleship",                          -- title
	"Patrick de Arteaga",           -- author
	"wetlands_pvp_battle_2",                 -- identifier
	"wetlands_music_record_pvp_battle_2.png", -- texture image
	"pvp_battle_2"            -- sound file (without .ogg extension)
)

-- Wetlands Custom Disc 3: Intergalactic Odyssey
mcl_jukebox.register_record(
	"Intergalactic Odyssey",                          -- title
	"Patrick de Arteaga",           -- author
	"wetlands_pvp_battle_3",                 -- identifier
	"wetlands_music_record_pvp_battle_3.png", -- texture image
	"pvp_battle_3"            -- sound file (without .ogg extension)
)

-- Wetlands Custom Disc 4: Chase At Rush Hour
mcl_jukebox.register_record(
	"Chase At Rush Hour",                          -- title
	"Patrick de Arteaga",           -- author
	"wetlands_pvp_battle_4",                 -- identifier
	"wetlands_music_record_pvp_battle_4.png", -- texture image
	"pvp_battle_4"            -- sound file (without .ogg extension)
)
