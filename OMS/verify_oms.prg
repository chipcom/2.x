#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define MAX_REC_REESTR 9999
#define MAX_REC_REESTR_RDL 5000
#define BASE_ISHOD_RZD 500

// 29.08.25
Function verify_oms( arr_m, fl_view )
  // Возврат: arrKolSl (массив)
  // 1 эл. - кол-во обычных случаев, 
  // 2 эл. - кол-во случаев диспансеризации

  Local ii := 0, iprov := 0, inprov := 0, ko := 2, fl, name_file := cur_dir() + 'err_sl.txt', ;
    name_file2, name_file3, kr_unlock, i, ;
    mas_pmt := { 'Список обнаруженных ошибок в результате проверки' }, mas_file := {}
  // local kol_1r := 0, ; // количество обычных случаев
  //   kol_2r := 0, ;     // количество случаев диспансеризации
  local  arrKolSl := { 0, 0 }

  local max_records_send

  max_records_send := iif( glob_mo[ _MO_KOD_TFOMS ] == '805965', MAX_REC_REESTR_RDL, MAX_REC_REESTR ) // число записываемых случаев в реестры

  AAdd( mas_file, name_file )

  Default arr_m To year_month( T_ROW, T_COL + 5, , 3 ), fl_view To .t.

  If arr_m == NIL
    // Return Nil
    Return arrKolSl
  Endif

  If arr_m[ 1 ] <= 2018
    func_error( 4, 'Случай ранее 2019 года.' )
    // Return Nil
    Return arrKolSl
  Endif

  If fl_view .and. ( ko := popup_prompt( T_ROW, T_COL + 5, 1, ;
      { 'Проверять ~всех пациентов', ;
      'Не проверять вернувшихся из ТФОМС с ~ошибкой' } ) ) == 0
    // Return Nil
    Return arrKolSl
  Endif
  kr_unlock := iif( fl_view, 50, 1000 )
  waitstatus( 'Начало проверки...' )
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Список обнаруженных ошибок', 80 ) )
  add_string( Center( 'по дате окончания лечения ' + arr_m[ 4 ], 80 ) )
  add_string( '' )
  If ! fl_view
    Use ( cur_dir() + 'tmp' ) new
    Use ( cur_dir() + 'tmpb' ) index ( cur_dir() + 'tmpb' ) new
  Endif
  dbCreate( cur_dir() + 'tmp_no', { { 'kod', 'N', 7, 0 }, ;
    { 'tip', 'N', 1, 0 }, ;
    { 'komu', 'N', 1, 0 }, ;
    { 'str_crb', 'N', 2, 0 } } )
  Use ( cur_dir() + 'tmp_no' ) new

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
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
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
  If AScan( kod_LIS, glob_mo[ _MO_KOD_TFOMS ] ) > 0 .and. fl_view
    Private old_npr_mo := '000000'
    Index On f_napr_mo_lis() + Upper( fio ) + Str( kod_k, 7 ) to ( cur_dir() + 'tmp_hfio' ) ;
      While human->k_data <= arr_m[ 6 ] .and. !Eof() ;
      For tip_h == B_STANDART .and. Empty( schet ) .and. !Empty( k_data )
  Else
    Index On Upper( fio ) + Str( kod_k, 7 ) to ( cur_dir() + 'tmp_hfio' ) ;
      While human->k_data <= arr_m[ 6 ] .and. !Eof() ;
      For tip_h == B_STANDART .and. Empty( schet ) .and. !Empty( k_data )
  Endif
  Set Index to ( dir_server() + 'humans' ), ( dir_server() + 'humankk' ), ( dir_server() + 'humand' ), ( cur_dir() + 'tmp_hfio' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To kod_k into KART
  Set Order To 4
  Go Top
  Do While !Eof()
    If emptyall( iprov, inprov )
      updatestatus()
    Endif
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
        Select TMP_NO
        Append Blank
        tmp_no->kod  := human->kod
        tmp_no->tip  := iif( human->cena_1 == 0, 1, 2 )
        tmp_no->komu := human->komu
        tmp_no->str_crb := human->str_crb
      Elseif ko == 2 .and. human_->oplata == 2 .and. human_->ST_VERIFY < 5
        // не проверять вернувшихся из ТФОМС с ошибкой
      Else
        If arr_m[ 1 ] > 2018
          fl := verify_sluch( fl_view )
        Endif
        If fl
          ++iprov
          If !fl_view .and. human->ishod != 88 .and. ! exist_reserve_ksg( human->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) ) // это не 1-ый л/у в двойном случае
            Select TMPB
            find ( Str( human->kod, 7 ) )
            If !Found()
              Append Blank
              tmpb->kod_human := human->kod
              tmpb->n_data := human->n_data
              tmpb->k_data := human->k_data
              tmpb->cena_1 := human->cena_1
              tmpb->PZKOL := human_->pzkol
              tmpb->ishod := human->ishod
              tmpb->plus := .t.
              tmpb->kod_tmp := 1
              tmpb->plus := .t.
              If arr_m[ 1 ] > 2016
