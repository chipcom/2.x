procedure main()
  local a, b, c, x, s
  local d := 'Hello, world' //{10, 15, 8}
  local hVal

  // FOR EACH a IN d   // Descend
  //   ? a
  // NEXT

  FOR EACH x IN { "ABC" => 123, "ASD" => 456, "ZXC" => 789 }
    ? x, "@", x:__enumKey()
  NEXT

  s := "abcdefghijk"
  FOR EACH c IN @s
    IF c $ "aei"
      c := Upper( c )
    ENDIF
  NEXT
  ? s      // AbcdEfghIjk

  hVal := { "ABC" => 123, "ASD" => 456, "ZXC" => 789 }
  FOR EACH x IN hVal
     ? x:__enumIndex(), ":", x:__enumKey(), "=>", x:__enumValue(), ;
       "=>", x:__enumBase()[ x:__enumKey() ]
  NEXT

  // p(0)

  return nil

proc p( n )
    local s := "a", x
    ? n
    if n < 1000
       for each x in s
          p( n + 1 )
       next
    endif
 return
