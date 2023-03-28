# proc convert_vm_to_hack {path vm_file_name} {
#     puts $path
#     set file_path [file join $path $vm_file_name]
#     set lines [read_file $file_path]
#     set only_code_lines [split lines "\n"]
#     set only_code_lines [lmap line $only_code_lines {
#     if {![regexp {^\s*//} $line] && [string trim $line] ne ""} {
#         string trim $line
#     }}]

#     set hack_code {}
#     foreach line $only_code_lines {
#         set result [map_line $line]
#         if {$result ne ""} {
#             lappend hack_code {*}$result
#         }
#     }

#     set asm_file_name [string map {".vm" ".asm"} $vm_file_name]
#     set hack_f [open [file join $path $asm_file_name] w]
#     puts $hack_f [join $hack_code "\n"]
#     close $hack_f
# }

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