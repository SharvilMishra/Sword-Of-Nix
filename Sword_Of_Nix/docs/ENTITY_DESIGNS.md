# Sword Of Nix — Entity Designs

This catalogue indexes the playable actors, enemy roster, projectiles, story-only character and world pieces preserved from the supplied Shadow source. The ZIP contains the original frame art; this guide identifies the role and authored asset paths rather than replacing or redrawing the designs.

## Visual language

The game is a rain-soaked, blue-black cyber-noir world. The player reads through a restrained cyan/teal edge light and katana glow; ordinary threats are differentiated by dark uniforms, a red blade or red weapon accents, and readable attack wind-ups. The Warden escalates the palette with a stronger crimson rim and warm amber bounce light. Wet rooftops, dim industrial interiors, distant skyline silhouettes, rain and sparse warm warning lights keep the silhouettes legible. The post-boss comic sequence shifts to illustrated story panels while preserving the same city/character identity.

## Character and entity roster

| Entity | Design and gameplay identity | States / animation art | Implementation and asset paths |
| --- | --- | --- | --- |
| **Blue Wraith / Nixblade (player)** | The user-selected cobalt-blue cyber-ninja: swept dark hair, luminous visor, navy/cobalt armor, trailing blue scarf and cyan katana. The design is now used by the playable hero, with the matching figure shown on Character & Gear. Equipment includes hood/visor, chest and shoulder armor, bracers, energy sash, utility belt/sheath, knee/shin plates and armored boots. | `idle`, `run`, `jump`, `attack`, `death` (4 frames each). | `scripts/player.gd`, `scripts/animation_frames.gd`, `scripts/title_screen.gd`; runtime frames in `assets/characters/blue_wraith/{idle,run,jump,attack,death}/`; source sheets and frame details in `assets/characters/blue_wraith/`. The previous supplied hero art remains under `assets/characters/hero/`. |
| **Akai blade guard** | Close-range enforcer in dark armor with red/magenta cloth or armor accents and a red-lit blade. It patrols, turns toward the player, closes distance, telegraphs a melee strike and attacks at close range. The player can take three hits before defeat. | `idle` (1), `run` (13), `attack` (12), `death` (12). | `scripts/enemy.gd` (`kind == "blade"`); frames under `assets/characters/blade_guard/{idle,run,attack,death}/`. |
| **Akai gunner** | Ranged enforcer in dark tactical armor with a compact firearm/energy weapon. It keeps distance, faces the player, visibly winds up its shot and sends a hostile projectile across the room. | `idle` (1), `walk` (13), `shoot` (12), `death` (12). | `scripts/enemy.gd` (`kind == "gunner"`) and `scripts/projectile.gd`; frames under `assets/characters/gunner/{idle,walk,shoot,death}/`. |
| **The Warden (final boss)** | The final Akai stronghold defender. It reuses the blade-guard animation art as its base silhouette but is enlarged and receives a distinct crimson key rim plus amber bounce light, a dedicated health display, hit flash and strong attack rings. The default boss has 25 health segments; a melee parry or reflected boss round removes two. | Reuses the blade-guard `idle`/`run`/`attack`/`death` sequences; boss states are `INTRO`, `RECOVER`, `MELEE_WINDUP`, `MELEE_DASH`, `TELEPORT_IN`, `RANGED_WINDUP`, `RANGED_BURST`, `STAGGER` and `DEAD`. | `scripts/boss.gd`, `scripts/boss_battle.gd`; shared art in `assets/characters/blade_guard/`; boss encounter tuning in `scripts/tuning_store.gd`. |
| **Hostile projectile** | Small scarlet/orange shot with a luminous core and short warm trail. The circular hit area is intentionally distinct from character art; it can be read as it crosses dark rain and skyline. | Fired by gunners and the Warden; expires after its lifetime or world boundary. | `scripts/projectile.gd`; Godot draws the projectile and its hit radius in code. |
| **Reflected projectile** | The same shot becomes bright cyan after a successful parry, reverses its trajectory and accelerates to three times its incoming speed. It can sweep through other hostile rounds before its first enemy impact. | `HOSTILE → REFLECTED → EXPIRED`; reflected rounds intercept hostile bullets and hit the first enemy along their path. | `scripts/projectile.gd` (`reflect`, segment/capsule collision and interception methods); cyan trail is drawn in `_draw()`. |
| **Akai dialogue actors** | Tutorial and interior guards use the same blade-guard/gunner designs; XML-driven barks and staged conversations give them identity without a separate portrait or duplicate sprite set. They are ordinary combat actors between dialogue beats. | Briefing, rooftop surprise, tutorial lessons, guard chatter on each of five floors, Warden arrival and defeat dialogue. | `data/story.xml`, `data/i18n.json`, `scripts/tutorial.gd`, `scripts/interior_level.gd`, `scripts/boss_battle.gd`. |
| **Calico cat (epilogue character)** | A story reveal rather than a combat actor: the mysterious “cargo” is shown as a trembling calico exotic-shorthair cat in the illustrated post-boss sequence. It has no combat collision or in-level AI. | Appears in the final illustrated beats and the “TO BE CONTINUED…” ending. | Story/cinematic images under `assets/story/`; panel order, captions and timing are authored in `data/story.xml` and consumed by the post-boss scene. |

