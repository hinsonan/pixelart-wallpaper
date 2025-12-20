cmake_minimum_required(VERSION 3.16)
project(pixelart-wallpaper-tests)

# Find Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS QuickTest Qml)

# Enable testing
enable_testing()

# Create test executable
add_executable(test_runner
    tests/main.cpp
)

# Link Qt libraries
target_link_libraries(test_runner PRIVATE
    Qt6::QuickTest
    Qt6::Qml
)

# Add import paths for QML modules
set(QML_IMPORT_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/ui"
    "${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components"
)

# Set QML import path for the test runner
target_compile_definitions(test_runner PRIVATE
    QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/tests"
)

# Add test
add_test(
    NAME wallhaven_api_tests
    COMMAND test_runner -input ${CMAKE_CURRENT_SOURCE_DIR}/tests
)

# Set environment for test
set_tests_properties(wallhaven_api_tests PROPERTIES
    ENVIRONMENT "QML2_IMPORT_PATH=${CMAKE_CURRENT_SOURCE_DIR}/contents/ui:${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components"
)
