# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later
"""Execution tests for plugin_Voxalys scripts using headless Praat."""

import math
import shutil
import struct
import subprocess
import wave
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


def synthesize_clean_vowel(path: Path, duration: float = 1.5, f0: float = 150.0, sr: int = 44100):
    """Generate a clean synthetic harmonic pulse train with -6 dB/oct rolloff."""
    n_samples = int(duration * sr)
    samples = []
    num_harmonics = 12

    for n in range(n_samples):
        t = n / sr
        val = 0.0
        for h in range(1, num_harmonics + 1):
            amp = 1.0 / h  # -6 dB / octave rolloff
            val += amp * math.sin(2.0 * math.pi * h * f0 * t)
        samples.append(val)

    max_amp = max(abs(s) for s in samples) or 1.0
    scale = (32767.0 * 0.7) / max_amp

    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        raw_data = struct.pack(f"<{len(samples)}h", *[int(s * scale) for s in samples])
        wf.writeframes(raw_data)


def synthesize_pathological_voice(
    path: Path, duration: float = 1.5, base_f0: float = 150.0, sr: int = 44100
):
    """Generate synthetic voice with strong cycle-to-cycle jitter and shimmer."""
    samples = []
    current_time = 0.0
    cycle_idx = 0

    while current_time < duration:
        # Cycle-to-cycle jitter (+-4%) and shimmer (+-12%)
        jitter_factor = 1.0 + 0.04 * math.sin(2.7 * cycle_idx) + 0.03 * math.cos(5.1 * cycle_idx)
        shimmer_factor = 1.0 + 0.12 * math.cos(3.3 * cycle_idx) + 0.08 * math.sin(6.7 * cycle_idx)

        cycle_f0 = base_f0 / jitter_factor
        period_s = 1.0 / cycle_f0
        period_samples = int(period_s * sr)
        if period_samples < 2:
            period_samples = 2

        for i in range(period_samples):
            phase = 2.0 * math.pi * (i / period_samples)
            # Glottal-like pulse waveform with shimmer
            val = shimmer_factor * (
                math.sin(phase)
                + 0.5 * math.sin(2 * phase)
                + 0.3 * math.sin(3 * phase)
                + 0.2 * math.sin(4 * phase)
            )
            samples.append(val)

        current_time += period_samples / sr
        cycle_idx += 1

    max_amp = max(abs(s) for s in samples) or 1.0
    scale = (32767.0 * 0.7) / max_amp

    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        raw_data = struct.pack(f"<{len(samples)}h", *[int(s * scale) for s in samples])
        wf.writeframes(raw_data)


@pytest.fixture
def praat_executable():
    praat = shutil.which("praat")
    if praat is None:
        pytest.skip("Praat executable not available in environment.")
    return praat


@pytest.fixture
def test_env(tmp_path):
    """Set up temporary working directory with all praat scripts and synthesized audio."""
    for script in REPO_ROOT.glob("*.praat"):
        shutil.copy(script, tmp_path / script.name)

    clean_wav = tmp_path / "clean_vowel.wav"
    patho_wav = tmp_path / "pathological_voice.wav"
    synthesize_clean_vowel(clean_wav)
    synthesize_pathological_voice(patho_wav)

    return tmp_path, clean_wav, patho_wav


