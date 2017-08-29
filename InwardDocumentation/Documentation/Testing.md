# Testing
## CI
Each time we try to  merge into development a build is automatically kicked off.
If the solution fails to build or any of the tests fail we block the merge.
## Release
Before each release we manually run the [MAQS test suite](https://magenic.visualstudio.com/MaqsFramework/_testManagement?planId=2159&suiteId=2160&_a=tests)