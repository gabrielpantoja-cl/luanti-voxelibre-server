-- Wetlands Music - Custom music discs for Wetlands server
-- Author: Gabriel Pantoja
-- License: GPL v3.0
-- Version: 2.0.0
--
-- This mod integrates custom music discs into VoxeLibre's jukebox system
-- All music files are in .ogg format and textures are 16x16 PNG files
-- Compatible with VoxeLibre (MineClone2) mcl_jukebox API

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- VoxeLibre jukebox API documentation:
-- mcl_jukebox.register_record(title, author, identifier, image, sound)
-- Parameters:
--   title: Display name of the music disc
--   author: Artist/composer name
--   identifier: Unique identifier for the disc item
--   image: Texture filename (16x16 PNG recommended)
--   sound: Sound filename WITHOUT .ogg extension

minetest.log("action", "[wetlands_music] Registering custom music discs...")

-- Disc 1: Dinosaur Spirit
mcl_jukebox.register_record(
	"Dinosaur Spirit",
	"Wetlands Music Collection",
	"wetlands_dinosaur_spirit",
	"wetlands_music_dinosaur_spirit.png",
	"wetlands_music_dinosaur_spirit"
)

-- Disc 2: Gagaga Song
mcl_jukebox.register_record(
	"Gagaga Song",
	"Wetlands Music Collection",
	"wetlands_gagaga_song",
	"wetlands_music_gagaga_song.png",
	"wetlands_music_gagaga_song"
)

-- Disc 3: Groovy Goblins
mcl_jukebox.register_record(
	"Groovy Goblins",
	"Wetlands Music Collection",
	"wetlands_groovy_goblins",
	"wetlands_music_groovy_goblins.png",
	"wetlands_music_groovy_goblins"
)

-- Disc 4: Princess
mcl_jukebox.register_record(
	"Princess",
	"Wetlands Music Collection",
	"wetlands_princess",
	"wetlands_music_princess.png",
	"wetlands_music_princess"
)

-- Disc 5: PvP Battle 2 - Battleship
mcl_jukebox.register_record(
	"Battleship",
	"Patrick de Arteaga",
	"wetlands_pvp_battle_2",
	"wetlands_music_record_pvp_battle_2.png",
	"wetlands_music_pvp_battle_2"
)

-- Disc 6: PvP Battle 4 - Chase At Rush Hour
mcl_jukebox.register_record(
	"Chase At Rush Hour",
	"Patrick de Arteaga",
	"wetlands_pvp_battle_4",
	"wetlands_music_pvp_battle_4.png",
	"wetlands_music_pvp_battle_4"
)

-- Disc 7: Rock City Ransom
mcl_jukebox.register_record(
	"Rock City Ransom",
	"Wetlands Music Collection",
	"wetlands_rock_city_ransom",
	"wetlands_music_rock_city_ransom.png",
	"wetlands_music_rock_city_ransom"
)

-- Disc 8: Warp Zone
mcl_jukebox.register_record(
	"Warp Zone",
	"Wetlands Music Collection",
	"wetlands_warp_zone",
	"wetlands_music_warp_zone.png",
	"wetlands_music_warp_zone"
)

-- Disc 9: Youthful Elf
mcl_jukebox.register_record(
	"Youthful Elf",
	"Wetlands Music Collection",
	"wetlands_youthful_elf",
	"wetlands_music_youthful_elf.png",
	"wetlands_music_youthful_elf"
)

minetest.log("action", "[wetlands_music] Successfully registered 9 custom music discs")

-- Note: pvp_battle_3 (Intergalactic Odyssey) was removed as the sound file doesn't exist
-- To add new discs:
-- 1. Add .ogg file to sounds/ directory
-- 2. Add 16x16 PNG texture to textures/ directory
-- 3. Register using mcl_jukebox.register_record() following the pattern above