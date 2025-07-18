#include 'inkey.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 07.01.25
function check_diag_onko_lek_prep( kod_diag )

  local kod, lRet := .f., i, j
  local arrDiag := { 'C40', 'C49', 'C62', 'C64', 'C70', 'C71', 'C72', 'C81', 'C95' }
  local arrDiagFull := { ;
    'C22.2', 'C38.1', 'C47.3', 'C47.4', 'C47.5', 'C47.6', ;
    'C47.8', 'C47.9', 'C48.0', 'C74.1', 'C74.9', 'C76.0', ;
    'C76.1', 'C76.2', 'C76.3', 'C76.7', 'C76.8', 'C83.3', ;
    'C83.5', 'C83.7', 'C84.6', 'C84.7', 'C85.2', 'C91.0', ;
    'C91.8', 'C92.0', 'C92.3', 'C92.4', 'C92.5', 'C92.6', ;
    'C92.7', 'C92.8', 'C92.9', 'C93.0', 'C94.0', 'C94.2' ;
  }

  kod := Upper( AllTrim( kod_diag ) )
  i := ascan( arrDiagFull, { | x | x == kod } )
  j := ascan( arrDiag, { | x | x == substr( kod, 1, 3 ) } )
  if ( i > 0 ) .or. ( j > 0 )
    lRet := .t.
  Endif
  return lRet

// 05.11.23 проходит только КТ, УЗИ, гистология диагностика при онкологии
Function only_control_onko( napr, date, rslt, ishod )

  // napr - наравившее МО
  // date - дата направления
  Local lRet

  // Волгамедлаб исключаем
  // lRet := (!empty(napr) .and. !empty(date) .and. rslt == 314 .and. ishod == 304 .and. hb_main_curOrg:Kod_Tfoms != '805903')
  lRet := ( !Empty( napr ) .and. !Empty( date ) .and. rslt == 314 .and. ishod == 304 ) // .and. ! is_VOLGAMEDLAB())
  Return lRet

// 17.07.25 проверка правильности соответствующей стадии по соответствующему справочнику
Function f_verify_tnm( n, lkod, ldiag, mdate, versionTNM, ar )

  Local sn := lstr( n )
  Local sd
  Local fl := .t., lal := 'n' + sn
  Local s := { '', 'ST', 'T', 'N', 'M' }[ n ]
  Local s1 := { ' противопоказаний и отказов', 'стадия заболевания', 'Tumor', 'Nodus', 'Metastasis' }[ n ]
  Local smsg := 'онкология: в справочнике N00' + sn + ' не найдена стадия заболевания ' + s + '=' + lstr( lkod ) + ' для диагноза ' + ldiag
  Local aTmp, it, aTmpDS
  Local nameFunc := 'getN00' + lstr( n ) + '()'
  Local nameFuncDS

  default mdate to sys_date
  ldiag := iif( mdate >= 0d20250701, getds_sootv_onko( ldiag, versionTNM ), ldiag )
