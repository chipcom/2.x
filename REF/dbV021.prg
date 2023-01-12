
#require 'hbsqlit3'

* 12.01.23 вернуть массив по справочнику ФФОМС V021.xml
function getV021()
  // V021.xml - Классификатор медицинских специальностей (должностей) (MedSpec)
  //  1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - POSTNAME(C)  6 - IDPOST_MZ(C)
  // local dbName := '_mo_v021'
  // Local dbAlias := 'V021'
  // local tmp_select := select()

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    // dbUseArea(.t., , exe_dir + dbName, dbName, .f., .f.)
    // (dbName)->(dbGoTop())
    // do while !(dbName)->(EOF())
    //   if Empty((dbName)->DATEEND)
    //     aadd(_arr, {alltrim(str((dbName)->IDSPEC)) + '.' + alltrim((dbName)->SPECNAME), (dbName)->IDSPEC, (dbName)->DATEBEG, (dbName)->DATEEND, alltrim((dbName)->POSTNAME), alltrim((dbName)->IDPOST_MZ)})
    //   endif
    //   (dbName)->(dbSkip())
    // enddo
    // (dbName)->(dbCloseArea())
    // Select(tmp_select)
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    // aTable := sqlite3_get_table( db, "SELECT idspec, specname, postname, idpost_mz, datebeg, dateend FROM v021" )
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
        'idspec, ' + ;
        'idspec || "." || trim(specname), ' +;
        'postname, ' + ;
        'idpost_mz, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v021')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        if Empty(ctod(aTable[nI, 6]))
        //  aadd(_arr, {alltrim(aTable[nI, 1]) + '.' + alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4])})
         aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6]), alltrim(aTable[nI, 3]), alltrim(aTable[nI, 4])})
        endif
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil
  endif
  return _arr

** 12.12.22 вернуть массив описывающий специальность
Function DoljBySpec_V021(idspec)
  Local i, retArray := ''
  local aV021 := getV021()

  if !empty(idspec) .and. ((i := ascan(aV021, {|x| x[2] == idspec})) > 0)
    retArray := aV021[i, 5]
  endif
  return retArray

