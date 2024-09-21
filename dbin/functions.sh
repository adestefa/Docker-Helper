#!/bin/bash

LIB_VERSION="2.7"

MOD_TEST="OK!"



# saves preferences
function ddata() {
    echo "INFO:     D: Saving configuration: $1"
    $1 >> "dd.txt"
}

# returns 1 if d.txt exists
function dFileExists() {
    
    echo "START"
    # use current dir if none provided
    if [ -z "$1" ]; then
        current_dir=$(pwd)
        d_file="${current_dir}"
       
    else
        d_file="${1}"
    fi
   # echo "dFileExsits::$d_file"
   # echo "INFO:        D: Searching for data file..${d_file}"
    if [ -e "${d_file}" ]; then
        echo "1"
    else
        echo "0"
    fi
}

# $1 = directory to begin searching
# find all d.txt files
function dtxt_search() {
    # will recursivly search for all instances of d.txt and save to "d_sessions.txt"
    find "$1" -type f -name "d.txt" > "d_sessions.txt"
    #cat d_sessions.txt

    # maybe we didn't find any d files
    if [ ! -s "d_sessions.txt" ]; then
        echo "INFO:      D: Inspect, no d files in path $1"

    # we found a d file
    else
        count=1
        while IFS= read -r line; do
            echo "${count}. $line"
            {
                read -r image_name < <(sed -n '1p' ${line})
                read -r container_name < <(sed -n '2p' ${line})
                read -r hash_id < <(sed -n '3p' ${line})
                echo "    -->IMAGE        : ${image_name}"
                echo "    -->CONTAINER    : ${container_name}"
                echo "    -->LAST INSTANCE: ${hash_id}"
            }
            ((count++))
        done < "d_sessions.txt"
    fi

    if [  -s "d.txt" ]; then
        echo "d file exists at this level cleaning up the session file"
        # clean up the sessions file if we already have a d.txt at this level
        rm d_sessions.txt
    fi
}



# returns d file data
# return output: <image name>,<container name>
function get_d() {
    # use current dir if none provided
   # if [ -z "$1" ]; then
    #    current_dir=$(pwd)
    #    d_file="${current_dir}/d.txt"
    #else
        d_file="${1}"
   # fi
    {
        read -r image_name < <(sed -n '1p' ${d_file})
        read -r container_name < <(sed -n '2p' ${d_file})
        read -r hash_id < <(sed -n '3p' ${d_file})
        echo "${image_name},${container_name},${hash_id}"
    }
}

# full d.txt check with hint
# No side-effects
function check_d() {
    current_dir=$(pwd)
    d_file="${current_dir}/d.txt"
    echo "D FILE CHECK:${d_file}"
    if [ -e "${d_file}" ]; then
        playBell
        echo "INFO:        D: d file exists in the current directory!"
        read -r image_name < <(sed -n '1p' ${d_file})
        read -r container_name < <(sed -n '2p' ${d_file})
        echo "INFO:        D: Data loaded!"
        echo "INFO:        D:  IMAGE NAME      : $image_name"
        echo "INFO:        D:  CONTAINER NAME  : $container_name"
        echo "HINT:        D: You're ready to Rock and Roll!"
        echo "HINT:        D: Type 'd go'"
        #echo "${image_name},${container_name}"
    else
        playWarning
        echo "WARN:        D: d file does not exist in the current directory ($PWD)."
        echo "INFO:        D: [Quick Fix]: run:"
        echo "STEP:        D:   >d create <image name> <container name>"
        echo "INFO:        D:  *Volla!* d will now reference this file to build and run your images."
        echo "INFO:        D:   >d which"
        echo "INFO:        D:     d will inspect all sub directories for any d files."
    fi
}

# $1 = image_name
# $2 = container name
# $3 = container hash
function save_rec_to_data_file() {
    echo "> Save session for later? y/n"
    read choice_1
    if [ "$choice_1" == 'y' ]; then
        playDone
        echo "INFO:     D: Saving session for later '${1}', '${2}'"
        echo "${1},${2}," >> $DATA_FILE_2
        list_sessions
    else
        playBell
        echo "Skip saving.."
    fi


}

function cat_recs_from_data_file() {
    cat $DATA_FILE_2
}

# will return a stored session
# $1 = session row number in data file
# to use 'result=$(my_function)'
function get_session() {
    line=$(sed "${i}q;d" "$DATA_FILE_2")
    echo "${line}"

}




function maybe() {

    d_file="${1}/d.txt"
    echo "INFO:      D: Searching for data file..${d_file}"
    if [ -e "${d_file}" ]; then
        playBell
        echo "INFO:        D: File exists in the current directory!"
        read -r image_name < <(sed -n '1p' ${d_file})
        read -r container_name < <(sed -n '2p' ${d_file})
        echo "INFO:        D: Data loaded!"
        echo "INFO:        D:  IMAGE:$image_name"
        echo "INFO:        D:  CONTA:$container_name"
    else
        playBad
        echo "INFO:      D: File NOT found"
    fi
}



function list_sessions() {

    # Count the number of lines
    line_count=$(wc -l < "$DATA_FILE_2")
   # echo "LINES:${line_count}"

    if [ -z "$line_count" ]; then
        echo "No saved sessions found."
    else

        echo "[SAVED SESSIONS]"

        # loop over lines in file
        for i in $(seq 1 $line_count); do

            # grab the line
            line=$(sed "${i}q;d" "$DATA_FILE_2")

            # now split the line on comma
            IFS=',' read -r -a row_data <<< "$line"

            # build the ouput for this row to select
            echo "${i}. ${row_data[0]}, ${row_data[1]}, ${row_data[2]}"
        done
    fi

}

function pick_a_session() {
    # now message the user to make a selection
    echo "> Please pick a session to continue.."
    read choice
    #echo "you selected ${choice}"
    # now use the index to grab the line


}


# run image as container
# $1 = image name
# $2 = container name
function run_image(){
    docker rm $2    # first remove any existing container with same name
    docker run -d --name $2 -p 80:80 $1
}


# open browswer to the provided url
# $1 = URL
function openBrowser() {
    echo "INFO:      D: Opening Browser to ${1}"
    open -na "Google Chrome" --args --new-window "${1}"
}

# given a container hash as only argument
# save to the data file as the thrid line
# $1 = container hash
function save_container_hash() {
    echo "INFO:     D: Saving container hash to data file...${1}"
    sed -i '3i\$1'  $DATA_FILE
}


function get_container_logs() {
    echo "INFO:     D: Loading log files from container hash..."

}


function open_docs() {
    echo "INFO:      D: Opening Docker docs"
    openBrowswer "https://docs.docker.com/engine/reference/commandline/cli/"
}