//  nameFuncDS := 'getDS_N00' + lstr( n ) + '()'
  nameFuncDS := 'getDS_N00' + lstr( n ) + '("' + dtoc( mdate ) + '")'  
  aTmp := &nameFunc
  If ( it := AScan( aTmp, {| x| x[ 2 ] == lkod } ) ) > 0
    If Empty( aTmp[ it, 3 ] )
      aTmpDS := &nameFuncDS
      sd := PadR( ldiag, 5 )
      If ( it := AScan( aTmpDS, {| x| PadR( x[ 1 ], 5 ) == sd } ) ) > 0
        fl := .f.
        AAdd( ar, smsg )
      Else
        sd := PadR( ldiag, 3 )
        If ( it := AScan( aTmpDS, {| x| PadR( x[ 1 ], 5 ) == sd } ) ) > 0
          fl := .f.
          AAdd( ar, smsg )
        Endif
      Endif
    Elseif Len( AllTrim( aTmp[ it, 3 ] ) ) == 5
      If !( Left( ldiag, 5 ) == aTmp[ it, 3 ] )
        fl := .f.
        AAdd( ar, smsg )
      Endif
    Else
      If !( Left( ldiag, 3 ) == AllTrim( aTmp[ it, 3 ] ) )
        fl := .f.
        AAdd( ar, smsg )
      Endif
    Endif
  Elseif  ( it := AScan( aTmp, {| x| Empty( x[ 2 ] ) } ) ) > 0
    If Empty( aTmp[ it, 3 ] )
      aTmpDS := &nameFuncDS
      sd := PadR( ldiag, 5 )
      If ( it := AScan( aTmpDS, {| x| PadR( x[ 1 ], 5 ) == sd } ) ) > 0
        fl := .f.
        AAdd( ar, smsg )
      Else
        sd := PadR( ldiag, 3 )
        If ( it := AScan( aTmpDS, {| x| PadR( x[ 1 ], 5 ) == sd } ) ) > 0
          fl := .f.
          AAdd( ar, smsg )
        Endif

      Endif
    Elseif Len( AllTrim( aTmp[ it, 3 ] ) ) == 5
      If !( Left( ldiag, 5 ) == aTmp[ it, 3 ] )
        fl := .f.
        AAdd( ar, smsg )
      Endif
    Else
      If !( Left( ldiag, 3 ) == AllTrim( aTmp[ it, 3 ] ) )
        fl := .f.
        AAdd( ar, smsg )
      Endif
    Endif
  Else
    fl := .f.
    AAdd( ar, smsg )
  Endif
  Return fl

// 18.07.25 функция определения массива в ф-ии редактирования листа учёта
Function f_define_tnm( n, ldiag, mdata )

  Local aRet := {}, sd, fl := .f.
  Local aTmp, it
  Local nameFunc
  Local diag_onko_replace

//  if mdata >= 0d20250701
//    diag_onko_replace := getds_sootv_onko( ldiag, mem_ver_TNM )
//    aRet := get_onko_stad( ldiag, stage, mem_ver_TNM, 'tumor', mdata )
//  else
    //  nameFunc := 'getDS_N00' + lstr( n ) + '( mdata )'
    nameFunc := 'getDS_N00' + lstr( n ) + '("' + dtoc( mdata ) + '")'  
    aTmp := &nameFunc
    sd := PadR( ldiag, 5 )
    If ( it := AScan( aTmp, {| x| PadR( x[ 1 ], 5 ) == sd } ) ) > 0
      aRet := AClone( aTmp[ it, 2 ] )
      fl := .t.
    Endif
    If ! fl
      sd := PadR( ldiag, 3 )
      If ( ( it := AScan( aTmp, {| x| PadR( x[ 1 ], 3 ) == sd } ) ) > 0 ) .and. Len( aTmp[ it, 1 ] ) == 3
        aRet := AClone( aTmp[ it, 2 ] )
        fl := .t.
      Endif
    Endif
    If ! fl
      sd := Space( 5 )
      If ( it := AScan( aTmp, {| x| PadR( x[ 1 ], 5 ) == sd } ) ) > 0
        aRet := AClone( aTmp[ it, 2 ] )
      Endif
    Endif
//  endif
  Return aRet

// 14.01.19 проверка правильности введённых стадий по справочнику N006 в get'e
Function f_valid_tnm( g )

  Local buf, fl_found, s := PadR( mkod_diag, 5 )

  /*if !emptyany(m1ONK_T,m1ONK_N,m1ONK_M)
    select N6
    find (s)
    if !(fl_found := found())
      s := padr(mkod_diag, 3)
      find (s)
      fl_found := (found() .and. s == alltrim(n6->ds_gr))
    endif
    if fl_found
      find (padr(s, 5)+str(m1ONK_T, 6)+str(m1ONK_N, 6)+str(m1ONK_M, 6))
      if found()
        if m1stad != n6->id_st
          m1stad := n6->id_st
          mSTAD  := padr(inieditspr(A__MENUVERT, mm_N002, m1STAD), 5)
          buf := save_maxrow()
          stat_msg('Справочник N006: по сочетанию стадий TNM исправлено поле 'Стадия'') ; mybell(1,OK)
          rest_box(buf)
          update_get('mstad')
        endif
      else
        func_error(2,'Справочник N006: некорректное сочетание стадий TNM')
      endif
    endif
  endif*/
  Return .t.

