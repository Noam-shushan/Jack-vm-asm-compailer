
proc binary_operation {operator} {
    return [list "@SP" "M=M-1" "A=M" "D=M" "@SP" "M=M-1" "A=M" "M=M${operator}D" "@SP" "M=M+1"]
}

proc onary_operation {operator} {
    return [list "@SP" "M=M-1" "A=M" "M=${operator}M" "@SP" "M=M+1"]
}

set true_counter -1
set false_counter -1
set end_counter -1

proc compare_operation {operator} {
    global true_counter
    global false_counter
    global end_counter
    incr true_counter
    incr false_counter
    incr end_counter
    return [list "@SP" "M=M-1" "A=M" "D=M" "@SP" "M=M-1" "A=M" "D=M-D" "@TRUE$true_counter" "D;$operator" "@FALSE$false_counter" "0;JMP" "(TRUE$true_counter)" "@SP" "A=M" "M=-1" "@SP" "M=M+1" "@END$end_counter" "0;JMP" "(FALSE$false_counter)" "@SP" "A=M" "M=0" "@SP" "M=M+1" "(END$true_counter)"]
}