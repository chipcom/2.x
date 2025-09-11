#include 'common.ch'
#include 'hbhash.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 11.09.25
function is_napr_pol( param )

  static lIs_napr_pol

  if HB_ISNIL( lIs_napr_pol )
    lIs_napr_pol := .f.
  endif
  if ! HB_ISNIL( param ) .and. ValType( param ) == 'L'
    lIs_napr_pol := param
  endif
  return lIs_napr_pol
  
// 11.09.25
function is_napr_stac( param )

  static lIs_napr_stac

  if HB_ISNIL( lIs_napr_stac )
    lIs_napr_stac := .f.
  endif
  if ! HB_ISNIL( param ) .and. ValType( param ) == 'L'
    lIs_napr_stac := param
  endif
  return lIs_napr_stac

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

// 11.09.25
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
      If k == X_263 .and. ( is_napr_pol() .or. is_napr_stac() ) // .and. ( substr( glob_mo()[ _MO_PROD ], X_263, 1 ) == '1' )
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

// 11.09.25
function glob_MU_dializ()

  local arr := {}     // 'A18.05.002.001','A18.05.002.002','A18.05.002.003', ;
  // 'A18.05.003','A18.05.003.001','A18.05.011','A18.30.001','A18.30.001.001'}

  return arr

// 11.09.25
function glob_KSG_dializ()

  local arr := {}     // '10000901','10000902','10000903','10000905','10000906','10000907','10000913', ;
  // '20000912','20000916','20000917','20000918','20000919','20000920'}
  // '1000901','1000902','1000903','1000905','1000906','1000907','1000913', ;
  // '2000912','2000916','2000917','2000918','2000919','2000920'}

  return arr

// 11.09.25
function is_alldializ( param )

  static is_dial

  if isnil( is_dial )
    is_dial := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_dial := param
  endif
  return is_dial

// 11.09.25
function is_dop_ob_em()

  static is_dop

  if isnil( is_dop )
    is_dop := .f.
  endif
  return is_dop

// 11.09.25
function is_reabil_slux( param )

  static is_reab

  if isnil( is_reab )
    is_reab := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_reab := param
  endif
  return is_reab

// 11.09.25
function is_hemodializ( param )

  static is_hemo

  if isnil( is_hemo )
    is_hemo := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_hemo := param
  endif
  return is_hemo

// 11.09.25
function is_per_dializ( param )

  static is_per

  if isnil( is_per )
    is_per := .f.
  endif
  if PCount() != 0 .and. ValType( param ) == 'L'
    is_per := param
  endif
  return is_per

// 11.09.25
function glob_menu_mz_rf( index, param )

  static glob_menu

  if isnil( glob_menu )
    glob_menu := { .f., .f., .f. }
  endif
  if PCount() == 2 .and. ( ValType( index ) == 'N' ) .and. ( ValType( param ) == 'L' )
    glob_menu[ index ] := param
  endif
  return glob_menu

// 11.09.25
function hColor()

  static hashColor

  if HB_ISNIL( hashColor )
    hashColor := { => }
    hb_HCaseMatch( hashColor, .f. )
    hashColor[ 'color0' ] := 'N/BG, W+/N'
    hashColor[ 'color1' ] := 'W+/B, W+/R'
    hashColor[ 'color_uch' ] := 'B/BG, W+/B'
    hashColor[ 'col_tit_uch' ] := 'B+/BG'
    hashColor[ 'col1menu' ] := 'N/BG, W+/N, B/BG, BG+/N'
    hashColor[ 'col2menu' ] := 'N/BG, W+/N, B/BG, BG+/N'
    hashColor[ 'col_tit_popup' ] := 'B/BG'
    //
    hashColor[ 'cColorStMsg' ] := 'W+/R, , , , B/W'                 // Stat_msg
    hashColor[ 'cColorSt1Msg' ] := 'W+/R, , , , B/W'                // Stat_msg
    hashColor[ 'cColorSt2Msg' ] := 'GR+/R, , , , B/W'               // Stat_msg
    hashColor[ 'cColorWait' ] := 'W+/R*, , , , B/W'                 // ����
    //
    hashColor[ 'cCalcMain' ] := 'N/W, GR+/R'                     // ��������
    //
    hashColor[ 'cColorText' ] := 'W+/N, BG+/N, , , B/W'
    //
    hashColor[ 'cHelpCMain' ] := 'W+/RB, W+/N, , , B/W'             // ������
    hashColor[ 'cHelpCTitle' ] := 'G+/RB'
    hashColor[ 'cHelpCStatus' ] := 'BG+/RB'
    // ���� ������
    hashColor[ 'cDataCScr' ]  := 'W+/B, B/BG'
    hashColor[ 'cDataCGet' ]  := 'W+/B, W+/R, , , BG+/B'
    hashColor[ 'cDataCSay' ]  := 'BG+/B, W+/R, , , BG+/B'
    hashColor[ 'cDataCMenu' ] := 'N/BG, W+/N, , , B/W'
    hashColor[ 'cDataPgDn' ]  := 'BG/B'
    hashColor[ 'color5' ]     := 'N/W, GR+/R, , , B/W'
    hashColor[ 'color8' ]     := 'GR+/B, W+/R'
    hashColor[ 'color13' ]    := 'W/B, W+/R, , , BG+/B'             // �����p�� �뤥�����
    hashColor[ 'color14' ]    := 'G+/B, W+/R'
  endif
  return hashColor