#include 'Directry.ch'
#include 'function.ch'
#include 'chip_mo.ch'
#include 'common.ch'

#require 'hbsqlit3'

#DEFINE TIMEEXISTS  600

static hExistsFilesNSI  // ��६����� �ᯮ������ � exists_file_TFOMS(...), array_exists_files_TFOMS(...) � fill_exists_files_TFOMS(...)

// 12.03.23
function array_exists_files_TFOMS(nYear)

  return hExistsFilesNSI[nYear]
  
// 12.03.23
function exists_file_TFOMS(nYear, nameTFOMS)
  local ret := .f., arr

  if nYear >= 2018
    arr := hExistsFilesNSI[nYear]
    if (i := ascan(arr, {|x| x[1] == lower(alltrim(nameTFOMS))})) > 0
      ret := arr[i, 2]
    endif
  endif
  return ret

// 23.03.23
function value_public_is_VMP(nYear)
  local cVar

  cVar := 'is_' + substr(str(nYear, 4), 3) + '_VMP'
  return __mvGet( cVar )

// 26.09.23
function fill_exists_files_TFOMS(cur_dir)
  local counterYear, prefix, arr, sbase
  local cDbf := '.dbf'
  local cDbt := '.dbt'

  if isnil(hExistsFilesNSI)
    hExistsFilesNSI := hb_Hash()
    for counterYear = 2018 to WORK_YEAR
      arr := {}
      prefix := cur_dir + prefixFileRefName(counterYear)
      aadd(arr, {'vmp_usl', hb_FileExists(prefix + 'vmp_usl' + cDbf)})
      aadd(arr, {'dep', hb_FileExists(prefix + 'dep' + cDbf)})
      aadd(arr, {'deppr', hb_FileExists(prefix + 'deppr' + cDbf)})
      aadd(arr, {'usl', hb_FileExists(prefix + 'usl' + cDbf)})
      aadd(arr, {'uslc', hb_FileExists(prefix + 'uslc' + cDbf)})
      aadd(arr, {'uslf', hb_FileExists(prefix + 'uslf' + cDbf)})
      aadd(arr, {'unit', hb_FileExists(prefix + 'unit' + cDbf)})
      // aadd(arr, {'shema', hb_FileExists(prefix + 'shema' + cDbf)})
      aadd(arr, {'k006', hb_FileExists(prefix + 'k006' + cDbf)})
      aadd(arr, {'it', hb_FileExists(prefix + 'it' + cDbf)})
      aadd(arr, {'it1', hb_FileExists(prefix + 'it1' + cDbf)})
      aadd(arr, {'kiro', hb_FileExists(prefix + 'kiro' + cDbf)})
      aadd(arr, {'kslp', hb_FileExists(prefix + 'kslp' + cDbf)})
      aadd(arr, {'lvlpay', hb_FileExists(prefix + 'lvlpay' + cDbf)})
      aadd(arr, {'moserv', hb_FileExists(prefix + 'moserv' + cDbf)})
      aadd(arr, {'prices', hb_FileExists(prefix + 'prices' + cDbf)})
      aadd(arr, {'subdiv', hb_FileExists(prefix + 'subdiv' + cDbf)})
      hExistsFilesNSI[counterYear] := arr
    next
  endif
  return nil

function openSQL_DB()

  return sqlite3_open( dir_exe() + FILE_NAME_SQL, .f. )

// 19.01.23
function timeout_load(/*@*/time_load)
  local ret := .f.

  if isnil(time_load)
    time_load := int(seconds())
    ret := .t.
  else
    if (int(seconds()) - time_load) > TIMEEXISTS
      time_load := int(seconds())
      ret := .t.
    endif
  endif

  return ret

function aliasIsAlreadyUse(cAlias)
  local we_opened_it := .f.
  local save_sel := select()

  if select(cAlias) != 0
    we_opened_it = .t.
  endif

  select(save_sel)
  return we_opened_it

// 18.03.23 
Function create_name_alias(cVarAlias, in_date)
  //* cVarAlias - ��ப� � ��砫�묨 ᨬ������ �����
  //* in_date - ��� �� ������ ����室��� ��ନ஢��� �����
  local ret := cVarAlias, valYear

  // �஢�ਬ �室�� ��ࠬ����
  if valtype(in_date) == 'D'
    valYear := year(in_date)
  elseif valtype(in_date) == 'N' .and. in_date >= 2018 .and. in_date < WORK_YEAR
    valYear := in_date
  else
    return ret
  endif

  if   ((valYear == WORK_YEAR) .or. (valYear < 2018))
    return ret
  endif

  // if valYear != WORK_YEAR .and. (WORK_YEAR - valYear) <= 5  // �᫨ ࠡ�稩 ��� �⫨砥��� �� ��⠭��������� � ����ன���
  // if valYear != WORK_YEAR .and. (valYear > 2018)  // �᫨ ࠡ�稩 ��� �⫨砥��� �� ��⠭��������� � ����ன���
    ret += substr(str(valYear, 4), 3)
  // elseif valYear < 2018
    // ret += '18'
  // endif
  return ret

