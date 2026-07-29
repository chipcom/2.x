// insurance_companies.prg - функции работы со страховыми компаниями
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

#require 'hbsqlit3'

// =========== F002 =================== 
//
// TF_OKATO,  "C", 5, 0  // Код субъекта РФ по ОКАТО
// SMOCOD,    "C", 5, 0  // Код СМО в ЕРСМО
// NAM_SMOP,  "C", 1000, 0 // Наименование организации (полное)
// NAM_SMOK,  "C", 250, 0 // Наименование организации (краткое)
// INN,       "C", 12, 0  // ИНН
// OGRN,      "C", 15, 0  // ОГРН
// ORG,       "N", 1, 0  // Тип организации: 1 ? головная; 2 ? филиал

// 28.05.26 вернуть массив справочнику ФФОМС F019.xml
Function get_SMO_OKATO_OGRN_f002( mOKATO, mOGRN )

  // возвращает массив
  Static _arr
  Local db
  Local aTable
  local cmd

  _arr := {}
  db := opensql_db()
  cmd := 'SELECT tf_okato, smocod, nam_smop, nam_smok, inn, ogrn FROM f002 where tf_okato=="' + mOKATO +  '" and ogrn=="' + SubStr( mOGRN, 1, 13 ) + '"'
  aTable := sqlite3_get_table( db, cmd )
  If Len( aTable ) > 1
    // берем вторую сторку
    AAdd( _arr, aTable[ 2, 1 ] )
    AAdd( _arr, aTable[ 2, 2 ] )
    AAdd( _arr, Alltrim( aTable[ 2, 3 ] ) )
    AAdd( _arr, Alltrim( aTable[ 2, 4 ] ) )
    AAdd( _arr, aTable[ 2, 5 ] )
    AAdd( _arr, aTable[ 2, 6 ] )
  Endif
  db := nil

  Return _arr

Function findSMO_in_f002( code )

  // возвращает array
  Static _arr
  Local db
  Local aTable
  Local cmd

  _arr := {}
  db := opensql_db()
  cmd := 'SELECT tf_okato, smocod, nam_smop, nam_smok, inn, ogrn FROM f002 where smocod=="' + code +  '"'
//  cmd := 'SELECT tf_okato, orgtype, orgcod, nam_orgp, nam_orgk, tf_kod, smocod FROM f019 where smocod=="' + code + '"'
  aTable := sqlite3_get_table( db, cmd )
  If Len( aTable ) > 1
    // берем вторую сторку
    AAdd( _arr, aTable[ 2, 1 ] )
    AAdd( _arr, '' )  //  aTable[ 2, 2 ] )
    AAdd( _arr, '' )  //  val( aTable[ 2, 3 ] ) )
    AAdd( _arr, Alltrim( aTable[ 2, 3 ] ) )
    AAdd( _arr, Alltrim( aTable[ 2, 4 ] ) )
    AAdd( _arr, '' )    //  aTable[ 2, 1 ] )
    AAdd( _arr, aTable[ 2, 2 ] )
  Endif
  db := nil

  Return _arr

// 28.05.26 вернуть массив справочнику ФФОМС F019.xml
Function get_SMO_OKATO_f002( code )

  // возвращает массив
  Static _arr
  Local db
  Local aTable
  Local nI
  local cmd

  _arr := {}
  db := opensql_db()
  cmd := 'SELECT tf_okato, smocod, nam_smop, nam_smok, inn, ogrn FROM f002 where tf_okato=="' + code +  '"'
  aTable := sqlite3_get_table( db, cmd )
  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      AAdd( _arr, { aTable[ nI, 1 ], ;
        '', ;
        '', ;
        Alltrim( aTable[ nI, 3 ] ), ;
        Alltrim( aTable[ nI, 4 ] ), ;
        '', ;
        aTable[ nI, 2 ] } )