// 06.06.25
Function ret_arr_shema( k, dk )

  // возвращает схемы лекарственных терапий для онкологии на дату
  Static ashema := { {}, {}, {} }
  Static stYear
  Local i, db, aTable, row, arr := {}
  Local year_dk, dBeg, dEnd

  If ValType( dk ) == 'N'
    year_dk := dk
  Elseif ValType( dk ) == 'D'
    year_dk := Year( dk )
  Endif
  If ISNIL( stYear ) .or. Empty( ashema[ 1 ] ) .or. year_dk != stYear
    ashema := { {}, {}, {} }
    arr := getv024( dk )
    AAdd( ashema[ 1 ], { '-----     без схемы лекарственной терапии', PadR( 'нет', 20 ) } )
    AEval( arr, {| x, j| iif( Left( x[ 1 ], 2 ) == 'sh', AAdd( ashema[ 1 ], { PadR( x[ 1 ], 10 ) + Left( x[ 2 ], 68 ), PadR( x[ 1 ], 20 ) } ), '' ) } )
    AEval( arr, {| x, j| iif( Left( x[ 1 ], 2 ) == 'mt', AAdd( ashema[ 2 ], { PadR( x[ 1 ], 10 ) + Left( x[ 2 ], 68 ), PadR( x[ 1 ], 20 ) } ), '' ) } )
    AEval( arr, {| x, j| iif( Left( x[ 1 ], 2 ) == 'fr', AAdd( ashema[ 3 ], { PadR( x[ 1 ], 10 ) + Left( x[ 2 ], 68 ), PadR( x[ 1 ], 20 ), 0, 0 } ), '' ) } )
    For i := 1 To Len( ashema[ 3 ] )
      ashema[ 3, i, 3 ] := Int( Val( SubStr( ashema[ 3, i, 1 ], 3, 2 ) ) )
      ashema[ 3, i, 4 ] := Int( Val( SubStr( ashema[ 3, i, 1 ], 6, 2 ) ) )
    Next
    stYear := year_dk
  Endif
  Return ashema[ k ]

// 04.02.22
Function ret_arr_shema_old( k, k_data )

  // возвращает схемы лекарственных терапий для онкологии на дату
  Static ashema := { {}, {}, {} }
  Local i
  Local _data := 0d20210101 // 21 год

  Default k_data To sys_date
  _data := k_data

  If Empty( ashema[ 1 ] )
    r_use( dir_exe() + prefixfilerefname( _data ) + 'shema', , 'IT' )
    AAdd( ashema[ 1 ], { '-----     без схемы лекарственной терапии', PadR( 'нет', 10 ) } )
    Index On kod to ( cur_dir() + 'tmp_schema' ) For Left( kod, 2 ) == 'sh' .and. between_date( it->datebeg, it->dateend, _data )
    dbEval( {|| AAdd( ashema[ 1 ], { it->kod + Left( it->name, 68 ), it->kod } ) } )
    Index On kod to ( cur_dir() + 'tmp_schema' ) For Left( kod, 2 ) == 'mt' .and. between_date( it->datebeg, it->dateend, _data )
    dbEval( {|| AAdd( ashema[ 2 ], { it->kod + Left( it->name, 68 ), it->kod } ) } )
    Index On kod to ( cur_dir() + 'tmp_schema' ) For Left( kod, 2 ) == 'fr' .and. between_date( it->datebeg, it->dateend, _data )
    dbEval( {|| AAdd( ashema[ 3 ], { it->kod + Left( it->name, 68 ), it->kod, 0, 0 } ) } )
    Use
    For i := 1 To Len( ashema[ 3 ] )
      ashema[ 3, i, 3 ] := Int( Val( SubStr( ashema[ 3, i, 1 ], 3, 2 ) ) )
      ashema[ 3, i, 4 ] := Int( Val( SubStr( ashema[ 3, i, 1 ], 6, 2 ) ) )
    Next
  Endif
  Return ashema[ k ]