// 04.11.21
// ������ ��䨪� �ࠢ�筮�� 䠩�� ��� ����
function prefixFileRefName(in_date)
  local valYear

  // �஢�ਬ �室�� ��ࠬ����
  if valtype(in_date) == 'D'
    valYear := year(in_date)
  elseif valtype(in_date) == 'N' .and. in_date >= 2018 .and. in_date <= WORK_YEAR
    valYear := in_date
  else
    valYear := WORK_YEAR
  endif

  return '_mo' + substr(str(valYear, 4, 0), 4, 1)

// 23.12.21
// ������ ��ப� �� ���� ��᫥���� ��� ��� ����
function last_digits_year(in_date)
  local valYear

  // �஢�ਬ �室�� ��ࠬ����
  if valtype(in_date) == 'D'
    valYear := year(in_date)
  elseif valtype(in_date) == 'N' .and. in_date >= 2018 .and. in_date <= WORK_YEAR
    valYear := in_date
  else
    valYear := WORK_YEAR
  endif

  return str(valYear - 2000, 2, 0)

// 14.02.21
function notExistsFileNSI(nameFile)
  // nameFile - ������ ��� 䠩�� ���
  return func_error('����� ���������� - 䠩� "' + upper(nameFile) + '" ���������.')

// 17.05.21
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

// 21.08.24
function dir_XML_FNS()

  static dir

  if isnil( dir )
    dir := dir_server + 'XML_FNS' + hb_ps()
  endif

  return dir

// 14.10.24
function dir_exe()
  
  static dir

  if isnil( dir )
    dir := hb_DirBase()
  endif
  return dir

// 22.03.24
function cur_dir()

  static dir

  if isnil( dir )
    dir := chip_CurrPath()
  endif
  return dir

// 14.04.23
function chip_CurrPath()

  local cPrefix

#ifdef __PLATFORM__UNIX
  cPrefix := '/'
#else
  cPrefix := hb_curDrive() + ':\'
#endif

  RETURN cPrefix + CurDir() + hb_ps()

// 14.04.23
// function chip_ExePath()

//   return upper(beforatnum(hb_ps(), exename())) + hb_ps()

// 17.04.23
function check_extension_file(fileName, sExt)

  return lower(right(fileName, len(sExt))) == lower(sExt)

// 08.10.23
function suffixFileTimestamp()
  local cRet

  cRet := hb_StrReplace(hb_strShrink(HB_TSTOSTR(hb_DateTime(), .f.), 4 ), ' :', '__')
  return cRet

  function SaveTo( cOldFileFull )
    local nResult
    local cDirR, cNameR, cExtR
    local nameFile
    local newDir
  
    hb_FNameSplit( cOldFileFull, @cDirR, @cNameR, @cExtR )
    nameFile := cNameR + cExtR
  
    newDir := manager( 5, 10, maxrow() - 2, , .t., 2, .f., , , ) // "norton" ��� �롮� ��⠫���
    if !empty( newDir )
      if upper( newDir ) == upper( cDirR )
        func_error(4, '��࠭ ��⠫��, � ���஬ 㦥 ����ᠭ 楫���� 䠩�! �� �������⨬�.')
      else
        if hb_FileExists(cOldFileFull)
          mywait('����஢���� "' + nameFile + '" � ��⠫�� "' + newDir + '"' )
          if hb_FileExists(newDir + nameFile)
            hb_FileDelete(newDir + nameFile)
          endif
          nResult := FRename( (cOldFileFull), ( newDir + nameFile ) )
          if nResult != 0
            func_error( 4, "�訡�� ᮧ����� 䠩�� " + newDir + nameFile )
          else
            n_message({'� ��⠫��� '+ newDir +' ����ᠭ 䠩�',;
              '"' + upper(nameFile) + '".';
              },,;
              cColorSt2Msg,cColorStMsg,,,"G+/R")
          endif
        endif
      endif
    else
      n_message({'� ��⠫��� '+ cDirR +' ����ᠭ 䠩�',;
      '"' + upper(nameFile) + '".';
      },,;
      cColorSt2Msg,cColorStMsg,,,"G+/R")
  endif
  
  return iif( empty( newDir ), nil, newDir + nameFile )