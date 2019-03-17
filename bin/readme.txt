=====================================================================================

X44 Software Factory

=====================================================================================

Install process:
- copy files with organisation above
- Execute powershell
- Activate script execution: Set-Executionpolicy RemoteSigned (launch powershell console in admin mode)
- Execute install-alias.ps1 for create powershell alias which invokated from HTA programs

Usage, execute: 

1-Create a template first (see TemplateDefinition), create a XML definition like AspNetCoreAPI.xml
2-Instanciate template by executing CreateTemplate.hta
3-Instanciate an application by executing CreatApplication.hta

Distribution
------------

C:\DotNetTemplate
	|_____X44
		|_____bin
		|	- CreatApplication.hta
		|	- CreatTemplate.hta
		|	- dotnet-create.ps1
		|	- install-alias.ps1
		|	- Readme.txt (this file)
		|_____VisualStudio
			|_____SolutionTemplate
			|	-(empty by default)
			|_____TemplateDefinition	
				-some .xml template definition files
				-CreateDotNetCommand.xsl (transform xml to command line batch)
				-init.cmd (launch xslt)
				-xslt.ps1	
				|_____files-packages (files added after template creation process)
		
				







