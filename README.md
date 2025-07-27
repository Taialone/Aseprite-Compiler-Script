# Aseprite Portable Compiler for Windows

This repository contains a batch script (`compile.bat`) that automates the process of compiling Aseprite from source on Windows. The script creates a fully portable version that can be run on other computers without needing any dependencies.

## Features

- **Fully Automated**: Just set up the folders and run the script.
- **Portable Build**: Compiles Aseprite with static libraries, so you can easily share the final program.
- **Auto-detects Visual Studio**: No need to manually configure paths to your VS installation.
- **Clean Workspace**: Automatically creates and deletes temporary working directories (`C:\aseprite`, `C:\deps`).

## Prerequisites

- **Windows 10/11**
- **Visual Studio Community/Professional/Enterprise** (2019 or newer) with the **"Desktop development with C++"** workload installed.

## What You Need to Download

Before running the script, you need to download the following components:

1.  **Aseprite Source Code**:
    - Go to the [Aseprite Releases Page](https://github.com/aseprite/aseprite/releases).
    - Download the source code zip file for the version you want (e.g., `Aseprite-v1.3.7-source.zip`).

2.  **Skia Library**:
    - Go to the [Aseprite Skia Releases Page](https://github.com/aseprite/skia/releases).
    - Download the Skia library that matches your Aseprite version (e.g., `Skia-m102-aseprite-v1.3-win-x64-release.zip`).

3.  **Ninja Build System**:
    - Go to the [Ninja Releases Page](https://github.com/ninja-build/ninja/releases).
    - Download the `ninja-win.zip` file.

## How to Use

1.  Create a main working directory for the project. For example, `C:\AsepriteCompiler`.

2.  Place the `compile.bat` script inside this main directory.

3.  Download and extract the required components into subfolders within the main directory. The final folder structure **must** look like this:

    ```
    AsepriteCompiler/
    |
    +--- compile.bat
    |
    +--- Aseprite/       <-- Extracted Aseprite source code goes here
    |
    +--- Skia/           <-- Extracted Skia library goes here
    |
    +--- ninja/          <-- Extracted ninja.exe goes here
    ```

4.  Double-click `compile.bat` to run it.

5.  The script will open a command prompt and begin the compilation process. This can take a significant amount of time (15-30 minutes depending on your system).

## Result

Once the script finishes successfully, it will:
- Create a new folder named `Aseprite_Portable` inside your main directory.
- Open this folder for you.
- The `Aseprite_Portable` folder contains the complete, ready-to-use Aseprite application. You can zip this folder and share it with others.

## Troubleshooting

- **`vswhere.exe not found`**: This means the script cannot find your Visual Studio installation. Make sure you have Visual Studio 2019 or newer installed correctly.
- **`CMake configuration failed`**: This usually indicates a problem with the source files or dependencies. Double-check that your Skia version is compatible with your Aseprite version as specified in Aseprite's `INSTALL.md`.
- **`Ninja build failed`**: A C++ compilation error occurred. This can be complex, but often relates to an incorrect Visual Studio workload setup. Ensure the "Desktop development with C++" workload is fully installed.