//      AAdd( _arr, { aTable[ nI, 1 ], ;
//        aTable[ nI, 2 ], ;
//        val( aTable[ nI, 3 ] ), ;
//        Alltrim( aTable[ nI, 4 ] ), ;
//        Alltrim( aTable[ nI, 5 ] ), ;
//        aTable[ nI, 6 ], ;
//        aTable[ nI, 7 ] } )
    Next
  Endif
  db := nil

  Return _arr

// =========== F019 =================== 
//
// F019.xml - Справочник организаций, осуществляющих оплату медицинской помощи по обязательному медицинскому страхованию (РersAccOrg)
// TF_OKATO,  "C", 5, 0  // Код субъекта РФ по ОКАТО
// ORGTYPE,  "C", 1, 0  // Тип организации: 0 ? ФОМС; 1 ? ТФОМС; 2 ? СМО
// ORGCOD,    "N", 5, 0  // Уникальный порядковый номер организации в справочнике
// NAM_ORGP,  "C", 250, 0 // Наименование организации (полное)
// NAM_ORGK,  "C", 250, 0 // Наименование организации (краткое)
// TF_KOD,    "C", 2, 0  // Код ТФОМС из Справоч?ника территориальных фондов ОМС (F001)
// SMOCOD,    "C", 5, 0  // Код СМО в ЕРСМО
// DATEBEG,   "D",   8, 0  // Дата начала действия записи
// DATEEND,   "D",   8, 0   // Дата окончания действия записи

// 28.05.26 вернуть массив справочнику ФФОМС F014.xml
Function getf019()

  // возвращает массив
  Static _arr
  Local db
  Local aTable
  Local nI

  _arr := {}
  db := opensql_db()
  aTable := sqlite3_get_table( db, 'SELECT tf_okato, orgtype, orgcod, nam_orgp, nam_orgk, tf_kod, smocod FROM f019' )
  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      AAdd( _arr, { aTable[ nI, 1 ], ;
        aTable[ nI, 2 ], ;
        val( aTable[ nI, 3 ] ), ;
        Alltrim( aTable[ nI, 4 ] ), ;
        Alltrim( aTable[ nI, 5 ] ), ;
        aTable[ nI, 6 ], ;
        aTable[ nI, 7 ] } )
    Next
  Endif
  db := nil

  Return _arr

// 03.06.26
Function findSMO_in_f019( code )

  // возвращает array
  Static _arr
  Local db
  Local aTable
  Local cmd

  _arr := {}
  db := opensql_db()
  cmd := 'SELECT tf_okato, orgtype, orgcod, nam_orgp, nam_orgk, tf_kod, smocod FROM f019 where smocod=="' + code + '" or orgcod=="' + code + '"'
  // для новых территорий берем код ТФОМС orgcod как код СМО, разговор с Антоновой 03.06.26
  aTable := sqlite3_get_table( db, cmd )
  If Len( aTable ) > 1
    // берем вторую сторку
    AAdd( _arr, aTable[ 2, 1 ] )
    AAdd( _arr, aTable[ 2, 2 ] )
    AAdd( _arr, val( aTable[ 2, 3 ] ) )
    AAdd( _arr, Alltrim( aTable[ 2, 4 ] ) )
    AAdd( _arr, Alltrim( aTable[ 2, 5 ] ) )
    AAdd( _arr, aTable[ 2, 6 ] )
    AAdd( _arr, aTable[ 2, 7 ] )
  Endif
  db := nil

  Return _arr

// 03.06.26 вернуть массив справочнику ФФОМС F019.xml
Function get_SMO_OKATO_f019( code )

  // возвращает массив
  Static _arr
  Local db
  Local aTable
  Local nI
  local cmd

  _arr := {}
  Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
  db := opensql_db()
