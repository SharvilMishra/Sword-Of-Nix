# Blue Wraith Runtime Sprite Set

This is the active player character art, based on the design reference supplied by the user. The generated transparent source sheets are preserved in `source/`; runtime files are lossless WebP frame crops on aligned 192×192 canvases.

| Animation | Runtime frames | Source sheet area |
| --- | ---: | --- |
| Idle | 4 | Main sheet, row 1 |
| Run | 4 | Main sheet, row 2 |
| Jump | 4 | Separate jump sheet, 2×2 |
| Katana attack | 4 | Main sheet, row 3 |
| Defeat | 4 | Main sheet, row 4 |

`scripts/animation_frames.gd` loads these sequences. The original supplied hero sprites remain intact under `assets/characters/hero/` as source-project material, but are no longer used for the playable hero.