//                If Between( human->ishod, 301, 305 ) .or. Between( human->ishod, 201, 205 ) .or. Between( human->ishod, 101, 102 ) .or. Between( human->ishod, 401, 402 ) .or. Between( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 )
                If is_dispanserizaciya( human->ishod )
                  tmpb->tip := 2
                  // kol_2r++
                  arrKolSl[ 2 ]++
                Else
                  tmpb->tip := 1
                  // kol_1r++
                  arrKolSl[ 1 ]++
                Endif
              Endif
            Endif
            If iprov >= max_records_send // если число проверенных без ошибок достигло максимума, 
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
    Select HUMAN
    Set Order To 4  //
    Skip
  Enddo
  dbUnlockAll()
  dbCommitAll()
  If inprov == 0
    If iprov > 0
      add_string( 'Проверено случаев - ' + lstr( iprov ) + '. Ошибок не обнаружено.' )
    Else
      add_string( 'Нечего проверять!' )
    Endif
  Endif
  FClose( fp )
  If !fl_view
    Select HUMAN
    Set Index To  // отвязываем условный индекс
    g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
    // проверяем случаи, где 2-ой случай закончился в текущем отчётном месяце, а 1-ый - неважно
    Select HUMAN_3
    Set Order To 2 // встать на индекс по 2-му случаю
    Select TMPB
    Index On Str( kod_human, 7 ) to ( cur_dir() + 'tmpb' ) For ishod == 89  // 2-ой лист учёта в двойном случае
    Go Top
    Do While !Eof()
      Select HUMAN_3
      find ( Str( tmpb->kod_human, 7 ) )
      If Found()
        Select HUMAN
        Goto ( tmpb->kod_human )  // 2-ой лист учёта в двойном случае
        ln_data := human->n_data
        lk_data := human->k_data
        ldiag := human->kod_diag
        lcena := human->cena_1
        pz := human_->PZKOL
        Select HUMAN
        Goto ( human_3->kod )
        If human_->ST_VERIFY >= 5 // если 1-ый л/у также прошёл проверку
          If !exist_reserve_ksg( HUMAN->kod, 'HUMAN', ( HUMAN->ishod == 89 .or. HUMAN->ishod == 88 ) )
            ln_data := human->n_data
          Endif
          lcena += human->cena_1
          pz += human_->PZKOL
          Select HUMAN_3
          g_rlock( forever )
