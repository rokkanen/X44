
function updateDocumentationFile([xml]$xml, [string]$documentationFile)
{
	$pr = $xml.CreateElement("PropertyGroup")
	$pr.SetAttribute("Condition", "'`$(Configuration)|`$(Platform)'=='Debug|AnyCPU'")
	$doc = $xml.CreateElement("DocumentationFile")
	$doc.innerText = documentationFile
	$pr.AppendChild($doc)
	$xml.Project.AppendChild($pr)
}


$file = (Get-Location).Path + "\Company.Template.Api.csproj"
$xml  = [xml](Get-Content $file)
updateDocumentationFile $xml "Company.Template.Api.xml"
$xml.Save($file)


