#include 'function.ch'

#require 'hbsqlit3'

#define V009_IDRMP    1
#define V009_RMPNAME  2
#define V009_DL_USLOV 3
#define V009_DATEBEG  4
#define V009_DATEEND  5

** 23.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V009.xml
function getV009(work_date)
  // V009.xml - �����䨪��� १���⮢ ���饭�� �� ����樭᪮� �������
  // Local dbName, dbAlias := 'V009'
  // local tmp_select := select()
  static _arr   //:= {} 
  local stroke := '', vid := ''
  static time_load
  local db
  local aTable, row
  local nI
  local ret_array

  // if len(_arr) == 0
  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'idrmp, ' + ;
      'rmpname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v009')  // WHERE dateend == "    -  -  "')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        // if val(aTable[nI, 3]) == 1
        if val(aTable[nI, V009_DL_USLOV]) == 1
          vid := '/��-�/'
        // elseif val(aTable[nI, 3]) == 2
        elseif val(aTable[nI, V009_DL_USLOV]) == 2
          vid := '/��.�/'
        // elseif val(aTable[nI, 3]) == 3
        elseif val(aTable[nI, V009_DL_USLOV]) == 3
          vid := '/�-��/'
        else
          vid := '/'
        endif
        // stroke := str(val(aTable[nI, 1]), 3) + vid + alltrim(aTable[nI, 2])
        // aadd(_arr, { stroke, val(aTable[nI, 1]), ctod(aTable[nI, 4]), ctod(aTable[nI, 5]), val(aTable[nI, 3]) })
        stroke := str(val(aTable[nI, V009_IDRMP]), 3) + vid + alltrim(aTable[nI, V009_RMPNAME])
        aadd(_arr, {stroke, val(aTable[nI, V009_IDRMP]), ctod(aTable[nI, V009_DATEBEG]), ctod(aTable[nI, V009_DATEEND]), val(aTable[nI, V009_DL_USLOV])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

  //   tmp_select := select()
  //   dbName := '_mo_v009'
  //   dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbAlias , .t., .f. )

  // //  1 - RMPNAME(C)  2 - IDRMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DL_USLOV(N)
  // (dbAlias)->(dbGoTop())
  //   do while !(dbAlias)->(EOF())
  //     if empty((dbAlias)->DATEEND)  // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
  //       if (dbAlias)->DL_USLOV == 1
  //         vid := '/��-�/'
  //       elseif (dbAlias)->DL_USLOV == 2
  //         vid := '/��.�/'
  //       elseif (dbAlias)->DL_USLOV == 3 .and. (dbAlias)->IDRMP < 316
  //         vid := '/�-��/'
  //       else
  //         vid := '/'
  //       endif
  //       stroke := str((dbAlias)->IDRMP, 3) + vid + alltrim((dbAlias)->RMPNAME)
  //       aadd(_arr, { stroke, (dbAlias)->IDRMP, (dbAlias)->DATEBEG, (dbAlias)->DATEEND, (dbAlias)->DL_USLOV })
  //     endif
  //     (dbAlias)->(dbSkip())
  //   enddo

  //   (dbAlias)->(dbCloseArea())
  //   Select(tmp_select)
  endif
  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      // if (row[3] <= work_date) .and. (empty(row[4]) .or. row[4] >= work_date)
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  // return _arr
  return ret_array

** 04.11.22 ������ १���� ���饭�� �� ����樭᪮� ������� �� ����
function getRSLT_V009(result)
  local ret := NIL
  local i

  if (i := ascan(getV009(), {|x| x[2] == result})) > 0
      ret := getV009()[i, 1]
  endif
  return ret

** 23.01.23 ������ १���� ���饭�� �� �᫮��� �������� � ���
function getRSLT_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV009(date)
    // if (empty(row[4]) .and. date >= row[3]) .or. between_date(row[3], row[4], date)
      if uslovie == row[5]
        // aadd(ret, {row[1], row[2], row[3], row[4], row[5]})
        aadd(ret, row)
      endif
    // endif
  next
  return ret
