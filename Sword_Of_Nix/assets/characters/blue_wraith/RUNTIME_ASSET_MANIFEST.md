# Klint Runtime Sprite Set

This is the active player character art, based on the design reference supplied by the user. The original transparent source sheets are preserved in `source/`. Klint's idle, run, attack, and death animations use the cleaned `source/klint_main_sheet_clean.png` atlas; it contains no ground reflection or mirrored duplicate. The jump animation uses the four aligned WebP frame crops.

| Animation | Runtime frames | Source sheet area |
| --- | ---: | --- |
| Idle | 4 | Main sheet, row 1 |
| Run | 4 | Main sheet, row 2 |
| Jump | 4 | Separate jump sheet, 2×2 |
| Katana attack | 4 | Main sheet, row 3 |
| Defeat | 4 | Main sheet, row 4 |

`scripts/animation_frames.gd` loads these sequences. The original supplied hero sprites remain intact under `assets/characters/hero/` as source-project material, but are no longer used for the playable hero.
