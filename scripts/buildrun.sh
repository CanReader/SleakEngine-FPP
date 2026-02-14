#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Run build.sh script
if "$SCRIPT_DIR/build.sh"; then
    echo -e "\033[0;32mBuild successful! Running the application...\033[0;37m"

    # Check if ./app exists and is executable
    if [ -x "$ROOT_DIR/bin/SleakEngine" ]; then
        "$ROOT_DIR/bin/SleakEngine" -t Sleak_Engine
    else
        echo -e "\033[0;31mError: SleakEngine does not exist or is not executable.\033[0;37m"
    fi
else
    echo -e "\033[0;31mBuild failed. Exiting...\033[0;37m"
fi
