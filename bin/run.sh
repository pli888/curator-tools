#!/bin/bash

################
# Set up logging
################

colblk='\033[0;30m' # Black - Regular
colred='\033[0;31m' # Red
colgrn='\033[0;32m' # Green
colylw='\033[0;33m' # Yellow
colpur='\033[0;35m' # Purple
colrst='\033[0m'    # Text Reset

verbosity=5

### verbosity levels
silent_lvl=0
crt_lvl=1
err_lvl=2
wrn_lvl=3
ntf_lvl=4
inf_lvl=5
dbg_lvl=6

## esilent prints output even in silent mode
function esilent() { verb_lvl=$silent_lvl elog "$@"; }
function enotify() { verb_lvl=$ntf_lvl elog "$@"; }
function eok() { verb_lvl=$ntf_lvl elog "SUCCESS - $@"; }
function ewarn() { verb_lvl=$wrn_lvl elog "${colylw}WARNING${colrst} - $@"; }
function einfo() { verb_lvl=$inf_lvl elog "${colwht}INFO${colrst} ---- $@"; }
function edebug() { verb_lvl=$dbg_lvl elog "${colgrn}DEBUG${colrst} --- $@"; }
function eerror() { verb_lvl=$err_lvl elog "${colred}ERROR${colrst} --- $@"; }
function ecrit() { verb_lvl=$crt_lvl elog "${colpur}FATAL${colrst} --- $@"; }
function edumpvar() { for var in $@; do edebug "$var=${!var}"; done; }
function elog() {
  if [[ $verbosity -ge $verb_lvl ]]; then
    datestring=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "$datestring - $@"
  fi
}

OPTIND=1
while getopts ":fsVG" opt; do
  case $opt in
  f)
    elog "Setting input file: $3"
    INPUT_FILE=$3
    if ! test -f "$INPUT_FILE"; then
      eerror "${INPUT_FILE} does not exist!!"
    fi
    ;;
  s)
    verbosity=$silent_lvl
    edebug "-s specified: Silent mode"
    ;;
  V)
    verbosity=$inf_lvl
    edebug "-V specified: Verbose mode"
    ;;
  G)
    verbosity=$dbg_lvl
    edebug "-G specified: Debug mode"
    ;;
  esac
done

#########################
# Set up and sanity check
#########################

# Initialise variables
#DOMAIN_NAME="https://variant-spark-test.s3-ap-southeast-1.amazonaws.com/"
DOMAIN_NAME="https://variant-spark.s3-ap-southeast-2.amazonaws.com/"

# Set working directory to this script directory
WD=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# Project directory
PROJECT_DIR="${WD%/*}"

# Input directory
FILE_DIR="${WD%/*}"

# Output directory
OUTPUT_DIR="${WD%/*}/output"

# Check directories
einfo "PROJECT_DIR: "$PROJECT_DIR
einfo "WORKING DIR: "$WD
einfo "OUTPUT_DIR: "$OUTPUT_DIR
einfo "DOMAIN NAME: ${DOMAIN_NAME}"


##############
# Main program
##############

# Read file containing URLs line by line
while read -r line; do

  elog "Processing: ${line}"
  str="${line/$DOMAIN_NAME/}"
  elog "Removed domain name: ${str}"

  # Set backslash as delimiter
  IFS='\/'
  # Read tokens into strarr string array
  read -a strarr <<<"${str}"

  # Process URL
  for ((n = 0; n < ${#strarr[*]}; n++)); do
    elog "Working on: ${strarr[n]}"

    if [ $n -eq 0 ]; then
      dir="$OUTPUT_DIR/${strarr[n]}"

      # Wait 5 secs
      sleep 5

      if [ ! -d "${dir}" ]; then
        elog "Creating directory: ${dir}"
        mkdir -p "${dir}"
      else
        elog "${strarr[n]} directory already present"
      fi

    elif [ $n -eq $((${#strarr[*]} - 1)) ]; then
      elog "Downloading file: ${line}"
      elog "Output file: ${dir}/${strarr[n]}"
      curl -H "Host: variant-spark.s3-ap-southeast-2.amazonaws.com" \
        "${line}" --output "${dir}/${strarr[n]}"

    else
      dir="${dir}/${strarr[n]}"

      if [ ! -d "${dir}" ]; then
        elog "Creating directory: ${dir}"
        mkdir -p "${dir}"
      else
        elog "${strarr[n]} directory already present"
      fi
    fi
  done

done < $INPUT_FILE
