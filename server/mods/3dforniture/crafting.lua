--[[
   3D Forniture
   
   Copyright 2012 Tonyka
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
   Contributors:

    InfinityProject

        suggested creating bathroom kit.

    cosarara97

        code.
   
]]--

-- Deco Home

	--Table
	minetest.register_craft( {
		output = '3dforniture:table', '3dforniture:chair 2',
		recipe = {
			{ 'mcl_core:wood','mcl_core:wood', 'mcl_core:wood' },
			{ 'mcl_core:stick', '', 'mcl_core:stick' },
		},
	})

	minetest.register_craft({
		type = 'fuel',
		recipe = '3dforniture:table',
		burntime = 30,
	})

	--Chair
	minetest.register_craft( {
		output = '3dforniture:chair 2',
		recipe = {
			{ 'mcl_core:stick',''},
			{ 'mcl_core:wood','mcl_core:wood' },
			{ 'mcl_core:stick','mcl_core:stick' },
		},
	})

	minetest.register_craft({
		type = 'fuel',
		recipe = '3dforniture:chair',
		burntime = 15,
	})

	--Armchair
	minetest.register_craft( {
		output = '3dforniture:armchair 2',
		recipe = {
			{ 'mcl_core:wood',''},
			{ 'mcl_core:wood','mcl_core:wood' },
			{ 'mcl_core:wood','mcl_core:wood' },
		},
	})

	minetest.register_craft({
		type = 'fuel',
		recipe = '3dforniture:armchair',
		burntime = 30,
	})

	--Table Lamp
	minetest.register_craft( {
		output = '3dforniture:table_lamp_off',
		recipe = {
			{'mcl_core:paper','mcl_torches:torch' ,'mcl_core:paper'},
			{'','mcl_core:stick',''},
			{'','mcl_stairs:slab_wood',''},
		},
	})

	minetest.register_craft({
		type = 'fuel',
		recipe = '3dforniture:table_lamp_off',
		burntime = 10,
	})

	-- Bathroom Kit

		--Toilet
		minetest.register_craft( {
			output = '3dforniture:toilet',
			recipe = {
				{'','','mcl_buckets:bucket_water'},
				{ 'mcl_core:cobble','mcl_core:cobble', 'mcl_core:cobble' },
				{ '', 'mcl_buckets:bucket_empty', '' },
			},
		})

		--Sink
		minetest.register_craft( {
			output = '3dforniture:sink',
			recipe = {
				{ 'mcl_core:cobble','mcl_buckets:bucket_empty', 'mcl_core:cobble' },
			},
		})

		--Taps
		minetest.register_craft( {
			output = '3dforniture:taps',
			recipe = {
				{ 'mcl_core:iron_ingot','mcl_buckets:bucket_water', 'mcl_core:iron_ingot' },
			},
		})

		--Shower Tray
		minetest.register_craft( {
			output = '3dforniture:shower_tray',
			recipe = {
				{ 'mcl_core:cobble','mcl_buckets:bucket_water', 'mcl_core:cobble' },
			},
		})

		--Shower Head
		minetest.register_craft( {
			output = '3dforniture:shower_head',
			recipe = {
				{'mcl_core:iron_ingot', 'mcl_buckets:bucket_water'},
			},
		})

-- Medieval Forniture

	--Bars
	minetest.register_craft( {
		output = '3dforniture:bars 10',
		recipe = {
			{ 'mcl_core:iron_ingot','mcl_core:iron_ingot','mcl_core:iron_ingot' },
			{ 'mcl_core:iron_ingot','mcl_core:iron_ingot','mcl_core:iron_ingot' },
		},
	})

	-- L Binding Bars
	minetest.register_craft( {
		output = '3dforniture:L_binding_bars 4',
		recipe = {
			{ '3dforniture:bars','' },
			{ '3dforniture:bars','3dforniture:bars' },
		},
	})

	--Chains
	minetest.register_craft( {
		output = '3dforniture:chains 4',
		recipe = {
			{'','mcl_core:iron_ingot',''},
			{ 'mcl_core:iron_ingot','', 'mcl_core:iron_ingot' },
			{ '', 'mcl_core:iron_ingot', '' },
		},
	})

	--Torch Wall
	minetest.register_craft( {
		output = '3dforniture:torch_wall 10',
		recipe = {
			{ 'mcl_core:coal_lump' },
			{ 'mcl_core:iron_ingot' },
		},
	})
