#include 'function.ch'

// 27.02.2021
// возвращает массив КСЛП на указанную дату
function getKSLPtable( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local tmpKSLP := {}
  
  // static aKSLP, loadKSLP := .f.
  
  // if loadKSLP //если массив КСЛП существует вернем его
  //   if (iy := ascan(aKSLP, {|x| x[1] == Year(dateSl) })) > 0 // год
  //     return aKSLP[ iy, 2 ]
  //   endif
  // endif
  
  if year(dateSl) == 2021 // КСЛП на 2021 год
    tmp_select := select()
    // aKSLP := {}
    dbName := '_mo1kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )
  
    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      if between(dateSl, (dbAlias)->DATEBEG, (dbAlias)->DATEEND)
      // if (dateSl >= (dbAlias)->DATEBEG) .and. (dateSl <= (dbAlias)->DATEEND)
        aadd(tmpKSLP, { (dbAlias)->CODE, alltrim((dbAlias)->NAME), alltrim((dbAlias)->NAME_F), (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      endif
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    // aadd(aKSLP, { Year(dateSl), tmpKSLP })
    // loadKSLP := .t.
  else
    alertx('На дату ' + DToC(dateSl) + ' КСЛП отсутствуют!')
  endif
  return tmpKSLP  