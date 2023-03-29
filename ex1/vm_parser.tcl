proc push_constant {const} {
    return [list "@$const" "D=A" "@0" "A=M" "M=D" "@0" "M=M+1"]
}

proc stack_opertion {operator} {
    return [list "@0" "A=M-1" "D=M" "A=A-1" "M=D$operator M" "@0" "M=M-1"]
}

proc logical_opertion {operator} {
    return [list "@0" "M=M-1" "A=M" "D=M" "A=A-1" "M=D$operator M"]
}

# map line of vm code to hack code
proc map_line {line} {
    if {[string match "push constant*" $line]} {      
        set constant [lindex [split $line " "] end]
        return [push_constant $constant]
    } 
    elseif {[string match "pop*" $line]} {
        return [list "@0" "M=M-1" "A=M" "D=M"]
    }
    elseif {[string match "add*" $line]} {
        return [stack_opertion "+"]
    } 
    elseif {[string match "sub*" $line]} {
        return [stack_opertion "-"]
    } 
    elseif {[string match "and*" $line]} {
        return [logical_opertion "&"]
    } 
    elseif {[string match "or*" $line]} {
        return [logical_opertion "|"]
    } 
    elseif {[string match "not*" $line]} {
        return [list "@0" "A=M-1" "M=!M"]
    }  
    elseif {[string match "neg*" $line]} {
        return [list "@0" "A=M-1" "M=-M"]
    } 
    elseif {[string match "eq*" $line]} {
        return [list "@0" "M=M-1" "A=M" "D=M" "@0" "A=M-1" "D=D-M" "@IF_TRUE" "D;JEQ" "@0" "A=M-1" "M=0" "@IF_FALSE" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "M=-1" "(IF_FALSE)"]
    } 
    elseif {[string match "gt*" $line]} {
        return [list "@0" "A=M-1" "D=M" "A=A-1" "D=M-D" "@IF_TRUE" "D;JGT" "@0" "A=M-1" "A=A-1" "M=0" "@END" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "A=A-1" "M=-1" "(END)" "@0" "M=M-1"]
    } 
    elseif {[string match "lt*" $line]} {
        return [list "@0" "M=M-1" "A=M" "D=M" "@0" "A=M-1" "D=D-M" "@IF_TRUE" "D;JGT" "@0" "A=M-1" "M=0" "@IF_FALSE" "0;JMP" "(IF_TRUE)" "@0" "A=M-1" "M=-1" "(IF_FALSE)"]
    } 
}

# convert vm code to hack code
proc parse_vm_to_hack {vm_code} {
    # remove comments and empty lines
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