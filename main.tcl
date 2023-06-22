source "./init_dirs.tcl"

proc main { dir } {
    tokenize_dir $dir
    parse_dir $dir
    # jack_to_vm $dir
    # vm_to_hack $dir
    
}


if {[info script] eq $argv0} {
    set root [lindex $argv 0]
    main $root
}