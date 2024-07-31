#include 'function.ch'
#include 'common.ch'
#include 'hbhash.ch' 

#require 'hbsqlit3'

// 13.07.24
function getPCEL_usl( shifr )

  local ret := ''
  local lshifr := alltrim( shifr )
  local aHash := loadUsl_pcel()

  if hb_hHaskey( aHash, lshifr )
    ret := aHash[ lshifr ]
  endif
  return ret

// 13.07.24 ������ ���ᨢ �� �ࠢ�筨�� usl_p_cel (ᮮ⢥��⢨� ��㣨 楫� ���饭��)
function loadUsl_pcel()

  static arr
  local db
  local aTable
  local nI

  if isnil( arr )
    arr := hb_hash()
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT shifr, p_cel FROM usl_p_cel')
    
//    if len(aTable) > 1
//      for nI := 2 to Len( aTable )
//        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1])})
//      next
//    endif
    if len(aTable) > 1
      for nI := 2 to Len(aTable)
        hb_hSet(arr, alltrim( aTable[ nI, 1 ] ), alltrim( aTable[ nI, 2 ] ) )
      next
    endif

    db := nil
  endif
  return arr

// 28.03.23 ������ ���ᨢ �� �ࠢ�筨�� dlo_lgota
function getDLO_lgota()
  // dlo_lgota - �����䨪��� ����� �죮� �� ���
  //  1 - KOD(C) 2 - NAME(C)
  static _arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    _arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT kod, name FROM dlo_lgota')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(_arr, {alltrim(aTable[nI, 2]), alltrim(aTable[nI, 1])})
      next
    endif
    db := nil
  endif
  return _arr

// 30.03.23
function get_err_csv_prik()
  static arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT kod, name FROM err_csv_prik')
    
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(arr, {alltrim(aTable[nI, 2]), val(aTable[nI, 1])})
      next
    endif
    db := nil
  endif

  return arr

// 31.03.23
function get_rekv_SMO()
  static arr
  static time_load
  local db
  local aTable
  local nI

  if timeout_load(@time_load)
    arr := {}
    db := openSQL_DB()
    aTable := sqlite3_get_table(db, 'SELECT kod, name, inn, kpp, ogrn, addres FROM rekv_smo')
    if len(aTable) > 1
      for nI := 2 to Len( aTable )
        aadd(arr, {aTable[nI, 1], alltrim(aTable[nI, 2]), aTable[nI, 3], aTable[nI, 4], ;
          aTable[nI, 5], alltrim(aTable[nI, 6]), '', '', ''})
      next
    endif
    db := nil
  endif

  return arr

