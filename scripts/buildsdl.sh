#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SDL3_DIR="$ROOT_DIR/Engine/vendors/SDL3"
SDL3_BUILD_DIR="$SDL3_DIR/build"
SDL3_DEBUG_DIR="$SDL3_BUILD_DIR/Debug"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SDL3_LIB="$SDL3_BUILD_DIR/libSDL3.so"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "winnt"* ]]; then
    SDL3_LIB="$SDL3_BUILD_DIR/SDL3.lib"
fi

if [ -e "$SDL3_LIB" ]; then
  echo "$SDL3_LIB exists!"
  exit
else
  echo "$SDL3_LIB does not exists :(( but dont worry I'm building that immediately..."
fi

if [ ! -d "$SDL3_BUILD_DIR" ]; then
    mkdir $SDL3_BUILD_DIR
fi

cd $SDL3_BUILD_DIR
cmake ..

if [ $? -eq 0 ]; then
    echo "CMake configuration successful."

    build_result=$(cmake --build .)

    if [ $? -eq 0 ]; then
        echo "Build successful."
        if [ -d "Debug" ]; then
            find Debug -type f -exec mv {} . \;
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                cp "$SDL3_BUILD_DIR/libSDL3.so" "$ROOT_DIR/bin/libSDL3.so"
            elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "winnt"* ]]; then
                cp "$SDL3_BUILD_DIR/SDL3.dll" "$ROOT_DIR/bin/SDL3.dll"
            fi
        if [ $? -eq 0 ]; then
            echo "Files moved successfully."
        else
            echo "Error moving files."
            exit 1
        fi
    else
        echo "Debug directory not found."
    fi
    else
        echo "Build failed."
        echo "$build_result"
        exit 1
    fi

else
    echo "CMake configuration failed."
    echo "$cmake_result"
    exit 1
fi
