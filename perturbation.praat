# Voxalys - Perturbation Analysis & Voice Report
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

if numberOfSelected("Sound") <> 1
    exitScript: "Please select exactly one Sound object."
endif
sound_id = selected("Sound")
sound_name$ = selected$("Sound")

form Voxalys - Perturbation Analysis
    positive F0_floor_(Hz) 75
    positive F0_ceiling_(Hz) 500
    optionmenu Correlation_method: 2
        option Autocorrelation (ac)
        option Cross-correlation (cc - recommended for perturbation)
    optionmenu Output_format: 1
        option Info window + Picture
        option Save TXT report
        option Save HTML report
    word Client_ID Klient_01
endform

selectObject: sound_id
if correlation_method = 1
    pitch_id = To Pitch (ac): 0, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
else
    pitch_id = To Pitch (cc): 0, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
endif

selectObject: sound_id, pitch_id
pp_id = To PointProcess (cc)

selectObject: sound_id
harm_id = To Harmonicity (cc): 0.01, f0_floor, 0.1, 1.0
hnr_mean = Get mean: 0, 0

selectObject: sound_id, pitch_id, pp_id
report$ = Voice report: 0, 0, f0_floor, f0_ceiling, 1.3, 1.6, 0.03, 0.45

f0_mean = extractNumber(report$, "Mean pitch: ")
f0_med = extractNumber(report$, "Median pitch: ")
f0_sd = extractNumber(report$, "Standard deviation: ")
unvoiced_pct = extractNumber(report$, "Fraction of locally unvoiced frames: ")
n_breaks = extractNumber(report$, "Number of voice breaks: ")
breaks_pct = extractNumber(report$, "Degree of voice breaks: ")

jit_loc = extractNumber(report$, "Jitter (local): ")
jit_abs = extractNumber(report$, "Jitter (local, absolute): ") * 1e6
jit_rap = extractNumber(report$, "Jitter (rap): ")
jit_ppq5 = extractNumber(report$, "Jitter (ppq5): ")
jit_ddp = extractNumber(report$, "Jitter (ddp): ")

shim_loc = extractNumber(report$, "Shimmer (local): ")
shim_db = extractNumber(report$, "Shimmer (local, dB): ")
shim_apq3 = extractNumber(report$, "Shimmer (apq3): ")
shim_apq5 = extractNumber(report$, "Shimmer (apq5): ")
shim_apq11 = extractNumber(report$, "Shimmer (apq11): ")
shim_dda = extractNumber(report$, "Shimmer (dda): ")

Erase all
Select outer viewport: 0, 6.5, 0, 3.5
Font size: 10
selectObject: pp_id
Colour: "Blue"
Draw: 0, 0, "yes"
Colour: "Black"
Text top: "no", "Voxalys Glottal Pulses & Voice Breaks: " + sound_name$

flag_jloc$ = "OK (<= 1.040%)"
if jit_loc > 1.040
    flag_jloc$ = "ABOVE THRESHOLD (> 1.040%)"
endif
flag_jabs$ = "OK (<= 83.2 us)"
if jit_abs > 83.200
    flag_jabs$ = "ABOVE THRESHOLD (> 83.2 us)"
endif
flag_jrap$ = "OK (<= 0.680%)"
if jit_rap > 0.680
    flag_jrap$ = "ABOVE THRESHOLD (> 0.680%)"
endif
flag_jppq$ = "OK (<= 0.840%)"
if jit_ppq5 > 0.840
    flag_jppq$ = "ABOVE THRESHOLD (> 0.840%)"
endif
flag_sloc$ = "OK (<= 3.810%)"
if shim_loc > 3.810
    flag_sloc$ = "ABOVE THRESHOLD (> 3.810%)"
endif
flag_sdb$ = "OK (<= 0.350 dB)"
if shim_db > 0.350
    flag_sdb$ = "ABOVE THRESHOLD (> 0.350 dB)"
endif
flag_sapq$ = "OK (<= 3.070%)"
if shim_apq3 > 3.070
    flag_sapq$ = "ABOVE THRESHOLD (> 3.070%)"
