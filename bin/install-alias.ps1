#Set-Executionpolicy RemoteSigned

if (!(Test-Path $profile))
{
  New-Item -path $profile -type file -force
  echo '# Alias configuration'>>$profile
  echo 'Set-Alias dotnet-create "C:\DotNetTemplate\X44\bin\dotnet-create.ps1"'>>$profile
}
else
{
	echo "Profile has not been updated, it already exists,"
	echo "Add alias by hand."
}
