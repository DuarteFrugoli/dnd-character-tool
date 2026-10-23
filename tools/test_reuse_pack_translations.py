import unittest

from reuse_pack_translations import identical_entry_ids, seed_overlay


class ReusePackTranslationsTest(unittest.TestCase):
    def test_named_entries_require_every_english_field_to_match(self):
        old = [
            {"name": "Rope", "weight": 10},
            {"name": "Torch", "weight": 1},
        ]
        new = [
            {"name": "Rope", "weight": 5},
            {"name": "Torch", "weight": 1},
        ]
        self.assertEqual(
            identical_entry_ids("tools.json", old, new),
            {"Torch": "Torch"},
        )

    def test_resource_ids_can_change_but_rules_must_match(self):
        old = {"resources": {
            "rage": {"name": "Rage", "max": "2", "recharge": "long_rest"},
            "focus": {"name": "Focus", "max": "2", "recharge": "short_rest"},
        }}
        new = {"resources": {
            "2024_rage": {"name": "Rage", "max": "2", "recharge": "short_rest"},
            "2024_focus": {"name": "Focus", "max": "2", "recharge": "short_rest"},
        }}
        self.assertEqual(
            identical_entry_ids("feature_usages.json", old, new),
            {"2024_focus": "focus"},
        )

    def test_existing_translations_are_never_replaced(self):
        result, additions = seed_overlay(
            "feature_usages.json",
            {"2024_rage": "rage", "2024_focus": "focus"},
            {"resources": {"rage": {"name": "Furia"},
                           "focus": {"name": "Enfoque"}}},
            {"resources": {"2024_rage": {"name": "Ira"}}},
        )
        self.assertEqual(additions, {"2024_focus": {"name": "Enfoque"}})
        self.assertEqual(result["resources"]["2024_rage"]["name"], "Ira")

    def test_old_overlay_fields_not_used_in_2024_are_dropped(self):
        result, additions = seed_overlay(
            "classes.json", {"Wizard": "Wizard"},
            {"Wizard": {"name": "Mago", "subclassFeatureName": "Tradicao",
                        "startingEquipment": {"fixed": ["Cajado"]}}},
            {},
        )
        self.assertEqual(
            additions,
            {"Wizard": {"name": "Mago", "subclassFeatureName": "Tradicao"}},
        )
        self.assertEqual(result, additions)


if __name__ == "__main__":
    unittest.main()
