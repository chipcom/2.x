#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

Static Sreestr_sem := 'Работа с реестрами'
Static Sreestr_err := 'В данный момент с реестрами работает другой пользователь.'
static err_admin := 'Доступ в данный режим разрешен только администратору системы!'

// 15.08.25
Function create_reestrZSL_2025()

  Local mnyear, mnmonth, k := 0, k1 := 0
  Local buf := save_maxrow(), arr, adbf,  i           // , arr_m
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  Local tip_lu
  Local t_smo   //, arr_smo := {}

  private arr_m // пока не знаю как передать

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
    { 'kod_tmp',  'N',  6, 0 }, ;
    { 'kod_human','N',  7, 0 }, ;
    { 'fio',      'C', 50, 0 }, ;
    { 'n_data',   'D',  8, 0 }, ;
    { 'k_data',   'D',  8, 0 }, ;
    { 'cena_1',   'N', 11, 2 }, ;
    { 'PZKOL',    'N',  3, 0 }, ;
    { 'PZ',       'N',  3, 0 }, ;
    { 'ishod',    'N',  3, 0 }, ;
    { 'tip',      'N',  1, 0 }, ; // 1 - обычный реестр, 2 -диспансеризация
    { 'yes_del',  'L',  1, 0 }, ; // надо ли удалить после дополнительной проверки
    { 'PLUS',     'L',  1, 0 }, ;  // включается ли в счет
    { 'KOD_SMO',  'C',  5, 0 } ;  // код СМО
  }
  dbCreate( cur_dir() + 'tmpb', adbf )

  Use ( cur_dir() + 'tmpb' ) new
  Index On FIELD->KOD_SMO + Str( FIELD->kod_human, 7 ) to ( cur_dir() + 'tmpb' )
//  Index On Str( FIELD->kod_human, 7 ) to ( cur_dir() + 'tmpb' )
//  Index On FIELD->fio to ( cur_dir() + 'tmpb_fio' )

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

  mnyear := arr_m[ 1 ]
  mnmonth := arr_m[ 3 ]

  p_array_PZ := get_array_pz( mnyear )  // получим массив план-заказа на год составления реестра
  lenPZ := len( p_array_PZ )

  For i := 0 To lenPZ   // для таблицы _moXunit 03.02.23
    AAdd( adbf, { 'PZ' + lstr( i ), 'N', 9, 2 } )
  Next i

  dbCreate( 'mem:tmp', adbf, , .t., 'TMP' )

  Index On FIELD->kod_smo to ( 'mem:tmp_smo' )

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

      if empty( human_->smo )
        human->( dbSkip() )
        loop
      endif

      t_smo := iif( SubStr( AllTrim( human_->smo ), 1, 2 ) == '34', human_->smo, '34   ' )
      if ! tmp->( dbSeek( t_smo ) )
        tmp->( dbAppend() )
        tmp->nyear := mnyear
        tmp->nmonth := mnmonth
        tmp->min_date := arr_m[ 6 ]
        tmp->kod_smo := t_smo
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

      ++k
      If tmp->kol < 999999
//        ++k
        If ! exist_reserve_ksg( human->kod, 'HUMAN', (HUMAN->ishod == 89 .or. HUMAN->ishod == 88) )
          tmp->kol++
          tmp->min_date := Min( tmp->min_date, human->k_data )
        Endif
        tmp->summa += human->cena_1
      Endif
    Endif
    Select HUMAN
    human->( dbSkip() )
  Enddo
  tmp->( dbGoTop() )
  do while ! tmp->( Eof() )
    k1 := Date() - tmp->min_date
    tmp->dni := iif( Between( k1, 1, 999 ), k1, 0 )
    tmp->( dbSkip() )
  Enddo
  Select tmp
  otd->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  if aliasIsAlreadyUse('USL1')
    usl1->( dbCloseArea() )
  endif

  If k == 0
    rest_box( buf )
    func_error( 4, 'Нет пациентов для включения в реестр с датой окончания ' + arr_m[ 4 ] )
  Else
//    Use ( cur_dir() + 'tmp' ) new
//    k := Date() - tmp->min_date
//    tmp->dni := iif( Between( k, 1, 999 ), k, 0 )

