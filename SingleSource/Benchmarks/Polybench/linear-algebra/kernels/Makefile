# SingleSource/Polybench/linear-algebra
# Makefile:  Build all subdirectories automatically

LEVEL = ../../../../..
PARALLEL_DIRS = 2mm 3mm atax bicg doitgen mvt

ifdef BENCHMARKING_ONLY
PARALLEL_DIRS := $(filter-out 2mm, $(PARALLEL_DIRS))
PARALLEL_DIRS := $(filter-out 3mm, $(PARALLEL_DIRS))
endif

include $(LEVEL)/Makefile.config
include $(LEVEL)/Makefile.programs

