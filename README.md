# Voxalys Praat Plugin (v2.1)

A pedagogical and clinical voice analysis plugin for **[Praat](https://www.fon.hum.uva.nl/praat/)**.

Created and developed by **Jonas Lindh** for pedagogical and clinical acoustic voice assessment by speech-language pathologists (*logopeder*), voice teachers, and phoneticians.

Reference paper:
> Lindh, J., 2007, *"Voxalys – a Pedagogical Praat Plugin for Voice Analysis"*, **Proceedings of Fonetik 2007**, TMH-QPSR, Vol. 50(1), pp. 45–48.

---

## Upstream Praat Dependency & Attribution

Voxalys runs inside **Praat: doing phonetics by computer**, created and maintained by **Paul Boersma & David Weenink** at the University of Amsterdam (<https://www.fon.hum.uva.nl/praat/>). Praat is free software licensed under the **GNU General Public License (GPL) version 3 or later**.

Voxalys v2.1 is distributed under the **GNU General Public License v3.0 or later (`GPL-3.0-or-later`)**, ensuring 100% license compatibility with Praat.

---

## Clinical Usability for Speech-Language Pathologists

Voxalys was conceived primarily for Swedish speech-language pathologists (*logopeder*) and voice clinicians, and its design remains remarkably practical and clinically relevant today:

1. **Automated Patient Directory Structure (`clients/<Client_ID>/`)**
   - In clinical voice therapy and phoniatrics, longitudinal tracking across baseline, mid-therapy, and post-therapy sessions is essential.
   - Voxalys automatically categorizes files into standardized Swedish clinical subfolders (`Ljud` for recordings, `Bilder` for 300-DPI visual plots, and `Rapporter` for HTML/TXT documentation), removing manual file management errors.
2. **Objective Dysphonia & Pathology Screening**
   - The perturbation module implements clinical thresholds established by Deliyski (1993) and the Multi-Dimensional Voice Program (MDVP) normative database.
   - Immediate threshold flagging (`OK` vs. `ABOVE THRESHOLD`) gives clinicians an objective acoustic basis for assessing vocal fold nodules, polyps, paresis, functional dysphonia, or pre/post-operative phonosurgery outcomes.
3. **Perceptually Grounded $F_0$ Semitone Scaling**
   - Rather than raw linear Hertz, intonation is tracked in semitones (re 100 Hz), directly mirroring human musical and pitch perception. This is especially valuable in pitch re-education, voice masculinization/feminization therapy, and singing voice rehabilitation.
4. **Interactive & Diagnostic Voice Range Profiles (VRP / Phonetogram)**
   - Following European Phonetogram recommendations (Union of European Phoniatricians, UEP), Voxalys enables both live dynamic voice profiling and static phonetograms to gauge physiological voice limits (minimum/maximum SPL across the vocal range).
5. **Long-Term Average Spectrum (LTAS)**
   - Allows rapid assessment of glottal closure efficiency, hypophonia, and spectral energy distribution (e.g., vocal tilt, alpha ratio, singer's formant) without being confounded by short-term phonetic variations.

> **Clinical Notes for Modern Practice:**
> - Absolute SPL (dB) requires microphone distance control and sound-level meter calibration. Without calibration, the phonetogram and VRP provide high-utility relative dynamic range contours.
> - Sustained vowel phonations (/a/, /i/, /u/) at comfortable pitch and loudness remain the gold-standard input for perturbation analysis to prevent articulation-driven pitch and amplitude variation from biasing jitter and shimmer.

---

## Beyond Praat: JoVoice & Modern AI Voice Technology

While Voxalys provides a comprehensive desktop workstation inside Praat, **Jonas Lindh** is currently developing **JoVoice**—an Android mobile application designed to bring modern voice assessment directly to the patient's bedside and mobile clinical fieldwork:

- **Next-Gen $F_0$ Estimation:** Powered by an AI / deep learning model engineered for robust fundamental frequency tracking, resilient against environmental acoustic noise and severely dysphonic voice signals.
- **Mobile Workflow:** Bringing voice biofeedback, range monitoring, and acoustic screening to mobile devices.
- **Company & Demos:** For information, demonstrations, and ongoing development updates, visit **[hejai.se](https://hejai.se)**.

---

## Features & Modules

Voxalys provides an integrated clinical and pedagogical workflow organized around patient/client profiles:

| Module | Praat Script | Description |
| :--- | :--- | :--- |
| **Record voice** | `record_voice.praat` | Fixed-time or interactive sound recording with automatic silence trimming and client folder structuring. |
| **Voice Range Profile (VRP)** | `vrp.praat` | Interactive real-time sound-level vs. fundamental frequency recording with chronological color gradient (Blue $\to$ Red). |
| **F0 Intonation Analysis** | `f0_analysis.praat` | Fundamental frequency contour plotted in **semitones re 100 Hz** with acoustic summary statistics (mean, median, SD in Hz and st). |
| **F0 Histogram** | `f0_histogram.praat` | Fundamental frequency distribution histogram with customizable bin width and frequency bounds. |
| **Phonetogram** | `phonetogram.praat` | Instantaneous SPL (dB) vs. F0 (Hz) acoustic voice field mapping. |
| **LTAS** | `ltas_analysis.praat` | Long-Term Average Spectrum with configurable bandwidth and frequency limits. |
| **Perturbation Analysis** | `perturbation.praat` | Comprehensive voice report detailing jitter, shimmer, voice breaks, and HNR against clinical thresholds (Deliyski 1993 / MDVP norm values). Outputs to Info window, TXT, or HTML. |
| **Quick Complete Voice Report**| `voice_report.praat` | One-click comprehensive HTML voice report aggregating perturbation metrics and all acoustic plots. |

### Diagnostic & Normative Thresholds (Deliyski 1993 / MDVP)

The perturbation module flags voice parameters exceeding validated clinical pathology thresholds:
- **Jitter (local):** $\le 1.040\%$
- **Jitter (local, absolute):** $\le 83.200\ \mu\text{s}$
- **Jitter (RAP):** $\le 0.680\%$
- **Jitter (PPQ5):** $\le 0.840\%$
- **Shimmer (local):** $\le 3.810\%$
- **Shimmer (local, dB):** $\le 0.350\ \text{dB}$
- **Shimmer (APQ3):** $\le 3.070\%$

---

## Installation

Clone this repository directly into your Praat plugin folder:

### Linux
```bash
git clone https://github.com/joenaess/plugin_Voxalys.git ~/.praat-dir/plugin_Voxalys
```

### macOS
```bash
git clone https://github.com/joenaess/plugin_Voxalys.git "$HOME/Library/Preferences/Praat Prefs/plugin_Voxalys"
```

### Windows (PowerShell)
```powershell
git clone https://github.com/joenaess/plugin_Voxalys.git "$env:USERPROFILE\Praat\plugin_Voxalys"
```

Once installed, restart Praat. You will find:
- **New $\to$ Voxalys** in the Objects window for voice recording and interactive VRP.
- **Voxalys -** menu in the dynamic action menu when a **Sound** object is selected.

---

## Client Data Organization

When analyzing or recording voice samples, Voxalys automatically maintains a structured directory tree under `clients/<Client_ID>/`:

```text
clients/
└── <Client_ID>/
    ├── Bilder/       # High-resolution (300 DPI) publication/diagnostic PNG plots
    ├── Ljud/         # Uncompressed WAV audio recordings
    └── Rapporter/    # Standalone HTML and TXT diagnostic voice reports
```

---

## Development & Testing

The repository includes a modern developer toolchain using `uv`, `pytest`, and `ruff` for static linting, block validation, and headless Praat integration testing.

### Prerequisites
- Python $\ge$ 3.11 with [uv](https://docs.astral.sh/uv/)
- [Praat](https://www.fon.hum.uva.nl/praat/) installed in PATH (`praat`)

### Commands
```bash
# Run full CI suite (linting + test suite)
make ci

# Run test suite
make test

# Format and lint code
make format
make lint
```

---

## License

Copyright (C) 2007–2026 Jonas Lindh  

This program is free software: you can redistribute it and/or modify it under the terms of the **GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version**.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [LICENSE](LICENSE) file for details.
