# SingleSource/Polybench/linear-algebra
# Makefile:  Build all subdirectories automatically

LEVEL = ../../../../..
PARALLEL_DIRS = cholesky durbin gramschmidt lu ludcmp trisolv

# LLVM: We removed the benchmark ludcmp. This change ensures we do not
# calculate nan values, which are formatted differently on different platforms
# and which may also be optimized unexpectedly.

include $(LEVEL)/Makefile.config
include $(LEVEL)/Makefile.programs

