@echo off
setlocal

:: 1. Get the directory of this script.
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT_DIR=%%~fI"

:: 2. Define directory and file paths.
set "SDL3_DIR=%ROOT_DIR%\Engine\vendors\SDL3"
set "SDL3_BUILD_DIR=%SDL3_DIR%\build"
set "SDL3_LIB=%SDL3_BUILD_DIR%\SDL3.lib"
set "SDL3_DLL=%SDL3_BUILD_DIR%\SDL3.dll"
set "BIN_DIR=%ROOT_DIR%\bin"

:: 3. Check if the library already exists.
IF EXIST "%SDL3_LIB%" (
  echo %SDL3_LIB% exists!
  goto :eof
) ELSE (
  echo %SDL3_LIB% does not exist. Building immediately...
)

:: 4. Create the build directory if it doesn't exist.
IF NOT EXIST "%SDL3_BUILD_DIR%" (
    mkdir "%SDL3_BUILD_DIR%"
)

:: 5. Navigate to the build directory and run CMake to configure.
cd /D "%SDL3_BUILD_DIR%"
cmake ..

:: Check if CMake configuration was successful.
IF %ERRORLEVEL% NEQ 0 (
    echo CMake configuration failed.
    exit /b 1
)
echo CMake configuration successful.

:: 6. Build the project.
cmake --build .

:: Check if the build was successful.
IF %ERRORLEVEL% NEQ 0 (
    echo Build failed.
    exit /b 1
)
echo Build successful.

:: 7. Move files from the Debug directory (if it exists).
IF EXIST "%SDL3_BUILD_DIR%\Debug" (
    echo Moving build artifacts from Debug directory...
    move "%SDL3_BUILD_DIR%\Debug\*" "%SDL3_BUILD_DIR%\"
    IF %ERRORLEVEL% NEQ 0 (
        echo Error moving files.
        exit /b 1
    )
    echo Files moved successfully.
)

:: 8. Copy the final DLL to the binary output directory.
IF EXIST "%SDL3_DLL%" (
    echo Copying %SDL3_DLL% to %BIN_DIR%...
    IF NOT EXIST "%BIN_DIR%" mkdir "%BIN_DIR%"
    copy "%SDL3_DLL%" "%BIN_DIR%\SDL3.dll"
    IF %ERRORLEVEL% NEQ 0 (
        echo Failed to copy SDL3.dll.
        exit /b 1
    )
    echo DLL copied successfully.
) ELSE (
    echo Could not find SDL3.dll to copy.
    exit /b 1
)

endlocal
goto :eof
