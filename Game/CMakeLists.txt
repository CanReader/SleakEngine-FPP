cmake_minimum_required(VERSION 3.31)

project(SleakGame)

file(GLOB_RECURSE GAME_SOURCES "src/*.cpp")

add_library(SleakGame SHARED ${GAME_SOURCES})

target_compile_definitions(SleakGame PRIVATE SLEAK_EXPORTS)

target_include_directories(SleakGame PUBLIC
                          ${CMAKE_CURRENT_SOURCE_DIR}/include
                          ${CMAKE_SOURCE_DIR}/Engine/include/public)

target_link_libraries(SleakGame PRIVATE Engine)
