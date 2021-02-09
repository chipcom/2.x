***** 09.02.2021
// возвращает массив соответствия видов и методов ВМП услугам ФФОС
function getVMP_USL( dateSl)
  Local dbName, dbAlias := 'VMP_USL'
  local tmp_select := select()
  local tmpVMP_USL := {}
  
  if year(dateSl) == 2021
    dbName := '_mo1vmp_usl'
  else
    return tmpVMP_USL
  endif

  tmp_select := select()
  dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

  //  1 - SHIFR(C)  2 - HVID(C)  3 - HMETHOD(N)
  (dbAlias)->(dbGoTop())
  do while !(dbAlias)->(EOF())
    aadd(tmpVMP_USL, { alltrim((dbAlias)->SHIFR), alltrim((dbAlias)->HVID), (dbAlias)->HMETHOD })
    (dbAlias)->(dbSkip())
  enddo
  // asort(tmpV018,,,{|x,y| x[1] < y[1] })

  (dbAlias)->(dbCloseArea())
  Select(tmp_select)
  return tmpVMP_USL
