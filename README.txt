LLVM "test-suite" Repository
----------------------------

Please see the LLVM testing infrastructure guide:

  https://llvm.org/docs/TestSuiteGuide.html

for more information on the contents of this repository.

This repo has had the directory "MultiSource/Applications/ClamAV" excised via the command:
* git filter-repo --path MultiSource/Applications/ClamAV/ --invert-paths

In detail:

* git clone https://github.com/jsrob1n/llvm-test-suite.git
* cd llvm-test-suite
* git fetch --all
* git remote prune
* git filter-repo --path MultiSource/Applications/ClamAV/ --invert-paths