// 30.03.23
function getNMIC()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {' ����樭᪠� �࣠������ ������ࠤ� (������ࠤ᪮� ������)'               , 0})
    aadd(arr, {' 1 ���� ��������� ��.�.�.���娭�'                                          , 1})
    aadd(arr, {' 2 ���� ��.�.�.��������'                                                   , 2})
    aadd(arr, {' 3 ���� �थ筮-��㤨�⮩ ���ࣨ� ��.�.�.���㫥��'                      , 3})
    aadd(arr, {' 4 ���� ���஢�� ��⥩'                                                    , 4})
    aadd(arr, {' 5 ���� ������⢠, ����������� � ��ਭ�⮫���� ��.��������� �.�.�㫠����' , 5})
    aadd(arr, {' 6 ���� ࠤ�������'                                                        , 6})
    aadd(arr, {' 7 ���� ���᪮� ����⮫����, ��������� � ���㭮����� ��.������ ����祢�'  , 7})
    aadd(arr, {' 8 ���� ��娠�ਨ � ��મ����� ��.�.�.���᪮��'                          , 8})
    aadd(arr, {' 9 ���� ��न������'                                                       , 9})
    aadd(arr, {'10 ���� ��.��������� �.�.��蠫����'                                        ,10})
    aadd(arr, {'11 ���� ����������� � ���஡������� ��.���⭮�� ��������� �.�.�������'  ,11})
    aadd(arr, {'12 ���� ��䨫����᪮� ����樭�'                                         ,12})
    aadd(arr, {'13 ���� ���ਭ������'                                                    ,13})
    aadd(arr, {'14 ���� ��������� ��.�.�.���஢�'                                          ,14})
    aadd(arr, {'15 ���� ॠ�����樨 � ����⮫����'                                       ,15})
    aadd(arr, {'16 ���� ����⮫����'                                                       ,16})
    aadd(arr, {'17 ���� ��娠�ਨ � ���஫���� ��.�.�.����ॢ�'                          ,17})
    aadd(arr, {'18 ���� �������ࣨ� ��.��������� �.�.��थ���'                           ,18})
    aadd(arr, {'19 ���� �ࠢ��⮫���� � ��⮯���� ��.�.�.�ਮ஢�'                         ,19})
    aadd(arr, {'20 ���� �࠭ᯫ��⮫���� � �����⢥���� �࣠��� ��.��������� �.�.�㬠����',20})
    aadd(arr, {'21 ���� ���ࣨ� ��.�.�.��譥�᪮��'                                       ,21})
    aadd(arr, {'22 ���� ���� "�������ࣨ� �����" ��.��������� �.�.����஢�'              ,22})
    aadd(arr, {'23 ���� �⨧����쬮������� � ��䥪樮���� �����������'                    ,23})
    aadd(arr, {'24 ���� ������� �������� ����� ���쬣����'                                ,24})
    aadd(arr, {'25 ����� �� "��祭��᪨� ���������"'                                     ,25})
    aadd(arr, {'26 ���� �� �.�. ��ண���'                                                  ,26})
    aadd(arr, {'27 ����� ��᪮�᪨� ���.������-�⮠�⮫����᪨� �-� ��.�.�.����������'   ,27})
    aadd(arr, {'28 ����� �����-������᪨� ���.��������᪨� ����樭᪨� 㭨������'   ,28})
    aadd(arr, {'29 ���� �ࠢ��⮫���� � ��⮯���� ����� �.�. �।���'                      ,29})
    aadd(arr, {'30 ���� �ࠢ��⮫���� � ��⮯���� ����� ��������� �.�. �����஢�'          ,30})
    aadd(arr, {'31 ���� ���᪮� �ࠢ��⮫���� � ��⮯���� ����� �.�. ��୥�'              ,31})
    aadd(arr, {'32 ���� ���������'                                                         ,32})
    aadd(arr, {'33 ���� �⮬�⮫���� � 祫��⭮-��楢�� ���ࣨ�'                          ,33})
    aadd(arr, {'34 ���� ��祡��-ॠ�����樮��� 業��'                                    ,34})
    aadd(arr, {'35 ���� �����ப⮫���� ��. �.�. �릨�'                                    ,35})
    aadd(arr, {'36 ���� ��ਭ���ਭ������� ����'                                          ,36})
  endif
  
  return arr

// 30.03.23
function getParOrgan()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'1 �ࠢ�� ������ ����筮���', 1})
    aadd(arr, {'2 ����� ������ ����筮���', 2})
    aadd(arr, {'3 �ࠢ�� ������ ����筮���', 3})
    aadd(arr, {'4 ����� ������ ����筮��', 4})
    aadd(arr, {'5 �ࠢ�� ����筠� ������', 5})
    aadd(arr, {'6 ����� ����筠� ������', 6})
    aadd(arr, {'7 �ࠢ� ����, �ਤ�⪨ �����', 7})
    aadd(arr, {'8 ���� ����, �ਤ�⪨ �����', 8})
    aadd(arr, {'9 �ࠢ�� ��஭�', 9})
    aadd(arr, {'10 ����� ��஭�', 10})
    aadd(arr, {'11 ��� (�ࠢ�� ��஭�)', 11})
    aadd(arr, {'12 ��� (����� ��஭�)', 12})
    aadd(arr, {'13 ��㤭�� ���⪠ (�ࠢ�� ��஭�)', 13})
    aadd(arr, {'14 ��㤭�� ���⪠ (����� ��஭�)', 14})
    aadd(arr, {'15 ������ 祫����', 15})
    aadd(arr, {'16 ������ 祫����', 16})
    aadd(arr, {'17 �������筨�', 17})
    aadd(arr, {'18 ��㤨��', 18})
  endif

  return arr

// 30.03.23
function getPrichInv()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'��饥 �����������', 1})
    aadd(arr, {'��㤮��� 㢥��', 2})
    aadd(arr, {'����ᨮ���쭮� �����������', 3})
    aadd(arr, {'������������ � ����⢠', 4})
    aadd(arr, {'������������ � ����⢠ �᫥��⢨� ࠭���� (����� ����⢨� � ��ਮ� ���)', 5})
    aadd(arr, {'������� �ࠢ��', 6})
    aadd(arr, {'����������� ����祭� � ��ਮ� ������� �㦡�', 7})
    aadd(arr, {'����������� ࠤ��樮���� (�� �ᯮ������ ������� �㦡�) �� ��୮���᪮� ���', 8})
    aadd(arr, {'����������� �易�� � ������䮩 �� ��୮���᪮� ���', 9})
    aadd(arr, {'����������� (��� ��易����� �ᯮ������ ������� �㦡�) �� ��୮���᪮� ���', 10})
    aadd(arr, {'����������� �易�� � ���ਥ� �� �� "���"', 11})
    aadd(arr, {'����������� (��� ��易����� �ᯮ������ ������� �㦡�) �� �� "���"', 12})
    aadd(arr, {'����������� �易�� � ��᫥��⢨ﬨ ࠤ��樮���� �������⢨�', 13})
    aadd(arr, {'����������� ࠤ��樮���� (�� �ᯮ������ ������� �㦡�) ���ࠧ�.�ᮡ��� �᪠', 14})
    aadd(arr, {'����������� (࠭����) �� ���㦨������� �/� �� ���� � ��, ������ �� �㡥���', 15})
    aadd(arr, {'��� ��稭�, ��⠭������� ��������⥫��⢮� ��', 16})
  endif

  return arr

