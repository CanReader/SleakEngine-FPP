#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Set the directories
ENGINE_SHADERS_DIR="$ROOT_DIR/Engine/shaders"
SHADERS_DIR="$ROOT_DIR/Game/shaders"
OUTPUT_DIR="$ROOT_DIR/Engine/assets/shaders"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Compile engine shader files (default_shader, etc.)
for shader in "$ENGINE_SHADERS_DIR"/*.{vert,frag,comp,geom,tesc,tese}
do
  if [[ -f "$shader" ]]; then
    filename=$(basename "$shader")
    output_file="$OUTPUT_DIR/$filename.spv"

    glslc "$shader" -o "$output_file"

    if [[ $? -eq 0 ]]; then
      echo "Compiled $shader to $output_file"
    else
      echo "Failed to compile $shader"
    fi
  fi
done

# Compile game shader files (if any)
for shader in "$SHADERS_DIR"/*.{vert,frag,comp,geom,tesc,tese}
do
  if [[ -f "$shader" ]]; then
    filename=$(basename "$shader")
    output_file="$ROOT_DIR/Game/assets/shaders/$filename.spv"

    mkdir -p "$(dirname "$output_file")"
    glslc "$shader" -o "$output_file"

    if [[ $? -eq 0 ]]; then
      echo "Compiled $shader to $output_file"
    else
      echo "Failed to compile $shader"
    fi
  fi
done
