# return 1 if the object is a dict, 0 otherwise
proc is_dict {obj} {
    if {[catch {dict size $obj}]} {
        return 0
    } else {
        return 1
    }
}

# remove empty lines from a string
proc remove_empty_lines {str} {
    set lines [split $str "\n"]
    set new_lines {}
    foreach line $lines {
        if {[string length $line]} {
            lappend new_lines $line
        }
    }
    return [join $new_lines "\n"]
}

# convert a dict to xml recursively
proc dict_to_xml_rec { obj root} {
  if {[is_dict $obj]} {
    set xml ""
    foreach {key value} [dict get $obj] {
      if {[is_dict $value]} {
        append xml "\n[dict_to_xml $value $key]"
      } else {
        append xml "\n<$key>$value</$key>"
      }
    }
    return  "\n<$root>\n$xml\n</$root>"
  } else {
    return "\n<$root>\n$obj\n</$root>"
  }
}

# convert a dict to xml
proc dict_to_xml {obj root} {
  set xml [dict_to_xml_rec $obj $root]
  return [remove_empty_lines $xml]
}
