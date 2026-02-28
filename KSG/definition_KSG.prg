#include 'inkey.ch'
#include 'function.ch'
#include 'tbox.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.02.26 определение КСГ по остальным введённым полям ввода - 2019-24 год
Function definition_ksg( par, k_data2, lDoubleSluch )

  // файлы 'human', 'human_' и 'human_2' открыты и стоят на нужной записи
  // 'human' открыт для записи суммы случая
  // выполнено use_base('human_u', 'HU') - для записи
  // выполнено use_base('mo_hu', 'MOHU') - для записи
  Static ver_year := 0 // последний проверяемый год
  Static sp0, sp1, sp6, sp15
  Static a_iskl_1 := { ; // исключение из правил №1
    { 'st02.010', 'st02.008' }, ;
    { 'st02.011', 'st02.008' }, ;
    { 'st02.010', 'st02.009' }, ;
    { 'st14.001', 'st04.002' }, ;
    { 'st14.004', 'st04.002' }, ;
    { 'st21.001', 'st21.007' }, ;
    { 'st34.002', 'st34.001' }, ;
    { 'st34.002', 'st26.001' }, ;
    { 'st34.006', 'st30.003' }, ;
    { 'st09.001', 'st30.005' }, ;
    { 'st31.002', 'st31.017' }, ;
    { 'st37.001', '' }, ;
    { 'st37.002', '' }, ;
    { 'st37.003', '' }, ;
    { 'st37.004', '' }, ;
    { 'st37.005', '' }, ;
    { 'st37.006', '' }, ;
    { 'st37.007', '' }, ;
    { 'st37.008', '' }, ;
    { 'st37.009', '' }, ;
    { 'st37.010', '' }, ;
    { 'st37.011', '' }, ;
    { 'st37.012', '' }, ;
    { 'st37.013', '' }, ;
    { 'st37.014', '' }, ;
    { 'st37.015', '' }, ;
    { 'st37.016', '' }, ;
    { 'st37.017', '' }, ;
    { 'st37.018', '' }, ;
    { 'ds37.001', '' }, ;
    { 'ds37.002', '' }, ;
    { 'ds37.003', '' }, ;
    { 'ds37.004', '' }, ;
    { 'ds37.005', '' }, ;
    { 'ds37.006', '' }, ;
    { 'ds37.007', '' }, ;
    { 'ds37.008', '' }, ;
    { 'ds37.009', '' }, ;
    { 'ds37.010', '' }, ;
    { 'ds37.011', '' }, ;
    { 'ds37.012', '' };
  }

  Local mdiagnoz, aHirKSG := {}, aTerKSG := {}, fl_cena := .f., lvmp, lvidvmp := 0, lstentvmp := 0, ;
    strSoob, ar1, fl, im, lshifr, ln_data, lk_data, lvr, ldni, ldate_r, lpol, lprofil_k, ;
    lfio, cenaTer := 0, cenaHir := 0, ars := {}, arerr := {}, ;
    lksg := '', lcena := 0, lprofil, ldnej := 0, y := 0, m := 0, d := 0, ;
    osn_diag := Space( 6 ), sop_diag := {}, osl_diag := {}, tmp, lrslt, akslp, akiro, ;
    lad_cr := '', lad_cr1 := '', lis_err := 0, lpar_org := 0, lyear, ;
    kol_ter := 0, kol_hir := 0, lkoef, fl_reabil, lkiro := 0, lkslp := '', lbartell := '', ;
    s_dializ := 0, ahu := {}, amohu := {}, nfile, ;
    date_usl := SToD( '20210101' ) // stod('20200101')
  local typeKSG  // тип КСГ ( st или ds )
  local uslOkaz         // условия оказания (стационар, дневной стационар м т.д.)
  local i, j
  local _a1, ar, ar_crit, ar_crit1
  local c_crit, icrit
  local lal, lalf, lage
  local lsex, llos
  local sds1, sds2
  local arr_ad_criteria
  local oBox

  Local iKSLP, newKSLP := '', tmpSelect
  Local humKSLP := ''
  Local vkiro := 0
	local color_say := 'N/W', color_get := 'W/N*'
  local two_letters
  local ltype_ksg := 0

  Default par To 1, sp0 To '', sp1 To Space( 1 ), sp6 To Space( 6 ), sp15 To Space( 20 )
  Default lDoubleSluch To .f.
  Private pole

  If par == 1
    uch->( dbGoto( human->LPU ) )
    otd->( dbGoto( human->OTD ) )
    If ( lvmp := human_2->VMP ) == 1
      lvidvmp := human_2->METVMP
    Endif
    lad_cr  := AllTrim( human_2->pc3 )
    lfio    := AllTrim( human->fio )
    ln_data := human->n_data
    If ValType( k_data2 ) == 'D'
      lk_data := k_data2
    Else
      lk_data := human->k_data
    Endif
    uslOkaz    := human_->USL_OK
    ldate_r := iif( human_->NOVOR > 0, human_->date_r2, human->date_r )
    lpol    := iif( human_->NOVOR > 0, human_->pol2,    human->pol )
    lvr     := iif( human->VZROS_REB == 0, 0, 1 ) // 0-взрослый, 1-ребенок
    lprofil := human_->profil
    lprofil_k := human_2->profil_k
    lrslt   := human_->rslt_new
    // массив диагнозов (минимум два)
    mdiagnoz := diag_to_array( , , , , .t. )
    If Len( mdiagnoz ) > 0
      osn_diag := mdiagnoz[ 1 ]
      If Len( mdiagnoz ) > 1
        sop_diag := AClone( mdiagnoz )
        hb_ADel( sop_diag, 1, .t. ) // начиная со 2-го - сопутствующие диагнозы
      Endif
    Endif
    If !Empty( human_2->OSL1 )
      AAdd( osl_diag, human_2->OSL1 )
    Endif
    If !Empty( human_2->OSL2 )
      AAdd( osl_diag, human_2->OSL2 )
    Endif
    If !Empty( human_2->OSL3 )
      AAdd( osl_diag, human_2->OSL3 )
    Endif

    If uslOkaz < 3 .and. lVMP == 0 .and. f_is_oncology( 1 ) == 2 .and. Empty( lad_cr )
      If Select( 'ONKSL' ) == 0
        g_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'ONKSL' ) // Сведения о случае лечения онкологического заболевания
      Endif
      Select ONKSL
      onksl->( dbSeek( Str( human->kod, 7 ) ) )  //find ( Str( human->kod, 7 ) )
      lad_cr := AllTrim( onksl->crit )
      If lad_cr == 'нет'
        lad_cr := ''
      Endif
      lad_cr1 := AllTrim( onksl->crit2 )
      lis_err := onksl->is_err
    Endif
  Else // из режима импорта случаев
    If ( lvmp := iif( Empty( ihuman->VID_HMP ), 0, 1 ) ) == 1
      lvidvmp := ihuman->METOD_HMP
    Endif
    lad_cr  := AllTrim( ihuman->ad_cr )
    If lad_cr == 'нет'
      lad_cr := ''
    Endif
    lad_cr1 := AllTrim( ihuman->ad_cr2 )
    lis_err := ihuman->is_err
    uslOkaz    := ihuman->USL_OK
    lfio    := AllTrim( ihuman->fio )
    ln_data := ihuman->date_1
    If ValType( k_data2 ) == 'D'
      lk_data := k_data2
    Else
      lk_data := ihuman->date_2
    Endif
    ldate_r := iif( ihuman->NOVOR > 0, ihuman->reb_dr,  ihuman->dr )
    lpol    := iif( ihuman->NOVOR > 0, ihuman->reb_pol, ihuman->w )
    lpol    := iif( lpol == 1, 'М', 'Ж' )
    lvr     := iif( m1VZROS_REB == 0, 0, 1 ) // 0-взрослый, 1-ребенок
    lprofil := ihuman->profil
    lprofil_k := ihuman->profil_k
    lrslt   := ihuman->rslt
    osn_diag := PadR( ihuman->DS1, 6 )
    If !Empty( ihuman->DS2 )
      AAdd( sop_diag, PadR( ihuman->DS2, 6 ) )
    Endif
    If !Empty( ihuman->DS2_2 )
      AAdd( sop_diag, PadR( ihuman->DS2_2, 6 ) )
    Endif
    If !Empty( ihuman->DS2_3 )
      AAdd( sop_diag, PadR( ihuman->DS2_3, 6 ) )
    Endif
    If !Empty( ihuman->DS2_4 )
      AAdd( sop_diag, PadR( ihuman->DS2_4, 6 ) )
    Endif
    If !Empty( ihuman->DS2_5 )
      AAdd( sop_diag, PadR( ihuman->DS2_5, 6 ) )
    Endif
    If !Empty( ihuman->DS2_6 )
      AAdd( sop_diag, PadR( ihuman->DS2_6, 6 ) )
    Endif
    If !Empty( ihuman->DS2_7 )
      AAdd( sop_diag, PadR( ihuman->DS2_7, 6 ) )
    Endif
    mdiagnoz := AClone( sop_diag )
    ins_array( mdiagnoz, 1, osn_diag )
    If !Empty( ihuman->DS3 )
      AAdd( osl_diag, PadR( ihuman->DS3, 6 ) )
    Endif
    If !Empty( ihuman->DS3_2 )
      AAdd( osl_diag, PadR( ihuman->DS3_2, 6 ) )
    Endif
    If !Empty( ihuman->DS3_3 )
      AAdd( osl_diag, PadR( ihuman->DS3_3, 6 ) )
    Endif
  Endif

  //
  lyear := Year( lk_data )
  If eq_any( lad_cr, '60', '61' )
    lbartell := lad_cr
    lad_cr := ''
  Endif
  ldni := ln_data - ldate_r // для ребёнка возраст в днях
  count_ymd( ldate_r, ln_data, @y, @m, @d )
  date_usl := lk_data // !!!!!!!!!!!!раскомментировать после теста!!!!!!!!!!!!!!!
  If uslOkaz == USL_OK_HOSPITAL // стационар
    If ( ldnej := lk_data - ln_data ) == 0
      ldnej := 1
    Endif
  Endif
  AAdd( ars, lfio + ', д.р.' + full_date( ldate_r ) + iif( lvr == 0, ' (взр.', ' (реб.' ) + '), ' + iif( lpol == 'М', 'муж.', 'жен.' ) )
  AAdd( ars, ' срок лечения: ' + date_8( ln_data ) + '-' + date_8( lk_data ) + ' (' + lstr( ldnej ) + 'дн.)' )
  strSoob := iif( lVMP == 1, 'ВМП ', ' ' )
  If par == 1
    strSoob += AllTrim( substr( otd->name, 1, 30 ) ) + ' / '
  Endif
  strSoob += 'профиль "' + inieditspr( A__MENUVERT, getv002(), lprofil ) + '"'
  AAdd( ars, strSoob )
  AAdd( ars, ' Осн.диаг.: ' + osn_diag + ;
    iif( Empty( sop_diag ), '', ', соп.диаг.' + CharRem( ' ', print_array( sop_diag ) ) ) + ;
    iif( Empty( osl_diag ), '', ', диаг.осл.' + CharRem( ' ', print_array( osl_diag ) ) ) )
  If Empty( osn_diag )
    AAdd( arerr, ' не введён основной диагноз' )
    Return { ars, arerr, lksg, lcena, {}, {} }
  Endif
  If f_put_glob_podr( uslOkaz, date_usl, arerr ) // если не заполнен код подразделения
    Return { ars, arerr, lksg, lcena, {}, {} }
  Endif
  If lvmp > 0
    If lvidvmp == 0
      AAdd( arerr, ' не введён метод ВМП' )
    Elseif ( AScan( arr_VMP(), lvidvmp ) == 0 .and. Year( lk_data ) < 2021 )
      AAdd( arerr, ' для метода ВМП ' + lstr( lvidvmp ) + ' нет услуги ТФОМС' )
    Else
      lksg := getserviceforvmp( lvidvmp, lk_data, human_2->VIDVMP, human_2->METVMP, human_2->PN5, full_diagnoz_human( human->KOD_DIAG, human->DIAG_PLUS ) )
      AAdd( ars, ' для ' + lstr( lvidvmp ) + ' метода ВМП введена услуга ' + lksg )
      lcena := ret_cena_ksg( lksg, lvr, date_usl )
      If lcena > 0
        AAdd( ars, ' РЕЗУЛЬТАТ: выбрана услуга = ' + lksg + ' с ценой ' + lstr( lcena, 11, 0 ) )
      Else
        AAdd( arerr, ' для Вашей МО в справочнике ТФОМС не найдена услуга: ' + lksg )
      Endif
    Endif
    Return { ars, arerr, AllTrim( lksg ), lcena, {}, {} }
  Endif
  lal := create_name_alias( 'LUSL', lyear )
  lalf := create_name_alias( 'LUSLF', lyear )
  If Select( 'LUSLF' ) == 0
    use_base( 'LUSLF' )
  Endif

  // составляем массив услуг и массив манипуляций
  If par == 1
    Select HU
    hu->( dbSeek( Str( human->kod, 7 ) ) )  //find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. ! hu->( Eof() )
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, date_usl ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If ( Left( lshifr, 5 ) == '60.3.' ) .or. ( Left( lshifr, 6 ) == '60.10.' )
        s_dializ += hu->stoim_1
      Endif
      If AScan( ahu, lshifr ) == 0
        AAdd( ahu, lshifr )
      Endif
      If uslOkaz == USL_OK_DAY_HOSPITAL .and. Left( lshifr, 5 ) == '55.1.'
        ldnej += hu->kol_1
      Endif
      Select HU
      hu->( dbSkip() )  //  Skip
    Enddo
    If Select( 'MOSU' ) == 0
      r_use( dir_server() + 'mo_su', , 'MOSU' )
    Endif
    Select MOHU
    mohu->( dbSeek( Str( human->kod, 7 ) ) )  //find ( Str( human->kod, 7 ) )
    Do While mohu->kod == human->kod .and. ! mohu->( Eof() )
      If mosu->( RecNo() ) != mohu->u_kod
        mosu->( dbGoto( mohu->u_kod ) )
      Endif
      If AScan( amohu, mosu->shifr1 ) == 0
        AAdd( amohu, mosu->shifr1 )
      Endif
      dbSelectArea( lalf )
      find ( PadR( mosu->shifr1, 20 ) )
      If Found() .and. !Empty( &lalf.->par_org )
        lpar_org += Len( list2arr( mohu->zf ) )
      Endif
      Select MOHU
      mohu->( dbSkip() )  //  Skip
    Enddo
  Else
    Select IHU
    find ( Str( ihuman->kod, 10 ) )
    Do While ihu->kod == ihuman->kod .and. !Eof()
      If eq_any( Left( ihu->CODE_USL, 1 ), 'A', 'B' )
        If AScan( amohu, ihu->CODE_USL ) == 0
          AAdd( amohu, ihu->CODE_USL )
        Endif
        dbSelectArea( lalf )
        find ( PadR( ihu->CODE_USL, 20 ) )
        If Found() .and. !Empty( &lalf.->par_org )
          lpar_org += Len( list2arr( ihu->par_org ) )
        Endif
      Else
        If AScan( ahu, AllTrim( ihu->CODE_USL ) ) == 0
          AAdd( ahu, AllTrim( ihu->CODE_USL ) )
        Endif
        If ( Left( ihu->CODE_USL, 5 ) == '60.3.' ) .or. ( Left( ihu->CODE_USL, 6 ) == '60.10.' )
          s_dializ += ihu->SUMV_USL
        Endif
        If uslOkaz == USL_OK_DAY_HOSPITAL .and. Left( ihu->CODE_USL, 5 ) == '55.1.'
          ldnej += ihu->KOL_USL
        Endif
      Endif
      Select IHU
      ihu->( dbSkip() )  //  Skip
    Enddo
  Endif

  //
  If lvr == 0 //
    lage := '6'
    strSoob := 'взр.'
  Else
    lage := '5'
    strSoob := 'дети'
    fl := .t.
    If ldni <= 28
      lage += '1' // дети до 28 дней
      strSoob := '0-28дн.'
      fl := .f.
    Elseif ldni <= 90
      lage += '2' // дети до 90 дней
      strSoob := '29-90дн.'
      fl := .f.
    Elseif y < 1 // до 1 года
      lage += '3' // дети от 91 дня до 1 года
      strSoob := '91день-1год'
      fl := .f.
    Endif
    If y <= 2 // до 2 лет включительно
      lage += '4' // дети до 2 лет
      If fl
        strSoob := 'до2лет включ.'
      Endif
    Endif
  Endif
  ars[ 1 ] := lfio + ', д.р. ' + full_date( ldate_r ) + iif( lvr == 0, ' (взр.', ' (реб.' ) + '), ' + iif( lpol == 'М', 'муж.', 'жен.' )
  ars[ 2 ] := ' срок лечения: ' + date_8( ln_data ) + '-' + date_8( lk_data ) + ' (' + lstr( ldnej ) + 'дн.)'

  ars[ 4 ] := ' Осн.диаг.: ' + osn_diag + ;
    iif( Empty( sop_diag ), '', ', соп.диаг.' + CharRem( ' ', print_array( sop_diag ) ) ) + ;
    iif( Empty( osl_diag ), '', ', диаг.осл.' + CharRem( ' ', print_array( osl_diag ) ) )
  lsex := iif( lpol == 'М', '1', '2' )

  llos := {} // ''
  If ldnej < 4
    AAdd( llos, '1' ) // llos += '1'
  Elseif Between( ldnej, 4, 10 )
    AAdd( llos, '11' )
  Elseif Between( ldnej, 11, 20 )
    AAdd( llos, '12' )
  Elseif Between( ldnej, 21, 30 )
    AAdd( llos, '13' )
  Endif
  /*
  0 - КИРО не применяется
  1 - длительность случая 3 койко-дня (дней лечения) и менее и пациенту выполнена хирургическая операция
      либо другое вмешательство, являющиеся классификационным критерием отнесения данного случая лечения
      к конкретной КСГ вне зависимости от сочетания с результатами обращения за медицинской помощью
  2 - длительность случая 3 койко-дня (дней лечения) и менее, но хирургическое лечение либо другое вмешательство,
      определяющее отнесение к КСГ не проводилось и критерием отнесения в случае является код диагноза по МКБ 10
      вне зависимости от сочетания с результатами обращения за медицинской помощью;
  3 - длительность случая 4 койко-дня (дней лечения) и более и пациенту выполнена хирургическая операция
      либо другое вмешательство, являющиеся классификационным критерием отнесения данного случая лечения
      к конкретной КСГ в сочетании с результатами обращения за медицинской помощью
      (Классификатор V009) 102, 105, 107, 110, 202, 205, 207
  4 - длительность случая 4 койко-дня (дней лечения) и более, но хирургическое лечение либо другое вмешательство,
      определяющее отнесение к КСГ не проводилось, в сочетании с результатами обращения за медицинской помощью
      (Классификатор V009) 102, 105, 107, 110, 202, 205, 207
  5 - случаи с несоблюдением режима введения лекарственного препарата (дней введения в схеме) согласно инструкции
      к препарату при длительности случая 3 койко-дня (дня лечения) и менее вне зависимости от результата обращения
      за медицинской помощью
  6 - случаи с несоблюдением режима введения лекарственного препарата (дней введения в схеме) согласно инструкции
      к препарату при длительности случая 4 койко-дня (дня лечения) и более в сочетании с результатами обращения
      за медицинской помощью (Классификатор V009) 102, 105, 107, 110, 202, 205, 207
  */
  // aadd(ars, '   ║age=' +lage+ ' sex=' +lsex+ ' los=' +print_array(llos))

  nfile := prefixfilerefname( lyear ) + 'k006'
  If Select( 'K006' ) == 0
    r_use( dir_exe() + nfile, { cur_dir() + nfile, cur_dir() + nfile + '_', cur_dir() + nfile + 'AD' }, 'K006' )
  Else
    If ver_year == lyear // проверяем: если тот же год, что только что проверяли
      // ничего не меняем
    Else // иначе переоткрываем данный файл с необходимым годом и тем же алиасом
      k006->( dbCloseArea() )
      r_use( dir_exe() + nfile, { cur_dir() + nfile, cur_dir() + nfile + '_', cur_dir() + nfile + 'AD' }, 'K006' )
    Endif
  Endif
  ver_year := lyear
  fl_reabil := ( AScan( ahu, '1.11.2' ) > 0 .or. AScan( ahu, '55.1.4' ) > 0 )
  typeKSG := iif( uslOkaz == USL_OK_HOSPITAL, 'st', 'ds' )

  // собираем КСГ по осн.диагнозу (терапевтические и комбинированные)
  ar := {}
  tmp := {}
  Select K006

  If lprofil == 137   // ЭКО
    Set Order To 3
    K006->( dbGoTop() )
    K006->( dbSeek( Lower( lad_cr ) ) )
    Do While Lower( AllTrim( K006->AD_CR ) ) == Lower( AllTrim( lad_cr ) ) .and. !( 'K006' )->( Eof() )

      lkoef := k006->kz
      dbSelectArea( lal )
      find ( PadR( k006->shifr, 10 ) )
      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      j := 0
      j++
      j++
      If fl
        if lk_data >= 0d20260101
          AAdd( ar, { k006->shifr, ; // 1
            0, ;           // 2
            lkoef, ;       // 3
            &lal.->kiros, ; // 4
            osn_diag, ;    // 5
            k006->sy, ;    // 6
            k006->age, ;   // 7
            k006->sex, ;   // 8
            k006->los, ;   // 9
            k006->ad_cr, ; // 10
            '', ;        // 11
            '', ;        // 12
            j, ;           // 13
            &lal.->kslps, ; // 14
            k006->ad_cr1, ; // 15
            &lal.->TYPE_KSG } ; // 16
          )
        else
          AAdd( ar, { k006->shifr, ; // 1
            0, ;           // 2
            lkoef, ;       // 3
            &lal.->kiros, ; // 4
            osn_diag, ;    // 5
            k006->sy, ;    // 6
            k006->age, ;   // 7
            k006->sex, ;   // 8
            k006->los, ;   // 9
            k006->ad_cr, ; // 10
            '', ;        // 11
            '', ;        // 12
            j, ;           // 13
            &lal.->kslps, ; // 14
            k006->ad_cr1 } ; // 15
          )
        endif
      Endif
      K006->( dbSkip() )
    Enddo
  Else
    Set Order To 1
    find ( typeKSG + PadR( osn_diag, 6 ) )
    Do While Left( k006->shifr, 2 ) == typeKSG .and. k006->ds == PadR( osn_diag, 6 ) .and. ! k006->( Eof() )
      lkoef := k006->kz
      dbSelectArea( lal )
      find ( PadR( k006->shifr, 10 ) )
      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      If fl
        sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // соп.диагноз
        sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // диагн.осложнения
      Endif
      j := 0

      // что-то здесь не так
      If fl .and. !Empty( k006->sy )
        If ( i := AScan( amohu, k006->sy ) ) > 0
          j += 10
        Else
          fl := .f.
        Endif
      Endif
      // конец что-то здесь не так

      If fl .and. !Empty( k006->age )
        If ( fl := ( k006->age $ lage ) )
          If k006->age == '1'
            j += 5
          Elseif k006->age == '2'
            j += 4
          Elseif k006->age == '3'
            j += 3
          Elseif k006->age == '4'
            j += 2
          Else
            j++
          Endif
        Endif
      Endif
      If fl .and. !Empty( k006->sex )
        fl := ( k006->sex == lsex )
        If fl
          j++
        Endif
      Endif
      If fl .and. !Empty( k006->los )
        fl := AScan( llos, AllTrim( k006->los ) ) > 0  // (k006->los $ llos)
        If fl
          j++
        Endif
      Endif

      If fl
        If Empty( lad_cr ) // в случае нет доп.критерия
          If !Empty( k006->ad_cr ) // а в справочнике есть доп.критерий
            fl := .f.
          Endif
        Else // в случае есть доп.критерий
          If Empty( k006->ad_cr ) // а в справочнике нет доп.критерия
            fl := .f.
          Else                  // а в справочнике есть доп.критерий
            fl := ( AllTrim( lad_cr ) == AllTrim( k006->ad_cr ) )
            If fl
              j++
            Endif
          Endif
        Endif
      Endif
      If fl
        If Empty( lad_cr1 ) // в случае нет доп.критерия2
          If !Empty( k006->ad_cr1 ) // а в справочнике есть доп.критерий2
            fl := .f.
          Endif
        Else // в случае есть доп.критерий2
          If Empty( k006->ad_cr1 ) // а в справочнике нет доп.критерия2
            fl := .f.
          Else                  // а в справочнике есть доп.критерий2
            fl := ( lad_cr1 == AllTrim( k006->ad_cr1 ) )
            If fl
              j++
            Endif
          Endif
        Endif
      Endif
      //
      If fl .and. !Empty( sds1 )
        fl := .f.
        For i := 1 To Len( sop_diag )
          If AllTrim( sop_diag[ i ] ) $ sds1
            fl := .t.
            Exit
          Endif
        Next
        If fl
          j++
        Endif
      Endif
      If fl .and. !Empty( sds2 )
        fl := .f.
        For i := 1 To Len( osl_diag )
          If AllTrim( osl_diag[ i ] ) $ sds2
            fl := .t.
            Exit
          Endif
        Next
        If fl
          j++
        Endif
      Endif
      //
      If fl
        If !Empty( k006->sy ) .and. ( i := AScan( amohu, k006->sy ) ) > 0
          AAdd( tmp, i )
        Endif
        if lk_data >= 0d20260101
          AAdd( ar, { k006->shifr, ; // 1
            0, ;           // 2
            lkoef, ;       // 3
            &lal.->kiros, ; // 4
            osn_diag, ;    // 5
            k006->sy, ;    // 6
            k006->age, ;   // 7
            k006->sex, ;   // 8
            k006->los, ;   // 9
            k006->ad_cr, ; // 10
            sds1, ;        // 11
            sds2, ;        // 12
            j, ;           // 13
            &lal.->kslps, ; // 14
            k006->ad_cr1, ; // 15
            &lal.->TYPE_KSG } ; // 16
          )
        else
          AAdd( ar, { k006->shifr, ; // 1
            0, ;           // 2
            lkoef, ;       // 3
            &lal.->kiros, ; // 4
            osn_diag, ;    // 5
            k006->sy, ;    // 6
            k006->age, ;   // 7
            k006->sex, ;   // 8
            k006->los, ;   // 9
            k006->ad_cr, ; // 10
            sds1, ;        // 11
            sds2, ;        // 12
            j, ;           // 13
            &lal.->kslps, ; // 14
            k006->ad_cr1 } ; // 15
          )
        endif
      Endif
      Select K006
      k006->( dbSkip() )  //  Skip
    Enddo
  Endif
  ar1 := {}
  If uslOkaz == USL_OK_DAY_HOSPITAL .and. !Empty( lad_cr ) .and. lad_cr == 'mgi'
    Select K006
    Locate For k006->ad_cr == PadR( 'mgi', 20 )
    If Found() // <CODE>ds19.033</CODE>
      lkoef := k006->kz
      dbSelectArea( lal )
      find ( PadR( k006->shifr, 10 ) )
      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      If fl
        sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // соп.диагноз
        sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // диагн.осложнения
        j := 1
        ar := {}
        if lk_data >= 0d20260101
          AAdd( ar1, { k006->shifr, ; // 1
            0, ;           // 2
            lkoef, ;       // 3
            &lal.->kiros, ; // 4
            k006->ds, ;    // 5
            lshifr, ;      // 6
            k006->age, ;   // 7
            k006->sex, ;   // 8
            k006->los, ;   // 9
            k006->ad_cr, ; // 10
            sds1, ;        // 11
            sds2, ;        // 12
            j, ;           // 13
            &lal.->kslps, ; // 14
            k006->ad_cr1, ; // 15
            &lal.->kslps } ; // 16
          )
        else
          AAdd( ar1, { k006->shifr, ; // 1
            0, ;           // 2
            lkoef, ;       // 3
            &lal.->kiros, ; // 4
            k006->ds, ;    // 5
            lshifr, ;      // 6
            k006->age, ;   // 7
            k006->sex, ;   // 8
            k006->los, ;   // 9
            k006->ad_cr, ; // 10
            sds1, ;        // 11
            sds2, ;        // 12
            j, ;           // 13
            &lal.->kslps, ; // 14
            k006->ad_cr1 } ; // 15
          )
        endif
      Endif
    Endif
  Endif
  If Len( ar ) > 0
    For i := 1 To Len( tmp )
      im := tmp[ i ]
      amohu[ im ] := '' // очистить, чтобы не включать в хирургическую КСГ
    Next
    For i := 1 To Len( ar )
      ar[ i, 2 ] := ret_cena_ksg( ar[ i, 1 ], lvr, date_usl )
      If ar[ i, 2 ] > 0
        fl_cena := .t.
      Endif
    Next
    aTerKSG := AClone( ar )
    If Len( aTerKSG ) > 1
      ASort( aTerKSG, , , {| x, y| iif( x[ 13 ] == y[ 13 ], x[ 3 ] > y[ 3 ], x[ 13 ] > y[ 13 ] ) } )
    Endif
    /*aadd(ars, '   ║КСГ: ' +print_array(aTerKSG[1]))
    for j := 2 to len(aTerKSG)
      aadd(ars, '   ║     ' +print_array(aTerKSG[j]))
    next*/
    If ( kol_ter := f_put_debug_ksg( 0, aTerKSG, ars ) ) > 1
      AAdd( ars, ' └─> выбираем КСГ=' + RTrim( aTerKSG[ 1, 1 ] ) + ' [КЗ=' + lstr( aTerKSG[ 1, 3 ] ) + ']' )
    Endif
  Endif
  // собираем КСГ по манипуляциям (хирургические и комбинированные)
  ar := ar1
  ar_crit := {}
  ar_crit1 := {}
  arr_ad_criteria := getAdditionalCriteria( lk_data )  // загрузим доп. критерии на дату

  For im := 1 To Len( amohu )
    If !Empty( lshifr := AllTrim( amohu[ im ] ) )
      _a1 := {}
      Select K006
      Set Order To 2
      find ( typeKSG + PadR( lshifr, 20 ) )
      Do While Left( k006->shifr, 2 ) == typeKSG .and. k006->sy == PadR( lshifr, 20 ) .and. ! k006->( Eof() )
        lkoef := k006->kz
        dbSelectArea( lal )
        find ( PadR( k006->shifr, 10 ) )
        fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
        If fl
          fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
        Endif
        If fl
          sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // соп.диагноз
          sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // диагн.осложнения
        Endif
        j := 0
        If fl .and. !Empty( k006->ds )
          fl := ( k006->ds == osn_diag )
          If fl
            j += 10
          Endif
        Endif
        If fl .and. !Empty( k006->age )
          If ( fl := ( k006->age $ lage ) )
            If k006->age == '1'
              j += 5
            Elseif k006->age == '2'
              j += 4
            Elseif k006->age == '3'
              j += 3
            Elseif k006->age == '4'
              j += 2
            Else
              j++
            Endif
          Endif
        Endif
        If fl .and. !Empty( k006->sex )
          fl := ( k006->sex == lsex )
          If fl
            j++
          Endif
        Endif
        If fl .and. !Empty( k006->los )
          fl := AScan( llos, AllTrim( k006->los ) ) > 0  // (k006->los $ llos)
          If fl
            j++
          Endif
        Endif
        If fl .and. !Empty( k006->ad_cr )  // в справочнике есть доп.критерий
          two_letters := lower( substr( lshifr, 1, 2 ) )
          fl := .f.
          If !Empty( lad_cr )        // в случае есть доп.критерий
            fl := ( lad_cr == AllTrim( k006->ad_cr ) ) .or. ! eq_any( two_letters, 'st', 'ds' )
            If fl
              j++
            Endif
          else  // add 01.11.25
            fl := .t.  // add 01.11.25
            j++  // add 01.11.25
          Endif
        Endif
        If fl .and. !Empty( k006->ad_cr1 )  // в справочнике есть доп.критерий2
          fl := .f.
          If !Empty( lad_cr1 )        // в случае есть доп.критерий2
            fl := ( lad_cr1 == AllTrim( k006->ad_cr1 ) )
            If fl
              j++
            Endif
          Endif
        Endif
        If fl .and. !Empty( sds1 )
          fl := .f.
          For i := 1 To Len( sop_diag )
            If AllTrim( sop_diag[ i ] ) $ sds1
              fl := .t.
              Exit
            Endif
          Next
          If fl
            j++
          Endif
        Endif
        If fl .and. !Empty( sds2 )
          fl := .f.
          For i := 1 To Len( osl_diag )
            If AllTrim( osl_diag[ i ] ) $ sds2
              fl := .t.
              Exit
            Endif
          Next
          If fl
            j++
          Endif
        Endif
        If fl
          if lk_data >= 0d20260101
            AAdd( _a1, { k006->shifr, ; // 1
              0, ;           // 2
              lkoef, ;       // 3
              &lal.->kiros, ; // 4
              k006->ds, ;    // 5
              lshifr, ;      // 6
              k006->age, ;   // 7
              k006->sex, ;   // 8
              k006->los, ;   // 9
              k006->ad_cr, ; // 10
              sds1, ;        // 11
              sds2, ;        // 12
              j, ;           // 13
              &lal.->kslps, ; // 14
              k006->ad_cr1, ; // 15
              &lal.->kslps } ) // 16
          else
            AAdd( _a1, { k006->shifr, ; // 1
              0, ;           // 2
              lkoef, ;       // 3
              &lal.->kiros, ; // 4
              k006->ds, ;    // 5
              lshifr, ;      // 6
              k006->age, ;   // 7
              k006->sex, ;   // 8
              k006->los, ;   // 9
              k006->ad_cr, ; // 10
              sds1, ;        // 11
              sds2, ;        // 12
              j, ;           // 13
              &lal.->kslps, ; // 14
              k006->ad_cr1 } ) // 15
          endif
          if Empty( k006->ad_cr )
            AAdd( ar_crit, { '', '--нет критерия--' } )
            AAdd( ar_crit1, '--нет критерия--' )
          else
            c_crit := AllTrim( k006->ad_cr )
            if ( icrit := AScan( arr_ad_criteria, {| x | AllTrim( x[ 2 ] ) == c_crit } ) ) > 0
              AAdd( ar_crit, { c_crit, c_crit + ' ' + arr_ad_criteria[ icrit, 6 ] } )
              AAdd( ar_crit1, c_crit + ' ' + arr_ad_criteria[ icrit, 6 ] )
            endif
          endif
        Endif
        Select K006
        k006->( dbSkip() )  //  Skip
      Enddo
      If Len( _a1 ) > 1 // если по данной услуге более одной КСГ, сортируем по убыванию критериев
        If __mvExist( 'mshifr' ) .and. ! HB_ISNIL( mshifr )
          if  AllTrim( mshifr ) == AllTrim( lshifr ) .and. ;
              Upper( ProcName( 1 ) ) == Upper( 'f_usl_definition_KSG' ) .and. ;
              Upper( ProcName( 2 ) ) == Upper( 'f2oms_usl_sluch' )
            oBox := NIL // уничтожим окно
            oBox := TBox():New( 2, 10, 22, 70 )
            oBox:Color := color_say + ',' + color_get
            oBox:Frame := BORDER_SINGLE
            oBox:MessageLine := '^<Esc>^ - выход;  ^<Enter>^ - выбор'
            oBox:Save := .t.
  
            oBox:Caption := 'Выбор дополнительного критерия'
            oBox:View()
            if ( icrit := AChoice( oBox:Top + 1, oBox:Left + 1, oBox:Bottom - 1, oBox:Right - 1, ar_crit1 ) ) > 0
              AAdd( ar, AClone( _a1[ icrit ] ) )
            endif
            oBox := nil
          endif
