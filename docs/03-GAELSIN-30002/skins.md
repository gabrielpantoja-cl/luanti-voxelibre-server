# Custom Skins — GAELSIN

Skins personalizadas disponibles en el menú `/skin` de los jugadores del mundo
**GAELSIN (puerto 30002)**. Habilitado desde **2026-07-26**.

A diferencia de Wetlands, este mundo no tiene todas las skins — el set es el
mínimo que el admin copió explícitamente. La lista autoritativa vive en
`server/worlds/gaelsin/skins.txt` (gitignored, vive en el VPS) y los PNG en
`server/worlds/gaelsin/_world_folder_media/textures/` (idem).

## Cómo funciona

Dos mods cooperan (ver jerarquía en
[`docs/00-SHARED/config/01-CONFIGURATION_HIERARCHY.md`](../00-SHARED/config/01-CONFIGURATION_HIERARCHY.md)):

| Mod | Función |
|-----|---------|
| `_world_folder_media` (MisterE) | Permite que el servidor lea texturas y sonidos desde la carpeta del mundo (`_world_folder_media/`) |
| `mcl_custom_world_skins` (covertiii) | En el arranque, lee `skins.txt` del worldpath y registra cada entrada vía `mcl_skins.register_simple_skin()` |

Gate primario (autoritativo):
`server/worlds/gaelsin/world.mt:30` → `load_mod_mcl_custom_world_skins = true`.

Gate secundario (default):
`server/config/luanti-gaelsin.conf:135` → `load_mod_mcl_custom_world_skins = true`.

> El mod **no loguea** en `init.lua` cuando registra skins correctamente.
> Verificación: que `skins.txt` exista y que el server arranque sin errores
> referidos al mod. In-game: las skins aparecen en `/skin`.

## Skins pobladas

11 skins, todas `gender = "male"`. Marcas de procesamiento:

- **↻ crop** = `PIL.Image.crop((0,0,64,32))` — solo capa base, **sin overlay**
  (puede dejar la skin incompleta si tiene armadura/casco/capa en el original)
- **✓ godly** = procesado con [godly Minetest Skin Converter](#1-convertir-el-png)
  — incluye overlays (armadura, capa, mangas) horneados en la capa base

| # | texture (`skins.txt`) | gender | Origen | Tamaño PNG | Notas |
|---|-----------------------|--------|--------|------------|-------|
| 1 | `zombie` | male | Wetlands | 1395 B | clon directo |
| 2 | `buddhist_monk` | male | Wetlands | 1009 B | clon directo |
| 3 | `ninja_boxy` | male | Wetlands | 492 B | clon directo |
| 4 | `panda` | male | Wetlands | 319 B | clon directo |
| 5 | `santa_ho_ho_ho` | male | Wetlands | 1032 B | estacional (navidad) |
| 6 | `pepe` | male | Wetlands | 1017 B | clon directo |
| 7 | `lloyd_possesion_suit` | male | Wetlands | 2364 B | clon directo |
| 8 | `indie_boy` | male | MinecraftSkins | 637 B | ↻ crop (sin overlay visible) |
| 9 | `wetlands_npc_luke` | male | `wetlands_npcs/textures/` | 824 B | textura del NPC Luke reutilizada como skin de jugador |
| 10 | `mandalorian` | male | MinecraftSkins | 2048 B | ✓ godly (re-procesado 2026-07-26 — la versión ↻ crop quedó como `.lossy.bak`) |
| 11 | `diamond_armor` | male | MinecraftSkins | 1988 B | ✓ godly (re-procesado 2026-07-26 — la versión ↻ crop quedó como `.lossy.bak`) |

Adicionalmente, el archivo `enderman.png` vive en la carpeta de texturas pero
**no** está en `skins.txt`. Lo registra el mod custom `wetlands_gabo_skin`
(oculto del menú `/skin`, disfraz personal de `gabo`) — ver log de arranque:

```
[wetlands_gabo_skin] Skin 'enderman.png' registrado (oculto del menu /skin)
[wetlands_gabo_skin] Loaded successfully - disfraz completo (skin + nametag) para gabo (world: gaelsin)
```

## Receta: agregar una skin

Todo se hace en el VPS, con `sudo` para los `chown`. `server/worlds/gaelsin/`
debe seguir siendo `1000:1000` (uid del container `abc`) — nunca hacer
`chown -R` sobre la raíz del repo.

### 1. Convertir el PNG

**El problema**: un skin de Minecraft 64×64 tiene **dos capas** (base + overlay).
La base es la "ropa interior" del personaje; la overlay es lo que se pinta
encima con alpha: pecheras de armadura, capas, cascos, mangas, pantalones. Un
crop ingenuo `crop((0,0,64,32))` solo toma la base y **se pierde toda la
overlay** — la armadura de diamante queda sin pechera, el Mandalorian sin
casco/capa, etc.

**Opción 1 (Recomendada) — godly Minetest Skin Converter**:
<https://godly.github.io/minetest-skin-converter/> (godly, GPLv3, 18★ GitHub,
corre 100% en el browser, offline después de cargar).

1. Subir el PNG 64×64.
2. Subir todos los alpha a `1.0` (en cada `Copy` hay un campo `0.5` → cambiar
   a `1.0`).
3. Click en cada botón: **Copy Cape**, **Copy Jacket**, **Copy Left/Right
   Trouser**, **Copy Left/Right Sleeve**. Cada uno compone la overlay
   correspondiente sobre la base con alpha = 1.0.
