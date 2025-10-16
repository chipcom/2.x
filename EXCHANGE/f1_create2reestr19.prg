// реестры/счета с 2019 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// Static sadiag1

// 16.10.25 работаем по текущей записи
Function f1_create2reestr19( _nyear, p_tip_reestr )

  Local i, j, lst, s
  Local locPRVS
  local arr_not_zs, lc, lpods

  arr_not_zs := np_arr_not_zs( human->k_data )

  fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
  lshifr_zak_sl := lvidpoms := ''
  a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
  a_usl_name := {}
  atmpusl := {}
  akslp := {}
  akiro := {}
  tarif_zak_sl := human->cena_1
  kol_kd := 0
  is_KSG := is_mgi := .f.
  v_reabil_slux := 0
  m1veteran := 0
  m1mobilbr := 0  // мобильная бригада
  m1mesto_prov := 0
  m1p_otk := 0    // признак отказа
  m1dopo_na := 0
  m1napr_v_mo := 0
  arr_mo_spec := {}
  m1napr_stac := 0
  m1profil_stac := 0
  m1napr_reab := 0
  m1profil_kojki := 0
  pr_amb_reab := .f.
  fl_disp_nabl := .f.
  is_disp_DVN := .f.
  is_disp_DVN_COVID := .f.
  is_disp_DRZ := .f.
  ldate_next := CToD( '' )
  ar_dn := {}
  //
  is_oncology_smp := 0
  is_oncology := f_is_oncology( 1, @is_oncology_smp )
  If p_tip_reestr == 2
    is_oncology := 0
  Endif
  arr_onkna := {}
  Select ONKNA
  find ( Str( human->kod, 7 ) )
  Do While onkna->kod == human->kod .and. !Eof()
    P2TABN->( dbGoto( onkna->KOD_VR ) )
    If !( P2TABN->( Eof() ) ) .and. !( P2TABN->( Bof() ) )
      // aadd(arr_nazn, {3, i, P2TABN->snils, lstr(ret_prvs_V015toV021(P2TABN->PRVS_NEW))}) // теперь каждое назначение в отдельном PRESCRIPTIONS
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
    Else
      // aadd(arr_nazn, {3, i, '', ''}) // теперь каждое назначение в отдельном PRESCRIPTIONS
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, '', '' } )
    Endif

    // mosu->(dbGoto(onkna->U_KOD))
    // aadd(arr_onkna, {onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL,mosu->shifr1, onkna->NAPR_MO})
    Skip
  Enddo
  Select ONKCO
  find ( Str( human->kod, 7 ) )
  //
  Select ONKSL
  find ( Str( human->kod, 7 ) )
  //
  arr_onkdi := {}
  If eq_any( onksl->b_diag, 98, 99 ) 
    Select ONKDI
    find ( Str( human->kod, 7 ) )
    Do While onkdi->kod == human->kod .and. !Eof()
      AAdd( arr_onkdi, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
      Skip
    Enddo
  Endif
  //
  arr_onkpr := {}
  If human_->USL_OK < 3 // противопоказания по лечению только в стационаре и дневном стационаре
    Select ONKPR
    find ( Str( human->kod, 7 ) )
    Do While onkpr->kod == human->kod .and. !Eof()
      AAdd( arr_onkpr, { onkpr->PROT, onkpr->D_PROT } )
      Skip
    Enddo
  Endif
  If eq_any( onksl->b_diag, 0, 7, 8 ) .and. AScan( arr_onkpr, {| x| x[ 1 ] == onksl->b_diag } ) == 0
    // добавим отказ,не показано,противопоказано по гистологии
    AAdd( arr_onkpr, { onksl->b_diag, human->n_data } )
  Endif
  //
  arr_onk_usl := {}
  If iif( human_2->VMP == 1, .t., Between( onksl->DS1_T, 0, 2 ) )
    Select ONKUS
    find ( Str( human->kod, 7 ) )
    Do While onkus->kod == human->kod .and. !Eof()
      If Between( onkus->USL_TIP, 1, 5 )
        AAdd( arr_onk_usl, onkus->USL_TIP )
      Endif
      Skip
    Enddo
  Endif
  //
  Select HU
  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. !Eof()
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , @lst, , @s )
      lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
      If human_->USL_OK == 3 .and. is_usluga_disp_nabl( lshifr )
        ldate_next := c4tod( human->DATE_OPL )
        fl_disp_nabl := .t.
      Endif
      AAdd( atmpusl, lshifr )
      If eq_any( Left( lshifr, 5 ), '1.11.', '55.1.' )
        kol_kd += hu->kol_1
        is_KSG := .t.
      Elseif Left( lshifr, 5 ) == '2.89.'
        pr_amb_reab := .t.
      Elseif Left( lshifr, 5 ) == '60.9.'
        is_mgi := .t.
      Endif
      If !Empty( s ) .and. ',' $ s
        lvidpoms := s
      Endif
      // попытка правки
      If AllTrim( lshifr ) == '2.78.107'
        // терпевт + общая врачебная практика
        If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '76', '39' )
          lvidpoms := '12'
        Elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '25', '35', '41', '45', '46', ;
            '68', '71', '79', '84', '90', '92', '95' )
          lvidpoms := '13'
        Endif
        // фельдшер
        // lvidpoms := '11'
      Endif
      locPRVS := put_prvs_to_reestr( human_->PRVS, _NYEAR )
      If ( hu->stoim_1 > 0 .or. Left( lshifr, 3 ) == '71.' ) .and. ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
        lvidpom := i
        // для школ здоровья ХНИЗ
        if eq_any( lshifr, '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.8', '2.92.9', '2.92.10', '2.92.11', '2.92.12' )
          if eq_any( locPRVS, '76', '49' )  // тераипия, педиатрия
            lvidpom := 12
          elseif eq_any( lshifr, '2.92.4', '2.92.5', '2.92.9', '2.92.10', '2.92.11' ) .and. locPRVS == '39'   // общая врачебная практика (семейная медицина)
            lvidpom := 12
          else  // узкие специалисты
            lvidpom := 13
          endif
        endif
        // для комплексного посещения центров здоровья
        if eq_any( lshifr, '2.76.100', '2.76.101', '2.76.102' )
          if eq_any( locPRVS, '76', '39' )  // тераипия, общая врачебная практика (семейная медицина)
            lvidpom := 12
          else  // 206 - лечебное дело (средний мед. персонал)
            lvidpom := 11
          endif
        endif
      Endif
      If human_->USL_OK == 3
        If f_is_neotl_pom( lshifr )
          lfor_pom := 2 // неотложная
        Elseif eq_any( Left( lshifr, 5 ), '60.4.', '60.5.', '60.6.', '60.7.', '60.8.' )
          Select OTD
          dbGoto( human->otd )
          If FieldNum( 'TIP_OTD' ) > 0 .and. otd->TIP_OTD == 1  // отделение приёмного покоя стационара
            lfor_pom := 2 // неотложная
          Endif
        Endif
      Endif
      If lst == 1
        lshifr_zak_sl := lshifr
        If f_is_zak_sl_vr( lshifr ) // зак.случай в п-ке
          is_zak_sl_vr := .t.
        Else
          is_zak_sl_vr := .t. // КСГ
          If human_->USL_OK < 3 .and. p_tip_reestr == 1
            tarif_zak_sl := hu->STOIM_1
            If !Empty( human_2->pc1 )
              akslp := list2arr( human_2->pc1 )
            Endif
            If !Empty( human_2->pc2 )
              akiro := list2arr( human_2->pc2 )
            Endif
          Endif
          If !Empty( akslp ) .or. !Empty( akiro )
            otd->( dbGoto( human->OTD ) )
            f_put_glob_podr( human_->USL_OK, human->K_DATA ) // заполнить код подразделения
            if isnil( ksl_date )  // это не двойной случай
              tarif_zak_sl := fcena_oms( lshifr, ( human->vzros_reb == 0 ), human->k_data )
            else
              tarif_zak_sl := fcena_oms( lshifr, ( human->vzros_reb == 0 ), ksl_date )
            endif
          Endif
        Endif
      Else
        AAdd( a_usl, hu->( RecNo() ) )
        AAdd( a_usl_name, lshifr )
      Endif
    Endif
    Select HU
    Skip
  Enddo
  If human_->USL_OK == 1 .and. human_2->VMP == 1 .and. !emptyany( human_2->VIDVMP, human_2->METVMP ) // ВМП
    is_KSG := .f.
  Endif
  If !Empty( lvidpoms )
    If !eq_ascan( atmpusl, '55.1.2', '55.1.3' ) .or. glob_mo[ _MO_KOD_TFOMS ] == '801935' // ЭКО-Москва
      lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // только для дн.стационара при стационаре
    Elseif eq_ascan( atmpusl, '55.1.2' ) .and. glob_mo[ _MO_KOD_TFOMS ] == '805960'  // грязелечебница
      lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // только для дн.стационара при стационаре
    Else
      If eq_ascan( atmpusl, '55.1.3' )
        lvidpoms := ret_vidpom_st_dom_licensia( human_->USL_OK, lvidpoms, human_->profil )
      Endif
    Endif
    If !Empty( lvidpoms ) .and. !( ',' $ lvidpoms )
      lvidpom := Int( Val( lvidpoms ) )
      lvidpoms := ''
    Endif
  Endif
  If !Empty( lvidpoms )
    If eq_ascan( atmpusl, '55.1.1', '55.1.4' )
      If '31' $ lvidpoms
        lvidpom := 31
      Endif
    Elseif eq_ascan( atmpusl, '55.1.2', '55.1.3', '2.76.6', '2.76.7', '2.81.67' )
      If eq_any( human_->PROFIL, 57, 68, 97 ) // терапия,педиатр,врач общ.практики
        If '12' $ lvidpoms
          lvidpom := 12
        Endif
      Else
        If '13' $ lvidpoms
          lvidpom := 13
        Endif
      Endif
    Elseif eq_ascan( atmpusl, '2.78.109' )
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '39', '69', '71', '76', '95' )
        // врачи
        lvidpom := 12
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '35', ;
        '41', '45', '46', '79', '84', '90', '92' )
        // врачи специализированнные
        lvidpom := 13
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '206', '207' )
        // фельдшеры
        lvidpom := 11
      endif
    Elseif eq_ascan( atmpusl, '2.78.110' )
      // врачи специализированнные
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '9', '41' )
        lvidpom := 13
      endif
    Elseif eq_ascan( atmpusl, '2.78.111' )
      // врачи
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '39', '76', '95' )
        lvidpom := 12
      elseIf eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '92' )
        // врачи специализированнные
        lvidpom := 13
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '206' )
        // фельдшеры
        lvidpom := 11
      endif
    Elseif eq_ascan( atmpusl, '2.78.112' )
      // врачи
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '39', '76', '95' )
        lvidpom := 12
      elseIf eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '25' )
        // врачи специализированнные
        lvidpom := 13
      elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '206' )
        // фельдшеры
        lvidpom := 11
      endif
    Elseif eq_ascan( atmpusl, '2.78.107' )
      // терпевт + общая врачебная практика
      If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '76', '39' )
        lvidpom := 12
      Elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '25', '35', '41', '45', '46', ;
          '68', '71', '79', '84', '90', '92', '95' )
        lvidpom := 13
      Endif
      // фельдшер
      // lvidpoms := '11'
    Endif
  Endif
  Select MOHU
  find ( Str( human->kod, 7 ) )
  Do While mohu->kod == human->kod .and. !Eof()
    AAdd( a_fusl, mohu->( RecNo() ) )
    Skip
  Enddo
  a_otkaz := {}
  arr_nazn := {}
  If eq_any( human->ishod, 101, 102 ) // дисп-ия детей-сирот
    read_arr_dds( human->kod, human->K_DATA )
  Elseif eq_any( human->ishod, 301, 302 ) // профосмотры несовершеннолетних
    arr_usl_otkaz := {}
    read_arr_pn( human->kod, .t., human->K_DATA )
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) > 9 .and. ValType( ar[ 5 ] ) == 'C' .and. ;
            ValType( ar[ 10 ] ) == 'C' .and. ar[ 10 ] $ 'io'
          lshifr := AllTrim( ar[ 5 ] )
          ldate := human->N_DATA // дата
          If ValType( ar[ 9 ] ) == 'D'
            ldate := ar[ 9 ]
          Endif
          If ar[ 10 ] == 'i' // исследования
            if human->k_data >= 0d20250901
              lc := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } )
              if lc > 0
                lpods := arr_not_zs[ lc, 1 ]
              else
                lpods := lshifr
              endif
            endif
