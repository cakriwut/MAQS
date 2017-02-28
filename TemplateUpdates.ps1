<#
.SYNOPSIS
  Makes updates to the MAQS project templates.
.DESCRIPTION
  This powershell script is used to update the MAQS project templates. It can unzip, update specified references, or rezip the templates. Editing of parameters in the powershell file will likely be necessary.
.PARAMETER codeLocation
    The location of the MAQS project folder.
.PARAMETER maqsVer
    The desired version of MAQS to set.
.PARAMETER unzip
    Set true if the templates should be unzipped.
.PARAMETER update
    Set true if the templates should be updated.
.PARAMETER zip
    Set true if the templates should be zipped.
.PARAMETER openSource
    Set true if the openSource version of MAQS should be updated
.PARAMETER closedSource
    Set false if the closeSource version of MAQS shouldn't be updated
.NOTES
  Version:        1.0
  Author:         Cole Gillum
  Creation Date:  02/23/2017
  Purpose/Change: Initial script development. 
  
.EXAMPLE
  ./TemplateUpdates

  This command will unzip, update, or zip to the default codeLocation of the closed source version of MAQs, depending on which flags are hardcoded to default to true.
.EXAMPLE
  ./TemplateUpdates -unzip $true -update $true -zip $true

  This command will unzip, update, and zip to the default codeLocation of the closed source version of MAQs.
.EXAMPLE
  ./TemplateUpdates -codeLocation "C:\Users\exampleUser\Source\Repos\MAQS" -maqsVer "4.0.0" -update $true -zip $true -openSource $true

  This command will update references in all files in the specified codeLocation to the specified maqs version and zip the templates.
#>

param (
    # MAQS CODE LOCATION & CURRENT VERSION
    [string]$codeLocation = "C:\Users\coleg\Source\Repos\MAQS",
    [string]$maqsVer = "4.0.0",
    [bool]$unzip = $false,
    [bool]$update = $false,
    [bool]$zip = $false,
    [bool]$openSource = $false,
    [bool]$closedSource = $true
)

# Which package references need to be updated and the corresponding versions
$packageList = "Magenic.MaqsFramework", "Magenic.MaqsFramework.NunitOnly", "Newtonsoft.Json"
$versionList = $maqsVer, $maqsVer, "9.0.1"

# Which assembly file values need to be updated and the corresponding versions (THIS UPDATES ALL ASSEMBLYINFO.CS FILES IN THE REPO, AND SOME SHOULD BE MANUALLY REVERTED)
$assemblyList = "AssemblyVersion", "AssemblyFileVersion"
$assemblyVer = $maqsVer, $maqsVer

# Which nuspec file values need to be updated and the corresponding versions
$nuspecIds = "Magenic.MaqsFramework", "Magenic.MaqsFramework.NunitOnly", "Magenic.Open.Maqs.NunitOnly", "Magenic.Open.Maqs"
$nuspecVer = $maqsVer, $maqsVer, $maqsVer, $maqsVer

# Desired nuget.config intranet repository value
$nugetRepo = "https://magenic.pkgs.visualstudio.com/_packaging/MAQS/nuget/v3/index.json"

# Desired HelpFile version
$helpFileVer = $maqsVer

# Desired VSIXManifest version
$vsixManVer = $maqsVer

###################################################################################################################

