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
      arr_sem[ arr[ i, 2 ] ] := 'Важный режим в задаче "' + arr[ i, 5 ] + '"'
    next
  endif
  return arr_sem

// 10.09.25
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
