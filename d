#!/bin/bash

###################################
# Docker Helper!! 'D'
# 8/10/2024 Anthony Destefano
#  - let's document docker commands
#  - make it easier to work on CLI
#  - git level performance
#  - treat containers like branches
# What is this?
#  I bounce around a lot, I have a many projects
#  I forget what I name images/containers
#  Naming things takes energy, documenting takes time
#  > let's combine all the above into a simple CLI
#  Step 1: add a d.txt file in your project dir
#  Step 2: add image name on first line and container name on second
#  Step 3: > d go
#  that's it. You pick a name once.
#  everything is documented, just look at d.txt for what you named
#  less time thinking more time doing
# Note: 'd' is for both Destefano and Docker
####################################################

VERSION="3.1"

CREATED="Aug 13 2024"

LAST_UPDATE="Sep 23 2024"

# track cmd history
HISTORY_ON="1"

# history text file
HISTORY_FILENAME="d_history.txt"

# list of saved sessions
DATA_FILE_2="d_saved_sessions.txt"

# Data file
#DATA_FILE="/Users/corelogic/Desktop/DEV/FastAPI/fastDocker/d_data.txt"

# Will be set when we detach a container
CONTAINER_ID='NULL'

# get the current dir this script is being *called* from
CURRENT_DIR=$(pwd)

# Get the directory the script is *actually* in
#SCRIPT_DIR=$(dirname "$(realpath "$0")")

SCRIPT_DIR="/Users/corelogic/docker_helper"

# last active session
DATA_FILE="${SCRIPT_DIR}/d_active.txt"

# 'd.txt' file stored in active user project dir
DFILE="${CURRENT_DIR}/d.txt"


# load functions module
source $SCRIPT_DIR/dbin/functions.sh

# load audio module
source $SCRIPT_DIR/dbin/audio.sh


# sets YYYYMMDD
formatted_date=$(date +'%Y%m%d-%H%M')

# record current command to history
current_dir=$(PWD)

# turn on history tracking when true
if [ "$HISTORY_ON" == "1" ]; then
    echo "${formatted_date} >d ${1} ${2} ${3} ${4} ${5}" >> "${current_dir}/${HISTORY_FILENAME}"
fi

# FAIL SAFE
# ----------------------------------------------
# Show help and exit if no argument to shell provided
if [[ -z $1 ]]; then
    echo ">Error: please provide a command to continue."
    echo "Type: 'd help' for more"
    exit;
fi
# clear the screen
#clear
# pause to show the work
sleep 0.5
# format the curent date
FD=$(date +"%Y-%m-%d %H:%M:%S")
# build the prompt showing the command we are running..
echo "[${FD}] > d ${1} ${2} ${3} ${4} ${5}"
echo "-----------------------------------------"
# shift off the command
CMD=$1
shift

# ----------------[Process Commands]---------------------

# shows help
if [ "$CMD" == "help" ] || [ "$CMD" == "h" ] || [ "$CMD" == "-help" ] || [ "$CMD" == "--help" ]; then
    # 'd help -docs' will only list docs: commands
    if [ "$1" == "-docs" ]; then
        echo "List available reference documentation:"
        cat "$SCRIPT_DIR/d_help.txt" | grep "docs:"

    # list all commands
    else
        cat "$SCRIPT_DIR/d_help.txt"
    fi
    playBell


# check paths
elif [ "$CMD" == "help-examples" ]; then
    echo "Example sessions:"
    echo " > d images -t ; list images in last 7 days"
    echo " > d check     ; checks d.txt file and names"
    echo " > d go        ; builds and runs image/container in d.txt"
    echo " > d logs      ; shows logs from container in d.txt"
    echo " > d sh        ; opens shell to current container in d.txt"
    playBell

# show list of docker or openshift commands -d || -oc
elif [ "$CMD" == "commands" ]; then

    if [ "$1" == "-d" ]; then 
        cat "${SCRIPT_DIR}/commands_docker.txt" | more 
    elif [ "$1" == "-oc" ]; then
        cat "${SCRIPT_DIR}/commands_oc.txt" | more
    else
       cat "${SCRIPT_DIR}/commands_docker.txt" | more  
    fi


