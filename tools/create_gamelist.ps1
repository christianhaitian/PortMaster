# running this code will automatically update your gamelist
# Please change line '$Drive = "f:\"' to the correct path of your SD card on your computer
# and simply run the code in a powershell window
# This can run with any version of powershell

# Purposes : 
# - will fetch from the gameport json files
# - will copy all required screenshots to ports\images\
# - will create (erase existing) ports\gamelist.xml

# Requirements : you need to have installed PortMaster on your device/sd card

# Setting base directories
$Drive = "f:\"
$Games = dir ($Drive + "ports\*.sh")
if (!(test-path ($Drive + "ports\images"))) { $null = mkdir ($Drive + "ports\images") }
del ($Drive + "ports\images\*.*") -force | out-null

#### Building All Data
$pmmv  = (get-content ($Drive + "tools\PortMaster\config\021_portmaster.multiverse.source.json") | convertfrom-json -AsHashtable).data.info.values
$pm = (get-content ($Drive + "tools\PortMaster\config\020_portmaster.source.json") | convertfrom-json -AsHashtable).data.info.values

# Adding the filename and the image
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
$Alldata = ($pm + $pmmv) | group -Property filename -AsHashTable

$Gamelist = foreach ($Game in $Games) {
    $filename = $game.name
    if ($AllData.ContainsKey($filename)) {
        write-host $filename  found -ForegroundColor Green
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
        write-host $filename  not found -ForegroundColor Red
    }
}

$Gamelist = "
<?xml version=""1.0""?>
<gameList>" + $Gamelist + "</gameList>"

$Gamelist | out-file ($Drive + "ports\gamelist.xml")
