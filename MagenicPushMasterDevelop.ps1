
function Auto-Push-Magenic{

	param (
        [parameter(Mandatory = $true)] [string] $sourceRepo,
        [parameter(Mandatory = $true)] [string] $destinationRepo,
		[parameter(Mandatory = $true)] [string] $branch
    )
	
	Try
    {
		#Setup folders
		cd $env:userprofile\documents
		
		if (Test-Path $env:userprofile\documents\MagenicOpenAutoPushVxyz)
		{
			Remove-Item $env:userprofile\documents\MagenicOpenAutoPushVxyz -Recurse -Force
		}
		
		New-Item -Path $env:userprofile\documents -Name "MagenicOpenAutoPushVxyz" -ItemType "directory" -Force
		cd $env:userprofile\documents\MagenicOpenAutoPushVxyz
		
		# Clone the origin
		git clone $sourceRepo -b $branch
		
		cd MAQS
		
		echo ""
		echo ""
		echo "Starting Filter-Branch Index Filter"
		
		#Filter and remove all files not included in the grep list
		git filter-branch --prune-empty --index-filter 'git ls-tree -z -r --name-only --full-tree $GIT_COMMIT | grep --null-data --invert-match "^README.md$" | grep --null-data --invert-match "^LICENSE$" | grep --null-data --invert-match "^Settings.StyleCop$" | grep --null-data --invert-match "^OutwardDocumentation/Documentation" | grep --null-data --invert-match "^Framework/OpenMaqsBase.sln$" | grep --null-data --invert-match "^Framework/Parallel.testsettings$" | grep --null-data --invert-match "^Framework/VSUnitTestShim" | grep --null-data --invert-match "^Framework/UtilitiesUnitTests" | grep --null-data --invert-match "^Framework/Utilities" | grep --null-data --invert-match "^Framework/SeleniumUnitTesting" | grep --null-data --invert-match "^Framework/OpenDocumentation" | grep --null-data --invert-match "^Framework/NugetSetup" | grep --null-data --invert-match "^Framework/BaseTest" | grep --null-data --invert-match "^Framework/BaseTestUnitTests" | grep --null-data --invert-match "^Framework/BaseSeleniumTest" | xargs --null --no-run-if-empty git rm --cached -q -r' --  --all
		
		echo "Done With Index Filter"
		echo ""
		echo ""
		echo "Starting Filter-Branch Commit Filter"
		
		# prune empty merges
		git filter-branch --commit-filter '
		isMerge=false
		for sha in $(git rev-list --min-parents=2 --all) 
		do
			if [ $isMerge = false ]
			then
				if [ $GIT_COMMIT = ${sha} ] && [ $(git rev-parse ${sha}^{tree}) == $(git rev-parse ${sha}^1^{tree} ) ]
				then
					isMerge=true
				fi
			fi
		done;
		if [ $isMerge = true ]
		then
			skip_commit "$@";	
		else
			git_commit_non_empty_tree "$@"
		fi' --force --  --all
		
		echo "Done With Commit Filter"
		echo ""
		echo ""
		echo "Clean Up and Repackage"
		
		#remove refs and repackage, check if needed
		Remove-Item .git\refs\original  -Force -Recurse
		Remove-Item .git\logs\  -Force -Recurse
		git gc
		
		echo "Done With Clean Up and Repackage"
		echo ""
		echo ""
		echo "Push to new Repo"
		
		#Set the git url to the url you want to push to
		git remote set-url origin $destinationRepo
		
		git push -f origin $branch
		
		cd ..		
		Remove-Item .\MAQS -Force -Recurse
		
		cd $env:userprofile\documents
		Remove-Item $env:userprofile\documents\MagenicOpenAutoPushVxyz -Recurse -Force
		
		echo "Done Done, Bye"
    }
    Catch {
		return $_.Exception.Message
    }
	Finally
	{
	}
}

Auto-Push-Magenic "https://magenic.visualstudio.com/DefaultCollection/MaqsFramework/_git/MAQS" "https://github.com/Magenic/MAQS.git" "master"
Auto-Push-Magenic "https://magenic.visualstudio.com/DefaultCollection/MaqsFramework/_git/MAQS" "https://github.com/Magenic/MAQS.git" "develop"


