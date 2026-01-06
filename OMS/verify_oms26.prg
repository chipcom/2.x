#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

#define MAX_REC_REESTR 9999
#define MAX_REC_REESTR_RDL 5000
#define BASE_ISHOD_RZD 500

// 03.12.25
Function verify_oms26( arr_m, fl_view, kod_smo )

  // Возврат: arrKolSl (массив)
  // 1 эл. - кол-во обычных случаев, 
  // 2 эл. - кол-во случаев диспансеризации

  Local ii := 0, iprov := 0, inprov := 0, ko := 2, fl, kr_unlock, i, mas_pmt
  local  arrKolSl := { 0, 0 }, adbf
  Local tmpSelect
  Local ln_data, lk_data, ldiag, lcena, pz
  local name_file, name_file2, name_file3, mas_file, ft
  Local old_komu, old_str_crb, old_tip, am
  local check_pacient, current_mo
  local fr_data, fr_titl

  mas_file := {}
  mas_pmt := { 'Список обнаруженных ошибок в результате проверки' }
  name_file := cur_dir() + 'err_sl.txt'
  name_file2 := cur_dir() + 'err_sl2.txt'
  name_file3 := cur_dir() + 'err_sl3.txt'

  AAdd( mas_file, name_file )

  Default fl_view To .t.
  If arr_m == NIL
    Return arrKolSl
  Endif

  current_mo := glob_mo()
  check_pacient := { ;
      'Проверять ~всех пациентов', ;
      'Не проверять вернувшихся из ТФОМС с ~ошибкой' ;
    }
  If fl_view .and. ( ko := popup_prompt( T_ROW, T_COL + 5, 1, check_pacient ) ) == 0
    Return arrKolSl
  Endif

  kr_unlock := iif( fl_view, 50, 1000 )
  waitstatus( 'Начало проверки...' )
  
  ft := tfiletext():new( name_file, , .t., , .t. )
  ft:add_string( 'Список обнаруженных ошибок', FILE_CENTER, ' ' )
  ft:add_string( 'по дате окончания лечения ' + arr_m[ 4 ], FILE_CENTER, ' ' )
  ft:add_string( '' )

