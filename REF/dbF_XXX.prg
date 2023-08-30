#include 'inkey.ch'
#include 'function.ch'
#include 'common.ch'
#include 'edit_spr.ch'
#include "chip_mo.ch"

#include 'tbox.ch'

#require 'hbsqlit3'

// =========== F003 ===================
//
// 20.01.21 {_MO_KOD_TFOMS,_MO_SHORT_NAME}
Function viewF003()

  local nTop, nLeft, nBottom, nRight
  local tmp_select := select()
  local l := 0, fl
  Local ar, aStruct, dbName := '_mo_f003', indexName := cur_dir + dbName
	local color_say := 'N/W', color_get := 'W/N*'
  local oBox, oBoxRegion
  local strRegion := '�롮� ॣ����' 
  local lFileCreated := .f.
  local retMCOD := { '', space(10) }
  local ar_f010 := getf010()
  local selectedRegion := '34'
  local sbase := 'mo_add'
  local prev_codem := 0, cur_codem := 0

  private nRegion := 34
  private tmpName := cur_dir + 'tmp_F003', tmpAlias := 'tF003'
  private oBoxCompany
  private fl_space := .f., fl_other_region := .f.

  ar := {}
  for i := 1 to len(ar_f010)
    aadd(ar, ar_f010[i, 1])
    l := max(l,len(ar[i]))
  next

  dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbName, .t., .f. )
  aStruct := (dbName)->(dbStruct())
  (dbName)->(dbCreateIndex( indexName, 'substr(MCOD,1,2)', , NIL ))

  nTop := 4
  nLeft := 3
  nBottom := 23
  nRight := 77

  // ���� �롮� ॣ����
  oBoxRegion := TBox():New( nTop, nLeft, nBottom, nRight )
  oBoxRegion:Caption := '�롥�� ॣ���'
  oBoxRegion:Frame := BORDER_SINGLE
    
  // ���� ������� ������������ �࣠����樨
  oBoxCompany := TBox():New( 19, 11, 21, 68 )
  oBoxCompany:Frame := BORDER_NONE
  oBoxCompany:Color := color5

  // ������� ����
  oBox := NIL // 㭨�⮦�� ����
  oBox := TBox():New( 2, 10, 22, 70 )
	oBox:Color := color_say + ',' + color_get
	oBox:Frame := BORDER_DOUBLE
  oBox:MessageLine := '^^ ��� ���.�㪢� - ��ᬮ��;  ^<Esc>^ - ��室;  ^<Enter>^ - �롮�'
  oBox:Save := .t.

  oBoxRegion:MessageLine := '^^ ��� ���.�㪢� - ��ᬮ��;  ^<Esc>^ - ��室;  ^<Enter>^ - �롮�'
  oBoxRegion:Save := .t.
  oBoxRegion:View()
  nRegion := AChoice( oBoxRegion:Top + 1, oBoxRegion:Left + 1, oBoxRegion:Bottom - 1, oBoxRegion:Right - 1, ar, , , 34 )
  if nRegion == 0
    (dbName)->(dbCloseArea())
    (tmpAlias)->(dbCloseArea())
    select (tmp_select)
    return retMCOD
  else
    selectedRegion  := ar_f010[nRegion, 2]
  endif
  fl_other_region := .f.

  // ᮧ����� �६���� 䠩� ��� �⡮� �࣠����権 ��࠭���� ॣ����
  dbCreate(tmpName, aStruct)
  dbUseArea( .t.,, tmpName, tmpAlias, .t., .f. )
        
  (dbName)->(dbGoTop())
  (dbName)->(dbSeek(selectedRegion))
  do while substr((dbName)->MCOD, 1, 2) == selectedRegion
    (tmpAlias)->(dbAppend())
    (tmpAlias)->MCOD := (dbName)->MCOD
    (tmpAlias)->NAMEMOK := (dbName)->NAMEMOK
    (tmpAlias)->NAMEMOP := (dbName)->NAMEMOP
    (tmpAlias)->ADDRESS := (dbName)->ADDRESS
    (tmpAlias)->YEAR := (dbName)->YEAR
        
    (dbName)->(dbSkip())
  enddo
                
  oBox:Caption := '�롮� ���ࠢ��襩 �࣠����樨'
  oBox:View()
  dbCreateIndex( tmpName, 'NAMEMOK', , NIL )

  (tmpAlias)->(dbGoTop())
  if fl := Alpha_Browse(oBox:Top + 1, oBox:Left + 1, oBox:Bottom - 5, oBox:Right - 1, 'ColumnF003', color0, , , , , , 'ViewRecordF003', 'controlF003', , {'�', '�', '�', 'N/BG, W+/N, B/BG, BG+/B'} )
    // �஢��塞 �롮�
    if (ifi := hb_ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == (tmpAlias)->MCOD }, , , .t.) ) > 0
      // ��諨 � 䠩��
      alert('����樭᪮� ��०����� 㦥 ��������� � �ࠢ�筨�!')
    else
      if G_Use(dir_server + sbase, dir_server + sbase, sbase, , .t.,)
        (sbase)->(dbGoTop())
        do while ! (sbase)->(Eof())
          prev_codem := (sbase)->CODEM
          (sbase)->(dbSkip())
          cur_codem := (sbase)->CODEM
          if (val(cur_codem) - val(prev_codem)) != 1
            (sbase)->(dbappend())
            (sbase)->MCOD := (tmpAlias)->MCOD
            (sbase)->CODEM := str(val(prev_codem) + 1, 6)
            (sbase)->NAMEF := (tmpAlias)->NAMEMOK
            (sbase)->NAMES := (tmpAlias)->NAMEMOP
            (sbase)->ADRES := (tmpAlias)->ADDRESS
            (sbase)->DEND := hb_SToD('20251231')
            exit
          endif
        enddo
        (sbase)->(dbCloseArea())
        retMCOD := { str(val(prev_codem) + 1, 6), AllTrim((tmpAlias)->NAMEMOK) }
      endif
    endif
        
  endif
  selectedRegion := ''

  oBoxRegion := NIL
  oBoxCompany := nil
  oBox := nil
  (tmpAlias)->(dbCloseArea())
  (dbName)->(dbCloseArea())
  select (tmp_select)
  return retMCOD

