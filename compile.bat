@echo off
chcp 65001 > nul

:: ==================================================================
:: ASEPRITE PORTABLE COMPILER SCRIPT
::
:: INSTRUCTIONS:
:: 1. Place this script in a directory (e.g., "AsepriteCompiler").
:: 2. Place the extracted source code folders inside the same directory:
::
::    AsepriteCompiler/
::    |
::    +--- compile.bat (This script)
::    |
::    +--- Aseprite/   (Folder containing Aseprite source code)
::    |
::    +--- Skia/       (Folder containing the Skia library)
::    |
::    +--- ninja/      (Folder containing ninja.exe)
::
:: 3. Run this script. The "Aseprite_Portable" folder will be created.
:: ==================================================================

:: --- Configure relative paths ---
set "BASE_DIR=%~dp0"
set "ASEPRITE_SOURCE_PATH=%BASE_DIR%Aseprite"
set "SKIA_SOURCE_PATH=%BASE_DIR%Skia"
set "NINJA_PATH=%BASE_DIR%ninja"
set "FINAL_DESTINATION=%BASE_DIR%Aseprite_Portable"

echo --- Base Directory: "%BASE_DIR%"
echo --- Final Destination: "%FINAL_DESTINATION%"
echo.

:: --- Auto-detect Visual Studio ---
echo --- Searching for Visual Studio...
set "VSWHERE_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE_PATH%" (
    echo ERROR: vswhere.exe not found. Please ensure Visual Studio Installer is installed.
    pause
    exit /b
)

for /f "usebackq tokens=*" %%i in (`"%VSWHERE_PATH%" -latest -property installationPath`) do (
    set "VS_INSTALL_PATH=%%i"
)

if not defined VS_INSTALL_PATH (
    echo ERROR: No Visual Studio installation found.
    pause
    exit /b
)

set "VS_DEV_CMD_PATH=%VS_INSTALL_PATH%\Common7\Tools\VsDevCmd.bat"
if not exist "%VS_DEV_CMD_PATH%" (
    echo ERROR: VsDevCmd.bat not found at "%VS_INSTALL_PATH%".
    pause
    exit /b
)

echo --- Found Visual Studio at: %VS_INSTALL_PATH%
echo.


:: --- Start Compilation Process ---
:: Clean up previous build attempts
if exist "C:\aseprite" rmdir /s /q "C:\aseprite"
if exist "C:\deps" rmdir /s /q "C:\deps"

:: Add Ninja to the script's PATH
echo --- Adding Ninja to PATH...
set "PATH=%NINJA_PATH%;%PATH%"

:: Call Developer Command Prompt
echo --- Initializing Developer Command Prompt...
call "%VS_DEV_CMD_PATH%" -arch=x64
@echo on

:: Check if local source folders exist
if not exist "%ASEPRITE_SOURCE_PATH%" (
    echo ERROR: Aseprite source folder not found at: "%ASEPRITE_SOURCE_PATH%"
    pause
    exit /b
)
if not exist "%SKIA_SOURCE_PATH%" (
    echo ERROR: Skia folder not found at: "%SKIA_SOURCE_PATH%"
    pause
    exit /b
)
if not exist "%NINJA_PATH%\ninja.exe" (
    echo ERROR: ninja.exe not found at: "%NINJA_PATH%"
    pause
    exit /b
)

:: Copy core files to working directories
echo --- Setting up working directories...
robocopy "%SKIA_SOURCE_PATH%" "C:\deps\skia" /E
robocopy "%ASEPRITE_SOURCE_PATH%" "C:\aseprite" /E
mkdir C:\aseprite\build

cd C:\aseprite\build

:: Build Aseprite as a portable (statically-linked) application
echo --- Starting CMake configuration for a portable build...
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded -DLAF_BACKEND=skia -DSKIA_DIR=C:\deps\skia -DSKIA_LIBRARY_DIR=C:\deps\skia\out\Release-x64 -DSKIA_LIBRARY=C:\deps\skia\out\Release-x64\skia.lib -G Ninja ..

:: Check for CMake errors
if errorlevel 1 (
    echo.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo  ERROR: CMake configuration failed.
    echo  Please scroll up and check the output for error messages.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    pause
    exit /b
)

echo --- Starting Ninja build (data files)...
ninja data

:: Check for Ninja build errors
if errorlevel 1 (
    echo.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo  ERROR: Ninja 'data' build failed.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    pause
    exit /b
)

echo --- Starting Ninja build (main program). This will take a long time...
ninja aseprite

:: Check for Ninja build errors
if errorlevel 1 (
    echo.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo  ERROR: Ninja 'aseprite' build failed. The compilation was not successful.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    pause
    exit /b
)


:: --- Cleanup and Finalize ---
@echo off
echo.
echo ==========================================================
echo  Compilation completed successfully! Creating portable folder...
echo ==========================================================

:: Create final destination folder
if exist "%FINAL_DESTINATION%" rmdir /s /q "%FINAL_DESTINATION%"
mkdir "%FINAL_DESTINATION%"

:: Move final program files and data folder to destination
echo --- Moving final program to %FINAL_DESTINATION%...
move "C:\aseprite\build\bin\data" "%FINAL_DESTINATION%\"
move "C:\aseprite\build\bin\aseprite.exe" "%FINAL_DESTINATION%\"
move "C:\aseprite\build\bin\gen.exe" "%FINAL_DESTINATION%\"
move "C:\aseprite\build\bin\icudtl.dat" "%FINAL_DESTINATION%\"


:: Delete temporary folders
echo --- Deleting temporary build files...
rmdir /s /q "C:\aseprite"
rmdir /s /q "C:\deps"

echo.
echo ====================================================================
echo  Cleanup complete! Aseprite is ready.
echo  You can now zip the folder below and send it to your friends.
echo  Location: %FINAL_DESTINATION%
echo ====================================================================
timeout /t 2 /nobreak >nul
start "" "%FINAL_DESTINATION%"

pause
