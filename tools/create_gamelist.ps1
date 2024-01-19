[CmdletBinding()]
Param($Drive)

if ($PSBoundParameters.ContainsKey("drive")) {
    if ($drive -notmatch '^\w:$') {
        Write-host "The drive parameter must be a letter followed by a colon (example E:)" -ForegroundColor Red
        return
    }
} else {
    # Automatically detect the SD Card
    $Removable = Get-CimInstance -ClassName Win32_Volume | ? { $_.drivetype -eq 2 -and  $_.filesystem -like "FAT32" -and $_.DriveLetter } | select -ExpandProperty DriveLetter
    $removable = $removable | ? { test-path ($_ + "\ports\") }

    if (!$removable) {
        Write-host "No removable drive found that has a 'ports' folder, exiting ..." -ForegroundColor Red
        return
    }

    if ($removable.count -gt 1) {
        Write-host "Multiple drives were found. Please run the script using the -drive variable" -ForegroundColor Red
        Write-host "example : create_gamelist.ps1 -drive" -ForegroundColor Red
        return
    }
    Write-host "ROM SD card found on drive $removable"

    $Drive = $removable
}

# Testing Path
Write-host "Testing Path"
$Drive += "\"
if (!(test-path ($Drive + "ports\"))) {
    Write-host "The ports folder was not found on the SD card, exiting ..." -ForegroundColor Red
    return
}
if (!(test-path ($Drive + "tools\PortMaster\config"))) {
    Write-host "The ""tools\PortMaster\config"" folder was not found on the SD card. PortMaster needs to be installed. Exiting the script" -ForegroundColor Red
    return
}


$Games = dir ($Drive + "ports\*.sh")
if (!(test-path ($Drive + "ports\images"))) { $null = mkdir ($Drive + "ports\images") }


#### Building All Data
Write-host "Getting Data from PortMaster"
$pmmv  = (get-content ($Drive + "tools\PortMaster\config\021_portmaster.multiverse.source.json") | convertfrom-json -AsHashtable).data.info.values
$pm = (get-content ($Drive + "tools\PortMaster\config\020_portmaster.source.json") | convertfrom-json -AsHashtable).data.info.values

if (!$pm -or !$pmmv) {
    Write-host "The PortMaster data was not found. PortMaster needs to be installed. Exiting the script" -ForegroundColor Red
    return
}

# Adding the filename and the image
Write-host "Copying screenshots to the SD card"
$pm | % {
    $_ | add-member -TypeName NoteProperty -MemberType NoteProperty -Name filename -Value ($_.items | ? { $_ -match "\.sh" })
    $_ | add-member -TypeName NoteProperty -MemberType NoteProperty -Name screen -Value ("./images/" + $_.attr.image.screenshot)
    copy  ($Drive + "tools/PortMaster/config/images_pm/" + $_.attr.image.screenshot) ($Drive + "ports\images\")
}
$pmmv | % {
    $_ | add-member -TypeName NoteProperty -MemberType NoteProperty -Name filename -Value ($_.items | ? { $_ -match "\.sh" })
    $_ | add-member -TypeName NoteProperty -MemberType NoteProperty -Name screen -Value ("./images/" + $_.attr.image.screenshot)
    copy  ($Drive + "tools/PortMaster/config/images_pmmv/" + $_.attr.image.screenshot) ($Drive + "ports\images\")
}


# Converting to a hashtable
Write-host "Building gamelist.xml"
$Alldata = ($pm + $pmmv) | group -Property filename -AsHashTable

$Gamelist = foreach ($Game in $Games) {
    $filename = $game.name
    if ($AllData.ContainsKey($filename)) {
        write-host " > $filename found"
        "<game>
            <path>./$filename</path>
            <name>$($AllData[$filename].attr.title)</name>
            <desc>$($AllData[$filename].attr.desc)</desc>
            <developer>$($AllData[$filename].attr.porter -join ',')</developer>
            <genre>$($AllData[$filename].attr.genres -join ',')</genre>
            <image>$($AllData[$filename].screen)</image>
        </game>
        "
    } else {
        write-host " > $filename not found" -ForegroundColor Red
    }
}

$Gamelist = "
<?xml version=""1.0""?>
<gameList>" + $Gamelist + "</gameList>"

Write-host "deleting existing gamelist.xml on your SD card"
del ($Drive + "ports\images\*.*") -force | out-null

Write-host "Creating gamelist.xml on your SD card"
$Gamelist | out-file ($Drive + "ports\gamelist.xml")
