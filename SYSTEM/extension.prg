#include 'Directry.ch'
#include 'function.ch'
#include 'chip_mo.ch'

function aliasIsAlreadyUse(cAlias)
  local we_opened_it := .f.
  local save_sel := select()

  if select(cAlias) != 0
    we_opened_it = .t.
  endif

  select(save_sel)
  return we_opened_it

***** 24.11.21 
Function create_name_alias(cVarAlias, in_date)
  *** cVarAlias - строка с начальными символами алиаса
  *** in_date - дата на которую необходимо сформировать алиас
  local ret := cVarAlias, valYear

  // проверим входные параметры
  if valtype(in_date) == 'D'
    valYear := year(in_date)
  elseif valtype(in_date) == 'N' .and. in_date > 2010 .and. in_date <= WORK_YEAR
    valYear := in_date
  else
    return ret
  endif

  if valYear != WORK_YEAR .and. (WORK_YEAR - valYear) <= 3  // если рабочий год отличается от установленного в настройках
    ret += substr(str(valYear, 4), 3)
  elseif valYear < 2018
    ret += '18'
  endif
  return ret

// 04.11.21
// вернуть префикс справочного файла для года
function prefixFileRefName(in_date)
  local valYear

  // проверим входные параметры
  if valtype(in_date) == 'D'
    valYear := year(in_date)
  elseif valtype(in_date) == 'N' .and. in_date > 2018 .and. in_date <= WORK_YEAR
    valYear := in_date
  else
    valYear := WORK_YEAR
  endif

  return '_mo' + substr(str(valYear, 4, 0), 4, 1)

***** 14.02.2021
function notExistsFileNSI(nameFile)
  // nameFile - полное имя файла НСИ
  return func_error('Работа невозможна - файл "' + upper(nameFile) + '" отсутствует.')

***** 17.05.2021
function checkNTXFile( cSource, cDest )
  static arrNTXFile := {}
  local fl := .f.
  local tsDateTimeSource, tsDateTimeDest
  local nPos

  if len(arrNTXFile) == 0
    arrNTXFile := hb_vfDirectory( cur_dir + '*.ntx' )
  endif

  HB_VFTIMEGET( cSource, @tsDateTimeSource )

  nPos := AScan( arrNTXFile, ;
    {| aFile, nPos | HB_SYMBOL_UNUSED( nPos ), aFile[ F_NAME ] == cDest } )
  if nPos != 0
    tsDateTimeDest := arrNTXFile[nPos, F_DATE]
  else
    return .t.
  endif
  if tsDateTimeSource > tsDateTimeDest
    fl := .t.
  endif

  return fl