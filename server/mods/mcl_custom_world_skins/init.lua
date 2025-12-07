local mcl_skins_enabled = core.settings:get_bool("mcl_enable_skin_customization", true)

local function process_skin(skin)
  local name  = skin.texture .. ".png"
  mcl_skins.register_simple_skin({
    texture = name,
    slim_arms = skin and skin.gender == "female",
  })
end

local function init_simple_skins()
  local f = io.open(core.get_worldpath().."/skins.txt", "r")
  local skins

  if f then
    skins = core.deserialize(f:read("*all"))
  else
    -- shouldn't get here though :-/
    return
  end

  for _, skin in ipairs(skins) do
    process_skin(skin)
  end
end

if mcl_skins_enabled then
  init_simple_skins()
end
