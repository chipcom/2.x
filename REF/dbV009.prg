#include 'function.ch'

#require 'hbsqlit3'

#define V009_IDRMP    1
#define V009_RMPNAME  2
#define V009_DL_USLOV 3
#define V009_DATEBEG  4
#define V009_DATEEND  5

// 23.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V009.xml
function getV009(work_date)
  // V009.xml - �����䨪��� १���⮢ ���饭�� �� ����樭᪮� �������
  static _arr
  local stroke := '', vid := ''
  static time_load
  local db
  local aTable, row
  local nI
  local ret_array

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
        if val(aTable[nI, V009_DL_USLOV]) == 1
          vid := '/��-�/'
        elseif val(aTable[nI, V009_DL_USLOV]) == 2
          vid := '/��.�/'
        elseif val(aTable[nI, V009_DL_USLOV]) == 3
          vid := '/�-��/'
        else
          vid := '/'
        endif
        stroke := str(val(aTable[nI, V009_IDRMP]), 3) + vid + alltrim(aTable[nI, V009_RMPNAME])
        aadd(_arr, {stroke, val(aTable[nI, V009_IDRMP]), ctod(aTable[nI, V009_DATEBEG]), ctod(aTable[nI, V009_DATEEND]), val(aTable[nI, V009_DL_USLOV])})
      next
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
    db := nil

  endif
  if hb_isnil(work_date)
    return _arr
  else
    ret_array := {}
    for each row in _arr
      if correct_date_dictionary(work_date, row[3], row[4])
        aadd(ret_array, row)
      endif
    next
  endif
  return ret_array

// 04.11.22 ������ १���� ���饭�� �� ����樭᪮� ������� �� ����
function getRSLT_V009(result)
  local ret := NIL
  local i

  if (i := ascan(getV009(), {|x| x[2] == result})) > 0
      ret := getV009()[i, 1]
  endif
  return ret

// 23.01.23 ������ १���� ���饭�� �� �᫮��� �������� � ���
function getRSLT_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV009(date)
    if uslovie == row[5]
      aadd(ret, row)
    endif
  next
  return ret
