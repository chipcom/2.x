***** 10.02.2021
// возвращает шифр услуги соответствующий виду и методу ВМП
function getServiceForVMP(hVid, hMethod)
  // hVid - вид ВМП (строка)
  // hMethod - метод ВМП (целое)
  local ret := '', vid := alltrim(hVid)
  local arrVMP_USL := getVMP_USL()
  local i

  if (i := ascan(arrVMP_USL, {|x| x[2] == vid .and. x[3] == hMethod })) > 0
    ret := arrVMP_USL[i, 1]
  endif

  return ret

***** 10.02.2021
// возвращает массив соответствия видов и методов ВМП услугам ФФОС
function getVMP_USL( dateSl)
  static arrVMP_USL := {}

  Local dbName, dbAlias := 'VMP_USL'
  local tmp_select := select()
  
  // if year(dateSl) == 2021
  // else
  //   return arrVMP_USL
  // endif
  if len(arrVMP_USL) == 0
    dbName := '_mo1vmp_usl'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
  
    //  1 - SHIFR(C)  2 - HVID(C)  3 - HMETHOD(N)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(arrVMP_USL, { alltrim((dbAlias)->SHIFR), alltrim((dbAlias)->HVID), (dbAlias)->HMETHOD })
      (dbAlias)->(dbSkip())
    enddo
    // asort(tmpV018,,,{|x,y| x[1] < y[1] })
  
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif

  return arrVMP_USL
