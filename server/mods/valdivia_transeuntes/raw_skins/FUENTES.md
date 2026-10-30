# Fuentes de los skins de transeúntes

Todos descargados de **mc-skins.net** (galería de skins subidos por la
comunidad) el **2026-10-30**. Se eligieron solo diseños de ropa común —
vecinos, escolares, trabajadores— y **ningún personaje reconocible**: son
figurantes de fondo de una ciudad, no cameos.

`minecraftskins.com` quedó descartado como fuente: responde `403` a todo
acceso automatizado (desafío de bots de Cloudflare), tanto por `curl` como por
navegador controlado. Para traer uno de ahí hay que descargarlo a mano desde
el navegador y dejar el PNG 64x64 en esta carpeta.

| Archivo final (`../textures/`) | Original 64x64 | Slug en mc-skins.net |
|---|---|---|
| `valdivia_transeunte_vecino_1.png`     | `vecino_1_64x64.png`     | `dark-green-jacket-boy-5a0411` |
| `valdivia_transeunte_vecino_2.png`     | `vecino_2_64x64.png`     | `blue-hoodie-girl-039b1e` |
| `valdivia_transeunte_escolar_1.png`    | `escolar_1_64x64.png`    | `black-school-uniform-boy-82bd26` |
| `valdivia_transeunte_escolar_2.png`    | `escolar_2_64x64.png`    | `blue-uniform-girl-185954` |
| `valdivia_transeunte_estudiante_1.png` | `estudiante_1_64x64.png` | `blue-jacket-teen-41e2af` |
| `valdivia_transeunte_estudiante_2.png` | `estudiante_2_64x64.png` | `3-am-studying-girl-d9462f` |
| `valdivia_transeunte_feriante_1.png`   | `feriante_1_64x64.png`   | `barista-mik-62869d` |
| `valdivia_transeunte_feriante_2.png`   | `feriante_2_64x64.png`   | `brown-hair-chef-outfit-85ae19` |
| `valdivia_transeunte_pescador_1.png`   | `pescador_1_64x64.png`   | `mark-pescador-18d772` |
| `valdivia_transeunte_pescador_2.png`   | `pescador_2_64x64.png`   | `yellow-raincoat-boy-6f72ef` |
| `valdivia_transeunte_turista_1.png`    | `turista_1_64x64.png`    | `blonde-adventurer-outfit-bbc29c` |
| `valdivia_transeunte_turista_2.png`    | `turista_2_64x64.png`    | `brown-leather-adventurer-370ef2` |

Descarga directa de un original: `https://mc-skins.net/texture/<slug>.png`

## Conversión

`tools/convert_skin.py <64x64.png> <64x32.png>` — hornea las tres regiones de
overlay (chaqueta, manga derecha, pantalón derecho) sobre la base antes de
recortar. Los 12 pasaron por ahí; 11 tenían overlay real que el recorte simple
habría borrado. Verificado comparando monigotes frontales del original contra
el convertido: ninguno perdió detalle.

Re-generar todos:

```bash
for n in vecino_1 vecino_2 escolar_1 escolar_2 estudiante_1 estudiante_2 \
         feriante_1 feriante_2 pescador_1 pescador_2 turista_1 turista_2; do
  python tools/convert_skin.py "raw_skins/${n}_64x64.png" \
    "textures/valdivia_transeunte_${n}.png"
done
```