// 29.03.23
function getVidUd()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'��ᯮ�� �ࠦ�.����', 1, 1, '�������'})
    aadd(arr, {'���࠭���.�ࠦ�.����', 2, 0, '���������'})
    aadd(arr, {'����-�� � ஦����� (��)', 3, 1, '�-�� � ஦.��'})
    aadd(arr, {'��-��� ��筮�� ����', 4, 0, '����� �������'})
    aadd(arr, {'��ࠢ�� �� �᢮��������', 5, 1, '������� �� ���'})
    aadd(arr, {'��ᯮ�� ������䫮�', 6, 0, '������� ������'})
    aadd(arr, {'������ �����', 7, 0, '������� �����'})
    aadd(arr, {'����.��ᯮ�� �ࠦ�.��', 8, 0, '���������� ��'})
    aadd(arr, {'�����࠭�� ��ᯮ��', 9, 1, '������ �������'})
    aadd(arr, {'�����⥫��⢮...������', 10, 0, '���� �������'})
    aadd(arr, {'��� �� ��⥫��⢮', 11, 1, '��� �� ������'})
    aadd(arr, {'�����-�� ������ � ��', 12, 1, '����� �������'})
    aadd(arr, {'�६.�.���.�ࠦ�.��', 13, 1, '���� �����'})
    aadd(arr, {'��ᯮ�� �ࠦ�.���ᨨ', 14, 1, '��ᯮ�� ���ᨨ'})
    aadd(arr, {'���࠭���.�ࠦ�.��', 15, 1, '�������� ��'})
    aadd(arr, {'��ᯮ�� ���猪', 16, 0, '������� ������'})
    aadd(arr, {'������ ����� ��.�����', 17, 0, '���� ����� ��'})
    aadd(arr, {'��� ���㬥���', 18, 1, '������'})
    aadd(arr, {'���-� ����.�ࠦ������', 21, 0, '������ �������'})
    aadd(arr, {'���-� ��� ��� �ࠦ����⢠', 22, 0, '���� ��� �����'})
    aadd(arr, {'����-�� �� �६.�஦������', 23, 0, '���� �� ��.��.'})
    aadd(arr, {'����-�� � ஦�.(�� � ��)', 24, 0, '�.� ஦.�� ��'})
  endif
  
  return arr

// 30.03.23
function get_Name_Vid_Ud(vid_doc, lFull, suffics)
  local ret := '', j

	HB_Default( @vid_doc, 0 ) 
	HB_Default( @lFull, .f. ) 
	HB_Default( @suffics, '' ) 

  if (j := ascan(getVidUd(), {|x| x[2] == vid_doc})) > 0
    ret := getVidUd()[j, iif(lFull, 1, 4)] + suffics
  endif

  return ret

// 30.03.23 �᭮����� �ॡ뢠��� � ��
function get_osn_preb_RF()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'�� (��� �� ��⥫��⢮)', 1})
    aadd(arr, {'��� (ࠧ�襭�� �� �६������ �ॡ뢠���)', 0})
    aadd(arr, {'����樮���� ����', 2})
    aadd(arr, {'������᪠� ����', 3})
    aadd(arr, {'����樭᪠� ����', 4})
    aadd(arr, {'���⥢�� ����', 5})
    aadd(arr, {'������� ����', 6})
    aadd(arr, {'�࠭��⭠� ����', 7})
    aadd(arr, {'��㤥��᪠� ����', 8})
    aadd(arr, {'������ ����', 9})
    aadd(arr, {'��㣠� ����', 10})
  endif
  return arr

