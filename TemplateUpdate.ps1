<#
.SYNOPSIS
    Makes updates to the MAQS project templates.
.DESCRIPTION
    This powershell script is used to update the MAQS project templates. It updates the specified references in the unzipped templates. Editing of parameters in the powershell file will be necessary to set the desired packages and related versions to update.
.PARAMETER maqsVer
    The desired version of MAQS to set.
.PARAMETER closedSource
    Set true if the closeSource version of MAQS should be updated
.PARAMETER openSource
    Set true if the openSource version of MAQS should be updated
.PARAMETER openSource
    Set true if the openSource version of MAQS should be updated
.NOTES
  Version:        1.0
  Author:         Magenic
  Creation Date:  05/16/2017
  Purpose/Change: Initial script development. 

  Version:        2.0
  Author:         Magenic
  Creation Date:  07/5/2018
  Purpose/Change: Add SpecFlow extension support 

  Version:        3.0
  Author:         Magenic
  Creation Date:  08/23/2018
  Purpose/Change: Add .NET core template support 
  
.EXAMPLE
  ./TemplateUpdates

  This command will update the open or closed source version of MAQs to the hardcoded MAQS version, depending on which flags are hardcoded to default to true.
.EXAMPLE
  ./TemplateUpdates -maqsVer 4.0.0

  This command will update the open or closed source version of MAQs to MAQS version 4.0.0, depending on which flags are hardcoded to default to true.
.EXAMPLE
  ./TemplateUpdates -maqsVer "4.0.0" -closedSource $true -openSource $false -specFlowSource $false

  This command will update references in all files in the specified codeLocation to the specified maqs version and zip the templates.
#>

param (
    # MAQS CURRENT VERSION
    [string]$maqsVer = "5.1.1",
    [bool]$closedSource = $true,
    [bool]$openSource = $true,
    [bool]$specFlowSource = $true
)

# to avoid updating a value, set its value to ""

# Which package references need to be updated and the corresponding versions
$packageList = "Magenic.Maqs", "Magenic.Maqs.NunitOnly", "Magenic.Open.Maqs", "Magenic.Open.Maqs.NunitOnly", "Newtonsoft.Json", "Selenium.WebDriver", "Selenium.Support", "Castle.Core", "MailKit", "MimeKit",  "NUnit",  "NUnit3TestAdapter", "Selenium.WebDriver.ChromeDriver", "Selenium.WebDriver.GeckoDriver", "Selenium.WebDriver.GeckoDriver.Win32", "Selenium.WebDriver.IEDriver", "Selenium.WebDriver.MicrosoftDriver", "Appium.WebDriver",  "MSTest.TestAdapter", "MSTest.TestFramework"
$versionList = $maqsVer,        $maqsVer,                 $maqsVer,            $maqsVer,                     "11.0.2",          "3.14.0",              "3.14.0",          "4.3.1",       "2.0.4",   "2.0.4",    "3.10.1", "3.10.0",            "2.42.0.1",                        "0.22.0",                         "0.22.0",                               "3.14.0",                      "17.17134.0",                         "4.0.0.3-beta",      "1.3.2",              "1.3.2"

# Which assembly file values need to be updated and the corresponding versions (THIS UPDATES ALL ASSEMBLYINFO.CS FILES IN THE REPO, AND SOME SHOULD BE MANUALLY REVERTED)
$assemblyList = "AssemblyVersion", "AssemblyFileVersion"
$assemblyVer = $maqsVer, $maqsVer

# Which nuspec file values need to be updated and the corresponding versions
$nuspecIds = "Magenic.Maqs", "Magenic.Maqs.NunitOnly", "Magenic.Open.Maqs", "Magenic.Open.Maqs.NunitOnly", "Magenic.Maqs.Templates", "Magenic.Maqs.SpecFlow"
$nuspecVer = $maqsVer, $maqsVer, $maqsVer, $maqsVer, $maqsVer, $maqsVer

# Desired nuget.config intranet repository value
#$nugetRepo = "https://magenic.pkgs.visualstudio.com/_packaging/MAQS/nuget/v3/index.json"
$nugetRepo = ""

# Desired HelpFile version
$helpFileVer = $maqsVer

# Desired VSIXManifest version
$vsixManVer = $maqsVer

