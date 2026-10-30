# Sword Of Nix — Project Memory

This is the continuation brief for the game project. Read this first, then consult `USER_PROFILE.md` and `AGENT_WORKFLOW.md` before making changes.

## Project identity

- Game name: **Sword Of Nix** (formerly the supplied Shadow / game-scroller project).
- Engine: Godot 4.7 project; main scene is `scenes/title_screen.tscn`.
- Genre: offline 2D action side-scroller with a story/tutorial, rooftop and interior stages, and a Warden boss encounter.
- The source game and its art/story assets are integrated into the initialized project. Preserve source credits, licensing, and provenance documentation.
- Player-facing language is English. Original Chinese story source and upstream documents are preserved for reference.
- Do not begin Android/mobile work yet: the user explicitly wants to make more game changes first. The project guide describes an Android export preset, but this is a future step, not the current priority.

## User's requested game direction

- Rework the existing game as a whole over time, including character models and presentation.
- The player hero should have a distinctive blue theme and read as a unique hero. Existing concept: **Blue Wraith**, documented and illustrated in `docs/ENTITY_DESIGNS.md` and `docs/concept/hero_blue_concept.png`.
- Latest character direction: use the user's newly attached blue masked swordsman (spiky dark hair, bright cyan visor, navy/cobalt armor, trailing blue scarf, cyan katana) as the actual in-game player. Runtime animation sprites are now stored under `assets/characters/blue_wraith/`; original hero frames are retained unused.
- Add a Character & Gear option, show the designed hero, and include the hero's equipment. The current menu profile covers the Nixblade katana, hood/visor, chest and shoulder armor, bracers, energy sash/scarf, belt/sheath, and knee/shin/boot armor.
- Menu art direction: cyberpunk paintstroke, rain-lit city, cyan accents, clear game-like navigation. Latest reference image is a cinematic rainy Nix City scene, title on the left, hero with glowing blue blade on the right, numbered angular menu rows, cyan active choice and red challenge choice. Its content is a visual reference, not literal in-game instructions.
- The title is “Sword Of Nix.”

## Current intended controls

- Move: A/D or arrow keys.
- Jump: Space, at most two jumps before landing.
- Story dialogue: F continues (touch NEXT on mobile when mobile work is resumed).
- Directional slash: J/X or left click.
- Focus: press E once; the world slows for 3 seconds while the player moves normally. The 10-second cooldown starts on activation. This is separate from the D+R focus dash.
- Focus dash/slash: hold D + R. Replaces the earlier L+D+J chord as the simplified dash command.
- Drop through one-way platform: hold S/Down, then Space.
- Pause: Escape; restart: Backspace.
- At zero HP: Backspace retries the current section; Escape returns to title.

Keep these consistent in tutorial prompts, title hints, HUD, input maps, and docs. Press E once to activate Focus: the world slows for 3 seconds while the player moves normally, with a 10-second cooldown from activation. The dash remains D+R.

## Music routing

- Title/menu BGM: `BGM SONG/Headlights_on_Wet_Pavement.mp3` only.
- Story prologue and Warden/battle BGM: `BGM SONG/Steel_Against_the_Horizon.mp3`.
- The user specifically asked to keep Headlights as game/menu BGM and not use it during story or battle.
- The user reported that menu BGM was not playing and asked for a fix. `scripts/title_screen.gd` now creates/starts the title player and retries on first input, but this edit has not yet been runtime-confirmed in Godot.

## Recent implementation state (needs Godot validation)

Recent changes reported in this chat:

