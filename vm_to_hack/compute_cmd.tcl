
proc binary_operation {operator} {
    return [list "@0" "M=M-1" "A=M" "D=M" "@0" "M=M-1" "A=M" "M=M${operator}D" "@0" "M=M+1"]
}

proc onary_operation {operator} {
    return [list "@0" "M=M-1" "A=M" "M=${operator}M" "@0" "M=M+1"]
}

set true_counter -1
set end_counter -1

proc compare_operation {operator} {
    global true_counter
    global end_counter
    incr true_counter
    incr end_counter
    return [list "@0" "M=M-1" "A=M" "D=M" "@0" "M=M-1" "A=M" "D=D-M" "@TRUE$true_counter" "D;$operator" "@0" "A=M" "M=0" "@END$end_counter" "0;JMP" "(TRUE$true_counter)" "@0" "A=M" "M=-1" "(END$end_counter)" "@0" "M=M+1"]
}