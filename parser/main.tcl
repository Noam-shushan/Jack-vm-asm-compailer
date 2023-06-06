source "../file_handler.tcl"

proc main {dir} { 
  set tokens_files [glob -directory $dir -types f -tails *T.xml]
  foreach file $tokens_files {
    set file_conntent [read_file $dir/$file]
    # handle file content
    write_file [$dir/[join [split $ $file T] ""] "hi mom"]  
  }
}

if {[info script] eq $argv0} {
  main [lindex $argv 0]
}
