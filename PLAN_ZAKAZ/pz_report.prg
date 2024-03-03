#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'
#include 'hbxlsxwriter.ch'

// статистика по план-заказу
Function pz_statist( k )

  Static si1 := 2
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { 'По ~одному счету', ;
      'По ~счетам за отчётный период', ;
      'По счетам по дате окончания ~лечения', ;
      'По ~невыписанным счетам', ;
      '~Расчёт потребности в фин.обеспечении' }
    mas_msg := { 'Статистика по конкретному счету', ;
      'Статистика по счетам за отчётный период времени (кратный месяцу)', ;
      'Статистика по счетам с выборкой по дате окончания лечения', ;
      'Статистика по невыписанным счетам', ;
      'Расчёт потребности в финансовом обеспечении выполнения объёмов мед.помощи' }
    mas_fun := { 'pz_statist(11)', ;
      'pz_statist(12)', ;
      'pz_statist(13)', ;
      'pz_statist(14)', ;
      'pz_statist(15)' }
    popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    pz1statist( 1 )
  Case k == 12
    pz1statist( 2, 1 )
  Case k == 13
    pz1statist( 2, 2 )
  Case k == 14
    pz1statist( 3 )
  Case k == 15
    pz_raschet_potr()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 03.03.24
Function pz1statist( par, par2 )

  Static _su := 2
  Local buf := SaveScreen(), fl_exit := .f., fl := .t., a_otd := {}, ;
    name_file := cur_dir + 'plan_z' + stxt, arr_m, ta[ 2 ], arr_title, ;
    sh := 80, HH := 60, reg_print := 2, ;
    mstr_crb, ltrud, lplan, lcount_uch, lcount_otd, mismo
  Local sbase, i, k, j
  local strOut
  // для Excel
  Local lExcel := .f., lText := .f., used_column := 0 
  Local name_fileXLS := 'Plan_zakaz_' + suffixfiletimestamp()
  Local name_fileXLS_full := hb_DirTemp() + name_fileXLS + '.xlsx'
  Local workbook
  Local worksheet, wsCommon
  Local row, column, rowWS, columnWS
  local arrOutput
  Local header, header_wrap
  Local formatDate
  Local fmtCellNumber, fmtCellString, fmtCellStringCenter, fmtCellNumberRub
  Local s1, s2, s3
  Local wsCommon_format, wsCommon_format_header, wsCommon_String_Right
  Local wsCommon_format_wrap, wsCommon_Number, wsCommon_Number_Rub


  Private flag_uet := .t., as[ 10, 3 ], s_stac, sdstac, s_amb, skt, ssmp, suet, sstoim, ;
    su, su1, arr_goi, arr_zn := { B_END, B_STANDART }, arr_rees_no := { 1, 2 }, ;
    kol_sl_2 := {}, arr_lp := {}, fl_period := .f.
  Private fl_plan := .f., ym_kol_mes := 1, tfoms_pz[ 6 ]

  AFill( tfoms_pz, 0 )
  If par > 1 .and. ( arr_goi := ret_g_o_i( T_ROW, T_COL - 5 ) ) == NIL
    Return Nil
  Endif
  Private v_deti := 1, apf := {},   apz2016 := {}, luapz2016 := {}  //, ;
    // is_2019 := .f., is_2020 := .f., is_2021 := .f., is_2022 := .f., is_2023 := .f.
  If ( v_deti := popup_prompt( T_ROW, T_COL - 5, 1, { 'по ~всем пациентам', 'по ~детям' }, , , 'N/G*,W+/B,B/G*,BG+/B' ) ) == 0
    RestScreen( buf )
    Return Nil
  Endif
  If par == 1
    arr_goi := { 1, 2 }
    Private p_number, p_date
    If !input_schet( 15 )
      RestScreen( buf )
      Return Nil
    Endif
    r_use( dir_server + 'schet_', , 'SCHET_' )
    r_use( dir_server + 'schet', dir_server + 'schetk', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    find ( Str( glob_schet, 6 ) )
    begin_date := end_date := Chr( Int( Val( Left( Str( schet_->nyear, 4 ), 2 ) ) ) ) + Chr( Int( Val( SubStr( Str( schet_->nyear, 4 ), 3 ) ) ) )
    begin_date += Chr( schet_->nmonth ) + Chr( 1 )
    end_date += Chr( schet_->nmonth ) + Chr( 1 )
    end_date := dtoc4( EoM( c4tod( end_date ) ) )
    arr_m := { schet_->nyear, schet_->nmonth, schet_->nmonth, '', c4tod( begin_date ), c4tod( end_date ), begin_date, end_date }
    Close databases
  Elseif par == 2
    If ( arr_m := year_month( T_ROW, T_COL - 5 ) ) == NIL
      Return Nil
    Endif
    If par2 == 1
      Private mdate_reg
      If !is_otch_period( arr_m )
        Return Nil
      Elseif !ret_date_reg_otch_period()
        Return Nil
      Endif
    Endif
    If mem_trudoem == 2 .and. mem_tr_plan == 2 .and. ym_kol_mes > 0
      fl_plan := .t.
    Endif
    fl := pz2statist( arr_m, par2 )
  Else
    If yes_vypisan == B_END .and. ( arr_zn := ret_z_n( T_ROW, T_COL - 5 ) ) == NIL
      Return Nil
    Endif
    If AScan( arr_zn, B_STANDART ) > 0 .and. ( arr_rees_no := ret_reestr_no( T_ROW, T_COL - 5 ) ) == NIL
      Return Nil
    Endif
    If ( arr_m := year_month( T_ROW, T_COL - 5 ) ) == NIL
      Return Nil
    Endif
  Endif
  If arr_m[ 6 ] < 0d20200101
    Return func_error( 4, 'Отчётный период должен быть не ранее 2020 года' )
  Endif
  mas_pmt := { 'Список ~отделений (план-заказ)', ;
    'Вывод списка ~услуг (план-заказ)', ;
    '~Службы + услуги (список услуг)', ;
    'Наработка по ~врачам (список услуг)' }
  If ( su := popup_prompt( T_ROW, T_COL - 5, _su, mas_pmt ) ) == 0
    fl := .f.
  Elseif su == 4 .and. ( su1 := popup_prompt( T_ROW, T_COL - 5, 1, { '~Итоговые суммы по врачам', 'С расшифровкой ~услуг' } ) ) == 0
    fl := .f.
  Endif
  If !fl
    RestScreen( buf )
    Return Nil
  Endif
  _su := su 
  If Between( par, 2, 3 ) .and. eq_any( su, 1, 2, 5 )
    sbase := prefixfilerefname( arr_m[ 1 ] ) + 'unit'
    r_use( dir_exe + sbase, , 'MOUNIT' )
    Index On Str( ii, 3 ) to ( cur_dir + 'tmp_unitii' )
    Set Index to ( cur_dir + sbase ), ( cur_dir + 'tmp_unitii' )
    apz2016 := arr_plan_zakaz( arr_m[ 1 ] )
    luapz2016 := arr_plan_zakaz( arr_m[ 1 ] )
    kol_sl_2 := Array( Len( apz2016 ) )
    AFill( kol_sl_2, 0 )
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL - 5, , , @lcount_uch ) ) == NIL
    RestScreen( buf )
    Return Nil
  Endif
  If par < 3 .and. menu_schet_akt() == 0
    RestScreen( buf )
    Return Nil
  Endif
  If Len( st_a_uch ) == 1
    glob_uch := st_a_uch[ 1 ]
    If ( st_a_otd := inputn_otd( T_ROW, T_COL - 5, .f., .f., glob_uch, @lcount_otd ) ) == NIL
      RestScreen( buf )
      Return Nil
    Endif
    AEval( st_a_otd, {| x| AAdd( a_otd, x[ 1 ] ) } )
  Else
    r_use( dir_server + 'mo_otd', , 'OTD' )
    Go Top
    Do While !Eof()
      If f_is_uch( st_a_uch, otd->kod_lpu ) .and. ;
          iif( ValType( arr_m ) == 'A', between_date( otd->DBEGIN, otd->DEND, arr_m[ 5 ], arr_m[ 6 ] ), .t. )
        AAdd( a_otd, otd->( RecNo() ) )
      Endif
      Skip
    Enddo
    otd->( dbCloseArea() )
  Endif
  adbf := { { 'kod', 'N', 4, 0 }, ;
    { 'kod1', 'N', 4, 0 }, ;
    { 'shifr', 'C', 10, 0 }, ;
    { 'u_name', 'C', 255, 0 }, ;
    { 'kol', 'N', 7, 0 }, ;
    { 'kol1', 'N', 7, 0 }, ;
    { 'uet', 'N', 11, 4 }, ;
    { 'sum', 'N', 13, 2 } }
  dbCreate( cur_dir + 'tmp_xls', adbf )
  Use ( cur_dir + 'tmp_xls' ) new
  dbCreate( cur_dir + 'tmp', adbf )
  Use ( cur_dir + 'tmp' ) new
  If su > 2
    Index On Str( kod, 4 ) to ( cur_dir + 'tmp' )
  Else
    Index On shifr to ( cur_dir + 'tmp' )
  Endif
  If su == 4
    dbCreate( cur_dir + 'tmp1', adbf )
    Use ( cur_dir + 'tmp1' ) new
    Index On Str( kod, 4 ) + Str( kod1, 4 ) to ( cur_dir + 'tmp1' )
  Endif
  adbf := { { 'otd', 'N', 3, 0 }, ;
    { 'uch', 'N', 3, 0 }, ;
    { 'kol1', 'N', 7, 0 }, ;
    { 'kol2', 'N', 7, 0 }, ;
    { 'kol3', 'N', 7, 0 }, ;
    { 'kol4', 'N', 7, 0 }, ;
    { 'kol5', 'N', 12, 2 }, ;
    { 'kol6', 'N', 7, 0 }, ;
    { 'kol7', 'N', 7, 0 }, ;
    { 'kol8', 'N', 7, 0 }, ;
    { 'kol9', 'N', 7, 0 }, ;
    { 'kol10', 'N', 7, 0 } }
  dbCreate( cur_dir + 'tmpo', adbf )
  Use ( cur_dir + 'tmpo' ) new
  Index On Str( otd, 3 ) to ( cur_dir + 'tmpo' )
  dbCreate( cur_dir + 'tmpok', { { 'otd', 'N', 3, 0 }, { 'kod_k', 'N', 7, 0 } } )
  Use ( cur_dir + 'tmpok' ) new
  Index On Str( otd, 3 ) + Str( kod_k, 7 ) to ( cur_dir + 'tmpok' )
  dbCreate( cur_dir + 'tmpos', { { 'otd', 'N', 3, 0 }, { 'kod', 'N', 7, 0 } } )
  Use ( cur_dir + 'tmpos' ) new
  Index On Str( otd, 3 ) + Str( kod, 7 ) to ( cur_dir + 'tmpos' )
  r_use( dir_server + 'mo_su', , 'MOSU' )
  r_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u_', , 'HU_' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To u_kod into USL, To RecNo() into HU_
  afillall( as, 0 )
  s_stac := sdstac := s_amb := skt := ssmp := suet := sstoim := 0
  waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  If par == 1
    r_use( dir_server + 'schet_', , 'SCHET_' )
    r_use( dir_server + 'schet', dir_server + 'schetk', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    find ( Str( glob_schet, 6 ) )
    p_number := AllTrim( schet_->NSCHET )
    p_date := schet_->DSCHET
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    find ( Str( glob_schet, 6 ) )
    Do While human->schet == glob_schet .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If f_usl_schet_akt( human_->oplata ) .and. iif( v_deti == 1, .t., human->VZROS_REB > 0 )
        f1pz1statist( a_otd, 1 )
      Endif
      Select HUMAN
      Skip
    Enddo
  Elseif par == 2
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    Use ( cur_dir + 'tmp_smo' ) index ( cur_dir + 'tmp_smo1' ) new
    r_use( dir_server + 'schet_', , 'SCHET_' )
    r_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
    Set Relation To RecNo() into SCHET_
    Set Filter To Empty( schet_->IS_DOPLATA )
    Go Top
    Do While !Eof()
      If par2 == 1
        If emptyany( schet_->nyear, schet_->nmonth )
          fl := Between( schet->pdate, arr_m[ 7 ], arr_m[ 8 ] )
        Else
          mdate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '15' )
          If ( fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] ) )
            fl_period := .t.
          Endif
        Endif
        If fl .and. mdate_reg != NIL
          fl := ( schet_->NREGISTR == 0 .and. date_reg_schet() <= mdate_reg )
        Endif
      Else
        If emptyany( schet_->nyear, schet_->nmonth )
          fl := .f.
        Else
          mdate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '01' )
          Do While .t.
            If ( fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] ) )
              Exit
            Endif
            ++mdate
            If mdate == EoM( mdate )
              Exit
            Endif
          Enddo
        Endif
      Endif
      If fl
        If schet_->ifin > 0
          mkomu := 0
          mstr_crb := 0
          msmo := schet_->smo
        Else
          mkomu := iif( schet->komu == 1, 1, 3 )
          mstr_crb := schet->str_crb
          msmo := Space( 5 )
        Endif
        Select TMP_SMO
        find ( Str( mkomu, 1 ) + Str( mstr_crb, 2 ) + msmo )
        If Found() .and. tmp_smo->is == 1
          @ MaxRow(), 0 Say PadR( '№ ' + AllTrim( schet_->NSCHET ) + ' от ' + date_8( schet_->DSCHET ), 28 ) Color 'W/R'
          Select HUMAN
          find ( Str( schet->kod, 6 ) )
          Do While human->schet == schet->kod .and. !Eof()
            updatestatus()
            If Inkey() == K_ESC
              fl_exit := .t. ; Exit
            Endif
            If iif( par2 == 1, .t., Between( human->k_data, arr_m[ 5 ], arr_m[ 6 ] ) ) ;
                .and. f_usl_schet_akt( human_->oplata ) ;
                .and. iif( v_deti == 1, .t., human->VZROS_REB > 0 )
              f1pz1statist( a_otd, 1 )
            Endif
            Select HUMAN
            Skip
          Enddo
          If fl_exit ; exit ; Endif
        Endif
      Endif
      Select SCHET
      Skip
    Enddo
  Else
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humann', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    dbSeek( '1', .t. )
    Do While human->tip_h < B_SCHET .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If Between( human->k_data, arr_m[ 5 ], arr_m[ 6 ] ) .and. AScan( arr_zn, human->tip_h ) > 0 ;
          .and. iif( v_deti == 1, .t., human->VZROS_REB > 0 )
        If human_->reestr == 0
          fl := AScan( arr_rees_no, 1 ) > 0
        Else
          fl := AScan( arr_rees_no, 2 ) > 0
        Endif
        If fl
          f1pz1statist( a_otd, 2 )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
  Endif
  If su == 1
    sh := 86
  Endif
  For i := 1 To Len( apz2016 )
    AAdd( adbf, { 'kol' + StrZero( apz2016[ i, 2 ], 2 ), 'N', 9, 2 } )
  Next
  //
  if lExcel
    workbook  := workbook_new( name_fileXLS_full )
    wsCommon := workbook_add_worksheet( workbook, hb_StrToUTF8( 'Описание' ) )
    worksheet := workbook_add_worksheet( workbook, hb_StrToUTF8( 'Список' ) )
    worksheet_set_column( wsCommon, 7, 7, 15, nil )

    wsCommon_format := workbook_add_format( workbook )
    format_set_align( wsCommon_format, LXW_ALIGN_CENTER )
    format_set_align( wsCommon_format, LXW_ALIGN_VERTICAL_CENTER )
    format_set_bold( wsCommon_format )

    wsCommon_format_wrap := workbook_add_format( workbook )
    format_set_align( wsCommon_format_wrap, LXW_ALIGN_CENTER )
    format_set_align( wsCommon_format_wrap, LXW_ALIGN_VERTICAL_CENTER )
    format_set_text_wrap( wsCommon_format_wrap )
    format_set_bold( wsCommon_format_wrap )

    wsCommon_format_header := workbook_add_format( workbook )
    format_set_align( wsCommon_format_header, LXW_ALIGN_CENTER )
    format_set_align( wsCommon_format_header, LXW_ALIGN_VERTICAL_CENTER )
    format_set_bold( wsCommon_format_header )
    format_set_font_size( wsCommon_format_header, 20 )

    wsCommon_Number := workbook_add_format( workbook )
    format_set_align( wsCommon_Number, LXW_ALIGN_CENTER )
    format_set_align( wsCommon_Number, LXW_ALIGN_VERTICAL_CENTER )

    wsCommon_Number_Rub := workbook_add_format( workbook )
    format_set_align( wsCommon_Number_Rub, LXW_ALIGN_RIGHT )
    format_set_align( wsCommon_Number_Rub, LXW_ALIGN_VERTICAL_CENTER )
    format_set_num_format( wsCommon_Number_Rub, '#,##0.00' )

    wsCommon_String_Right := workbook_add_format( workbook )
    format_set_align( wsCommon_String_Right, LXW_ALIGN_RIGHT )
    format_set_align( wsCommon_String_Right, LXW_ALIGN_VERTICAL_CENTER )

    row := 0
    column := 0
    rowWS := 0
    columnWS := 0
    worksheet_write_string( wsCommon, row++, column, hb_StrToUTF8( 'дата печати ' + date_8( sys_date ) + ' ' + hour_min( Seconds() ) ) ) //, header )
    arrOutput := arr_titleN_uch( st_a_uch, lcount_uch )
    For i := 1 To Len( arrOutput )
      worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format_wrap )
      worksheet_write_string( wsCommon, row++, column, hb_StrToUTF8( arrOutput[ i ] ), wsCommon_format_wrap )
    next
    If Len( st_a_uch ) == 1
      arrOutput := arr_titlen_otd( st_a_otd, lcount_otd )
      For i := 1 To Len( arrOutput )
        worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format_wrap )
        worksheet_write_string( wsCommon, row++, column, hb_StrToUTF8( arrOutput[ i ] ), wsCommon_format_wrap )
      next
    Endif
    row++
    worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format_header )
    worksheet_write_string( wsCommon, row++, column, ;
      hb_StrToUTF8( iif( su > 2, 'Список оказанных услуг', 'Статистика по выполнению план-заказа' ) ), wsCommon_format_header )
  else
    fp := FCreate( name_file )
    tek_stroke := 0
    n_list := 1
    add_string( PadL( 'дата печати ' + date_8( sys_date ) + ' ' + hour_min( Seconds() ), sh ) )
    titlen_uch( st_a_uch, sh, lcount_uch )
    If Len( st_a_uch ) == 1
      titlen_otd( st_a_otd, sh, lcount_otd )
    Endif
    add_string( '' )
    If su > 2
      add_string( PadC( 'Список оказанных услуг', sh ) )
    Else
      add_string( PadC( 'Статистика по выполнению план-заказа', sh ) )
    Endif
  endif
  Select TMP_XLS
  Append Blank
  If par == 1
    strOut := 'по счету № ' + p_number + ' от ' + full_date( p_date ) + ' г.'
    if lExcel
      worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
      worksheet_write_string( wsCommon, row++, column, ;
        hb_StrToUTF8(strOut ), wsCommon_format )
    else
      add_string( Center( strOut, sh ) )
    endif
    tmp_xls->u_name := strOut
  Elseif par == 2 .and. par2 == 1
    strOut := 'по счетам ' + arr_m[ 4 ]
    if lExcel
      worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
      worksheet_write_string( wsCommon, row++, column, ;
        hb_StrToUTF8( strOut ), wsCommon_format )
    else
      add_string( Center( strOut, sh ) )
    endif
    tmp_xls->u_name := strOut
    If fl_period
      strOut := '[ подсчёт производится по отчётному периоду]'
      if lExcel
        worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
        worksheet_write_string( wsCommon, row++, column, ;
          hb_StrToUTF8( strOut ), wsCommon_format )
      else
          add_string( Center( strOut, sh ) )
      endif
    endif
    Select TMP_XLS
    Append Blank
    tmp_xls->u_name := strOut
    If mdate_reg != NIL
      strOut := '[ по счетам, зарегистрированным по ' + full_date( mdate_reg ) + 'г. включительно ]'
      if lExcel
        worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
        worksheet_write_string( wsCommon, row++, column, ;
          hb_StrToUTF8( strOut ), wsCommon_format )
      else
        add_string( Center( strOut, sh ) )
      endif
      Select TMP_XLS
      Append Blank
      tmp_xls->u_name := strOut
    Endif
  Elseif par == 2 .and. par2 == 2
    if lExcel
      strOut := 'по счетам (дата окончания лечения ' + arr_m[ 4 ] + ')'
      worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
      worksheet_write_string( wsCommon, row++, column, ;
        hb_StrToUTF8( strOut ), wsCommon_format )
    else
      add_string( Center( strOut, sh ) )
    endif
    tmp_xls->u_name := strOut
  Else
    strOut := 'по невыписанным счетам (дата окончания лечения ' + arr_m[ 4 ] + ')'
    if lExcel
      worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
      worksheet_write_string( wsCommon, row++, column, ;
        hb_StrToUTF8( strOut ), wsCommon_format )
    else
      add_string( Center( strOut, sh ) )
    endif
    tmp_xls->u_name := strOut
  Endif
  If v_deti == 2
    strOut := '[ ПО ДЕТЯМ ]'
    if lExcel
      worksheet_merge_range( wsCommon, row, column, row, 8, '', wsCommon_format )
      worksheet_write_string( wsCommon, row++, column, ;
        hb_StrToUTF8( strOut ), wsCommon_format )
    else
      add_string( Center( strOut, sh ) )
    endif
    Select TMP_XLS
    Append Blank
    tmp_xls->u_name := Center( strOut, sh )
  Endif

  If par < 3
    if lExcel
      strOut := title_schet_akt( glob_schet_akt )
      worksheet_write_string( wsCommon, row++, column, ;
        hb_StrToUTF8( strOut ) ) //, header )
    else
      add_string( Center( strOut, sh ) )
    endif
  Endif
  If eq_any( su, 1, 2, 5 )
    k := 0
    if lExcel
      worksheet_merge_range( wsCommon, row, 0, row, 5, '' ) //, wsCommon_format_wrap )
      worksheet_write_string( wsCommon, row, 6, ;
        hb_StrToUTF8( 'план-заказ' ) ) //, header )
      worksheet_write_string( wsCommon, row, 7, ;
        hb_StrToUTF8( 'листов учета' ) ) //, header )
      worksheet_write_string( wsCommon, row++, 8, ;
        hb_StrToUTF8( 'сумма' ) ) //, header )
    else
      add_string( '' )
      add_string( '──────────────────────────────────────────┬──────────┬────────────┬──────────────' )
      add_string( '                                          │план-заказ│листов учета│    сумма     ' )
      add_string( '──────────────────────────────────────────┴──────────┴────────────┴──────────────' )
    endif
    For i := 1 To Len( luapz2016 )
      If luapz2016[ i, 3 ] > 0 .or. apz2016[ i, 3 ] > 0
        if lExcel
          worksheet_merge_range( wsCommon, row, 0, row, 5, '' ) //, wsCommon_format_wrap )
          worksheet_write_string( wsCommon, row, 0, ;
            hb_StrToUTF8( luapz2016[ i, 1 ] ) ) //, header )
        else
          s := PadL( luapz2016[ i, 1 ], 42 )
        endif
        If Empty( apz2016[ i, 3 ] ) .and. !Empty( luapz2016[ i, 3 ] )
          if lExcel
            worksheet_write_number( wsCommon, row, 6, ;
              ( luapz2016[ i, 3 ] - kol_sl_2[ i ] ) ) //, header )
          else
            s += Str( luapz2016[ i, 3 ] - kol_sl_2[ i ], 10, 0 )
          endif
        Else
          if lExcel
            worksheet_write_number( wsCommon, row, 6, ;
              ( apz2016[ i, 3 ] - kol_sl_2[ i ] ) ) //, header )
          else
            s += Str( apz2016[ i, 3 ] - kol_sl_2[ i ], 10, 0 )
          endif
        Endif
        if lExcel
          worksheet_write_number( wsCommon, row, 7, ;
            luapz2016[ i, 3 ] ) //, header )
          worksheet_write_number( wsCommon, row++, 8, ;
            luapz2016[ i, 2 ] ) //, header )
        else
          s += Str( luapz2016[ i, 3 ], 10, 0 ) + Str( luapz2016[ i, 2 ], 17, 2 )
          add_string( s )
        endif
        k += luapz2016[ i, 3 ]
      Endif
    Next
    if lExcel
      worksheet_merge_range( wsCommon, row, 0, row, 5, '', wsCommon_String_Right )
      worksheet_write_string( wsCommon, row, 0, ;
        hb_StrToUTF8( 'Всего листов учета' ), wsCommon_String_Right )
      worksheet_write_number( wsCommon, row, 7, ;
        k ) //, header )
      worksheet_write_number( wsCommon, row++, 8, ;
        sstoim ) //, header )

      worksheet_merge_range( wsCommon, ++row, 0, row, 5, '' ) //, wsCommon_format_wrap )
      worksheet_write_string( wsCommon, row, 6, ;
        hb_StrToUTF8( 'Кол-во услуг' ) ) //, header )
      worksheet_write_string( wsCommon, row, 7, ;
        hb_StrToUTF8( 'У.Е.Т.' ) ) //, header )
      worksheet_write_string( wsCommon, row++, 8, ;
        hb_StrToUTF8( 'Стоимость услуг' ) ) //, header )
    else
      add_string( Replicate( '─', sh ) )
      add_string( PadL( 'Всего листов учета', 42 ) + Str( k, 20, 0 ) + Str( sstoim, 17, 2 ) )
      add_string( '' )
      add_string( '─────────────────────────────────────────────────┬──────┬────────┬──────────────' )
      add_string( '                                                 │Кол-во│        │  Стоимость   ' )
      add_string( '                                                 │ услуг│ У.Е.Т. │    услуг     ' )
      add_string( '─────────────────────────────────────────────────┴──────┴────────┴──────────────' )
    endif
    For i := 1 To 10
      If !emptyall( as[ i, 1 ], as[ i, 2 ], as[ i, 3 ] )
        k := perenos( ta, f14tf_array()[ i ], 49 )
        If i == 6
          if lExcel
            worksheet_merge_range( wsCommon, row, 0, row, 5, '' ) //, wsCommon_format_wrap )
            worksheet_write_string( wsCommon, row, 0, ;
              hb_StrToUTF8( ta[ 1 ] ) ) //, header )
          else
            add_string( PadR( ta[ 1 ], 49 ) + Str( as[ i, 1 ], 7, 0 ) )
          endif
        Else
          if lExcel
            worksheet_merge_range( wsCommon, row, 0, row, 5, '' ) //, wsCommon_format_wrap )
            worksheet_write_string( wsCommon, row, 0, ;
              hb_StrToUTF8( ta[ 1 ] ) ) //, header )
            worksheet_write_number( wsCommon, row, 6, ;
              as[ i, 1 ] ) //, header )
            worksheet_write_number( wsCommon, row, 7, ;
              as[ i, 2 ] ) //, header )
            worksheet_write_number( wsCommon, row++, 8, ;
              as[ i, 3 ] ) //, header )
          else
            add_string( PadR( ta[ 1 ], 49 ) + Str( as[ i, 1 ], 7, 0 ) + ;
              umest_val( as[ i, 2 ], 9, 2 ) + ;
              put_kope( as[ i, 3 ], 15 ) )
          endif
        Endif
        if ! lExcel
          For j := 2 To k
            add_string( PadL( AllTrim( ta[ j ] ), 49 ) )
          Next
        endif
      Endif
    Next
  Endif
  If su == 1
    if lExcel
      worksheet_write_string( worksheet, rowWS, 0, ;
        hb_StrToUTF8( 'Наименование отделения' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 1, ;
        hb_StrToUTF8( 'человек' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 2, ;
        hb_StrToUTF8( 'случаев' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 3, ;
        hb_StrToUTF8( 'койко-дней' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 4, ;
        hb_StrToUTF8( 'пациенто-дней' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 5, ;
        hb_StrToUTF8( 'врач.приемов' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 6, ;
        hb_StrToUTF8( 'стоматол.посещ' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 7, ;
        hb_StrToUTF8( 'стоматологических УЕТ' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 8, ;
        hb_StrToUTF8( 'отдел медиц услуг' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, 9, ;
        hb_StrToUTF8( 'вызовов СМП' ) ) //, header )
      rowWS++
    else
      arr_title := { ;
        '──────────────────────────────╥────┬─────╥─────┬─────┬─────┬─────┬────────┬─────┬─────', ;
        '                              ║ че-│ слу-║кой- │паци-│врач.│стома│стомато-│отдел│вызо-', ;
        '  Наименование отделения      ║ ло-│ ча- ║ко-  │енто-│приё-│тол. │логичес-│медиц│вов  ', ;
        '                              ║ век│ ев  ║дней │дней │мов  │посещ│ких УЕТ │услуг│СМП  ', ;
        '──────────────────────────────╨────┴─────╨─────┴─────┴─────┴─────┴────────┴─────┴─────';
        }
    //
      AEval( arr_title, {| x| add_string( x ) } )
    endif
    n1 := 30
    r_use( dir_server + 'mo_uch', , 'UCH' )
    r_use( dir_server + 'mo_otd', , 'OTD' )
    Set Relation To kod_lpu into UCH
    Select TMPO
    Set Index To
    dbEval( {|| otd->( dbGoto( tmpo->otd ) ), tmpo->uch := otd->kod_lpu } )
    Set Relation To otd into OTD
    Index On Upper( uch->name ) + Str( uch, 3 ) + Upper( otd->name ) + Str( otd, 3 ) to ( cur_dir + 'tmpo' )
    old_uch := 0
    Go Top
    Do While !Eof()
      if ! lExcel
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
      endif
      If old_uch != tmpo->uch
        If old_uch > 0
          if !lExcel
            add_string( '' )
          endif
        Endif
        if lExcel
          worksheet_write_string( worksheet, rowWS++, 0, ;
            hb_StrToUTF8( Upper( uch->name ) ) ) //, header )
        else
          add_string( Upper( uch->name ) )
          add_string( Replicate( '═', sh ) )
        endif
        old_uch := tmpo->uch
      Endif
      k := ks := 0
      Select TMPOK
      find ( Str( tmpo->otd, 3 ) )
      dbEval( {|| ++k }, , {|| tmpok->otd == tmpo->otd } )
      Select TMPOS
      find ( Str( tmpo->otd, 3 ) )
      dbEval( {|| ++ks }, , {|| tmpos->otd == tmpo->otd } )
      if lExcel
        columnWS := 0
        worksheet_write_string( worksheet, rowWS, columnWS++, ;
          hb_StrToUTF8( otd->name ) ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          k ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          ks ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmpo->kol1 ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmpo->kol2 ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmpo->kol3 ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmpo->kol4 ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmpo->kol5 ) //, header )
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmpo->kol6 ) //, header )
        worksheet_write_number( worksheet, rowWS++, columnWS, ;
          tmpo->kol7 ) //, header )
      else
        add_string( PadR( otd->name, n1 ) + ;
          put_val( k, 5 ) + ;
          put_val( ks, 6 ) + ;
          put_val( tmpo->kol1, 6 ) + ;
          put_val( tmpo->kol2, 6 ) + ;
          put_val( tmpo->kol3, 6 ) + ;
          put_val( tmpo->kol4, 6 ) + ;
          ' ' + umest_val( tmpo->kol5, 8, 2 ) + ;
          put_val( tmpo->kol6, 6 ) + ;
          put_val( tmpo->kol7, 6 ) )
      endif
      Select TMPO
      Skip
    Enddo
  Elseif eq_any( su, 2, 3 )
    n1 := iif( flag_uet, 49, 58 )
    if lExcel
      worksheet_write_string( worksheet, rowWS, columnWS++, ;
        hb_StrToUTF8( '' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, columnWS++, ;
        hb_StrToUTF8( 'Наименование услуги' ) ) //, header )
      worksheet_write_string( worksheet, rowWS, columnWS++, ;
        hb_StrToUTF8( 'Кол-во услуг' ) ) //, header )
    else
      arr_title := { ;
        Replicate( '─', n1 ), ;
        Space( n1 ), ;
        PadC( 'Наименование услуги', n1 ), ;
        Replicate( '─', n1 ) }
      arr_title[ 1 ] += '┬──────'
      arr_title[ 2 ] += '│Кол-во'
      arr_title[ 3 ] += '│ услуг'
      arr_title[ 4 ] += '┴──────'
    endif
    If flag_uet
      if lExcel
        worksheet_write_string( worksheet, rowWS, columnWS++, ;
          hb_StrToUTF8( 'У.Е.Т.' ) ) //, header )
      else
        arr_title[ 1 ] += '┬────────'
        arr_title[ 2 ] += '│        '
        arr_title[ 3 ] += '│ У.Е.Т. '
        arr_title[ 4 ] += '┴────────'
      endif
    Endif
    if lExcel
      worksheet_write_string( worksheet, rowWS++, columnWS, ;
        hb_StrToUTF8( 'Стоимость услуг' ) ) //, header )
    else
      arr_title[ 1 ] += '┬──────────────'
      arr_title[ 2 ] += '│  Стоимость   '
      arr_title[ 3 ] += '│    услуг     '
      arr_title[ 4 ] += '┴──────────────'
      AEval( arr_title, {| x| add_string( x ) } )
    endif

    Select HU
    Set Relation To
    If su == 2
      Select TMP
      Index On fsort_usl( shifr ) to ( cur_dir + 'tmp' )
      Go Top
      Do While !Eof()
        columnWS := 0
        if lExcel
          worksheet_write_string( worksheet, rowWS, columnWS++, ;
            hb_StrToUTF8( tmp->shifr ) ) //, header )
          worksheet_write_string( worksheet, rowWS, columnWS++, ;
            hb_StrToUTF8( tmp->u_name ) ) //, header )
          worksheet_write_number( worksheet, rowWS, columnWS++, ;
            tmp->kol ) //, header )
        else
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          k := perenos( as, tmp->u_name, n1 - 11 )
          s := tmp->shifr + ' ' + PadR( as[ 1 ], n1 - 11 ) + Str( tmp->kol, 7, 0 )
        endif
        If flag_uet
          If Empty( tmp->uet )
            If Empty( tmp->kol ) .and. !Empty( tmp->kol1 )
              strOut := ' (' + lstr( tmp->kol1 ) + ')'
              if lExcel
                worksheet_write_string( worksheet, rowWS, columnWS++, ;
                  hb_StrToUTF8( strOut ) ) //, header )
              else
                s += PadR( strOut, 9 )
              endif
            Else
              if lExcel
                worksheet_write_string( worksheet, rowWS, columnWS++, ;
                  hb_StrToUTF8( '' ) ) //, header )
              else
                s += Space( 9 )
              endif
            Endif
          Else
            if lExcel
              worksheet_write_number( worksheet, rowWS, columnWS++, ;
                tmp->uet ) //, header )
            else
              s += ' ' + umest_val( tmp->uet, 8, 2 )
            endif
          Endif
        Endif
        if lExcel
          worksheet_write_number( worksheet, rowWS, columnWS, ;
            tmp->sum ) //, header )
        else
          s += put_kope( tmp->sum, 14 )
          add_string( s )
        endif
        // 1-й
        Select TMP_XLS
        Append Blank
        tmp_xls->kod    := tmp->kod
        tmp_xls->shifr  := tmp->shifr
        tmp_xls->u_name := tmp->u_name
        tmp_xls->kol    := tmp->kol
        tmp_xls->sum    := tmp->sum
        // {'kol1', 'N', 7, 0}, ;
        if ! lExcel
          For j := 2 To k
            add_string( Space( 11 ) + as[ j ] )
          Next
        endif
        If ( j := AScan( arr_lp, {| x| x[ 1 ] == tmp->shifr } ) ) > 0
          For k := 1 To Len( arr_lp[ j, 2 ] )
            ASort( arr_lp[ j, 2 ], , , {| x, y| fsort_usl( x[ 1 ] ) < fsort_usl( y[ 1 ] ) } )
            if lExcel
              rowWS++
              worksheet_write_string( worksheet, rowWS, 1, ;
                hb_StrToUTF8( 'в т.ч. ' + AllTrim( arr_lp[ j, 2, k, 1 ] ) ) ) //, header )
              worksheet_write_number( worksheet, rowWS, 2, ;
                arr_lp[ j, 2, k, 2 ] ) //, header )
            else
              s := Space( 10 ) + 'в т.ч. ' + AllTrim( arr_lp[ j, 2, k, 1 ] )
              If Len( s ) > n1
                s := PadR( s, n1 )
              Else
                s := PadL( s, n1 )
              Endif
              s := s + Str( arr_lp[ j, 2, k, 2 ], 7 )
            endif
            If !Empty( arr_lp[ j, 2, k, 3 ] )
              if lExcel
                worksheet_write_string( worksheet, rowWS, 3, ;
                  hb_StrToUTF8( ' (' + lstr( arr_lp[ j, 2, k, 3 ] ) + ')' ) ) //, header )
              else
                s += ' (' + lstr( arr_lp[ j, 2, k, 3 ] ) + ')'
              endif
            Endif
            if ! lExcel
              If verify_ff( HH, .t., sh )
                AEval( arr_title, {| x| add_string( x ) } )
              Endif
              add_string( s )
            endif
          Next
        Endif
        Select TMP
        Skip
        if lExcel
          rowWS++
        endif
      Enddo
    Else
      Select TMP
      Set Relation To kod into USL
      r_use( dir_server + 'slugba', dir_server + 'slugba', 'SL' )
      Select USL
      Set Relation To Str( slugba, 3 ) into SL
      Select TMP
      Index On Str( usl->slugba, 3 ) + fsort_usl( usl->shifr ) to ( cur_dir + 'tmp' )
      old_s := -999
      ssl := Array( 3 ) ; AFill( ssl, 0 )
      Go Top
      Do While !Eof()
        columnWS := 0
        if ! lExcel
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
        endif
        If !( old_s == usl->slugba )
          If old_s > -999
            if lExcel
              worksheet_write_string( worksheet, rowWS, 1, ;
                hb_StrToUTF8( 'Итого по службе:' ) ) //, header )
              worksheet_write_number( worksheet, rowWS, 2, ;
                ssl[ 1 ] ) //, header )
            else
              add_string( Replicate( '─', sh ) )
              s := PadL( 'Итого по службе:', n1 ) + Str( ssl[ 1 ], 7, 0 )
            endif
            If flag_uet
              if lExcel
                worksheet_write_number( worksheet, rowWS, 3, ;
                  ssl[ 2 ] ) //, header )
              else
                s += ' ' + umest_val( ssl[ 2 ], 8, 2 )
              endif
            Endif
            if lExcel
              worksheet_write_number( worksheet, rowWS++, 4, ;
                ssl[ 3 ] ) //, header )
            else
              s += put_kope( ssl[ 3 ], 14 )
              add_string( s )
              add_string( '' )
            endif
          Endif
          strOut := 'Служба: ' + lstr( usl->slugba ) + '.' + AllTrim( sl->name )
          if lExcel
            worksheet_write_string( worksheet, rowWS++, 1, ;
              hb_StrToUTF8( strOut ) ) //, header )
          else
            add_string( PadC( strOut, sh, '_' ) )
          endif
          old_s := usl->slugba
          AFill( ssl, 0 )
        Endif
        if lExcel
          worksheet_write_string( worksheet, rowWS, 0, ;
            hb_StrToUTF8( usl->shifr ) ) //, header )
          worksheet_write_string( worksheet, rowWS, 1, ;
            hb_StrToUTF8( usl->name ) ) //, header )
          worksheet_write_number( worksheet, rowWS, 2, ;
            tmp->kol ) //, header )
        else
          k := perenos( as, usl->name, n1 - 11 )
          s := usl->shifr + ' ' + PadR( as[ 1 ], n1 - 11 ) + Str( tmp->kol, 7, 0 )
        endif
        If flag_uet
          if lExcel
            worksheet_write_number( worksheet, rowWS, 3, ;
              tmp->uet ) //, header )
          else
            s += ' ' + umest_val( tmp->uet, 8, 2 )
          endif
        Endif
        if lExcel
          worksheet_write_number( worksheet, rowWS, 4, ;
            tmp->sum ) //, header )
        else
          s += put_kope( tmp->sum, 14 )
          add_string( s )
          For j := 2 To k
            add_string( Space( 11 ) + as[ j ] )
          Next
        endif
        ssl[ 1 ] += tmp->kol
        ssl[ 2 ] += tmp->uet
        ssl[ 3 ] += tmp->sum
        Select TMP_XLS
        Append Blank
        tmp_xls->kod    := tmp->kod
        tmp_xls->shifr  := tmp->shifr
        tmp_xls->u_name := tmp->u_name
        tmp_xls->kol    := tmp->kol
        tmp_xls->sum    := tmp->sum
        // {'kol1', 'N', 7, 0}, ;
        Select TMP
        Skip
        if lExcel
          rowWS++
        endif
      Enddo
      If ssl[ 1 ] > 0
        strOut := 'Итого по службе:'
        if lExcel
          worksheet_write_string( worksheet, rowWS, 1, ;
            hb_StrToUTF8( strOut ) ) //, header )
          worksheet_write_number( worksheet, rowWS, 2, ;
            ssl[ 1 ] ) //, header )
        else
          add_string( Replicate( '─', sh ) )
          s := PadL( strOut, n1 ) + Str( ssl[ 1 ], 7, 0 )
        endif
        If flag_uet
          if lExcel
            worksheet_write_number( worksheet, rowWS, 3, ;
              ssl[ 2 ] ) //, header )
          else
            s += ' ' + umest_val( ssl[ 2 ], 8, 2 )
          endif
        Endif
        if lExcel
          worksheet_write_number( worksheet, rowWS++, 4, ;
            ssl[ 3 ] ) //, header )
        else
          s += put_kope( ssl[ 3 ], 14 )
          add_string( s )
        endif
      Endif
    Endif
  Elseif su == 4
    If !flag_uet
      fl_plan := .f.
    Endif
    n1 := 80 -18
    If flag_uet
      n1 -= 9
    Endif
    If fl_plan
      n1 -= 10
    Endif
    if lExcel
      rowWS := 0
      columnWS := 0
      worksheet_write_string( worksheet, rowWS, columnWS++, ;
        hb_StrToUTF8( 'Врач' + iif( su1 == 1, '', ' (плюс услуги)' ) ) ) //, header )
      if fl_plan
        worksheet_write_string( worksheet, rowWS, columnWS++, ;
          hb_StrToUTF8( 'План УЕТ' ) ) //, header )
      endif
      worksheet_write_string( worksheet, rowWS, columnWS++, ;
        hb_StrToUTF8( 'Кол-во услуг' ) ) //, header )
      if flag_uet
        worksheet_write_string( worksheet, rowWS, columnWS++, ;
          hb_StrToUTF8( 'У.Е.Т.' ) ) //, header )
      endif
      worksheet_write_string( worksheet, rowWS, columnWS++, ;
        hb_StrToUTF8( 'Стоимость услуг' ) ) //, header )
      if fl_plan
        worksheet_write_string( worksheet, rowWS++, columnWS, ;
          hb_StrToUTF8( '%% план' ) ) //, header )
      endif
      columnWS := 0
    else
      arr_title := { ;
        Replicate( '─', n1 ), ;
        Space( n1 ), ;
        PadC( 'Врач' + iif( su1 == 1, '', ' (плюс услуги)' ), n1 ), ;
        Replicate( '─', n1 ) }
      If fl_plan
        arr_title[ 1 ] += '┬────'
        arr_title[ 2 ] += '│План'
        arr_title[ 3 ] += '│ УЕТ'
        arr_title[ 4 ] += '┴────'
      Endif
      arr_title[ 1 ] += '┬──────'
      arr_title[ 2 ] += '│Кол-во'
      arr_title[ 3 ] += '│ услуг'
      arr_title[ 4 ] += '┴──────'
      If flag_uet
        arr_title[ 1 ] += '┬────────'
        arr_title[ 2 ] += '│        '
        arr_title[ 3 ] += '│ У.Е.Т. '
        arr_title[ 4 ] += '┴────────'
      Endif
      arr_title[ 1 ] += '┬──────────'
      arr_title[ 2 ] += '│Стоимость '
      arr_title[ 3 ] += '│  услуг   '
      arr_title[ 4 ] += '┴──────────'
      If fl_plan
        arr_title[ 1 ] += '┬────'
        arr_title[ 2 ] += '│ %% '
        arr_title[ 3 ] += '│план'
        arr_title[ 4 ] += '┴────'
      Endif
      AEval( arr_title, {| x| add_string( x ) } )
    endif
    Select HU
    Set Relation To
    If fl_plan
      r_use( dir_server + 'uch_pers', dir_server + 'uch_pers', 'UCHP' )
    Endif
    Select TMP1
    Set Relation To kod1 into USL
    Index On Str( kod, 4 ) + fsort_usl( usl->shifr ) to ( cur_dir + 'tmp1' )
    g_use( dir_server + 'mo_pers', , 'PERSO' )
    Select TMP
    Set Relation To kod into PERSO
    Index On Upper( perso->fio ) to ( cur_dir + 'tmp' )
    Go Top
    Do While !Eof()
      if lExcel
        columnWS := 0
      else
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
      endif
      if lExcel
        worksheet_write_string( worksheet, rowWS, columnWS++, ;
          hb_StrToUTF8( iif( Empty( perso->fio ), '__Не введен врач__', AllTrim( perso->fio ) ) + ' [' + lstr( perso->tab_nom ) + ']' ) ) //, header )
      else
        s := iif( Empty( perso->fio ), '__Не введен врач__', AllTrim( perso->fio ) ) + ' [' + lstr( perso->tab_nom ) + ']'
        k := perenos( as, s, n1 )
        s := PadR( as[ 1 ], n1 )
      endif
      If fl_plan
        ltrud := ret_trudoem( tmp->kod, tmp->uet, ym_kol_mes, arr_m, @lplan )
        if lExcel
          worksheet_write_number( worksheet, rowWS, columnWS++, ;
            lplan ) //, header )
        else
          s += put_val( lplan, 5, 0 )
        endif
      Endif
      if lExcel
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmp->kol ) //, header )
      else
        s += Str( tmp->kol, 7, 0 )
      endif
      If flag_uet
        if lExcel
          worksheet_write_number( worksheet, rowWS, columnWS++, ;
            tmp->uet ) //, header )
        else
          s += ' ' + umest_val( tmp->uet, 8, 2 )
        endif
      Endif
      if lExcel
        worksheet_write_number( worksheet, rowWS, columnWS++, ;
          tmp->sum ) //, header )
      else
        s += put_kope( tmp->sum, 11 )
      endif
      If fl_plan
        if lExcel
          worksheet_write_number( worksheet, rowWS, columnWS++, ;
            ltrud ) //, header )
        else
          s += ' ' + umest_val( ltrud, 4, 1 )
        endif
      Endif
      if lExcel
        rowWS++
      else
        add_string( s )
        For j := 2 To k
          add_string( PadL( AllTrim( as[ j ] ), n1 ) )
        Next
      endif
      If su1 == 2
        columnWS := 0
        Select TMP1
        find ( Str( tmp->kod, 4 ) )
        Do While tmp->kod == tmp1->kod .and. !Eof()
          if ! lExcel
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
          endif
          lname := usl->name
          Select LUSL
          find ( PadR( usl->shifr, 10 ) )
          If Found()
            lname := lusl->name  // наименование услуги из справочника ТФОМС
          Endif
          if lExcel
            worksheet_write_string( worksheet, rowWS, columnWS++, ;
              hb_StrToUTF8( AllTrim( usl->shifr ) ) ) //, header )
            worksheet_write_string( worksheet, rowWS, columnWS++, ;
              hb_StrToUTF8( AllTrim( lname ) ) ) //, header )
          else
            k := perenos( as, AllTrim( usl->shifr ) + ' ' + AllTrim( lname ), n1 - 2 )
            s := '  ' + PadR( as[ 1 ], n1 - 2 )
          endif
          If fl_plan
            if lExcel
              worksheet_write_string( worksheet, rowWS, columnWS++, ;
                hb_StrToUTF8( '' ) ) //, header )
            else
              s += Space( 5 )
            endif
          Endif
          if lExcel
            worksheet_write_number( worksheet, rowWS, columnWS++, ;
              tmp1->kol ) //, header )
          else
            s += Str( tmp1->kol, 7, 0 )
          endif
          If flag_uet
            if lExcel
              worksheet_write_number( worksheet, rowWS, columnWS++, ;
                tmp1->uet ) //, header )
              else
              s += ' ' + umest_val( tmp1->uet, 8, 2 )
            endif
          Endif
          if lExcel
            worksheet_write_number( worksheet, rowWS++, columnWS, ;
              tmp1->sum ) //, header )
          else
            s += put_kope( tmp1->sum, 11 )
            add_string( s )
          endif
          columnWS := 0
          Select TMP_XLS
          Append Blank
          tmp_xls->shifr  := usl->shifr
          tmp_xls->u_name := AllTrim( lname )
          tmp_xls->kol    := tmp1->kol
          tmp_xls->sum    := tmp1->sum
          if ! lExcel
            For j := 2 To k
              add_string( PadL( AllTrim( as[ j ] ), n1 ) )
            Next
          endif
          Select TMP1
          Skip
        Enddo
      Endif
      Select TMP
      Skip
    Enddo
  Endif
  Close databases
  RestScreen( buf )
  If lExcel
    workbook_close( workbook )
    saveto( name_fileXLS_full )
  else
    FClose( fp )
    viewtext( name_file, , , , ( sh > 80 ), , , reg_print )
  Endif

  If glob_mo[ _MO_KOD_TFOMS ] == '805965' // РДЛ
    create_xls_rdl( 'rdl_report', arr_m, st_a_uch, lcount_uch, st_a_otd, lcount_otd )
    saveto( cur_dir + 'rdl_report.xlsx' )
  Endif

  Return Nil

// 26.12.23
Function f1pz1statist( arr_otd, par )

  Local lreg_lech := { 0, 0, 0, 0, 0 }, s, lkod, lshifr, ta, i, j, k, mkol1, ;
    mkol, muet, msum, koef := 1, lshifr1, fl := .t., arr_dn_st := { '', '', 0 }, ;
    d2_year := Year( human->k_data ), ar, i14 := 0, i16 := 0, au_su1 := {}, sdializ := ''

  If par == 2
    If Int( Val( cut_code_smo( human_->smo ) ) ) == 34
      fl := ( AScan( arr_goi, 2 ) > 0 )
    Else
      fl := ( AScan( arr_goi, 1 ) > 0 )
    Endif
  Endif
  If !fl
    Return Nil
  Endif
  If glob_schet_akt == 2 .and. human_->oplata == 3
    koef := human_->sump / human->cena_1
  Endif
  sstoim += human->cena_1 * koef
  ar := Array( Len( luapz2016 ) ) ; AFill( ar, 0 )
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    If AScan( arr_otd, hu->otd ) > 0
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      ta := f14tf_nastr( lshifr, , d2_year )
      For j := 1 To Len( ta )
        If ( k := ta[ j, 3 ] ) > 0
          ar[ k ] ++
        Endif
      Next
    Endif
    Select HU
    Skip
  Enddo
  For j := 1 To Len( ar )
    If ar[ j ] > 0
      If Empty( luapz2016[ j, 3 ] )
        luapz2016[ j, 2 ] := 0
      Endif
      luapz2016[ j, 3 ] ++
      luapz2016[ j, 2 ] += human->cena_1 * koef
      If human->ishod == 89 // это 2-ой л/у в двойном случае
        kol_sl_2[ j ] ++
      Endif
    Endif
  Next
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    If AScan( arr_otd, hu->otd ) > 0
      lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
      muet := hu->kol_1 * ret_tfoms_uet( usl->shifr, lshifr1, human->vzros_reb )
      tfoms_pz[ 4 ] += muet
      If eq_any( su, 3, 4 )
        suet += muet
        lkod := iif( su == 3, hu->u_kod, hu->kod_vr )
        Select TMP
        find ( Str( lkod, 4 ) )
        If !Found()
          Append Blank
          tmp->kod := lkod
          If RecNo() % 5000 == 0
            dbCommit()
          Endif
        Endif
        tmp->kol += hu->kol_1
        tmp->uet += muet
        tmp->sum += hu->stoim_1 * koef
        If su == 4
          Select TMP1
          find ( Str( hu->kod_vr, 4 ) + Str( hu->u_kod, 4 ) )
          If !Found()
            Append Blank
            tmp1->kod := hu->kod_vr
            tmp1->kod1 := hu->u_kod
            tmp1->shifr := usl->shifr
            If RecNo() % 5000 == 0
              dbCommit()
            Endif
          Endif
          tmp1->kol += hu->kol_1
          tmp1->uet += muet
          tmp1->sum += hu->stoim_1 * koef
        Endif
        If Empty( lshifr := lshifr1 )
          lshifr := usl->shifr
        Endif
        ta := f14tf_nastr( lshifr, , d2_year )
        For j := 1 To Len( ta )
          k := ta[ j, 1 ]
          If Between( k, 1, 10 )
            If k == 2
              tfoms_pz[ 1 ] += hu->kol_1
            Elseif k == 1 // врачебные приёмы
              If ta[ j, 2 ] >= 0
                tfoms_pz[ 3 ] += hu->kol_1
              Endif
            Elseif k == 7
              tfoms_pz[ 5 ] += hu->kol_1
            Elseif k == 8
              tfoms_pz[ 6 ] += hu->kol_1
            Elseif eq_any( k, 3, 4, 5 )
              tfoms_pz[ 2 ] += hu->kol_1
            Endif
            If ta[ j, 2 ] >= 0
              as[ k, 1 ] += hu->kol_1
              as[ k, 2 ] += muet
            Endif
            as[ k, 3 ] += hu->stoim_1
          Endif
        Next
      Else
        If Empty( lshifr := lshifr1 )
          lshifr := usl->shifr
        Endif
        lname := AllTrim( usl->name )
        s := lshifr
        ta := f14tf_nastr( @lshifr, @lname, d2_year )
        lshifr := PadR( lshifr, 10 )
        fl := .t.
        For j := 1 To Len( ta )
          i16 := ta[ j, 3 ]
          k := ta[ j, 1 ] ; mkol1 := 0
          If Between( k, 1, 10 )
            If ta[ j, 2 ] == 1  // законченный случай
              mkol := human->k_data - human->n_data  // койко-день
              If Between( ta[ j, 1 ], 3, 5 ) // дневной стационар до 1 апреля
                ++mkol
              Endif
              If ( i := AScan( arr_lp, {| x| x[ 1 ] == lshifr } ) ) == 0
                AAdd( arr_lp, { lshifr, {} } ) ; i := Len( arr_lp )
              Endif
              If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == s } ) ) == 0
                AAdd( arr_lp[ i, 2 ], { s, 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
              Endif
              arr_lp[ i, 2, i1, 2 ] += mkol
              arr_lp[ i, 2, i1, 3 ] ++
            Elseif ta[ j, 2 ] == 0
              mkol := hu->kol_1
              If Between( ta[ j, 1 ], 3, 5 ) .or. ( ta[ j, 1 ] == 2 .and. d2_year > 2013 )
                arr_dn_st[ 2 ] := lshifr
                arr_dn_st[ 3 ] += mkol
              Endif
            Else
              mkol := 0
              mkol1 := hu->kol_1
              If Between( ta[ j, 1 ], 3, 5 ) .or. ( ta[ j, 1 ] == 2 .and. d2_year > 2013 )
                arr_dn_st[ 1 ] := lshifr
              Endif
            Endif
            If mkol > 0
              If hu->kol_rcp < 0 .and. domuslugatfoms( lshifr )
                s := iif( hu->kol_rcp == -1, 'на дому', 'на дому(АКТИВ)' )
                If ( i := AScan( arr_lp, {| x| x[ 1 ] == lshifr } ) ) == 0
                  AAdd( arr_lp, { lshifr, {} } ) ; i := Len( arr_lp )
                Endif
                If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == s } ) ) == 0
                  AAdd( arr_lp[ i, 2 ], { s, 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
                Endif
                arr_lp[ i, 2, i1, 2 ] += mkol
                // arr_lp[i, 2,i1, 3] ++
              Endif
              If eq_any( Left( lshifr, 4 ), '2.3.', '2.6.', '2.60', '1.11', '55.1' )
                s := inieditspr( A__MENUVERT, getv002(), hu_->PROFIL )
                If ( i := AScan( arr_lp, {| x| x[ 1 ] == lshifr } ) ) == 0
                  AAdd( arr_lp, { lshifr, {} } ) ; i := Len( arr_lp )
                Endif
                If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == s } ) ) == 0
                  AAdd( arr_lp[ i, 2 ], { s, 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
                Endif
                arr_lp[ i, 2, i1, 2 ] += mkol
                // arr_lp[i, 2,i1, 3] ++
              Endif
            Endif
            If k == 2
              tfoms_pz[ 1 ] += mkol
            Elseif k == 1
              tfoms_pz[ 3 ] += mkol
            Elseif k == 7
              tfoms_pz[ 5 ] += mkol
            Elseif k == 8
              tfoms_pz[ 6 ] += mkol
            Elseif eq_any( k, 3, 4, 5 )
              tfoms_pz[ 2 ] += mkol
            Endif
            msum := hu->stoim_1 * koef
            If eq_any( k, 9, 10 )  // УЕТ для стоматологий
              suet += muet
              // if apz2016[i16, 2] == 62 // УЕТ стоматологии
              // apz2016[i16, 3] += muet
              // endif
            Elseif i16 > 0
              lalunit := 'MOUNIT'   // 29.12.2022
              dbSelectArea( lalunit )
              Set Order To 2  // 2 23.12.21 == 1
              // find (str(i16, 3))
              // if &lalunit.->c_t == 2 // план-заказ подсчитывается по случаю
              t_vrem := &lalunit.->code
              If eq_any( t_vrem, 511, 317, 261, 262, 318, 319, 320, 321 )
                // apz2016[i16, 3] ++
                apz2016[ i16, 3 ] := 0
              Else
                apz2016[ i16, 3 ] += mkol
              Endif
              Set Order To 1
              /*if eq_any(apz2016[i16, 2], 57, 60, 61)
                if (i := ascan(apf, {|x| x[1]==lshifr })) == 0
                  aadd(apf, {lshifr, 0}) ; i := len(apf)
                endif
                apf[i, 2] += iif(empty(mkol), mkol1, mkol)
              endif*/
            Endif
            Select TMP
            find ( PadR( lshifr, 10 ) )
            If !Found()
              Append Blank
              tmp->shifr := lshifr
              tmp->u_name := lname
            Endif
            If fl
              tmp->kol += mkol
              tmp->kol1 += mkol1
              tmp->uet += muet
              tmp->sum += msum
              If su == 1 .and. ( ( Between( k, 1, 8 ) .and. !Empty( mkol ) ) .or. !Empty( muet ) )
                AAdd( au_su1, { hu->otd, human->kod_k, human->kod, k, mkol, muet } )
              Endif
            Endif
            as[ k, 1 ] += mkol
            as[ k, 2 ] += muet
            as[ k, 3 ] += msum
            fl := .f.
          Endif
        Next
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If !Empty( sdializ )
    If ( i := AScan( arr_lp, {| x| x[ 1 ] == sdializ } ) ) == 0
      AAdd( arr_lp, { sdializ, {} } ) ; i := Len( arr_lp )
    Endif
    Select MOHU
    find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. !Eof()
      lshifr := AllTrim( mosu->shifr1 )
      If mohu->kol_1 > 0 .and. AScan( glob_MU_dializ, lshifr ) > 0
        If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == lshifr } ) ) == 0
          AAdd( arr_lp[ i, 2 ], { lshifr, 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
        Endif
        arr_lp[ i, 2, i1, 2 ] += mohu->kol_1
      Endif
      Select MOHU
      Skip
    Enddo
  Elseif !emptyany( arr_dn_st[ 1 ], arr_dn_st[ 2 ], arr_dn_st[ 3 ] ) // дневной стационар с 1 апреля 2013 года или КСГ с 2014 года
    If ( i := AScan( arr_lp, {| x| x[ 1 ] == arr_dn_st[ 1 ] } ) ) == 0
      AAdd( arr_lp, { arr_dn_st[ 1 ], {} } ) ; i := Len( arr_lp )
    Endif
    If ( i1 := AScan( arr_lp[ i, 2 ], {| x| x[ 1 ] == arr_dn_st[ 2 ] } ) ) == 0
      AAdd( arr_lp[ i, 2 ], { arr_dn_st[ 2 ], 0, 0 } ) ; i1 := Len( arr_lp[ i, 2 ] )
    Endif
    arr_lp[ i, 2, i1, 2 ] += arr_dn_st[ 3 ]
    arr_lp[ i, 2, i1, 3 ] ++
  Endif
  If su == 1
    For i := 1 To Len( au_su1 )
      // aadd(au_su1,{hu->otd,human->kod_k,human->kod,k,mkol,muet})
      Select TMPO
      find ( Str( au_su1[ i, 1 ], 3 ) )
      If !Found()
        Append Blank
        tmpo->otd := au_su1[ i, 1 ]
      Endif
      If au_su1[ i, 4 ] == 2
        tmpo->kol1 += au_su1[ i, 5 ]
      Elseif au_su1[ i, 4 ] == 1
        tmpo->kol3 += au_su1[ i, 5 ]
      Elseif au_su1[ i, 4 ] == 6
        tmpo->kol4 += au_su1[ i, 5 ]
      Elseif au_su1[ i, 4 ] == 7
        tmpo->kol6 += au_su1[ i, 5 ]
      Elseif au_su1[ i, 4 ] == 8
        tmpo->kol7 += au_su1[ i, 5 ]
      Elseif eq_any( au_su1[ i, 4 ], 3, 4, 5 )
        tmpo->kol2 += au_su1[ i, 5 ]
      Endif
      tmpo->kol5 += au_su1[ i, 6 ]
      If i == Len( au_su1 )
        Select TMPOK
        find ( Str( au_su1[ i, 1 ], 3 ) + Str( au_su1[ i, 2 ], 7 ) )
        If !Found()
          Append Blank
          tmpok->otd := au_su1[ i, 1 ]
          tmpok->kod_k := au_su1[ i, 2 ]
        Endif
        Select TMPOS
        find ( Str( au_su1[ i, 1 ], 3 ) + Str( au_su1[ i, 3 ], 7 ) )
        If !Found()
          Append Blank
          tmpos->otd := au_su1[ i, 1 ]
          tmpos->kod := au_su1[ i, 3 ]
        Endif
      Endif
    Next i
  Endif

  Return Nil

// 19.02.13
Function pz2statist( arr_m, par2 )

  Local begin_date, end_date, buf := save_maxrow(), fl := .f., mstr_crb, mismo

  begin_date := arr_m[ 7 ]
  end_date := arr_m[ 8 ]
  //
  mywait()
  //
  adbf := { { 'KOMU',   'N',     1,     0 }, ; // от 0 до 5
    { 'STR_CRB',   'N',     2,     0 }, ; // код стр.компании, комитета и т.п.
    { 'NKOMU',   'C',    35,     0 }, ;
    { 'IFIN',   'N',     1,     0 }, ;
    { 'SMO',   'C',     5,     0 }, ; // код СМО
    { 'KOL_BOLN',   'N',     6,     0 }, ;
    { 'SUMMA',   'N',    13,     2 }, ;
    { 'is',   'N',     1,     0 } }
  dbCreate( cur_dir + 'tmp_smo', adbf )
  Use ( cur_dir + 'tmp_smo' ) New Alias TMP
  Index On Str( komu, 1 ) + Str( str_crb, 2 ) + smo to ( cur_dir + 'tmp_smo1' )
  Index On nkomu to ( cur_dir + 'tmp_smo2' )
  Set Index to ( cur_dir + 'tmp_smo1' ), ( cur_dir + 'tmp_smo2' )
  If par2 == 2
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
  Endif
  r_use( dir_server + 'schet_', , 'SCHET_' )
  r_use( dir_server + 'schet', dir_server + 'schetd', 'SCHET' )
  Set Relation To RecNo() into SCHET_
  Set Filter To Empty( schet_->IS_DOPLATA )
  Go Top
  Do While !Eof()
    If par2 == 1
      If emptyany( schet_->nyear, schet_->nmonth )
        fl := Between( schet->pdate, arr_m[ 7 ], arr_m[ 8 ] )
      Else
        mdate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '15' )
        fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] )
      Endif
      If fl .and. mdate_reg != NIL
        fl := ( schet_->NREGISTR == 0 .and. date_reg_schet() <= mdate_reg )
      Endif
    Else
      If emptyany( schet_->nyear, schet_->nmonth )
        fl := .f.
      Else
        mdate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '01' )
        Do While .t.
          If ( fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] ) )
            Exit
          Endif
          ++mdate
          If mdate == EoM( mdate )
            Exit
          Endif
        Enddo
      Endif
    Endif
    If fl
      If schet->komu == 2 .or. Int( Val( schet_->smo ) ) == 34
        fl := ( AScan( arr_goi, 2 ) > 0 )
      Else
        fl := ( AScan( arr_goi, 1 ) > 0 )
      Endif
    Endif
    If fl .and. schet->komu != 5
      If schet_->ifin > 0
        mkomu := 0
        mstr_crb := 0
        msmo := schet_->smo
      Else
        mkomu := iif( schet->komu == 1, 1, 3 )
        mstr_crb := schet->str_crb
        msmo := Space( 5 )
      Endif
      If par2 == 1
        Select TMP
        find ( Str( mkomu, 1 ) + Str( mstr_crb, 2 ) + msmo )
        If !Found()
          Append Blank
          Replace tmp->komu With mkomu, ;
            tmp->str_crb With mstr_crb, tmp->smo With msmo, ;
            tmp->is With 1
        Endif
        tmp->kol_boln += schet->kol
        tmp->summa += schet->summa
      Else
        Select HUMAN
        find ( Str( schet->kod, 6 ) )
        Do While human->schet == schet->kod .and. !Eof()
          If Between( human->k_data, arr_m[ 5 ], arr_m[ 6 ] ) ;
              .and. iif( v_deti == 1, .t., human->VZROS_REB > 0 )
            Select TMP
            find ( Str( mkomu, 1 ) + Str( mstr_crb, 2 ) + msmo )
            If !Found()
              Append Blank
              Replace tmp->komu With mkomu, ;
                tmp->str_crb With mstr_crb, tmp->smo With msmo, ;
                tmp->is With 1
            Endif
            tmp->kol_boln++
            tmp->summa += human->cena_1
          Endif
          Select HUMAN
          Skip
        Enddo
      Endif
    Endif
    Select SCHET
    Skip
  Enddo
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, 'Нет счетов за указанный период времени!' )
  Else
    schet->( dbCloseArea() )
    Select TMP
    dbEval( {|| tmp->nkomu := f4_view_list_schet( tmp->komu, tmp->smo, tmp->str_crb ) } )
    Set Order To 2
    Go Top
    If alpha_browse( T_ROW, 0, MaxRow() -1, 79, 'pz21statist', color0, ;
        'Счета ' + arr_m[ 4 ], 'R/BG', , , , , ;
        'pz22statist', , { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', , 0 } )
      fl := .t.
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return fl

//
Function pz21statist( oBrow )

  Local oColumn, blk := {|| iif ( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }

  oColumn := TBColumnNew( ' ', {|| if( tmp->is == 1, '', ' ' ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( Center( 'Принадлежность счета', 35 ), {|| Left( tmp->nkomu, 35 ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( ' Кол.; бол.', {|| Str( tmp->kol_boln, 6 ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( ' Сумма счета', {|| put_kop( tmp->summa, 13 ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  oColumn := TBColumnNew( ' ', {|| if( tmp->is == 1, '', ' ' ) } )
  oBrow:addcolumn( oColumn )
  oColumn:colorBlock := blk
  status_key( '^<Esc>^ - выход;  ^<Enter>^ - подсчет;  ^<Ins><+><->^ - отметить СМО для подсчета' )

  Return Nil

//
Function pz22statist( nKey, oBrow )

  Local ret := 0

  Do Case
  Case nKey == 45  // минус
    rec := tmp->( RecNo() )
    tmp->( dbEval( {|| tmp->is := 0 } ) )
    tmp->( dbGoto( rec ) )
    ret := 0
  Case nKey == 43  // плюс
    rec := tmp->( RecNo() )
    tmp->( dbEval( {|| tmp->is := 1 } ) )
    tmp->( dbGoto( rec ) )
    ret := 0
  Case nKey == K_INS
    tmp->is := iif( tmp->is == 1, 0, 1 )
    oBrow:down()
    ret := 0
  Endcase

  Return ret

// 27.09.13 Расчёт потребности в финансовом обеспечении выполнения объёмов мед.помощи
Function pz_raschet_potr()

  Local buf := SaveScreen(), fl_exit := .f., i, j, k, lreg_lech[ 9 ], ;
    name_file := cur_dir + 'pz_r_p' + stxt, arr_m, ta[ 2 ], arr_title, lshifr, ;
    d2_year, sh := 80, HH := 80, reg_print := 5, au

  If ( arr_m := input_year() ) == NIL
    Return Nil
  Endif
  Private s_stac, sdstac, s_amb, skt, ssmp, suet, sstoim
  s_stac := sdstac := s_amb := skt := ssmp := suet := sstoim := 0
  waitstatus( '<Esc> - прервать поиск' ) ; mark_keys( { '<Esc>' } )
  dbCreate( cur_dir + 'tmp', { ;
    { 'shifr', 'C', 10, 0 }, ;
    { 'tip1', 'N', 1, 0 }, ;
    { 'tip2', 'N', 1, 0 }, ;
    { 'vr', 'N', 1, 0 }, ; // 0-взрослый, 1-ребенок
    { 'tarif', 'N', 10, 2 }, ;
    { 'mm', 'N', 2, 0 }, ;
    { 'kol1', 'N', 11, 2 }, ;
    { 'kol2', 'N', 11, 2 }, ;
    { 'kol3', 'N', 11, 2 }, ;
    { 'kol4', 'N', 11, 2 };
    } )
  Use ( cur_dir + 'tmp' ) new
  Index On shifr + Str( vr, 1 ) + Str( tarif, 10, 2 ) to ( cur_dir + 'tmp' )
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u_', , 'HU_' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To u_kod into USL, To RecNo() into HU_
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + 'schet_', , 'SCHET_' )
  r_use( dir_server + 'schet', , 'SCHET' )
  Set Relation To RecNo() into SCHET_
  Index On pdate + nomer_s to ( cur_dir + 'tmp_sch' ) ;
    For emptyall( schet_->NREGISTR, schet_->IS_DOPLATA ) .and. ;
    Int( Val( schet_->smo ) ) > 34000 .and. schet_->nyear == arr_m[ 1 ] .and. ;
    Between( date_reg_schet(), arr_m[ 5 ], arr_m[ 6 ] )
  Go Top
  Do While !Eof()
    @ MaxRow(), 0 Say PadR( AllTrim( schet_->NSCHET ) + ' ' + ;
      date_8( schet_->DSCHET ), 24 ) Color 'W/R'
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select HUMAN
    find ( Str( schet->kod, 6 ) )
    Do While human->schet == schet->kod .and. !Eof()
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      If human_->oplata != 9
        d2_year := Year( human->k_data )
        lvr := iif( human->vzros_reb == 0, 1, 2 )
        sstoim += human->cena_1
        AFill( lreg_lech, 0 )
        is_z_sl := .f.
        au := {}
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          muet := hu->kol_1 * ret_tfoms_uet( usl->shifr, lshifr, human->vzros_reb )
          If Empty( lshifr )
            lshifr := usl->shifr
          Endif
          ta := f14tf_nastr( lshifr, , d2_year )
          For j := 1 To Len( ta )
            k := ta[ j, 1 ]
            If Between( k, 1, 8 )
              i := 2                // остальные - амбулаторно
              If k == 2             // k := 2 - койко-дни
                i := 1
              Elseif Between( k, 3, 5 ) // k := 3, 4, 5 - дневной стационар
                i := 3
              Elseif k == 7 // о/м/у
                i := 4
              Elseif k == 8 // СМП
                i := 5
              Endif
              ++lreg_lech[i ]
              If k != 6 // не стомат.посещение
                AAdd( au, { i, iif( ta[ j, 2 ] == 0, 1, 2 ), lshifr, hu->kol_1, hu->u_cena, hu_->profil } )
                If ta[ j, 2 ] != 0
                  is_z_sl := .t.
                Endif
              Endif
            Endif
            If eq_any( k, 9, 10 )  // УЕТ для стоматологий
              suet += muet
              AAdd( au, { 6, 1, iif( k == 9, 'УЕТ леч.', 'УЕТ орт.' ), muet, 0, 0 } )
            Endif
          Next
          Select HU
          Skip
        Enddo
        If lreg_lech[ 1 ] > 0
          ++s_stac
        Elseif lreg_lech[ 3 ] > 0
          ++sdstac
        Elseif lreg_lech[ 4 ] > 0
          ++skt
        Elseif lreg_lech[ 5 ] > 0
          ++ssmp
        Else
          ++s_amb
        Endif
        If eq_any( human->ishod, 101, 102, 201, 202, 203, 204, 205, 301, 302, 303, 304, 305 )
          is_disp := .t.
          is_z_sl := .f.
        Else
          is_disp := .f.
        Endif
        k := Month( human->k_data )
        For i := 1 To Len( au )
          If is_z_sl
            If au[ i, 2 ] == 1 // оставим только законченный случай
              Loop          // пропустим все остальные услуги
            Endif
          Elseif is_disp
            If au[ i, 2 ] == 2 // оставим только приёмы
              Loop          // пропустим шифр законченного случая
            Endif
            au[ i, 3 ] := Str( au[ i, 6 ], 10 )
            au[ i, 5 ] := au[ i, 6 ]
          Endif
          Select TMP
          find ( PadR( au[ i, 3 ], 10 ) + Str( lvr, 1 ) + Str( au[ i, 5 ], 10, 2 ) )
          If !Found()
            Append Blank
            tmp->shifr := au[ i, 3 ]
            tmp->tip1 := iif( is_disp, 7, au[ i, 1 ] )
            tmp->tip2 := au[ i, 2 ]
            tmp->vr := lvr
            tmp->tarif := au[ i, 5 ]
          Endif
          If tmp->mm == 0 .or. k < tmp->mm
            tmp->mm := k
          Endif
          If Between( k, 1, 3 )
            tmp->kol1 += au[ i, 4 ]
          Elseif Between( k, 4, 6 )
            tmp->kol2 += au[ i, 4 ]
          Elseif Between( k, 7, 9 )
            tmp->kol3 += au[ i, 4 ]
          Else
            tmp->kol4 += au[ i, 4 ]
          Endif
        Next
      Endif
      Select HUMAN
      Skip
    Enddo
    If fl_exit ; exit ; Endif
    Select SCHET
    Skip
  Enddo
  If fl_exit
    Close databases
    Return Nil
  Endif
  arr_title := { ;
    '───────────────────────────────┬───┬────────┬────────┬────────┬────────┬────────', ;
    ' Услуга                        │Вид│ Тариф  │ I кв.  │ II кв. │ III кв.│ IV кв. ', ;
    '───────────────────────────────┴───┴────────┴────────┴────────┴────────┴────────' }
  // 32                                   8.2     9
  fp := FCreate( name_file )
  tek_stroke := 0
  n_list := 1
  add_string( PadL( 'дата печати ' + date_8( sys_date ), sh ) )
  add_string( '' )
  add_string( Center( 'Расчёт потребности в финансовом обеспечении выполнения объёмов мед.помощи', sh ) )
  add_string( Center( 'по зарегистрированным счетам ' + arr_m[ 4 ], sh ) )
  add_string( Center( '[ отчётный период ' + lstr( arr_m[ 1 ] ) + ' год]', sh ) )
  add_string( Center( '[ без учёта иногородних ]', sh ) )
  add_string( Center( '[ без учёта повторно выставленных случаев ]', sh ) )
  add_string( '' )
  add_string( 'Всего листов учета: ' + lstr( s_stac + sdstac + s_amb + skt + ssmp ) )
  add_string( '   в том числе:' )
  If s_stac > 0
    add_string( PadL( 'стационар:', 31 ) + ' ' + lstr( s_stac ) )
  Endif
  If sdstac > 0
    add_string( PadL( 'дневной стационар:', 31 ) + ' ' + lstr( sdstac ) )
  Endif
  If s_amb > 0
    add_string( PadL( 'поликлиника:', 31 ) + ' ' + lstr( s_amb ) )
  Endif
  If skt > 0
    add_string( PadL( 'отдельные медицинские услуги:', 31 ) + ' ' + lstr( skt ) )
  Endif
  If ssmp > 0
    add_string( PadL( 'скорая медицинская помощь:', 31 ) + ' ' + lstr( ssmp ) )
  Endif
  add_string( '' )
  add_string( 'Общая сумма лечения :  ' + lstr( sstoim, 13, 2 ) )
  If suet > 0
    add_string( 'Общее количество УЕТ:  ' + AllTrim( str_0( suet, 13, 2 ) ) )
  Endif
  AEval( arr_title, {| x| add_string( x ) } )
  If Select( 'LUSL' ) == 0
    use_base( 'lusl' )
  Endif
  Select TMP
  Index On Str( tip1, 1 ) + Str( tip2, 1 ) + fsort_usl( shifr ) + Str( mm, 2 ) + Str( vr, 1 ) to ( cur_dir + 'tmp' )
  For i := 1 To 7
    For j := 1 To 2
      find ( Str( i, 1 ) + Str( j, 1 ) )
      If !Found() ; loop ; Endif
      If verify_ff( HH - 3, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      s := { 'Стационар', 'Поликлиника', 'Дневной стационар', 'Отдельые медуслуги', ;
        'СМП', 'Стоматология', 'Диспансеризация/Профилактика/Медосмотры' }[ i ]
      If i == 1
        s += ' [' + { 'койко-дни', 'законченные случаи' }[ j ] + ']'
      Elseif i == 2
        s += ' [' + { 'посещения', 'обращения' }[ j ] + ']'
      Elseif i == 3
        s += ' [' + { 'пациенто-дни', 'законченные случаи' }[ j ] + ']'
      Endif
      add_string( '' )
      add_string( s )
      add_string( Replicate( '─', sh ) )
      Do While tmp->tip1 == i .and. tmp->tip2 == j .and. !Eof()
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        If tmp->tip1 == 7
          s := inieditspr( A__MENUVERT, getv002(), Int( tmp->tarif ) )
          s := PadR( s, 31 ) + ' ' + { 'вз.', 'реб' }[ tmp->vr ] + Space( 9 )
        Else
          s := AllTrim( tmp->shifr ) + ' '
          Select LUSL
          find ( PadR( tmp->shifr, 10 ) )
          If Found()
            s += lusl->name
          Endif
          s := PadR( s, 31 ) + ' ' + { 'вз.', 'реб' }[ tmp->vr ] + put_kope( tmp->tarif, 9 )
        Endif
        s += umest_val( tmp->kol1, 9, 2 ) + umest_val( tmp->kol2, 9, 2 ) + ;
          umest_val( tmp->kol3, 9, 2 ) + umest_val( tmp->kol4, 9, 2 )
        add_string( s )
        Select TMP
        Skip
      Enddo
    Next
  Next
  FClose( fp )
  Close databases
  RestScreen( buf )
  viewtext( name_file, , , , ( sh > 80 ), , , reg_print )

  Return Nil
