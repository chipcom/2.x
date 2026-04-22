#include 'function.ch'
#include 'tbox.ch'
#include 'common.ch'
#include 'chip_mo.ch'
#include 'edit_spr.ch'

// 22.04.26 определение КСГ 2026 год
Function definition_ksg( par, k_data2, lDoubleSluch )  // исправить на defenition_ksg_2026

  // файлы 'human', 'human_' и 'human_2' открыты и стоят на нужной записи
  // 'human' открыт для записи суммы случая
  // выполнено use_base('human_u', 'HU') - для записи
  // выполнено use_base('mo_hu', 'MOHU') - для записи

  Static ver_year := 0 // последний проверяемый год
  Static sp0, sp1, sp6, sp15

  local ars := {}, arerr := {}, akslp := {}, akiro := {}
  local s_dializ := 0, lksg := '', lcena := 0
  // данные из листа учета
  local lfio, ldate_r, lpol, lvr, lsex
  local ln_data, lk_data, lprofil, lprofil_k, lrslt
  local lvmp, lvidvmp := 0  // для ВМП
  Local lad_cr := '', lad_cr1 := '', llos // доп. критерии
  local mdiagnoz, osn_diag := Space( 6 ), sop_diag := {}, osl_diag := {}
  local lis_err := 0, strSoob
  local uslOkaz         // условия оказания (стационар, дневной стационар м т.д.)
  local lal, lalf, lshifr, lage
  local ahu := {}, amohu := {}, lpar_org := 0
  local typeKSG  // тип КСГ ( st или ds )
  local fl, fl_cena := .f., fl_reabil
  local lyear, lbartell := '', ldni, ldnej := 0, y := 0, m := 0, d := 0, nfile, ar_ksg, ar1, lkoef, tmp
  local sds1, sds2
  local i, j, im
  local date_usl := SToD( '20210101' )


/*
  local _a1, ar_crit, ar_crit1
  local c_crit, icrit
  local arr_ad_criteria
  Local aHirKSG := {}, aTerKSG := {}, lstentvmp := 0, ;
    cenaTer := 0, cenaHir := 0, ;
    ;
    kol_ter := 0, kol_hir := 0, lkiro := 0, lkslp := '', ;
*/
  Default par To 1, sp0 To '', sp1 To Space( 1 ), sp6 To Space( 6 ), sp15 To Space( 20 )
  Default lDoubleSluch To .f.

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
      onksl->( dbSeek( Str( human->kod, 7 ) ) )
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
  date_usl := lk_data   // установить дату услуги на конец лечения
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
    hu->( dbSeek( Str( human->kod, 7 ) ) )
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
      hu->( dbSkip() )
    Enddo
    If Select( 'MOSU' ) == 0
      r_use( dir_server() + 'mo_su', , 'MOSU' )
    Endif
    Select MOHU
    mohu->( dbSeek( Str( human->kod, 7 ) ) )
    Do While mohu->kod == human->kod .and. ! mohu->( Eof() )
      If mosu->( RecNo() ) != mohu->u_kod
        mosu->( dbGoto( mohu->u_kod ) )
      Endif
      If AScan( amohu, mosu->shifr1 ) == 0
        AAdd( amohu, mosu->shifr1 )
      Endif
      dbSelectArea( lalf )
      ( lalf )->( dbSeek( PadR( mosu->shifr1, 20 ) ) )
      If Found() .and. !Empty( &lalf.->par_org )
        lpar_org += Len( list2arr( mohu->zf ) )
      Endif
      Select MOHU
      mohu->( dbSkip() )
    Enddo
  Else
    Select IHU
    ihu->( dbSeek( Str( ihuman->kod, 10 ) ) )
    Do While ihu->kod == ihuman->kod .and. !Eof()
      If eq_any( Left( ihu->CODE_USL, 1 ), 'A', 'B' )
        If AScan( amohu, ihu->CODE_USL ) == 0
          AAdd( amohu, ihu->CODE_USL )
        Endif
        dbSelectArea( lalf )
        ( lalf )->( dbSeek( PadR( ihu->CODE_USL, 20 ) ) )
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
      ihu->( dbSkip() )
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

  llos := {}

  AAdd( llos, code_duration_K006( lk_data, ldnej ) )

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
  ar_ksg := {}
  tmp := {}
  Select K006

  If lprofil != 137   // не ЭКО
    Set Order To 1
    k006->( dbSeek( typeKSG + PadR( osn_diag, 6 ) ) )
    Do While Left( k006->shifr, 2 ) == typeKSG .and. k006->ds == PadR( osn_diag, 6 ) .and. ! k006->( Eof() )
      lkoef := k006->kz
      dbSelectArea( lal )
      ( lal )->( dbSeek( PadR( k006->shifr, 10 ) ) )