//  cmd := 'SELECT tf_okato, orgtype, orgcod, nam_orgp, nam_orgk, tf_kod, smocod FROM f019 where orgtype=="2" and tf_okato=="' + code + '"'
  cmd := 'SELECT tf_okato, orgtype, orgcod, nam_orgp, nam_orgk, tf_kod, smocod FROM f019 where tf_okato=="' + code + '"'
  // для новых территорий берем код ТФОМС orgcod как код СМО, разговор с Антоновой 03.06.26
  aTable := sqlite3_get_table( db, cmd )
  If Len( aTable ) > 1
    For nI := 2 To Len( aTable )
      AAdd( _arr, { ;
        Alltrim( aTable[ nI, 5 ] ), ;
        iif( Empty( aTable[ nI, 7 ] ), aTable[ nI, 3 ], aTable[ nI, 7 ] ) } )
//      AAdd( _arr, { ;
//        aTable[ nI, 1 ], ;
//        aTable[ nI, 2 ], ;
//        val( aTable[ nI, 3 ] ), ;
//        Alltrim( aTable[ nI, 4 ] ), ;
//        Alltrim( aTable[ nI, 5 ] ), ;
//        aTable[ nI, 6 ], ;
//        aTable[ nI, 7 ] } )
    Next
  Endif
  db := nil
  Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )

  Return _arr

// 02.06.25 справочник страховых компаний в Волгоградской области
function smo_volgograd()

  static arr_smo

  if HB_ISNIL( arr_smo )
    arr_smo := { ;
      { 'АСП ООО "Капитал МС"-филиал в Волгоградской области',    34007, 1 }, ;
      { 'ОАО "СОГАЗ-Мед"',        34002, 1 }, ;
      { 'АО ВТБ Мед.страхование', 34003, 0 }, ;  // не работает
      { 'ООО "ВСК-Милосердие"',   34004, 0 }, ;  // не работает
      { 'КапиталЪ Медстрах',      34001, 0 }, ;
      { 'ООО "МСК-Максимус"',     34006, 0 }, ;
      { 'ТФОМС (иногородние)',   34, 1 } ;
    }
  Endif
  return arr_smo

// 15.09.25 справочник страховых компаний РФ
//function glob_array_srf( dir_spavoch, working_dir )
function glob_array_srf()

  // dir_spavoch - каталог расположения справочников системы
  // working_dir - рабочий каталог в котором хранятся рабочие файлы пользователя

  static arr_srf
  Local db
  Local aTable
  Local nI
  local cmd
  local d := Date()
//  local sbase, i

  if HB_ISNIL( arr_srf )
    arr_srf := {}

    Set( _SET_DATEFORMAT, 'yyyy-mm-dd' )
    db := opensql_db()
    cmd := 'SELECT kod_okato, subname, dateBeg, dateend FROM f010'
    aTable := sqlite3_get_table( db, cmd )
    If Len( aTable ) > 1
      For nI := 2 To Len( aTable )
        if between_date( CToD( aTable[ nI, 3 ] ), CToD( aTable[ nI, 4 ] ), d )
          AAdd( arr_srf, { ;
            Alltrim( aTable[ nI, 2 ] ), ;
            Alltrim( aTable[ nI, 1 ] ) } )
        endif
      Next
    Endif
    db := nil
    Set( _SET_DATEFORMAT, 'dd.mm.yyyy' )
