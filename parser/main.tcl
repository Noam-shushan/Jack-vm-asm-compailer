source "../file_handler.tcl"
source "parser.tcl"


# run: tclsh main.tcl ./test
if {[info script] eq $argv0} {
  parse_dir [lindex $argv 0]
}
