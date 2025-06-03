#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static Sreestr_sem := "Работа с реестрами"
Static Sreestr_err := "В данный момент с реестрами работает другой пользователь."

// 03.07.24
Function create_reestr()

  Local buf := save_maxrow(), i, j, k := 0, k1 := 0, arr, bSaveHandler, fl, pole, arr_m
  Local nameArr
  Local tip_lu

  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local arrKolSl

  If ! hb_user_curUser:isadmin()
    Return func_error( 4, err_admin )
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
  Endif
  If !myfiledeleted( cur_dir() + 'tmpb' + sdbf )
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + 'tmp' + sdbf )
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
  stat_msg( 'Подождите, работаю...' )
  dbCreate( cur_dir() + 'tmpb', { ;
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
  } )
  Use ( cur_dir() + 'tmpb' ) new
  Index On Str( kod_human, 7 ) to ( cur_dir() + 'tmpb' )

  adbf := { ;
    { 'MIN_DATE',    'D',     8,     0 }, ;
    { 'DNI',         'N',     3,     0 }, ;
    { 'NYEAR',       'N',     4,     0 }, ; // отчетный год;;
    { 'NMONTH',      'N',     2,     0 }, ; // отчетный месяц;;
    { 'KOL',         'N',     6,     0 }, ;
    { 'SUMMA',       'N',    15,     2 }, ;
    { 'KOD',         'N',     6,     0 } }

  mnyear := arr_m[ 1 ]
  mnmonth := arr_m[ 3 ]
  
  private p_array_PZ

// перенесено из reestrOMS_XML
  p_array_PZ := get_array_pz( mnyear )  // получим массив план-заказа на год составления реестра
  lenPZ := len( p_array_PZ )
// конец перенесено

  For i := 0 To lenPZ   // для таблицы _moXunit 03.02.23
    AAdd( adbf, { 'PZ' + lstr( i ), 'N', 9, 2 } )
  Next

  dbCreate( cur_dir() + 'tmp', adbf )

  Use ( cur_dir() + 'tmp' ) New Alias TMP
  Append Blank
  Replace tmp->nyear With mnyear, tmp->nmonth With mnmonth, tmp->min_date With arr_m[ 6 ]
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    If++k1 % 100 == 0
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
    Select HUMAN
    Skip
  Enddo
  Close databases
  If k == 0
    rest_box( buf )
    func_error( 4, 'Нет пациентов для включения в реестр с датой окончания ' + arr_m[ 4 ] )
  Else
    Use ( cur_dir() + 'tmp' ) new
    k := sys_date - tmp->min_date
    tmp->dni := iif( Between( k, 1, 999 ), k, 0 )
    Go Top
    rest_box( buf )
    If alpha_browse( T_ROW, 2, T_ROW + 7, 77, 'f1create_reestr', color0, ;
        'Невыписанные реестры случаев', 'R/BG', , , , , 'f2create_reestr', , ;
        { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B,R/BG', .f., 180 } )
      rest_box( buf )
      // if .f.
      If sys_date < SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + "11" )
        func_error( 10, "Сегодня " + date_8( sys_date ) + ", а реестры разрешается отсылать с 11 числа" )
      Elseif mo_lock_task( X_OMS )
        Close databases
        fl := .t.
        bSaveHandler := ErrorBlock( {| x| Break( x ) } )
        Begin Sequence
          r_use( dir_server() + "human" )
          Index On Str( schet, 6 ) + Str( tip_h, 1 ) + Upper( SubStr( fio, 1, 20 ) ) to ( dir_server() + "humans" ) progress
          Index On Str( if( kod > 0, kod_k, 0 ), 7 ) + Str( tip_h, 1 ) to ( dir_server() + "humankk" ) progress
          Index On DToS( k_data ) + uch_doc to ( dir_server() + "humand" ) progress
          Use
          r_use( dir_server() + "human_u" )
          Index On Str( kod, 7 ) + date_u to ( dir_server() + "human_u" ) progress
          Use
          r_use( dir_server() + "mo_hu" )
          Index On Str( kod, 7 ) + date_u to ( dir_server() + "mo_hu" ) progress
          Use
          r_use( dir_server() + "human_3" )
          Index On Str( kod, 7 ) to ( dir_server() + "human_3" ) progress
          Index On Str( kod2, 7 ) to ( dir_server() + "human_32" ) progress
          Use
          r_use( dir_server() + "mo_onkna" )
          Index On Str( kod, 7 ) to ( dir_server() + "mo_onkna" ) progress
          r_use( dir_server() + "mo_onksl" )
          Index On Str( kod, 7 ) to ( dir_server() + "mo_onksl" ) progress
          r_use( dir_server() + "mo_onkco" )
          Index On Str( kod, 7 ) to ( dir_server() + "mo_onkco" ) progress
          r_use( dir_server() + "mo_onkdi" )
          Index On Str( kod, 7 ) + Str( diag_tip, 1 ) + Str( diag_code, 3 ) to ( dir_server() + "mo_onkdi" ) progress
          r_use( dir_server() + "mo_onkpr" )
          Index On Str( kod, 7 ) + Str( prot, 1 ) to ( dir_server() + "mo_onkpr" ) progress
          r_use( dir_server() + "mo_onkus" )
          Index On Str( kod, 7 ) + Str( usl_tip, 1 ) to ( dir_server() + "mo_onkus" ) progress
          r_use( dir_server() + "mo_onkle" )
          Index On Str( kod, 7 ) + regnum + code_sh + DToS( date_inj ) to ( dir_server() + "mo_onkle" ) progress
          Use
        RECOVER USING error
          fl := func_error( 10, "Возникла непредвиденная ошибка при переиндексировании!" )
        End
        ErrorBlock( bSaveHandler )
        Close databases
        If fl
          // Private kol_1r := 0, kol_2r := 0
          private p_tip_reestr := 1
          arrKolSl := verify_oms( arr_m, .f. )
          clrline( MaxRow(), color0 )
          // If kol_1r == 0 .and. kol_2r == 0
          If arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] == 0
            //
          // Elseif kol_1r > 0 .and. kol_2r == 0
          Elseif arrKolSl[ 1 ] > 0 .and. arrKolSl[ 2 ] == 0
            p_tip_reestr := 1
          // Elseif kol_1r == 0 .and. kol_2r > 0
          Elseif arrKolSl[ 1 ] == 0 .and. arrKolSl[ 2 ] > 0
            p_tip_reestr := 2
          // Elseif f_alert( { "", ;
          //     PadC( "Выберите тип реестра случаев для отправки в ТФОМС", 70, "." ), ;
          //     "" }, ;
          //     { " Реестр ~обычный(" + lstr( kol_1r ) + ")", " Реестр по ~диспансеризации(" + lstr( kol_2r ) + ")" }, ;
          //     1, "W/RB", "G+/RB", MaxRow() -6,, "BG+/RB,W+/R,W+/RB,GR+/R" ) == 2
          Elseif f_alert( { "", ;
              PadC( "Выберите тип реестра случаев для отправки в ТФОМС", 70, "." ), ;
              "" }, ;
              { " Реестр ~обычный(" + lstr( arrKolSl[ 1 ] ) + ")", " Реестр по ~диспансеризации(" + lstr( arrKolSl[ 2 ] ) + ")" }, ;
              1, "W/RB", "G+/RB", MaxRow() -6,, "BG+/RB,W+/R,W+/RB,GR+/R" ) == 2
            p_tip_reestr := 2
          Endif
          mywait()
          Use ( cur_dir() + "tmp" ) new
          _k := tmp->kol
          tmp->kol := 0
          tmp->summa := 0
          tmp->min_date := SToD( StrZero( tmp->nyear, 4 ) + StrZero( tmp->nmonth, 2 ) + "01" )
          For i := 0 To lenPZ   // 99
            pole := "tmp->PZ" + lstr( i )
            &pole := 0
          Next
          r_use( dir_server() + "human_3", { dir_server() + "human_3", dir_server() + "human_32" }, "HUMAN_3" )
          Set Order To 2
          r_use( dir_server() + "human_",, "HUMAN_" )
          r_use( dir_server() + "human",, "HUMAN" )
          Use ( cur_dir() + "tmpb" ) new
          Set Relation To kod_human into HUMAN, To kod_human into HUMAN_
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
              pole := "tmp->PZ" + lstr( j )
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
            func_error( 4, "После дополнительной проверки некого включать в реестр" )
          Else
            If _k != tmp->kol
              Select TMPB
              Delete For yes_del
              Pack
            Endif
            If tmp->nyear > 2018 // 2019 год
              create1reestr19( tmp->( RecNo() ), tmp->nyear, tmp->nmonth )
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
  Close databases

  Return Nil