//          human_3->N_DATA    := ln_data
          human_3->K_DATA    := lk_data
          human_3->CENA_1    := lcena
          Select HUMAN
          Goto ( human_3->kod2 )  // снова встать на 2-ой случай, чтобы взять исход, результат, ...
          human_3->RSLT_NEW  := human_->RSLT_NEW
          human_3->ISHOD_NEW := human_->ISHOD_NEW
          human_3->VNR1      := human_2->VNR1
          human_3->VNR2      := human_2->VNR2
          human_3->VNR3      := human_2->VNR3
          human_3->PZKOL     := pz
          human_3->ST_VERIFY := 5
          tmpb->n_data := ln_data
          tmpb->k_data := lk_data
          tmpb->cena_1 := lcena
          tmpb->PZKOL := pz
        Else
          tmpb->tip := 0 // p_tip_reestr
          // kol_1r--
          arrKolSl[ 1 ]--
        Endif
      Else
        tmpb->tip := 0 // p_tip_reestr
        // kol_1r--
        arrKolSl[ 1 ]--
      Endif
      Select TMPB
      Skip
    Enddo
  Endif
  If fl_view .and. d_srok->( LastRec() ) > 0
    name_file2 := cur_dir() + 'err_sl2.txt'
    Delete File ( name_file2 )
    AAdd( mas_pmt, 'Случаи повторных обращений по поводу одного заболевания' )
    AAdd( mas_file, name_file2 )
    mywait()
    delfrfiles()
    adbf := { { 'name', 'C', 130, 0 }, ;
      { 'name1', 'C', 150, 0 }, ;
      { 'period', 'C', 150, 0 } }
    dbCreate( fr_titl, adbf )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->name := glob_mo[ _MO_SHORT_NAME ]
    frt->name1 := 'Список случаев повторных обращений по поводу одного и того же заболевания'
    frt->period := arr_m[ 4 ]
    adbf := { { 'fio', 'C', 100, 0 }, ;
      { 'diag', 'C', 5, 0 }, ;
      { 'diag1', 'C', 5, 0 }, ;
      { 'srok', 'C', 30, 0 }, ;
      { 'srok1', 'C', 30, 0 }, ;
      { 'tip', 'C', 12, 0 }, ;
      { 'tip1', 'C', 12, 0 }, ;
      { 'otd', 'C', 200, 0 }, ;
      { 'otd1', 'C', 200, 0 }, ;
      { 'vrach', 'C', 100, 0 }, ;
      { 'vrach1', 'C', 100, 0 } }
    dbCreate( fr_data, adbf )
    Use ( fr_data ) New Alias FRD
    am := { '78', '80', '88', '89' }
    Select HUMAN
    Set Index To
    Select D_SROK
    Go Top
    Do While !Eof()
      Select HUMAN
      Goto ( d_srok->kod )
      Select FRD
      Append Blank
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
      Goto ( d_srok->kod1 )
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
      Skip
    Enddo
  Endif
  If fl_view .and. tmp_no->( LastRec() ) > 0
    name_file3 := cur_dir() + 'err_sl3.txt'
    AAdd( mas_pmt, 'Список листов учёта, которые не проверялись' )
    AAdd( mas_file, name_file3 )
    fp := FCreate( name_file3 )
    n_list := 1
    tek_stroke := 0
    Select HUMAN
    Set Index To
    add_string( '' )
    add_string( Center( 'Список листов учёта, которые не проверялись', 80 ) )
    r_use( dir_server() + 'str_komp', , 'STR' )
    r_use( dir_server() + 'komitet', , 'KOM' )
    Select TMP_NO
    Set Relation To kod into HUMAN
    Index On Str( tip, 1 ) + Str( komu, 1 ) + Str( str_crb, 2 ) + Upper( human->fio ) to ( cur_dir() + 'tmp_no' )
    old_tip := old_komu := old_str_crb := -1
    Go Top
    Do While !Eof()
      verify_ff( 77, .t., 80 )
      add_string( '' )
      If old_tip != tmp_no->tip
        old_tip := tmp_no->tip
        If tmp_no->tip == 1
          add_string( PadC( 'Нулевая цена', 80, '-' ) )
        Endif
      Endif
      If old_komu != tmp_no->komu
        old_komu := tmp_no->komu
        If tmp_no->tip == 2 .and. tmp_no->komu == 0
          add_string( PadC( 'Пустая СМО', 80, '-' ) )
        Endif
      Endif
      If !( old_komu == tmp_no->komu .and. old_str_crb == tmp_no->str_crb )
        old_komu := tmp_no->komu
        old_str_crb := tmp_no->str_crb
        Do Case
        Case tmp_no->komu == 1
          str->( dbGoto( tmp_no->str_crb ) )
          add_string( PadC( 'Прочая компания: ' + AllTrim( str->name ), 80, '-' ) )
        Case tmp_no->komu == 3
          kom->( dbGoto( tmp_no->str_crb ) )
          add_string( PadC( 'Комитет/МО: ' + AllTrim( kom->name ), 80, '-' ) )
        Case tmp_no->komu == 5
          add_string( PadC( 'Личный счёт', 80, '-' ) )
        Endcase
      Endif
      uch->( dbGoto( human->LPU ) )
      otd->( dbGoto( human->OTD ) )
      add_string( AllTrim( human->fio ) + ' ' + date_8( human->n_data ) + '-' + date_8( human->k_data ) )
      add_string( ' ' + AllTrim( uch->name ) + '/' + AllTrim( otd->name ) )
      Select TMP_NO
      Skip
    Enddo
    FClose( fp )
  Endif
  Close databases
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

  // Return Nil
  // arrKolSl[ 1 ] := kol_1r
  // arrKolSl[ 2 ] := kol_2r
  Return arrKolSl

