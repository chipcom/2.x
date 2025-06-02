#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 02.06.25 �ࠢ�筨� ���客�� �������� � ������ࠤ᪮� ������
function smo_volgograd()

  static arr_smo

  if HB_ISNIL( arr_smo )
    arr_smo := { ;
      { '��� ��� "����⠫ ��"-䨫��� � ������ࠤ᪮� ������',    34007, 1 }, ;
      { '��� "�����-���"',        34002, 1 }, ;
      { '�� ��� ���.���客����', 34003, 0 }, ;  // �� ࠡ�⠥�
      { '��� "���-�����न�"',   34004, 0 }, ;  // �� ࠡ�⠥�
      { '����⠫� �������',      34001, 0 }, ;
      { '��� "���-���ᨬ��"',     34006, 0 }, ;
      { '����� (�����த���)',   34, 1 } ;
    }
  Endif
  return arr_smo

// 02.06.25 �ࠢ�筨� ���客�� �������� ��
function glob_array_srf( dir_spavoch, working_dir )

  // dir_spavoch - ��⠫�� �ᯮ������� �ࠢ�筨��� ��⥬�
  // working_dir - ࠡ�稩 ��⠫�� � ���஬ �࠭���� ࠡ�稥 䠩�� ���짮��⥫�

  static arr_srf
  local sbase

  if HB_ISNIL( arr_srf )
    sbase := '_mo_smo'
    arr_srf := {}
    r_use( dir_spavoch + sbase )
    Index On okato to ( working_dir + sbase ) UNIQUE
    dbEval( {|| AAdd( arr_srf, { '', field->okato } ) } )
    Index On okato + smo to ( working_dir + sbase )
    Index On smo to ( working_dir + sbase + '2' )
    Index On okato + ogrn to ( working_dir + sbase + '3' )
    Use

    dbCreate( working_dir + 'tmp_srf', { { 'okato', 'C', 5, 0 }, { 'name', 'C', 80, 0 } } )
    Use ( working_dir + 'tmp_srf' ) New Alias TMP
    r_use( dir_spavoch + '_okator', working_dir + '_okatr', 'RE' )
    r_use( dir_spavoch + '_okatoo', working_dir + '_okato', 'OB' )
    For i := 1 To Len( arr_srf )
      Select OB
      find ( arr_srf[ i, 2 ] )
      If Found()
        arr_srf[ i, 1 ] := RTrim( ob->name )
      Else
        Select RE
        find ( Left( arr_srf[ i, 2 ], 2 ) )
        If Found()
          arr_srf[ i, 1 ] := RTrim( re->name )
        Elseif Left( arr_srf[ i, 2 ], 2 ) == '55'
          arr_srf[ i, 1 ] := '�.��������'
        Endif
      Endif
      Select TMP
      Append Blank
      tmp->okato := arr_srf[ i, 2 ]
      tmp->name  := iif( SubStr( arr_srf[ i, 2 ], 3, 1 ) == '0', '', '  ' ) + arr_srf[ i, 1 ]
    Next
    OB->( dbCloseArea() )
    RE->( dbCloseArea() )
    TMP->( dbCloseArea() )
  endif
  return arr_srf