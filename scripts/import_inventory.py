#!/usr/bin/env python3
"""
Seed Firestore with the Runebound Magic inventory schema.

Usage:
    python scripts/import_inventory.py --credentials path/to/serviceAccountKey.json \
        --schema data/inventory_schema.json

The script uses firebase_admin to authenticate with the provided service account,
reads the JSON schema, and writes documents into the collections:
items, recipes, metadata/schema, users/{id}/(profile, inventory, equipment).
"""

import argparse
import json
import pathlib
from typing import Any, Dict

import firebase_admin
from firebase_admin import credentials, firestore


def load_schema(path: pathlib.Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def ensure_app(creds_path: pathlib.Path) -> firestore.Client:
    cred = credentials.Certificate(str(creds_path))
    firebase_admin.initialize_app(cred)
    return firestore.client()


def seed_items(db: firestore.Client, items: Dict[str, Any]) -> None:
    for item_id, payload in items.items():
        db.collection("items").document(item_id).set(payload)


def seed_recipes(db: firestore.Client, recipes: Dict[str, Any]) -> None:
    for recipe_id, payload in recipes.items():
        db.collection("recipes").document(recipe_id).set(payload)


def seed_metadata(db: firestore.Client, metadata: Dict[str, Any]) -> None:
    if metadata:
        db.collection("metadata").document("schema").set(metadata, merge=True)


def seed_users(db: firestore.Client, users: Dict[str, Any]) -> None:
    for user_id, user_payload in users.items():
        profile = user_payload.get("profile", {})
        if profile:
            db.collection("users").document(user_id).set({"profile": profile}, merge=True)

        inventory = user_payload.get("inventory", {})
        for inv_id, inv_payload in inventory.items():
            db.collection("users").document(user_id).collection("inventory").document(inv_id).set(inv_payload)

        equipment = user_payload.get("equipment", {})
        for slot_id, slot_payload in equipment.items():
            db.collection("users").document(user_id).collection("equipment").document(slot_id).set(slot_payload)


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Runebound Magic inventory schema into Firestore.")
    parser.add_argument("--credentials", required=True, help="Path to Firebase serviceAccountKey.json")
    parser.add_argument("--schema", default="data/inventory_schema.json", help="Path to inventory schema JSON")
    args = parser.parse_args()

    schema_path = pathlib.Path(args.schema).resolve()
    creds_path = pathlib.Path(args.credentials).resolve()
    schema = load_schema(schema_path)

    db = ensure_app(creds_path)

    if "items" in schema:
        seed_items(db, schema["items"])
    if "recipes" in schema:
        seed_recipes(db, schema["recipes"])
    if "metadata" in schema:
        seed_metadata(db, schema["metadata"])
    if "users" in schema:
        seed_users(db, schema["users"])

    print("✅ Firestore seeded with Runebound Magic inventory data.")


if __name__ == "__main__":
    main()
