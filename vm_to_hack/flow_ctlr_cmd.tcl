proc label {label file_name} {
    return [list "($file_name.$label)"]
}

proc goto {label file_name} {
    return [list "@$file_name.$label" "0;JMP"]
}

proc if_goto {label file_name} {
    return [list "@SP" "M=M-1" "A=M" "D=M" "@$file_name.$label" "D; JNE"]
}