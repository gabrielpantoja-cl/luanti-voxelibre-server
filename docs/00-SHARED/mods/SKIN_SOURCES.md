# De dónde bajar skins (y cómo)

Resultado de un piloto hecho el **2026-10-30**: se probaron diez sitios, se
bajaron dos skins desde cada uno de los tres que sirven, y se convirtieron los
seis a 64×32. Esta página es el resumen operativo; el detalle por archivo de
cada skin de Valdivia vive en el manifiesto
`server/skins/skins.json` (ver el final de esta página).

## El comando

```bash
./scripts/fetch-skin.sh <fuente> <salida_64x32.png> [original_64x64.png]
```

Descarga, verifica que sea un PNG, guarda el original y lo convierte a 64×32
horneando la capa de overlay. Ejemplo real:

```bash
./scripts/fetch-skin.sh msn:trendyguy \
  server/mods/valdivia_transeuntes/textures/valdivia_transeunte_vecino_3.png \
  server/skins/raw/transeunte_vecino_3.png
```

**Guarda siempre el original 64×64** (tercer argumento). Es lo que permite
re-convertir más adelante sin volver a depender de que el sitio siga vivo, y es
la única copia del overlay completo.

## Qué sitio sirve y cuál no

Medido con `curl` el 2026-10-30. El `403` es el desafío de bots de Cloudflare:
no se arregla con user-agent, ni con cookies, ni con un navegador controlado
por Playwright.

| Sitio | Automatizable | Prefijo | Patrón de descarga |
|---|---|---|---|
| **www.minecraftskins.net** | ✅ | `msn:<slug>` | `https://www.minecraftskins.net/<slug>/download` |
| **mc-skins.net** | ✅ | `mcs:<slug>` | `https://mc-skins.net/texture/<slug>.png` |
| **mc-heads.net** (espejo de Mojang) | ✅ | `player:<nombre>` | `https://mc-heads.net/skin/<nombre>` |
| **crafatar.com** (espejo de Mojang) | ✅ | `uuid:<uuid>` | `https://crafatar.com/skins/<uuid>` |
| www.minecraftskins.com (Skindex) | ❌ 403 | — | descarga manual desde el navegador |
| namemc.com | ❌ 403 | — | — |
| planetminecraft.com | ❌ 403 | — | — |
| skinmc.net | ❌ 403 | — | — |
| minecraft.novaskin.me | ❌ 403 | — | — |
| needcoolshoes.com/gallery | ❌ 403 | — | — |

**minecraftskins.com (el Skindex) es el catálogo más grande y es justamente el
que no se puede automatizar.** Si hace falta un skin de ahí: abrirlo en el
navegador, bajar el PNG a mano, y pasarlo directo al conversor:

```bash
python scripts/convert-skin.py ~/Downloads/loquesea.png destino_64x32.png
```

### Buscar en los dos catálogos que sí responden

Las páginas de listado son HTML plano, sin JS:

```bash
# minecraftskins.net — categorias: people, fantasy, games, mobs, movies, tv, other
curl -s https://www.minecraftskins.net/category/people | grep -oE 'href="/[a-z0-9]+"' | sort -u
```

El `<slug>` de cada resultado es lo que va después de `msn:`. Los previews
están en `/static/front_preview/<slug>.png` y `/static/head/<slug>.png`, útiles
para mirar antes de bajar.

## Formatos: lo que devuelve cada sitio

- Las galerías devuelven **64×64** (formato Minecraft moderno, dos capas).
- `mc-heads` / `crafatar` devuelven **64×64 normalmente, pero 64×32 para
  cuentas antiguas** (verificado: `jeb_` llega en 64×32 legacy). El conversor
  detecta el caso y lo pasa tal cual.

## La conversión 64×64 → 64×32

`scripts/convert-skin.py` reemplaza al conversor web de godly: hace lo mismo
(Copy Jacket / Copy Sleeve / Copy Trouser con alpha 1.0) sin navegador, sin
Playwright y sin estado acumulado entre archivos.

El 64×64 guarda **dos capas**: una base y un overlay con alpha (chaqueta,
mangas, pantalones). Un `crop((0,0,64,32))` se queda solo con la base y borra
en silencio la chaqueta, el casco y la capa — es lo que le costó el casco al
`mandalorian` de GAELSIN. El script hornea las tres regiones de overlay del
lado derecho sobre la base antes de recortar, y reporta cuántas encontró:

```
3/3 regiones de overlay horneadas    <- el recorte simple habria roto este
0/3 regiones de overlay horneadas    <- este no tenia overlay; el recorte servia
ya era 64x32                         <- skin legacy, se copia tal cual
```

