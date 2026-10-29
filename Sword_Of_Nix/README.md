# Sword Of Nix

**Sword Of Nix** is an English-language, offline 2D action-scroller built from the supplied Shadow game source and integrated into the initialized Godot 4.7 `game-scroller` project.

Start with the [project guide](docs/UMBRAL_RUN_README.md) for gameplay, controls, source layout and export instructions. The [entity design catalogue](docs/ENTITY_DESIGNS.md) documents the player, enemy roster, Warden, projectiles, story character, world sets and their exact asset paths. The [source-package contents manifest](PACKAGE_CONTENTS.md) summarizes what is included in the complete project ZIP.

Open `project.godot` in Godot 4.7 to run the game from `scenes/title_screen.tscn`. The title menu offers Play, Story, Warden Challenge, Character & Gear, and Settings. The playable hero now uses the user's blue masked-swordsman design across idle, run, jump, attack and defeat animation frames; Character & Gear displays the matching hero and equipment. The complete source, project configuration and supplied runtime assets are included in this package. The original Chinese story file, upstream documentation, archive manifests, credits and licensing/provenance notes are preserved under `docs/source-game/`.

Stage progress is stored in Godot's per-user save data. Completing the story prologue, rooftop and interior unlocks the next level; **Enter the City** resumes from the current saved level. Continuing restarts that level from its beginning, rather than restoring an in-level checkpoint.