function UnpackAllZips($directory, $destination){
    Set-Location $directory
    $relativePath = Get-ChildItem $directory -Filter *.zip -Recurse | Resolve-Path -Relative
    ForEach($filePath in $relativePath){
        $filePath = $filePath.TrimStart(".", " ", "\")
        $unzippedFile = $filePath.Substring(0, $filePath.LastIndexOf('.'))
        $fullDestination = $destination + "\" + $unzippedFile
        $fullStartDirectory = $directory + "\" + $filePath

        Write-Host "Unzipping " $fullStartDirectory
        New-Item -path $fullDestination -type directory -force
        Unzipper -file $fullStartDirectory -destination $fullDestination
    }
}

function UnZipper($file, $destination){
	$shell = new-object -c shell.application
	$zip = $shell.Namespace($file)
	foreach($item in $zip.items()){
		$shell.Namespace($destination).copyhere($item, 0x14)
	}
}

function UpdateLine($fileText, $regexType, $searchValue, $replaceValue){
    if($regexType -eq "ProjReferences") { $regexPattern = "(<HintPath>..\\..\\packages\\" + $searchValue + ".)([\d\.]*)(\\.*</HintPath>)" }
    if($regexType -eq "PackageReferences") { $regexPattern = "(<package id=""" + $searchValue + """ version="")([\d\.]*)("" targetFramework=""net45"" />)" }
    if($regexType -eq "AssemblyReferences") { $regexPattern = "(\[assembly: " + $searchValue + "\("")([\d\.]*)(""\)\])" }
    if($regexType -eq "NuspecVersion"){ $regexPattern = "(<id>" + $searchValue + "</id>[\r\n\s]*<version>)([\d\.]*)(</version>)" }
    if($regexType -eq "HelpDocument") { $regexPattern = "(<HelpFileVersion>)([\d\.]*)(</HelpFileVersion>)" }
    if($regexType -eq "VsixManifest") { $regexPattern = "(<Identity Id=""[A-Za-z0-9 -]*"" Version="")([\d\.]*)("" Language=""en-US"" Publisher=""Magenic"" />)" }
    if($regexType -eq "NugetRepository") { $regexPattern = "(<add key=""intranet repository"" value="")([A-Za-z0-9 \\\.:/_-]*)("" />)" }

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
            $filetext = UpdateLine $filetext $regexType $matchValueList[$i] $replaceValueList[$i]
        }
    }
    if($matchValueList -isnot [system.array]){
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

function ZipFiles($inputDirectory, $outputDirectory){
    $nunitDir1 = $inputDirectory + "\NUnit"
    $nunitDir2 = $inputDirectory + "\NUnit Only"

    Set-Location $inputDirectory
    $relativePath = Get-ChildItem $inputDirectory -Directory | Resolve-Path -Relative
    ForEach($file in $relativePath){
        $file = $file.TrimStart(".", " ", "\")
        $input = $inputDirectory + "\" + $file
        $inputDir = $input + "\*"
        $destination = $outputDirectory + "\" + $file + ".zip"

        if(($input -ne $nunitDir1) -and ($input -ne $nunitDir2) -and ($input -ne $outputDirectory)){
            Write-Host "Zipping " $input
            Compress-Archive -Path $inputDir -DestinationPath $destination -Force
        }
    }
}

###################################################################################################################

function WorkFlowFunction($doUnZip, $doUpdate, $doZip){
    if($doUnZip){
        if($closedSource){
            UnpackAllZips $codeLocation"\Extensions\VisualStudioQatExtension\ProjectTemplates\Magenic Test" $codeLocation"\Extensions\VisualStudioQatExtension\ProjectTemplates\Magenic Test"
        }
        if($openSource){
            UnpackAllZips $codeLocation"\Extensions\VisualStudioQatExtensionOss\ProjectTemplates\Magenic's Open Test" $codeLocation"\Extensions\VisualStudioQatExtensionOss\ProjectTemplates\Magenic's Open Test"
        }
    }

    # Comment out what doesn't need to be updated
    if($doUpdate){
        if($closedSource){
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtension" "*.csproj" "ProjReferences" $packageList $versionList
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtension" "packages.config" "PackageReferences" $packageList $versionList
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtension" "source.extension.vsixmanifest" "VsixManifest" "NotNeeded" $vsixManVer
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtension" "nuget.config" "NugetRepository" "NotNeeded" $nugetRepo
        }
        if($openSource){
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtensionOss" "*.csproj" "ProjReferences" $packageList $versionList
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtensionOss" "packages.config" "PackageReferences" $packageList $versionList
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtensionOss" "source.extension.vsixmanifest" "VsixManifest" "NotNeeded" $vsixManVer
            UpdateFiles $codeLocation"\Extensions\VisualStudioQatExtensionOss" "nuget.config" "NugetRepository" "NotNeeded" $nugetRepo
        }
        if($closedSource -or $openSource){
            UpdateFiles $codeLocation"\Framework" "AssemblyInfo.cs" "AssemblyReferences" $assemblyList $assemblyVer
            UpdateFiles $codeLocation"\Framework" "*.nuspec" "NuspecVersion" $nuspecIds $nuspecVer
            UpdateFiles $codeLocation"\Framework" "*.shfbproj" "HelpDocument" "NotNeeded" $helpFileVer
        }
    }

    if($doZip){
        if($closedSource){
            ZipFiles $codeLocation"\Extensions\VisualStudioQatExtension\ProjectTemplates\Magenic Test" $codeLocation"\Extensions\VisualStudioQatExtension\ProjectTemplates\Magenic Test"
            ZipFiles $codeLocation"\Extensions\VisualStudioQatExtension\ProjectTemplates\Magenic Test\NUnit" $codeLocation"\Extensions\VisualStudioQatExtension\ProjectTemplates\Magenic Test\Nunit"
        }
        if($openSource){
            ZipFiles $codeLocation"\Extensions\VisualStudioQatExtensionOss\ProjectTemplates\Magenic's Open Test" $codeLocation"\Extensions\VisualStudioQatExtensionOss\ProjectTemplates\Magenic's Open Test"
            ZipFiles $codeLocation"\Extensions\VisualStudioQatExtensionOss\ProjectTemplates\Magenic's Open Test\NUnit Only" $codeLocation"\Extensions\VisualStudioQatExtensionOss\ProjectTemplates\Magenic's Open Test\NUnit Only"
        }
    }
}

# set whatever needs to be done to $true in params
WorkFlowFunction $unzip $update $zip