#include 'function.ch'

#require 'hbsqlit3'

#define V012_IDIZ     1
#define V012_IZNAME   2
#define V012_DL_USLOV 3
#define V012_DATEBEG  4
#define V012_DATEEND  5

// 23.01.23 вернуть массив по справочнику ФФОМС V012.xml
function getV012(work_date)
  // V012.xml - Классификатор исходов заболевания
  static _arr
  static time_load
  local stroke := '', vid := ''
  local db
  local aTable, row
  local nI
  local ret_array

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
        'idiz, ' + ;
        'izname, ' + ;
        'dl_uslov, ' + ;
        'datebeg, ' + ;
        'dateend ' + ;
        'FROM v012')   // WHERE dateend == "    -  -  "')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        // if empty(ctod(aTable[nI, 5]))  // только если поле окончания действия пусто
        if val(aTable[nI, V012_DL_USLOV]) == 1
          vid := '/ст-р/'
        elseif val(aTable[nI, V012_DL_USLOV]) == 2
          vid := '/дн.с/'
        elseif val(aTable[nI, V012_DL_USLOV]) == 3
          vid := '/п-ка/'
        else
          vid := '/'
        endif
        stroke := str(val(aTable[nI, V012_IDIZ]), 3) + vid + alltrim(aTable[nI, V012_IZNAME])
        aadd(_arr, { stroke, val(aTable[nI, V012_IDIZ]), ctod(aTable[nI, V012_DATEBEG]), ctod(aTable[nI, V012_DATEEND]), val(aTable[nI, V012_DL_USLOV])})
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

// 06.11.22 вернуть исход заболевания по коду
function getISHOD_V012(ishod)
  local ret := NIL
  local i

  if (i := ascan(getV012(), {|x| x[2] == ishod})) > 0
    ret := getV012()[i, 1]
  endif
  return ret

// 23.01.23 вернуть исход заболевания по условию оказания и дате
function getISHOD_usl_date(uslovie, date)
  local ret := {}
  local row

  for each row in getV012(date)
    if uslovie == row[5]
      aadd(ret, row)
    endif
  next
  return ret