# Voxalys - To LTAS (Long-Term Average Spectrum)
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

if numberOfSelected("Sound") <> 1
    exitScript: "Please select exactly one Sound object."
endif
sound_id = selected("Sound")
sound_name$ = selected$("Sound")

form Voxalys - LTAS Analysis
    positive Bandwidth_(Hz) 100
    positive Max_frequency_(Hz) 5000
    boolean Save_picture 1
    word Client_ID Klient_01
endform

selectObject: sound_id
ltas_id = To Ltas: bandwidth

Erase all
Select outer viewport: 0, 6.5, 0, 4.5
Font size: 10
Colour: "Blue"
Line width: 1.5
Draw: 0, max_frequency, 0, 0, "no", "bars"

Colour: "Black"
Line width: 1
Draw inner box
Marks bottom every: 1, 500, "yes", "yes", "no"
Marks left every: 1, 10, "yes", "yes", "no"
Text bottom: "yes", "Frequency (Hz)"
Text left: "yes", "Spectral Energy (dB/Hz)"
Text top: "no", "Voxalys LTAS (" + fixed$(bandwidth, 0) + " Hz bw): " + sound_name$

if save_picture = 1
    client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    out_png$ = "clients/" + client$ + "/Bilder/" + sound_name$ + "_LTAS.png"
    Save as 300-dpi PNG file: out_png$
    writeInfoLine: "Saved LTAS plot: ", out_png$
endif

removeObject: ltas_id
selectObject: sound_id