//        elseif Upper( ProcName( 1 ) ) == Upper( 'f_1pac_definition_KSG' ) .and. ;
//            Upper( ProcName( 2 ) ) == Upper( 'oms_sluch_main' )
//          if ( icrit := AScan( _a1, {| x | AllTrim( x[ 10 ] ) == AllTrim( human_2->PC3 ) } ) ) > 0
//            AAdd( ar, AClone( _a1[ icrit ] ) )
//          endif
        elseif ( Upper( ProcName( 1 ) ) == Upper( 'f_usl_definition_KSG' ) .and. ;
            Upper( ProcName( 2 ) ) == Upper( 'oms_usl_sluch' ) ) .or. ;
              ;
            ( Upper( ProcName( 1 ) ) == Upper( 'f_1pac_definition_KSG' ) .and. ;
            Upper( ProcName( 2 ) ) == Upper( 'oms_sluch_main' ) ) .or. ;
              ;
            ( Upper( ProcName( 1 ) ) == Upper( 'verify_sluch' ) .and. ! Empty( human_2->PC3 ) )

          if ( icrit := AScan( _a1, {| x | AllTrim( x[ 10 ] ) == AllTrim( human_2->PC3 ) } ) ) > 0
            AAdd( ar, AClone( _a1[ icrit ] ) )
          endif
