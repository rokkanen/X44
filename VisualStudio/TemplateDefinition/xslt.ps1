$xml = $args[0]
$xsl = $args[1]
$out = $args[2]

function generateCmd([string]$xml, [string]$xsl, [string]$out)
{
	$xslt = New-Object System.Xml.Xsl.XslCompiledTransform;
	$xslt.load($xsl)
	$xslt.Transform($xml, $out)
}

generateCmd $xml $xsl $out