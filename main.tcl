source "./tokenizer/tokenizer.tcl"
source "./parser/parser.tcl"
source "./parser_to_vm/jack_to_vm.tcl"
source "./vm_to_hack/vm_to_hack.tcl"

proc main { dir } {
    tokenize_dir $dir
    puts "tokenize done"
    parse_dir $dir
    puts "parse done"
    jack_to_vm $dir
    puts "jack_to_vm done"
    vm_to_hack $dir
    puts "compile done"
}


if {[info script] eq $argv0} {
    set root [lindex $argv 0]
    main $root
}