// 15.06.24
Function verify_oms_sluch( mkod )

  Local buf := save_maxrow(), fl := .t., name_file := cur_dir() + 'err_sl.txt'

  mywait()
  f_create_diag_srok( 'tmp_d_srok' )
  Use ( cur_dir() + 'tmp_d_srok' ) New Alias D_SROK

  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Список обнаруженных ошибок', 80 ) )
  add_string( Center( 'в листе учёта', 80 ) )
  add_string( '' )
  //
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
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
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
  g_use( dir_server() + 'human', { dir_server() + 'humans', ;
    dir_server() + 'humankk', ;
    dir_server() + 'humand' }, 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To kod_k into KART
  Goto ( mkod )
  If Empty( human->k_data )
    //
  Elseif Year( human->k_data ) > 2018
    fl := verify_sluch()
  Else
    func_error( 4, 'Случай ранее 2019 года.' )
    Close databases
    Return Nil
  Endif
  If d_srok->( LastRec() ) > 0
    am := { '78', '80', '88', '89' }
    If fl
      uch->( dbGoto( human->LPU ) )
      otd->( dbGoto( human->OTD ) )
      add_string( AllTrim( human->fio ) + ' ' + AllTrim( human->kod_diag ) + ' ' + ;
        date_8( human->n_data ) + '-' + date_8( human->k_data ) + ;
        iif( d_srok->tip == 0, '', ' (2.' + am[ d_srok->tip ] + '.*)' ) )
      add_string( AllTrim( uch->name ) + '/' + AllTrim( otd->name ) + '/профиль по "' + ;
        inieditspr( A__MENUVERT, getv002(), human_->profil ) + '"' )
      pers->( dbGoto( human_->VRACH ) )
      add_string( 'лечащий врач [' + lstr( pers->tab_nom ) + '] ' + pers->fio )
    Endif
    Select HUMAN
    Goto ( d_srok->kod1 )
    uch->( dbGoto( human->LPU ) )
    otd->( dbGoto( human->OTD ) )
    add_string( '' )
    add_string( Center( 'Предупреждение!', 80 ) )
    add_string( '' )
    add_string( 'Обратите внимание, что ' + lstr( d_srok->dni ) + ' дней назад обнаружен случай' )
    add_string( 'с основным диагнозом ' + AllTrim( human->kod_diag ) + ' ' + ;
      date_8( human->n_data ) + '-' + date_8( human->k_data ) + ;
      iif( d_srok->tip1 == 0, '', ' (2.' + am[ d_srok->tip1 ] + '.*)' ) )
    add_string( AllTrim( uch->name ) + '/' + AllTrim( otd->name ) + '/профиль по "' + ;
      inieditspr( A__MENUVERT, getv002(), human_->profil ) + '"' )
    pers->( dbGoto( human_->VRACH ) )
    add_string( 'лечащий врач [' + lstr( pers->tab_nom ) + '] ' + pers->fio )
    fl := .f.
  Endif
  Close databases
  FClose( fp )
  rest_box( buf )
  If !fl
    viewtext( name_file, , , , .t., , , 5 )
  Endif

  Return Nil