//    tmp->( dbSelectArea() )
    tmp->( dbGoTop() )
    rest_box( buf )
    If alpha_browse( T_ROW, 2, T_ROW + len( smo_volgograd() ) + 2, 77, 'f1create_reestr_2025', color0, ;
        'Невыписанные реестры случаев', 'R/BG', , , , , 'f2create_reestr_2025', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B,R/BG', .t., 180 } )
      rest_box( buf )
    endif
  endif
  dbCloseAll()
  dbDrop( 'mem:tmp' )  /* освободим память */
  hb_vfErase( 'mem:tmp_smo.ntx' )  /* освободим память от индексного файла */
  return nil

// 13.08.25
Function f1create_reestr_2025( oBrow )

  Local oColumn, n := 36, n1 := 20, blk

  // mm_month - public массив названий месяцев
  oColumn := TBColumnNew( 'Год', {|| Str( tmp->nyear, 4 ) + ' ' } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Месяц', {|| ' ' + mm_month()[ tmp->nmonth ] + ' ' } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Компания', {|| substr( inieditspr( A__MENUVERT, smo_volgograd(), Val( tmp->kod_smo ) ), 1, 20 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Дни;max', {|| put_val( tmp->dni, 3 ) } )
  oColumn:defColor := { 5, 5 }
  oColumn:colorBlock := {|| { 5, 5 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Кол-во;больных', 14 ), {|| Str( tmp->kol, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Сумма;случаев', 15 ), {|| Str( tmp->summa, 15, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход;  ^<Enter>^ составить реестр случаев;  ^<F9>^ печать списка пациентов' )
  Return Nil

// 13.08.25
Function f2create_reestr_2025( nKey, oBrow )

  Local rec, ret := -1, tmpSelect

  rec := tmp->( RecNo() )
  tmpSelect := Select()
  Do Case
  Case nkey == K_ENTER
      If Date() < SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + '11' )
        func_error( 10, 'Сегодня ' + date_8( Date() ) + ', а реестры разрешается отсылать с 11 числа' )
      Else  //  if mo_lock_task( X_OMS )
        control_and_create_schet_2025( tmp->kod_smo )
        tmp->( dbSelectArea() )
        tmp->( dbGoto( rec ) )
        ret := 0
      endif
  Case nkey == K_F9
    print_list_pacients( tmp->kod_smo, tmp->nyear, tmp->nmonth )
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
    Select TMP
    rest_box( buf )
    ft := nil
    viewtext( nfile, , , , .t., , , 2 )
    return nil

// 14.08.25
function control_and_create_schet_2025( kod_smo )

  // при работе использует созданные алиасы TMP и TMPB

  Local k := 0, k1 := 0, fl, i, _k
  Local buf := save_maxrow()
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local arrKolSl
  Local j, pole
  Local nameArr
  Local p_tip_reestr  // тип формируемого Реестра случаев
  Local tip_lu
  Local t_smo   //, arr_smo := {}
  Local mnyear, mnmonth, bSaveHandler, arr, adbf
//  Local arr_m

//        dbCloseAll()
  fl := .t.
//  bSaveHandler := ErrorBlock( {| x| Break( x ) } )

//  Begin Sequence
//    r_use( dir_server() + 'human' )
//    Index On Str( FIELD->schet, 6 ) + Str( FIELD->tip_h, 1 ) + Upper( SubStr( FIELD->fio, 1, 20 ) ) to ( dir_server() + 'humans' ) progress
//    Index On Str( if( FIELD->kod > 0, FIELD->kod_k, 0 ), 7 ) + Str( FIELD->tip_h, 1 ) to ( dir_server() + 'humankk' ) progress
//    Index On DToS( FIELD->k_data ) + FIELD->uch_doc to ( dir_server() + 'humand' ) progress
//    human->( dbCloseArea() )
//    r_use( dir_server() + 'human_u' )
//    Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + 'human_u' ) progress
//    human_u->( dbCloseArea() )
//    r_use( dir_server() + 'mo_hu' )
//    Index On Str( FIELD->kod, 7 ) + FIELD->date_u to ( dir_server() + 'mo_hu' ) progress
//    mo_hu->( dbCloseArea() )
//    r_use( dir_server() + 'human_3' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'human_3' ) progress
//    Index On Str( FIELD->kod2, 7 ) to ( dir_server() + 'human_32' ) progress
//    human_3->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkna' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'mo_onkna' ) progress
//    mo_onkna->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onksl' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'mo_onksl' ) progress
//    mo_onksl->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkco' )
//    Index On Str( FIELD->kod, 7 ) to ( dir_server() + 'mo_onkco' ) progress
//    mo_onkco->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkdi' )
//    Index On Str( FIELD->kod, 7 ) + Str( FIELD->diag_tip, 1 ) + Str( FIELD->diag_code, 3 ) to ( dir_server() + 'mo_onkdi' ) progress
//    mo_onkdi->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkpr' )
//    Index On Str( FIELD->kod, 7 ) + Str( FIELD->prot, 1 ) to ( dir_server() + 'mo_onkpr' ) progress
//    mo_onkpr->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkus' )
//    Index On Str( FIELD->kod, 7 ) + Str( FIELD->usl_tip, 1 ) to ( dir_server() + 'mo_onkus' ) progress
//    mo_onkus->( dbCloseArea() )
//    r_use( dir_server() + 'mo_onkle' )
//    Index On Str( FIELD->kod, 7 ) + FIELD->regnum + FIELD->code_sh + DToS( FIELD->date_inj ) to ( dir_server() + 'mo_onkle' ) progress
//    mo_onkle->( dbCloseArea() )
//  RECOVER USING error
//    fl := func_error( 10, 'Возникла непредвиденная ошибка при переиндексировании!' )
//  End
//  ErrorBlock( bSaveHandler )

//        dbCloseAll()  // Close databases

  If fl
//          private p_tip_reestr := 1
    arrKolSl := verify_oms_2025( kod_smo, arr_m, .f. )
    clrline( MaxRow(), color0 )
    If arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] == 0
      // случаев нет
//    Elseif arrKolSl[ 1 ] > 0 .and. arrKolSl[ 2 ] == 0
//      p_tip_reestr := 1
//    Elseif arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] > 0
//      p_tip_reestr := 2
//    Elseif f_alert( { '', ;
    Else 
      p_tip_reestr := f_alert( { '', ;
        PadC( 'Выберите тип реестра случаев для отправки в ТФОМС', 70, '.' ), ;
        '' }, ;
        { ' Реестр ~обычный(' + lstr( arrKolSl[ 1 ] ) + ')', ' Реестр по ~диспансеризации(' + lstr( arrKolSl[ 2 ] ) + ')' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6,, 'BG+/RB,W+/R,W+/RB,GR+/R' ) //== 2
//      p_tip_reestr := 2
    Endif
    mywait()
//          Use ( cur_dir() + 'tmp' ) new
    _k := tmp->kol
    tmp->kol := 0
    tmp->summa := 0
    tmp->min_date := SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + '01' )
    For i := 0 To lenPZ
      pole := 'tmp->PZ' + lstr( i )
      &pole := 0
    Next
    r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    Set Order To 2
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human',, 'HUMAN' )
//    Use ( cur_dir() + 'tmpb' ) new
    SELECT tmpb
    Set Relation To FIELD->kod_human into HUMAN, To FIELD->kod_human into HUMAN_
//          Go Top
    tmpb->( dbSeek( kod_smo, .t. ) )
    Do While ! ( tmpb->( Eof() ) ) .and. ( tmpb->kod_smo == kod_smo )
//          Do While !Eof()
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
//            Skip
      tmpb->( dbSkip() )
    Enddo

    close_list_alias( { 'K006', 'PRPRK', 'HUMAN_3', 'HUMAN_', 'HUMAN' } )

    If tmp->kol == 0
      func_error( 4, 'После дополнительной проверки некого включать в реестр' )
    Else
      If _k != tmp->kol
//        Select TMPB
//        Delete For yes_del
//        Pack
altd()
        tmpb->( dbEval( {|| dbDelete() }, FIELD->yes_del ) )
        tmpb->( __dbPack() )
      Endif
//      If tmp->nyear > 2025
//        create1reestr19( tmp->( RecNo() ), tmp->nyear, tmp->nmonth )
//      Else
//        func_error( 10, 'Реестр ранее августа 2025 года не формируется!' )
//      Endif
    Endif
  Endif

  rest_box( buf )
  return nil