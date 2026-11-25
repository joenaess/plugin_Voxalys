# Voxalys - Record Voice & Manage Client Folder Structure
# Copyright (C) 2007-2026 Jonas Lindh
# SPDX-License-Identifier: GPL-3.0-or-later

default_client$ = "Klient_01"
if fileReadable("last_client.txt")
    saved$ = readFile$("last_client.txt")
    saved$ = replace_regex$(saved$, "[\r\n]+$", "", 0)
    if saved$ <> ""
        default_client$ = saved$
    endif
endif

form Voxalys - Record Voice
    word Client_ID 'default_client$'
    optionmenu Recording_mode: 1
        option SoundRecorder interface (record until satisfied)
        option Direct fixed-time recording (default mic)
    positive Fixed_duration_(s) 5.0
    positive Sampling_frequency_(Hz) 44100
    boolean Auto_remove_silence 1
    positive Silence_threshold_below_peak_(dB) 25.0
    boolean Save_to_client_folder 1
endform

client$ = replace_regex$(client_ID$, "[^A-Za-z0-9_-]", "_", 0)
if client$ = ""
    client$ = "Klient_01"
endif
writeFileLine: "last_client.txt", client$

if recording_mode = 1
    beginPause: "Voxalys - SoundRecorder"
        comment: "1. Open 'New -> Record mono Sound...' in Praat's Objects window."
        comment: "2. Record until satisfied, click 'Save to list', select the Sound, and click Continue."
    clicked = endPause: "Cancel", "Continue", 2, 1
    if clicked = 1
        exitScript()
    endif
    if numberOfSelected("Sound") = 0
        exitScript: "No Sound object selected in the Objects window."
    endif
    sound_id = selected("Sound")
else
    sound_id = Record Sound (fixed time): "Microphone", 1.0, 0.5, sampling_frequency, fixed_duration
endif

selectObject: sound_id

if auto_remove_silence = 1
    dur = Get total duration
    int_id = To Intensity: 75, 0.01, "yes"
    max_db = Get maximum: 0, 0, "Parabolic"
    thresh_db = max_db - silence_threshold_below_peak
    n_frames = Get number of frames
    t_start = 0
    t_end = dur

    for i from 1 to n_frames
        val = Get value in frame: i
        if val <> undefined and val > thresh_db
            t_frame = Get time from frame number: i
            t_start = max(0, t_frame - 0.05)
            i = n_frames + 1
        endif
    endfor

    for i from 0 to n_frames - 1
        idx = n_frames - i
        val = Get value in frame: idx
        if val <> undefined and val > thresh_db
            t_frame = Get time from frame number: idx
            t_end = min(dur, t_frame + 0.05)
            i = n_frames
        endif
    endfor

    removeObject: int_id
    if t_end > t_start + 0.05
        selectObject: sound_id
        trimmed_id = Extract part: t_start, t_end, "rectangular", 1.0, "no"
        removeObject: sound_id
        sound_id = trimmed_id
    endif
endif

ts$ = replace_regex$(date$(), "[: ]+", "_", 0)
obj_name$ = client$ + "_" + ts$
selectObject: sound_id
Rename: obj_name$

if save_to_client_folder = 1
    createDirectory: "clients"
    createDirectory: "clients/" + client$
    createDirectory: "clients/" + client$ + "/Bilder"
    createDirectory: "clients/" + client$ + "/Ljud"
    createDirectory: "clients/" + client$ + "/Rapporter"
    wav_path$ = "clients/" + client$ + "/Ljud/" + obj_name$ + ".wav"
    Save as WAV file: wav_path$
    writeInfoLine: "Voxalys recording saved: ", wav_path$
endif
