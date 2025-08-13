#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

Static Sreestr_sem := "Работа с реестрами"
Static Sreestr_err := "В данный момент с реестрами работает другой пользователь."
static err_admin := 'Доступ в данный режим разрешен только администратору системы!'

// 13.08.25
Function create_reestrZSL_2025()

  Local mnyear, mnmonth, k := 0, k1 := 0, fl, bSaveHandler
  Local buf := save_maxrow(), arr_m, arr, adbf,  i
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  Local tip_lu
//  Local j, pole
//  Local nameArr

//  local arrKolSl

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
  Endif

  // временно
//  If find_unfinished_reestr_sp_tk()
//    Return func_error( 4, 'Попытайтесь снова' )
//  Endif
//

  If ( arr_m := year_month( T_ROW, T_COL + 5, , 3 ) ) == NIL
    Return Nil
  Endif
  // !!! ВНИМАНИЕ
  If DONT_CREATE_REESTR_YEAR == arr_m[ 1 ]
    Return func_error( 4, 'Реестры за ' + Str( DONT_CREATE_REESTR_YEAR, 4 ) + ' год недоступны' )
  Endif
  If !myfiledeleted( cur_dir() + 'tmpb' + sdbf() )
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + 'tmp' + sdbf() )
    Return Nil
  Endif

  arr := { 'Предупреждение!', ;
           '', ;
           'Во время составления реестра', ;
           'никто не должен работать в задаче ОМС' }
  n_message( arr, , 'GR+/R', 'W+/R', , , 'G+/R' )
  
  Private pkol := 0, psumma := 0, ;
    CODE_LPU := glob_mo[ _MO_KOD_TFOMS ], ;
    CODE_MO  := glob_mo[ _MO_KOD_FFOMS ]
  private p_array_PZ

  stat_msg( 'Подождите, работаю...' )
  adbf := { ;
    { 'kod_tmp', 'N', 6, 0 }, ;
    { 'kod_human', 'N', 7, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'n_data', 'D', 8, 0 }, ;
    { 'k_data', 'D', 8, 0 }, ;
    { 'cena_1', 'N', 11, 2 }, ;
    { 'PZKOL', 'N', 3, 0 }, ;
    { 'PZ', 'N', 3, 0 }, ;
    { 'ishod', 'N', 3, 0 }, ;
    { 'tip', 'N', 1, 0 }, ; // 1 - обычный реестр, 2 -диспансеризация
    { 'yes_del', 'L', 1, 0 }, ; // надо ли удалить после дополнительной проверки
    { 'PLUS', 'L', 1, 0 } ;  // включается ли в счет
  }
  dbCreate( cur_dir() + 'tmpb', adbf )

//  dbCreate( cur_dir() + 'tmpb', { ;
//    { 'kod_tmp', 'N', 6, 0 }, ;
//    { 'kod_human', 'N', 7, 0 }, ;
//    { 'fio', 'C', 50, 0 }, ;
//    { 'n_data', 'D', 8, 0 }, ;
//    { 'k_data', 'D', 8, 0 }, ;
//    { 'cena_1', 'N', 11, 2 }, ;
//    { 'PZKOL', 'N', 3, 0 }, ;
//    { 'PZ', 'N', 3, 0 }, ;
//    { 'ishod', 'N', 3, 0 }, ;
//    { 'tip', 'N', 1, 0 }, ; // 1 - обычный реестр, 2 -диспансеризация
//    { 'yes_del', 'L', 1, 0 }, ; // надо ли удалить после дополнительной проверки
//    { 'PLUS', 'L', 1, 0 } ;  // включается ли в счет
//  } )
  Use ( cur_dir() + 'tmpb' ) new
  Index On Str( kod_human, 7 ) to ( cur_dir() + 'tmpb' )

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

  p_array_PZ := get_array_pz( mnyear )  // получим массив план-заказа на год составления реестра
  lenPZ := len( p_array_PZ )

  For i := 0 To lenPZ   // для таблицы _moXunit 03.02.23
    AAdd( adbf, { 'PZ' + lstr( i ), 'N', 9, 2 } )
  Next i

  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' ) New Alias TMP
  tmp->( dbAppend() )
  Replace tmp->nyear With mnyear, tmp->nmonth With mnmonth, tmp->min_date With arr_m[ 6 ]

  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_

  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
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
      If tmp->kol < 999999
        ++k
        If ! exist_reserve_ksg( human->kod, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
          tmp->kol++
          tmp->min_date := Min( tmp->min_date, human->k_data )
        Endif
        tmp->summa += human->cena_1
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  dbCloseAll()
  If k == 0
    rest_box( buf )
    func_error( 4, 'Нет пациентов для включения в реестр с датой окончания ' + arr_m[ 4 ] )
  Else
    Use ( cur_dir() + 'tmp' ) new
    k := Date() - tmp->min_date
    tmp->dni := iif( Between( k, 1, 999 ), k, 0 )
    tmp->( dbGoTop() )    // Go Top
    rest_box( buf )
    If alpha_browse( T_ROW, 2, T_ROW + 7, 77, 'f1create_reestr', color0, ;
        'Невыписанные реестры случаев', 'R/BG', , , , , 'f2create_reestr_2025', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B,R/BG', .f., 180 } )
      rest_box( buf )
      If Date() < SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + '11' )
        func_error( 10, 'Сегодня ' + date_8( Date() ) + ', а реестры разрешается отсылать с 11 числа' )
      Elseif mo_lock_task( X_OMS )
        dbCloseAll()
        fl := .t.
        bSaveHandler := ErrorBlock( {| x| Break( x ) } )

      endif

    endif
  endif

altd()
  dbCloseAll()
  return nil

// 13.08.25
Function f2create_reestr_2025( nKey, oBrow )

  Local buf, rec, k := -1, nfile := cur_dir() + 'spisok.txt', j := 0
  Local ft

  Do Case
  Case nkey == K_F9
    buf := save_maxrow()
    mywait()
    rec := tmp->( RecNo() )
    ft := tfiletext():new( nfile, , .t., , .t. )
    ft:add_string( '' )
    ft:add_string( 'Список пациентов за отчётный период ' + Str( tmp->nyear, 4 ) + '/' + StrZero( tmp->nmonth, 2 ), FILE_CENTER, ' ' )
    ft:add_string( '' )

    r_use( dir_server() + 'mo_otd', , 'OTD' )
    r_use( dir_server() + 'human', , 'HUMAN' )
    Set Relation To otd into OTD
    Use ( cur_dir() + 'tmpb' ) new
    Set Relation To kod_human into HUMAN
    Index On Upper( human->fio ) + DToS( human->k_data ) to ( cur_dir() + 'tmpb' ) For kod_tmp == rec
    Go Top
    Do While !Eof()
      ft:add_string( Str( ++j, 5 ) + '. ' + PadR( human->fio, 47 ) + date_8( human->n_data ) + '-' + ;
        date_8( human->k_data ) + ' [' + otd->short_name + ']' )
      Skip
    Enddo
    otd->( dbCloseArea() )
    human->( dbCloseArea() )
    tmpb->( dbCloseArea() )
    Select TMP
    rest_box( buf )
    
    ft := nil
    viewtext( nfile, , , , .t., , , 2 )
  Endcase
  Return k
