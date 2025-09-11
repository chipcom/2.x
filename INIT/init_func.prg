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
      arr_sem[ arr[ i, 2 ] ] := 'Важный режим в задаче "' + arr[ i, 5 ] + '"'
    next
  endif
  return arr_sem

// 11.09.25
function array_tasks()

  static arr_tasks
  local i, k

  if HB_ISNIL( arr_tasks )
    arr_tasks := {}
    AAdd( arr_tasks, { 'Регистратура поликлиники', X_REGIST, , .t., 'РЕГИСТРАТУРА' } )
    AAdd( arr_tasks, { 'Приёмный покой стационара', X_PPOKOJ, , .t., 'ПРИЁМНЫЙ ПОКОЙ' } )
    AAdd( arr_tasks, { 'Обязательное медицинское страхование', X_OMS, , .t., 'ОМС' } )
    AAdd( arr_tasks, { 'Учёт направлений на госпитализацию', X_263, , .f., 'ГОСПИТАЛИЗАЦИЯ' } )
    AAdd( arr_tasks, { 'Платные услуги', X_PLATN, , .t., 'ПЛАТНЫЕ УСЛУГИ' } )
    AAdd( arr_tasks, { 'Ортопедические услуги в стоматологии', X_ORTO, , .t., 'ОРТОПЕДИЯ' } )
    AAdd( arr_tasks, { 'Касса медицинской организации', X_KASSA, , .t., 'КАССА' } )
//    AAdd( arr_tasks, { 'КЭК медицинской организации', X_KEK, , .f., 'КЭК' } )
    If glob_mo()[ _MO_KOD_TFOMS ] == TF_KOD_MO_VOUNC
      AAdd( arr_tasks, { 'ВОУНЦ - трансплантированные', X_MO, 'TABLET_ICON', .t. } )
    Endif
    AAdd( arr_tasks, { 'Редактирование справочников', X_SPRAV, , .t. } )
    AAdd( arr_tasks, { 'Сервисы и настройки', X_SERVIS, , .t. } )
    AAdd( arr_tasks, { 'Резервное копирование базы данных', X_COPY, , .t. } )
    AAdd( arr_tasks, { 'Переиндексирование базы данных', X_INDEX, , .t. } )

    for i := 1 to len( arr_tasks )
      If ( k := arr_tasks[ i, 2 ] ) < 10  // код задачи
        arr_tasks[ i, 4 ] := ( SubStr( glob_mo()[ _MO_PROD ], k, 1 ) == '1' )
      Endif
      // Учёт направлений на госпитализацию
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
        { '103001', 1, 'г.Волгоград, ул.Землячки, д.78' }, ;
        { '103099', 2, 'г.Михайловка, ул.Мичурина, д.8' }, ;
        { '103099', 3, 'г.Волжский, ул.Комсомольская, д.25' }, ;
        { '103099', 4, 'г.Волжский, ул.Оломоуцкая, д.33' }, ;
        { '103099', 5, 'г.Камышин, ул.Днепровская, д.43' }, ;
        { '103099', 6, 'г.Камышин, ул.Мира, д.51' }, ;
        { '103099', 7, 'г.Урюпинск, ул.Фридек-Мистек, д.8' } ;
        };
      }, ;
      { '101003', ;
        { ;
          { '101003', 1, 'г.Волгоград, ул.Циолковского, д.1' }, ;
          { '101099', 2, 'г.Волгоград, ул.Советская, д.47' } ;
        };
      }, ;
      { '131001', ;
        { ;
          { '131001', 1, 'г.Волгоград, ул.Кирова, д.10' }, ;
          { '131099', 2, 'г.Волгоград, ул.Саши Чекалина, д.7' }, ;
          { '131099', 3, 'г.Волгоград, ул.им.Федотова, д.18' } ;
        };
      }, ;
      { '171004', ;
        { ;
          { '171004', 1, 'г.Волгоград, ул.Ополченская, д.40' }, ;
          { '171099', 2, 'г.Волгоград, ул.Тракторостроителей, д.13' } ;
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
    hashColor[ 'cColorWait' ] := 'W+/R*, , , , B/W'                 // Ждите
    //
    hashColor[ 'cCalcMain' ] := 'N/W, GR+/R'                     // Калькулятор
    //
    hashColor[ 'cColorText' ] := 'W+/N, BG+/N, , , B/W'
    //
    hashColor[ 'cHelpCMain' ] := 'W+/RB, W+/N, , , B/W'             // Помощь
    hashColor[ 'cHelpCTitle' ] := 'G+/RB'
    hashColor[ 'cHelpCStatus' ] := 'BG+/RB'
    // Ввод данных
    hashColor[ 'cDataCScr' ]  := 'W+/B, B/BG'
    hashColor[ 'cDataCGet' ]  := 'W+/B, W+/R, , , BG+/B'
    hashColor[ 'cDataCSay' ]  := 'BG+/B, W+/R, , , BG+/B'
    hashColor[ 'cDataCMenu' ] := 'N/BG, W+/N, , , B/W'
    hashColor[ 'cDataPgDn' ]  := 'BG/B'
    hashColor[ 'color5' ]     := 'N/W, GR+/R, , , B/W'
    hashColor[ 'color8' ]     := 'GR+/B, W+/R'
    hashColor[ 'color13' ]    := 'W/B, W+/R, , , BG+/B'             // некотоpое выделение
    hashColor[ 'color14' ]    := 'G+/B, W+/R'
  endif
  return hashColor