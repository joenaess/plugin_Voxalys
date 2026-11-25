# Voxalys - To Phonetogram (SPL dB vs. F0 Hz)
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

if numberOfSelected("Sound") <> 1
    exitScript: "Please select exactly one Sound object."
endif
sound_id = selected("Sound")
sound_name$ = selected$("Sound")

form Voxalys - Phonetogram
    positive F0_floor_(Hz) 65
    positive F0_ceiling_(Hz) 800
    real SPL_floor_(dB) 40
    real SPL_ceiling_(dB) 110
    word Plot_colour Blue
    boolean Erase_previous_plot 1
    boolean Save_picture 1
    word Client_ID Klient_01
endform

selectObject: sound_id
tmin = Get start time
tmax = Get end time
pitch_id = To Pitch (ac): 0.01, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
selectObject: sound_id
int_id = To Intensity: f0_floor, 0.01, "yes"

if erase_previous_plot = 1
    Erase all
endif

Select outer viewport: 0, 6.5, 0, 4.5
Font size: 10
Axes: f0_floor, f0_ceiling, sPL_floor, sPL_ceiling
Colour: plot_colour$

t = tmin
while t <= tmax
    selectObject: pitch_id
    f0 = Get value at time: t, "Hertz", "Linear"
    if f0 <> undefined and f0 >= f0_floor and f0 <= f0_ceiling
        selectObject: int_id
        spl = Get value at time: t, "Cubic"
        if spl <> undefined and spl >= sPL_floor and spl <= sPL_ceiling
            Paint circle (mm): plot_colour$, f0, spl, 1.2
        endif
    endif
    t = t + 0.01
endwhile

Colour: "Black"
Line width: 1
Draw inner box
Marks bottom every: 1, 50, "yes", "yes", "no"
Marks left every: 1, 10, "yes", "yes", "no"
Text bottom: "yes", "Fundamental Frequency F0 (Hz)"
Text left: "yes", "Intensity / SPL (dB)"
Text top: "no", "Voxalys Phonetogram: " + sound_name$

if save_picture = 1
    client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    out_png$ = "clients/" + client$ + "/Bilder/" + sound_name$ + "_phonetogram.png"
    Save as 300-dpi PNG file: out_png$
    writeInfoLine: "Saved phonetogram: ", out_png$
endif

removeObject: pitch_id, int_id
selectObject: sound_id
