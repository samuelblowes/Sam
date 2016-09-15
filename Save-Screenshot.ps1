<#
.Synopsis
Take screenshot of active screens
.Description
Script to capture PNG screenshots of all active screens and saves to a custom location (defaults to local user's documents).
.Parameter simple
Takes a single, unified screenshot of all screens combined. Outputs one file.
.Parameter location
Sepcifies a custom location to save the screenshots. Once this location is set, a folder is created for the Computer Name, and then a subfolder for today's date. Screenshots are saved in this location.
.Example
Save-Screenshot.ps1
Saves individual screenshots of all screens to the default location.
.Example
Save-Screenshot.ps1 -simple
Saves a combined screenshot of all screens to a single image in the default location.
.Example
Save-Screenshot.ps1 - location c:\screenshots
Saves individual screenshots of all screens to the c:\screenshots.
#>
Param(
    [switch]$simple,
    [string]$location
)

#Set the save Location - Creates (if necessary) a folder at the base location named after the PC and then a subfolder for today's date
if(!($location)) {
    $baselocation = "$($ENV:HOMEPATH)\Documents"
} else {
    $baselocation = $location
}
$userlocation = "$($baselocation)\$($ENV:COMPUTERNAME)"
$todaylocation = "$($userlocation)\$(Get-Date -UFormat "%Y%m%d")"
if(!(Test-Path $userlocation)){
    New-Item $userlocation -type directory | Out-Null
    $todaylocation = "$($userlocation)\$(Get-Date -UFormat "%Y%m%d")"
    if(!(Test-Path $todaylocation)){
        New-Item $todaylocation -type directory | Out-Null
    }
}
$finallocation = $todaylocation

#Set up the C# call
[void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")            

#Function to take the screenshot and save it to the specified location
function screenshot([Drawing.Rectangle]$bounds, $path) {
    $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
    $graphics = [Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
    $bmp.Save($path)
    $graphics.Dispose()
    $bmp.Dispose()
}

#Create object with all screens
$Screens = [system.windows.forms.screen]::AllScreens            

#Check the "Simple" flag to take a unified screenshot of all screens combined
if($simple){
    foreach ($Screen in $Screens) {
        if ($Screen.Bounds.Left -lt $left) { $left = $Screen.Bounds.Left }
        if ($Screen.Bounds.Top -lt $top) { $top = $Screen.Bounds.Top }
        if ($Screen.Bounds.Right -gt $right) { $right = $Screen.Bounds.Right }
        if ($Screen.Bounds.Bottom -gt $bottom) { $bottom = $Screen.Bounds.Bottom }
    }            
    $DeviceName = "DISPLAY-ALL"
    $timestamp = (Get-Date -UFormat "%Y%m%d%H%M%S")
    $bounds = [Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
    screenshot $bounds "$($finallocation)\$($timestamp)-$($DeviceName).png"
} else {

#Or take individual screenshots of each screen
    foreach ($Screen in $Screens) {
        $DeviceName = ($Screen.DeviceName).trim("\\.\")
        $timestamp = (Get-Date -UFormat "%Y%m%d%H%M%S")
        $bounds = [Drawing.Rectangle]::FromLTRB($Screen.Bounds.Left, $Screen.Bounds.Top, $Screen.Bounds.Right, $Screen.Bounds.Bottom)
        screenshot $bounds "$($finallocation)\$($timestamp)-$($DeviceName).png"
    }            
}
