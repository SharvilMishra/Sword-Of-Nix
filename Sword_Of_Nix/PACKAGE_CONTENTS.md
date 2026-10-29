# Sword Of Nix Source Package

This package is the complete editable Sword Of Nix Godot project, not only a Web export. It integrates the supplied Shadow source into the initialized Godot 4.7 `game-scroller` project and includes the entity-design catalogue.

## Included

- `project.godot`, `export_presets.cfg`, all gameplay scenes, GDScript source, shaders, autoloads, game data, tests and package/runtime configuration.
- Supplied character animation frames and manifests, rooftop/interior/world/story art, audio, fonts, required license notices and the game-specific favicon/share cover.
- The editable pre-PCK loading shell, stylesheet, builder and export manifest, plus the generated `web/loading.html` snapshot used by the Web export preset.
- Project guide, full entity-design catalogue, upstream source documentation, original Chinese story, source SHA manifest, license/provenance records and the nested original `inputs/ying-source.zip` archive.
- The nested upstream source-input archive is retained byte-for-byte; see [`docs/source-game/INPUT_ARCHIVE.md`](docs/source-game/INPUT_ARCHIVE.md) for its checksum and the original Shadow source-package URL.

## Open and run

Use Godot 4.7 or a compatible Godot 4.7 build. Open `project.godot` and run the main scene `scenes/title_screen.tscn`. The project’s editable game guide contains the keyboard controls and Web export steps.

## Intentionally omitted

The source ZIP excludes `.git/`, `.godot/` import/cache data, `node_modules/`, logs, generated `dist/` and `site/` exports, temporary captures and local platform state/secrets. The upstream-generated `site/` is not needed to run or rebuild the game; the current Godot project, Web preset and loading-shell sources are included.

The inherited managed game runtime itself is platform-managed and is not redistributed. Its `npm run check` aliases are useful only inside the initialized managed game-development environment; ordinary Godot editing and play do not require them.
