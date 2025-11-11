# Runebound Magic

Desktop cinematic experience built with Qt/QML for the Runebound Magic universe.  
This repository also contains tooling for seeding Firestore with the sample inventory system used by the lobby hero flow.

## Inventory Schema

- `data/inventory_schema.json` holds the canonical sample dataset:
  - `items`: global item templates (name, rarity, stats).
  - `users`: sample player document with profile, inventory entries, and equipment slots.
  - `recipes`: crafting definitions.
  - `metadata`: schema info/versioning.
- Use this file as a reference in QML or for seeding Firestore. Modify or extend it to match production content.
- `data/armour_items.json` includes derived armor items based on the images under `assets/images/Armour/`. Import it the same way as the main schema to seed armor templates.
- `data/gear_items.json` captures weapons, shields, and accessory assets under `assets/images/{weapons,shield,Accessories}`.
- `data/tiles.json` mirrors the match-3 tile art in `assets/images/tiles/` and seeds the `tiles` collection. Each entry includes the in-game description plus the asset path so the desktop client can stay in sync with Firestore.

## Firestore Import Script

`scripts/import_inventory.py` reads the JSON schema and writes it to Firestore using `firebase_admin`.

```
python -m venv .venv
source .venv/bin/activate
pip install firebase-admin
python scripts/import_inventory.py \
    --credentials path/to/serviceAccountKey.json \
    --schema data/inventory_schema.json
```

To import just the match-3 tile definitions:

```
python scripts/import_inventory.py \
    --credentials path/to/serviceAccountKey.json \
    --schema data/tiles.json
```

Notes:
- The `--schema` flag is optional; by default it points to the file in `data/`.
- The script writes into collections: `items`, `recipes`, `tiles`, `metadata/schema`, and `users/{userId}/(inventory, equipment)`—only the sections present in the JSON are touched.
- Each run overwrites documents with the same IDs; adjust the script if you need merge-only behavior.

## Development Quickstart

```
cmake -S . -B build -DQt6_DIR=/usr/lib/x86_64-linux-gnu/cmake/Qt6
cmake --build build
./build/RuneboundMagicApp
```

Ensure Qt 6.9+ and the Multimedia/QuickControls2 modules are installed. Update `src/firebaseconfig.h` with your project credentials if you deploy to a different Firebase project.
