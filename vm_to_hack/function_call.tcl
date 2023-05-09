# path of the tests: ../../projects/08/FunctionCalls/{SimpleFunction/ (test pass) | NestedCall/ | FibonacciElement/ | StaticsTest/}

proc push_referenced_address_onto_stack { virtual_memory_segment } {
    return [list "@$virtual_memory_segment" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
}

set call_counter 0

proc call_cmd {func_name args_count} {
    global call_counter
    incr call_counter
    set result [list "// push return-address" "@$func_name.ReturnAddress$call_counter" "D=A" "@SP" "A=M" "M=D" "@SP" "M=M+1" ]
    set push_local [push_referenced_address_onto_stack "LCL"]
    set push_arg [push_referenced_address_onto_stack "ARG"]
    set push_this [push_referenced_address_onto_stack "THIS"]
    set push_that [push_referenced_address_onto_stack "THAT"]
    set end_result [list "// ARG = SP-n-5" "@SP" "D=M" "@$args_count" "D=D-A" "@ARG" "M=D" "// LCL = SP" "@SP" "D=M" "@LCL" "M=D" "// goto $func_name" "@$func_name" "0;JMP" "// label return-address" "($func_name.ReturnAddress$call_counter)"]
    return [concat $result $push_local $push_arg $push_this $push_that $end_result]
}

set func_loop_local_counter 0
set no_locals_counter 0

proc func_cmd {func_name args_count} {
    global func_loop_local_counter
    global no_locals_counter
    incr func_loop_local_counter
    incr no_locals_counter
    return [list "($func_name)" "@$args_count" "D=A" "(LOOP.ADD_LOCALS.$func_loop_local_counter)" "@NO_LOCALS.$no_locals_counter" "D;JEQ" "@SP" "A=M" "M=0" "@SP" "M=M+1" "D=D-1" "@LOOP.ADD_LOCALS.$func_loop_local_counter" "D;JNE" "(NO_LOCALS.$no_locals_counter)" "@2" "D=M" "@0" "D=D+A" "A=D" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1"]
} 

proc return_cmd {} {
    return [list "@LCL" "D=M" "@R13" "M=D" "@5" "D=A" "@R13" "A=M-D" "D=M" "@R14" "M=D" "@SP" "AM=M-1" "D=M" "@ARG" "A=M" "M=D" "@ARG" "D=M+1" "@SP" "M=D" "@1" "D=A" "@R13" "A=M-D" "D=M" "@THAT" "M=D" "@2" "D=A" "@R13" "A=M-D" "D=M" "@THIS" "M=D" "@3" "D=A" "@R13" "A=M-D" "D=M" "@ARG" "M=D" "@4" "D=A" "@R13" "A=M-D" "D=M" "@LCL" "M=D"]
}


proc bootstrap {} {
    return [list "// bootstarp" "@256" "D=A" "@SP" "M=D" "@Sys.init.ReturnAddress0" "D=A" "@SP" "A=M" "M=D" "@SP" "M=M+1" "@LCL" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1" "@ARG" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1" "@THIS" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1" "@THAT" "D=M" "@SP" "A=M" "M=D" "@SP" "M=M+1" "@SP" "D=M" "@0" "D=D-A" "@5" "D=D-A" "@ARG" "M=D" "@SP" "D=M" "@LCL" "M=D" "@Sys.init.ReturnAddress0" "0;JMP" "(Sys.init.ReturnAddress0)" "\n"]
}