//            If ( i := AScan( np_arr_issled( human->k_data ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0
            If ( i := AScan( np_arr_issled( human->k_data ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lpods } ) ) > 0
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
                ldate, ; // дата
                correct_profil( ar[ 4 ] ), ; // профиль
                ar[ 2 ], ; // специальность
                0, ;     // цена
                1 } )     // 1-отказ, 2-невозможность
            Endif
          elseIf ar[ 10 ] == 'o' // осмотры
//          Elseif ( i := AScan( np_arr_osmotr( human->k_data, m1mobilbr ), {| x| ValType( x[ 1 ] ) == 'C' .and. x[ 1 ] == lshifr } ) ) > 0 // осмотры
            if human->k_data >= 0d20250901
              lc := AScan( arr_not_zs, {| x| x[ 2 ] == lshifr } )
              if lc > 0
                lpods := arr_not_zs[ lc, 1 ]
              else
                lpods := lshifr
              endif
            else
              If ( i := AScan( np_arr_osmotr_KDP2(), {| x| x[ 1 ] == lshifr } ) ) > 0
                lshifr := np_arr_osmotr_KDP2()[ i, 3 ]  // замена врачебного приёма на 2.3.*
              Endif
            endif
            AAdd( a_otkaz, { lshifr, ;
              ar[ 6 ], ; // диагноз
              ldate, ; // дата
              correct_profil( ar[ 4 ] ), ; // профиль
              ar[ 2 ], ; // специальность
              0, ;     // цена
              1 } )     // 1-отказ, 2-невозможность
          Endif
        Endif
      Next j
    Endif
  Elseif Between( human->ishod, 201, 205 ) // дисп-ия I этап или профилактика
    is_disp_DVN := .t.
    arr_usl_otkaz := {}
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      &pole_diag := Space( 6 )
      &pole_1dispans := 0
      &pole_dn_dispans := CToD( '' )
    Next
    read_arr_dvn( human->kod )
    If ValType( arr_usl_otkaz ) == 'A' .and. eq_any( human->ishod, 201, 203 ) // не II этап
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          If ( i := AScan( dvn_arr_usl, {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
                human->N_DATA, ; // дата
                correct_profil( ar[ 4 ] ), ; // профиль
                ar[ 2 ], ; // специальность
                ar[ 8 ], ; // цена
                ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
  // Elseif Between( human->ishod, 401, 402 ) // углубленная диспансеризация после COVID
  Elseif is_sluch_dispanser_COVID( human->ishod ) // углубленная диспансеризация после COVID
    is_disp_DVN_COVID := .t.
    arr_usl_otkaz := {}
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      &pole_diag := Space( 6 )
      &pole_1dispans := 0
      &pole_dn_dispans := CToD( '' )
    Next
    read_arr_dvn_covid( human->kod )
    If ValType( arr_usl_otkaz ) == 'A'
      For j := 1 To Len( arr_usl_otkaz )
        ar := arr_usl_otkaz[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )
          If ( i := AScan( uslugietap_dvn_covid( iif( human->ishod == 401, 1, 2 ) ), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
          Else   // записываем только федеральные услуги
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
                human->N_DATA, ; // дата
                correct_profil( ar[ 4 ] ), ; // профиль
                ar[ 2 ], ; // специальность
                ar[ 8 ], ; // цена
                ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
  // elseif Between( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 ) // диспансеризации репродуктивного здоровья
  elseif is_sluch_dispanser_DRZ( human->ishod ) // диспансеризации репродуктивного здоровья
    is_disp_DRZ := .t.
    arr_usl_otkaz := {}
    arr_ne_nazn := {}
    arr_ne_vozm := {}
    For i := 1 To 5
      sk := lstr( i )
      pole_diag := 'mdiag' + sk
      pole_1dispans := 'm1dispans' + sk
      pole_dn_dispans := 'mdndispans' + sk
      &pole_diag := Space( 6 )
      &pole_1dispans := 0
      &pole_dn_dispans := CToD( '' )
    Next
    read_arr_drz( human->kod )
    // не понятно что делать с неназначенными услугами
    If ValType( arr_ne_nazn ) == 'A'
      For j := 1 To Len( arr_ne_nazn )
        ar := arr_ne_nazn[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )

          If ( i := AScan( uslugietap_drz( iif( human->ishod == BASE_ISHOD_RZD + 1, 1, 2 ), count_years( human->DATE_R, human->k_data ), human->pol ), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
//            
          Else   // записываем только федеральные услуги
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
                human->N_DATA, ; // дата
                correct_profil( ar[ 4 ] ), ; // профиль
                ar[ 2 ], ; // специальность
                ar[ 8 ], ; // цена
                ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
    If ValType( arr_ne_vozm ) == 'A'
      For j := 1 To Len( arr_ne_vozm )
        ar := arr_ne_vozm[ j ]
        If ValType( ar ) == 'A' .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == 'C'
          lshifr := AllTrim( ar[ 5 ] )

          If ( i := AScan( uslugietap_drz( iif( human->ishod == BASE_ISHOD_RZD + 1, 1, 2 ), count_years( human->DATE_R, human->k_data ), human->pol ), {| x| ValType( x[ 2 ] ) == 'C' .and. x[ 2 ] == lshifr } ) ) > 0
//            
          Else   // записываем только федеральные услуги
            If ValType( ar[ 10 ] ) == 'N' .and. Between( ar[ 10 ], 1, 2 )
              AAdd( a_otkaz, { lshifr, ;
                ar[ 6 ], ; // диагноз
                human->N_DATA, ; // дата
                correct_profil( ar[ 4 ] ), ; // профиль
                ar[ 2 ], ; // специальность
                ar[ 8 ], ; // цена
                ar[ 10 ] } ) // 1-отказ, 2-невозможность
            Endif
          Endif
        Endif
      Next j
    Endif
  Endif
  If m1dopo_na > 0
    For i := 1 To 4
      If IsBit( m1dopo_na, i )
        If mtab_v_dopo_na != 0
          If P2TABN->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
            AAdd( arr_nazn, { 3, i, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
          Else
            AAdd( arr_nazn, { 3, i, '', '' } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
          Endif
        Else
          AAdd( arr_nazn, { 3, i, '', '' } ) // теперь каждое назначение в отдельном PRESCRIPTIONS
        Endif
      Endif
    Next
  Endif
  If Between( m1napr_v_mo, 1, 2 ) .and. !Empty( arr_mo_spec )
    For i := 1 To Len( arr_mo_spec ) // теперь каждая специальность в отдельном PRESCRIPTIONS
      If mtab_v_mo != 0
        If P2TABN->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )  // '-', т.к. спец-ть была в кодировке V015
        Else
          AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), '', '' } ) // '-', т.к. спец-ть была в кодировке V015
        Endif
      Else
        AAdd( arr_nazn, { m1napr_v_mo, put_prvs_to_reestr( -arr_mo_spec[ i ], _NYEAR ), '', '' } ) // '-', т.к. спец-ть была в кодировке V015
      Endif
    Next
  Endif
  If Between( m1napr_stac, 1, 2 ) .and. m1profil_stac > 0
    If mtab_v_stac != 0
      If P2TABN->( dbSeek( Str( mtab_v_stac, 5 ) ) )
        AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
      Else
        AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, '', '' } )
      Endif
    Else
      AAdd( arr_nazn, { iif( m1napr_stac == 1, 5, 4 ), m1profil_stac, '', '' } )
    Endif
  Endif
  If m1napr_reab == 1 .and. m1profil_kojki > 0
    If mtab_v_reab != 0
      If P2TABN->( dbSeek( Str( mtab_v_reab, 5 ) ) )
        AAdd( arr_nazn, { 6, m1profil_kojki, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
      Else
        AAdd( arr_nazn, { 6, m1profil_kojki, '', '' } )
      Endif
    Else
      AAdd( arr_nazn, { 6, m1profil_kojki, '', '' } )
    Endif
  Endif
  cSMOname := ''
  If AllTrim( human_->smo ) == '34'
    cSMOname := ret_inogsmo_name( 2 )
  Endif
  mdiagnoz := diag_for_xml( , .t., , , .t. )

/// 26.12.24
  AFill( adiag_talon, 0 )
  For i := 1 To 16
    adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
  Next
///
  If p_tip_reestr == 1
    If glob_mo[ _MO_IS_UCH ] .and. ;                    // наше МО имеет прикреплённое население
        human_->USL_OK == 3 .and. ;                    // поликлиника
        kart2->MO_PR == glob_MO[ _MO_KOD_TFOMS ] .and. ; // прикреплён к нашему МО
      Between( kart_->INVALID, 1, 4 )                    // инвалид
      Select INV
      find ( Str( human->kod_k, 7 ) )
      If Found() .and. !emptyany( inv->DATE_INV, inv->PRICH_INV )
        // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
        fl_DISABILITY := ( inv->DATE_INV < human->n_data .and. human->n_data <= AddMonth( inv->DATE_INV, 12 ) )
      Endif
    Endif
  Else
    If human->OBRASHEN == '1' .and. AScan( mdiagnoz, {| x| PadR( x, 5 ) == 'Z03.1' } ) == 0
      AAdd( mdiagnoz, 'Z03.1' )
    Endif
    // AFill( adiag_talon, 0 )
    // For i := 1 To 16
    //   adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    // Next
  Endif
  mdiagnoz3 := {}
  If !Empty( human_2->OSL1 )
    AAdd( mdiagnoz3, human_2->OSL1 )
  Endif
  If !Empty( human_2->OSL2 )
    AAdd( mdiagnoz3, human_2->OSL2 )
  Endif
  If !Empty( human_2->OSL3 )
    AAdd( mdiagnoz3, human_2->OSL3 )
  Endif

  Return Nil
