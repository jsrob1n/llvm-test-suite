set(POLYBENCH_UTILS SingleSource/Benchmarks/Polybench/utilities )
list(APPEND CFLAGS -I ${CMAKE_SOURCE_DIR}/${POLYBENCH_UTILS} -DPOLYBENCH_DUMP_ARRAYS)
if(SMALL_PROBLEM_SIZE)
  list(APPEND CFLAGS -DSMALL_DATASET)
endif()
set(HASH_PROGRAM_OUTPUT 1)
add_definitions(-DFP_ABSTOLERANCE=1e-5)
llvm_singlesource()