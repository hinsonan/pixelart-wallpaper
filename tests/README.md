# Unit Tests for Pixel Art Wallpaper Plugin

This directory contains Qt Quick Test unit tests for the KDE Plasma wallpaper plugin.

## Test Coverage

### tst_wallhaven_api.qml

Tests the Wallhaven API URL construction and query parameter handling:

- **URL Format Tests**: Verify correct base URL and parameter structure
- **Category Tests**: Test all category combinations (General, Anime, People)
  - 100 (General only)
  - 010 (Anime only)
  - 001 (People only)
  - 110 (General + Anime)
  - 111 (All categories)
- **Purity Tests**: Test content rating parameters
  - 100 (SFW only)
  - 010 (Sketchy)
  - 110 (SFW + Sketchy)
- **Query Encoding Tests**: Verify special characters and spaces are properly URL-encoded
- **Sorting Tests**: Test different sorting options (random, toplist, date_added)
- **Resolution Tests**: Test minimum resolution constraints (1920x1080, 3840x2160, etc.)
- **Edge Cases**: Empty queries, special characters

## Running the Tests

### Prerequisites

Make sure you have Qt 6 development packages installed:

```bash
# On Arch Linux
sudo pacman -S qt6-base qt6-declarative cmake

# On Ubuntu/Debian
sudo apt install qt6-base-dev qt6-declarative-dev cmake
```

### Quick Run

Use the provided test runner script:

```bash
./run_tests.sh
```

### Manual Build and Run

```bash
# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake ..

# Build
make

# Run tests
./test_runner -input ../tests
```

### Running Specific Tests

To run a specific test function:

```bash
./build/test_runner -input tests -functions test_categories_general_only
```

To see verbose output:

```bash
./build/test_runner -input tests -v2
```

## Test Structure

Each test file uses the Qt Quick Test framework:

```qml
import QtQuick
import QtTest

TestCase {
    name: "TestSuiteName"

    function test_something() {
        verify(condition)
        compare(actual, expected)
    }
}
```

## Adding New Tests

1. Create a new `.qml` file in the `tests/` directory with the prefix `tst_`
2. Import `QtQuick` and `QtTest`
3. Create a `TestCase` component
4. Add test functions with the `test_` prefix
5. Run `./run_tests.sh` to execute all tests

## CI Integration

To integrate with CI/CD pipelines:

```bash
# Exit with non-zero code on test failure
cd build && ctest --output-on-failure
```

## Expected Output

When all tests pass, you should see:

```
********* Start testing of pixelart_tests *********
...
PASS   : WallhavenAPITests::test_build_url_with_defaults()
PASS   : WallhavenAPITests::test_categories_general_only()
...
Totals: 15 passed, 0 failed, 0 skipped, 0 blacklisted
********* Finished testing of pixelart_tests *********
```

## Troubleshooting

**Error: "Could not find Qt6QuickTest"**
- Install Qt 6 development packages (see Prerequisites)

**Error: "No test functions found"**
- Make sure test functions start with `test_`
- Check that the test file is in the `tests/` directory

**QML import errors**
- Verify the QML_IMPORT_PATH is set correctly in CMakeLists.txt
- Check that component files are in the correct directory structure
