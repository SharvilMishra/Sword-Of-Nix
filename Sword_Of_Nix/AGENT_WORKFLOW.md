# AI Agent Workflow — Sword Of Nix

Use this guide when continuing the project in another AI coding agent.

## Read first

1. `MEMORY.md` for current project state and decisions.
2. `USER_PROFILE.md` for user preferences and project interests.
3. `README.md` and `docs/UMBRAL_RUN_README.md` for project operation.
4. `docs/ENTITY_DESIGNS.md` before changing characters or game entities.
5. Relevant source-game provenance/license notes before changing or redistributing supplied assets.

## Working rules

- Work in the existing project directory and preserve the current Godot project structure.
- Confirm the actual project root before editing. The project is the folder containing `project.godot`.
- Inspect the relevant scene, script, resources, input map, documentation and existing tests before making a change.
- Follow the user's latest instruction if it updates a preference in this handoff. Update the docs and related UI strings when controls or music routing change.
- Make complete, coherent edits across the game: for example, a control change may require the input map, player logic, tutorial, HUD, title screen, localization and docs to agree.
- Do not overwrite or remove supplied source art, music, story files, notices or manifests without an explicit request. Keep attribution/licensing/provenance intact.
- Prefer reusing project assets and established visual style. For visual/UI work, use the supplied references and current assets rather than inventing unrelated branding.
- Do not start Android conversion/APK publishing until the user says the other game work is ready.
- Never claim a change is live in an open Godot session unless that session was actually refreshed and observed.

## Verification and reporting

- First check whether Godot 4.7 is available. Open/import the project and run the main scene when possible; capture/fix parser or runtime errors.
- Run an existing check only when appropriate for the available environment. Distinguish static inspection from a real Godot run and from automated checks.
- If the engine is unavailable, make safe source changes, perform limited static checks where useful, and explicitly list the runtime checks still pending.
- After changes, report: files/areas changed, behavior implemented, checks actually performed, and remaining limitations. Keep the summary concise and understandable to a non-specialist.
- Do not claim tests passed unless they were run and passed.

## Current game decisions to preserve

- Title: **Sword Of Nix**.
- Menu: cyberpunk paintstroke treatment based on rainy Nix City reference; numbered navigation; includes play/enter city, story, Warden challenge, Character & Gear, Settings.
- Player: user's blue masked swordsman reference, with swept dark hair, glowing cyan visor, navy/cobalt armor, trailing blue scarf and cyan katana. Active 4-frame animations are under `assets/characters/blue_wraith/`; original supplied hero sprites remain intact but inactive.
- Controls: A/D or arrows move; Space double jump (maximum 2); F continues story; J/X or left-click slashes; L/Shift focus; hold D+R for focus dash; S/Down + Space drops through; Escape pauses; Backspace restarts.
- Player has 3 HP, a brief invulnerability window after damage, and flashing feedback. At zero HP, Backspace retries the current section and Escape returns to title. The previous runtime rewind-on-death flow is removed.
- Progress is saved locally through `scripts/save_store.gd` to Godot `user://`: current level, highest unlocked level, completed levels, tutorial completion and best rooftop time. The title Continue route resumes the current level from its start; there are no mid-level checkpoints yet.
- Music: Headlights on menu/general gameplay per project guide; Steel Against the Horizon for story and battle. Follow more specific future user instructions if they revise this.
- Mobile/Android: future phase after other requested changes.

## Tool and environment notes

- Project claims Godot 4.7 compatibility in `project.godot`; use a Godot 4.7-compatible editor/runtime.
- Main scene: `scenes/title_screen.tscn`.
- On the prior session, Godot was not found on PATH and no editor runtime validation was performed. Recheck on the next machine; do not assume the environment is the same.
- The project folder was not a Git repository in the prior inspection. Do not assume Git history exists; inspect before using Git workflows.
