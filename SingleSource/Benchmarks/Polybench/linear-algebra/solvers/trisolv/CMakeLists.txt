set(POLYBENCH_UTILS SingleSource/Benchmarks/Polybench/utilities )
list(APPEND CFLAGS -I ${CMAKE_SOURCE_DIR}/${POLYBENCH_UTILS} -DPOLYBENCH_DUMP_ARRAYS)
set(HASH_PROGRAM_OUTPUT 1)
# Floating point contraction must be suppressed due to accuracy issues
list(APPEND CXXFLAGS -ffp-contract=off -DFMA_DISABLED=1)
list(APPEND CFLAGS -ffp-contract=off -DFMA_DISABLED=1)

add_definitions(-DFP_ABSTOLERANCE=1e-5)
llvm_singlesource()