//  If ! fl_view
//    Use ( cur_dir() + 'A_SMO' ) new
//    Use ( cur_dir() + 'tmpb' ) index ( cur_dir() + 'tmpb' ) new
//  Endif

  adbf := { ;
            { 'kod', 'N', 7, 0 }, ;
            { 'tip', 'N', 1, 0 }, ;
            { 'komu', 'N', 1, 0 }, ;
            { 'str_crb', 'N', 2, 0 } ;
          } 
  dbCreate( 'mem:tmp_no', adbf, , .t., 'tmp_no' )

  f_create_diag_srok( 'tmp_d_srok' )
  Use ( cur_dir() + 'tmp_d_srok' ) New Alias D_SROK

  r_use( dir_server() + 'mo_pers', , 'PERS' )
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  use_base( 'lusl' )
  use_base( 'luslc' )
  use_base( 'luslf' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  g_use( dir_server() + 'human_u_', , 'HU_' )
  g_use( dir_server() + 'human_u', { dir_server() + 'human_u', ;
    dir_server() + 'human_uk', ;
    dir_server() + 'human_ud', ;
    dir_server() + 'human_uv', ;
    dir_server() + 'human_ua' }, 'HU' )
  Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To FIELD->u_kod into MOSU
  g_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  g_use( dir_server() + 'mo_onkna', dir_server() + 'mo_onkna', 'ONKNA' ) // онконаправления
  g_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'ONKSL' ) // Сведения о случае лечения онкологического заболевания
  g_use( dir_server() + 'mo_onkdi', dir_server() + 'mo_onkdi', 'ONKDI' ) // Диагностический блок
  g_use( dir_server() + 'mo_onkpr', dir_server() + 'mo_onkpr', 'ONKPR' ) // Сведения об имеющихся противопоказаниях
  g_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus', 'ONKUS' )
  g_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco', 'ONKCO' )
  g_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle', 'ONKLE' )
  g_use( dir_server() + 'human_2', , 'HUMAN_2' )
  g_use( dir_server() + 'human_', , 'HUMAN_' )
  g_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )

  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  If AScan( kod_LIS(), current_mo[ _MO_KOD_TFOMS ] ) > 0 .and. fl_view
    Private old_npr_mo := '000000'
    Index On f_napr_mo_lis() + Upper( FIELD->fio ) + Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_hfio' ) ;
      While human->k_data <= arr_m[ 6 ] .and. !Eof() ;
      For FIELD->tip_h == B_STANDART .and. Empty( FIELD->schet ) .and. !Empty( FIELD->k_data )
  Else
    Index On Upper( FIELD->fio ) + Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp_hfio' ) ;
      While human->k_data <= arr_m[ 6 ] .and. !Eof() ;
      For FIELD->tip_h == B_STANDART .and. Empty( FIELD->schet ) .and. !Empty( FIELD->k_data )
  Endif
  Set Index to ( dir_server() + 'humans' ), ( dir_server() + 'humankk' ), ( dir_server() + 'humand' ), ( cur_dir() + 'tmp_hfio' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To FIELD->kod_k into KART
  Set Order To 4

  tmpb->( dbSeek( kod_smo, .t. ) )
  Do While ! ( tmpb->( Eof() ) ) .and. ( tmpb->kod_smo == kod_smo )
    if tmpb->kod_smo != kod_smo
      tmpb->( dbSkip() )
      loop
    endif
    If emptyall( iprov, inprov )
      updatestatus()
    Endif
    human->( dbGoto( tmpb->kod_human ) )
    If Empty( human_->reestr )
      ++ii
      If ( fl := ( human->cena_1 == 0 ) ) // если цена нулевая
        otd->( dbGoto( human->OTD ) )
        If is_smp( human_->USL_OK, human_->PROFIL )  // скорая помощь
          fl = .f.
        Elseif eq_any( human->ishod, 201, 202, 204 ) // диспансеризация взрослого населения
          fl = .f.
        Elseif otd->tiplu == TIP_LU_ONKO_DISP
          fl := .f.
        Endif
      Endif
      If Empty( Int( Val( human_->smo ) ) ) // нет СМО
        fl := .t.
      Endif
      If fl // прочие счета
        TMP_NO->( dbAppend() )
        tmp_no->kod  := human->kod
        tmp_no->tip  := iif( human->cena_1 == 0, 1, 2 )
        tmp_no->komu := human->komu
        tmp_no->str_crb := human->str_crb
      Elseif ko == 2 .and. human_->oplata == 2 .and. human_->ST_VERIFY < 5
        // не проверять вернувшихся из ТФОМС с ошибкой
      Else

//        If arr_m[ 1 ] >= 2025
        fl := verify_sluch( fl_view, ft )
//        Endif
        If fl
          ++iprov
          If !fl_view .and. human->ishod != 88 .and. ! exist_reserve_ksg( human->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) ) // это не 1-ый л/у в двойном случае
//            Select TMPB
//            find ( Str( human->kod, 7 ) )
//            If !Found()
//              Append Blank
//              tmpb->kod_human := human->kod
//              tmpb->n_data := human->n_data
//              tmpb->k_data := human->k_data
//              tmpb->cena_1 := human->cena_1
//              tmpb->PZKOL := human_->pzkol
//              tmpb->ishod := human->ishod
//              tmpb->plus := .t.
              tmpb->kod_tmp := 1
//              tmpb->plus := .t.
//              If arr_m[ 1 ] > 2016
//                If is_dispanserizaciya( human->ishod )
                if tmpb->tip == 2
//                  tmpb->tip := 2
                  arrKolSl[ 2 ]++
                Else
//                  tmpb->tip := 1
                  arrKolSl[ 1 ]++
                Endif
//              Endif
//            Endif
            If iprov >= MAX_REC_REESTR // если число проверенных без ошибок достигло максимума,
              Exit                     // остальных не проверяем, начинаем составление реестра
            Endif
          Endif
        Else
          ++inprov
        Endif
      Endif
      @ MaxRow(), 50 Say PadL( 'всего: ' + lstr( iprov + inprov ) + ', ошибок: ' + lstr( inprov ), 30 ) Color cColorSt2Msg
    Endif
    If ii % kr_unlock == 0
      dbUnlockAll()
      dbCommitAll()
    Endif
