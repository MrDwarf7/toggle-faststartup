using namespace RegistryPath


function CorrectRegPath {
    [OutputType([string], [System.Exception])]
    param(
        [string]$RegPath = $null
    )
    $outPath = $null;

    $RegKey = $RegKey.Trim();

    if ($null -eq $RegPath) {
        Write-Host("Error: RegPath is null") -ForegroundColor Red;
        throw New-Object System.Exception("RegPath is null");
    };

    if ($RegPath -match '^HK') {
        # If the RegPath starts with 'HK', we assume it's a registry path
        # this handles both eg: 'HKLM' AND 'HKEY_LOCAL_MACHINE'
        # and we need to prefix it with 'Registry::'
        $outPath = "Registry::$RegPath";
    };

    return [string]$outPath;
}


function GetRegistryValue {
    [OutputType([PSCustomObject], [System.Exception])]
    param(
        [string]$RegPath = $null,
        [string]$RegKey = $null,
        [string]$PropertyName = $null
    )
    [PSCustomObject]$registryObject = $null; # Fill with data from registry
    [System.Exception]$err = $null;
    [PSCustomObject]$output = $null;

    if (($null -eq $RegPath) -or ($null -eq $RegKey)) {
        Write-Host("Error: RegPath or RegKey is null") -ForegroundColor Red;
        $err = New-Object System.Exception("RegPath or RegKey is null");
        throw $err;
    };

    $RegPath = CorrectRegPath -RegPath $RegPath;

    try {
        $registryObject = Get-ItemProperty -Path "$RegPath" -Name $RegKey -ErrorAction SilentlyContinue;
    } catch {
        Write-Host("Error querying registry: $_") -ForegroundColor Red;
        $err = New-Object System.Exception("Error querying registry: $_");
        throw $err;
    };

    if ($null -eq $registryObject) {
        Write-Host("Error: Registry key '$RegKey' not found at path '$RegPath'.") -ForegroundColor Red;
        $err = New-Object System.Exception("Registry key '$RegKey' not found at path '$RegPath'.");
        throw $err;
    };


    if ($null -eq $PropertyName) {
        # If PropertyName is null, we assume we want the whole object - this is in order to fill out the returning type/object
        $PropertyName = $RegKey;
    };

    if ($PropertyName -eq $RegKey) {
        $RegKey = $PropertyName;
    };

    $propListValue = $registryObject.PSObject.Properties.Item($RegKey);

    $output = [PSCustomObject]@{
        Name  = $propListValue.Name;
        TypeNameOfValue  = $propListValue.TypeNameOfValue;
        Value = $propListValue.Value;
    };

    return $output;
}


function SetRegistryValue {
    [OutputType([void], [System.Exception])]
    param(
        [string]$RegPath = $null,
        [string]$RegKey = $null,
        $Value = $null
    );

    if (($null -eq $RegPath) -or ($null -eq $RegKey)) {
        Write-Host("Error: RegPath or RegKey is null") -ForegroundColor Red;
        throw New-Object System.Exception("RegPath or RegKey is null");
    };

    $RegPath = CorrectRegPath -RegPath $RegPath;

    try {
        Set-ItemProperty -Path $RegPath -Name $RegKey -Value $Value -Force -ErrorAction Stop;
    } catch {
        Write-Host("Error setting registry value: $_") -ForegroundColor Red;
        throw New-Object System.Exception("Error setting registry value: $_");
    };
}


Export-ModuleMember -Function GetRegistryValue, SetRegistryValue;