// 11.07.24
function get_bukva()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'A-���㫠�୮-����������᪠� ������ (A)'    , 'A'})
    aadd(arr, {'B-��� � �஬������᪮� �࠯���'           , 'B'})
    aadd(arr, {'D-��ᯠ��ਧ��� ��⥩-��� (��樮�����)', 'D'})
    aadd(arr, {'E-᪮�� ����樭᪠� ������'                 , 'E'})
    aadd(arr, {'F-��䨫����᪨� �ᬮ�� ��ᮢ��襭����⭨�', 'F'})
    aadd(arr, {'G-��ଠ⮢���஫����᪠� ������'            , 'G'})
    aadd(arr, {'H-��᮪��孮����筠� ����樭᪠� ������'    , 'H'})
    aadd(arr, {'I-���. ९த�⨢���� ���஢�� ���� �⠯', 'I'})
    aadd(arr, {'J-���㫠�୮-����������᪠� ������'        , 'J'})
    aadd(arr, {'K-�⤥��� ����樭᪨� ��㣨'              , 'K'})
    aadd(arr, {'M-�����祭�� ��砩 � ��樮��� (1.7.*)'   , 'M'})
    aadd(arr, {'N-��樮��ୠ� ������/�������⥫�� �����' , 'N'})
    aadd(arr, {'O-��ᯠ��ਧ��� ���᫮�� ��ᥫ����'       , 'O'})
    aadd(arr, {'R-��䨫��⨪� ���᫮�� ��ᥫ����'          , 'R'})
    aadd(arr, {'S-��樮��ୠ� ������'                       , 'S'})
    aadd(arr, {'T-�⮬�⮫����᪠� ������'                  , 'T'})
    aadd(arr, {'U-��ᯠ��ਧ��� ��⥩-��� (��� ������)'  , 'U'})
    aadd(arr, {'V-���. ९த�⨢���� ���஢�� ��ன �⠯', 'V'})
    aadd(arr, {'W-㣫㡫����� ��ᯠ��ਧ��� ���� �⠯'   , 'W'})
    aadd(arr, {'Y-㣫㡫����� ��ᯠ��ਧ��� ��ன �⠯'   , 'Y'})
    aadd(arr, {'Z-������� ��樮���'                         , 'Z'})
  endif

  return arr

// 30.03.23 ᯨ᮪ ��稭 �� ��ᯨ⠫����� ��樥��
function get_reason_annul()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'1-������⢨� ��������� ��� ��ᯨ⠫���樨',1})
    aadd(arr, {'2-���।�⠢����� ����室����� ����� ���㬥�⮢ (�⪠� ��樮���)',2})
    aadd(arr, {'3-���樠⨢�� �⪠� �� ��ᯨ⠫���樨 ��樥�⮬',3})
    aadd(arr, {'4-�⪠� �� ��ᯨ⠫���樨 �� �����������᪨� ���������', 4})
    aadd(arr, {'5-��࠭⨭ � ��樮��୮� �⤥�����', 5})
    aadd(arr, {'6-���ࠢ����� �����客������ ��� �� �� ��䨫� �����������', 6})
    aadd(arr, {'7-��� ��樥�� �� ��ᯨ⠫�����', 7})
    aadd(arr, {'8-ᬥ��� �� ��ᯨ⠫���樨', 8})
    aadd(arr, {'9-��稥 ��稭�', 9})
  endif
  return arr

// 31.03.23  ��� ��⥣�ਨ �죮��
function get_stm_kategor()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'�������� �����', 1, 1})
    aadd(arr, {'���⭨�� ������� ����⢥���� �����', 2, 2})
    aadd(arr, {'���࠭� ������ ����⢨� (����� �5-�� �� 12.01.95�. "� ���࠭��")', 8, 3})
    aadd(arr, {'�������㦠騥 �� �� �������饩 �ନ� (��ਮ� 22.06.41-03.09.45)', 5, 4})
    aadd(arr, {'���, ���ࠦ��� ������ "��⥫� ���������� ������ࠤ�"', 4, 5})
    aadd(arr, {'���, ࠡ�⠢訥 � ��ਮ� ��� �� ��ꥪ�� ��� � �.�.', 14, 6})
    aadd(arr, {'童�� ᥬ�� ������� (㬥���) ��������� �����, ����, ���࠭��...', 3, 7})
    aadd(arr, {'��������', 6, 8})
    aadd(arr, {'���-��������', 7, 9})
    aadd(arr, {'����.ࠤ.�����.', 9, 0})
    aadd(arr, {'����.ࠤ.�����.(����)', 91, 0})
    aadd(arr, {'����.ࠤ.���.(���.�.)', 92, 0})
    aadd(arr, {'����.ࠤ.�����.(��.)', 93, 0})
    aadd(arr, {'��������஢����', 10, 0})
    aadd(arr, {'�����⮪', 11, 0})
    aadd(arr, {'������� �� ����', 12, 0})
    aadd(arr, {'��稥', 13, 13})
  endif
  return arr