// 15.02.20
Function f_is_oncology( r, /*@*/_onk_smp)

  Local i, k, mdiagnoz, lusl_ok, lprofil, lzno := 0, lyear, lk_data

  If r == 1
    lk_data := human->k_data
    lyear := Year( human->k_data )
    lusl_ok := human_->USL_OK
    mdiagnoz := diag_to_array()
    lprofil := human_->profil
    If human->OBRASHEN == '1'
      lzno := 1
    Endif
  Else
    lk_data := mk_data
    lyear := Year( mk_data )
    lusl_ok := m1USL_OK
    mdiagnoz := diag_to_array( ' ' )
    lprofil := m1profil
    lzno := m1ds_onk
  Endif
  If Empty( mdiagnoz )
    AAdd( mdiagnoz, Space( 6 ) )
  Endif
  k := lzno
  If lyear >= 2021 .and. ( Left( mdiagnoz[ 1 ], 1 ) == 'C' .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D00', 'D09' ) ;
      .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D45', 'D47' ) ) // согласно письму 04-18-05 от 12.02.21
    k := 2
  Elseif lyear >= 2019 .and. ( Left( mdiagnoz[ 1 ], 1 ) == 'C' .or. Between( Left( mdiagnoz[ 1 ], 3 ), 'D00', 'D09' ) )
    k := 2
  Elseif lyear == 2018 .and. Left( mdiagnoz[ 1 ], 1 ) == 'C'
    k := 2
  Elseif Left( mdiagnoz[ 1 ], 3 ) == 'D70' .and. lk_data < 0d20200401 // только до 1 апреля 2020 года
    For i := 2 To Len( mdiagnoz )
      If Left( mdiagnoz[ i ], 1 ) == 'C'
        If Between( Left( mdiagnoz[ i ], 3 ), 'C00', 'C80' ) .or. Left( mdiagnoz[ i ], 3 ) == 'C97'
          k := 2
        Endif
      Endif
    Next
  Endif
  If k == 2
    yes_oncology := .t.
    m1ds_onk := 0
    mds_onk := inieditspr( A__MENUVERT, mm_danet, m1ds_onk )
    If lprofil == 158
      _onk_smp := k := 1
    Endif
  Endif
  If lusl_ok == 4 // скорая помощь
    _onk_smp := k
    k := 0
  Endif
  Return k

// 19.08.18
Function when_ds_onk()

  Private yes_oncology := .f.

  f_is_oncology( 2 )
  Return !yes_oncology

// 29.01.19
Function is_lymphoid( _diag ) // ЗНО кроветворной или лимфоидной тканей

  Return !Empty( _diag ) .and. Between( Left( _diag, 3 ), 'C81', 'C96' )

// 21.12.24
Function mmb_diag()

  Local mmb_diag := { ;
    { 'выполнено (результат получен)', 98 }, ;
    { 'выполнено (результат не получен)', 97 }, ;
    { 'выполнено (до 1 сентября 2018г.)', -1 }, ;
    { 'отказ', 0 }, ;
    { 'не показано', 7 }, ;
    { 'противопоказано', 8 }, ;
    { 'не надо', 99 } }

  Return mmb_diag

// 02.02.19
Function ret_str_onc( k, par )

  Static arr := { ;
    'Суммарная очаговая доза (в Греях)', ;  // 1 lstr_sod
    'Кол-во фракций', ;                     // 2 lstr_fr
    'Масса тела (в кг.)', ;                 // 3 lstr_wei
    'Рост (в см)', ;                        // 4 lstr_hei
    'Площадь пов-ти тела (в кв.м)', ;       // 5 lstr_bsa
    'Режим введения лекарственного препарата (дней введения)', ; // 6 lstr_err
    'Схема лекарственной терапии', ;        // 7 lstr_she
    'Список лекарственных препаратов', ;    // 8 lstr_lek
    'Проводилась ли профилактика тошноты и рвотного рефлекса' }     // 9 lstr_ptr
  Local s := arr[ k ]

  Default par To 1
  Return iif( par == 1, s, Space( Len( s ) ) )
