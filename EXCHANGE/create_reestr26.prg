#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

Static Sreestr_sem := 'Работа с реестрами'
Static Sreestr_err := 'В данный момент с реестрами работает другой пользователь.'

// 12.02.26
Function create_reestr26( arr_calendar )

  Local mnyear, mnmonth, k := 0, k1 := 0
  Local buf := save_maxrow(), arr, adbf, i
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  Local tip_lu, currDate
  Local t_smo   //, arr_smo := {}
  Local lshifr1, lbukva, c, fl
  Local p_array_PZ

  Private pkol := 0, psumma := 0
  Private arr_m := arr_calendar

  If !myfiledeleted( cur_dir() + 'tmpb' + sdbf() )
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + 'tmp' + sdbf() )
    Return Nil
  Endif

  currDate := sys_date

  arr := { 'Предупреждение!', ;
           '', ;
           'Во время составления реестра', ;
           'никто не должен работать в задаче ОМС' }
  n_message( arr, , 'GR+/R', 'W+/R', , , 'G+/R' )
  
  stat_msg( 'Подождите, работаю...' )

  fl := reestr_file_reindex()
  if fl
    mo_lock_task( X_OMS )
  endif
  adbf := { ;
    { 'kod_tmp',  'N',  6, 0 }, ;
    { 'kod_human','N',  7, 0 }, ;
    { 'fio',      'C', 50, 0 }, ;
    { 'n_data',   'D',  8, 0 }, ;
    { 'k_data',   'D',  8, 0 }, ;
    { 'cena_1',   'N', 11, 2 }, ;
    { 'PZKOL',    'N',  3, 0 }, ;
    { 'PZ',       'N',  3, 0 }, ;
    { 'ishod',    'N',  3, 0 }, ;
    { 'tip',      'N',  1, 0 }, ;  // 1 - обычный реестр, 2 -диспансеризация
    { 'yes_del',  'L',  1, 0 }, ;  // надо ли удалить после дополнительной проверки
    { 'PLUS',     'L',  1, 0 }, ;  // включается ли в счет
    { 'KOD_SMO',  'C',  5, 0 }, ;  // код СМО
    { 'BUKVA',    'C',  1, 0 } ;   // буква счета
  }
//  dbCreate( cur_dir() + 'tmpb', adbf )
//  Use ( cur_dir() + 'tmpb' ) new

  dbCreate( 'mem:tmpb', adbf, , .t., 'TMPB' )
  INDEX ON FIELD->KOD_SMO + Str( FIELD->kod_human, 7 ) TO ( 'mem:tmpb' )

  mnyear := arr_calendar[ 1 ]
  mnmonth := arr_calendar[ 3 ]

  adbf := { ;
    { 'MIN_DATE',    'D',     8,     0 }, ;
    { 'DNI',         'N',     3,     0 }, ;
    { 'NYEAR',       'N',     4,     0 }, ; // отчетный год;;
    { 'NMONTH',      'N',     2,     0 }, ; // отчетный месяц;;
    { 'KOL',         'N',     6,     0 }, ;
    { 'SUMMA',       'N',    15,     2 }, ;
    { 'KOD',         'N',     6,     0 }, ;
    { 'KOD_SMO',     'C',     5,     0 } ;
  }

  p_array_PZ := get_array_pz( mnyear )  // получим массив план-заказа на год составления реестра
  lenPZ := len( p_array_PZ )

  For i := 0 To lenPZ   // для таблицы _moXunit 03.02.23
    AAdd( adbf, { 'PZ' + lstr( i ), 'N', 9, 2 } )
  Next i

  dbCreate( 'mem:a_smo', adbf, , .t., 'A_SMO' )
  INDEX ON FIELD->kod_smo TO ( 'mem:a_smo' )

  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u_', , 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