endif

writeInfoLine: "=== VOXALYS PERTURBATION ANALYSIS ==="
appendInfoLine: "File: ", sound_name$, " | Date: ", date$()
appendInfoLine: "--- Fundamental Frequency (F0) ---"
appendInfoLine: "Mean F0:   ", fixed$(f0_mean, 2), " Hz"
appendInfoLine: "Median F0: ", fixed$(f0_med, 2), " Hz"
appendInfoLine: "SD F0:     ", fixed$(f0_sd, 2), " Hz"
appendInfoLine: "--- Voice Breaks ---"
appendInfoLine: "Locally unvoiced frames: ", fixed$(unvoiced_pct, 2), " %"
appendInfoLine: "Number of voice breaks:  ", n_breaks
appendInfoLine: "Degree of voice breaks:  ", fixed$(breaks_pct, 2), " %"
appendInfoLine: "--- Jitter (Deliyski/MDVP Thresholds) ---"
appendInfoLine: "Jitter (local):          ", fixed$(jit_loc, 3), " %   [", flag_jloc$, "]"
appendInfoLine: "Jitter (local, abs):     ", fixed$(jit_abs, 2), " us  [", flag_jabs$, "]"
appendInfoLine: "Jitter (RAP):            ", fixed$(jit_rap, 3), " %   [", flag_jrap$, "]"
appendInfoLine: "Jitter (PPQ5):           ", fixed$(jit_ppq5, 3), " %   [", flag_jppq$, "]"
appendInfoLine: "Jitter (DDP):            ", fixed$(jit_ddp, 3), " %"
appendInfoLine: "--- Shimmer (Deliyski/MDVP Thresholds) ---"
appendInfoLine: "Shimmer (local):         ", fixed$(shim_loc, 3), " %   [", flag_sloc$, "]"
appendInfoLine: "Shimmer (local, dB):     ", fixed$(shim_db, 3), " dB  [", flag_sdb$, "]"
appendInfoLine: "Shimmer (APQ3):          ", fixed$(shim_apq3, 3), " %   [", flag_sapq$, "]"
appendInfoLine: "Shimmer (APQ5):          ", fixed$(shim_apq5, 3), " %"
appendInfoLine: "Shimmer (APQ11):         ", fixed$(shim_apq11, 3), " %"
appendInfoLine: "Shimmer (DDA):           ", fixed$(shim_dda, 3), " %"
appendInfoLine: "--- Harmonicity ---"
appendInfoLine: "Mean HNR (cc):           ", fixed$(hnr_mean, 2), " dB"

if output_format >= 2
    client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    createDirectory: "clients/" + client$ + "/Rapporter"
    png_path$ = "clients/" + client$ + "/Bilder/" + sound_name$ + "_pulses.png"
    Save as 300-dpi PNG file: png_path$

    if output_format = 2
        txt_path$ = "clients/" + client$ + "/Rapporter/" + sound_name$ + "_perturbation.txt"
        txt$ = info$()
        writeFileLine: txt_path$, txt$
        appendInfoLine: "Saved TXT report: ", txt_path$
    else
        html_path$ = "clients/" + client$ + "/Rapporter/" + sound_name$ + "_perturbation.html"
        writeFileLine: html_path$, "<html><head><meta charset='utf-8'><title>Voxalys Perturbation Report</title></head><body>"
        appendFileLine: html_path$, "<h1>Voxalys Perturbation Report: " + sound_name$ + "</h1>"
        appendFileLine: html_path$, "<p><b>Client:</b> " + client$ + " | <b>Date:</b> " + date$() + "</p>"
        appendFileLine: html_path$, "<pre>" + info$() + "</pre>"
        appendFileLine: html_path$, "<img src='../Bilder/" + sound_name$ + "_pulses.png' style='max-width:700px;'>"
        appendFileLine: html_path$, "</body></html>"
        appendInfoLine: "Saved HTML report: ", html_path$
    endif
endif

removeObject: pitch_id, pp_id, harm_id
selectObject: sound_id