4. Click derecho sobre la imagen **nueva** (esquina superior izquierda) →
   "Save Image As".

Resultado: 64×32 RGBA con armadura/capa/casco **incluidos**.

> Documentado también en `docs/00-SHARED/config/07-CUSTOM_SKINS.md` como
> "Opción 1 (Recomendada)".

**Opción 2 (Solo fallback) — PIL crop para skins SIN overlay**:

Si el skin de Minecraft no tiene armadura/casco/capa (personaje simple), un
crop vertical basta:

```bash
python3 -c "from PIL import Image; \
  Image.open('origen.png').crop((0,0,64,32)).save('destino.png')"
```

⚠️ **Si el skin tiene overlay visible (armadura, casco, capa, etc.) el crop
dejará la skin incompleta**. Ejemplos vividos en este set: `mandalorian`
quedó sin yelmo, `diamond_armor` quedó sin pechera. La solución es godly.

**Nombres de archivo**: `snake_case` limpio, sin fecha, sin ID de
MinecraftSkins, guiones convertidos a `_`. Ejemplos ya en uso: `zombie`,
`buddhist_monk`, `ninja_boxy`, `panda`, `pepe`, `lloyd_possesion_suit`,
`indie_boy`, `mandalorian`, `diamond_armor`.

### 2. Copiar al VPS

```bash
# Local → /tmp del VPS
scp destino.png <VPS_USER>@<VPS_IP>:/tmp/destino.png

# Mover al world folder con owner correcto
ssh <VPS_USER>@<VPS_IP> "sudo cp /tmp/destino.png \
  <PROJECT_PATH>/server/worlds/gaelsin/_world_folder_media/textures/<nombre>.png && \
  sudo chown 1000:1000 \
  <PROJECT_PATH>/server/worlds/gaelsin/_world_folder_media/textures/<nombre>.png"
```

### 3. Editar `skins.txt`

`server/worlds/gaelsin/skins.txt` (también `1000:1000`, `0644`). Agregar una
entrada antes del cierre `}` del array:

```lua
  { texture = "<nombre>", gender = "male" },
```

Con `sudo`:

```bash
ssh <VPS_USER>@<VPS_IP> "sudo vim \
  <PROJECT_PATH>/server/worlds/gaelsin/skins.txt"
```

### 4. Reiniciar y verificar

```bash
ssh <VPS_USER>@<VPS_IP> "docker restart luanti-gaelsin-server"
ssh <VPS_USER>@<VPS_IP> "docker logs --since='30s' luanti-gaelsin-server 2>&1 \
  | grep -iE 'error|warn' | grep -vE 'MINETEST_GAME_PATH|mineshaft'"
```

In-game: la skin aparece en `/skin`. Si no aparece, verificar:

- PNG existe dentro del container:
  `docker exec luanti-gaelsin-server ls /config/.minetest/worlds/gaelsin/_world_folder_media/textures/`
- Entrada en `skins.txt`:
  `docker exec luanti-gaelsin-server cat /config/.minetest/worlds/gaelsin/skins.txt`
- `world.mt` tiene `load_mod_mcl_custom_world_skins = true`.

## Receta: quitar una skin

1. Borrar la entrada de `skins.txt`.
2. Borrar el PNG de `_world_folder_media/textures/`.
3. Reiniciar.

No hace falta tocar `world.mt` ni `luanti-gaelsin.conf` — el mod seguirá
cargado pero no registrará nada.

## Diferencias con Wetlands

| Aspecto | Wetlands (30000) | GAELSIN (30002) |
|---------|------------------|-----------------|
| Mod cargando | mismo `mcl_custom_world_skins` | mismo |
| Set de skins | el de `server/worlds/original/skins.txt` | el de `server/worlds/gaelsin/skins.txt` |
| Tamaño del set | 7 | 11 (Wetlands + 4 nuevas: `indie_boy`, `wetlands_npc_luke`, `mandalorian`, `diamond_armor`) |
| Skins con disfraz oculto (no en menú) | depende | `enderman` (vía `wetlands_gabo_skin`) |

Las skins **no se sincronizan automáticamente** entre mundos — el set de
GAELSIN es una decisión explícita del admin, copia individual.

## Pitfalls

- **64×64 de Minecraft NO funciona** directamente. VoxeLibre/MT espera 64×32.
  Convertir antes de subir — godly para skins con overlay, PIL crop solo para
  skins simples.
- **Crop ingenuo destruye la overlay layer.** El formato Minecraft 64×64 tiene
  dos capas (base + overlay con alpha). Un `crop((0,0,64,32))` solo conserva
  la base y pierde armadura/casco/capa/mangas. Para esos casos usar godly
  (ver [Receta](#1-convertir-el-png)).
- **No poner skins con nombre tipo `mobs_mc_villager_*.png`** (riesgo de
  colisión de texture IDs con VoxeLibre). Usar siempre prefijo propio del
  mundo, p. ej. `wetlands_npc_*.png` o nombres únicos.
- **El directorio `server/skins/` del repo NO se monta en el container.** Es
  un directorio huérfano del sistema legacy de skins de Minetest; el sistema
  vigente es `mcl_custom_world_skins` + `skins.txt` por mundo.
- **`server/worlds/gaelsin/` está gitignored.** Cambios ahí viven solo en el
  VPS. No hay workflow automático de commit (decisión consciente para no
  commitear map.sqlite).
- **El mod no loguea.** Ausencia de líneas en el log de arranque ≠ éxito.
  Verificar siempre in-game con `/skin`.