En el piloto, 5 de 6 skins tenían overlay real. **Asumir que hay overlay
siempre** es la regla correcta.

### Limitación conocida

El formato 64×32 no tiene brazo ni pierna izquierdos propios: los espeja del
lado derecho. Un skin 64×64 con asimetría izquierda/derecha (un parche en una
sola manga, un tatuaje en un brazo) la pierde. No hay arreglo: es el formato.

## Verificar a ojo antes de commitear

`scripts/render-skin-front.py` arma una lámina con el monigote frontal de cada
skin de una carpeta, a escala, para revisar que nada se haya roto:

```bash
python scripts/render-skin-front.py <carpeta_con_64x32> lamina.png
```

## Criterio editorial para figurantes

Para transeúntes, vecinos y gente de fondo: **ropa común y ningún personaje
reconocible**. Nada de Spiderman, Ronaldo, Herobrine ni personajes de anime —
son figurantes de una ciudad, no cameos. En `minecraftskins.net/category/people`
la mitad del catálogo son personajes con licencia; filtrar por nombre de slug
antes de bajar.

Los skins de `player:` / `uuid:` son el skin real de una cuenta de Minecraft.
Sirven cuando alguien pide "el skin de fulano", **no** para figurantes
anónimos.

---

# La fuente única de la verdad: `server/skins/skins.json`

Todo skin humanoide de Valdivia (puerto 30001) tiene **una fila y solo una**
en `server/skins/skins.json`. La fila dice de dónde salió, cuál es su original
64×64 y a qué textura de qué mod va:

```json
"discoteca_rave2": {
  "original": "discoteca_rave2.png",
  "fuente":   "skindex:rave-24164935",
  "destino":  "server/mods/valdivia_discoteca/textures/valdivia_discoteca_dancer_rave2.png",
  "usa":      "valdivia_discoteca · bailarin rave2"
}
```

Los originales 64×64 viven todos juntos en **`server/skins/raw/`**. Ya no hay
`raw_skins/` por mod: cada mod conserva únicamente su `textures/*.png` de
64×32, que es lo que Luanti necesita ahí.

```bash
python scripts/rebuild-skins.py --check   # qué está desactualizado
python scripts/rebuild-skins.py           # regenera los 64×32 que cambiaron
python scripts/rebuild-skins.py --force   # reescribe todo
```

## Qué cubre hoy

| Mod | Skins | Procedencia |
|---|---|---|
| `valdivia_transeuntes` | 60 | ✅ sitio + slug de cada uno |
| `valdivia_discoteca` | 11 | ✅ sitio + slug de cada uno |
| `valdivia_spawn_npc` (guías) | 4 | ✅ sitio + slug de cada uno |
| `valdivia_policia` | 1 | ⚠️ `fuente: null` — no se registró al crearlo |
| **`wetlands_npcs`** | 11 | ❌ **todavía fuera del manifiesto** |

`wetlands_npcs` quedó afuera a propósito: tiene sistema de modelo dual
(humanoide 64×32 + villager 64×64), 24 originales con convenciones viejas y su
propio `tools/generate_textures.py` que *genera* texturas de villager en vez de
convertirlas. Migrarlo es un trabajo aparte.

## Por qué existe esto

Había un convertidor por mod y cada uno distinto. Tres usaban el recorte con
pérdida, y nadie lo notó: **los 11 bailarines de la discoteca y los 4 guías
perdieron su capa de overlay** (chaqueta, manga, pantalón) — medido el
2026-10-30, los 15 tenían overlay real, entre 20 y 300 píxeles cada uno.
Se regeneraron desde los originales con el conversor bueno.

Tres skins además se reutilizan entre mods, cosa que ninguna doc por mod podía
mostrar: `indie_boy` es a la vez el guía del spawn y el bailarín `indie`;
`summer_gala` es el guía del Parque Catrico y la bailarina `summer`; `hipster`
es el guía de Huachocopihue y el bailarín `hipster2`.

## Agregar un skin

1. `./scripts/fetch-skin.sh <fuente> <destino_64x32.png> server/skins/raw/<nombre>.png`
2. Agregar la fila en `server/skins/skins.json`.
3. Registrar el NPC en el `init.lua` del mod que corresponda.
4. `python scripts/render-skin-front.py <carpeta_textures> lamina.png` y mirarla.

Saltarse el paso 2 significa que ese skin queda fuera de toda re-conversión
futura y su procedencia se pierde — que es exactamente cómo se llegó al estado
anterior.