// 15.10.21
Function controlF003(nkey, oBrow)
  Local ret := -1, cCode, rec

  return ret
    
// 15.10.21
Function ColumnF003(oBrow)
  Local oColumn
  
  oColumn := TBColumnNew(center('������������', 50), {|| left((tmpAlias)->NAMEMOK, 50)})
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ - ��室; ^<Enter>^ - �롮�')
  return nil

// 21.01.21
Function ViewRecordF003()
  Local i, arr := {}, count

  if ! oBoxCompany:Visible
    oBoxCompany:View()
  else
    oBoxCompany:Clear()
  endif
  // ࠧ��쥬 ������ ����������� �� �����ப�
  // perenos(arr,(tmpAlias)->NAMEMOP,50)
  perenos(arr, (tmpAlias)->NAMEMOP, oBoxCompany:Width)
  count := iif(len(arr) > oBoxCompany:Height, oBoxCompany:Height, len(arr))

  for i := 1 to count
    @ oBoxCompany:Top + i - 1, oBoxCompany:Left + 1 say arr[i]
  next
  
  return nil

// 15.10.21
Function getF003mo(mCode)
  // mCode - ��� �� �� F003
  Local arr, dbName := '_mo_f003', indexName := cur_dir + dbName + 'cod'
  local tmp_select := Select()
  Local i // ����� ��ࢮ� �� ���浪� ��

  if SubStr(mCode,1,2) != '34'

    arr := aclone(glob_arr_mo[1])
    if empty(mCode) .or. (Len(mCode) != 6)
      for i := 1 to len(arr)
        if valtype(arr[i]) == 'C'
          arr[i] := space(6) // � ���⨬ ��ப��� ������
        endif
      next
      Select(tmp_select)
      return arr
    endif

    arr := array(_MO_LEN_ARR)

    dbUseArea( .t., 'DBFNTX', exe_dir + dbName, dbName, .t., .f. )
    (dbName)->(dbCreateIndex( indexName, 'MCOD', , NIL ))

    (dbName)->(dbGoTop())
    if (dbName)->(dbSeek(mCode))
      arr[_MO_KOD_FFOMS]  := (dbName)->MCOD
      arr[_MO_KOD_TFOMS]  := ''
      arr[_MO_FULL_NAME]  := AllTrim((dbName)->NAMEMOP)
      arr[_MO_SHORT_NAME] := AllTrim((dbName)->NAMEMOK)
      arr[_MO_ADRES]      := AllTrim((dbName)->ADDRESS)
      arr[_MO_PROD]       := ''
      arr[_MO_DEND]       := ctod('01-01-2021')
      arr[_MO_STANDART]   := 1
      arr[_MO_UROVEN]     := 1
      arr[_MO_IS_MAIN]    := .t.
      arr[_MO_IS_UCH]     := .t.
      arr[_MO_IS_SMP]     := .t.
    endif
    (dbName)->(dbCloseArea())
  else
    arr := aclone(glob_arr_mo[1])
    for i := 1 to len(arr)
      if valtype(arr[i]) == 'C'
        arr[i] := space(6) // � ���⨬ ��ப��� ������
      endif
    next
    if !empty(mCode)
      if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == mCode })) > 0
        arr := glob_arr_mo[i]
      elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == mCode })) > 0
        arr := glob_arr_mo[i]
      endif
    endif
  endif
  Select(tmp_select)
  return arr

