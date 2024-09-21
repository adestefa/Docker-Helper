#!/bin/bash

# _____               __
#/ _  //\ /\  /\ /\  / /
#\// // / \ \/ / \ \/ /
# / //\ \_/ /\ \_/ / /___
#/____/\___/  \___/\____/ Orge
################################

## AUDIO SOUND EFFECTS ##


## WARNING WARNING WARNING ##
## you must install SOX to use the play command!!! ##
## brew install sox ##

#SOUND_DIR=$(pwd)
#echo "SOUND_DIR:${SOUND_DIR}"

SOUND_PATH="/Users/corelogic/docker_helper/sounds"
AUDIO_VER="1.1"

function soundTest() {
    echo "Audio Warning! Performing sound test... in 3...2..1"
    pauseYesNo
    echo "----------------------------------------------------"

    pause_duration=1

    echo "1. Online...."
    playOnline
    sleep "$pause_duration"

    echo "2. Beep..."
    playBeep
    sleep "$pause_duration"

    echo "3. Done..."
    playDone
    sleep "$pause_duration"

    echo "4. Bell..."
    playBell
    sleep "$pause_duration"

    echo "5. Bad..."
    playBad
    sleep "$pause_duration"

    echo "6. Warning..."
    playWarning
    sleep "$pause_duration"

    echo "7. playSystemFailure"
    playSystemFailure
    sleep "$pause_duration"

    echo "8. Startup"
    playStartUp
    sleep "$pause_duration"

    echo "9. Unmount"
    playUnmount
    sleep "$pause_duration"

    echo "10. NO..."
    playNo
    sleep "$pause_duration"

    echo "11. Thinking..."
    playThinking
    sleep "$pause_duration"

    echo "12. Click..."
    playClick
    sleep "$pause_duration"

    echo "13. Working..."
    playWorking
    sleep "$pause_duration"

    echo "14. Cheer..."
    playCheer
    sleep "$pause_duration"

    echo "15. Exit..."
    playExit
    sleep "$pause_duration"



    echo "Sound test complete."
}




function playOnline() {
    play "${SOUND_PATH}/Systems_online.mp3" -q &
}

function playBeep() {
     play "${SOUND_PATH}/bleep.mp3" -q &
}

function playDone() {
    play "${SOUND_PATH}/done.mp3" -q &
}

function playStopDocker() {
  play "${SOUND_PATH}/System_power_down.mp3" -q &
}

function playExit() {
    play "${SOUND_PATH}/System_going_offline.mp3" -q &


}

function playBell() {
     play "${SOUND_PATH}/Bell2.mp3" -q &
}

function playBad() {
     play "${SOUND_PATH}/Bad.mp3" -q &
}

function playWarning() {
     play "${SOUND_PATH}/Warning.mp3" -q &
}

function playSystemFailure() {
    play "${SOUND_PATH}/System_Failure.mp3" -q &
}


function playStartUp() {
     play "${SOUND_PATH}/Power_on2.mp3" -q &
}

function playUnmount() {
    play "${SOUND_PATH}/Unmount.mp3" -q &
}

function playNo() {
    play "${SOUND_PATH}/unmount.mp3" -q &
}

function playThinking() {
    play "${SOUND_PATH}/process_sound_done.mp3" -q &
}

function  playClick() {
    play "${SOUND_PATH}/progressBar_done.mp3" -q &
}

function playWorking() {
     play "${SOUND_PATH}/system_working.mp3" -q &
}
function playCheer() {
     play "${SOUND_PATH}/cheer.mp3" -q &
}

function playErrorCondition() {
    playBad
    sleep 0.5
    playWarning
}
