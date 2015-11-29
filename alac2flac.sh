#!/bin/bash

### definitions ################################################################

ALAC2FLAC_VERSION="1.1"
SOURCES=("$@")
FLAC_EXTENSION="flac"
ALAC_EXTENSION="m4a"
ACODEC="flac"
LOG_FILE="alac2flac.log"


### functions ##################################################################

function print_usage(){
    echo "alac2flac version: ${ALAC2FLAC_VERSION}"
    cat <<'EOF'
Usage:

    ./alac2flac.sh [filename|directory]

Description:

    Utility for converting flac audio files to Apple Lossless (ALAC) using FFmpeg.
    Must have FFmpeg installed.

Examples:

    Convert a single flac file:
    ./alac2flac.sh song.flac

    Convert multiple flac files:
    ./alac2flac.sh track_1.flac track_2.flac track_3.flac

    Convert a folder of flac files:
    ./alac2flac.sh album
EOF
}

function alac2flac() {
    local _ALAC_FILE=$1
    local _FLAC_FILE=${_ALAC_FILE/$ALAC_EXTENSION/$FLAC_EXTENSION}

    if [[ -f $_FLAC_FILE ]]; then
        echo "$_FLAC_FILE already exists. Skipping..."
        return
    fi

    if [[ $_ALAC_FILE == *.${ALAC_EXTENSION} ]]; then
        ffmpeg -i "$_ALAC_FILE" -y -acodec $ACODEC "$_FLAC_FILE" >> $LOG_FILE 2>&1 &
    else
        echo "$_ALAC_FILE invalid file"
    fi
}


### main #######################################################################

# check if ffmpeg is installed
if ! type ffmpeg > /dev/null 2>&1; then
	echo "FFmpeg not found. Must have FFmpeg installed."
	exit 1;
fi

# check if any args were passed on the command line
if [[ ${#SOURCES[@]} == 0 ]]; then
    print_usage
    exit 1
fi

for SOURCE in ${SOURCES[*]};
do
    if [[ -d $SOURCE ]]; then
        ALAC_FILES=$(find $SOURCE -name "*.${ALAC_EXTENSION}")
        for ALAC_FILE in ${ALAC_FILES[*]};
        do
            alac2flac "$ALAC_FILE"
        done
    elif [[ -f $SOURCE ]]; then
        alac2flac $SOURCE
    else
        echo "$SOURCE is not valid filename or directory"
        print_usage
        exit 1
    fi
done
