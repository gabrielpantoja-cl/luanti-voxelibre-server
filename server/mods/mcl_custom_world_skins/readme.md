# VoxeLibre Custom World Skins

This is a skin mod for VoxeLibre (formerly MineClone2).  It allows server admins to upload and configure custom player skins in the world folder instead of a mod or game folder.  This is so updates to mods or games won't overwrite custom skins.  I created it because my kids wanted custom skins on our home server.

This depends on `_world_folder_media` and VoxeLibre. 


## First time usage

  1. Enable this mod and world folder media for the world.
  1. Start and stop the server so that world folder media will initialize.  

## Adding Textures

  1. Upload a 64x32 png texures to `<my_world>/_world_folder_media/textures`
  2. Create or update a skins.txt file in the the `<my_world>` folder to configure the skins.  Here's an example: 

```
return {
  {
    texture = "kitty_mt",
    gender = "female"
  },
  {
    texture = "drowned_mt",
    gender = "male"
  },
  {
    texture = "panda1_mt",
    gender = "female"
  }
}
```

In texture = "name", the "name" must be the name of the texture file without the .png file extension.

## Using 64x64 Skins

If you are getting MineCraft skins from somewhere like: https://www.minecraftskins.com/ you'll need to convert them.  Minecraft skins are 64x64 and VoxeLibre only supports 64x32.

You can convert using this tool: https://godly.github.io/minetest-skin-converter/ which will copy the lower half of the texture onto the texture.

Here's the git repo for the above url: https://github.com/godly/minetest-skin-converter
