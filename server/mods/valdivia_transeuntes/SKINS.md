# Skins de los transeúntes

> **La procedencia ya no se anota acá.** La fuente única de la verdad de todos
> los skins humanoides de Valdivia es **[`server/skins/skins.json`](../../skins/skins.json)**
> — sitio y slug de origen, original 64×64 y textura destino, en una sola
> tabla que además es ejecutable. Este archivo guarda solo las reglas
> editoriales propias del elenco.

Cada transeúnte es **una persona distinta**: un nombre, un oficio, una textura
y sus propias frases. No hay skins compartidos ni intercambiables — si dos
transeúntes se vieran iguales, sería un bug. El elenco vive en `init.lua`
(tabla `PERSONAJES`) y la textura se deduce del nombre:
`valdivia_transeunte_<nombre en minúscula>.png`.

**Regla de las marcas**: cuando un skin trae algo que lo identifica, el nombre
se amarra a esa marca. La polera de Hugo lleva una **"H"** morada dibujada, así
que ese skin es de **Hugo** y de nadie más. Lo mismo para cualquier skin futuro
con inicial, número o nombre visible.

**Criterio al elegir**: ropa común y **ningún personaje reconocible**. Son
figurantes de fondo de una ciudad, no cameos. Del barrido se probaron ~70
candidatos y se botaron los que llegaban rotos o fuera de tono: texturas casi
transparentes (piernas invisibles), patrones de prueba (damero, rayas de
peligro), disfraces de personaje con licencia y cualquier cosa con sangre. El
filtro es visual, porque el nombre del slug miente seguido.

## Sumar a alguien al elenco

```bash
# 1. bajar el original (queda en server/skins/raw/, no en el mod)
./scripts/fetch-skin.sh msn:<slug> \
  server/mods/valdivia_transeuntes/textures/valdivia_transeunte_<nombre>.png \
  server/skins/raw/transeunte_<nombre>.png

# 2. anotarlo en server/skins/skins.json (original, fuente, destino, usa)
# 3. agregar la fila en PERSONAJES (init.lua) con su oficio y sus 3 frases
# 4. revisar a ojo antes de commitear
python scripts/render-skin-front.py \
  server/mods/valdivia_transeuntes/textures lamina.png
```

El paso 2 no es burocracia: `python scripts/rebuild-skins.py` regenera los
64×32 **solo** de lo que esté en el manifiesto. Un skin sin fila ahí queda
fuera de cualquier re-conversión futura y su procedencia se pierde.

Qué sitios se pueden automatizar y cuáles devuelven 403:
[`docs/00-SHARED/mods/SKIN_SOURCES.md`](../../../docs/00-SHARED/mods/SKIN_SOURCES.md).
