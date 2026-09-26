# Incidente: Crash-loop de Valdivia por skins.txt en UTF-16LE

**ID:** INC-2026-09-26-001
**Severidad:** SEV-1 (Servicio caído — crash-loop de arranque)
**Estado:** Resuelto
**Inicio:** 2026-09-26 (UTC)
**Servidor:** Valdivia (puerto 30001) — contenedor `luanti-valdivia-server`

## Resumen Ejecutivo

La migración de las skins custom de Wetlands a Valdivia (commit `7b5d4a35`) introdujo `server/worlds/valdivia/skins.txt` codificado en **UTF-16LE con BOM** en lugar de UTF-8. `core.deserialize()` devuelve `nil` ante bytes inválidos, y `mcl_custom_world_skins/init.lua` hacía `ipairs(nil)` en la línea 22 → **ModError** → el servidor abortaba el arranque y el contenedor entraba en crash-loop (reinicio indefinido, puerto 30001 inaccesible).

## Causa raíz (mecanismo técnico)

### 1. La redirección de PowerShell `>` inyecta UTF-16LE

La copia inicial del archivo se hizo en la terminal Windows del operador con la sintaxis de redirección de PowerShell:

```powershell
ssh gabriel@luanti.gabrielpantoja.cl "sudo cat /home/.../worlds/original/skins.txt" > server\worlds\valdivia\skins.txt
```

En **Windows PowerShell 5.1**, el operador `>` es azúcar sintáctico para `Out-File`, y `Out-File` sin parámetro `-Encoding` usa por defecto **`Unicode` = UTF-16LE con BOM** (no UTF-8). El contenido de texto llega correcto, pero el *encoding de escritura* lo decide PowerShell:

| Capa | Esperado | Real |
|------|----------|------|
| Encoding | UTF-8 sin BOM | UTF-16LE con BOM (`FF FE`) |
| Primeros bytes | `2D 2D 20 57` (`-- W`) | `FF FE 2D 00 2D 00 20 00 57 00 ...` |
| Tamaño (7 skins) | 620 bytes | 1236 bytes (casi el doble: 2 bytes por carácter) |

Los bytes de ejemplo leídos del archivo dañado:

```
FF-FE-2D-00-2D-00-20-00-57-00-65-00-74-00-6C-00-61-00-6E-00-64-00-73-00 ...
^^^BOM  ^^-  ^^-  ^ sp  ^W   ^e   ^t   ^l   ^a   ^n   ^d   ^s        (UTF-16LE)
```

> **Regla aprendida:** en PowerShell **nunca** usar `>` para archivos de datos.
> Usar `[IO.File]::WriteAllText($path, $content, [Text.UTF8Encoding]::new($false))`
> o redirigir desde `cmd.exe` / Git Bash.

### 2. `core.deserialize()` devuelve `nil`

`mcl_custom_world_skins/init.lua` lee el archivo crudo y lo pasa al deserializador:

```lua
local f = io.open(core.get_worldpath().."/skins.txt", "r")
skins = core.deserialize(f:read("*all"))   -- ← content con \xFF\xFE y \x00
for _, skin in ipairs(skins) do            -- LÍNEA 22: ipairs(nil) → ERROR
```

`core.deserialize()` evalúa el string como código Lua serializado; los bytes del BOM (`0xFF 0xFE`) y los `0x00` intercalados hacen que el `loadstring` interno falle → devuelve **`nil`** (su contrato de "no se pudo deserializar"). No lanza error por sí mismo: el mod nunca validó el retorno.

### 3. `ipairs(nil)` → ModError → crash-loop

- `ipairs(nil)` en la línea 22 lanza `bad argument #1 to 'ipairs' (table expected, got nil)`.
- El error ocurre **durante la carga de mods**, así que el engine aborta el arranque con `ModError`.
- El entrypoint del contenedor (`linuxserver/luanti`) reinicia el proceso → vuelve a fallar en el mismo punto → **crash-loop**.

## Detección

