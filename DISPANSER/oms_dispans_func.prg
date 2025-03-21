#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 22.11.24
function read_napr_dispanser( lkod )
  // ������ arr_napr
  // arr_napr[1,1], arr_napr[1,2], arr_napr[1,3] - ���� ��� ��᫥������� (���, 0, ����� ����� � �ࠢ�筨�� ���ᮭ���)
  // arr_napr[2,1], arr_napr[2,2], arr_napr[2,3] - ����. � �� (�㤠 ��ࠢ�塞, ���ᨢ ����� ᯥ樠����樨, ����� ����� � �ࠢ�筨�� ���ᮭ���)
  // arr_napr[3,1], arr_napr[3,2], arr_napr[3,3] - ����. �� ��祭�� (�㤠 ���ࠢ�塞, ��� ��䨫�, ����� ����� � �ࠢ�筨�� ���ᮭ���)
  // arr_napr[4,1], arr_napr[4,2], arr_napr[4,3] - ����. ॠ�����樨 (��/���, ��� ��䨫�, ����� ����� � �ࠢ�筨�� ���ᮭ���)
  // arr_napr[5,1], arr_napr[5,2], arr_napr[5,3] - ����. �� ᠭ.-���. (��/���, 0, ����� ����� � �ࠢ�筨�� ���ᮭ���)

  local i, j, arr
  local arr_napr := Array( 5, 3 )

  for i := 1 to 5
    for j := 1 to 3
      arr_napr[ i, j ] := 0
    next
  next

  arr := read_arr_dispans( lkod )

  for i := 1 to len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      do case
        Case arr[ i, 1 ] == '47'
          // If ValType( arr[ i, 2 ] ) == 'N'
          //   m1dopo_na  := arr[ i, 2 ]
          // Elseif ValType( arr[ i, 2 ] ) == 'A'
          //   m1dopo_na  := arr[ i, 2 ][ 1 ]
          //   If arr[ i, 2 ][ 2 ] > 0
          //     TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
          //     mtab_v_dopo_na := TPERS->tab_nom
          //   Endif
          // Endif
          // arr_napr[ 1, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 1, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '50'
          arr_napr[ 5, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 5, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '52'
          arr_napr[ 2, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 2, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
          arr_napr[ 2, 2 ] := arr[ i, 2 ]
        Case arr[ i, 1 ] == '54'
          arr_napr[ 3, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 3, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
          arr_napr[ 3, 2 ] := arr[ i, 2 ]
        Case arr[ i, 1 ] == '56'
          arr_napr[ 4, 1 ] := arr[ i, 2 ][ 1 ]
          arr_napr[ 4, 3 ] := arr[ i, 2 ][ 2 ]
        Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
          arr_napr[ 4, 2 ] := arr[ i, 2 ]
      endcase
    endif
  next
  return arr_napr

// 01.08.24
function check_group_nazn( type, ... )
  // type - ⨯ �஢�ન ( '1' - ����, '2' - ��� ��� )
  // ��� �஢�ન �ᯮ������� PRIVATE ��६����:
  // m1gruppa - ��筠祭��� ��㯯� ���஢��
  // m1dopo_na - ���ࠢ����� �� �������⥫쭮� ��᫥�������
  // m1napr_v_mo - ���ࠢ����� � ᯥ樠���⠬ 
  // m1napr_stac - ���ࠢ����� �� ��祭��
  // m1napr_reab - ���ࠢ����� �� ॠ�������
  // m1sank_na - �� ������ � �஢�થ
  local ret := .f.
  local mvar, i
  local nfunc := 'eq_any( m1gruppa'

  type := substr( type, 1, 1 )
  if pcount() < 2
    return ret
  endif
  // ᮡ�६ �맮� �-樨
  for i := 2 to pcount()
    mvar := alltrim( str( hb_PValue( i ) ) )
    nfunc := nfunc + ', ' + mvar
  next
  nfunc += ')'

  if type == '1'
    ret := &nfunc .and. ( m1dopo_na == 0 ) .and. ( m1napr_v_mo == 0 ) .and. ( m1napr_stac == 0 ) .and. ( m1napr_reab == 0 )
  else
    ret := &nfunc .and. ( ( m1dopo_na != 0 ) .or. ( m1napr_v_mo != 0 ) .or. ( m1napr_stac != 0 ) .or. ( m1napr_reab != 0 ) )
  endif
  if ret
    if type == '1'
      func_error( 4, '��� ��࠭��� ������ �������� �롥�� �����祭�� (���ࠢ�����) ��� ��樥��!' )
    else
      func_error( 4, '�� ���ࠢ����� �� II �⠯ �� ����᪠���� �����祭�� (���ࠢ�����) ��� ��樥��!' )
    endif
  Endif
  return ret

// 04.07.24
function is_dispanserizaciya( ishod )

  // return ( Between( ishod, 101, 102 ) .or. ;  // ��ᯠ��ਧ��� ��⥩-��� � ��樮���� ��� ��ᯠ��ਧ��� ��⥩-��� ��� ������
  //       Between( ishod, 201, 205 ) .or. ;   // ��ᯠ��ਧ��� ���᫮�� ��ᥫ����
  //       Between( ishod, 301, 305 ) .or. ;   // ��䨫��⨪� ��ᮢ��襭����⭨�
  //       Between( ishod, 401, 402 ) .or. ;   // ��ᯠ��ਧ��� ��᫥ COVID-19
  //       Between( ishod, 501, 502) )         // ��ᯠ��ਧ��� ९த�⨢���� ���஢��
  return ( is_sluch_dispanser_deti_siroty( ishod ) .or. ; // ��ᯠ��ਧ��� ��⥩-��� � ��樮���� ��� ��ᯠ��ਧ��� ��⥩-��� ��� ������
    is_sluch_dispanser_DVN_prof( ishod ) .or. ;           // ��ᯠ��ਧ��� ���᫮�� ��ᥫ����
    is_sluch_dispanser_profilaktika_deti( ishod ) .or. ;  // ��䨫��⨪� ��ᮢ��襭����⭨�
    is_sluch_dispanser_COVID( ishod ) .or. ;              // ��ᯠ��ਧ��� ��᫥ COVID-19
    is_sluch_dispanser_DRZ( ishod ) )                     // ��ᯠ��ਧ��� ९த�⨢���� ���஢��

// 04.07.24 �� ��砩 ��ᯠ��ਧ��� ��⥩-���
function is_sluch_dispanser_deti_siroty( ishod )

  return Between( ishod, 101, 102)

// 04.07.24 �� ��砩 ��ᯠ��ਧ���/��䨫��⨪� ���᫮�� ��ᥫ����
function is_sluch_dispanser_DVN_prof( ishod )

  return Between( ishod, 201, 205)

// 04.07.24 �� ��砩 ��䨫��⨪� ��ᮢ��襭����⭨�
function is_sluch_dispanser_profilaktika_deti( ishod )

  return Between( ishod, 301, 305)

// 04.07.24 �� ��砩 ��ᯠ��ਧ�樨 ��᫥ COVID-19
function is_sluch_dispanser_COVID( ishod )

  return Between( ishod, 401, 402)

// 04.07.24 �� ��砩 ��ᯠ��ਧ�樨 ९த�⨢���� ���஢��
function is_sluch_dispanser_DRZ( ishod )

  return Between( ishod, 501, 502)

// 23.01.17
Function f_valid_diag_oms_sluch_dvn( get, k )

  Local sk := lstr( k )
  Private pole_diag := 'mdiag' + sk, ;
    pole_d_diag := 'mddiag' + sk, ;
    pole_pervich := 'mpervich' + sk, ;
    pole_1pervich := 'm1pervich' + sk, ;
    pole_stadia := 'm1stadia' + sk, ;
    pole_dispans := 'mdispans' + sk, ;
    pole_1dispans := 'm1dispans' + sk, ;
    pole_d_dispans := 'mddispans' + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 12 )
      &pole_1pervich := 0
      &pole_d_diag := CToD( '' )
      &pole_stadia := 1
      &pole_dispans := Space( 3 )
      &pole_1dispans := 0
      &pole_d_dispans := CToD( '' )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_dispans := inieditspr( A__MENUVERT, mm_danet, &pole_1dispans )
    Endif
  Endif
  If emptyall( m1dispans1, m1dispans2, m1dispans3, m1dispans4, m1dispans5 )
    m1dispans := 0
  Elseif m1dispans == 0
    m1dispans := ps1dispans
  Endif
  mdispans := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  update_get( pole_pervich )
  update_get( pole_d_diag )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_d_dispans )
  update_get( 'mdispans' )

  Return .t.

// 16.06.19 ࠡ��� �� ��㣠 (㬮�砭��) ��� � ����ᨬ��� �� �⠯�, ������ � ����
Function f_is_umolch_sluch_dvn( i, _etap, _vozrast, _pol )

  Local fl := .f., j, ta, ar := dvn_arr_umolch[ i ]

  If _etap > 3
    Return fl
  Endif
  If ValType( ar[ 3 ] ) == 'N'
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  If fl
    If _etap == 1
      i := iif( _pol == '�', 4, 5 )
    Else// if _etap == 3
      i := iif( _pol == '�', 6, 7 )
    Endif
    If ValType( ar[ i ] ) == 'N'
      fl := ( ar[ i ] != 0 )
    Elseif ValType( ar[ i ] ) == 'C'
      // '18,65' - ��� ��⪮�� ���.���.�������஢����
      ta := list2arr( ar[ i ] )
      For i := Len( ta ) To 1 Step -1
        If _vozrast >= ta[ i ]
          For j := 0 To 99
            If _vozrast == Int( ta[ i ] + j * 3 )
              fl := .t. ; Exit
            Endif
          Next
          If fl ; exit ; Endif
        Endif
      Next
    Else
      fl := Between( _vozrast, ar[ i, 1 ], ar[ i, 2 ] )
    Endif
  Endif

  Return fl

// 30.03.24
function arr_mm_napr_stac()

  local mm_napr_stac := { ;
        { '--- ��� ---', 0 }, ;
        { '� ��樮���', 1 }, ;
        { '� ��. ���.', 2 } ;
      }

  return AClone( mm_napr_stac )

// 30.03.24
function arr_mm_napr_v_mo()

  local mm_napr_v_mo := { ;
        { '-- ��� --', 0 }, ;
        { '� ���� ��', 1 }, ;
        { '� ���� ��', 2 } ;
      }

  return AClone( mm_napr_v_mo )

// 30.03.24
function arr_mm_pervich()

  local mm_pervich := { ;
        { '�����     ', 1 }, ;
        { '࠭�� ��.', 0 }, ;
        { '�।.�������', 2 } ;
      }

  return AClone( mm_pervich )

// 30.03.24
function arr_mm_dispans()

  local mm_dispans := { ;
        { '�� ��⠭������             ', 0 }, ;
        { '���⪮�� �࠯��⮬      ', 3 }, ;
        { '��箬 ��.���.��䨫��⨪�', 1 }, ;
        { '��箬 業�� ���஢��     ', 2 } ;
      }

  return AClone( mm_dispans )

// 30.03.24
function arr_mm_dopo_na()

  local mm_dopo_na := { ;
        { '���.�������⨪�', 1 }, ;
        { '�����.�������⨪�', 2 }, ;
        { '��祢�� �������⨪�', 3 }, ;
        { '��, ���, ���������', 4 } ;
      }

  return AClone( mm_dopo_na )

// 30.03.24
function arr_mm_otkaz()

  local mm_otkaz := { ;
        { '_�믮�����', 0 }, ;
        { '�⪫������', 3 }, ;
        { '����� ���.', 1 }, ;
        { '����������', 2 } ;
      }

  return AClone( mm_otkaz )

//30.03.24
function arr_mm_gruppaP()

  local mm_gruppaP := { ;
        { '��᢮��� I ��㯯� ���஢��'   , 1, 343 }, ;
        { '��᢮��� II ��㯯� ���஢��'  , 2, 344 }, ;
        { '��᢮��� III ��㯯� ���஢��' , 3, 345 }, ;
        { '��᢮��� III� ��㯯� ���஢��', 3, 373 }, ;
        { '��᢮��� III� ��㯯� ���஢��', 4, 374 } ;
      }

  return AClone( mm_gruppaP )

// 23.01.17
Function f_valid_vyav_diag_dispanser( get, k )

  Local sk := lstr( k )

  Private pole_diag := "mdiag" + sk, ;
    pole_d_diag := "mddiag" + sk, ;
    pole_pervich := "mpervich" + sk, ;
    pole_1pervich := "m1pervich" + sk, ;
    pole_stadia := "m1stadia" + sk, ;
    pole_dispans := "mdispans" + sk, ;
    pole_1dispans := "m1dispans" + sk, ;
    pole_d_dispans := "mddispans" + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 12 )
      &pole_1pervich := 0
      &pole_d_diag := CToD( "" )
      &pole_stadia := 1
      &pole_dispans := Space( 3 )
      &pole_1dispans := 0
      &pole_d_dispans := CToD( "" )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_dispans := inieditspr( A__MENUVERT, mm_danet, &pole_1dispans )
    Endif
  Endif
  If emptyall( m1dispans1, m1dispans2, m1dispans3, m1dispans4, m1dispans5 )
    m1dispans := 0
  Elseif m1dispans == 0
    m1dispans := ps1dispans
  Endif
  mdispans := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  update_get( pole_pervich )
  update_get( pole_d_diag )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_d_dispans )
  update_get( "mdispans" )

  Return .t.