// 10.06.22
Function f1create_reestr( oBrow )

  Local oColumn, n := 36, n1 := 20, blk

  oColumn := TBColumnNew( 'Отчетный год', {|| Str( tmp->nyear, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Отчетный месяц', {|| Str( tmp->nmonth, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Дни max', {|| put_val( tmp->dni, 3 ) } )
  oColumn:defColor := { 5, 5 }
  oColumn:colorBlock := {|| { 5, 5 } }
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол-во больных', {|| Str( tmp->kol, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Сумма случаев', {|| Str( tmp->summa, 15, 2 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ выход;  ^<Enter>^ составить реестр случаев;  ^<F9>^ печать списка пациентов' )

  Return Nil

// 19.11.23
Function f2create_reestr( nKey, oBrow )

  Local buf, rec, k := -1, sh := 80, HH := 60, nfile := cur_dir() + 'spisok.txt', j := 0

  Do Case
  Case nkey == K_F9
    buf := save_maxrow()
    mywait()
    rec := tmp->( RecNo() )
    fp := FCreate( nfile )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Список пациентов за отчётный период ' + Str( tmp->nyear, 4 ) + '/' + StrZero( tmp->nmonth, 2 ), sh ) )
    add_string( '' )
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    r_use( dir_server() + 'human', , 'HUMAN' )
    Set Relation To otd into OTD
    Use ( cur_dir() + 'tmpb' ) new
    Set Relation To kod_human into HUMAN
    Index On Upper( human->fio ) + DToS( human->k_data ) to ( cur_dir() + 'tmpb' ) For kod_tmp == rec
    Go Top
    Do While !Eof()
      verify_ff( HH, .t., sh )
      add_string( Str( ++j, 5 ) + '. ' + PadR( human->fio, 47 ) + date_8( human->n_data ) + '-' + ;
        date_8( human->k_data ) + ' [' + otd->short_name + ']' )
      Skip
    Enddo
    FClose( fp )
    otd->( dbCloseArea() )
    human->( dbCloseArea() )
    tmpb->( dbCloseArea() )
    Select TMP
    rest_box( buf )
    viewtext( nfile, , , , , , , 2 )
  Endcase

  Return k
