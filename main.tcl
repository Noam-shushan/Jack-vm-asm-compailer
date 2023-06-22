source "init_dirs.tcl"

# source "./tokenizer/tokenizer.tcl"
# source "./parser/parser.tcl"
# source "./jack_to_vm/jack_to_vm.tcl"
# source "./vm_to_hack/vm_to_hack.tcl"
# C:\Users\Asuspcc\TclWorks\projects\11\Pong

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