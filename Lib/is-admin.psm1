using namespace System.Security.Principal
using namespace IsAdmin;


function Get-CurrentPrincipal {
    [OutputType([Security.Principal.WindowsPrincipal])]
    param();
    return New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent());
}

function IsAdmin {
    [OutputType([bool], [System.Exception])]
    param(
        [Parameter(Mandatory = $false)]
        [Security.Principal.WindowsPrincipal]$CurrentPrincipal = $null,

        [Parameter(Mandatory = $false)]
        [boolean]$ThrowIfNotAdmin = $true
    );
    $isAdmin = $null;

    if ($null -eq $CurrentPrincipal) {
        $CurrentPrincipal = Get-CurrentPrincipal;
    };

    $isAdmin = $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);

    if (-not $isAdmin) {
        $err = New-Object System.Management.Automation.ErrorRecord(
            [System.Exception]::new("toggle-faststartup :: IsAdmin :: This script requires administrative privileges"),
            "NotAdmin",
            [System.Management.Automation.ErrorCategory]::PermissionDenied,
            $null
        );
        throw $err;
    };

    if ($isAdmin.GetType().Name -ne "Boolean") {
        Write-Host("IsAdmin :: Error: isAdmin is not a boolean") -ForegroundColor Red;
        throw "Error: isAdmin is not a boolean";
    };

    return [bool]$isAdmin;
}


Export-ModuleMember -Function IsAdmin;
