@echo off
setlocal enabledelayedexpansion

:: 1. Define base directories from the script's location.
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%I in ("%SCRIPT_DIR%\..") do set "ROOT_DIR=%%~fI"
set "BIN_DIR=%ROOT_DIR%\bin"
set "BUILD_DIR=%ROOT_DIR%\build"
set "ENGINE_ASSETS_DIR=%ROOT_DIR%\Engine\assets"
set "GAME_ASSETS_DIR=%ROOT_DIR%\Game\assets"

:: 2. Clean up previous build output.
echo Cleaning previous build directories...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%BIN_DIR%" rmdir /s /q "%BIN_DIR%"

:: 3. Build the SDL3 dependency first.
echo --- Building SDL3 ---
call "%SCRIPT_DIR%\buildsdl.bat"
if !errorlevel! neq 0 (
    echo Failed to build SDL library! Aborting.
    exit /b 1
)
echo --- SDL3 build check successful ---
echo.

:: 4. Create directories for the main project build.
echo Creating build directory for the main project...
mkdir "%BUILD_DIR%"
cd /D "%BUILD_DIR%"

:: 5. Configure the main project with CMake.
echo --- Configuring Main Project ---
cmake -DCMAKE_BUILD_TYPE=Debug "%ROOT_DIR%"
if !errorlevel! neq 0 (
    echo CMake configuration for the main project failed.
    exit /b 1
)
echo --- Main Project Configuration Successful ---
echo.

:: 6. Build the main project.
echo --- Building Main Project ---
cmake --build .
if !errorlevel! neq 0 (
    echo Main project build failed. Please check the output for errors.
    exit /b 1
)
echo --- Main Project Build Successful ---
echo.

:: 7. Post-build steps.
cd /D "%ROOT_DIR%"

echo --- Performing post-build steps ---
echo Renaming and moving executable...
move "%BIN_DIR%\Debug\Client.exe" "%BIN_DIR%\SleakEngine.exe"

echo Copying assets...
xcopy "%ENGINE_ASSETS_DIR%" "%BIN_DIR%\assets\" /s /i /y
xcopy "%GAME_ASSETS_DIR%" "%BIN_DIR%\assets\" /s /i /y

:: Copy required DLLs to the bin directory.
set "SDL3_DLL_SOURCE=%ROOT_DIR%\Engine\vendors\SDL3\build\SDL3.dll"
if exist "%SDL3_DLL_SOURCE%" (
    echo Copying SDL3.dll to final bin directory...
    copy "%SDL3_DLL_SOURCE%" "%BIN_DIR%\SDL3.dll"
) else (
    echo WARNING: Could not find SDL3.dll to copy. The application may not run.
)

set "YAML_DLL_SOURCE=%ROOT_DIR%\Engine\vendors\yaml-cpp\build\yaml-cppd.dll"
if exist "%YAML_DLL_SOURCE%" (
    echo Copying yaml-cppd.dll to final bin directory...
    copy "%YAML_DLL_SOURCE%" "%BIN_DIR%\yaml-cppd.dll"
) else (
    echo WARNING: Could not find yaml-cppd.dll to copy. The application may not run.
)

echo.
echo Build process completed successfully!

endlocal
exit /b 0