| Señal | Valor observado |
|-------|-----------------|
| Estado del contenedor | `Up 4 minutes` (reiniciándose) |
| Errores en 90 s | 60 (`ModError` en `mcl_custom_world_skins`) |
| Texto del error | `bad argument #1 to 'ipairs'` en `init.lua:22` |
| Puerto 30001 | Inaccesible durante el loop |
| Wetlands / GAELSIN / Plano / Mineclonia | `healthy` (no afectados — solo Valdivia tiene el `skins.txt` dañado) |

## Por qué no se detectó antes del push

El archivo dañado se creó localmente con la redirección de PowerShell, y la validación posterior (`ssh "sudo cat ... > file"` de vuelta) **leyó el archivo con el mismo mecanismo roto**, devolviendo texto aparentemente correcto en pantalla (PowerShell *decodifica* UTF-16LE al leer, ocultando el problema). La verificación definitiva es **por bytes** (`[IO.File]::ReadAllBytes` + hexdump), no por contenido visual.

## Corrección aplicada

| Paso | Acción | Commits |
|------|--------|---------|
| 1 | Recodificar `server/worlds/valdivia/skins.txt` → **UTF-8 sin BOM** (620 bytes, 7 skins intactas: `zombie`, `buddhist_monk`, `ninja_boxy`, `lloyd_possesion_suit`, `panda`, `pepe`, + 1) | `fix(skins)` |
| 2 | **Defense in depth**: nil-guard en `init.lua` — si `type(skins) ~= "table"` se loguea `error` y el mod carga 0 skins (degrada, no crashea). También `f:close()` y warning si falta el archivo | `fix(skins)` |
| 3 | Fix por **GitOps completo** (local → GitHub → VPS pull → restart → verificar logs). **No** se editó nada manualmente en el VPS | — |

**Verificación post-fix (esperada):** 0 × `ModError`, `listening on [::]:30001`, 7 skins visibles en el selector de Valdivia.

## Decisión de descarte: comando destructivo propuesto

Se propuso ejecutar en el VPS:

```bash
sudo chown -R gabriel:gabriel . && git fetch && git reset --hard origin/main && git clean -fd && docker compose restart
```

**Rechazado** por cuatro razones verificadas:

1. **`git clean -fd` habría borrado mundos vivos.** El chain `!server/worlds/*/` (introducido en `7b5d4a35`) dejaba `server/worlds/original/` (el mundo Wetlands **en el VPS**), `mineclonia/`, `plano/`, `infierno_OLD/` y `ctf_OLD-20260914/` como *untracked-no-ignored* → `clean -fd` los habría eliminado.
2. **`chown -R` sobre todo el repo** rompe los permisos del contenedor (`server/worlds/` y `server/config/` deben ser `1000:1000` por el `PUID` de docker-compose) → fallo `Couldn't save env meta` en el siguiente arranque.
3. El sync ya estaba completo (HEAD = `origin/main`); `reset --hard` no arreglaba nada.
4. **No corregía la causa raíz** (el encoding UTF-16 ya estaba dentro de la historia de git: había que reescribir el archivo y pushear).

El ownership, de todos modos, **se auto-corrigió** al reiniciar el contenedor (el entrypoint de `linuxserver/luanti` re-aplica `opc:opc`).

## Decisiones de limpieza local del repositorio

Contexto: el chain `!server/worlds/*/` necesario para las skins (commit `7b5d4a35`) tenía un efecto secundario — antes, `server/worlds/*` ocultaba los directorios de mundo **enteros** y git nunca descendía; al des-ocultarlos, surgieron **8 archivos untracked** acumulados:

| Origen | Archivos | Cuándo | Diagnóstico |
|--------|----------|--------|-------------|
| Sesión WorldEdit | `server/worlds/original/schematics/*.mts` ×3 + `*.mts.bak` ×3 | 24-07-2026 (hace 2 meses) | Esquemas válidos (`chateau_without_garden`, `default_town_tower`, `library_1_0`). Los `.bak` son backups previos a edición (mtimes 14 min anteriores, tamaños ≠). **No existen en el VPS** → única copia local |
| Scaffold a medias Mineclonia | `server/worlds/mineclonia/.gitkeep` + `world.mt` (44 B, 2 líneas) | 01-08-2026 (tarea Mineclonia) | **No es basura de prueba**: Mineclonia es mundo de producción (30004). El `world.mt` local es un esqueleto **desactualizado** — el real (182 B, con `backend` + `load_mod_*`) vive solo en el VPS |