/*
    sbase := '_mo_smo'
    r_use( dir_spavoch + sbase )
    Index On FIELD->okato to ( working_dir + sbase ) UNIQUE
    dbEval( {|| AAdd( arr_srf, { '', FIELD->okato } ) } )
    Index On FIELD->okato + FIELD->smo to ( working_dir + sbase )
    Index On FIELD->smo to ( working_dir + sbase + '2' )
    Index On FIELD->okato + FIELD->ogrn to ( working_dir + sbase + '3' )
    Use

    dbCreate( working_dir + 'tmp_srf', { { 'okato', 'C', 5, 0 }, { 'name', 'C', 80, 0 } } )
    Use ( working_dir + 'tmp_srf' ) New Alias TMP
    r_use( dir_spavoch + '_okator', working_dir + '_okatr', 'RE' )
    r_use( dir_spavoch + '_okatoo', working_dir + '_okato', 'OB' )
    For i := 1 To Len( arr_srf )
      ob->( dbSeek( arr_srf[ i, 2 ] ) )
      If ob->( Found() )
        arr_srf[ i, 1 ] := RTrim( ob->name )
      Else
        re->( dbSeek( Left( arr_srf[ i, 2 ], 2 ) ) )
        If re->( Found() )
          arr_srf[ i, 1 ] := RTrim( re->name )
        Elseif Left( arr_srf[ i, 2 ], 2 ) == '55'
          arr_srf[ i, 1 ] := 'г.Байконур'
        Endif
      Endif
      tmp->( dbAppend() )
      tmp->okato := arr_srf[ i, 2 ]
      tmp->name  := iif( SubStr( arr_srf[ i, 2 ], 3, 1 ) == '0', '', '  ' ) + arr_srf[ i, 1 ]
    Next
    OB->( dbCloseArea() )
    RE->( dbCloseArea() )
    TMP->( dbCloseArea() )
*/
  endif

  return arr_srf

// 18.11.25 вернуть иногороднюю СМО
Function ret_inogsmo_name( ltip, /*@*/rec, fl_close)

  Local s := Space( 100 ), fl := .f., tmp_select := Select()

  Default fl_close To .f.
  If Select( 'SN' ) == 0
    r_use( dir_server() + iif( ltip == 1, 'mo_kismo', 'mo_hismo' ), , 'SN' )
    Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
    fl := .t.
  Endif
//  Select SN
  sn->( dbSeek( Str( iif( ltip == 1, kart->kod, human->kod ), 7 ) ) ) // find ( Str( iif( ltip == 1, kart->kod, human->kod ), 7 ) )
  If sn->( Found() )
    s := sn->SMO_NAME
    rec := sn->( RecNo() )
  Endif
  If fl .and. fl_close
    sn->( dbCloseArea() )
  Endif
  Select ( tmp_select )

  Return s

// 17.11.25 СМО на экран (печать)
Function smo_to_screen( ltip )

  Local s := '', s1 := '', lsmo, nsmo, lokato

  lsmo := iif( ltip == 1, kart_->smo, human_->smo )
  nsmo := Int( Val( lsmo ) )
  s := inieditspr( A__MENUVERT, smo_volgograd(), nsmo )
  If Empty( s ) .or. nsmo == 34
    If nsmo == 34
      s1 := ret_inogsmo_name( ltip, , .t. )
    Else
      s1 := init_ismo( lsmo )
    Endif
    If !Empty( s1 )
      s := AllTrim( s1 )
    Endif
    lokato := iif( ltip == 1, kart_->KVARTAL_D, human_->okato )
    If !Empty( lokato )
      s += '/' + inieditspr( A__MENUVERT, glob_array_srf(), lokato )
    Endif
  Endif

  Return s

// 27.05.26 вернуть наименование иногородней СМО
Function init_ismo( lsmo )

  Local s := Space( 10 )  //  , tmp_select
  local arrSMO := {}

  If !Empty( lsmo )
//    tmp_select := Select()
//    r_use( dir_exe() + '_mo_smo', cur_dir() + '_mo_smo2', 'SMO' )
//    smo->( dbSeek( PadR( lsmo, 5 ) ) )
    arrSMO := findSMO_in_f019( lsmo )
    If Len( arrSMO ) != 0     //   smo->( Found() )
//      s := RTrim( smo->name )
      s := arrSMO[ 5 ]
    Endif
//    smo->( dbCloseArea() )
//    Select ( tmp_select )
  Endif

  Return s

// вместо иногородней СМО подставить код ТФОМС
Function cut_code_smo( _smo )

  Local s := Space( 5 )

  If !Empty( _smo )
    If Left( _smo, 3 ) == '340'
      s := _smo
    Else
      s := '34   '
    Endif
  Endif
  Return s
