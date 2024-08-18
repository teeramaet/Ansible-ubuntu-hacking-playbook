#!/bin/bash
set -e

COLOR_END='\e[0m'
COLOR_RED='\e[0;31m' # Red
COLOR_YEL='\e[0;33m' # Yellow

# This current directory.
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$DIR/../" && pwd)

PYTHON_REQUIREMENTS_FILE="$DIR/requirements.txt"
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
        msg_warning "You are running Debian-based Linux."
        # Install build-essential and python3-dev
        echo "Installing required packages..."
        sudo apt-get update
        sudo apt-get install -y build-essential python3-dev
    else
        msg_warning "Your Linux system was not tested; We have tested only on Ubuntu."
    fi
fi

# Check if root
# Since we need to make sure paths are okay, we need to run as a normal user who will use Ansible
[[ "$(whoami)" == "root" ]] && msg_exit "Please run as a normal user, not root."

# Check python
if ! command -v python3 &> /dev/null; then
    msg_exit "Python3 is not installed or is not in your path. Please install Python and try again."
fi

# Check python requirements file
[[ ! -f "$PYTHON_REQUIREMENTS_FILE" ]]  && msg_exit "Python requirements file '$PYTHON_REQUIREMENTS_FILE' does not exist or has permission issues. Please check and rerun."

# Install Python packages
echo "This script installs Python packages defined in '$PYTHON_REQUIREMENTS_FILE'."
echo "Installing requirements..."
pip3 install --no-cache-dir --upgrade --requirement "$PYTHON_REQUIREMENTS_FILE"

# Touch finished-indicator
echo "Touching finished."
if [ -w "$ROOT_DIR" ]; then
   touch "$FINISHED_FILE"
else
  sudo touch "$FINISHED_FILE"
fi
exit 0