elif [ "$CMD" == "python-init" ] || [ "$CMD" == "python-start" ] || [ "$CMD" == "start-python" ]; then
    echo "Creating Python virtual environment.."
    python3 -m venv venv
    echo "Activating environment.."
    source venv/bin/activate
    echo "Installing requirements.txt..."
    pip install -r requirements.txt
    playBell

# check paths
elif [ "$CMD" == "inspect" ]; then
    echo "Docker Helper self-check"
    echo " > SCRIPT DIR:${SCRIPT_DIR}"
    echo " > CURRENT DIR:${CURRENT_DIR}"
    echo " * DATA FILE:${DATA_FILE}"
    echo " @ HISTORY ON: ${HISTORY_ON}"
    echo " @ d     v:$VERSION"
    echo " @ lib   v:$LIB_VERSION"
    echo " @ Audio v:$AUDIO_VER"
    playBell


# show current version infromation
elif [ "$CMD" == "ver" ] || [ "$CMD" == "version" ]; then
    echo "Docker helper - $LAST_UPDATE"
    echo "d     v:$VERSION"
    echo "lib   v:$LIB_VERSION"
    echo "Audio v:$AUDIO_VER"
    playBell

# save d configuration preferences. $1: "option:setting"
elif [ "$CMD" == "config:save" ]; then
    ddata "${1}"


# create d file. $1: image name; $2: container name
elif [ "$CMD" == "create" ]; then
    current_dir=$(pwd)
    d_file="${current_dir}/d.txt"
    echo "INFO:         D: Creating 'd.txt' file using '${1}', '${2}'"
    playBell
    touch "$d_file" && echo -e "${1}\n${2}" >> "$d_file"
    echo "INFO:         D: File created!"

# manual check d.txt file data is valid
elif [ "$CMD" == "check" ]; then
  check_d

# using current directory find any d files recursevely.  $1: optional path instead
elif [ "$CMD" == "which" ] || [ "$CMD" == "inspect" ]; then
  # use current dir if none provided
  if [ -z "$1" ]; then
      current_dir=$(pwd)
      echo "INFO:      D: Inspect from current directory"
      dtxt_search "${current_dir}"

  # user provided path
  else
      uesr_path="${1}"
      echo "INFO:    D: Inspect fro≠m User provided path: $uesr_path"
      dtxt_search "${uesr_path}"
  fi




# build docker image. $1 : image name
elif [ "$CMD" == "build" ]; then
      echo "INFO:      D: Building image '${1}'..."
      playBell
      docker build -t $1 .

# open shell to container. Uses d file in current directory
elif [ "$CMD" == "sh" ]; then
    echo "INFO:      D: Open Shell to '${1}'..."
    playBell
    r=$(get_d)
    # split on comma delimiter
    IFS=',' read -r -a d_data <<< "$r"
    # load the data
    image_name="${d_data[0]}"
    container_name="${d_data[1]}"
    hash_id="${d_data[2]}"
    docker exec -it $container_name /bin/bash


# run a d file from anywhere. $1 : full d file path and name
elif [ "$CMD" == "do" ]; then
    echo "INFO:     D: Load a d.txt file: $1"


