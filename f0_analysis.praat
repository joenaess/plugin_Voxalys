# Voxalys - To F0-analysis (Intonation in Semitones re 100 Hz)
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

if numberOfSelected("Sound") <> 1
    exitScript: "Please select exactly one Sound object."
endif
sound_id = selected("Sound")
sound_name$ = selected$("Sound")

form Voxalys - F0-analysis (Intonation)
    positive F0_floor_(Hz) 75
    positive F0_ceiling_(Hz) 500
    optionmenu Pitch_method: 1
        option Autocorrelation (ac)
        option Cross-correlation (cc)
    boolean Save_picture 1
    word Client_ID Klient_01
endform

selectObject: sound_id
dur = Get total duration
if pitch_method = 1
    pitch_id = To Pitch (ac): 0, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
else
    pitch_id = To Pitch (cc): 0, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
endif

f0_mean_hz = Get mean: 0, 0, "Hertz"
f0_med_hz = Get quantile: 0, 0, 0.5, "Hertz"
f0_sd_hz = Get standard deviation: 0, 0, "Hertz"

f0_mean_st = Get mean: 0, 0, "semitones re 100 Hz"
f0_med_st = Get quantile: 0, 0, 0.5, "semitones re 100 Hz"
f0_sd_st = Get standard deviation: 0, 0, "semitones"

st_min = floor(12 * log2(f0_floor / 100))
st_max = ceiling(12 * log2(f0_ceiling / 100))

Erase all
Select outer viewport: 0, 6.5, 0, 4.5
Font size: 10
Colour: "Blue"
Line width: 2
Draw semitones (re 100 Hz): 0, 0, st_min, st_max, "no"

Colour: "Black"
Line width: 1
Draw inner box
Marks bottom every: 1, 0.5, "yes", "yes", "no"
Marks left every: 1, 3, "yes", "yes", "no"
Text bottom: "yes", "Time (s)"
Text left: "yes", "F0 (semitones re 100 Hz)"
Text top: "no", "Voxalys F0-analysis: " + sound_name$ + " (" + date$() + ")"

Select outer viewport: 0, 6.5, 4.3, 5.1
Font size: 9
Text: 0.02, "left", 0.5, "half",
    ... "Duration: " + fixed$(dur, 2) + " s | Mean: " + fixed$(f0_mean_hz, 1) + " Hz (" + fixed$(f0_mean_st, 1) + " st) | " +
    ... "Median: " + fixed$(f0_med_hz, 1) + " Hz (" + fixed$(f0_med_st, 1) + " st) | SD: " + fixed$(f0_sd_hz, 1) + " Hz (" + fixed$(f0_sd_st, 2) + " st)"

if save_picture = 1
    client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    Select outer viewport: 0, 6.5, 0, 5.1
    out_png$ = "clients/" + client$ + "/Bilder/" + sound_name$ + "_F0_intonation.png"
    Save as 300-dpi PNG file: out_png$
    writeInfoLine: "Saved F0 intonation plot: ", out_png$
endif

removeObject: pitch_id
selectObject: sound_id
