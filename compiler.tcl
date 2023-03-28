proc push_constant {const} {
    return [list "@$const" "D=A" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc stack_opertion {operator} {
    return [list "@0" "A=M-1" "D=M" "A=A-1" "M=D$operator M" "@0" "M=M-1"]
}

proc map_line {line} {
    if {[string match "push constant*" $line]} {      
        set constant [lindex [split $line " "] end]
        return [push_constant $constant]
    } elseif {[string match "add*" $line]} {
        return [stack_opertion "+"]
    } elseif {[string match "sub*" $line]} {
        return [stack_opertion "-"]
    } elseif {[string match "neg*" $line]} {
        return [list "@0" "A=M-1" "M=-M"]
    } elseif {[string match "eq*" $line]} {
        return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JEQ" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
    } elseif {[string match "gt*" $line]} {
        return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JGT" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
    } elseif {[string match "lt*" $line]} {
        return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JLT" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
    } elseif {[string match "and*" $line]} {
        return [stack_opertion "&"]
    } elseif {[string match "or*" $line]} {
        return [stack_opertion "|"]
    } elseif {[string match "not*" $line]} {
        return [list "@0" "A=M-1" "M=!M"]
    } else {
        return ""
    }
}



# proc map_line {line} {
#     if {[string match "push constant*" $line]} {
#         set constant [lindex [split $line " "] end]
#         return [push_constant $constant]
#     } elseif {[string match "add*" $line]} {
#         return [stack_opertion "+"]
#     } elseif {[string match "sub*" $line]} {
#         return [stack_opertion "-"]
#     } elseif {[string match "neg*" $line]} {
#         return [list "@0" "A=M-1" "M=-M"]
#     } elseif {[string match "eq*" $line]} {
#         return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JEQ" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
#     } elseif {[string match "gt*" $line]}{
#         return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JGT" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
#     } elseif {[string match "lt*" $line]} {
#         return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JLT" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
#     } elseif {[string match "and*" $line]} {
#         return [stack_opertion "&"]
#     } elseif {[string match "or*" $line]} {
#         return [stack_opertion "|"]
#     } elseif {[string match "not*" $line]} {
#         return [list "@0" "A=M-1" "M=!M"]
#     }
# }

proc convert_vm_to_hack {vm_code} {
    set only_code_lines [split $vm_code "\n"]
    set only_code_lines [lmap line $only_code_lines {
        if {![regexp {^\s*//} $line] && [string trim $line] ne ""} {
        string trim $line
        }
    }]

    set hack_code {}
    foreach line $only_code_lines {
        set result [map_line $line]
        if {$result ne ""} {
            lappend hack_code {*}$result
        }
    }
    return $hack_code
}