# note: will stop and rebuild image if already running
# once d.txt file is created
# we can take over the whole workflow
elif [ "$CMD" == "go" ]; then

    echo "INFO:    D: Let's GO!"

    # use current dir if none provided
    if [ -z "$1" ]; then
        current_dir=$(pwd)
        d_file="${current_dir}/d.txt"
        echo " GO :    D: ${d_file}"
    # user provided path and file
    else
        d_file="${1}"
        echo "INFO:    D: User provided d file: $d_file"
    fi

    echo "INFO:   D:FILE:${d_file}"
    # -------------------------------
    # d.txt file exists
    # -------------------------------

    if [ -e "${d_file}" ]; then
        echo "INFO:    D: d.txt file found, reading data..."
        playBell
        # read data from file
        r=$(get_d "$d_file")

        # split on comma delimiter
        IFS=',' read -r -a d_data <<< "$r"

        # load the data
        image_name="${d_data[0]}"
        container_name="${d_data[1]}"
        hash_id="${d_data[2]}"

        # show the data
        echo " IMAGE: ${image_name}"
        echo " CONTA: ${container_name}"
        echo " HASH : ${hash_id}"


        # make sure we have image and container before trying to call docker on them
        if [ -n "$image_name" ] && [ -n "$container_name" ]; then
            echo "INFO:      D: Re-Building image ${image_name} ${container_name}"

            # first stop the container if it is alreaddy running
            docker stop $container_name

            # now rebuild the image
            docker build -t $image_name .
            # rerunning image (image) (container namse)

            echo "INFO:      D: Removing container ${container_name}.."
            echo "INFO:      D: Re-Running container ${image_name} ${container_name}"

            # first remove any existing container with same name
            OUT=$(docker rm $container_name)
            #openBrowser "http://0.0.0.0:80" &

            echo "INFO:      D: Persisting detatched container ${container_name}"
            CONTAINER_ID=$(docker run -d --name $container_name -p 80:80 $image_name)

            # save container ID to active session file
            echo "INFO:      D: Container HASH: ${CONTAINER_ID}"
            echo "INFO:      D: Saving active sesison "
            echo "${image_name}" > $DFILE
            echo "${container_name}" >> $DFILE
            echo "${CONTAINER_ID}"   >> $DFILE
            echo "INFO:      D: Session data update complete."

        if [ "$1" == "-b" ]; then
            # open browsers
            openBrowser "http://0.0.0.0:80"
            sleep 1
            playCheer
        fi

        else
            echo "INFO:        D: Can't load last, missing image and container names"
        fi
    # -------------------------------
    # d.txt file not found!
    # -------------------------------
    else
        playWarning
        echo "ERR :    D: ERROR: d.txt file not found.."
        echo "INFO:    D:  -->Is the project dir?"
        echo "INFO:    D:  -->Quick Fix: run 'd create <img> <container>'"
    fi





# will stop the last run container hash we stored in the data file
elif [ "$CMD" == "stop" ]; then
        playUnmount
        {
            read -r line1   # first line is the image name
            read -r line2   # second line is the container name
            read -r line3   # second line is the container name
        } < "$DFILE"
        docker stop "${line3}"


# will print logs from the container hash stored in data file
elif [ "$CMD" == "log" ] || [ "$CMD" == "logs" ]; then
        {
            read -r line1   # first line is the image name
            read -r line2   # second line is the container name
            read -r line3   # second line is the container name
        } < "$DFILE"
        docker logs "${line3}"


# list running containers
elif [ "$CMD" == "ps" ] || [ "$CMD" == "running" ] || [ "$CMD" == "active" ]; then
        echo "INFO:       D: List running containers"
        docker ps

# find container with fuzzy searc
elif [ "$CMD" == "search" ] || [ "$CMD" == "search-containers" ] || [ "$CMD" == "find-container" ]; then
        echo "INFO:      D: Finding container ${1}"
        docker ps -a | grep "${1}"


# read image and container name from data file
elif [ "$CMD" == "read" ] || [ "$CMD" == "data" ]; then
        {
            read -r line1   # first line is the image name
            read -r line2   # second line is the container name
            read -r line3   # third line is the container hash
        } < "$DFILE"
        echo "INFO:      D: Reading stored data..."
        echo "             -->IMAGE:${line1}"
        echo "             -->CONTA:${line2}"
        echo "             -->HASH :${line3}"



# open browser to http://0.0.0.0:80
elif [ "$CMD" == "open:browser" ] || [ "$CMD" == "browser" ]; then
    echo "INFO:        D: open browser"
    openBrowser "http://0.0.0.0:80" &


# open docker hub
elif [ "$CMD" == "open:hub" ]; then
    echo "INFO:      D: Opening Docker Hub"
    openBrowser "https://hub.docker.com/search?image_filter=official"


# start the docker daemon
elif [ "$CMD" == "open:docker" ] || [ "$CMD" == "start:docker" ]; then
    if docker info > /dev/null 2>&1; then
        playNo
        sleep 1
        echo "INFO:        D: docker daemon already running"
        playWarning
    else
        echo "INFO:        D: opening docker daemon"
        open -a Docker
        playStartUp
        sleep 1
        playOnline
    fi

