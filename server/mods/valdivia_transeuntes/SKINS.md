# Fuentes de los skins de transeúntes

Cada transeúnte de Valdivia es **una persona distinta**: un nombre, un oficio,
una textura y sus propias frases. No hay skins compartidos ni intercambiables
— si dos transeúntes se vieran iguales, sería un bug. El elenco vive en
`init.lua` (tabla `PERSONAJES`) y la textura se deduce del nombre:
`valdivia_transeunte_<nombre en minúscula>.png`.

**Regla de las marcas**: cuando un skin trae algo que lo identifica, el nombre
se amarra a esa marca. La polera de `estudiante_1` lleva una **"H"** morada
dibujada, así que ese skin es de **Hugo** y de nadie más. Lo mismo para
cualquier skin futuro con inicial, número o nombre visible.

Todos descargados de **mc-skins.net**: 12 el **2026-10-30** (lote inicial, por
oficio) y 48 el mismo día al pasar al modelo de elenco. Se eligieron solo
diseños de ropa común y **ningún personaje reconocible**: son figurantes de
fondo de una ciudad, no cameos.

Qué sitio sirve, qué prefijo usa y cómo bajar uno nuevo:
**`docs/00-SHARED/mods/SKIN_SOURCES.md`**. En corto, para sumar a alguien:

```bash
# 1. bajar y convertir (nombre del personaje en minúscula)
./scripts/fetch-skin.sh msn:<slug> \
  server/mods/valdivia_transeuntes/textures/valdivia_transeunte_<nombre>.png \
  server/mods/valdivia_transeuntes/raw_skins/<Nombre>_64x64.png

# 2. agregar la fila en PERSONAJES (init.lua) con sus 3 frases
# 3. revisar a ojo antes de commitear
python scripts/render-skin-front.py \
  server/mods/valdivia_transeuntes/textures lamina.png
```

`minecraftskins.com` (el Skindex) sigue descartado como fuente automatizable:
responde `403` a todo acceso programático (muro de bots de Cloudflare), por
`curl` y por navegador controlado. Para traer uno de ahí hay que descargarlo a
mano desde el navegador y pasarlo a `scripts/convert-skin.py`.

## El elenco

