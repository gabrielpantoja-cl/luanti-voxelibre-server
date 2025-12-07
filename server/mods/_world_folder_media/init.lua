local function load_world_folder()
    local wrld_dir = minetest.get_worldpath() .. "/_world_folder_media"
    local sounds_dir = wrld_dir .. "/sounds"
    local tex_dir = wrld_dir .. "/textures"

    local content = minetest.get_dir_list(wrld_dir)
    local modpath = minetest.get_modpath("_world_folder_media")
  
    if not next(content) then
      local src_dir = modpath .. "/IGNOREME"
      minetest.cpdir(src_dir, wrld_dir)
      os.remove(wrld_dir .. "/README.md")  
    else
      local function iterate_dirs(dir)
        for _, f_name in pairs(minetest.get_dir_list(dir, false)) do
            if f_name ~= "sounds_here.txt" and f_name ~= "textures_here.txt" then
                minetest.dynamic_add_media({filepath = dir .. "/" .. f_name}, function(name) end) -- not really dynamic media, hehe
            end
        end
        for _, subdir in pairs(minetest.get_dir_list(dir, true)) do
          iterate_dirs(dir .. "/" .. subdir)
        end
      end
  
      -- dynamic media can't be added when the server starts
      minetest.after(0.1, function()
        iterate_dirs(sounds_dir)
        iterate_dirs(tex_dir)
      end)
    end
end
  
  load_world_folder()