////  r_use( dir_server() + 'human_u', { dir_server() + 'human_u', ;
////    dir_server() + 'human_uk', ;
////    dir_server() + 'human_ud', ;
////    dir_server() + 'human_uv', ;
////    dir_server() + 'human_ua' }, 'HU' )
  Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To FIELD->u_kod into MOSU

  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_

  human->( dbSeek( DToS( arr_calendar[ 5 ] ), .t. ) )

  Do While human->k_data <= arr_calendar[ 6 ] .and. !Eof()
    If ++k1 % 100 == 0
      @ MaxRow(), 1 Say lstr( k1 ) Color cColorSt2Msg
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( k ) Color cColorStMsg
    Endif
    OTD->( dbGoto( human->OTD ) )
    If ! ( OTD->( Eof() ) ) .and. ! ( OTD->( Bof() ) )
      tip_lu := OTD->TIPLU
    Else
      tip_lu := 0
    Endif
    If human->tip_h == B_STANDART .and. emptyall( human_->reestr, human->schet ) ;
        .and. ( human->cena_1 > 0 .or. human_->USL_OK == 4 .or. tip_lu == TIP_LU_ONKO_DISP ) ;
        .and. Val( human_->smo ) > 0 .and. human_->ST_VERIFY >= 5       // и проверили

      if empty( human_->smo )
        human->( dbSkip() )
        loop
      endif

      t_smo := iif( SubStr( AllTrim( human_->smo ), 1, 2 ) == '34', human_->smo, '34   ' )
      if ! A_SMO->( dbSeek( t_smo ) )
        A_SMO->( dbAppend() )
        A_SMO->nyear := mnyear
        A_SMO->nmonth := mnmonth
        A_SMO->min_date := arr_calendar[ 6 ]
        A_SMO->kod_smo := t_smo
      endif

      tmpb->( dbAppend() )
//      tmpb->kod_tmp := 1
      tmpb->kod_human := human->kod
      tmpb->fio := human->fio
      tmpb->n_data := human->n_data
      tmpb->k_data := human->k_data
      tmpb->cena_1 := human->cena_1
      tmpb->PZKOL := human_->pzkol
//      tmpb->PZ := 
      tmpb->ishod := human->ishod
      tmpb->tip := iif( is_dispanserizaciya( human->ishod ), 2, 1 ) // 1 - обычный реестр, 2 -диспансеризация
//      tmpb->yes_del :=  // надо ли удалить после дополнительной проверки
      tmpb->PLUS := .t.  // включается ли в счет
      tmpb->kod_smo := t_smo

      // находим букву счета для случая
      c := ' '
      hu->( dbSeek( Str( human->kod, 7 ), .t. ) )
      Do While hu->kod == human->kod .and. ! hu->( Eof() )
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        lbukva := ' '
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , @lbukva )
          lshifr1 := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
          If hu->STOIM_1 > 0 .or. Left( lshifr1, 3 ) == '71.' .or. Left( lshifr1, 5 ) == '2.5.2'  // скорая помощь и постановка онко пациентов на дисп. набл.
            If !Empty( lbukva )
              c := lbukva
              Exit
            Endif
          Endif
        Endif
        hu->( dbSkip() )
      Enddo
      tmpb->BUKVA := c

      ++k
      If A_SMO->kol < 999999
