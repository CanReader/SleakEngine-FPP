cmake_minimum_required(VERSION 3.31)

project(Client)

file(GLOB_RECURSE CLIENT_SOURCES "src/*.cpp")

add_executable(SleakEngine ${CLIENT_SOURCES})

target_link_libraries(SleakEngine PRIVATE SleakGame Engine)

target_include_directories(SleakEngine PRIVATE ${CMAKE_SOURCE_DIR}/Game/include)

# --- Post-build: copy assets to output directory ---
add_custom_command(TARGET SleakEngine POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/Engine/Engine/assets
        $<TARGET_FILE_DIR:SleakEngine>/assets
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/Game/assets
        $<TARGET_FILE_DIR:SleakEngine>/assets
    COMMENT "Copying assets to output directory"
)

# --- Post-build: copy runtime DLLs (Windows) ---
if(WIN32)
    add_custom_command(TARGET SleakEngine POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_RUNTIME_DLLS:SleakEngine>
            $<TARGET_FILE_DIR:SleakEngine>
        COMMAND_EXPAND_LISTS
    )
endif()
