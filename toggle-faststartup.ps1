## toggle-faststartup.ps1

<#
#
#    .SYNOPSIS
#    Toggles fast startup on or off.
#
#    This script is used for toggling Windows 'fake shutdown' feature, which is known as 'fast startup'.
#
#    .DESCRIPTION
#    This script toggles the fast startup feature in Windows.
#
#>

### Dev things -
### Colors:
### Magenta - Base settings/debug/variable info
### Green - Good/Success
### Red - Bad/Error
### Cyan - Info
### Yellow - Warning/Info


## Have to do some janky stuff here because of powershell module system being crap.
using namespace Lib.IsAdmin;
using namespace Lib.RegistryPath;
using namespace Lib.Utils;

# Import-Module .\Lib\is-admin.psm1 -Force;

using module .\Lib\is-admin.psm1;
using module .\Lib\registry-path.psm1
using module .\Lib\utils.psm1

Write-Host("");


function GetWindowsTool {
    [OutputType([any])]
    param(
        [string]$ToolName = $null
    )
    $windowsPath = $env:WINDIR;
    $sys32 = "$windowsPath\System32";
    $pathValue = $env:PATH -split ';';

    # First we scan sys32, then if we can't find it, we scan the PATH

    $toolPath = Join-Path -Path $sys32 -ChildPath $ToolName;

    if (Test-Path -Path $toolPath) {
        return $toolPath;
    } else {
        foreach ($path in $pathValue) {
            $fullPath = Join-Path -Path $path -ChildPath $ToolName;
            if (Test-Path -Path $fullPath) {
                return $fullPath;
            };
        };
    };

    if ($null -eq $ToolName) {
        return $null;
    };

    # Error path-way technically - we failed all general stop-checks
    Write-Host("Error: Tool '$ToolName' not found in System32 or PATH.") -ForegroundColor Red;

    return [void]$null;
}


function Setup {
    [OutputType([void])]
    param()

    $isAdmin = $null;

    try {
        $isAdmin = IsAdmin;
    } catch {
        Write-Host("toggle-faststartup :: Main :: isAdmin :: Catch :: Error: $_") -ForegroundColor Red;

        Write-Host("Error:
`t` Setup :: This script requires administrative privileges") -ForegroundColor Red;
        Write-Host("
`t` If you have 'sudo' turned on in Developer Features,
`t` you can use `"sudo pwsh.exe -c `'$($PSScriptRoot)`'`" to run this script as admin
") -ForegroundColor Cyan;

        exit 1;
    }

    # something something redundancy or w/e
    if (-not $isAdmin) {
        Write-Host("Error:
`t` Setup :: This script requires administrative privileges") -ForegroundColor Red;
        Write-Host("
`t` If you have 'sudo' turned on in Developer Features,
`t` you can use `"sudo pwsh.exe -c `'$($PSScriptRoot)`'`" to run this script as admin
") -ForegroundColor Cyan;

        exit 1;
    }
    return [void]$null;
}


function Main {
    [OutputType([int], [System.Exception])]
    param()

    $regPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power";
    $regName = "HiberbootEnabled";
    $currentValue = $null;
    $inverseValue = $null;

    try {
        $currentValue = GetRegistryValue -RegPath $regPath -RegKey $regName -PropertyName $regName;
    } catch {
        Write-Host("Main::GetRegistryValue $currentValue :: Error: $_") -ForegroundColor Red;
        Write-Host("Main::GetRegistryValue :: Error: $_") -ForegroundColor Red;
        throw New-Object System.Exception("Error querying registry: $_");
    };

    if ($null -eq $currentValue) {
        # Should basically never happen
        Write-Host("Error: Could not retrieve registry value for '$regName' at '$regPath'.") -ForegroundColor Red;
        throw New-Object System.Exception("Could not retrieve registry value for '$regName' at '$regPath'.");
    };

    Write-Host("Current value: $($currentValue.Value) (Type: $($currentValue.TypeNameOfValue))") -ForegroundColor Cyan;
    try {
        $inverseValue = InvertValue -CurrentValueObject $currentValue;
    } catch {
        Write-Host("Main :: Error: $_") -ForegroundColor Red;
        throw New-Object System.Exception("toggle-faststartup :: Main :: Error inverting value: $_");
    };

    Write-Host("Inverse value: $($inverseValue) (Type: $($currentValue.TypeNameOfValue))") -ForegroundColor Cyan;
    if ($inverseValue -eq $currentValue.Value) {
        Write-Host("Main :: Error: Inverted value is the same as current value") -ForegroundColor Red;
        throw New-Object System.Exception("Inverted value is the same as current value");
    };

    try {
        # Set it to the inverted value
        SetRegistryValue -RegPath $regPath -RegKey $regName -Value $inverseValue;
    } catch {
        Write-Host("Main :: Error: $_") -ForegroundColor Red;
        $err = New-Object System.Exception("Error setting registry value: $_");
        throw $err;
    };


    $means = if ($inverseValue -eq 1) {
        "enabled";
    } else {
        "disabled";
    };

    Write-Host("Fast startup toggled successfully") -ForegroundColor Green;
    Write-Host("Was: $($currentValue.Value) (Type: $($currentValue.TypeNameOfValue))") -ForegroundColor Cyan;
    Write-Host("Now: $($inverseValue) (Type: $($currentValue.TypeNameOfValue))") -ForegroundColor Cyan;
    Write-Host("");

    if ($means -eq "enabled") {
        Write-Host("Fast startup is now [ $means ]") -ForegroundColor Blue;
    } else {
        Write-Host("Fast startup is now [ $means ]") -ForegroundColor Yellow;
    };

    return 0;
}



Write-Host("Running setup") -ForegroundColor Yellow;

# $vars = Setup;

Setup;

# if ($null -eq $vars) {
#     Write-Host("Error: $vars") -ForegroundColor Red;
#     Write-Host("Error: $_") -ForegroundColor Red;
#     exit 1;
# };

$res = $null;

Write-Host("Running main") -ForegroundColor Yellow;
try {
    $res = Main;
} catch {
    Write-Host("Error: $res") -ForegroundColor Red;
    Write-Host("Error: $_") -ForegroundColor Red;
};

if ($null -eq $res) {
    Write-Host("Error: $res") -ForegroundColor Red;
    Write-Host("Error: $_") -ForegroundColor Red;
};

Write-Host("");
Write-Host("Done") -ForegroundColor Green;