//        ++k
        If ! exist_reserve_ksg( human->kod, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
          A_SMO->kol++
          A_SMO->min_date := Min( A_SMO->min_date, human->k_data )
        Endif
        A_SMO->summa += human->cena_1
      Endif
    Endif
    Select HUMAN
    human->( dbSkip() )
  Enddo
  A_SMO->( dbGoTop() )
  do while ! A_SMO->( Eof() )
    k1 := Date() - A_SMO->min_date
    A_SMO->dni := iif( Between( k1, 1, 999 ), k1, 0 )
    A_SMO->( dbSkip() )
  Enddo
  Select A_SMO

  close_use_base( 'lusl' )
  close_use_base( 'luslc' )
  close_use_base( 'luslf' )
  close_list_alias( { 'OTD', 'HUMAN_', 'HUMAN', 'USL', 'USL1', 'HU_', 'HU', 'MOSU', 'MOHU' } )

  If k == 0
    rest_box( buf )
    func_error( 4, 'Нет пациентов для включения в реестр с датой окончания ' + arr_calendar[ 4 ] )
  Else
//    Use ( cur_dir() + 'A_SMO' ) new
//    k := Date() - A_SMO->min_date
//    A_SMO->dni := iif( Between( k, 1, 999 ), k, 0 )

//    dbSelectArea( 'A_SMO' )
    A_SMO->( dbGoTop() )
    rest_box( buf )

    If alpha_browse( T_ROW, 2, T_ROW + len( smo_volgograd() ) + 2, 77, 'f1create_reestr26', color0, ;
        'Невыписанные реестры случаев', 'R/BG', , , , , 'f2create_reestr26', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B,R/BG', .t., 180 } )
      rest_box( buf )
    endif
  endif
  close_list_alias( { 'HUMAN_', 'HUMAN', 'MO_OTD' } )

  close_list_alias( { 'A_SMO', 'TMPB' } )
  dbDrop( 'mem:a_smo' )  /* освободим память */
  hb_vfErase( 'mem:a_smo.ntx' )  /* освободим память от индексного файла */
  dbDrop( 'mem:tmpb' )  /* освободим память */
  hb_vfErase( 'mem:tmpb.ntx' )  /* освободим память от индексного файла */
  if fl
    mo_unlock_task( X_OMS )
  endif
  return nil

// 13.08.25
Function f1create_reestr26( oBrow )

  Local oColumn, n := 36, n1 := 20, blk

  oColumn := TBColumnNew( 'Год', {|| Str( A_SMO->nyear, 4 ) + ' ' } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Месяц', {|| ' ' + mm_month()[ A_SMO->nmonth ] + ' ' } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Компания', {|| substr( inieditspr( A__MENUVERT, smo_volgograd(), Val( A_SMO->kod_smo ) ), 1, 20 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Дни;max', {|| put_val( A_SMO->dni, 3 ) } )
  oColumn:defColor := { 5, 5 }
  oColumn:colorBlock := {|| { 5, 5 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Кол-во;больных', 14 ), {|| Str( A_SMO->kol, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Сумма;случаев', 15 ), {|| Str( A_SMO->summa, 15, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход;  ^<Enter>^ составить реестр случаев;  ^<F9>^ печать списка пациентов' )
  Return Nil

// 13.08.25
Function f2create_reestr26( nKey, oBrow )

  Local rec, ret := -1, tmpSelect

  rec := A_SMO->( RecNo() )
  tmpSelect := Select()
  Do Case
  Case nkey == K_ENTER
      If Date() < SToD( StrZero( A_SMO->nyear, 4 ) + StrZero( A_SMO->nmonth, 2 ) + '11' )
        func_error( 10, 'Сегодня ' + date_8( Date() ) + ', а реестры разрешается отсылать с 11 числа' )
      Else  //  if mo_lock_task( X_OMS )
        control_and_create_schet26( A_SMO->kod_smo )
        dbSelectArea( 'A_SMO' )
        A_SMO->( dbGoto( rec ) )
        ret := 0
      endif
  Case nkey == K_F9
    print_list_pacients( A_SMO->kod_smo, A_SMO->nyear, A_SMO->nmonth )
  Endcase
  Select( tmpSelect )
  Return ret

// 14.08.25
function print_list_pacients( kod_smo, nyear, nmonth )

  Local buf, nfile := cur_dir() + 'spisok.txt', j
  Local ft

    buf := save_maxrow()
    mywait()
    ft := tfiletext():new( nfile, , .t., , .t. )
    ft:add_string( '' )
    ft:add_string( 'Список пациентов за отчётный период ' + mm_month()[ nmonth ] + ' ' + Str( nyear, 4 ) + ' года', FILE_CENTER, ' ' )
    ft:add_string( '' )

    j := 0
    tmpb->( dbGoTop() )
    Do While !tmpb->( Eof() )
      if tmpb->kod_smo == kod_smo
        ft:add_string( Str( ++j, 5 ) + '. ' + PadR( tmpb->fio, 47 ) + date_8( tmpb->n_data ) + '-' + ;
          date_8( tmpb->k_data ) )
      endif
      tmpb->( dbSkip() )
    Enddo
    Select A_SMO
    rest_box( buf )
    ft := nil
    viewtext( nfile, , , , .t., , , 2 )
    return nil

// 05.02.26
function control_and_create_schet26( kod_smo )

  // при работе использует созданные алиасы A_SMO и TMPB

  Local k := 0, k1 := 0, fl, i, _k
  Local buf := save_maxrow()
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local arrKolSl
  Local j, pole
  Local nameArr
  Local p_tip_reestr  // тип формируемого Реестра случаев

//  fl := reestr_file_reindex()
//  If fl
    // arr_m - PRIVATE переменная
    arrKolSl := verify_oms26( arr_m, .f., kod_smo )
    clrline( MaxRow(), color0 )
    If arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] == 0
      // случаев нет
    Elseif arrKolSl[ 1 ] > 0 .and. arrKolSl[ 2 ] == 0
      p_tip_reestr := 1
    Elseif arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] > 0
      p_tip_reestr := 2
    Elseif ( p_tip_reestr := f_alert( { '', ;
          PadC( 'Выберите тип реестра случаев для отправки в ТФОМС', 70, '.' ), ;
          '' }, ;
          { ' Реестр ~обычный(' + lstr( arrKolSl[ 1 ] ) + ')', ' Реестр по ~диспансеризации(' + lstr( arrKolSl[ 2 ] ) + ')' }, ;
          1, 'W/RB', 'G+/RB', MaxRow() -6,, 'BG+/RB,W+/R,W+/RB,GR+/R' ) ) == 0
      rest_box( buf )
      return nil
    Endif
    mywait()
    _k := A_SMO->kol
    A_SMO->kol := 0
    A_SMO->summa := 0
    A_SMO->min_date := SToD( StrZero( A_SMO->nyear, 4 ) + StrZero( A_SMO->nmonth, 2 ) + '01' )
    For i := 0 To lenPZ
      pole := 'A_SMO->PZ' + lstr( i )
      &pole := 0
    Next
    r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    Set Order To 2
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human',, 'HUMAN' )

    //    r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
    //    Set Relation To RecNo() into HUMAN_

    dbSelectArea( 'tmpb' )
    Set Relation To FIELD->kod_human into HUMAN, To FIELD->kod_human into HUMAN_

    tmpb->( dbSeek( kod_smo, .t. ) )
    Do While ! ( tmpb->( Eof() ) ) .and. ( tmpb->kod_smo == kod_smo )
      If human_->ST_VERIFY >= 5 .and. tmpb->tip == p_tip_reestr
        A_SMO->kol++
        If tmpb->ishod == 89
          Select HUMAN_3
          find ( Str( human->kod, 7 ) )
          A_SMO->summa += human_3->cena_1
          A_SMO->min_date := Min( A_SMO->min_date, human_3->k_data )
          k := human_3->PZKOL
          Select TMPB
        Else
          A_SMO->summa += human->cena_1
          A_SMO->min_date := Min( A_SMO->min_date, human->k_data )
          k := human_->PZKOL
        Endif
        j := human_->PZTIP
        tmpb->fio := human->fio
        tmpb->PZ := j
        pole := 'A_SMO->PZ' + lstr( j )
        nameArr := get_array_PZ( A_SMO->nyear )
        If ( i := AScan( nameArr, {| x| x[ 1 ] == j } ) ) > 0 .and. !Empty( nameArr[ i, 5 ] )
          &pole := &pole + 1 // учёт по случаям
        Else
          if A_SMO->nyear > 2018
            &pole := &pole + k // учёт по единицам план-заказа
          else
            &pole := &pole + human_->PZKOL
          endif
        Endif
      Else
        tmpb->yes_del := .t. // удалить после дополнительной проверки
      Endif
      tmpb->( dbSkip() )
    Enddo

    close_list_alias( { 'K006', 'PRPRK', 'HUMAN_3', 'HUMAN_', 'HUMAN' } )

    If A_SMO->kol == 0
      func_error( 4, 'После дополнительной проверки некого включать в реестр' )
    Else
      If _k != A_SMO->kol
//        dbSelectArea( 'tmpb' )
//        Delete For yes_del
//        tmpb->( __dbPack() )
      Endif
      If A_SMO->nyear >= 2025
/*        
        cFor := 'FIELD->tip == ' + AllTrim( str( p_tip_reestr, 1 ) ) + '.and. FIELD->kod_smo == "' + kod_smo + '"'
        bFor := &( '{||' + cFor + '}' )
        tmpb->( __dbCopy( 'mem:tmp', , bFor ) )
        dbUseArea( .t., , 'mem:tmp', 'TMP', .f., .f. )
// соберем БУКВЫ СЧЕТОВ
        aBukva := {}
        INDEX ON ( FIELD->BUKVA ) TO ( 'mem:bukva' ) unique
        tmp->( dbGoTop() )
        while ! tmp->( Eof() )
          AAdd( aBukva, tmp->BUKVA )
          tmp->( dbSkip() )
        end do
        tmp->( ordListClear() )
        hb_vfErase( 'mem:bukva.ntx' )
        tmp->( dbGoTop() )
*/
//
//        create1reestr26( A_SMO->( RecNo() ), A_SMO->nyear, A_SMO->nmonth, kod_smo, p_tip_reestr ) //  , aBukva )
        create1reestr26( A_SMO->nyear, A_SMO->nmonth, kod_smo, p_tip_reestr ) //  , aBukva )
/*
        close_list_alias( { 'TMP' } )
        dbDrop( 'mem:tmp' )
        hb_vfErase( 'mem:tmp.ntx' )
*/

        A_SMO->kol := _k - A_SMO->kol

//        dbSelectArea( 'tmpb' )
//        Delete For yes_del
//        tmpb->( __dbPack() )

      Else
        func_error( 10, 'Реестр ранее августа 2025 года не формируется!' )
      Endif
    Endif
//  Endif
  rest_box( buf )
  return nil