//    Select HUMAN
//    Set Order To 4  //
    tmpb->( dbSkip() )
  Enddo
  dbUnlockAll()
  dbCommitAll()
  If inprov == 0
    If iprov > 0
      ft:add_string( 'Проверено случаев - ' + lstr( iprov ) + '. Ошибок не обнаружено.' )
    Else
      ft:add_string( 'Нечего проверять!' )
    Endif
  Endif
  ft := nil

  If ! fl_view
    human->( ordListClear() )
    g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    // проверяем случаи, где 2-ой случай закончился в текущем отчётном месяце, а 1-ый - неважно
//    Select HUMAN_3
//    Set Order To 2 // встать на индекс по 2-му случаю
    HUMAN_3->( ordSetFocus( 2 ) ) // встать на индекс по 2-му случаю для ALIAS-а HUMAN_3
    Select TMPB
    Index On FIELD->KOD_SMO + Str( FIELD->kod_human, 7 ) to ( 'mem:tmpb' ) For FIELD->ishod == 89  // 2-ой лист учёта в двойном случае

    tmpb->( dbSeek( kod_smo, .t. ) )
    Do While ! ( tmpb->( Eof() ) ) .and. ( tmpb->kod_smo == kod_smo )
      human_3->( dbSeek( Str( tmpb->kod_human, 7 ), .t. ) )
      If human_3->( Found() )
        human->( dbGoto( tmpb->kod_human ) )  // 2-ой лист учёта в двойном случае
        ln_data := human->n_data
        lk_data := human->k_data
        ldiag := human->kod_diag
        lcena := human->cena_1
        pz := human_->PZKOL
        human->( dbGoto( human_3->kod ) )
        If human_->ST_VERIFY >= 5 // если 1-ый л/у также прошёл проверку
          If ! exist_reserve_ksg( HUMAN->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) )
            ln_data := human->n_data
          Endif
          lcena += human->cena_1
          pz += human_->PZKOL
//          Select HUMAN_3
//          g_rlock( forever )
          human_3->( dbRLock() )
