
# Expect exact numeric results. However, the libc printf implementation emits
# 'E' in scientific notation, while the reference output contains 'e'.
set(FP_ABSTOLERANCE 0.0)

add_subdirectory(ControlFlow-dbl)
add_subdirectory(ControlFlow-flt)
add_subdirectory(ControlLoops-dbl)
add_subdirectory(ControlLoops-flt)
add_subdirectory(CrossingThresholds-dbl)
add_subdirectory(CrossingThresholds-flt)
add_subdirectory(Equivalencing-dbl)
add_subdirectory(Equivalencing-flt)
add_subdirectory(Expansion-dbl)
add_subdirectory(Expansion-flt)
add_subdirectory(GlobalDataFlow-dbl)
add_subdirectory(GlobalDataFlow-flt)
add_subdirectory(IndirectAddressing-dbl)
add_subdirectory(IndirectAddressing-flt)
add_subdirectory(InductionVariable-dbl)
add_subdirectory(InductionVariable-flt)
add_subdirectory(LinearDependence-dbl)
add_subdirectory(LinearDependence-flt)
add_subdirectory(LoopRerolling-dbl)
add_subdirectory(LoopRerolling-flt)
add_subdirectory(LoopRestructuring-dbl)
add_subdirectory(LoopRestructuring-flt)
add_subdirectory(NodeSplitting-dbl)
add_subdirectory(NodeSplitting-flt)
add_subdirectory(Packing-dbl)
add_subdirectory(Packing-flt)
add_subdirectory(Recurrences-dbl)
add_subdirectory(Recurrences-flt)
add_subdirectory(Reductions-dbl)
add_subdirectory(Reductions-flt)
add_subdirectory(Searching-dbl)
add_subdirectory(Searching-flt)
add_subdirectory(StatementReordering-dbl)
add_subdirectory(StatementReordering-flt)
add_subdirectory(Symbolics-dbl)
add_subdirectory(Symbolics-flt)