//      fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      fl := lkoef > 0 .and. between_date( ( lal )->DATEBEG, ( lal )->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      If fl
        sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // соп.диагноз
        sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // диагн.осложнения
      Endif
      j := 0

      // проверим наличие федеральной услуги
      If fl .and. !Empty( k006->sy )
        If ( i := AScan( amohu, k006->sy ) ) > 0
          j += 10
        Else
          fl := .f.
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
        add_KSG_table( ar_ksg, lk_data, lal, osn_diag, j, sds1, sds2, lvr, ldnej, lrslt, lDoubleSluch )
      Endif
      Select K006
      k006->( dbSkip() )
    Enddo
  else  // ЭКО
    Set Order To 3
    K006->( dbGoTop() )
    K006->( dbSeek( Lower( lad_cr ) ) )
    Do While Lower( AllTrim( K006->AD_CR ) ) == Lower( AllTrim( lad_cr ) ) .and. !( 'K006' )->( Eof() )
      lkoef := k006->kz
      dbSelectArea( lal )
      ( lal )->( dbSeek( PadR( k006->shifr, 10 ) ) )
      if ( lal )->( Found() )
//        fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
        fl := k006->kz > 0 .and. between_date( ( lal )->DATEBEG, ( lal )->DATEEND, date_usl )
        If fl
          fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
        Endif
        j := 0
        j++
        j++
        If fl
          add_KSG_table( ar_ksg, lk_data, lal, osn_diag, j, '', '', lvr, ldnej, lrslt, lDoubleSluch )
        Endif
      Endif
      K006->( dbSkip() )
    Enddo
  endif

  ar1 := {}
  If uslOkaz == USL_OK_DAY_HOSPITAL .and. !Empty( lad_cr ) .and. lad_cr == 'mgi'
    Select K006
    Locate For k006->ad_cr == PadR( 'mgi', 20 )
    If Found() // <CODE>ds19.033</CODE>
      lkoef := k006->kz
      dbSelectArea( lal )
      ( lal )->( dbSeek( PadR( k006->shifr, 10 ) ) )
//        fl := lkoef > 0 .and. between_date( &lal.->DATEBEG, &lal.->DATEEND, date_usl )
      fl := k006->kz > 0 .and. between_date( ( lal )->DATEBEG, ( lal )->DATEEND, date_usl )
      If fl
        fl := between_date( k006->DATEBEG, k006->DATEEND, date_usl )
      Endif
      If fl
        sds1 := iif( Empty( k006->ds1 ), sp0, AllTrim( k006->ds1 ) + sp6 ) // соп.диагноз
        sds2 := iif( Empty( k006->ds2 ), sp0, AllTrim( k006->ds2 ) + sp6 ) // диагн.осложнения
        j := 1
        ar_ksg := {}
        add_KSG_table( ar1, lk_data, lal, osn_diag, j, sds1, sds2, lvr, ldnej, lrslt, lDoubleSluch )
      Endif
    Endif
  Endif

  If Len( ar_ksg ) > 0
    For i := 1 To Len( tmp )
      im := tmp[ i ]
      amohu[ im ] := '' // очистить, чтобы не включать в хирургическую КСГ
    Next
