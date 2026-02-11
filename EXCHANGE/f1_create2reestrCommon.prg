// реестры с 2025 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500

// 31.01.26 работаем по текущей записи
Function f1_create2reestrCommon( _nyear, p_tip_reestr )

  Local i, j, lst, sVidpoms
  Local locPRVS
  local arr_not_zs, lc, lpods
  local lvidpoms
  Local atmpusl
  //

  tarif_zak_sl := human->cena_1

  //
  lvidpoms := ''
  atmpusl := {}
//  Select HU 
  hu->( dbSeek( Str( human->kod, 7 ) ) )  //  find ( Str( human->kod, 7 ) )
  Do While hu->kod == human->kod .and. ! hu->( Eof() )
    lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
    If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , @lst, , @sVidpoms )
      lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
      If human_->USL_OK == USL_OK_POLYCLINIC .and. is_usluga_disp_nabl( lshifr )
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
      If !Empty( sVidpoms ) .and. ',' $ sVidpoms
        lvidpoms := sVidpoms
      Endif
      // попытка правки
      locPRVS := put_prvs_to_reestr( human_->PRVS, _NYEAR )
      If AllTrim( lshifr ) == '2.78.107'
        // терпевт + общая врачебная практика
//        If eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '76', '39' )
        If eq_any( locPRVS, '76', '39' )
          lvidpoms := '12'
//        Elseif eq_any( put_prvs_to_reestr( human_->PRVS, _NYEAR ), '2', '17', '24', '25', '35', '41', '45', '46', ;
        Elseif eq_any( locPRVS, '2', '17', '24', '25', '35', '41', '45', '46', ;
            '68', '71', '79', '84', '90', '92', '95' )
          lvidpoms := '13'
        Endif
        // фельдшер
        // lvidpoms := '11'
      Endif
      If ( hu->stoim_1 > 0 .or. Left( lshifr, 3 ) == '71.' ) .and. ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
        lvidpom := i
        // для школ здоровья ХНИЗ
//        if eq_any( lshifr, '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.8', '2.92.9', '2.92.10', '2.92.11', '2.92.12', '2.92.13' )
        if eq_any( lshifr, '2.93.1', '2.93.2', '2.92.2', '2.92.3', '2.92.4', '2.92.5', '2.92.6', '2.92.7', '2.92.8', '2.92.9', '2.92.10', '2.92.11', '2.92.12', '2.92.13' ) .or. ;
          eq_any( lshifr, '2.83.11', '2.83.15' ) //.or. eq_any( lshifr, '70.5.100', '70.6.100' )
/*
          if eq_any( locPRVS, '76', '49' )  // тераипия, педиатрия
          elseif eq_any( locPRVS, '206' )  // фельдшер
            lvidpom := 11
          elseif eq_any( lshifr, '2.92.4', '2.92.5', '2.92.9', '2.92.10', '2.92.11' ) .and. locPRVS == '39'   // общая врачебная практика (семейная медицина)
            lvidpom := 12
          else  // узкие специалисты
            lvidpom := 13
          endif
*/
          if locPRVS == '206'  // фельдшер
            lvidpom := 11
          elseif eq_any( locPRVS, '76', '49', '39' )  // тераипия, педиатрия, общая врачебная практика
            lvidpom := 12
          else  // узкие специалисты
            lvidpom := 13
          endif
        endif
        // для комплексного посещения центров здоровья
        if eq_any( lshifr, '2.76.100', '2.76.101', '2.76.102', '2.76.103', '2.76.104' )
          if eq_any( locPRVS, '76', '39' )  // тераипия, общая врачебная практика (семейная медицина)
            lvidpom := 12
          elseif   locPRVS == '206'  // фельдшер, лечебное дело (средний мед. персонал)
            lvidpom := 11
          else
            lvidpom := 13
          endif
        endif
      Endif
      If human_->USL_OK == USL_OK_POLYCLINIC
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
          If human_->USL_OK < 3 .and. p_tip_reestr == TYPE_REESTR_GENERAL
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
//    Select HU
//    Skip
    hu->( dbSkip() )
  Enddo
  If human_->USL_OK == USL_OK_HOSPITAL .and. human_2->VMP == 1 .and. !emptyany( human_2->VIDVMP, human_2->METVMP ) // ВМП
    is_KSG := .f.
  Endif
  If !Empty( lvidpoms )
    If !eq_ascan( atmpusl, '55.1.2', '55.1.3' ) .or. glob_mo()[ _MO_KOD_TFOMS ] == '801935' // ЭКО-Москва
      lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // только для дн.стационара при стационаре
    Elseif eq_ascan( atmpusl, '55.1.2' ) .and. glob_mo()[ _MO_KOD_TFOMS ] == '805960'  // грязелечебница
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
  
  arr_not_zs := np_arr_not_zs( human->k_data )
  a_otkaz := {} 
//  arr_nazn := {}
//  If eq_any( human->ishod, 101, 102 ) // дисп-ия детей-сирот
  if is_sluch_dispanser_deti_siroty( human->ishod ) // дисп-ия детей-сирот
    read_arr_dds( human->kod )
//  Elseif eq_any( human->ishod, 301, 302 ) // профосмотры несовершеннолетних
  Elseif is_sluch_dispanser_profilaktika_deti( human->ishod ) // профосмотры несовершеннолетних
    arr_usl_otkaz := {}
    read_arr_pn( human->kod )
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
//  Elseif Between( human->ishod, 201, 205 ) // дисп-ия I этап или профилактика
  elseif is_sluch_dispanser_DVN_prof( human->ishod ) // диспансеризация/профилактика взрослого населения
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
/*
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
*/
  Return Nil
