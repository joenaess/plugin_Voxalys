# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later
"""Static lint tests for Praat plugin scripts."""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent


def test_license_headers():
    praat_files = list(REPO_ROOT.glob("*.praat"))
    assert len(praat_files) >= 9, f"Expected at least 9 .praat files, found {len(praat_files)}"

    for script in praat_files:
        content = script.read_text(encoding="utf-8")
        assert "SPDX-License-Identifier: GPL-3.0-or-later" in content, (
            f"Missing SPDX header in {script.name}"
        )
        assert "Copyright (C) 2007-2026 Jonas Lindh" in content, (
            f"Missing Copyright header in {script.name}"
        )


def test_balanced_blocks():
    praat_files = list(REPO_ROOT.glob("*.praat"))
    block_pairs = [
        (re.compile(r"^\s*if\b"), re.compile(r"^\s*endif\b"), "if/endif"),
        (re.compile(r"^\s*for\b"), re.compile(r"^\s*endfor\b"), "for/endfor"),
        (re.compile(r"^\s*while\b"), re.compile(r"^\s*endwhile\b"), "while/endwhile"),
        (re.compile(r"^\s*form\b"), re.compile(r"^\s*endform\b"), "form/endform"),
    ]

    for script in praat_files:
        lines = script.read_text(encoding="utf-8").splitlines()
        clean_lines = []
        for line in lines:
            stripped = line.strip()
            # Ignore comments
            if stripped.startswith("#") or stripped.startswith(";"):
                continue
            clean_lines.append(stripped)

        for open_re, close_re, label in block_pairs:
            opens = sum(1 for line in clean_lines if open_re.search(line))
            closes = sum(1 for line in clean_lines if close_re.search(line))
            assert opens == closes, (
                f"Unbalanced {label} in {script.name}: {opens} opens vs {closes} closes"
            )


def test_referenced_scripts_exist():
    # 1. Scripts in setup.praat
    setup_file = REPO_ROOT / "setup.praat"
    assert setup_file.exists()
    setup_content = setup_file.read_text(encoding="utf-8")
    referenced_scripts = re.findall(r'"([a-zA-Z0-9_-]+\.praat)"', setup_content)
    assert referenced_scripts, "No .praat scripts referenced in setup.praat"
    for ref in referenced_scripts:
        target = REPO_ROOT / ref
        assert target.exists(), f"Script {ref} referenced in setup.praat does not exist at root"

    # 2. Scripts in voice_report.praat runScript: calls
    report_file = REPO_ROOT / "voice_report.praat"
    assert report_file.exists()
    report_content = report_file.read_text(encoding="utf-8")
    run_scripts = re.findall(r'runScript:\s*"([a-zA-Z0-9_-]+\.praat)"', report_content)
    assert run_scripts, "No runScript references found in voice_report.praat"
    for ref in run_scripts:
        target = REPO_ROOT / ref
        assert target.exists(), (
            f"Script {ref} called via runScript: in voice_report.praat does not exist"
        )


def test_analysis_scripts_cleanup():
    analysis_scripts = [
        "f0_analysis.praat",
        "f0_histogram.praat",
        "phonetogram.praat",
        "ltas_analysis.praat",
        "perturbation.praat",
    ]
    for name in analysis_scripts:
        script = REPO_ROOT / name
        assert script.exists()
        content = script.read_text(encoding="utf-8")
        assert "removeObject:" in content, f"Script {name} should clean up temporary Praat objects"
