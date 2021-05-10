proc main()
  local dVal, tVal
  local tValue

  dVal := Date()
  tVal := dVal + {^ 02:00 }  // {^ 02:00 } timestamp
                             // constant, see below
  ? ValType(dVal), ValType(tVal)
  ? dVal; ? tVal
  dVal += 1.125  // In Clipper and Harbour it increases
                 // date value by 1
  tVal += 1.25   // it it increases timestamp value by 1 day
                 // and 6 hours
  ? dVal; ? tVal
  ? dVal = tVal  // In Harbour .T. because date part is the same
  ? Date() + 0.25, Date() + 0.001 == Date()

  // pattern:  YYYY-MM-DD [H[H][:M[M][:S[S][.f[f[f[f]]]]]]] [PM|AM]
  tValue := t"2020-03-21 5:31:45.437 PM"
  ? tValue
  // pattern:  YYYY-MM-DDT[H[H][:M[M][:S[S][.f[f[f[f]]]]]]] [PM|AM]
  tValue := t"2021-03-21T17:31:45.437"
  ? tValue
  
  ? e"Helow\r\nWorld \x21\041\x21\000abcdefgh"
  ? e"Helow\r\nWorld \x21\041abcdefgh"

return