1. `scripts/title_screen.gd` uses `assets/world/title_splash.webp`, “SWORD / OF NIX” title styling, custom angular numbered menu rows, bundled font, controls hint, title music player, Settings and Character & Gear overlays. Menu routes include Enter City, Story Prologue, Warden Challenge, Character & Gear, Settings.
2. `scripts/player.gd`, `scripts/game.gd`, `scripts/boss_battle.gd`, and `scripts/tutorial.gd` were updated for the D+R focus-dash chord and related prompts/action mapping.
3. Controls text in `docs/UMBRAL_RUN_README.md` and several tutorial/smoke/layout test expectations were updated. `data/i18n.json` was checked as valid JSON.
4. Godot was not available on PATH in the previous session, and no Godot runtime/editor verification was done. Do not claim the latest edits are confirmed to run. Open the project in Godot 4.7 and check for parse/runtime errors before further UI/audio work. The user has previously asked if opening the project in Godot will show changes directly; explain that saved project files appear when the project is refreshed/reopened, while a running game may need restart/reload.
5. Test files were edited but tests were not run. Do not claim tests passed.
6. Latest requested change replaces the runtime rewind-on-death mechanic with a 3-HP player system, short hit invulnerability, flashing feedback, HP HUD, and Backspace retry/Escape title behavior. Projectile, blade-guard and Warden hits now subtract HP. Rewind capture/selection calls were removed from gameplay, boss, tutorial and interior scripts; validate all inherited script references in Godot.
7. User shared a Godot screenshot with resource-loader errors for the new Blue Wraith WebP sprites plus empty `if` blocks in `scripts/boss_battle.gd` and `scripts/tutorial.gd`. Those empty-block parse errors are now removed. Godot-generated `.import` sidecars and imported cache files are present for the 20 Blue Wraith frame images. The Godot runtime/editor is not available to this assistant session, so re-open/rescan and run the project to confirm the errors clear.
8. Latest feedback from the user: new hero appeared to move backwards, forward dash prevented a follow-up attack, and death lacked obvious retry/leave actions. `scripts/player.gd` now treats Blue Wraith sprites as right-facing, queues an attack pressed during the dash to start immediately afterward, and game/tutorial/boss scenes have a visible death choice panel with retry and leave-to-title buttons (plus keyboard shortcuts). Runtime verification remains pending because no Godot executable is available here.
9. Jumping could visually leave the play area and ground contact could prematurely reset the jump count. The counter now resets only when grounded while not moving upward; `MAX_JUMPS` stays at 2. An invisible ceiling collider was added to rooftop, tutorial, boss and interior worlds to keep the hero in bounds. Verify in Godot after reload.

## Useful project references

Latest level-save implementation: `scripts/save_store.gd` uses schema v3 to track current level, highest unlocked level and completed level indices in Godot's user data, along with tutorial completion and best rooftop time. Title Continue resumes at the saved stage. Tutorial, rooftop, hideout and boss write progress as they complete. Old v2 saves migrate automatically. Continuing restarts at the beginning of the saved stage; there are no within-level checkpoints.

- `README.md` — short overview and how to open.
- `docs/UMBRAL_RUN_README.md` — controls, music, run/export guidance, project map.
- `docs/ENTITY_DESIGNS.md` — hero, enemies, boss, characters, and asset locations.
- `docs/source-game/` — preserved upstream/source notes, credits, licensing and provenance.
- `TODO.md` — completed setup/package tasks.
- `BGM SONG/` — user's music files; preserve filenames and routing unless asked otherwise.

## Open follow-up priorities

1. Confirm the latest title scene and scripts parse/run in Godot 4.7; fix concrete errors.
2. In the running game, verify menu music starts, loops, stops/transitions appropriately, and does not leak into story/battle.
3. Verify the menu against the supplied screenshot and refine layout/responsiveness where needed.
4. Verify the D+R tutorial and gameplay behavior, plus Space double-jump and F story continuation.
5. Continue broader game and hero/equipment improvements with the user. Only after they say the other changes are ready, return to the Android build/APK and website publishing path.

## Important unknowns

No reliable personal details such as age, location, school/work, contact information, or broader interests have been provided in the project conversation. Do not infer or invent them. Record new personal details only if the user explicitly shares them and they are useful for future collaboration.
