$solutionName="X44"
$rootTemplate="c:\DotNetTemplate"
$repository="https://github.com/rokkanen/X44"
$shortcut1=$rootTemplate + "\X44\bin\CreateApplication.hta"
$shortcut2=$rootTemplate + "\X44\bin\CreateTemplate.hta"
$DesktopPath = [Environment]::GetFolderPath("Desktop")

function installProgram(){
   mkdir -Force $rootTemplate
   cd $rootTemplate
   git clone $repository -b master
   rmdir -Force -Recurse .\X44\.git
   .\X44\bin\install-alias.ps1
} 
 
function createShorcut(){
   param ( [string]$SourceExe, [string]$DestinationPath )
   $WshShell = New-Object -comObject WScript.Shell
   $Shortcut = $WshShell.CreateShortcut($DestinationPath)
   $Shortcut.TargetPath = $SourceExe
   $Shortcut.Save()
}

installProgram
createShorcut $shortcut1 "$DesktopPath\X44 CreateApplication.lnk"
createShorcut $shortcut2 "$DesktopPath\X44 CreateTemplate.lnk"
