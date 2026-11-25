# Voxalys - To F0 Histogram
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

if numberOfSelected("Sound") <> 1
    exitScript: "Please select exactly one Sound object."
endif
sound_id = selected("Sound")
sound_name$ = selected$("Sound")

form Voxalys - F0 Histogram
    positive F0_floor_(Hz) 75
    positive F0_ceiling_(Hz) 500
    positive Plot_min_(Hz) 60
    positive Plot_max_(Hz) 400
    positive Bin_width_(Hz) 1.0
    word Colour Blue
    positive Line_width 1.5
    positive Font_size 10
    boolean Save_picture 1
    word Client_ID Klient_01
endform

selectObject: sound_id
pitch_id = To Pitch (ac): 0, f0_floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, f0_ceiling
n_frames = Get number of frames
n_bins = floor((plot_max - plot_min) / bin_width)
if n_bins < 1
    removeObject: pitch_id
    exitScript: "Invalid histogram frequency range."
endif

bins# = zero#(n_bins)
max_count = 0
for i from 1 to n_frames
    f0 = Get value in frame: i, "Hertz"
    if f0 <> undefined and f0 >= plot_min and f0 < plot_max
        b = floor((f0 - plot_min) / bin_width) + 1
        bins#[b] = bins#[b] + 1
        if bins#[b] > max_count
            max_count = bins#[b]
        endif
    endif
endfor

if max_count = 0
    removeObject: pitch_id
    exitScript: "No voiced F0 frames found in specified range."
endif

Erase all
Select outer viewport: 0, 6.5, 0, 4.5
Font size: font_size
Axes: plot_min, plot_max, 0, max_count * 1.1
Colour: colour$
Line width: line_width

for b from 1 to n_bins
    if bins#[b] > 0
        x1 = plot_min + (b - 1) * bin_width
        x2 = x1 + bin_width
        Paint rectangle: colour$, x1, x2, 0, bins#[b]
    endif
endfor

Colour: "Black"
Line width: 1
Draw inner box
Marks bottom every: 1, 25, "yes", "yes", "no"
Marks left every: 1, max(1, round(max_count / 5)), "yes", "yes", "no"
Text bottom: "yes", "Fundamental Frequency F0 (Hz)"
Text left: "yes", "Frame Count (bin = " + fixed$(bin_width, 1) + " Hz)"
Text top: "no", "Voxalys F0 Histogram: " + sound_name$

if save_picture = 1
    client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    out_png$ = "clients/" + client$ + "/Bilder/" + sound_name$ + "_F0_histogram.png"
    Save as 300-dpi PNG file: out_png$
    writeInfoLine: "Saved F0 histogram: ", out_png$
endif

removeObject: pitch_id
selectObject: sound_id
