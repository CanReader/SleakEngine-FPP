#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN="$ROOT_DIR/bin"

SDL3_LIB="$ROOT_DIR/Engine/vendors/SDL3/build/libSDL3.so"
SDL3_DIR="$ROOT_DIR/Engine/vendors/SDL3"
SDL3_BUILD_DIR="$SDL3_DIR/build"

if "$SCRIPT_DIR/buildsdl.sh"; then
  echo "Successfully built SDL library!"
else
  echo "Failed to build SDL library!"
  exit
fi

#Compile shaders
if "$SCRIPT_DIR/compile_shaders.sh"; then

# Clean up previous build and binary directories
rm -rf "$ROOT_DIR/build" "$ROOT_DIR/bin"

# Create a new build directory and navigate into it
mkdir "$ROOT_DIR/build" && cd "$ROOT_DIR/build"

# Run CMake to configure the project
cmake -DCMAKE_BUILD_TYPE=Debug "$ROOT_DIR"

Red='\033[0;31m'
Green='\033[0;32m'
White='\033[0;37m'

# Build the project using make
if cmake --build .; then
    # Navigate back to the project root directory
    cd "$ROOT_DIR"
    mv bin/Client bin/SleakEngine
    cp -R "$ROOT_DIR/Engine/assets/." bin/assets/
    cp -R "$ROOT_DIR/Game/assets/." bin/assets/
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      cp "$SDL3_BUILD_DIR/libSDL3.so" "$ROOT_DIR/bin/libSDL3.so"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "winnt"* ]]; then
      cp "$SDL3_BUILD_DIR/SDL3.dll" "$ROOT_DIR/bin/SDL3.dll"
    fi

    echo -e "${Green}Build successful!${White}"
    exit 0
else
    echo ""
    echo ""
    echo -e "${Red}Build failed. Please check the output for errors.${White}"
    exit 1
fi
fi
