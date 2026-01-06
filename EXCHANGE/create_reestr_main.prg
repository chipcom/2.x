#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static Sreestr_sem := 'Работа с реестрами'
Static Sreestr_err := 'В данный момент с реестрами работает другой пользователь.'

// 16.12.25
Function create_reestr_main()

  Local buf := save_maxrow(), k := 0, k1 := 0
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local arr_m

  //  Local nameArr, i, j, arr, bSaveHandler, fl, pole
//  Local tip_lu

//  local arrKolSl, _k
//  local adbf, currDate

//  local mnyear, mnmonth
//  private arr_m // пока не знаю как передать

//  Private pkol := 0, psumma := 0  //, ;

//  If ! currentuser():isadmin()
  If ! currentUser():isadmin()
    Return func_error( 4, err_admin() )
  Endif
  If find_unfinished_reestr_sp_tk()
    Return func_error( 4, 'Попытайтесь снова' )
  Endif
  If ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) == NIL
    Return Nil
  Endif

  // !!! ВНИМАНИЕ
  If DONT_CREATE_REESTR_YEAR == arr_m[ 1 ]
    Return func_error( 4, 'Реестры за ' + Str( DONT_CREATE_REESTR_YEAR, 4 ) + ' год недоступны' )
  elseif arr_m[ 1 ] <= 2018
    return func_error( 10, 'Реестр ранее 2019 года не формируется!' )
//  elseif arr_m[ 1 ] > 2018 .and. arr_m[ 1 ] <= 2025
//    create_reestr25( arr_m )
//  elseif arr_m[ 1 ] >= 2026
  else
    create_reestr26( arr_m )
  Endif

