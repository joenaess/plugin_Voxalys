# Voxalys - Quick Complete Voice Report
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

if numberOfSelected("Sound") <> 1
    exitScript: "Please select exactly one Sound object."
endif
sound_id = selected("Sound")
sound_name$ = selected$("Sound")

form Voxalys - Quick Complete Voice Report
    word Client_ID Klient_01
    positive F0_floor_(Hz) 75
    positive F0_ceiling_(Hz) 500
    boolean Include_F0_intonation 1
    boolean Include_F0_histogram 1
    boolean Include_phonetogram 1
    boolean Include_LTAS 1
    boolean Include_perturbation 1
endform

client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
createDirectory: "clients"
createDirectory: "clients/" + client$
createDirectory: "clients/" + client$ + "/Bilder"
createDirectory: "clients/" + client$ + "/Rapporter"

html_path$ = "clients/" + client$ + "/Rapporter/" + sound_name$ + "_voice_report.html"
writeFileLine: html_path$, "<!DOCTYPE html><html><head><meta charset='utf-8'>"
appendFileLine: html_path$, "<title>Voxalys Voice Report - " + sound_name$ + "</title>"
appendFileLine: html_path$, "<style>body{font-family:sans-serif;max-width:900px;margin:24px auto;line-height:1.5}table{border-collapse:collapse;width:100%}td,th{border:1px solid #ccc;padding:8px;text-align:left}.warn{color:#b00020;font-weight:bold}.ok{color:#1b5e20}</style>"
appendFileLine: html_path$, "</head><body>"
appendFileLine: html_path$, "<h1>Voxalys Voice Report</h1>"
appendFileLine: html_path$, "<p><strong>Client:</strong> " + client$ + " &nbsp;|&nbsp; <strong>Recording:</strong> " + sound_name$ + " &nbsp;|&nbsp; <strong>Date:</strong> " + date$() + "</p>"

if include_perturbation = 1
    selectObject: sound_id
    pitch_id = To Pitch (cc): 0, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
    selectObject: sound_id, pitch_id
    pp_id = To PointProcess (cc)
    selectObject: sound_id
    harm_id = To Harmonicity (cc): 0.01, f0_floor, 0.1, 1.0
    hnr_mean = Get mean: 0, 0

    selectObject: sound_id, pitch_id, pp_id
    rep$ = Voice report: 0, 0, f0_floor, f0_ceiling, 1.3, 1.6, 0.03, 0.45
    f0_mean = extractNumber(rep$, "Mean pitch: ")
    f0_med = extractNumber(rep$, "Median pitch: ")
    f0_sd = extractNumber(rep$, "Standard deviation: ")
    jit_loc = extractNumber(rep$, "Jitter (local): ")
    shim_loc = extractNumber(rep$, "Shimmer (local): ")
    breaks_pct = extractNumber(rep$, "Degree of voice breaks: ")

    jit_cls$ = "ok"
    jit_note$ = "Within normal range (<= 1.040%)"
    if jit_loc > 1.040
        jit_cls$ = "warn"
        jit_note$ = "Exceeds pathology threshold (> 1.040%)"
    endif

    shim_cls$ = "ok"
    shim_note$ = "Within normal range (<= 3.810%)"
    if shim_loc > 3.810
        shim_cls$ = "warn"
        shim_note$ = "Exceeds pathology threshold (> 3.810%)"
    endif

    appendFileLine: html_path$, "<h2>Acoustic Summary &amp; Pathology Thresholds</h2>"
    appendFileLine: html_path$, "<table><tr><th>Parameter</th><th>Value</th><th>Reference / Status</th></tr>"
    appendFileLine: html_path$, "<tr><td>Mean F0 / Median F0 / SD</td><td>" + fixed$(f0_mean, 1) + " Hz / " + fixed$(f0_med, 1) + " Hz / " + fixed$(f0_sd, 1) + " Hz</td><td>Boersma (1993)</td></tr>"
    appendFileLine: html_path$, "<tr><td>Jitter (local)</td><td>" + fixed$(jit_loc, 3) + " %</td><td class='" + jit_cls$ + "'>" + jit_note$ + "</td></tr>"
    appendFileLine: html_path$, "<tr><td>Shimmer (local)</td><td>" + fixed$(shim_loc, 3) + " %</td><td class='" + shim_cls$ + "'>" + shim_note$ + "</td></tr>"
    appendFileLine: html_path$, "<tr><td>Degree of voice breaks</td><td>" + fixed$(breaks_pct, 2) + " %</td><td>Breaks > 1.25 / F0 floor</td></tr>"
    appendFileLine: html_path$, "<tr><td>Mean HNR</td><td>" + fixed$(hnr_mean, 2) + " dB</td><td>Harmonics-to-Noise Ratio</td></tr>"
    appendFileLine: html_path$, "</table>"
    removeObject: pitch_id, pp_id, harm_id
endif

if include_F0_intonation = 1
    selectObject: sound_id
    runScript: "f0_analysis.praat", f0_floor, f0_ceiling, "Autocorrelation (ac)", 1, client$
    appendFileLine: html_path$, "<h2>F0 Intonation Analysis</h2><img src='../Bilder/" + sound_name$ + "_F0_intonation.png' style='max-width:100%;'>"
endif

if include_F0_histogram = 1
    selectObject: sound_id
    runScript: "f0_histogram.praat", f0_floor, f0_ceiling, 60, 400, 1.0, "Blue", 1.5, 10, 1, client$
    appendFileLine: html_path$, "<h2>F0 Histogram</h2><img src='../Bilder/" + sound_name$ + "_F0_histogram.png' style='max-width:100%;'>"
endif

if include_phonetogram = 1
    selectObject: sound_id
    runScript: "phonetogram.praat", 65, 800, 40, 110, "Blue", 1, 1, client$
    appendFileLine: html_path$, "<h2>Phonetogram</h2><img src='../Bilder/" + sound_name$ + "_phonetogram.png' style='max-width:100%;'>"
endif

if include_LTAS = 1
    selectObject: sound_id
    runScript: "ltas_analysis.praat", 100, 5000, 1, client$
    appendFileLine: html_path$, "<h2>Long-Term Average Spectrum (LTAS)</h2><img src='../Bilder/" + sound_name$ + "_LTAS.png' style='max-width:100%;'>"
endif

appendFileLine: html_path$, "</body></html>"
selectObject: sound_id
writeInfoLine: "Voxalys Complete Voice Report written to: ", html_path$