### Reglas aplicadas al `.gitignore`

1. **`*.bak` + `*.bak.*` globales** — ningún backup de archivo vuelve a aparecer como untracked (cubre `.mts.bak` y los `world.mt.bak.<timestamp>` del VPS).
2. **Capa de re-ocultado `server/worlds/*/*`** tras `!server/worlds/*/` — vuelve a ocultar *todo* el contenido de mundos, dejando pasar solo la lista blanca (`world.mt`, `auth.txt`, `skins.txt`, `schematics/*.mts`, media de skins). Esto además **cierra la landmina de `git clean -fd`**: los mundos dejan de ser *untracked*.
3. **Exclusiones explícitas de mundos VPS-only**: `mineclonia/`, `plano/`, `infierno_OLD/`, `ctf_OLD-*/` (además de `world/`, `gaelsin/`, `worlds_archive/` que ya existían).
4. **Esquemas válidos trackeados** (3 × `.mts`, ~7 KB): únicos en el repo, sin riesgo de conflicto en el VPS (el directorio no existe allá → el pull los crea limpio).

### Comandos ejecutados (solo local, sin VPS)

```bash
git check-ignore -v <candidatos>        # valida reglas (.bak + mineclonia ignorados; .mts trackeables)
git add server/worlds/original/schematics/*.mts   # 3 esquemas válidos
git status --short                      # limpia: 4 modificados + 3 agregados
```

**No se eliminó ningún archivo** (regla del proyecto: sin `rm -rf`; la "basura" queda ignorada en disco, intacta).

### Pendiente GitOps (follow-up)

- Trackear `server/worlds/original/world.mt` (Wetlands) y `server/worlds/mineclonia/world.mt` (versión real, desde el VPS) — hoy solo `valdivia/world.mt` está bajo git. Sin esto, un `git clean -fd` futuro en el VPS seguiría siendo peligroso para `world.mt` de Wetlands.
- Decidir el drift de `server/worlds/valdivia/world.mt` en el VPS (línea `load_mod_voxelibre_protection = false` eliminada allí, efecto idéntico al default).

## Log del Incidente

### 2026-09-26 — DETECCIÓN
- Contenedor `luanti-valdivia-server` en crash-loop, 60 errores `ModError` / 90 s
- Error: `bad argument #1 to 'ipairs'` → `mcl_custom_world_skins/init.lua:22`
- Wetlands/GAELSIN/Plano/Mineclonia: `healthy` (aislado a Valdivia)

### 2026-09-26 — DIAGNÓSTICO
- Hexdump de `skins.txt`: `FF FE ...` → **UTF-16LE con BOM confirmado** (causa raíz)
- Trazado de la cadena: redirección `>` de PowerShell → commit `7b5d4a35` → pull en VPS
- Ownership `opc:opc` verificado correcto (auto-corregido por el contenedor) → descartado como causa
- `git status` en VPS: solo drift de 1 línea en `world.mt` → descartado como causa

### 2026-09-26 — CONTENCIÓN
- Comando destructivo propuesto (`chown -R` + `reset --hard` + `clean -fd`) → **RECHAZADO** (landmina de `clean -fd` sobre mundos vivos, sin arreglo real)
- Verificación **por bytes** (no visual) del encoding dañado

### 2026-09-26 — RESOLUCIÓN
- `skins.txt` recodificado a UTF-8 sin BOM (620 B, 7 skins)
- Nil-guard + `f:close()` + warnings en `mcl_custom_world_skins/init.lua`
- `.gitignore`: `*.bak` globales, capa `server/worlds/*/*`, exclusiones `mineclonia`/`plano`/`*_OLD`, esquemas `*.mts` trackeados
- Fix completo vía GitOps (push → pull → restart → verificar logs)

---
*Documento mantenido por SRE — Última actualización: 2026-09-26*
