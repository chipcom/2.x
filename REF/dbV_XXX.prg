#include 'hbhash.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// =========== V002 ===================
//
#define V002_IDPR     1
#define V002_PRNAME   2
#define V002_DATEBEG  3
#define V002_DATEEND  4

// 23.01.23 ������ ���ᨢ �� �ࠢ�筨�� ॣ����� ����� V002.xml
Function getv002( work_date )

  // V002.dbf - �����䨪��� ��䨫�� ��������� ����樭᪮� �����
  // 1 - PRNAME(C)  2 - IDPR(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idpr, ' + ;
      'prname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v002' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, V002_PRNAME ] ), Val( aTable[ nI, V002_IDPR ] ), CToD( aTable[ nI, V002_DATEBEG ] ), CToD( aTable[ nI, V002_DATEEND ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// =========== V004 ===================
//
// 20.12.24 ������ ���ᨢ �� �ࠢ�筨�� ॣ����� ����� V004.xml
Function getv004_new()

  // V004.xml - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
  // MSPNAME(C), IDMSP(N), DATEBEG(D), DATEEND(D)
  Static _arr := {}
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'mspname, ' + ;
      'idmsp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v004' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), Val( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  return _arr

// 22.10.22 ������ ���ᨢ �� �ࠢ�筨�� ॣ����� ����� V004.xml
Function getv004()

  // V004.xml - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
  // 1 - MSPNAME(C)  2 - IDMSP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { '���襥 ����樭᪮� ��ࠧ������', 1, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� ����. ��������', 11, date_20110101, empty_date } )
    AAdd( _arr, { '������⢮ � �����������', 1101, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 110101, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 110102, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 110103, date_20110101, empty_date } )
    AAdd( _arr, { '����᪮���', 110104, date_20110101, empty_date } )
    AAdd( _arr, { '����⥧������� � ॠ����⮫����', 1103, date_20110101, empty_date } )
    AAdd( _arr, { '���ᨪ������', 110301, date_20110101, empty_date } )
    AAdd( _arr, { '�࠭��㧨������', 110302, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 110303, date_20110101, empty_date } )
    AAdd( _arr, { '��ଠ⮢���஫����', 1104, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ���������', 110401, date_20110101, empty_date } )
    AAdd( _arr, { '����⨪�', 1105, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 110501, date_20110101, empty_date } )
    AAdd( _arr, { '��䥪樮��� �������', 1106, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ���������', 110601, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ������ୠ� �������⨪�', 1107, date_20110101, empty_date } )
    AAdd( _arr, { '����ਮ�����', 110701, date_20110101, empty_date } )
    AAdd( _arr, { '����᮫����', 110702, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 110703, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ���������', 110704, date_20110101, empty_date } )
    AAdd( _arr, { '���஫����', 1109, date_20110101, empty_date } )
    AAdd( _arr, { '���㠫쭠� �࠯��', 110901, date_20110101, empty_date } )
    AAdd( _arr, { '��䫥���࠯��', 110902, date_20110101, empty_date } )
    AAdd( _arr, { '����⠭���⥫쭠� ����樭�', 110903, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������ � ᯮ�⨢��� ����樭�', 110904, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 110905, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 110906, date_20110101, empty_date } )
    AAdd( _arr, { '���� ��祡��� �ࠪ⨪� (ᥬ����� ����樭�)', 1110, date_20110101, empty_date } )
    AAdd( _arr, { '����⠭���⥫쭠� ����樭�', 111001, date_20110101, empty_date } )
    AAdd( _arr, { '��ਠ���', 111002, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������ � ᯮ�⨢��� ����樭�', 111003, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 111004, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 111005, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 111006, date_20110101, empty_date } )
    AAdd( _arr, { '����᪮���', 111007, date_20110101, empty_date } )
    AAdd( _arr, { '�⮫�ਭ�������', 1111, date_20110101, empty_date } )
    AAdd( _arr, { '��म�����-�⮫�ਭ�������', 111101, date_20110101, empty_date } )
    AAdd( _arr, { '��⠫쬮�����', 1112, date_20110101, empty_date } )
    AAdd( _arr, { '��⮫����᪠� ���⮬��', 1113, date_20110101, empty_date } )
    AAdd( _arr, { '��娠���', 1115, date_20110101, empty_date } )
    AAdd( _arr, { '����࠯��', 111501, date_20110101, empty_date } )
    AAdd( _arr, { '���᮫����', 111502, date_20110101, empty_date } )
    AAdd( _arr, { '�㤥���-��娠���᪠� �ᯥ�⨧�', 111503, date_20110101, empty_date } )
    AAdd( _arr, { '��娠���-��મ�����', 111504, date_20110101, empty_date } )
    AAdd( _arr, { '���⣥�������', 1118, date_20110101, empty_date } )
    AAdd( _arr, { '����������', 111801, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 111802, date_20110101, empty_date } )
    AAdd( _arr, { '����� ����樭᪠� ������', 1119, date_20110101, empty_date } )
    AAdd( _arr, { '����⠭���⥫쭠� ����樭�', 111901, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������ � ᯮ�⨢��� ����樭�', 111902, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 111903, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 111904, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 111905, date_20110101, empty_date } )
    AAdd( _arr, { '�࣠������ ��ࠢ���࠭���� � ����⢥���� ���஢�', 1120, date_20110101, empty_date } )
    AAdd( _arr, { '�㤥���-����樭᪠� �ᯥ�⨧�', 1121, date_20110101, empty_date } )
    AAdd( _arr, { '��࠯��', 1122, date_20110101, empty_date } )
    AAdd( _arr, { '�������஫����', 112201, date_20110101, empty_date } )
    AAdd( _arr, { '����⮫����', 112202, date_20110101, empty_date } )
    AAdd( _arr, { '��ਠ���', 112203, date_20110101, empty_date } )
    AAdd( _arr, { '���⮫����', 112204, date_20110101, empty_date } )
    AAdd( _arr, { '��न������', 112205, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� �ଠ�������', 112206, date_20110101, empty_date } )
    AAdd( _arr, { '���஫����', 112207, date_20110101, empty_date } )
    AAdd( _arr, { '��쬮�������', 112208, date_20110101, empty_date } )
    AAdd( _arr, { '�����⮫����', 112209, date_20110101, empty_date } )
    AAdd( _arr, { '�࠭��㧨������', 112210, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 112211, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 112212, date_20110101, empty_date } )
    AAdd( _arr, { '����樮���� � ��ᬨ�᪠� ����樭�', 112213, date_20110101, empty_date } )
    AAdd( _arr, { '����࣮����� � ���㭮�����', 112214, date_20110101, empty_date } )
    AAdd( _arr, { '����⠭���⥫쭠� ����樭�', 112215, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������ � ᯮ�⨢��� ����樭�', 112216, date_20110101, empty_date } )
    AAdd( _arr, { '���㠫쭠� �࠯��', 112217, date_20110101, empty_date } )
    AAdd( _arr, { '��䯠⮫����', 112218, date_20110101, empty_date } )
    AAdd( _arr, { '��䫥���࠯��', 112219, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 112220, date_20110101, empty_date } )
    AAdd( _arr, { '����᪮���', 112221, date_20110101, empty_date } )
    AAdd( _arr, { '�ࠢ��⮫���� � ��⮯����', 1123, date_20110101, empty_date } )
    AAdd( _arr, { '���㠫쭠� �࠯��', 112301, date_20110101, empty_date } )
    AAdd( _arr, { '����⠭���⥫쭠� ����樭�', 112302, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������ � ᯮ�⨢��� ����樭�', 112303, date_20110101, empty_date } )
    AAdd( _arr, { '����������', 112304, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 1124, date_20110101, empty_date } )
    AAdd( _arr, { '�⨧�����', 1125, date_20110101, empty_date } )
    AAdd( _arr, { '��쬮�������', 112501, date_20110101, empty_date } )
    AAdd( _arr, { '����ࣨ�', 1126, date_20110101, empty_date } )
    AAdd( _arr, { '�����ப⮫����', 112601, date_20110101, empty_date } )
    AAdd( _arr, { '�������ࣨ�', 112602, date_20110101, empty_date } )
    AAdd( _arr, { '�஫����', 112603, date_20110101, empty_date } )
    AAdd( _arr, { '��थ筮-��㤨��� ���ࣨ�', 112604, date_20110101, empty_date } )
    AAdd( _arr, { '��ࠪ��쭠� ���ࣨ�', 112605, date_20110101, empty_date } )
    AAdd( _arr, { '�࠭��㧨������', 112606, date_20110101, empty_date } )
    AAdd( _arr, { '�����⭮-��楢�� ���ࣨ�', 112608, date_20110101, empty_date } )
    AAdd( _arr, { '����᪮���', 112609, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 112610, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 112611, date_20110101, empty_date } )
    AAdd( _arr, { '�����ਭ������', 1127, date_20110101, empty_date } )
    AAdd( _arr, { '�����⮫����', 112701, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ���ਭ������', 112702, date_20110101, empty_date } )
    AAdd( _arr, { '���������', 1128, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ���������', 112801, date_20110101, empty_date } )
    AAdd( _arr, { '����������', 112802, date_20110101, empty_date } )
    AAdd( _arr, { '��������', 1134, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ���������', 113401, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ���ਭ������', 113402, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ��न������', 113403, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������ � ᯮ�⨢��� ����樭�', 113404, date_20110101, empty_date } )
    AAdd( _arr, { '����࣮����� � ���㭮�����', 113405, date_20110101, empty_date } )
    AAdd( _arr, { '����⠭���⥫쭠� ����樭�', 113406, date_20110101, empty_date } )
    AAdd( _arr, { '�������஫����', 113407, date_20110101, empty_date } )
    AAdd( _arr, { '����⮫����', 113408, date_20110101, empty_date } )
    AAdd( _arr, { '���⮫����', 113409, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� �ଠ�������', 113410, date_20110101, empty_date } )
    AAdd( _arr, { '���㠫쭠� �࠯��', 113411, date_20110101, empty_date } )
    AAdd( _arr, { '���஫����', 113412, date_20110101, empty_date } )
    AAdd( _arr, { '��쬮�������', 113413, date_20110101, empty_date } )
    AAdd( _arr, { '�����⮫����', 113414, date_20110101, empty_date } )
    AAdd( _arr, { '�࠭��㧨������', 113415, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 113416, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 113417, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 113418, date_20110101, empty_date } )
    AAdd( _arr, { '����᪮���', 113419, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ���ࣨ�', 1135, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� ���������', 113501, date_20110101, empty_date } )
    AAdd( _arr, { '���᪠� �஫����-���஫����', 113502, date_20110101, empty_date } )
    AAdd( _arr, { '�����ப⮫����', 113503, date_20110101, empty_date } )
    AAdd( _arr, { '�������ࣨ�', 113504, date_20110101, empty_date } )
    AAdd( _arr, { '��थ筮-��㤨��� ���ࣨ�', 113505, date_20110101, empty_date } )
    AAdd( _arr, { '��ࠪ��쭠� ���ࣨ�', 113506, date_20110101, empty_date } )
    AAdd( _arr, { '�࠭��㧨������', 113507, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 113508, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 113509, date_20110101, empty_date } )
    AAdd( _arr, { '�����⭮-��楢�� ���ࣨ�', 113510, date_20110101, empty_date } )
    AAdd( _arr, { '����᪮���', 113511, date_20110101, empty_date } )
    AAdd( _arr, { '�����⮫����', 1136, date_20110101, empty_date } )
    AAdd( _arr, { '������-��䨫����᪮� ����', 13, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ������ୠ� �������⨪�', 1301, date_20110101, empty_date } )
    AAdd( _arr, { '����ਮ�����', 130101, date_20110101, empty_date } )
    AAdd( _arr, { '����᮫����', 130102, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 130103, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ���������', 130104, date_20110101, empty_date } )
    AAdd( _arr, { '�������������', 1302, date_20110101, empty_date } )
    AAdd( _arr, { '����ਮ�����', 130201, date_20110101, empty_date } )
    AAdd( _arr, { '�����䥪⮫����', 130203, date_20110101, empty_date } )
    AAdd( _arr, { '��ࠧ�⮫����', 130204, date_20110101, empty_date } )
    AAdd( _arr, { '����᮫����', 130205, date_20110101, empty_date } )
    AAdd( _arr, { '���� �������', 1303, date_20110101, empty_date } )
    AAdd( _arr, { '������� ��⥩ � �����⪮�', 130301, date_20110101, empty_date } )
    AAdd( _arr, { '��������᪮� ��ᯨ⠭��', 130302, date_20110101, empty_date } )
    AAdd( _arr, { '������� ��⠭��', 130303, date_20110101, empty_date } )
    AAdd( _arr, { '������� ��㤠', 130304, date_20110101, empty_date } )
    AAdd( _arr, { '����㭠�쭠� �������', 130305, date_20110101, empty_date } )
    AAdd( _arr, { '�����樮���� �������', 130306, date_20110101, empty_date } )
    AAdd( _arr, { '�����୮-��������᪨� �������� ��᫥�������', 130307, date_20110101, empty_date } )
    AAdd( _arr, { '��樠�쭠� ������� � �࣠������ ���ᠭ���㦡�', 1306, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫����', 14, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� ��饩 �ࠪ⨪�', 1401, date_20110101, empty_date } )
    AAdd( _arr, { '��⮤����', 140101, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� ���᪠�', 140102, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� �࠯����᪠�', 140103, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� ��⮯����᪠�', 140104, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� ���ࣨ�᪠�', 140105, date_20110101, empty_date } )
    AAdd( _arr, { '�����⭮-��楢�� ���ࣨ�', 140106, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 140107, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ������ୠ� �������⨪�', 1402, date_20110101, empty_date } )
    AAdd( _arr, { '����ਮ�����', 140201, date_20110101, empty_date } )
    AAdd( _arr, { '����᮫����', 140202, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 140203, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ���������', 140204, date_20110101, empty_date } )
    AAdd( _arr, { '��ଠ��', 15, date_20110101, empty_date } )
    AAdd( _arr, { '��ࠢ����� � ������� �ଠ樨', 1501, date_20110101, empty_date } )
    AAdd( _arr, { '��ଠ楢��᪠� �孮�����', 1502, date_20110101, empty_date } )
    AAdd( _arr, { '��ଠ楢��᪠� 娬�� � �ଠ��������', 1503, date_20110101, empty_date } )
    AAdd( _arr, { '����ਭ᪮� ����', 16, date_20110101, empty_date } )
    AAdd( _arr, { '��ࠢ����� ���ਭ᪮� ���⥫쭮����', 1601, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ���娬��', 17, date_20110101, empty_date } )
    AAdd( _arr, { '����⨪�', 1701, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 170101, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ������ୠ� �������⨪�', 1702, date_20110101, empty_date } )
    AAdd( _arr, { '����ਮ�����', 170201, date_20110101, empty_date } )
    AAdd( _arr, { '����᮫����', 170202, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 170203, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ���������', 170204, date_20110101, empty_date } )
    AAdd( _arr, { '�㤥���-����樭᪠� �ᯥ�⨧�', 1703, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ���䨧���. ����樭᪠� ����୥⨪�', 18, date_20110101, empty_date } )
    AAdd( _arr, { '������᪠� ������ୠ� �������⨪�', 1801, date_20110101, empty_date } )
    AAdd( _arr, { '����ਮ�����', 180101, date_20110101, empty_date } )
    AAdd( _arr, { '����᮫����', 180102, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ����⨪�', 180103, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� ���������', 180104, date_20110101, empty_date } )
    AAdd( _arr, { '���⣥�������', 1802, date_20110101, empty_date } )
    AAdd( _arr, { '����������', 180201, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 180202, date_20110101, empty_date } )
    AAdd( _arr, { '����ࠧ�㪮��� �������⨪�', 180203, date_20110101, empty_date } )
    AAdd( _arr, { '�।��� ����樭᪮� � �ଠ楢��᪮� ��ࠧ������', 2, date_20110101, empty_date } )
    AAdd( _arr, { '�࣠������ ���ਭ᪮�� ����', 2001, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� ����', 2002, date_20110101, empty_date } )
    AAdd( _arr, { '�����᪮� ����', 2003, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫����', 2004, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� ��⮯����᪠�', 2005, date_20110101, empty_date } )
    AAdd( _arr, { '������������� (��ࠧ�⮫����)', 2006, date_20110101, empty_date } )
    AAdd( _arr, { '������� � ᠭ����', 2007, date_20110101, empty_date } )
    AAdd( _arr, { '�����䥪樮���� ����', 2008, date_20110101, empty_date } )
    AAdd( _arr, { '��������᪮� ��ᯨ⠭��', 2009, date_20110101, empty_date } )
    AAdd( _arr, { '��⮬������', 2010, date_20110101, empty_date } )
    AAdd( _arr, { '������ୠ� �������⨪�', 2011, date_20110101, empty_date } )
    AAdd( _arr, { '���⮫����', 2012, date_20110101, empty_date } )
    AAdd( _arr, { '������୮� ����', 2013, date_20110101, empty_date } )
    AAdd( _arr, { '��ଠ��', 2014, date_20110101, empty_date } )
    AAdd( _arr, { '����ਭ᪮� ����', 2015, date_20110101, empty_date } )
    AAdd( _arr, { '����ਭ᪮� ���� � ������ਨ', 2016, date_20110101, empty_date } )
    AAdd( _arr, { '����樮���� ����', 2017, date_20110101, empty_date } )
    AAdd( _arr, { '����⥧������� � ॠ����⮫����', 2018, date_20110101, empty_date } )
    AAdd( _arr, { '���� �ࠪ⨪�', 2019, date_20110101, empty_date } )
    AAdd( _arr, { '���⣥�������', 2020, date_20110101, empty_date } )
    AAdd( _arr, { '�㭪樮���쭠� �������⨪�', 2021, date_20110101, empty_date } )
    AAdd( _arr, { '������࠯��', 2022, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪨� ���ᠦ', 2023, date_20110101, empty_date } )
    AAdd( _arr, { '��祡��� 䨧������', 2024, date_20110101, empty_date } )
    AAdd( _arr, { '���⮫����', 2025, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ����⨪�', 2026, date_20110101, empty_date } )
    AAdd( _arr, { '�⮬�⮫���� ��䨫����᪠�', 2027, date_20110101, empty_date } )
    AAdd( _arr, { '�㤥���-����樭᪠� �ᯥ�⨧�', 2028, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ��⨪�', 2029, date_20110101, empty_date } )
    AAdd( _arr, { '����⢥��� ��㪨', 3, date_20110101, empty_date } )
    AAdd( _arr, { '���䨧���', 31, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ���䨧���', 3101, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ����୥⨪�', 3102, date_20110101, empty_date } )
    AAdd( _arr, { '���娬��', 32, date_20110101, empty_date } )
    AAdd( _arr, { '����樭᪠� ���娬��', 3201, date_20110101, empty_date } )
  Endif

  Return _arr

// =========== V005 ===================
//
// 22.10.22 ������ �����䨪��� ���� �����客������ V005.xml
Function getv005()

  // V005.xml - �����䨪��� ���� �����客������
  // 1 - POLNAME(C)  2 - IDPOL(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )

  If Len( _arr ) == 0
    AAdd( _arr, { '��᪮�', 1, empty_date, empty_date } )
    AAdd( _arr, { '���᪨�', 2, empty_date, empty_date } )
  Endif

  Return _arr

// =========== V006 ===================
//
// 18.05.22 ������ �᫮��t �������� ����樭᪮� ����� �� ����
Function getuslovie_v006( kod )

  Local ret := NIL
  Local i

  If ( i := AScan( getv006(), {| x| x[ 2 ] == kod } ) ) > 0
    ret := getv006()[ i, 1 ]
  Endif

  Return ret

// 28.02.21 ������ �����䨪��� �᫮��� �������� ����樭᪮� ����� V006.xml
Function getv006()

  // V006.xml - �����䨪��� �᫮��� �������� ����樭᪮� �����
  // 1 - UMPNAME(C)  2 - IDUMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { '��樮���', 1, date_20110101, empty_date } )
    AAdd( _arr, { '������� ��樮���', 2, date_20110101, empty_date } )
    AAdd( _arr, { '�����������', 3, date_20110101, empty_date } )
    AAdd( _arr, { '����� ������', 4, SToD( '20130101' ), empty_date } )
  Endif

  Return _arr

// =========== V008 ===================
//
// 22.10.22 ������ �����䨪��� ����� ����樭᪮� ����� V008.xml
Function getv008()

  // V008.xml - �����䨪��� ����� ����樭᪮� �����
  // 1 - VMPNAME(C)  2 - IDVMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )
  Local date_20110101 := SToD( '20110101' )

  If Len( _arr ) == 0
    AAdd( _arr, { '��ࢨ筠� ������-ᠭ��ୠ� ������', 1, date_20110101, empty_date } )
    AAdd( _arr, { '�����, � ⮬ �᫥ ᯥ樠����஢����� (ᠭ��୮-����樮����), ����樭᪠� ������', 2, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { '���樠����஢�����, � ⮬ �᫥ ��᮪��孮����筠�, ����樭᪠� ������', 3, date_20110101, empty_date } )
  Endif

  Return _arr

// =========== V009 ===================
//
#define V009_IDRMP    1
#define V009_RMPNAME  2
#define V009_DL_USLOV 3
#define V009_DATEBEG  4
#define V009_DATEEND  5

// 23.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V009.xml
Function getv009( work_date )

  // V009.xml - �����䨪��� १���⮢ ���饭�� �� ����樭᪮� �������
  Static _arr
  Local stroke := '', vid := ''
  Static time_load
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idrmp, ' + ;
      'rmpname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v009' )  // WHERE dateend == "    -  -  "')
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If Val( aTable[ nI, V009_DL_USLOV ] ) == 1
          vid := '/��-�/'
        Elseif Val( aTable[ nI, V009_DL_USLOV ] ) == 2
          vid := '/��.�/'
        Elseif Val( aTable[ nI, V009_DL_USLOV ] ) == 3
          vid := '/�-��/'
        Else
          vid := '/'
        Endif
        stroke := Str( Val( aTable[ nI, V009_IDRMP ] ), 3 ) + vid + AllTrim( aTable[ nI, V009_RMPNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V009_IDRMP ] ), CToD( aTable[ nI, V009_DATEBEG ] ), CToD( aTable[ nI, V009_DATEEND ] ), Val( aTable[ nI, V009_DL_USLOV ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// 04.11.22 ������ १���� ���饭�� �� ����樭᪮� ������� �� ����
Function getrslt_v009( result )

  Local ret := NIL
  Local i

  If ( i := AScan( getv009(), {| x| x[ 2 ] == result } ) ) > 0
    ret := getv009()[ i, 1 ]
  Endif

  Return ret

// 23.01.23 ������ १���� ���饭�� �� �᫮��� �������� � ���
Function getrslt_usl_date( uslovie, date )

  Local ret := {}
  Local row

  For Each row in getv009( date )
    If uslovie == row[ 5 ]
      AAdd( ret, row )
    Endif
  Next

  Return ret

// =========== V010 ===================
//
#define V010_IDSP     1
#define V010_SPNAME   2
#define V010_DATEBEG  3
#define V010_DATEEND  4

// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V010.xml
Function getv010( work_date )

  // V010.xml - �����䨪��� ᯮᮡ�� ������ ����樭᪮� �����
  Static _arr
  Static time_load
  Local stroke := ''
  Local db
  Local aTable
  Local nI
  Local ret_array, row

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idsp, ' + ;
      'spname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v010' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        stroke := StrZero( Val( aTable[ nI, V010_IDSP ] ), 2, 0 ) + '/' + AllTrim( aTable[ nI, V010_SPNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V010_IDSP ] ), AllTrim( aTable[ nI, V010_SPNAME ] ), CToD( aTable[ nI, V010_DATEBEG ] ), CToD( aTable[ nI, V010_DATEEND ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// =========== V012 ===================
//
#define V012_IDIZ     1
#define V012_IZNAME   2
#define V012_DL_USLOV 3
#define V012_DATEBEG  4
#define V012_DATEEND  5

// 23.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V012.xml
Function getv012( work_date )

  // V012.xml - �����䨪��� ��室�� �����������
  Static _arr
  Static time_load
  Local stroke := '', vid := ''
  Local db
  Local aTable, row
  Local nI
  Local ret_array

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idiz, ' + ;
      'izname, ' + ;
      'dl_uslov, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v012' )   // WHERE dateend == "    -  -  "')
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        // if empty(ctod(aTable[nI, 5]))  // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
        If Val( aTable[ nI, V012_DL_USLOV ] ) == 1
          vid := '/��-�/'
        Elseif Val( aTable[ nI, V012_DL_USLOV ] ) == 2
          vid := '/��.�/'
        Elseif Val( aTable[ nI, V012_DL_USLOV ] ) == 3
          vid := '/�-��/'
        Else
          vid := '/'
        Endif
        stroke := Str( Val( aTable[ nI, V012_IDIZ ] ), 3 ) + vid + AllTrim( aTable[ nI, V012_IZNAME ] )
        AAdd( _arr, { stroke, Val( aTable[ nI, V012_IDIZ ] ), CToD( aTable[ nI, V012_DATEBEG ] ), CToD( aTable[ nI, V012_DATEEND ] ), Val( aTable[ nI, V012_DL_USLOV ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif
  If HB_ISNIL( work_date )
    Return _arr
  Else
    ret_array := {}
    For Each row in _arr
      If correct_date_dictionary( work_date, row[ 3 ], row[ 4 ] )
        AAdd( ret_array, row )
      Endif
    Next
  Endif

  Return ret_array

// 06.11.22 ������ ��室 ����������� �� ����
Function getishod_v012( ishod )

  Local ret := NIL
  Local i

  If ( i := AScan( getv012(), {| x| x[ 2 ] == ishod } ) ) > 0
    ret := getv012()[ i, 1 ]
  Endif

  Return ret

// 23.01.23 ������ ��室 ����������� �� �᫮��� �������� � ���
Function getishod_usl_date( uslovie, date )

  Local ret := {}
  Local row

  For Each row in getv012( date )
    If uslovie == row[ 5 ]
      AAdd( ret, row )
    Endif
  Next

  Return ret

// =========== V014 ===================
//
// 21.10.22 ������ �����䨪��� �� ����樭᪮� ����� V014.xml
Function getv014()

  // V014.xml - �����䨪��� �� ����樭᪮� �����
  // 1 - FRMMPNAME(C)  2 - IDFRMMP(N)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr := {}
  Local empty_date := SToD( '' )

  If Len( _arr ) == 0
    AAdd( _arr, { '����७���', 1, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { '���⫮����', 2, SToD( '20130101' ), empty_date } )
    AAdd( _arr, { '��������', 3, SToD( '20130101' ), empty_date } )
  Endif

  Return _arr

// =========== V015 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� V015.xml
// �����頥� ���ᨢ V015
Function getv015()

  // V015.xml - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'recid, ' + ;
      'code, ' + ;
      'name, ' + ;
      'high, ' + ;
      'okso, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v015' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 3 ] ), Val( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 4 ] ), AllTrim( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ), CToD( aTable[ nI, 7 ] ), Val( aTable[ nI, 1 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil

    ASort( _arr, , , {| x, y| x[ 2 ] < y[ 2 ] } )
  Endif

  Return _arr

// =========== V016 ===================
//
// 26.01.23 ������ �����䨪��� ����� ��ᯠ��ਧ�樨/���ᬮ�஢ V016.xml
Function getv016()

  // V016.xml - �����䨪��� ����� ��ᯠ��ਧ�樨/���ᬮ�஢
  Static _arr
  Static time_load
  Local ar := {}
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT iddt, dtname, rule, datebeg, dateend FROM v016' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        ar := list2arr( aTable[ nI, 3 ] )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ar, CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 13.12.21 ������ ����⥫� ⨯� ��ᯭ�ਧ�樨 �� ����
Function get_type_dispt( mdate, codeDispT )

  Local dispT := Upper( AllTrim( codeDispT ) )
  Local _arr := {}, i
  Local tmpArr := getv016()
  Local lengthArr := Len( tmpArr )

  For i := 1 To lengthArr
    If dispT == tmpArr[ i, 1 ] .and. between_date( tmpArr[ i, 4 ], tmpArr[ i, 5 ], mdate )
      AAdd( _arr, tmpArr[ i, 1 ] )
      AAdd( _arr, tmpArr[ i, 2 ] )
      AAdd( _arr, tmpArr[ i, 3 ] )
    Endif
  Next

  Return _arr

// =========== V017 ===================
//
// 26.01.23 ������ �����䨪��� १���⮢ ��ᯠ��ਧ�樨 (DispR) V017.xml
Function getv017()

  // V017.xml - �����䨪��� १���⮢ ��ᯠ��ਧ�樨 (DispR)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT iddr, drname, datebeg, dateend FROM v017' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 13.12.21 ������ ᯨ᮪ १���⮢ ��ᯠ��ਧ�樨 �� ���� � ᮮ⢥��⢨� � ᯨ᪮� �����
Function get_list_dispr( mdate, arrDR )

  Local _arr := {}, code, i
  Local tmpArr := getv017()
  Local lenArr := Len( tmpArr )

  For Each code in arrDR
    For i := 1 To lenArr
      If code == tmpArr[ i, 1 ] .and. between_date( tmpArr[ i, 3 ], tmpArr[ i, 4 ], mdate )
        AAdd( _arr, tmpArr[ i, 2 ] )
      Endif
    Next
  Next

  Return _arr

// =========== V018 ===================
//
// 25.01.23 �����頥� ���ᨢ V018 �� 㪠������ ����
Function getv018( dateSl )

  Local yearSl := Year( dateSl )
  Local _arr
  Local db
  Local aTable, stmt
  Local nI

  Static hV018, lHashV018 := .f.

  // �� ������⢨� ���-���ᨢ� ᮧ����� ���
  If !lHashV018
    hV018 := hb_Hash()
    lHashV018 := .t.
  Endif

  // ����稬 ���ᨢ V018 �� ��� �� ����� ��� ��������� ������, ��� ����㧨� ��� �� �ࠢ�筨��
  If hb_HHasKey( hV018, yearSl )
    _arr := hb_HGet( hV018, yearSl )
  Else
    _arr := {}

    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idhvid, ' + ;
      'hvidname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v018' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If ( Year( CToD( aTable[ nI, 3 ] ) ) <= yearSl ) .and. ( Empty( CToD( aTable[ nI, 4 ] ) ) .or. Year( CToD( aTable[ nI, 4 ] ) ) >= yearSl )   // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
          AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
        Endif
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    // �����⨬ � ���-���ᨢ
    hV018[ yearSl ] := _arr
  Endif
  If Empty( _arr )
    alertx( '�� ���� ' + DToC( dateSl ) + ' V018 ����������!' )
  Endif

  Return _arr

// =========== V019 ===================
//
// 25.01.23 �����頥� ���ᨢ V019
Function getv019( dateSl )

  Local yearSl := Year( dateSl )
  Local _arr
  Local db
  Local aTable, stmt
  Local nI

  Static hV019, lHashV019 := .f.

  // �� ������⢨� ���-���ᨢ� ᮧ����� ���
  If !lHashV019
    hV019 := hb_Hash()
    lHashV019 := .t.
  Endif

  // ����稬 ���ᨢ V019 �� ��� �� ����� ��� ��������� ������, ��� ����㧨� ��� �� �ࠢ�筨��
  If hb_HHasKey( hV019, yearSl )
    _arr := hb_HGet( hV019, yearSl )
  Else
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idhm, ' + ;
      'hmname, ' + ;
      'diag, ' + ;
      'hvid, ' + ;
      'hgr, ' + ;
      'hmodp, ' + ;
      'idmodp, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v019' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        If ( Year( CToD( aTable[ nI, 8 ] ) ) <= yearSl ) .and. ( Empty( CToD( aTable[ nI, 9 ] ) ) .or. Year( CToD( aTable[ nI, 9 ] ) ) >= yearSl )   // ⮫쪮 �᫨ ���� ����砭�� ����⢨� ����
          AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ;
            AClone( split( AllTrim( aTable[ nI, 3 ] ), ', ' ) ), ;
            AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 8 ] ), CToD( aTable[ nI, 9 ] ), ;
            Val( aTable[ nI, 5 ] ), Val( aTable[ nI, 7 ] ) ;
            } )
        Endif
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    hV019[ yearSl ] := _arr
  Endif

  Return _arr

// =========== V020 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V020.xml - �����䨪��� ��䨫�� �����
Function getv020()

  Static _arr
  Static time_load
  Local db
  Local aTable, stmt
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idk_pr, ' + ;
      'k_prname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v020' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V021 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V021.xml
Function getv021()

  // V021.xml - �����䨪��� ����樭᪨� ᯥ樠�쭮�⥩ (�������⥩) (MedSpec)
  // 1 - SPECNAME(C)  2 - IDSPEC(N)  3 - DATEBEG(D)  4 - DATEEND(D)  5 - POSTNAME(C)  6 - IDPOST_MZ(C)

  Static _arr   // := {}
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idspec, ' + ;
      'idspec || "." || trim(specname), ' + ;
      'postname, ' + ;
      'idpost_mz, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v021 WHERE dateend == "    -  -  "' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 1 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ), AllTrim( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 27.02.23 ������ ���ᨢ ����뢠�騩 ᯥ樠�쭮���
Function doljbyspec_v021( idspec )

  Local i, retArray := ''
  Local aV021 := getv021()

  If !Empty( idspec ) .and. ( ( i := AScan( aV021, {| x| x[ 2 ] == idspec } ) ) > 0 )
    retArray := aV021[ i, 5 ]
  Endif

  Return retArray

// 25.06.24
Function ret_str_spec( kod )

  Local i, s := '', aV021 := getv021()

  If ! Empty( kod ) .and. ( ( i := AScan( aV021, {| x | x[ 2 ] == kod } ) ) > 0 )
    s := aV021[ i, 1 ]
  Endif

  Return s


// =========== V022 ===================
//
// 26.01.23 �����頥� ���ᨢ V022
Function getv022()

  Static _arr
  Static time_load
  Local db
  Local aTable, stmt
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idmpac, ' + ;
      'mpacname, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v022' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
    ASort( _arr, , , {| x, y| x[ 1 ] < y[ 1 ] } )
  Endif

  Return _arr

// 11.02.21 ������ ��ப� ������ ��樥�� ���
Function ret_v022( idmpac, lk_data )

  Local i, s := Space( 10 )
  Local aV022 := getv022()

  If !Empty( idmpac ) .and. ( ( i := AScan( aV022, {| x| x[ 1 ] == idmpac } ) ) > 0 )
    s := aV022[ i, 2 ]
  Endif

  Return s

// =========== V025 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V025 �����䨪��� 楫�� ���饭�� (KPC)
Function getv025()

  Static _arr
  Static time_load
  Local i
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'idpc, ' + ;
      'n_pc, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v025' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ) + '-' + AllTrim( aTable[ nI, 2 ] ), nI -1, AllTrim( aTable[ nI, 1 ] ), ;
          CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

Function get_idpc_from_v025_by_number( num )

  Local tableV025 := getv025()
  Local row
  Local retIDPC := ''

  For Each row in tableV025
    If row[ 2 ] == num
      retIDPC := row[ 3 ]
      Exit
    Endif
  Next

  Return retIDPC

// =========== V030 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V030.xml
Function getv030()

  // V030.xml - �奬� ��祭�� ����������� COVID-19 (TreatReg)
  // 1 - SCHEMCOD(C) 2 - SCHEME(C) 3 - DEGREE(N) 4 - COMMENT(M)  5 - DATEBEG(D)  6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    db := opensql_db()
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )

    aTable := sqlite3_get_table( db, 'SELECT ' + ;
      'schemcode, ' + ;
      'scheme, ' + ;
      'degree, ' + ;
      'comment, ' + ;
      'datebeg, ' + ;
      'dateend ' + ;
      'FROM v030' )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), ;
          Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), ;
          CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) ;
          } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 11.01.22 ������ �奬� ��祭�� ᮣ��᭮ �殮�� ��樥��
Function get_schemas_lech( _degree, ldate )

  Local _arr := {}, row

  If ValType( _degree ) == 'C' .and. Empty( _degree )
    Return _arr
  Endif
  If ValType( _degree ) == 'N' .and. _degree == 0
    Return _arr
  Endif

  For Each row in getv030()
    If ( row[ 3 ] == _degree ) .and. between_date( row[ 5 ], row[ 6 ], ldate )
      AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ], row[ 6 ] } )
    Endif
  Next

  Return _arr

// 07.01.22 ������ ������������ �奬�
Function ret_schema_v030( s_code )

  // s_code - ��� �奬�
  Local i, ret := ''
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv030(), {| x| x[ 2 ] == code } ) ) > 0 )
    ret := getv030()[ i, 1 ]
  Endif

  Return ret

// =========== V031 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V031.xml
Function getv031()

  // V031.xml - ��㯯� �९��⮢ ��� ��祭�� ����������� COVID-19 (GroupDrugs)
  // 1 - DRUGCODE(N) 2 - DRUGGRUP(C) 3 - INDMNN(N)  4 - DATEBEG(D)  5 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT drugcode, druggrup, indmnn, datebeg, dateend FROM v031' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { Val( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 29.08.22 ������ ��㯯� �९��⮢
Function get_group_prep_by_kod( _code, ldate )

  Local _arr, row, code

  If ValType( _code ) == 'C'
    code := Val( SubStr( _code, Len( _code ) ) )
  Elseif ValType( _code ) == 'N'
    code := _code
  Else
    Return _arr
  Endif

  For Each row in getv031()
    If ( row[ 1 ] == code ) .and. between_date( row[ 4 ], row[ 5 ], ldate )
      _arr := { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ] }
    Endif
  Next

  Return _arr

// =========== V032 ===================
//
// 26.01.22 ������ ���ᨢ �� �ࠢ�筨�� ����� V032.xml
Function getv032()

  // V032.xml - ���⠭�� �奬� ��祭�� � ��㯯� �९��⮢ (CombTreat)
  // 1 - SCHEDRUG(C) 2 - NAME(C) 3 - SCHEMCOD(C)  4 - DATEBEG(D)  5 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT schedrug, name, schemcode, datebeg, dateend FROM v032' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 2 ] ), AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// 04.01.22 ������ ��⠭�� �奬� � ��㯯� �९��⮢
Function get_group_by_schema_lech( _scheme, ldate )

  Local _arr := {}, row

  For Each row in getv032()
    If ( row[ 3 ] == AllTrim( _scheme ) ) .and. between_date( row[ 4 ], row[ 5 ], ldate )
      AAdd( _arr, { row[ 1 ], row[ 2 ], row[ 3 ], row[ 4 ], row[ 5 ] } )
    Endif
  Next

  Return _arr

// 08.01.22 ������ ������������ ���� �奬�
Function ret_schema_v032( s_code )

  // s_code - ��� �奬�
  Local i, ret := ''
  Local code := AllTrim( s_code )

  If !Empty( code ) .and. ( ( i := AScan( getv032(), {| x| x[ 2 ] == code } ) ) > 0 )
    ret := getv032()[ i, 1 ]
  Endif

  Return ret

// =========== V033 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V033.xml
Function getv033()

  // V033.xml - ���⢥��⢨� ���� �९��� �奬� ��祭�� (DgTreatReg)
  // 1 - SCHEDRUG(C) 2 - DRUGCODE(C)  3 - DATEBEG(D)  4 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT schedrug, drugcode, datebeg, dateend FROM v033' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V036 ===================
//
// 26.01.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V036.xml
Function getv036()

  // V036.xml - ���祭� ���, �ॡ���� ��������� ����樭᪨� ������� (ServImplDv)
  // 1 - S_CODE(C) 2 - NAME(C) 3 - PARAM(N) 4 - COMMENT(C) 5 - DATEBEG(D) 6 - DATEEND(D)
  Static _arr
  Static time_load
  Local db
  Local aTable
  Local nI

  If timeout_load( @time_load )
    _arr := {}
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    aTable := sqlite3_get_table( db, 'SELECT s_code, name, param, comment, datebeg, dateend FROM v036' )

    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        AAdd( _arr, { AllTrim( aTable[ nI, 1 ] ), AllTrim( aTable[ nI, 2 ] ), Val( aTable[ nI, 3 ] ), AllTrim( aTable[ nI, 4 ] ), CToD( aTable[ nI, 5 ] ), CToD( aTable[ nI, 6 ] ) } )
      Next
    Endif
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
    db := nil
  Endif

  Return _arr

// =========== V024 ===================
//
// 25.09.23 ������ ���ᨢ �� �ࠢ�筨�� ����� V036.xml
Function getv024( dk )

  // V024.xml - �����䨪��� �����䨪�樮���� ���ਥ� (DopKr)
  // 1 - IDDKK(C) 2 - DKKNAME(C) 3 - DATEBEG(D) 4 - DATEEND(D)
  Local arr
  Local db
  Local aTable
  Local nI
  Local dBeg, dEnd

  arr := {}
  If ValType( dk ) == 'N'
    dBeg := "'" + Str( dk, 4 ) + "-01-01 00:00:00'"
    dEnd := "'" + Str( dk, 4 ) + "-12-31 00:00:00'"
  Elseif ValType( dk ) == 'D'
    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    dBeg := "'" + DToS( dk ) + "-01-01 00:00:00'"
    dEnd := "'" + DToS( dk ) + "-12-31 00:00:00'"
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
  Endif

  db := opensql_db()
  aTable := sqlite3_get_table( db, "SELECT " + ;
    "iddkk, " + ;
    "dkkname, " + ;
    "datebeg, " + ;
    "dateend " + ;
    "FROM v024 " + ;
    "WHERE datebeg <= " + dBeg + ;
    "AND dateend >= " + dEnd )
  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
      dBeg := CToD( aTable[ nI, 3 ] )
      dEnd := CToD( aTable[ nI, 4 ] )
      Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )

      AAdd( arr, { aTable[ nI, 1 ], aTable[ nI, 2 ], dBeg, dEnd } )
    Next
  Endif
  db := nil

  Return arr
