using namespace Utils;


function InvertValue {
    [OutputType([int], [bool], [System.Exception])] # UNIONS OMG
    param(
        [PSCustomObject]$CurrentValueObject = $null
    );
    $inverseValue = $null;

    if ($null -eq $CurrentValueObject) {
        Write-Host("Error: Value is null") -ForegroundColor Red;
        $inverseValue = $null;
        throw New-Object System.Exception("Value is null");
    };

    if ($null -eq $CurrentValueObject.TypeNameOfValue) {
        Write-Host("Error: TypeNameOfValue is null") -ForegroundColor Red;
        $inverseValue = $null;
        throw New-Object System.Exception("TypeNameOfValue is null");
    };

    if ($CurrentValueObject.TypeNameOfValue -eq "System.Int32") {
        $inverseValue = [int]$CurrentValueObject.Value -eq 0 ? 1 : 0;
    } elseif ($CurrentValueObject.TypeNameOfValue -eq "System.Boolean") {
        $inverseValue = -not [bool]$CurrentValueObject.Value;
    } else {
        Write-Host("Error: Unsupported registry value type '$($CurrentValueObject.TypeNameOfValue)'.") -ForegroundColor Red;
        $inverseValue = $null;
        throw New-Object System.Exception("Unsupported registry value type '$($CurrentValueObject.TypeNameOfValue)'.");
    };

    return $inverseValue;
}


Export-ModuleMember -Function InvertValue;
