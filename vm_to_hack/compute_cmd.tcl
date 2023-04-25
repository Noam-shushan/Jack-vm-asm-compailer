
proc arithmetic_operation {operator} {
    return [list "@0" "A=M-1" "D=M" "A=A-1" "M=D$operator M" "@0" "M=M-1"]
}

proc logical_operation {operator} {
    return [list "@0" "M=M-1" "A=M" "D=M" "A=A-1" "M=D$operator M"]
}