/*
    For i := 1 To Len( ar_ksg ) 
      ar_ksg[ i, 2 ] := ret_cena_ksg( ar_ksg[ i, 1 ], lvr, date_usl )
      If ar_ksg[ i, 2 ] > 0
        fl_cena := .t.
      Endif
    Next
*/
//    aTerKSG := AClone( ar_ksg )
//    If Len( aTerKSG ) > 1
//      ASort( aTerKSG, , , {| x, y| iif( x[ 13 ] == y[ 13 ], x[ 3 ] > y[ 3 ], x[ 13 ] > y[ 13 ] ) } )
//    Endif
//    If ( kol_ter := f_put_debug_ksg( 0, aTerKSG, ars ) ) > 1
//      AAdd( ars, ' └─> выбираем КСГ=' + RTrim( aTerKSG[ 1, 1 ] ) + ' [КЗ=' + lstr( aTerKSG[ 1, 3 ] ) + ']' )
//    Endif
  Endif

altd()
  Return { ars, arerr, AllTrim( lksg ), lcena, akslp, akiro, s_dializ }
        //  1     2        3              4      5      6        7

// 22.04.26
function add_KSG_table( arr_KSG, mdate, lal, osn_diag, j, sds1, sds2, lvr, ldnej, lrslt, lDoubleSluch )

  local n_cena_oms
  local vkiro, akiro := {}

// определим цену КСГ с учетом КИРО
  n_cena_oms := ret_cena_ksg( k006->shifr, lvr, mdate )
  If ! Empty( ( lal )->kiros ) 
    vkiro := defenition_kiro( ( lal )->kiros, ldnej, lrslt, 0, k006->shifr, lDoubleSluch, mdate )
    If ( vkiro > 0 .and. mdate < 0d20260101 ) .or. ( mdate >= 0d20260101 )
      n_cena_oms := cena_with_kiro( n_cena_oms, vkiro, mdate, lrslt, ;
        iif( Year( mdate ) > 2025, ( lal )->TYPE_KSG, 0 ), akiro )
    Endif
  Endif

  default sds1 to '', sds2 to ''
  AAdd( arr_KSG, { ;
    k006->shifr, ;                // 1 шифр КСГ
    n_cena_oms, ;                 // 2 цена услуги в ОМС
    k006->kz, ;                   // 3 коэффициент затратоемкости
    AllTrim( ( lal )->kiros ), ;  // 4 список возможных КИРО
    osn_diag, ;                   // 5 основной диагноз
    k006->sy, ;                   // 6 Код услуги, соответствующий номенклатуре медицинских услуг V001. Если код услуги не участвует в правиле отнесения к КСГ, то передается ?пустой? тег.
    k006->age, ;                  // 7 Возрастная категория, в соответствии с которой проводится отнесение к КСГ. Если возраст не участвует в правиле отнесения к КСГ, то передается ?пустой? тег
    k006->sex, ;                  // 8 Пол, в соответствии с которым проводится отнесение к КСГ: 1- мужской, 2- женский. Если пол не участвует в правиле отнесения к КСГ, то передается ?пустой? тег
    k006->los, ;                  // 9 Длительность случая лечения. Если длительность случая не участвует в правиле, то передается ?пустой? тег.
    k006->ad_cr, ;                // 10 Код классификационного критерия в соответствии с ?Справочником дополнительных классификационных критериев? V024, за исключением показателя ?Количество фракций?, используемых при лучевой или химиолучевой терапии.
    sds1, ;                       // 11 Коды сопутствующих диагнозов по МКБ-10.
    sds2, ;                       // 12 Код диагнозов осложнений по МКБ10.
    j, ;                          // 13
    AllTrim( ( lal )->kslps ), ;  // 14 Список доступных КСЛП.
    k006->ad_cr1, ;               // 15 Иной классификационный критерий. Используется для передачи сведений о показателе ?Количество фракций? при лучевой или химиолучевой терапии.
    iif( Year( mdate ) > 2025, ( lal )->TYPE_KSG, 0 ), ;  // 16 тип КСГ ( 0 - терапевтическое, 1 - хирургическое ), до 26 года всегда 0
    lvr ;                         // 17 Взрослый - 0/ребенок - 1
  } ;
  )
//    0, ;                          // 2
//       &lal.->kiros, ; // 4
//       &lal.->kslps, ; // 14
//       &lal.->TYPE_KSG } ; // 16

  return arr_KSG