###################################################################################################################
function UpdateLine($fileText, $regexType, $searchValue, $replaceValue){
    if($regexType -eq "ProjReferences") { $regexPattern = "(<HintPath>..\\..\\packages\\" + $searchValue + ".)([\d\.]*)(\\.*</HintPath>)" }
    if($regexType -eq "PackageReferences") { $regexPattern = "(<package id=""" + $searchValue + """ version="")([\d\.]*)("" targetFramework=""[\w]+"" />)" }
    if($regexType -eq "AssemblyReferences") { $regexPattern = "(\[assembly: " + $searchValue + "\("")([\d\.]*)(""\)\])" }
    if($regexType -eq "NuspecVersion"){ $regexPattern = "(<id>" + $searchValue + "</id>[\r\n\s]*<version>)([\d\.]*)(</version>)" }
    if($regexType -eq "HelpDocument") { $regexPattern = "(<HelpFileVersion>)([\d\.]*)(</HelpFileVersion>)" }
    if($regexType -eq "VsixManifest") { $regexPattern = "(<Identity Id=""[A-Za-z0-9 -]*"" Version="")([\d\.]*)("" Language=""en-US"" Publisher=""Magenic"" />)" }
    if($regexType -eq "NugetRepository") { $regexPattern = "(<add key=""intranet repository"" value="")([A-Za-z0-9 \\\.:/_-]*)("" />)" }
    if($regexType -eq "DocumentationSource") {$regexPattern = "(<DocumentationSource sourceFile=""..\\packages\\" + $searchValue + ".)([\d\.]*)(\\lib\\[\w]+\\[\w\.]+"" />)" }
    if($regexType -eq "PackageReferenceOpen") {$regexPattern = "(<PackageReference Include=""" + $searchValue + """ version="")([\d\.]*)("" />)" }
    if($regexType -eq "ProjVersion_") {$regexPattern = "(<Version>)([\d\.]*)(</Version>)" }
    if($regexType -eq "ProjVersion_File") {$regexPattern = "(<FileVersion>)([\d\.]*)(</FileVersion>)" }
    if($regexType -eq "ProjVersion_Assembly") {$regexPattern = "(<AssemblyVersion>)([\d\.]*)(</AssemblyVersion>)" }

    if($regexPattern){
        $replaceValue = "`${1}" + $replaceValue + "`${3}"
        $filetext = $filetext -replace $regexPattern, $replaceValue
    }
    return $filetext
}

function UpdateFileContent($file, $regexType, $matchValueList, $replaceValueList){
    $filetext =  [System.IO.File]::ReadAllText($file)
    if($matchValueList -is [system.array]){
        for($i=0; $i -lt $matchValueList.Length; $i++){
            if(![string]::IsNullOrEmpty($replaceValueList[$i])){
                $filetext = UpdateLine $filetext $regexType $matchValueList[$i] $replaceValueList[$i]
            }
        }
    }
    if(($matchValueList -isnot [system.array]) -and (![string]::IsNullOrEmpty($nugetRepo) -or $regexType -eq "VsixManifest" -or $regexType -like "ProjVersion_*")){
        $filetext = UpdateLine $filetext $regexType $matchValueList $replaceValueList
    }

    [System.IO.File]::WriteAllText($file, $filetext, [System.Text.Encoding]::UTF8)
}

function UpdateFiles($directory, $fileFilter, $regexType, $matchValueList, $replaceValueList){
    Get-ChildItem $directory -Filter $fileFilter -Recurse |
    ForEach-Object{
        Write-Host "Updating " $_.FullName
        UpdateFileContent $_.FullName $regexType $matchValueList $replaceValueList
    }
}

# Comment out what doesn't need to be updated
function WorkFlowFunction($closedSource, $openSource){
    if($closedSource){
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtension" "*.csproj" "ProjReferences" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtension" "packages.config" "PackageReferences" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtension" "source.extension.vsixmanifest" "VsixManifest" "NotNeeded" $vsixManVer
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtension" "nuget.config" "NugetRepository" "NotNeeded" $nugetRepo
        # .NET Core templates
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtension" "*.csproj" "PackageReferenceOpen" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\CoreTemplates" "*.csproj" "PackageReferenceOpen" $packageList $versionList
    }
    if($openSource){
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtensionOss" "*.csproj" "ProjReferences" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtensionOss" "packages.config" "PackageReferences" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtensionOss" "source.extension.vsixmanifest" "VsixManifest" "NotNeeded" $vsixManVer
        UpdateFiles $PSScriptRoot"\Extensions\VisualStudioQatExtensionOss" "nuget.config" "NugetRepository" "NotNeeded" $nugetRepo
    }
    if($specFlowSource){
        UpdateFiles $PSScriptRoot"\Extensions\MaqsSpecFlowExtension" "*.csproj" "ProjReferences" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\MaqsSpecFlowExtension" "packages.config" "PackageReferences" $packageList $versionList
        UpdateFiles $PSScriptRoot"\Extensions\MaqsSpecFlowExtension" "source.extension.vsixmanifest" "VsixManifest" "NotNeeded" $vsixManVer
        UpdateFiles $PSScriptRoot"\Extensions\MaqsSpecFlowExtension" "nuget.config" "NugetRepository" "NotNeeded" $nugetRepo
    }
    UpdateFiles $PSScriptRoot"\Framework" "AssemblyInfo.cs" "AssemblyReferences" $assemblyList $assemblyVer
    UpdateFiles $PSScriptRoot"\Framework" "*.nuspec" "NuspecVersion" $nuspecIds $nuspecVer
    UpdateFiles $PSScriptRoot"\Framework" "*.shfbproj" "HelpDocument" "NotNeeded" $helpFileVer
    UpdateFiles $PSScriptRoot"\Framework" "*.shfbproj" "DocumentationSource" $packageList $versionList
    UpdateFiles $PSScriptRoot"\Framework" "*.csproj" "ProjVersion_" "NotNeeded" $maqsVer
    UpdateFiles $PSScriptRoot"\Framework" "*.csproj" "ProjVersion_File" "NotNeeded" $maqsVer
    UpdateFiles $PSScriptRoot"\Framework" "*.csproj" "ProjVersion_Assembly" "NotNeeded" $maqsVer
    # .NET Core templates
    UpdateFiles $PSScriptRoot"\Extensions\CoreTemplates" "*.nuspec" "NuspecVersion" $nuspecIds $nuspecVer
}

WorkFlowFunction $closedSource $openSource