// =========== F005 ===================
//
// 27.02.21 ������ ���ᨢ �����䨪��� ����ᮢ ������ ����樭᪮� ����� F005.xml
function getF005()
  // F005.xml - �����䨪��� ����ᮢ ������ ����樭᪮� �����
  //  1 - STNAME(C)  2 - IDIDST(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'�� �ਭ�� �襭�� �� �����', 0, stod('20110101'), stod('')})
    aadd(_arr, {'����祭�', 1, stod('20110101'), stod('')})
    aadd(_arr, {'�� ����祭�', 2, stod('20110101'), stod('')})
    aadd(_arr, {'����筮 ����祭�', 3, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F006 ===================
//
// 19.12.22 ������ ���ᨢ �����䨪��� ����� ����஫� F006.xml
function getF006()
  // F006.xml - �����䨪��� ����� ����஫�
  // IDVID,     "N",   2, 0  // ��� ���� ����஫�
  // VIDNAME,   "C", 350, 0  // ������������ ���� ����஫�
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0  // ��� ����砭�� ����⢨� �����

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT idvid, vidname, datebeg, dateend FROM f006')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F007 ===================
//
// 27.02.21 ������ ���ᨢ �����䨪��� ������⢥���� �ਭ��������� ����樭᪮� �࣠����樨 F007.xml
function getF007()
  // F007.xml - �����䨪��� ������⢥���� �ਭ��������� ����樭᪮� �࣠����樨
  //  1 - VEDNAME(C)  2 - IDVED(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'�㭨樯��쭮�� ��ࠧ������', 1, stod('20110101'), stod('')})
    aadd(_arr, {'��ꥪ� ���ᨩ᪮� �����樨', 2, stod('20110101'), stod('')})
    aadd(_arr, {'�����ࠢ��ࠧ���� ���ᨨ', 3, stod('20110101'), stod('')})
    aadd(_arr, {'�����ୠ㪨 ���ᨨ', 4, stod('20110101'), stod('')})
    aadd(_arr, {'������஭� ���ᨨ', 5, stod('20110101'), stod('')})
    aadd(_arr, {'��� ���ᨨ', 6, stod('20110101'), stod('')})
    aadd(_arr, {'������ ���ᨨ ����', 7, stod('20110101'), stod('')})
    aadd(_arr, {'��� ���ᨨ', 8, stod('20110101'), stod('')})
    aadd(_arr, {'����', 9, stod('20110101'), stod('')})
    aadd(_arr, {'���� ���ᨨ', 10, stod('20110101'), stod('')})
    aadd(_arr, {'���� 䥤�ࠫ��� ��������� � �������', 11, stod('20110101'), stod('')})
    aadd(_arr, {'��� ��� "���"', 12, stod('20110101'), stod('')})
    aadd(_arr, {'��⮭���� ��', 13, stod('20110101'), stod('')})
    aadd(_arr, {'����⢥����, ५�������� �࣠����権', 14, stod('20110101'), stod('')})
    aadd(_arr, {'���', 15, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F008 ===================
//
// 27.02.21 ������ �����䨪��� ⨯�� ���㬥�⮢, ���⢥ত���� 䠪� ���客���� �� ��� F008.xml
function getF008()
  // F008.xml - �����䨪��� ⨯�� ���㬥�⮢, ���⢥ত���� 䠪� ���客���� �� ���
  //  1 - DOCNAME(C)  2 - IDDOC(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'����� ��� ��ண� ��ࠧ�', 1, stod('20110101'), stod('')})
    aadd(_arr, {'�६����� ᢨ��⥫��⢮, ���⢥ত��饥 ��ଫ���� ����� ��易⥫쭮�� ����樭᪮�� ���客����', 2, stod('20110101'), stod('')})
    aadd(_arr, {'����� ��� ������� ��ࠧ�', 3, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F009 ===================
//
// 27.02.21 ������ �����䨪��� ����� �����客������ ��� F009.xml
function getF009()
  // F009.xml - �����䨪��� ����� �����客������ ���
  //  1 - StatusName(C)  2 - IDStatus(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {'������騩', 1, stod('20110101'), stod('')})
    aadd(_arr, {'��ࠡ���騩', 2, stod('20110101'), stod('')})
  endif

  return _arr

// =========== F010 ===================
//
// 17.12.22 ������ ���ᨢ ॣ����� �� �ࠢ�筨�� ॣ����� ����� F010.xml
function getf010()
  // F010.xml - �����䨪��� ��ꥪ⮢ ���ᨩ᪮� �����樨
  // KOD_TF,       "C",      2,      0  // ��� �����
  // KOD_OKATO,     "C",    5,      0  // ��� �� ����� (�ਫ������ � O002).
  // SUBNAME,     "C",    254,      0  // ������������ ��ꥪ� ��
  // OKRUG,     "N",        1,      0  // ��� 䥤�ࠫ쭮�� ���㣠
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0   // ��� ����砭�� ����⢨� �����

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT subname, kod_tf, okrug, kod_okato, datebeg, dateend FROM f010')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), alltrim(aTable[nI, 2]), val(aTable[nI, 3]), alltrim(aTable[nI, 4]), ctod(aTable[nI, 5]), ctod(aTable[nI, 6])})
      next
    endif
    db := nil
    aadd(_arr, {'����ࠫ쭮�� ���稭����', '99', 0})
    if hb_FileExists(exe_dir + 'f010' + sdbf)
      FErase(exe_dir + 'f010' + sdbf)
    endif
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F011 ===================
//
// 19.12.22 ������ �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮��� F011.xml
function getF011()
  // F011.xml - �����䨪��� ⨯�� ���㬥�⮢, 㤮�⮢������ ��筮���
  // IDDoc,     "C",   2, 0  // ��� ⨯� ���㬥��
  // DocName,   "C", 254, 0  // ������������ ⨯� ���㬥��
  // DocSer,    "C",  10, 0  // ��᪠ �ਨ ���㬥��
  // DocNum,    "C",  20, 0  // ��᪠ ����� ���㬥��
  // DATEBEG,   "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND,   "D",   8, 0  // ��� ����砭�� ����⢨� �����

  static _arr := {}
  local db
  local aTable
  local nI

  if len(_arr) == 0
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table( db, 'SELECT docname, iddoc, datebeg, dateend, docser, docnum FROM f011')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 1]), val(aTable[nI, 2]), ctod(aTable[nI, 3]), ctod(aTable[nI, 4]), alltrim(aTable[nI, 5]), alltrim(aTable[nI, 6])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F012 ===================
//
// 27.02.21 ������ ��ࠢ�筨� �訡�� �ଠ⭮-�����᪮�� ����஫� F012.xml
function getF012()
  // F012.xml - ��ࠢ�筨� �訡�� �ଠ⭮-�����᪮�� ����஫�
  //  1 - Opis(C)  2 - Kod(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - DopInfo(C)
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"�訡��� ���冷� ⥣��",901,stod("20110101"),stod(""),"����襭 ���冷� ᫥������� ⥣��, ���� ��������� ��易⥫�� ⥣."})
    aadd(_arr, {"��������� ��易⥫쭮� ����",902,stod("20110101"),stod(""),"��������� ���祭�� � ��易⥫쭮� ⥣�."})
    aadd(_arr, {"������ ⨯ ������",903,stod("20110101"),stod(""),"����������� ���� ᮤ�ন� �����, �� ᮮ⢥�����騥 ��� ⨯�."})
    aadd(_arr, {"������ ���",904,stod("20110101"),stod(""),"���祭�� �� ᮮ⢥����� �����⨬���."})
    aadd(_arr, {"�㡫� ���祢��� �����䨪���",905,stod("20110101"),stod(""),"�������� ��� 㦥 �ᯮ�짮����� � ������ 䠩��."})
    aadd(_arr, {"������ �ଠ� �����",801,stod("20110101"),stod(""),"����� �� 㯠����� � ��娢 �ଠ� zip."})
    aadd(_arr, {"����୮� ��� �����",802,stod("20110101"),stod(""),"��� ����� �� ᮮ⢥����� ���㬥��樨"})
    aadd(_arr, {"� ����� ᮤ�ঠ��� �� �� 䠩��",803,stod("20110101"),stod(""),"���� ��� ��� 䠩�� �� ������� � zip ��娢�"})
    aadd(_arr, {"����୮� ���祭�� �����",804,stod("20110101"),stod(""),"����୮� ���祭�� �����"})
    aadd(_arr, {"����� � ⠪�� ������ �� ��ॣ����஢�� ࠭��",805,stod("20110101"),stod(""),"����� � ⠪�� ������ �� ��ॣ����஢�� ࠭��"})
  endif

  return _arr

// =========== F014 ===================
//
// 19.05.23 ������ ���ᨢ �ࠢ�筨�� ����� F014.xml
function getF014()
  // F014.xml - �����䨪��� ��稭 �⪠�� � ����� ����樭᪮� �����
  // Kod,     "N",   3, 0  // ��� �訡��
  // IDVID,   "N",   1, 0  // ��� ���� ����஫�, १�ࢭ�� ����
  // Naim,    "C",1000, 0  // ������������ ��稭� �⪠��
  // Osn,     "C",  20, 0  // �᭮����� �⪠��
  // Komment, "C", 100, 0  // ��㦥��� �������਩
  // KodPG,   "C",  20, 0  // ��� �� �ଥ N ��
  // DATEBEG, "D",   8, 0  // ��� ��砫� ����⢨� �����
  // DATEEND, "D",   8, 0   // ��� ����砭�� ����⢨� �����

  // �����頥� ���ᨢ
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    Set(_SET_DATEFORMAT, 'yyyy-mm-dd')
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT ' + ;
      'kod, ' + ;
      'osn, ' + ;
      'naim, ' + ;
      'komment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM f014')
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        aadd(_arr, {val(aTable[nI, 1]), ;
          alltrim(aTable[nI, 1]) + ' (' + alltrim(aTable[nI, 2]) + ') ' + alltrim(aTable[nI, 3]), ;
          alltrim(aTable[nI, 4]), ;
          alltrim(aTable[nI, 2])})
      next
    endif
    db := nil
    Set(_SET_DATEFORMAT, 'dd.mm.yyyy')
  endif
  return _arr

// =========== F015 ===================
//
// 17.02.21 ������ ���ᨢ �ࠢ�筨�� ����� F015.xml
function getF015()
  // F015.xml - �����䨪��� 䥤�ࠫ��� ���㣮�
  //  1 - OKRNAME(C)  2 - KOD_OK(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  local dbName := "f015"
  static _arr := {}

  if len(_arr) == 0
    aadd(_arr, {"����ࠫ�� 䥤�ࠫ�� ����",1,stod("20110101"),stod("")})
    aadd(_arr, {"���� 䥤�ࠫ�� ����",2,stod("20110101"),stod("")})
    aadd(_arr, {"�����-������� 䥤�ࠫ�� ����",3,stod("20110101"),stod("")})
    aadd(_arr, {"���쭥������ 䥤�ࠫ�� ����",4,stod("20110101"),stod("")})
    aadd(_arr, {"�����᪨� 䥤�ࠫ�� ����",5,stod("20110101"),stod("")})
    aadd(_arr, {"�ࠫ�᪨� 䥤�ࠫ�� ����",6,stod("20110101"),stod("")})
    aadd(_arr, {"�ਢ���᪨� 䥤�ࠫ�� ����",7,stod("20110101"),stod("")})
    aadd(_arr, {"�����-������᪨� 䥤�ࠫ�� ����",8,stod("20110101"),stod("")})
    aadd(_arr, {"-",0,stod("20110101"),stod("")})
  endif

  return _arr
