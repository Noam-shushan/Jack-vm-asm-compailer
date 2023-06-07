
proc complie_symbol { tokens_name symbol } {
    upvar 1 $tokens_name tokens
    
    set output ""
    set next_token [lindex $tokens 0]
    set label [dict get $next_token label]
    set token [dict get $next_token token]
    if { $label == "symbol" && $token == $symbol } {
        set output "<symbol>$token</symbol>\n"
        set tokens [lrange $tokens 1 end]
    } else {
        return ""
    }
    set next_token [lindex $tokens 0]
    puts "$next_token  // in complie_symbol"

    return $output
}