# Third-Party Notices

Wetlands is distributed as an aggregate containing independently licensed
components. The root `LICENSE` applies only to original Wetlands code and
documentation for which Wetlands owns the copyright, unless a more specific
notice applies. It does not relicense third-party components or material that
already carries another license.

This is a conservative, non-exhaustive inventory based on notices present in
this checkout as of 2026-08-23. The component's own `LICENSE`, `COPYING`,
`LEGAL`, README, attribution, and per-file notices remain authoritative.

## Verified principal components

| Component | Location | Terms recorded in the component | Local evidence |
|---|---|---|---|
| Mineclonia | `server/games/mineclonia/` | Source code GPL-3.0-or-later, with some mods dual-licensed; media includes CC BY-SA 4.0, CC0, CC BY 4.0, and CC BY-SA 3.0 defaults and exceptions | `LEGAL.md`, `LICENSE.txt`, and notices inside individual mods |
| Plant-based Foods (`vegan_food`) | `server/mods/vegan_food/` | Code GPL-3.0-or-later; images CC BY-SA 4.0 | `README.md`, `LICENSE.txt`, `CREDITS.md` |
| Protector Redo | `server/mods/protector/` | Code MIT; incorporated door code WTFPL; textures include CC0 and CC BY-SA 3.0 material | `license.txt` and `textures/license.txt` |
| mcl_custom_world_skins | `server/mods/mcl_custom_world_skins/` | MIT | `LICENSE` |
| 3D Furniture | `server/mods/3dforniture/` | GPL-2.0-or-later | `LICENSE` |
| celevator | `server/mods/celevator/` | Public-domain dedication, with file origins documented separately | `LICENSE` and `docs/file_sources` |
| _world_folder_media | `server/mods/_world_folder_media/` | GPL-3.0 | `LICENSE.txt` |
| mcl_decor | `server/mods/mcl_decor/` | GPL-3.0 distribution with separately attributed code, textures, and sounds under additional licenses, including LGPL and Creative Commons variants | `LICENSE` and the detailed asset/code list in `README.md` |
| Christmas decorations | `server/mods/wetlands_christmas/` | MIT from the original component | `LICENSE.txt` and `README.md` |
| mypark | `server/mods/mypark/` | Code MIT; media CC0 | `LICENSE` |

The table summarizes notices rather than replacing them. In particular, a
single component can contain files under several licenses.

## Components requiring inventory work

- `server/games/mineclone2/` is empty in this checkout, so the configured
  VoxeLibre distribution and its per-file licenses could not be verified here.
- `server/games/capturetheflag/` is installed separately according to the CTF
  documentation but is absent from this checkout; its game and recursively
  fetched dependencies must be inventoried from the exact deployed revision.
- Several mod directories have missing, incomplete, or conflicting top-level
  notices. For example, `server/mods/chess/` includes a GPL-3.0 license file
  while `original-readme.txt` identifies the original release as WTFPL, and
  `server/mods/automobiles_pck/` contains an MIT `LICENSE` while adaptation
  documentation records GPL-3.0 terms for modifications. These require
  provenance and authorship review, not an inferred repository-level license.
- Mods and files previously marked GPL or another license have intentionally
  not been relicensed by this normalization.

## Assets awaiting verification

The following asset groups are **not cleared by this notice**. Their provenance,
copyright holders, source URLs, modification history, and redistribution terms
must be verified asset by asset before treating them as redistributable:

- player skins under `server/skins/` and world/media skin collections;
- NPC skins, franchise-inspired textures, models, and voice/media files under
  custom Wetlands mods, including `server/mods/wetlands_npcs/`;
- music and recordings under `server/mods/wetlands-music/`,
  `server/mods/valdivia_music/`, `server/mods/valdivia_discoteca/`, and related
  world media;
- fan art, screenshots, gallery images, logos, and other third-party visual
  material in the landing page, documentation, and mod asset directories.

Inclusion in the repository, an attribution without license terms, or a claim
that an asset is fan-made does not establish permission to redistribute it.
Do not add a license label unless supported by evidence from the rights holder
or another reliable provenance record.
