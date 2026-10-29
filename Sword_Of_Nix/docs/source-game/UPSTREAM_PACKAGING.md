# Upstream Shadow Source-Pack Note (English Translation)

This is a translated copy of the supplied source archive’s `打包说明.md`, preserved unchanged as `UPSTREAM_PACKAGING_ZH.md`. The original note describes the upstream local `zero-shadow` snapshot; it does **not** describe this renamed, integrated Umbral Run project unless a distinction is stated below.

## Upstream archive contents

The original source snapshot contains the Godot project configuration, scenes, GDScript, shaders and autoload scripts; the existing `assets/` collection, including files ignored by Git but present in the source tree; the Chinese story file and bilingual translation catalog; fonts and their notices; export settings, the Web loading page, tests, project documentation, asset-source records and lock manifests. The original package also retained its `inputs/` files and generated `site/` directory. Its `SOURCE_MANIFEST.json` lists original paths, byte counts and SHA-256 hashes for integrity checks.

## Opening the upstream project

After extraction, open `zero-shadow/project.godot` in Godot 4.7 or another compatible Godot 4.7 build. Godot recreates its `.godot/` import cache on first import. The source package is not a release build that can simply be double-clicked.

The upstream `npm` commands require the Manus Game Runtime (`GAME_RUNTIME`), which was not part of the source archive. That managed runtime is not needed to edit or run the Godot project directly.

## Upstream exclusions

The original archive omitted `.godot/`, Git and local Manus state/history, logs, temporary `.work/` data, `node_modules/`, build directories such as `dist/`, generated `outputs/` and local environment secrets. Historical paragraphs in the upstream README may not match the current project; consult current project configuration and the current README first.

## Scope of the Umbral Run project ZIP

The Umbral Run package integrates the source code and runtime assets into the initialized `game-scroller` project. It retains the nested original `inputs/ying-source.zip`, upstream source documentation, `SOURCE_MANIFEST.json`, the source Chinese story and provenance/license files under `docs/source-game/`. Unlike the upstream snapshot described above, the Umbral Run ZIP deliberately omits the old generated `site/` build and the source-only `manus-webdev.json` platform state. It also omits transient caches and local exports. Re-export the current Web build from the included Godot project and editable shell sources as described in [`../UMBRAL_RUN_README.md`](../UMBRAL_RUN_README.md).
