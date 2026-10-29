# Sword Of Nix — Project Guide

**Sword Of Nix** is the English-titled remix of the supplied **Shadow** game, integrated into the initialized Godot `game-scroller` project. The integrated project keeps the supplied story, playable hero, blade-guard/gunner roster, stages, boss encounter, soundtrack and entity artwork while retaining the managed Godot Web runtime.

## Game overview

Breach a rain-lit rooftop, climb through the Akai gang’s five-floor power-station hideout and face the Warden. Run, jump and use directional katana slashes to attack or parry. Focus slows time to make incoming fire and melee tells readable; reflected rounds become offensive projectiles. The hero has three HP and briefly flashes after taking damage; the Warden is a 25-segment boss. The opening story/tutorial, rooftop, interior ascent, separate boss arena and post-boss illustrated epilogue are preserved from the supplied game.

The game is offline. It has no account, server, network play or online leaderboard. Regular rooftop/interior gameplay uses `BGM SONG/Headlights_on_Wet_Pavement.mp3`; the story prologue and Warden battle use `BGM SONG/Steel_Against_the_Horizon.mp3`. The runtime UI and story dialogue are English. The supplied Chinese story remains preserved at `docs/source-game/data/story_source_zh.xml`, and the English translation catalog remains in `data/i18n.json`. The original source title/branding is replaced by **Sword Of Nix** in the game menu, Godot project, browser title, loading screen and share metadata. Source credits, notices, asset provenance and licensing records are retained.

The title menu uses the supplied rain-lit city artwork with a cyan paintstroke treatment and distinct Play, Story Prologue, Warden Challenge, Character & Gear and Settings choices. Character & Gear shows the Blue Wraith concept and its full katana, armor and field kit. Settings include saved master volume, fullscreen display and a quick control reference.

## Controls

| Input | Action |
| --- | --- |
| `A` / `D` or Left / Right | Move |
| `Space` / touch jump | Jump (up to two jumps before landing) |
| Hold `S` / Down, then `Space` | Drop through a one-way platform |
| Hold `D` + `R` | Focus dash and slash to the right |
| `J`, `X`, or left-click | Directional slash / projectile parry |
| Hold `E` | Focus slow-motion; 3-second cooldown after release |
| Backspace | Restart the current room/level |
| Escape | Pause or resume |
| Use the highlighted title-menu option | Start the opening flow or open that menu page |
| `F` / touch **NEXT** during story dialogue | Continue the story |

The player HUD shows remaining HP. Damage grants a short invulnerability window. At zero HP, press **Backspace** to retry the current section or **Escape** to return to the title screen.

## Saved level progress

The game keeps a local save in Godot's `user://` data folder. It records completed and unlocked levels, the current level to continue, tutorial completion and the best rooftop time. Completing the prologue unlocks the rooftop; clearing the rooftop unlocks the Akai Hideout; clearing the hideout unlocks the Warden. The title menu's **Enter the City** option continues from the current saved level. It starts that level from its beginning; in-level checkpoints are not currently saved. Existing save files are upgraded automatically while preserving tutorial completion and best time.

The title menu keeps the story/prologue and Warden test routes. Landscape Android support uses touch movement, jump, slash, focus, pause and story-continue buttons. In a development preview, `F1` or `P` opens the source tuning panel. The prepared release projection excludes developer-only Tweak UI.

## Run and Web export

Open `project.godot` in **Godot 4.7** and run it. The main scene is `scenes/title_screen.tscn`. The project includes Web and Android export presets. The Android preset exports a debug-signed, arm64 APK to `dist/UmbralRun-debug.apk`; Godot Android export templates, the Android SDK and Java SDK must be installed/configured in Godot first. The Web export uses a custom shell; generate it from the editable source before exporting:

```sh
node web/build-shell.mjs --output web/loading.html
```

Then select the `Web` preset in Godot and export. The game's media remain Godot project resources. In the initialized managed game-development environment, `npm run check` runs the managed finite verification and `npm run check -- --pack` checks the matching prepared release pack; those aliases use the current managed game-development runtime and are not portable stand-alone Godot commands.

## Project map

| Path | Purpose |
| --- | --- |
| `project.godot`, `export_presets.cfg` | Project identity, main scene, autoloads and Web/Android export settings. |
| `scenes/` | Title, tutorial, rooftop run, interior and Warden arena. |
| `scripts/` | Player, shared actor/enemy behavior, projectiles, bosses, story, UI, audio, effects, input, saves and tuning. |
| `data/story.xml`, `data/i18n.json` | Editable dialogue/story flow and English runtime text. |
| `assets/characters/` | Hero, blade guard and gunner animation frame sets with per-sequence manifests. |
| `assets/world/`, `assets/environment/`, `assets/story/` | City, rooftop, interior, gate, briefing and post-boss story art. |
| `assets/audio/`, `assets/fonts/`, `data/licenses/` | Supplied soundtrack/SFX, game font and licensing notices. |
| `docs/ENTITY_DESIGNS.md` | Entity-by-entity visual, behavioral and asset-path catalogue. |
| `docs/source-game/` | Preserved upstream guides, archive manifests, provenance, font notices and licensing notes. |
| `test/` | Supplied boot, story, tutorial, interior, boss and responsive-layout checks. |
| `web/` | Game-specific pre-PCK loading shell source, stylesheet and builder. |

The initialized scroller’s managed helper files and template reference material are preserved for compatibility and source transparency. The active game and Web shell use the integrated Shadow experience; unneeded template art is excluded from the Web export. This guide supplements the root starter workflow notes and is the project-specific source/run reference.
