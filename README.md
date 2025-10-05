# Toggle Fast Startup PowerShell Module

This PowerShell module provides a simple way to toggle the fast startup feature in Windows. Fast startup can be useful for quicker boot times, but it may also cause compatibility issues with certain hardware or software configurations. This module allows you to easily enable or disable fast startup as needed.

## Prerequisites

- Windows operating system
- PowerShell 5.0 or later
- Administrative privileges

## Installation

To use this module, you need to import it into your PowerShell session. You can do this by running the following command:

```powershell
Import-Module -Name path\to\toggle-faststartup
```

Make sure to replace `path\to\toggle-faststartup.psd1` with the actual path to the module manifest file.

## Usage

There are two ways to toggle fast startup using this module:

1. **Import the module:**

   ```powershell
   Import-Module -Name path\to\toggle-faststartup
   ```

   This will run the `toggle-faststartup.ps1` script, which toggles the fast startup setting.

2. **Run the script directly:**

   ```powershell
   .\toggle-faststartup.ps1
   ```

   This will also toggle the fast startup setting.

In both cases, the script will check the current state of fast startup and switch it to the opposite state.

**Note:** This script requires administrative privileges to modify the necessary registry settings. If you are not running PowerShell as an administrator, you will be prompted to do so.

Because this module requires administrative permissions, you can either run it
from an elevated terminal; or if you hate having to open a new shell just
to run something - you can use a command like this if you have the 'sudo'
command enabled for Windows.

```powershell
sudo pwsh.exe -c .\toggle-faststartup
```

#### Note - Alternative to Windows `sudo` feature

If you prefer, you may use `gsudo` (This is my personal preference)

I also use `scoop` to install anything wherever possible,
if you don't have it (scoop) or `gsudo` installed, you can find them here:

Scoop:
  [scoop.sh](https://scoop.sh/)

gsudo:
  [gsudo link](https://gerardog.github.io/gsudo/)

Alternative command you would run with `gsudo`:

```powershell
gsudo pwsh.exe -c .\toggle-faststartup
```

## Project Structure

The project is structured as follows:

- `toggle-faststartup.psd1`: The module manifest.
- `toggle-faststartup.ps1`: The main script that toggles fast startup.
- `Lib/`: A directory containing helper modules:
  - `is-admin.psm1`: Functions to check for administrative privileges.
  - `registry-path.psm1`: Functions for working with the Windows registry.
  - `utils.psm1`: Utility functions used by the main script.

## Author

MrDwarf7, Blake B. <github.com/MrDwarf7>

## Copyright

(c) MrDwarf7. All rights reserved.
