# Voxalys Praat Plugin v2.1 - Menu Registration
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

Add menu command: "Objects", "New", "Voxalys", "", 0, ""
Add menu command: "Objects", "New", "Record voice...", "Voxalys", 1, "record_voice.praat"
Add menu command: "Objects", "New", "Voice Range Profile (VRP)...", "Voxalys", 1, "vrp.praat"

Add action command: "Sound", 1, "", 0, "", 0, "Voxalys -", "", 0, ""
Add action command: "Sound", 1, "", 0, "", 0, "To F0-analysis (intonation)...", "Voxalys -", 1, "f0_analysis.praat"
Add action command: "Sound", 1, "", 0, "", 0, "To F0 histogram...", "Voxalys -", 1, "f0_histogram.praat"
Add action command: "Sound", 1, "", 0, "", 0, "To Phonetogram...", "Voxalys -", 1, "phonetogram.praat"
Add action command: "Sound", 1, "", 0, "", 0, "To LTAS...", "Voxalys -", 1, "ltas_analysis.praat"
Add action command: "Sound", 1, "", 0, "", 0, "Perturbation analysis (Voice report)...", "Voxalys -", 1, "perturbation.praat"
Add action command: "Sound", 1, "", 0, "", 0, "Quick Complete Voice Report...", "Voxalys -", 1, "voice_report.praat"