////          human_3->N_DATA    := ln_data
          human_3->K_DATA    := lk_data
          human_3->CENA_1    := lcena
          human->( dbGoto( human_3->kod2 ) ) // снова встать на 2-ой случай, чтобы взять исход, результат, ...
          human_3->RSLT_NEW  := human_->RSLT_NEW
          human_3->ISHOD_NEW := human_->ISHOD_NEW
          human_3->VNR1      := human_2->VNR1
          human_3->VNR2      := human_2->VNR2
          human_3->VNR3      := human_2->VNR3
          human_3->PZKOL     := pz
          human_3->ST_VERIFY := 5
          human_3->( dbUnlock() )
          tmpb->n_data := ln_data
          tmpb->k_data := lk_data
          tmpb->cena_1 := lcena
          tmpb->PZKOL := pz
        Else
          tmpb->tip := 0 // p_tip_reestr
          arrKolSl[ 1 ]--
        Endif
      Else
        tmpb->tip := 0 // p_tip_reestr
        arrKolSl[ 1 ]--
      endif
      tmpb->( dbSkip() )
    Enddo
  Endif
  If fl_view .and. d_srok->( LastRec() ) > 0
    HB_VFERASE( name_file2 )
    AAdd( mas_pmt, 'Случаи повторных обращений по поводу одного заболевания' )
    AAdd( mas_file, name_file2 )
    mywait()
    delfrfiles()
    adbf := { ;
      { 'name',   'C', 130, 0 }, ;
      { 'name1',  'C', 150, 0 }, ;
      { 'period', 'C', 150, 0 } ;
    }
    fr_titl := '_title'
    dbCreate( fr_titl, adbf )
    Use ( fr_titl ) New Alias FRT
    frt->( dbAppend() ) //  Append Blank
    frt->name := current_mo[ _MO_SHORT_NAME ]
    frt->name1 := 'Список случаев повторных обращений по поводу одного и того же заболевания'
    frt->period := arr_m[ 4 ]
    adbf := { ;
      { 'fio', 'C', 100, 0 }, ;
      { 'diag', 'C', 5, 0 }, ;
      { 'diag1', 'C', 5, 0 }, ;
      { 'srok', 'C', 30, 0 }, ;
      { 'srok1', 'C', 30, 0 }, ;
      { 'tip', 'C', 12, 0 }, ;
      { 'tip1', 'C', 12, 0 }, ;
      { 'otd', 'C', 200, 0 }, ;
      { 'otd1', 'C', 200, 0 }, ;
      { 'vrach', 'C', 100, 0 }, ;
      { 'vrach1', 'C', 100, 0 } ;
    }
    fr_data := '_data'
    dbCreate( fr_data, adbf )
    Use ( fr_data ) New Alias FRD
    am := { '78', '80', '88', '89' }
    Select HUMAN
    Set Index To
    Select D_SROK
    d_srok->( dbGoTop() )
    Do While ! d_srok->( Eof() )
      Select HUMAN
      human->( dbGoto( d_srok->kod ) )  //   Goto ( d_srok->kod )
      Select FRD
      frg->( dbAppend() ) //  Append Blank
      frd->fio := AllTrim( human->fio ) + ' д.р.' + full_date( human->date_r ) + ' (повтор через ' + lstr( d_srok->dni ) + ' дн.)'
      frd->diag := human->kod_diag
      frd->srok := full_date( human->n_data ) + ' - ' + full_date( human->k_data )
      If d_srok->tip > 0
        frd->tip := '( 2.' + am[ d_srok->tip ] + '.' + d_srok->tips + ' )'
      Elseif human_->usl_ok == USL_OK_HOSPITAL  // 1
        frd->tip := '( стац. )'
      Elseif human_->usl_ok == USL_OK_DAY_HOSPITAL  // 2
        frd->tip := '( дн.ст. )'
      Elseif human_->usl_ok == USL_OK_AMBULANCE // 4
        frd->tip := '( скорая )'
      Endif
      uch->( dbGoto( human->LPU ) )
      otd->( dbGoto( human->OTD ) )
      frd->otd := AllTrim( uch->name ) + '/ ' + AllTrim( otd->name ) + '/ профиль по "' + ;
        inieditspr( A__MENUVERT, getv002(), human_->profil ) + '"'
      pers->( dbGoto( human_->VRACH ) )
      frd->vrach := '[ ' + lstr( pers->tab_nom ) + ' ] ' + pers->fio
      //
      Select HUMAN
      human->( dbGoto( d_srok->kod1 ) )
      frd->diag1 := human->kod_diag
      frd->srok1 := full_date( human->n_data ) + ' - ' + full_date( human->k_data )
      If d_srok->tip1 > 0
        frd->tip1 := '( 2.' + am[ d_srok->tip1 ] + '.' + d_srok->tip1s + ' )'
      Elseif human_->usl_ok == USL_OK_HOSPITAL  // 1
        frd->tip1 := '( стац. )'
      Elseif human_->usl_ok == USL_OK_DAY_HOSPITAL  // 2
        frd->tip1 := '( дн.ст. )'
      Elseif human_->usl_ok == USL_OK_AMBULANCE // 4
        frd->tip1 := '( скорая )'
      Endif
      uch->( dbGoto( human->LPU ) )
      otd->( dbGoto( human->OTD ) )
      frd->otd1 := AllTrim( uch->name ) + '/ ' + AllTrim( otd->name ) + '/ профиль по "' + ;
        inieditspr( A__MENUVERT, getv002(), human_->profil ) + '"'
      pers->( dbGoto( human_->VRACH ) )
      frd->vrach1 := '[ ' + lstr( pers->tab_nom ) + ' ] ' + pers->fio
      Select D_SROK
      d_srok->( dbSkip() )  //Skip
    Enddo
  Endif
  If fl_view .and. tmp_no->( LastRec() ) > 0
    AAdd( mas_pmt, 'Список листов учёта, которые не проверялись' )
    AAdd( mas_file, name_file3 )

    ft := tfiletext():new( name_file3, , .t., , .t. )

    Select HUMAN
    Set Index To
    ft:add_string( '' )
    ft:add_string( 'Список листов учёта, которые не проверялись', FILE_CENTER, ' ' )

    r_use( dir_server() + 'str_komp', , 'STR' )
    r_use( dir_server() + 'komitet', , 'KOM' )
    Select TMP_NO
    Set Relation To FIELD->kod into HUMAN
    Index On Str( FIELD->tip, 1 ) + Str( FIELD->komu, 1 ) + Str( FIELD->str_crb, 2 ) + Upper( human->fio ) to ( cur_dir() + 'tmp_no' )
    old_tip := old_komu := old_str_crb := -1
    tmp_no->( dbGoTop() )
    Do While ! tmp_no->( Eof() )
      ft:add_string( '' )
      If old_tip != tmp_no->tip
        old_tip := tmp_no->tip
        If tmp_no->tip == 1
          ft:add_string( PadC( 'Нулевая цена', 80, '-' ) )
        Endif
      Endif
      If old_komu != tmp_no->komu
        old_komu := tmp_no->komu
        If tmp_no->tip == 2 .and. tmp_no->komu == 0
          ft:add_string( PadC( 'Пустая СМО', 80, '-' ) )
        Endif
      Endif
      If !( old_komu == tmp_no->komu .and. old_str_crb == tmp_no->str_crb )
        old_komu := tmp_no->komu
        old_str_crb := tmp_no->str_crb
        Do Case
        Case tmp_no->komu == 1
          str->( dbGoto( tmp_no->str_crb ) )
          ft:add_string( PadC( 'Прочая компания: ' + AllTrim( str->name ), 80, '-' ) )
        Case tmp_no->komu == 3
          kom->( dbGoto( tmp_no->str_crb ) )
          ft:add_string( PadC( 'Комитет/МО: ' + AllTrim( kom->name ), 80, '-' ) )
        Case tmp_no->komu == 5
          ft:add_string( PadC( 'Личный счёт', 80, '-' ) )
        Endcase
      Endif
      uch->( dbGoto( human->LPU ) )
      otd->( dbGoto( human->OTD ) )
      ft:add_string( AllTrim( human->fio ) + ' ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) )
      ft:add_string( ' ' + AllTrim( uch->name ) + '/' + AllTrim( otd->name ) )
      Select TMP_NO
      tmp_no->( dbSkip() )    // Skip
    Enddo
    ft := nil
  Endif

  close_use_base( 'lusl' )
  close_use_base( 'luslc' )
  close_use_base( 'luslf' )
  
  close_list_alias( { 'HU_', 'HU', 'MOSU', 'MOHU', 'TMP_NO', 'D_SROK' } )
  close_list_alias( { 'PERS', 'UCH', 'OTD', 'STR', 'KOM' } )
  close_list_alias( { 'ONKLE', 'ONKCO', 'ONKUS', 'ONKPR', 'ONKDI', 'ONKSL', 'ONKNA', 'KART_', 'KART' } )
  close_list_alias( { 'USL', 'USL1', 'K006', 'PRPRK' } )
  close_list_alias( { 'MKB_10', 'SMO', 'MOSPEC', 'MOPROF', 'HUMAN_3', 'HUMAN_2', 'HUMAN_', 'HUMAN' } )

  close_list_alias( { 'TMP_NO' } )
  dbDrop( 'mem:tmp_no' )  /* освободим память */

  // востановим индекс
  tmpSelect := Select()
  Index On FIELD->KOD_SMO + Str( FIELD->kod_human, 7 ) to ( 'mem:tmpb' )
  Select( tmpSelect )

  If fl_view
    clrline( MaxRow(), color0 )
    If Len( mas_pmt ) == 1
      viewtext( name_file, , , , .t., , , 5 )
    Else
      i := 1
      Keyboard Chr( K_ENTER )
      Do While i > 0
        If ( i := popup_prompt( T_ROW, T_COL + 5, i, mas_pmt, mas_pmt ) ) == 0
          If !f_esc_enter( 'выхода из просмотра' )
            i := 1
          Endif
        Elseif hb_FileExists( mas_file[ i ] )
          viewtext( mas_file[ i ], , , , .t., , , 5 )
        Else
          call_fr( 'mo_d_srok' )
        Endif
      Enddo
    Endif
  Endif
  Return arrKolSl