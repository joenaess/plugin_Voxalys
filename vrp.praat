# Voxalys - Interactive Voice Range Profile (VRP)
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

form Voxalys - Interactive Voice Range Profile
    word Client_ID Klient_01
    positive Total_duration_(s) 12.0
    positive Step_duration_(s) 0.5
    positive F0_floor_(Hz) 65
    positive F0_ceiling_(Hz) 900
    real SPL_floor_(dB) 40
    real SPL_ceiling_(dB) 115
    boolean Save_picture 1
endform

n_steps = max(1, round(total_duration / step_duration))

Erase all
Select outer viewport: 0, 6.5, 0, 4.5
Font size: 10
Axes: f0_floor, f0_ceiling, sPL_floor, sPL_ceiling
Colour: "Black"
Draw inner box
Marks bottom every: 1, 50, "yes", "yes", "no"
Marks left every: 1, 10, "yes", "yes", "no"
Text bottom: "yes", "Fundamental Frequency F0 (Hz)"
Text left: "yes", "Intensity / SPL (dB)"
Text top: "no", "Voxalys Interactive VRP (" + client_ID$ + ") - Blue=Start -> Red=End"

for step from 1 to n_steps
    frac = step / n_steps
    if frac <= 0.2
        col$ = "Blue"
    elsif frac <= 0.4
        col$ = "Cyan"
    elsif frac <= 0.6
        col$ = "Green"
    elsif frac <= 0.8
        col$ = "Magenta"
    else
        col$ = "Red"
    endif

    chunk_id = Record Sound (fixed time): "Microphone", 1.0, 0.5, 22050, step_duration
    selectObject: chunk_id
    pitch_id = To Pitch (ac): 0.01, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
    selectObject: chunk_id
    int_id = To Intensity: f0_floor, 0.01, "yes"

    t = 0
    while t <= step_duration
        selectObject: pitch_id
        f0 = Get value at time: t, "Hertz", "Linear"
        if f0 <> undefined and f0 >= f0_floor and f0 <= f0_ceiling
            selectObject: int_id
            spl = Get value at time: t, "Cubic"
            if spl <> undefined and spl >= sPL_floor and spl <= sPL_ceiling
                Paint circle (mm): col$, f0, spl, 1.5
            endif
        endif
        t = t + 0.01
    endwhile

    removeObject: chunk_id, pitch_id, int_id
endfor

if save_picture = 1
    client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    ts$ = replace_regex$(date$(), "[: ]+", "_", 0)
    out_png$ = "clients/" + client$ + "/Bilder/" + client$ + "_" + ts$ + "_VRP.png"
    Save as 300-dpi PNG file: out_png$
    writeInfoLine: "Saved VRP plot: ", out_png$
endif
