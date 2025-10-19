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
