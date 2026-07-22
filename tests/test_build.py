from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist" / "lotus-library.lua"
BUILD = ROOT / "scripts" / "build.py"
EXECUTOR = ROOT / "script-test" / "executor.lua"
CACHED_DIST = ROOT / "script-test" / "lotus-library.lua"

EXPECTED_MODULES = [
    "src/Prelude.lua",
    "src/Util/Signal.lua",
    "src/Util/Maid.lua",
    "src/Util/Tween.lua",
    "src/Theme.lua",
    "src/Components/Base.lua",
    "src/Components/Button.lua",
    "src/Components/Toggle.lua",
    "src/Components/Slider.lua",
    "src/Components/Progress.lua",
    "src/Section.lua",
    "src/Tab.lua",
    "src/Window.lua",
    "src/init.lua",
]


class LotusBuildTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        result = subprocess.run(
            [sys.executable, str(BUILD)],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise AssertionError(
                f"Build failed with exit code {result.returncode}\n"
                f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
            )
        cls.output = DIST.read_text(encoding="utf-8")

    def test_build_produces_single_standalone_file(self) -> None:
        self.assertTrue(DIST.is_file())
        self.assertIn("return Lotus", self.output)
        self.assertNotIn("require(", self.output)
        self.assertNotIn("game:HttpGet", self.output)
        self.assertNotIn("loadstring", self.output)

    def test_modules_are_bundled_in_manifest_order(self) -> None:
        positions = []
        for module in EXPECTED_MODULES:
            marker = f"--#region {module}"
            self.assertIn(marker, self.output)
            positions.append(self.output.index(marker))
        self.assertEqual(positions, sorted(positions))

    def test_public_api_contract_is_present(self) -> None:
        required_contracts = [
            "function Lotus.new(",
            "function Lotus.SetTheme(",
            "function Lotus.ResolveTheme(",
            "function Window:AddTab(",
            "function Window:SetTitle(",
            "function Window:SetSidebarTitle(",
            "function Window:SelectTab(",
            "function Window:Notify(",
            "function Window:Destroy(",
            "function Tab:AddSection(",
            "function Section:AddButton(",
            "function Section:AddToggle(",
            "function Section:AddSlider(",
            "function Section:AddProgress(",
            "function Toggle:Set(",
            "function Slider:Set(",
            "function Progress:Set(",
        ]
        for contract in required_contracts:
            self.assertIn(contract, self.output)

    def test_named_theme_presets_are_bundled(self) -> None:
        for preset in (
            "Default",
            "Midnight",
            "Rose",
            "Graphite",
            "Ocean",
            "Emerald",
            "Amber",
            "Light",
        ):
            self.assertIn(f"\t{preset} =", self.output)

        self.assertIn('if type(theme) == "string" then', self.output)

    def test_modern_visual_tokens_are_applied(self) -> None:
        for token in (
            "theme.SurfaceMuted",
            "theme.BorderStrong",
            "theme.SubtleText",
            "theme.AccentSoft",
            "theme.Shadow",
        ):
            self.assertIn(token, self.output)

        self.assertIn('Name = "WindowShadow"', self.output)

    def test_shadow_uses_matching_size_constraints(self) -> None:
        self.assertIn('local shadowSizeConstraint = create("UISizeConstraint"', self.output)
        self.assertIn("self._shadowSizeConstraint = shadowSizeConstraint", self.output)
        self.assertIn("self._shadowSizeConstraint.MinSize = Vector2.new(560, 68)", self.output)
        self.assertIn("self._shadowSizeConstraint.MinSize = Vector2.new(560, 340)", self.output)

    def test_executor_prefers_candidate_bundle_and_checks_version(self) -> None:
        executor = EXECUTOR.read_text(encoding="utf-8")
        self.assertIn('local EXPECTED_VERSION = "1.1.0"', executor)
        self.assertIn('local LOCAL_LIBRARY_PATH = "script-test/lotus-library.lua"', executor)
        self.assertIn('local EXECUTOR_LIBRARY_PATH = "lotus-library.lua"', executor)
        self.assertIn("isfile(LOCAL_LIBRARY_PATH)", executor)
        self.assertIn("readfile(LOCAL_LIBRARY_PATH)", executor)
        self.assertIn("isfile(EXECUTOR_LIBRARY_PATH)", executor)
        self.assertIn("library.Version ~= EXPECTED_VERSION", executor)
        self.assertIn("/refs/tags/v1.1.0/dist/lotus-library.lua", executor)
        self.assertNotIn("/refs/heads/main/dist/lotus-library.lua", executor)

    def test_executor_cached_bundle_matches_distribution(self) -> None:
        self.assertEqual(
            CACHED_DIST.read_text(encoding="utf-8"),
            self.output,
        )

    def test_output_has_no_unresolved_build_tokens(self) -> None:
        self.assertNotIn("{{LOTUS_", self.output)
        self.assertNotIn("__BUILD_", self.output)
        self.assertNotIn("--!include", self.output)

    def test_check_mode_confirms_dist_is_current(self) -> None:
        result = subprocess.run(
            [sys.executable, str(BUILD), "--check"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("up to date", result.stdout.lower())


if __name__ == "__main__":
    unittest.main()
