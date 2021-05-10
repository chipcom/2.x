proc main()
  local funcSym
  
  funcSym := @Str()
  ? funcSym:name, "=>", funcSym:exec( 123.456, 10, 5 )
  funcSym := &("@Upper()")
  ? funcSym:name, "=>", funcSym:exec( "Harbour" )
return
