## create-project v1.0
####################################################################################################
## Author: George Mauer (gmauer@gmail.com)
## Updated by: S.ROKKANEN
## Licence: GNU General Public License v3
## Copyright 2009
####################################################################################################
## Used to create all the basic files necessary for starting a new project.  By running this script
## you will create a directory with all the files necessary to get going.
## 
## The application works by copying over all files in a templates directory to the new project
## directory while replacing tokens in the file content and file name.  Currently this script will set
## up a C# .NET project - it should be fairly trivial to add any other project however.
## Tokens are set in the $tokens hash (see below) and are replaced by the results of a script block.
####################################################################################################
## Version History
## 1.0 First Release
## 1.1 Adapatation
####################################################################################################
## Usage:
##   dotnet-create [ProjectName]
####################################################################################################
$templatespath = "C:\DotNetTemplate\X44\VisualStudio\SolutionTemplate\"
$defaultTemplateSolutionName = "Company.Template"
$syntax = "command project-name [template-name] [string-replace]"

$projectname = $args[0]
if(!$projectname) {
	echo "give project name target"
	echo $syntax
	exit
}

$template = $args[1]
if(!$template) {
	$template="RO2K.Template"
}
$templatespathOk=$templatespath+$template

if (!(Test-Path $templatespathOk))
{
	echo "Template : $template doesn't exist in $templatespath"
	dir $templatespath
	exit
}
$templatespath=$templatespath+$template

$replacename = $args[2]
if(!$replacename) {
	$replacename=$defaultTemplateSolutionName
}

# Tokens that will be replaced in file names and contents
$tokens = @{
  $replacename={$projectname};
  '#{GUID}'={ [Guid]::NewGuid().ToString().ToUpperInvariant() };
}

for ($i=0; $i -lt 10; $i++) {
  $tokens.Add("#{GUID[$i]}", {[Guid]::NewGuid().ToString().ToUpperInvariant()})
}
####################################################################################################

function Replace-Tokens { param($str, $token_dictionary)
	foreach($tkn in $token_dictionary.Keys) {
		$val = $token_dictionary.Get_Item($tkn)
		$calcVal = & $val
		$str = $str.Replace($tkn, $calcVal)
  }
	return $str
}

echo "Creation du projet $projectname"
$scriptpath = [System.IO.Path]::GetDirectoryName($myinvocation.mycommand.path)
echo "Chemin des template: $templatespath"

# Copy and rename directories
mkdir $projectname 
$directories =  dir $templatespath -recurse | where {$_.PsIsContainer} | %{$_.FullName} | sort
foreach($dirpath in $directories) { 
	$newdirpath = Replace-Tokens $dirpath @{$templatespath={$projectname}}
	$newdirpath = Replace-Tokens $newdirpath $tokens
	$exec = "cp '$dirpath' '$newdirpath'"
	echo "copie '$newdirpath'"
	iex $exec
}

# Copy and rename, and replace tokens in binary files
#$files =  dir $templatespath -recurse -include *.dll,*.exe,*.png,*.gif,*.ico,*.jpg,*.fm,*.nupkg,*.xlsx | where {!$_.PsIsContainer} | %{$_.FullName} | sort
#foreach($filepath in $files) { 
#	$newfilepath = Replace-Tokens $filepath @{$templatespath={$projectname}}
#	$newfilepath = Replace-Tokens $newfilepath $tokens
#	$exec = "cp '$filepath' '$newfilepath'"
#	echo "copie '$newfilepath'"
#	iex $exec
#}

# Copy, rename, and replace tokens in text files
$files =  dir $templatespath -recurse -exclude *.dll,*.exe,*.png,*.gif,*.ico,*.jpg,*.nupkg,*.xlsx | where {!$_.PsIsContainer} | %{$_.FullName} | sort
foreach($filepath in $files) { 

        $file = Get-Content $filepath
        if ($file.Length -gt 0)
        {
            $contents = [String]::join([Environment]::Newline, ($file))
	        $contents = Replace-Tokens $contents $tokens
	        $newfilepath = Replace-Tokens $filepath @{$templatespath={$projectname}}
	        $newfilepath = Replace-Tokens $newfilepath $tokens
	        echo "Remplacement $newfilepath"
	        if ($newfilepath.contains("DipMetaModel.xml") -or $newfilepath.contains(".htm"))
	        {
		        Set-Content $newfilepath $contents
	        }
	        else
	        {
		        Set-Content $newfilepath $contents -Encoding UTF8
	        }
        }
    }

start "$projectname\src\$projectname.sln"