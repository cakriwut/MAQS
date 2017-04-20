# Builds
1. [Pull request](https://magenic.visualstudio.com/MaqsFramework/_build/index?context=Mine&path=%5C&definitionId=51&_a=completed) build  
 * Run with every pull request - failure will prevent code from being checked in
2. [Nuget And Extension](https://magenic.visualstudio.com/MaqsFramework/_build/index?context=Mine&path=%5C&definitionId=54&_a=completed) build  
 * Run on demand - Creates  a build version specific package and extension for internal testing purposes (Full version)
3. [Open Nuget And Extension](https://magenic.visualstudio.com/MaqsFramework/_build/index?context=Mine&path=%5C&definitionId=55&_a=completed) build  
 * Run on demand - Creates a build version specific package and extension for internal testing purposes (Open source version)
4. [Nuget And Extension - Internal Release](https://magenic.visualstudio.com/MaqsFramework/_build/index?context=Mine&path=%5C&definitionId=56&_a=completed) build  
 * Run on demand - Creates a release build version (Open source and full version) 