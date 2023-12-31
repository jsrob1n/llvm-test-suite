if(ENDIAN STREQUAL "big")
  list(APPEND CPPFLAGS -DHOST_WORDS_BIG_ENDIAN)
endif()
if(TARGET_OS STREQUAL "Darwin")
  # Necessary for iOS
  list(APPEND LDFLAGS -Xlinker -stack_size -Xlinker 0x800000)
endif()
list(APPEND CFLAGS -std=gnu89)
# We want reproducible builds
list(APPEND CPPFLAGS -D__DATE__="XXX" -D__TIME__="XXX")

macro(test_input run_type ifile sfile)
  llvm_test_run(RUN_TYPE ${run_type} WORKDIR %S
    data/${run_type}/input/${ifile} -o ${sfile}
  )
  llvm_test_verify(RUN_TYPE ${run_type}
    %b/${FPCMP} %S/data/${run_type}/output/${sfile} %S/${sfile}
  )
endmacro()

test_input(ref 166.i 166.s)
test_input(ref 200.i 200.s)
test_input(ref expr.i expr.s)
test_input(ref integrate.i integrate.s)
test_input(ref scilab.i scilab.s)
test_input(train cp-decl.i cp-decl.s)
test_input(test cccp.i cccp.s)

llvm_test_executable(176.gcc ${Source})
llvm_test_data_spec_default(176.gcc)
