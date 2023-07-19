proc bad_swap {x y} {
    set temp $x
    set x $y
    set y $temp
}
# dont do anything ❌❌❌❌

proc good_swap {x_name y_name} {
    upvar 1 $x_name x
    upvar 1 $y_name y
    set temp $x
    set x $y
    set y $temp
}
# do something ✅✅✅✅
