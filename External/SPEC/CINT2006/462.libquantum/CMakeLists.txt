list(APPEND LDFLAGS -lm)

macro(test_input run_type)
  llvm_test_run(RUN_TYPE ${run_type} WORKDIR %S
    ${ARGN} > ${run_type}.out
  )
  # Reference outputs for test+train have CRLF line endings so we have to use
  # diff --strip-trailing-cr
  # (This flag is a gnu extension, maybe we should rather extend fpcmp or
  #  somehow copy+fix the reference outputs?)
  llvm_test_verify(RUN_TYPE ${run_type}
    diff --strip-trailing-cr
    %S/data/${run_type}/output/${run_type}.out
    %S/${run_type}.out
  )
endmacro()

test_input(test 33 5)
test_input(train 143 25)
test_input(ref 1397 8)

llvm_test_executable(462.libquantum ${Source})
llvm_test_data_spec_default(462.libquantum)