# stop docker daemon
elif [ "$CMD" == "close:docker" ] || [ "$CMD" == "exit" ] || [ "$CMD" == "goodbye" ]; then
    echo "INFO:     D: Exit request..."
    echo "> Are you sure you want to exit? y/n"
    read choice
        if [ "$choice" == 'y' ]; then
            echo "Exiting.."
            playStopDocker
            osascript -e 'quit app "Docker"'
        else
            playBad
            echo "Canclled.."
        fi

# test sounds
elif [ "$CMD" == "sound" ]; then
    echo "INFO:    D: Audio test"
    playDone
   #playBeep
   #playUnmount
    #playClick
    #playBeep


# list of links to savailable docs
elif [ "$CMD" == "docs" ]; then
   echo "INFO:      D: showing help"
   cat "$SCRIPT_DIR/d_help.txt" | grep "docs:"


# list of steps using Docker
elif [ "$CMD" == "docs:steps" ]; then
    echo "Using Docker:"
    echo "--------------------------------------------"
    echo "1. Create src/main.py for your application"
    echo "2. Create requirements.txt file in the main directory"
    echo "    - fastapi"
    echo "    - uvicorn"
    echo "3. Create Dockerfile in the main directory and reference the requirements.txt"
    echo "   - CMD [] will contain the uvicorn server startup command"
    echo "4. Build the Docker image"
    echo "   ->'build -t <image-name> .'"
    echo "--------------------------------------------"
    playBell

# open docker documentation
elif [ "$CMD" == "docs:docker" ]; then
    echo "INFO:      D: Opening Docker docs"
    openBrowser "https://docs.docker.com/engine/reference/commandline/cli/"

# open docker documentation
elif [ "$CMD" == "docs:docker:video" ]; then
        echo "INFO:      D: Opening Docker videos"
        openBrowser "https://www.youtube.com/watch?v=0H2miBK_gAk"
        openBrowser "https://www.youtube.com/watch?v=zkMRWDQV4Tg"

# open Python learning documentation
elif [ "$CMD" == "docs:learn" ]; then
    echo "INFO:      D: Opening FastAPI Learn pages.."
    openBrowser "https://fastapi.tiangolo.com/learn/"

# open Fastapi documentation
elif [ "$CMD" == "docs:fastapi" ]; then
    echo "INFO:      D: Opening FastAPI-CLI reference.."
    openBrowser "https://fastapi.tiangolo.com/fastapi-cli/"
    openBrowser "https://fastapi.tiangolo.com/reference/fastapi/"


# open FastHTML documentation
elif [ "$CMD" == "docs:fasthtml" ]; then
    echo "INFO:      D: Opening FastHTML Reference"
    openBrowser "https://github.com/AnswerDotAI/fasthtml-example/blob/main/00_game_of_life/main.py"

# open FastHTML video
elif [ "$CMD" == "docs:fasthtml:video" ]; then
    echo "INFO:      D: Opening FastHTML video"
    openBrowser "https://www.youtube.com/watch?v=Auqrm7WFc0I"
    openBrowser "https://www.youtube.com/watch?v=QqZUzkPcU7A"

# open docker dataset agent image
elif [ "$CMD" == "docs:ai" ]; then
    echo "INFO:      D: Opening AI Reference"
    #openBrowser "https://www.youtube.com/watch?v=gMeTK6zzaO4"
    openBrowser "https://www.youtube.com/watch?v=RW2PeUQKzrE"
    openBrowser "https://hub.docker.com/r/davidondrej1/dataset-agent"

# open docker llama agents
elif [ "$CMD" == "docs:ai:agents" ]; then
    echo "INFO:      D: Opening AI Agents"
    openBrowser "https://github.com/run-llama/llama-agents"

# save data about this session
elif [ "$CMD" == "saveus" ]; then
    echo "Test:${MOD_TEST}"
    save_rec_to_data_file $1 $2 $3
    cat_recs_from_data_files
    playBell