/*

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

  dbCreate( cur_dir() + 'tmpb', adbf, , .t., 'TMPB' )
  Index On Str( FIELD->kod_human, 7 ) to ( cur_dir() + 'tmpb' )
// на будующее
//  dbCreate( 'mem:tmpb', adbf, , .t., 'TMPB' )
//  Index On FIELD->KOD_SMO + Str( FIELD->kod_human, 7 ) to ( 'mem:tmpb' )
//
  adbf := { ;
    { 'MIN_DATE',    'D',     8,     0 }, ;
    { 'DNI',         'N',     3,     0 }, ;
    { 'NYEAR',       'N',     4,     0 }, ; // отчетный год;;
    { 'NMONTH',      'N',     2,     0 }, ; // отчетный месяц;;
    { 'KOL',         'N',     6,     0 }, ;
    { 'SUMMA',       'N',    15,     2 }, ;
    { 'KOD',         'N',     6,     0 } ;
  }

  mnyear := arr_m[ 1 ]
  mnmonth := arr_m[ 3 ]
  
  private p_array_PZ

  p_array_PZ := get_array_pz( mnyear )  // получим массив план-заказа на год составления реестра
  lenPZ := len( p_array_PZ )

  For i := 0 To lenPZ   // для таблицы _moXunit 03.02.23
    AAdd( adbf, { 'PZ' + lstr( i ), 'N', 9, 2 } )
  Next
  dbCreate( cur_dir() + 'tmp', adbf, , .t., 'TMP' )
  tmp->( dbAppend() )
  Replace tmp->nyear With mnyear, tmp->nmonth With mnmonth, tmp->min_date With arr_m[ 6 ]

  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_

  human->( dbSeek( DToS( arr_m[ 5 ] ), .t. ) )
  Do While human->k_data <= arr_m[ 6 ] .and. !human->( Eof() )
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
        .and. Val( human_->smo ) > 0 .and. human_->ST_VERIFY >= 5 // и проверили
      If tmp->kol < 999999 
        ++k
        If ! exist_reserve_ksg( human->kod, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
          tmp->kol++
          tmp->min_date := Min( tmp->min_date, human->k_data )
        Endif
        tmp->summa += human->cena_1
      Endif
    Endif
    human->( dbSkip() )
  Enddo
  dbCloseAll()
  If k == 0
    rest_box( buf )
    func_error( 4, 'Нет пациентов для включения в реестр с датой окончания ' + arr_m[ 4 ] )
  Else
    Use ( cur_dir() + 'tmp' ) new
    k := currDate - tmp->min_date
    tmp->dni := iif( Between( k, 1, 999 ), k, 0 )
    Go Top
    rest_box( buf )
    If alpha_browse( T_ROW, 2, T_ROW + 7, 77, 'f1create_reestr', color0, ;
        'Невыписанные реестры случаев', 'R/BG', , , , , 'f2create_reestr', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B,R/BG', .f., 180 } )
      rest_box( buf )
      // if .f.
      If currDate < SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + '11' )
        func_error( 10, 'Сегодня ' + date_8( currDate ) + ', а реестры разрешается отсылать с 11 числа' )
      Elseif mo_lock_task( X_OMS )
        fl := reestr_file_reindex()
        If fl
          private p_tip_reestr := 1
          arrKolSl := verify_oms( arr_m, .f. )
          clrline( MaxRow(), color0 )
          If arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] == 0
            //
          Elseif arrKolSl[ 1 ] > 0 .and. arrKolSl[ 2 ] == 0
            p_tip_reestr := 1
          Elseif arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] > 0
            p_tip_reestr := 2
          Elseif f_alert( { '', ;
              PadC( 'Выберите тип реестра случаев для отправки в ТФОМС', 70, '.' ), ;
              '' }, ;
              { ' Реестр ~обычный(' + lstr( arrKolSl[ 1 ] ) + ')', ' Реестр по ~диспансеризации(' + lstr( arrKolSl[ 2 ] ) + ')' }, ;
              1, 'W/RB', 'G+/RB', MaxRow() -6,, 'BG+/RB,W+/R,W+/RB,GR+/R' ) == 2
            p_tip_reestr := 2
          Endif
          mywait()
          Use ( cur_dir() + 'tmp' ) new
          _k := tmp->kol
          tmp->kol := 0
          tmp->summa := 0
          tmp->min_date := SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + '01' )
          For i := 0 To lenPZ   // 99
            pole := 'tmp->PZ' + lstr( i )
            &pole := 0
          Next
          r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
          Set Order To 2
          r_use( dir_server() + 'human_',, 'HUMAN_' )
          r_use( dir_server() + 'human',, 'HUMAN' )
          Use ( cur_dir() + 'tmpb' ) new
          Set Relation To FIELD->kod_human into HUMAN, To FIELD->kod_human into HUMAN_
          Go Top
          Do While !Eof()
            If human_->ST_VERIFY >= 5 .and. tmpb->tip == p_tip_reestr
              tmp->kol++
              If tmpb->ishod == 89
                Select HUMAN_3
                find ( Str( human->kod, 7 ) )
                tmp->summa += human_3->cena_1
                tmp->min_date := Min( tmp->min_date, human_3->k_data )
                k := human_3->PZKOL
                Select TMPB
              Else
                tmp->summa += human->cena_1
                tmp->min_date := Min( tmp->min_date, human->k_data )
                k := human_->PZKOL
              Endif
              j := human_->PZTIP
              tmpb->fio := human->fio
              tmpb->PZ := j
              pole := 'tmp->PZ' + lstr( j )
              nameArr := get_array_PZ( tmp->nyear )
              If ( i := AScan( nameArr, {| x| x[ 1 ] == j } ) ) > 0 .and. !Empty( nameArr[ i, 5 ] )
                &pole := &pole + 1 // учёт по случаям
              Else
                if tmp->nyear > 2018
                  &pole := &pole + k // учёт по единицам план-заказа
                else
                  &pole := &pole + human_->PZKOL
                endif
              Endif
            Else
              tmpb->yes_del := .t. // удалить после дополнительной проверки
            Endif
            Skip
          Enddo
          If tmp->kol == 0
            func_error( 4, 'После дополнительной проверки некого включать в реестр' )
          Else
            If _k != tmp->kol
              Select TMPB
              Delete For FIELD->yes_del
              Pack
            Endif
            If tmp->nyear > 2018 // 2019 год
              create1reestr19( tmp->( RecNo() ), tmp->nyear, tmp->nmonth, p_tip_reestr )
            Else
              // см. файл not_use/create1reestr17.prg
              func_error( 10, 'Реестр ранее 2019 года не формируется!' )
            Endif
          Endif
        Endif
        mo_unlock_task( X_OMS )
      Endif
    Endif
    rest_box( buf )
  Endif
  dbCloseAll()
*/
  Return Nil
