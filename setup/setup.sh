#!/bin/bash
set -e

COLOR_END='\e[0m'
COLOR_RED='\e[0;31m' # Red
COLOR_YEL='\e[0;33m' # Yellow

# This current directory.
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$DIR/../" && pwd)

PYTHON_REQUIREMENTS_FILE="$DIR/requirements.txt"
PYTHON_VIRTUALENV="$ROOT_DIR/.venv"
FINISHED_FILE="$ROOT_DIR/.finished"

# Check if .finished exists
if [ -f "$FINISHED_FILE" ]; then
    echo ".finished file already exists. Setup might have already been completed."
    # Optionally exit or perform actions based on this condition
    exit 0
fi

msg_exit() {
    printf "$COLOR_RED$@$COLOR_END"
    printf "\n"
    printf "Exiting...\n"
    exit 1
}

msg_warning() {
    printf "$COLOR_YEL$@$COLOR_END"
    printf "\n"
}
# Check your environment 
system=$(uname)

if [ "$system" == "Linux" ]; then
    distro=$(lsb_release -i)
    if [[ $distro == *"Ubuntu"* ]] || [[ $distro == *"Debian"* ]] ;then
        msg_warning "Your running Debian based linux."
        # Install build-essential and python-dev
        echo "Installing required packages..."
        sudo apt-get update
        sudo apt-get install -y build-essential python3-dev
    else
        msg_warning "Your linux system was not test, We have test only on Ubuntu"
    fi
fi

# Check if root
# Since we need to make sure paths are okay we need to run as normal user he will use ansible
[[ "$(whoami)" == "root" ]] && msg_exit "Please run as a normal user not root"

# Check python
if ! command -v python3 &> /dev/null; then
    msg_exit "Python3 is not installed or is not in your path. Please install Python and try again"
fi
# Check virtualenvironment
if ! python3 -c "import venv" &> /dev/null; then
    msg_warning "Python3 venv module not installed."
    echo " Installing..."
    sudo apt-get install -y python3-venv
fi
# Check python requirements file
[[ ! -f "$PYTHON_REQUIREMENTS_FILE" ]]  && msg_exit "python_requirements '$PYTHON_REQUIREMENTS_FILE' does not exist or permssion issue.\nPlease check and rerun."


# Install 
# By default we upgrade all packges to latest. if we need to pin packages use the python_requirements
echo "This script install python packages defined in '$PYTHON_REQUIREMENTS_FILE' in the virtualenv at '$PYTHON_VIRTUALENV'"
echo "Creating virtualenvironment '$PYTHON_VIRTUALENV' if it does not already exist..."
python3 -m venv $PYTHON_VIRTUALENV
echo "Activating the virtualenvironment..."
source $PYTHON_VIRTUALENV/bin/activate
echo "Installing requirements..."
pip install --no-cache-dir  --upgrade --requirement "$PYTHON_REQUIREMENTS_FILE"


#Touch finished-indicator
echo "Touching finished"
if [ -w "$ROOT_DIR" ]
then
   touch "$FINISHED_FILE"
else
  sudo touch "$FINISHED_FILE"
fi
exit 0