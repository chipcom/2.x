***** 11.02.2021
// возвращает шифр услуги соответствующий виду и методу ВМП и диагнозу
function getServiceForVMP(hVid, hMethod, model) // sDiag)
  // hVid - вид ВМП (строка)
  // hMethod - метод ВМП (целое)
  // model - модель пациента V022 (целое)
  // sDiag - основной диагноз
  local ret := '', vid := alltrim(hVid) //, diag := alltrim(sDiag)
  local arrVMP_USL := getVMP_USL()
  local i := 0, row, arr := {}

  for each row in arrVMP_USL
    // arr := hb_ATokens(row[4], ';')  // развернем массив разрешенных диагнозов для ВМП
    if row[2] == vid .and. row[3] == hMethod .and. row[4] == model //(ascan(arr, diag) > 0)
alertx(model,'model')
      ret := row[1]
      // exit
    endif
  next
  return ret

***** 11.02.2021
// возвращает массив соответствия видов и методов ВМП услугам ФФОС
function getVMP_USL( dateSl)
  static arrVMP_USL := {}

  Local dbName, dbAlias := 'VMP_USL'
  local tmp_select := select()
  
  if len(arrVMP_USL) == 0
    dbName := '_mo1vmp_usl'
    tmp_select := select()
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
  
    //  1 - SHIFR(C)  2 - HVID(C)  3 - HMETHOD(N) 4 - MODEL(N) //  4 - DIAGNOZIS(C)
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(arrVMP_USL, { alltrim((dbAlias)->SHIFR), alltrim((dbAlias)->HVID), (dbAlias)->HMETHOD, (dbAlias)->MODEL })
      (dbAlias)->(dbSkip())
    enddo
  
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
  endif
  return arrVMP_USL
