#!/bin/bash

# Build and run tests for pixelart-wallpaper plugin

set -e

echo "=== Building tests ==="

# Create build directory if it doesn't exist
mkdir -p build
cd build

# Configure with CMake
cmake ..

# Build
make

echo ""
echo "=== Running tests ==="
echo ""

# Run the tests
./test_runner -input ../tests

echo ""
echo "=== Test run complete ==="