Animation counts above refer to the supplied frame sets: the numbered WebP images are the actual design poses, and their neighboring `.animation.json` files list the order, cover frame and authored playback metadata. Each frame keeps its source 192×192 transparent canvas/pivot alignment so changes in pose do not shift the shared foot baseline.

## Combat and readable tells

- The hero’s directional slash-dash is the principal melee response. Focus uses a separate energy meter and slows simulation; combining it with a direction and attack creates the signature parry/reflect moment.
- Blade guards visibly wind up before committing a close-range strike. Gunners stop to telegraph a shot. Both normal enemy archetypes remain distinct by weapon, animation and engagement distance.
- The Warden alternates a fast approach/dash or short teleport melee with a ranged burst. Colored attack arcs/rings, the boss-health strip and brief stagger make these patterns readable; the boss is a multi-hit encounter, unlike the one-hit ordinary enemies.
- A reflected cyan round is both defense and offense: it can intercept hostile fire on its route before it reaches the first living enemy. Death, impact, rain, parry and dialogue events use the source’s audio/visual feedback rather than new placeholder art.

## World and environmental design

| Set piece | Visual role | Assets / source owner |
| --- | --- | --- |
| Rain-lit rooftop and distant city | Main horizontal run; layered skyline, wet industrial ground, machines and foreground silhouettes establish depth. | `assets/world/skyline_far.webp`, `assets/environment/roof_ground_tile.webp`, `roof_ground_tile_b.webp`, `rooftop_machine_a.webp`, `rooftop_machine_b.webp`; `scripts/game.gd`. |
| One-way catwalks | Rooftop combat routes and the vertical ascent’s alternating jump/drop-through platforms. These are traversal geometry, not character entities. | `assets/environment/catwalk_platform.webp`; `scripts/interior_level.gd`. |
| Akai interior hideout | Five-floor power-station interior with elevated guards and a protected lower landing. | `assets/environment/interior_hideout.webp`; interior structure and encounters in `scripts/interior_level.gd`. |
| Exit gate / level transition | Industrial gate marks completion of the rooftop and routes into the next stronghold stage. | `assets/environment/exit_gate.webp`; transition logic in `scripts/game.gd`. |
| Rain, lightning and storm | Atmospheric weather also frames the materialization and boss introduction. Rain, lightning flashes and thunder support timing without replacing collision rules. | `scripts/game.gd`, `scripts/tutorial.gd`, `scripts/boss_battle.gd`; `assets/audio/rain_loop.ogg`, `thunder_1.ogg`, `thunder_2.ogg`, `thunder_3.ogg`. |
| Story illustrations | Mission briefing, reveal and epilogue change presentation from in-world action to framed sequential art; text remains editable and live. | `assets/story/`, `data/story.xml`, `scripts/tutorial.gd`, `scripts/post_boss_cinematic.gd`. |

Traversal hazards are chiefly platform gaps, one-way platforms and crossfire. The player can drop through a catwalk with down plus jump; no added trap types or new actor art were introduced. The Warden fight is a separate arena scene reached after the interior gate.

## Source art inventory

- `assets/characters/hero/` — all playable hero animation frames and manifests.
- `assets/characters/blade_guard/` — melee guard art and the shared Warden base animation set.
- `assets/characters/gunner/` — ranged guard animation frames.
- `assets/environment/` and `assets/world/` — rooftop/interior tiles, machinery, gate, skyline and title splash.
- `assets/story/` — supplied story/epilogue visuals.
- `assets/audio/` — rain, thunder, slash, enemy hit, parry, dialogue tick, victory and gameplay/boss music.
- `assets/fonts/` and `data/licenses/` — bundled source font and notices.

The original source README, story-editing guide, font notices, archive manifests, credits and licensing/provenance records are retained under `docs/source-game/` and `docs/`. The root README describes the current **English-only Sword Of Nix** configuration; the upstream README is preserved as historical source documentation.