//        elseif Upper( ProcName( 1 ) ) == Upper( 'verify_sluch' ) .and. ! Empty( human_2->PC3 )
//          if ( icrit := AScan( _a1, {| x | AllTrim( x[ 10 ] ) == AllTrim( human_2->PC3 ) } ) ) > 0
//              AAdd( ar, AClone( _a1[ icrit ] ) )
//          endif
        endif
//        ASort( _a1, , , {| x, y| iif( x[ 13 ] == y[ 13 ], x[ 3 ] > y[ 3 ], x[ 13 ] > y[ 13 ] ) } )
      elseif Len( _a1 ) == 1
        AAdd( ar, AClone( _a1[ 1 ] ) )
      Endif
//      If Len( _a1 ) > 0
//        AAdd( ar, AClone( _a1[ 1 ] ) )
//      Endif
    Endif
  Next
  If Len( ar ) > 0
    For i := 1 To Len( ar )
      ar[ i, 2 ] := ret_cena_ksg( ar[ i, 1 ], lvr, date_usl )
      If ar[ i, 2 ] > 0
        fl_cena := .t.
      Endif
      if ! empty( ar[ i, 10 ] ) // add 01.11.25
        lad_cr := ar[ i, 10 ]   // add 01.11.25
        m1ad_cr := ar[ i, 10 ]   // add 01.11.25
        input_ad_cr := .t.   // add 01.11.25

        human_2->( RLock() )
        human_2->PC3 := iif( input_ad_cr, m1ad_cr, '' ) 
        human_2->( dbUnlock() )

      endif                     // add 01.11.25
    Next
    aHirKSG := AClone( ar )
    If Len( aHirKSG ) > 1
      ASort( aHirKSG, , , {| x, y| iif( x[ 3 ] == y[ 3 ], x[ 13 ] > y[ 13 ], x[ 3 ] > y[ 3 ] ) } )
    Endif
    /*aadd(ars, '   ║КСГ: ' +print_array(aHirKSG[1]))
    for j := 2 to len(aHirKSG)
      aadd(ars, '   ║     ' +print_array(aHirKSG[j]))
    next*/
    If ( kol_hir := f_put_debug_ksg( 0, aHirKSG, ars ) ) > 1
      AAdd( ars, ' └─> выбираем КСГ=' + RTrim( aHirKSG[ 1, 1 ] ) + ' [КЗ=' + lstr( aHirKSG[ 1, 3 ] ) + ']' )
    Endif
  Endif
  If kol_ter > 0 .and. kol_hir > 0
    aTerKSG[ 1, 1 ] := AllTrim( aTerKSG[ 1, 1 ] )
    aHirKSG[ 1, 1 ] := AllTrim( aHirKSG[ 1, 1 ] )
    // i := int(val(substr(aTerKSG[1,1],2,3)))
    // j := int(val(substr(aHirKSG[1,1],2,3)))
    If !Empty( aTerKSG[ 1, 6 ] ) // т.е. диагноз + услуга
      lksg  := aTerKSG[ 1, 1 ]
      lcena := aTerKSG[ 1, 2 ]
      lkiro := list2arr( aTerKSG[ 1, 4 ] )
      lkslp := aTerKSG[ 1, 14 ]
      AAdd( ars, ' выбираем КСГ=' + lksg + ' (осн.диагноз+услуга ' + RTrim( aTerKSG[ 1, 6 ] ) + ')' )
      // elseif ascan(a_iskl_1, {|x| x[1]==j .and. eq_any(x[2],0,i) .and. uslOkaz==x[3] }) > 0 // исключение из правил №1
    Elseif AScan( a_iskl_1, {| x| x[ 1 ] == aHirKSG[ 1, 1 ] .and. ( Empty( x[ 2 ] ) .or. x[ 2 ] == aTerKSG[ 1, 1 ] ) } ) > 0 // исключение из правил №1
      lksg  := aHirKSG[ 1, 1 ]
      lcena := aHirKSG[ 1, 2 ]
      lkiro := list2arr( aHirKSG[ 1, 4 ] )
      lkslp := aHirKSG[ 1, 14 ]
      AAdd( ars, ' в соответствии с ИНСТРУКЦИЕЙ по КСГ выбираем ' + aHirKSG[ 1, 1 ] + ' вместо ' + aTerKSG[ 1, 1 ] )
    Else
      If aTerKSG[ 1, 3 ] > aHirKSG[ 1, 3 ] // 'если хирур.КЗ меньше терапевтического КЗ'
        lksg  := aTerKSG[ 1, 1 ]
        lcena := aTerKSG[ 1, 2 ]
        lkiro := list2arr( aTerKSG[ 1, 4 ] )
        lkslp := aTerKSG[ 1, 14 ]
        AAdd( ars, ' выбираем КСГ =' + aTerKSG[ 1, 1 ] + ' с БОЛЬШИМ коэффициентом затратоёмкости ' + lstr( aTerKSG[ 1, 3 ] ) )
      Else
        lksg  := aHirKSG[ 1, 1 ]
        lcena := aHirKSG[ 1, 2 ]
        lkiro := list2arr( aHirKSG[ 1, 4 ] )
        lkslp := aHirKSG[ 1, 14 ]
        AAdd( ars, ' оставляем КСГ=' + aHirKSG[ 1, 1 ] + ' с коэффициентом затратоёмкости ' + lstr( aHirKSG[ 1, 3 ] ) )
      Endif
    Endif
  Elseif kol_ter > 0
    aTerKSG[ 1, 1 ] := AllTrim( aTerKSG[ 1, 1 ] )
    lksg  := aTerKSG[ 1, 1 ]
    lcena := aTerKSG[ 1, 2 ]
    lkiro := list2arr( aTerKSG[ 1, 4 ] )
    lkslp := aTerKSG[ 1, 14 ]
    if lk_data >= 0d20260101
      ltype_ksg := aTerKSG[ 1, 16 ]
    endif
  Elseif kol_hir > 0
    aHirKSG[ 1, 1 ] := AllTrim( aHirKSG[ 1, 1 ] )
    lksg  := aHirKSG[ 1, 1 ]
    lcena := aHirKSG[ 1, 2 ]
    lkiro := list2arr( aHirKSG[ 1, 4 ] )
    lkslp := aHirKSG[ 1, 14 ]
    if lk_data >= 0d20260101
      ltype_ksg := aHirKSG[ 1, 16 ]
    endif
  Endif
  akslp := {}
  akiro := {}
  If lksg == 'ds18.001' .and. s_dializ > 0
    lksg := ''
  Endif
  If !Empty( lksg )
    strSoob := ' РЕЗУЛЬТАТ: выбрана КСГ = ' + lksg
    If Empty( lcena )
      strSoob += ', но не определена цена в справочнике ТФОМС'
      AAdd( arerr, strSoob )
    Else
      strSoob += ', цена ' + lstr( lcena, 11, 0 ) + 'р. '
      AAdd( ars, strSoob )
      strSoob := ''
      If lksg == 'st38.001' .and. lbartell == '61' // Старческая астения (это правило уже устарело и не применяется)
        lkslp := ''                                // т.к. у данной КСГ нет КСЛП
      Endif

      // 06.02.21
      If ( Year( lk_data ) >= 2021 ) .and. ( Lower( SubStr( lksg, 1, 2 ) ) == 'st' .or. Lower( SubStr( lksg, 1, 2 ) ) == 'ds' )
        If !Empty( HUMAN_2->PC1 )
          humKSLP := HUMAN_2->PC1
        Endif
        // Изощрение в порнографии
        // if Upper(ProcName(1)) == Upper('f_1pac_definition_KSG') .and. ! empty(lkslp)
        If Upper( ProcName( 1 ) ) == Upper( 'f_1pac_definition_KSG' )
          If ! Empty( lkslp )   // 24.02.21
            lkslp := selectkslp( lkslp, humKSLP, ln_data, lk_data, ldate_r, mdiagnoz )
          Endif
          // запомним КСЛП
          tmpSelect := Select( 'HUMAN_2' )
          If ( tmpSelect )->( dbRLock() )
            // G_RLock(forever)
            // HUMAN_2->PC1 := m1KSLP
            HUMAN_2->PC1 := lkslp
            ( tmpSelect )->( dbRUnlock() )
          Endif
          Select( tmpSelect )
        Else
          lkslp := humKSLP
        Endif
      Endif

      // lkslp - содержит список допустимых КСЛП
      akslp := f_cena_kslp( @lcena, ;
        lksg, ;
        ldate_r, ;
        ln_data, ;
        lk_data, ;
        lkslp, ;
        amohu, ;
        lprofil_k, ;
        mdiagnoz, ;
        lpar_org, ;
        lad_cr, ;
        uslOkaz )
      If Year( lk_data ) >= 2021  // added 29.01.21
        If !Empty( akslp )
          For iKSLP := 1 To Len( akslp ) Step 2
            If iKSLP != 1
              newKSLP += ', '
            Endif
            newKSLP += Str( akslp[ iKSLP ] ) // построим новый КСЛП
          Next
        Else
          newKSLP := ''
        Endif
        tmpSelect := Select( 'HUMAN_2' )
        If ( tmpSelect )->( dbRLock() )
          human_2->pc1 := newKSLP
        Endif
        ( tmpSelect )->( dbRUnlock() )
      Endif
      If !Empty( akslp )
        // 05.02.21
        strSoob += '  (КСЛП = '
        For iKSLP := 1 To Len( akslp ) Step 2
          If iKSLP != 1
            strSoob += ' + '
          Endif
          strSoob += Str( akslp[ iKSLP + 1 ], 4, 2 )
        Next
        strSoob += ', цена ' + lstr( lcena, 11, 0 ) + 'р.)'
      Endif
      If !Empty( lkiro )
        vkiro := defenition_kiro( lkiro, ldnej, lrslt, lis_err, lksg, lDoubleSluch, lk_data )

        If ( vkiro > 0 .and. lk_data < 0d20260101 ) .or. ( lk_data >= 0d20260101 )
          akiro := f_cena_kiro( @lcena, vkiro, lk_data, lrslt, ltype_ksg )
          strSoob += '  (КИРО = ' + Str( akiro[ 2 ], 4, 2 ) + ', цена ' + lstr( lcena, 11, 0 ) + 'р.)'
        Endif
      Endif
      If !Empty( strSoob )
        AAdd( ars, strSoob )
      Endif
    Endif
  Else
    If uslOkaz == USL_OK_DAY_HOSPITAL .and. s_dializ > 0
      Return { {}, {}, '', 0, {}, {}, s_dializ }
    Else
      AAdd( arerr, ' РЕЗУЛЬТАТ: не получилось выбрать КСГ' + iif( fl_reabil, ' для случая медицинской реабилитации', '' ) )
    Endif
  Endif

  Return { ars, arerr, AllTrim( lksg ), lcena, akslp, akiro, s_dializ }
// 1     2        3            4      5      6        7