def run_praat_script(praat_bin, cwd: Path, script_content: str):
    runner = cwd / "runner.praat"
    runner.write_text(script_content, encoding="utf-8")
    # Praat 7+ requires --FULL-TRUST for directory creation and file saving
    cmd = [praat_bin, "--FULL-TRUST", "--run", "runner.praat"]
    result = subprocess.run(
        cmd,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0 and "FULL-TRUST" in result.stderr and "Unknown" in result.stderr:
        cmd = [praat_bin, "--run", "runner.praat"]
        result = subprocess.run(
            cmd,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            check=False,
        )
    return result


def test_f0_analysis_execution(praat_executable, test_env):
    cwd, clean_wav, _ = test_env
    script = f"""
sound = Read from file: "{clean_wav.name}"
runScript: "f0_analysis.praat", 75, 500, "Autocorrelation (ac)", 1, "TestClient"
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"

    png_path = cwd / "clients" / "TestClient" / "Bilder" / f"{clean_wav.stem}_F0_intonation.png"
    assert png_path.exists(), "F0 intonation PNG was not generated"
    content = png_path.read_bytes()
    assert content.startswith(PNG_MAGIC), "Generated file is not a valid PNG"
    assert len(content) > 1000


def test_f0_histogram_execution(praat_executable, test_env):
    cwd, clean_wav, _ = test_env
    script = f"""
sound = Read from file: "{clean_wav.name}"
runScript: "f0_histogram.praat", 75, 500, 60, 400, 1.0, "Blue", 1.5, 10, 1, "TestClient"
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"

    png_path = cwd / "clients" / "TestClient" / "Bilder" / f"{clean_wav.stem}_F0_histogram.png"
    assert png_path.exists(), "F0 histogram PNG was not generated"
    assert png_path.read_bytes().startswith(PNG_MAGIC)


def test_phonetogram_execution(praat_executable, test_env):
    cwd, clean_wav, _ = test_env
    script = f"""
sound = Read from file: "{clean_wav.name}"
runScript: "phonetogram.praat", 65, 800, 40, 110, "Blue", 1, 1, "TestClient"
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"

    png_path = cwd / "clients" / "TestClient" / "Bilder" / f"{clean_wav.stem}_phonetogram.png"
    assert png_path.exists(), "Phonetogram PNG was not generated"
    assert png_path.read_bytes().startswith(PNG_MAGIC)


def test_ltas_execution(praat_executable, test_env):
    cwd, clean_wav, _ = test_env
    script = f"""
sound = Read from file: "{clean_wav.name}"
runScript: "ltas_analysis.praat", 100, 5000, 1, "TestClient"
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"

    png_path = cwd / "clients" / "TestClient" / "Bilder" / f"{clean_wav.stem}_LTAS.png"
    assert png_path.exists(), "LTAS PNG was not generated"
    assert png_path.read_bytes().startswith(PNG_MAGIC)


def test_perturbation_clean_voice(praat_executable, test_env):
    cwd, clean_wav, _ = test_env
    method = "Cross-correlation (cc - recommended for perturbation)"
    script = f"""
sound = Read from file: "{clean_wav.name}"
runScript: "perturbation.praat", 75, 500, "{method}", "Save HTML report", "TestClient"
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"
    output = res.stdout

    # Verify F0 around 150 Hz
    assert "Mean F0:" in output
    for line in output.splitlines():
        if "Mean F0:" in line:
            parts = line.split(":")
            val_str = parts[1].replace("Hz", "").strip()
            f0_val = float(val_str)
            assert 148.0 <= f0_val <= 152.0, f"Mean F0 {f0_val} out of expected 148-152 Hz range"

    # Verify OK statuses on clean voice
    assert "[OK (<= 1.040%)]" in output
    assert "[OK (<= 3.810%)]" in output

    client_dir = cwd / "clients" / "TestClient" / "Rapporter"
    html_path = client_dir / f"{clean_wav.stem}_perturbation.html"
    assert html_path.exists(), "Perturbation HTML report was not generated"
    assert "Voxalys Perturbation Report" in html_path.read_text(encoding="utf-8")


def test_perturbation_pathological_voice(praat_executable, test_env):
    cwd, _, patho_wav = test_env
    method = "Cross-correlation (cc - recommended for perturbation)"
    script = f"""
sound = Read from file: "{patho_wav.name}"
runScript: "perturbation.praat", 75, 500, "{method}", "Save TXT report", "TestClient"
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"
    output = res.stdout

    # Verify ABOVE THRESHOLD flags
    assert "ABOVE THRESHOLD" in output

    client_dir = cwd / "clients" / "TestClient" / "Rapporter"
    txt_path = client_dir / f"{patho_wav.stem}_perturbation.txt"
    assert txt_path.exists(), "Perturbation TXT report was not generated"


def test_complete_voice_report(praat_executable, test_env):
    cwd, clean_wav, _ = test_env
    script = f"""
sound = Read from file: "{clean_wav.name}"
runScript: "voice_report.praat", "TestClient", 75, 500, 1, 1, 1, 1, 1
"""
    res = run_praat_script(praat_executable, cwd, script)
    assert res.returncode == 0, f"Praat error: {res.stderr}"

    client_dir = cwd / "clients" / "TestClient" / "Rapporter"
    report_html = client_dir / f"{clean_wav.stem}_voice_report.html"
    assert report_html.exists(), "Complete voice report HTML was not generated"
    html_content = report_html.read_text(encoding="utf-8")
    assert "<h1>Voxalys Voice Report</h1>" in html_content
    assert "F0 Intonation Analysis" in html_content
    assert "F0 Histogram" in html_content
    assert "Phonetogram" in html_content
    assert "Long-Term Average Spectrum (LTAS)" in html_content
