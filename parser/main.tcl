source "../file_handler.tcl"
source "parser.tcl"

proc get_xml_content {file_conntent} {
  set file_content_list [split $file_conntent "\n"]
  set tokens_list [list]
  foreach line $file_content_list {
    set raw_tokens [lindex [split [string trim $line] "</"] 1]
    set label [string trim [lindex [split $raw_tokens ">"] 0]]
    set token [string trim [lindex [split $raw_tokens ">"] 1]]
    if { $label != "tokens" && $token != "" } {  
      set lable_token_dict [dict create "label" $label "token" $token]
      lappend tokens_list $lable_token_dict
    }
  }
  return $tokens_list
}


proc main {dir} { 
  set tokens_files [glob -directory $dir -types f -tails *T.xml]
  foreach file $tokens_files {
    # get tokens from file
    set file_xml_conntent [read_file $dir/$file]
    set tokens [get_xml_content $file_xml_conntent]
    set xml_tree_result [complie $tokens]
    # set parsed_tokens [parse_tokens $tokens]
    # set converted_to_xml [convert_to_xml $parsed_tokens]
    # # write to parsed files
    # write_file $dir/[string range $file 0 end-5].xml $converted_to_xml  
  }
}


if {[info script] eq $argv0} {
  main [lindex $argv 0]
}
