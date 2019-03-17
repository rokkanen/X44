$solutionName="X44"
$rootTemplate="c:\DotNetTemplate"
$repository="https://github.com/rokkanen/$solutionName"
$shortcut1=$rootTemplate + "\X44\bin\CreateApplication.hta"
$shortcut2=$rootTemplate + "\X44\bin\CreateTemplate.hta"

function installProgram(){
   mkdir -Force $rootTemplate
   cd $rootTemplate
   git clone $repository
   rmdir -Force -Recurse $solutionName\.git
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
createShorcut $shortcut1 "$Home\Desktop\X44 CreateApplication.lnk"
createShorcut $shortcut2 "$Home\Desktop\X44 CreateTemplate.lnk"