# read saved sessions
elif [ "$CMD" == "readus" ]; then
    echo "Test:${MOD_TEST}"
    cat_recs_from_data_file
    playBell

# list all saved sessions
elif [ "$CMD" == "list" ]; then
    list_sessions
    playBell

# list and pick a session
elif [ "$CMD" == "sessions" ]; then
    list_sessions
    pick_a_session
    playBell

# list docker images
elif [ "$CMD" == "images" ]; then

    # when '-t' time switch used will show images from last week
    if [ "$1" == "-t" ]; then
        echo "INFO:      D: Listing images created in last seven days..."
        docker images --format '{{.Repository}}:{{.Tag}} {{.CreatedSince}}' | grep -E '([1-7] days ago|hours ago|minutes ago)'

    # when '-s' substring switch is used, $2 will be a search query and can be used to tag/group images by substring
    elif [ "$1" == "-s" ]; then
        echo "INFO:      D: Listing images with substring '$2'"
        docker images --format '{{.Repository}}:{{.Tag}}' | grep $2

    # all images
    else
       docker images | more
    fi
    playBell

# find image with fuzzy searc
elif [ "$CMD" == "find" ] || [ "$CMD" == "find-image" ]; then
    echo "INFO:      D: Finding image ${1}"
    docker images | grep "${1}"
    playBell


# rebuild and rerun image. $1: image name; $2: container name
elif [ "$CMD" == "rebuild" ]; then
    echo "INFO:      D: Re-Building image ${1} ${2}"
    
    docker build -t $1 .
    # rerunning image (image) (container name)
    echo "INFO:      D: Re-Running container ${1} ${2}"
    echo "INFO:      D: Removing container ${2}.."
    # first remove any existing container with same name
    OUT=$(docker rm $2)
    #openBrowser "http://0.0.0.0:80" &
    echo "INFO:      D: Starting container ${2}"
    docker run -d --name $2 -p 80:80 $1


# start container
elif [ "$CMD" == "start" ]; then
    echo "INFO:      D: Starting container ${1}"
    openBrowser "http://0.0.0.0:80" &
    # both are required to get a shell
    docker start $1
    docker attach $1


# run docker image by name
elif [ "$CMD" == "run" ]; then
    # running image (image) (container name)
    playBell
    echo "INFO:      D: Running image ${1} ${2}"
    openBrowser "http://0.0.0.0:80" &
    run_image $1 $2


# rerun existing docker image by name
 elif [ "$CMD" == "rerun" ]; then
    # rerunning image (image) (container name)
    echo "INFO:      D: Re-Running container ${1} ${2}"
    echo "INFO:      D: Removing container ${2}.."
    # first remove any existing container with same name
    OUT=$(docker rm $2)
    openBrowser "http://0.0.0.0:80" &
    echo "INFO:      D: Starting container ${2}"
    docker run --name $2 -p 80:80 $1



# run docker image by name in background
elif [ "$CMD" == "persist" ]; then
    # running image (image) (container name)
    echo "INFO:      D: Persisting image ${1} ${2}"
    openBrowser "http://0.0.0.0:80" &
    docker stop $2
    docker rm $2    # first remove any existing container with same name
    playBell
    docker run -d --name $2 -p 80:80 $1







# delete container
elif [ "$CMD" == "rm" ] || [ "$CMD" == "delete" ]; then
    echo "INFO:      D: Deleting container ${1}"
    #docker rmi ${1} -- remove image
    docker rm $1

# list all containers
elif [ "$CMD" == "containers" ]; then
   echo "INFO:      D: List all containers"
    #if [ $1 -ne ]; then
    docker ps -a | more




# list all docker commands
elif [ "$CMD" == "all" ] || [ "$CMD" == "commands" ] || [ "$CMD" == "cmds" ]; then
    echo "> docker build -t fastdocker-image ."
    echo "> docker images | more "
    echo "> docker images | grep <name>"
    echo "> docker run -d --name <con name> -p 80:80 <img name>"
    echo "> docker start <con name>"
    echo "> docker attach <con name>"
    echo "> docker ps -a | more"
    echo "> docker ps"
    echo "> docker rm <con name>"
    echo "> docker rmi <image name"


