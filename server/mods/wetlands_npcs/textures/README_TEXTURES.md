# Texturas Wetlands NPCs v1.0.0

## Archivos

| Archivo | NPC | Colores |
|---------|-----|---------|
| `wetlands_npc_farmer.png` | Agricultor | Verde/marron |
| `wetlands_npc_librarian.png` | Bibliotecario | Azul/blanco |
| `wetlands_npc_teacher.png` | Maestro | Morado/gris |
| `wetlands_npc_explorer.png` | Explorador | Khaki/marron |

## Formato

- Resolucion: 64x64 pixeles
- Formato: PNG con canal alpha
- UV Map: Compatible con `mobs_mc_villager.b3d`
- Nombres unicos: Prefijo `wetlands_npc_` para evitar conflictos con VoxeLibre base

## Regenerar

```bash
python tools/generate_textures.py
```

## Reemplazar con texturas manuales

Para usar texturas personalizadas (ej: descargadas de minecraftskins.com),
simplemente reemplaza los archivos PNG manteniendo el mismo nombre y formato 64x64.
