#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 10.09.25
function sem_vagno_task()

  static arr_sem
  local i, arr

  if HB_ISNIL( arr_sem )
    arr_sem := Array( 24 )
    AFill( arr_sem, '' )
    arr := array_tasks()
    for i := 1 to 7
      arr_sem[ arr[ i, 2 ] ] := '����� ०�� � ����� "' + arr[ i, 5 ] + '"'
    next
  endif
  return arr_sem

// 10.09.25
function array_tasks()

  static arr_tasks
  local i, k

  if HB_ISNIL( arr_tasks )
    arr_tasks := {}
    AAdd( arr_tasks, { '���������� �����������', X_REGIST, , .t., '������������' } )
    AAdd( arr_tasks, { '���� ����� ��樮���', X_PPOKOJ, , .t., '�������� �����' } )
    AAdd( arr_tasks, { '��易⥫쭮� ����樭᪮� ���客����', X_OMS, , .t., '���' } )
    AAdd( arr_tasks, { '���� ���ࠢ����� �� ��ᯨ⠫�����', X_263, , .f., '��������������' } )
    AAdd( arr_tasks, { '����� ��㣨', X_PLATN, , .t., '������� ������' } )
    AAdd( arr_tasks, { '��⮯����᪨� ��㣨 � �⮬�⮫����', X_ORTO, , .t., '���������' } )
    AAdd( arr_tasks, { '���� ����樭᪮� �࣠����樨', X_KASSA, , .t., '�����' } )
//    AAdd( arr_tasks, { '��� ����樭᪮� �࣠����樨', X_KEK, , .f., '���' } )
    If glob_mo()[ _MO_KOD_TFOMS ] == TF_KOD_MO_VOUNC
      AAdd( arr_tasks, { '����� - �࠭ᯫ���஢����', X_MO, 'TABLET_ICON', .t. } )
    Endif
    AAdd( arr_tasks, { '������஢���� �ࠢ�筨���', X_SPRAV, , .t. } )
    AAdd( arr_tasks, { '��ࢨ�� � ����ன��', X_SERVIS, , .t. } )
    AAdd( arr_tasks, { '����ࢭ�� ����஢���� ���� ������', X_COPY, , .t. } )
    AAdd( arr_tasks, { '��२�����஢���� ���� ������', X_INDEX, , .t. } )

    for i := 1 to len( arr_tasks )
      If ( k := arr_tasks[ i, 2 ] ) < 10  // ��� �����
        arr_tasks[ i, 4 ] := ( SubStr( glob_mo()[ _MO_PROD ], k, 1 ) == '1' )
      Endif
      // ���� ���ࠢ����� �� ��ᯨ⠫�����
      If k == X_263 .and. ( is_napr_pol .or. is_napr_stac ) // .and. ( substr( glob_mo()[ _MO_PROD ], X_263, 1 ) == '1' )
        arr_tasks[ i, 4 ] := .t.
      Endif
    next
  endif
  return arr_tasks

// 09.09.25
function glob_adres_podr()

  static arr_address

  if isnil( arr_address )
    arr_address := { ;
      { '103001', { ;
        { '103001', 1, '�.������ࠤ, �.�����窨, �.78' }, ;
        { '103099', 2, '�.��堩�����, �.����ਭ�, �.8' }, ;
        { '103099', 3, '�.����᪨�, �.���ᮬ���᪠�, �.25' }, ;
        { '103099', 4, '�.����᪨�, �.������檠�, �.33' }, ;
        { '103099', 5, '�.����設, �.����஢᪠�, �.43' }, ;
        { '103099', 6, '�.����設, �.���, �.51' }, ;
        { '103099', 7, '�.����, �.�ਤ��-���⥪, �.8' } ;
        };
      }, ;
      { '101003', ;
        { ;
          { '101003', 1, '�.������ࠤ, �.�������᪮��, �.1' }, ;
          { '101099', 2, '�.������ࠤ, �.�����᪠�, �.47' } ;
        };
      }, ;
      { '131001', ;
        { ;
          { '131001', 1, '�.������ࠤ, �.��஢�, �.10' }, ;
          { '131099', 2, '�.������ࠤ, �.��� ��������, �.7' }, ;
          { '131099', 3, '�.������ࠤ, �.��.����⮢�, �.18' } ;
        };
      }, ;
      { '171004', ;
        { ;
          { '171004', 1, '�.������ࠤ, �.����祭᪠�, �.40' }, ;
          { '171099', 2, '�.������ࠤ, �.�ࠪ����ந⥫��, �.13' } ;
        };
      };
    }
  endif
  return arr_address
  
// 09.09.25
function glob_arr_mo( reload )

  static arr_mo
  local dbName := '_mo_mo'

  if isnil( arr_mo )
    create_mo_add()
    arr_mo := getmo_mo( dbName )
  elseif ! isnil( reload ) .and. reload
    arr_mo := getmo_mo( dbName, reload )
  endif
  return arr_mo

// 09.09.25
function is_adres_podr( param )

  static lAddressPodr

  if isnil( lAddressPodr )
    lAddressPodr := .f.
  else
    lAddressPodr := param
  endif
  return lAddressPodr

// 09.09.25
function glob_mo( param )

  static mo

  if isnil( mo ) .and. ValType( param ) == 'A'
    mo := param
  endif
  return mo