// 30.03.24 - ���������� ᯨ᪠ ������� ��������� �� ��ᯠ��ਧ�樨
function dispans_vyav_diag( /*@*/j, mndisp )

  // j - ���稪 ��ப �� ��࠭�
  // mndisp - ��������� ���� ��ᯭ�ਧ�樨
  // �ᯮ������� PRIVATE-��६����
  local pic_diag := '@K@!'
  Local bg := {| o, k | get_mkb10( o, k, .t. ) }

  @ ++j, 8 Get mndisp When .f. Color color14

  @ ++j, 1  Say '������������������������������������������������������������������������������'
  @ ++j, 1  Say '       �  �����  �   ���   ��⠤����⠭������ ��ᯠ��୮� ��� ᫥���饣�'
  @ ++j, 1  Say '������������������� ������� ������.��������     (�����)     �����'
  @ ++j, 1  Say '������������������������������������������������������������������������������'
  // 2      9            22           35       44        54
  @ ++j, 2  Get mdiag1 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 1 ), ;
    .f. ) }
  @ j, 9  Get mpervich1 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag1 )
  @ j, 22 Get mddiag1 When !Empty( mdiag1 )
  @ j, 35 Get m1stadia1 Pict '9' Range 1, 4 ;
    When !Empty( mdiag1 )
  @ j, 44 Get mdispans1 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag1 )
  @ j, 54 Get mddispans1 When m1dispans1 == 1
  @ j, 67 Get mdndispans1 When m1dispans1 == 1
  //
  @ ++j, 2  Get mdiag2 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 2 ), ;
    .f. ) }
  @ j, 9  Get mpervich2 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag2 )
  @ j, 22 Get mddiag2 When !Empty( mdiag2 )
  @ j, 35 Get m1stadia2 Pict '9' Range 1, 4 ;
    When !Empty( mdiag2 )
  @ j, 44 Get mdispans2 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag2 )
  @ j, 54 Get mddispans2 When m1dispans2 == 1
  @ j, 67 Get mdndispans2 When m1dispans2 == 1
  //
  @ ++j, 2  Get mdiag3 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 3 ), ;
    .f. ) }
  @ j, 9  Get mpervich3 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag3 )
  @ j, 22 Get mddiag3 When !Empty( mdiag3 )
  @ j, 35 Get m1stadia3 Pict '9' Range 1, 4 ;
    When !Empty( mdiag3 )
  @ j, 44 Get mdispans3 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag3 )
  @ j, 54 Get mddispans3 When m1dispans3 == 1
  @ j, 67 Get mdndispans3 When m1dispans3 == 1
  //
  @ ++j, 2  Get mdiag4 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 4 ), ;
    .f. ) }
  @ j, 9  Get mpervich4 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag4 )
  @ j, 22 Get mddiag4 When !Empty( mdiag4 )
  @ j, 35 Get m1stadia4 Pict '9' Range 1, 4 ;
    When !Empty( mdiag4 )
  @ j, 44 Get mdispans4 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag4 )
  @ j, 54 Get mddispans4 When m1dispans4 == 1
  @ j, 67 Get mdndispans4 When m1dispans4 == 1
  //
  @ ++j, 2  Get mdiag5 Picture pic_diag ;
    reader {| o| mygetreader( o, bg ) } ;
    valid  {| g| iif( val1_10diag( .t., .f., .f., mn_data, mpol ), ;
    f_valid_vyav_diag_dispanser( g, 5 ), ;
    .f. ) }
  @ j, 9  Get mpervich5 ;
    reader {| x| menu_reader( x, mm_pervich, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag5 )
  @ j, 22 Get mddiag5 When !Empty( mdiag5 )
  @ j, 35 Get m1stadia5 Pict '9' Range 1, 4 ;
    When !Empty( mdiag5 )
  @ j, 44 Get mdispans5 ;
    reader {| x| menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) } ;
    When !Empty( mdiag5 )
  @ j, 54 Get mddispans5 When m1dispans5 == 1
  @ j, 67 Get mdndispans5 When m1dispans5 == 1
  //
  @ ++j, 1 Say Replicate( '�', 78 ) Color color1

  return nil