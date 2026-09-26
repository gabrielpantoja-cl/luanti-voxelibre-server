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
    f:close()
  else
    -- shouldn't get here though :-/
    core.log("warning", "[mcl_custom_world_skins] skins.txt no encontrado en "..core.get_worldpath())
    return
  end

  -- Guard: deserialize() devuelve nil si el archivo esta en un encoding
  -- invalido (ej. UTF-16LE con BOM inyectado por redireccion de PowerShell).
  -- Sin este guard, ipairs(nil) en la linea 22 tiraba el init completo a
  -- ModError y el servidor entraba en crash-loop (INC-2026-09-26-001).
  if type(skins) ~= "table" then
    core.log("error", "[mcl_custom_world_skins] skins.txt no es deserializable (formato/encoding invalido). "
      .."Verifica que sea UTF-8 sin BOM. Cargando 0 skins custom.")
    return
  end

  for _, skin in ipairs(skins) do
    process_skin(skin)
  end
end

if mcl_skins_enabled then
  init_simple_skins()
end
