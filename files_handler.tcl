proc read_file {file_path} {
    if {![file exists $file_path]} {
        puts "Error: file $file_path does not exist"
        return
    }
    set f [open $file_path r]
    set content [read $f]
    close $f
    return $content
}

proc write_file {file_path content} {
    set f [open $file_path w]
    puts $f $content
    close $f
}