# save image and container name to data file
elif [ "$CMD" == "save" ]; then
    save_rec_to_data_file $1 $2
    playDone


# save image and container name to data file
elif [ "$CMD" == "save2" ]; then
    # first we read the data from existing file
    {
        read -r line1   # first line is the image name
        read -r line2   # second line is the container name
        read -r line3   # third line is the container hash running
    } < "$DATA_FILE"

    # save image and container name to data file
    if [ "$1" == "-h" ]; then
        echo "INFO:     D: Saving container hash:${2}"
        # now show the work by listing data
        echo "INFO:     D: first line: ${line1}"
        echo "INFO:     D: second line: ${line2}"
        echo "INFO:     D: Saving container hash to data file...${2}"
        # now write the data back to the file the way we found it
        echo "${line1}" > $DATA_FILE
        echo "${line2}" >> $DATA_FILE
        # and finally add the container hash we are running
        echo "${2}" >> $DATA_FILE
    else
        echo "INFO:     D: Saving data.. image:${1} container:${2}"
        echo "${line1}"  > $DATA_FILE
        echo "${line2}"  >> $DATA_FILE
        echo "${line3}"  >> $DATA_FILE
    fi

    # now that we are done, let's print out the data file for clarity
    {
      read -r line1   # first line is the image name
      read -r line2   # second line is the container name
      read -r line3   # second line is the container name
    } < "$DATA_FILE"
    echo "INFO:      D: Reading stored data..."
    echo "             -->IMAGE:${line1}"
    echo "             -->CONTA:${line2}"
    echo "             -->HASH :${line3}"







# Load last saved sessions
# will show menu of last sessions
# user can select which session to return to
elif [ "$CMD" == "load" ] || [ "$CMD" == "last" ]; then
    list_sessions
    echo "> Please type 'x' to exit, or pick a session to continue.."
    playBell
    read choice
    if [ "$choice" == 'x' ]; then
        echo "Exiting.."
    else
        playWorking
        session=$(sed "${choice}q;d" "$DATA_FILE_2")
        # now We have the session
        # echo "Session: ${session}"
        # now split the line on comma
        IFS=',' read -r -a row_data <<< "$session"
        echo "${row_data}"
        echo "     -->Image    : ${row_data[0]}"
        echo "     -->Container: ${row_data[1]}"
        echo "     -->Hash     : ${row_data[2]}"
        image_name="${row_data[0]}"
        container_name="${row_data[1]}"

        # make sure we have image and container before trying to call docker on them
        if [ -n "$image_name" ] && [ -n "$container_name" ]; then
            echo "INFO:      D: Re-Building image ${image_name} ${container_name}"

            # first stop the container if it is alreaddy running
            docker stop $container_name

            # now rebuild the image
            docker build -t $image_name .
            # rerunning image (image) (container namse)

            echo "INFO:      D: Removing container ${container_name}.."
            echo "INFO:      D: Re-Running container ${image_name} ${container_name}"

            # first remove any existing container with same name
            OUT=$(docker rm $container_name)
            #openBrowser "http://0.0.0.0:80" &

            # persist as detatcheds when '-p' switch is used
           # if [ "$1" == "-p" ]; then
                echo "INFO:      D: Persisting detatched container ${container_name}"
                CONTAINER_ID=$(docker run -d --name $container_name -p 80:80 $image_name)

                # save container ID to active session file
                echo "INFO:      D: Container HASH: ${CONTAINER_ID}"
                echo "INFO:      D: Saving active sesison "
                echo "${image_name}" > $DATA_FILE
                echo "${container_name}" >> $DATA_FILE
                echo "${CONTAINER_ID}"   >> $DATA_FILE
                echo "INFO:      D: Active session save complete."

                # open browser
                openBrowser "http://0.0.0.0:80"
                sleep 1
                playCheer

        else
            echo "INFO:        D: Can't load last, missing image and container names"
        fi
    fi

# generate this document
elif [ "$CMD" == "autodoc" ]; then
    echo "Generating documentation"
    sh dbin/autodoc.sh "d" "$VERSION"

else
    playErrorCondition
    echo "> not sure what you mean.. try 'd help' "
fi