| Personaje | Oficio | Textura | Slug en mc-skins.net |
|---|---|---|---|
| Agustin | vecino | `valdivia_transeunte_agustin.png` | `simple-boy-ac22e6` |
| Amanda | feriante | `valdivia_transeunte_amanda.png` | `green-apron-girl-146002` |
| Antonia | vecina | `valdivia_transeunte_antonia.png` | `brown-haired-baker-42fcfa` |
| Arturo | jubilado | `valdivia_transeunte_arturo.png` | `benjamins-dad-alt-1-3aa8fe` |
| Bastian | feriante | `valdivia_transeunte_bastian.png` | `barista-mik-62869d` |
| Benjamin | vecino | `valdivia_transeunte_benjamin.png` | `black-casual-outfit-045b05` |
| Camila | vecina | `valdivia_transeunte_camila.png` | `female-casual-outfit-7937b5` |
| Carmen | jardinera | `valdivia_transeunte_carmen.png` | `cute-farmer-boy-167a88` |
| Catalina | vecina | `valdivia_transeunte_catalina.png` | `malik-casual-outfit-29391c` |
| Constanza | pescadora | `valdivia_transeunte_constanza.png` | `yellow-raincoat-boy-6f72ef` |
| Cristobal | vecino | `valdivia_transeunte_cristobal.png` | `red-tracksuit-outfit-7743d7` |
| Daniela | doctora | `valdivia_transeunte_daniela.png` | `white-lab-coat-doctor-3cdcbe` |
| Diego | escolar | `valdivia_transeunte_diego.png` | `black-school-uniform-boy-82bd26` |
| Eduardo | oficinista | `valdivia_transeunte_eduardo.png` | `casual-black-suit-d2d0f2` |
| Elias | vecino | `valdivia_transeunte_elias.png` | `doctor-glasses-597b99` |
| Emilia | vecina | `valdivia_transeunte_emilia.png` | `blonde-girl-casual-0f2629` |
| Felipe | deportista | `valdivia_transeunte_felipe.png` | `blue-tracksuit-guy-76f345` |
| Fernanda | enfermera | `valdivia_transeunte_fernanda.png` | `pale-blue-nurse-outfit-5ea63d` |
| Florencia | vecina | `valdivia_transeunte_florencia.png` | `bill-the-baker-fc1f39` |
| Francisca | estudiante | `valdivia_transeunte_francisca.png` | `3-am-studying-girl-d9462f` |
| Gabriel | pescador | `valdivia_transeunte_gabriel.png` | `flannel-shirt-woodsman-16fc4b` |
| Gaspar | vecino | `valdivia_transeunte_gaspar.png` | `dad-skin-a29da7` |
| Gonzalo | oficinista | `valdivia_transeunte_gonzalo.png` | `classic-gray-trenchcoat-suit-3fa124` |
| Guillermo | jubilado | `valdivia_transeunte_guillermo.png` | `malak-dad-0b0e3b` |
| Hernan | oficinista | `valdivia_transeunte_hernan.png` | `dadada-suit-3185d6` |
| Hilda | campesina | `valdivia_transeunte_hilda.png` | `farmer-outfit-7d300b` |
| Hugo | estudiante | `valdivia_transeunte_hugo.png` | `blue-jacket-teen-41e2af` |
| Ignacia | turista | `valdivia_transeunte_ignacia.png` | `blonde-adventurer-outfit-bbc29c` |
| Ignacio | bombero | `valdivia_transeunte_ignacio.png` | `argentine-volunteer-firefighter-63d738` |
| Isidora | turista | `valdivia_transeunte_isidora.png` | `brown-vest-explorer-567e7e` |
| Javiera | vecina | `valdivia_transeunte_javiera.png` | `female-casual-outfit-9227b2` |
| Joaquin | vecino | `valdivia_transeunte_joaquin.png` | `blue-tracksuit-boy-0745d6` |
| Josefa | vecina | `valdivia_transeunte_josefa.png` | `blue-baker-c06772` |
| Lautaro | guardaparques | `valdivia_transeunte_lautaro.png` | `firefighter-dazw-d9d4cd` |
| Lucho | campesino | `valdivia_transeunte_lucho.png` | `comfy-farmer-skin-26a67f` |
| Manuel | obrero | `valdivia_transeunte_manuel.png` | `blue-work-overalls-ac7dae` |
| Marcelo | obrero | `valdivia_transeunte_marcelo.png` | `orange-safety-vest-3d8688` |
| Martin | vecino | `valdivia_transeunte_martin.png` | `casual-denim-outfit-ac0a2b` |
| Matias | vecino | `valdivia_transeunte_matias.png` | `gray-casual-outfit-9eb553` |
| Matilde | turista | `valdivia_transeunte_matilde.png` | `brown-leather-adventurer-370ef2` |
| Mauricio | obrero | `valdivia_transeunte_mauricio.png` | `construction-worker-remake-5bb050` |
| Milaray | vecina | `valdivia_transeunte_milaray.png` | `street-boy-glasses-c0d173` |
| Nahuel | estudiante | `valdivia_transeunte_nahuel.png` | `crimson-vest-student-ae5d00` |
| Olegario | campesino | `valdivia_transeunte_olegario.png` | `brown-hat-farmer-001594` |
| Pablo | cocinero | `valdivia_transeunte_pablo.png` | `chefs-uniform-3c591e` |
| Patricio | oficinista | `valdivia_transeunte_patricio.png` | `suit-with-glasses-c95c9d` |
| Paz | vecina | `valdivia_transeunte_paz.png` | `poncho-skin-11cd6b` |
| Ramon | campesino | `valdivia_transeunte_ramon.png` | `blonde-farmer-outfit-3a8e6f` |
| Rayen | estudiante | `valdivia_transeunte_rayen.png` | `grungy-teen-fit-beanie-059d74` |
| Renato | vecino | `valdivia_transeunte_renato.png` | `dark-green-jacket-boy-5a0411` |
| Rodrigo | bombero | `valdivia_transeunte_rodrigo.png` | `mark-bombero-firefighter-30a1e1` |
| Rosa | panadera | `valdivia_transeunte_rosa.png` | `baker-elliot-skin-2150c7` |
| Sergio | obrero | `valdivia_transeunte_sergio.png` | `dirty-denim-overalls-ed8d55` |
| Simon | pescador | `valdivia_transeunte_simon.png` | `mark-pescador-18d772` |
| Sofia | escolar | `valdivia_transeunte_sofia.png` | `blue-uniform-girl-185954` |
| Teresa | jubilada | `valdivia_transeunte_teresa.png` | `red-cardigan-73b271` |
| Trinidad | feriante | `valdivia_transeunte_trinidad.png` | `brown-hair-chef-outfit-85ae19` |
| Valentina | vecina | `valdivia_transeunte_valentina.png` | `blue-hoodie-girl-039b1e` |
| Vicente | vecino | `valdivia_transeunte_vicente.png` | `casual-blue-denim-outfit-07708c` |
| Victor | obrero | `valdivia_transeunte_victor.png` | `miners-blue-overalls-4f7800` |

Descarga directa de un original: `https://mc-skins.net/texture/<slug>.png`

## Conversión

`scripts/convert-skin.py <64x64.png> <64x32.png>` hornea las tres regiones de
overlay (chaqueta, manga derecha, pantalón derecho) sobre la base antes de
recortar. **Los 60 pasaron por ahí**; la mayoría traía overlay real que el
recorte simple habría borrado (es el error que en GAELSIN costó el casco del
mandalorian). Verificado comparando monigotes frontales del original contra el
convertido.

Re-generar todos, leyendo los nombres desde el propio elenco:

```bash
for f in server/mods/valdivia_transeuntes/raw_skins/*_64x64.png; do
  n=$(basename "$f" _64x64.png)
  python scripts/convert-skin.py "$f" \
    "server/mods/valdivia_transeuntes/textures/valdivia_transeunte_$(echo "$n" | tr 'A-Z' 'a-z').png"
done
```

## Descartados

Del barrido se probaron ~70 skins y se botaron los que llegaban rotos o fuera
de tono: texturas casi transparentes (piernas invisibles), patrones de prueba
(damero, rayas de peligro), disfraces de personaje reconocible y cualquier cosa
con sangre. El filtro fue visual: se renderiza el monigote frontal de cada
candidato en una lámina y se mira, porque el nombre del slug miente seguido.
