# Installation
Copy and paste the command below in command shell window and run it:
```
powershell -command "mkdir c:\DotNetTemplate;$webClient = New-Object –TypeName System.Net.WebClient; $webClient.DownloadFile('https://raw.githubusercontent.com/rokkanen/X44/master/boostrap-install.ps1','c:\DotNetTemplate\boostrap-install.ps1'); c:\DotNetTemplate\boostrap-install.ps1 master"
``` 
**
# THIS PROJECT IS DEPRECATED
I'm rewriting code generation  toolchain for .NET/JS or whatever with more open/simple/powerfull tools based on nodeJS stack:
- Model description with YAML (parsing with [js-yaml](https://www.npmjs.com/package/js-yaml))
- Templating with [handlebars](https://handlebarsjs.com/)
- Scaffolding with [Hygen](http://www.hygen.io/)
** 
# What is X44 ?
X44 is an acronym (of acronyms!) for XSLT (eXtensible Stylesheet Language Transformation)  for T4 (Text Template Transformation Toolkit).
X44 extends the code generation functionality of the T4 text templates in Visual Studio 201x by providing the ability to use XML and XSL transformation for text template transformation, with T4 acting as a hosting system for XSL Transformations (XSLT).

It allows you to: 

* Implement a pragmatic, simple and concrete approach of MDA (Model Driven Architecture) in unobtrusive way 
* Use the provided XSL templates and predefined XML Models to produce code for:
  * POCO classes (Plain Old C# Object) 
  * Entity Framework Code First: DbContexts & Mapping classes
  * Data Access Components based on Dapper and a CQS pattern (Command Query Segregation)
  * WebApi
- Describe your own Models in XML Format and your own XSL Templates and transform it to code via XSL Transformation templates and T4
- Use Entity Framework 6.x to design Entities Model to produce “Code First” Entity framework code: DbContexts, Mappings, and Entities.
- Upgrade Entity Framework Designer 6.x to be compatible for .NET Core!
- Generate a simple XML Entity Model file from an .EDMX (ADO.NET Entity Data Model) file for simple and easy XSL parsing
- Generate multiple output files from a single XSL template and  XML source 
- Automatically add output files to one or more projects and folders
- Reduce the dependency to T4 system, beacuse XSL Transformation is platform independent, you can design your XSL template where you want and run it in any context (internet browser for example)
- Avoid learning and mastering T4, just XML/XSLT.
- Launch sequentially a set of transformation on a set of models
- Custom the workflow generation by selecting Elements of model which must be generated or not with XPATH queries
- support [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) templates (unique centralized files) unlike the standard .tt entity framework files !

# Why X44 ?

X44 is a lightweight Software factory with the purpose to accelerate design and implementation of .NET application solutions or whatever. Microsoft has already published solutions in this field with DSL Tools and Visual Studio LightSwitch, but their adoption has remained very limited. Maybe some of these tools like DSL are too complex to implement and require lot of skills, or too simple for developers, like Lightswitch, having been dropped by Microsoft.
Nonetheless, Microsoft have been providing since Visual Studio 2005 the T4 technology that is used to generate code from ADO.NET Entity Data Models and in ASP.NET MVC projects for scaffolding Views and Controllers. 
There is lot of interesting article about this technology:

[T4 (Text Template Transformation Toolkit) Code Generation - Best Kept Visual Studio Secret](https://www.hanselman.com/blog/T4TextTemplateTransformationToolkitCodeGenerationBestKeptVisualStudioSecret.aspx)

When you want use T4 in an intensive and advanced way, for example produce multiple files in different solution folders or projects, you must use additional tool like T4Toolbox addin or if you not want install addin the [T4.Helper utility](https://github.com/renegadexx/T4.Helper). With this set of utilities T4 become a powerful tool.  
Nonetheless, if you want build a software factory with many T4 Template files (.tt) in order to generate code and solution artefacts, development and updating tasks can be difficult, time consuming and finally represent a great challenge.
This is due to the nature of the technology: T4 is a program that write program. It can considering as [Metaprogramming](https://en.wikipedia.org/wiki/Metaprogramming) 
The typical implementation typology of T4 template is a C# program that loops on data comes from a Model or a Configuration file and Write an output code.  The code generation algorithm mixes the code for reading input data with the output code to produce as illustrated bellow:

![T4 sample](./doc/t4sample.png?raw=true "T4 sample")

This approach represents a real problem because
[SOC principle](https://en.wikipedia.org/wiki/Separation_of_concerns) is not respected.
 
XML(Model)/XSL(Transformation) represent a solution to this problem. 

# TODO

* Complete Documentation


