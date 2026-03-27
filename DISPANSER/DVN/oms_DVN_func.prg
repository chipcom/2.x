#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 27.03.26
Function is_usluga_dvn( ausl, _vozrast, arr, _etap, _pol, _spec_ter, arr_umolch, arr_usl )
  
  // ausl := {lshifr,mdate,hu_->profil,hu_->PRVS}
  Local i, j, s, fl := .f., as, lshifr := alltrim(ausl[1])
  local kprof
//  local fl_19

/*
  fl_19 := ( type( 'is_disp_19' ) == 'L' .and. is_disp_19 )
  if ! fl_19 .and. ( ( lshifr == '2.3.3' .and. ausl[ 3 ] == 3 ) .or. ; // акушерскому делу
                  ( lshifr == '2.3.1' .and. ausl[ 3 ] == 136 ) )   // акушерству и гинекологии
      //.and. ( i := ascan(arr_usl, { | x | valtype( x[ 2 ] ) == 'C' .and. x[ 2 ] == '4.20.1' } ) ) > 0
    if ( ( lshifr == '2.3.3' .and. eq_any( ret_old_prvs( ausl[ 4 ] ), 2003, 2002 ) ) .or. ;
      ( lshifr == '2.3.1' .and. ret_old_prvs( ausl[ 4 ] ) == 1101 ) )
    else
      aadd( arr, 'не та специальность врача в случае невозможности использования услуги:' )
      aadd( arr, ' "4.1.12.Осмотр акушеркой, взятие мазка (соскоба)"' )
    endif
    fl := .t.
  endif
*/
  if !fl
    for i := 1 to len( arr_umolch )
      if arr_umolch[ i, 2 ] == lshifr
        fl := .t.
        exit
      endif
    next
  endif
  if !fl
    DEFAULT _spec_ter to 0
    for i := 1 to Len( arr_usl )
      if valtype( arr_usl[ i, 2 ] ) == 'C'
        if arr_usl[ i, 2 ] == '4.20.1' .and. lshifr == '4.20.2'
          fl := .t.
        elseif arr_usl[ i, 2 ] == lshifr
          fl := .t.
        endif
      endif
      if ! fl .and. len( arr_usl[ i ] ) > 11 .and. valtype( arr_usl[ i, 12 ] ) == 'A'
        if ValType( arr_usl[ i, 12 ][ 1 ][ 1 ] ) == 'A'
          If ( kprof := AScan( arr_usl[ i, 12 ], {| x | x[ 2 ] == ausl[ 3 ] } ) ) > 0
            if AScan( arr_usl[ i, 12, kprof, 1 ], lshifr ) > 0
              fl := .t.
            endif
          endif
        else
          if ascan( arr_usl[ i, 12 ], { | x | x[ 1 ] == lshifr .and. x[ 2 ] == ausl[ 3 ] } ) > 0
            fl := .t.
          endif
        endif
      endif
      if fl
        s := '"' + lshifr + '.' + arr_usl[ i, 1 ] + '"'
        if eq_any( _etap, 1, 4, 5 )
          j := iif( _pol == 'М', 6, 7 )
          if _etap > 1 .and. len( arr_usl[ i ] ) > 12
            j := iif( _pol == 'М', 13, 14 )
          endif
          if valtype( arr_usl[i, j]) == 'N'
            if arr_usl[ i, j ] == 0
              aadd( arr, 'несовместимость по полу в услуге ' + s )
            endif
          else
            if ascan( arr_usl[ i, j ], _vozrast ) == 0
              aadd( arr, 'некорректный возраст пациента для услуги ' + s )
            endif
          endif
        else
          j := iif( _pol == 'М', 8, 9 )
          if valtype( arr_usl[ i, j ] ) == 'N'
            if arr_usl[ i, j ] == 0
              aadd( arr, 'несовместимость по полу в услуге ' + s )
            endif
//          elseif type('is_disp_19') == 'L' .and. is_disp_19
          elseif valtype( arr_usl[ i, j ] ) == 'A'
            if ascan( arr_usl[ i, j ], _vozrast ) == 0
              aadd( arr,'некорректный возраст пациента для услуги ' + s )
            endif
          else
            if !between( _vozrast, arr_usl[ i, j, 1 ], arr_usl[ i, j, 2 ] )
              aadd( arr, 'некорректный возраст пациента для услуги ' + s )
            endif
          endif
        endif
        if valtype( arr_usl[ i, 10 ] ) == 'N'
          if ret_profil_dispans( arr_usl[ i, 10 ], ausl[ 4 ] ) != ausl[ 3 ]
          //if arr_usl[ i, 10 ] != ausl[ 3 ]
            aadd( arr, 'не тот профиль в услуге ' + s )
          endif
        else
          if ascan( arr_usl[ i, 10 ], ausl[ 3 ] ) == 0
            aadd( arr,'не тот профиль в услуге ' + s )
          endif
        endif
        as := aclone( arr_usl[ i, 11 ] )
        // "Измерение внутриглазного давления","3.4.9"
        if _etap == 1 .and. as[ 1 ] == 1112 .and. _spec_ter > 0
          aadd( as, _spec_ter ) // добавить спец-ть терапевта
        endif
        /*if ascan( as, ausl[ 4 ] ) == 0
          aadd( arr,'Не та специальность врача в услуге ' + s )
          aadd( arr, ' у Вас: ' + lstr( ausl[ 4 ] ) + ', разрешено: ' + print_array( as ) )
        endif*/
        exit
      endif
    next
  endif
  return fl

// 23.03.26
function del_usl_10_3_713_I_etap( mArr )

  local i

  for i := len( mArr ) to 1 step -1
    If ValType( mArr[ i, 2 ] ) == 'C' .and. mArr[ i, 2 ] == '10.3.713' ;
        .and. mArr[ i, 3 ] == 1 // для 1 этапа
      hb_ADel( mArr, i, .t. )  // удалим услугу 10.3.713 для I этапа
    endif
  next
  
  return mArr

// 16.03.26 замена услуг ДВН на профосмотр
function zamena_usl_dvn_to_prof( arr_osm )

  local i

  // замена услуг
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.63' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.17' // шифр услуги приёма терапевта для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.363' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.317' // шифр услуги приёма мобильного терапевта для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.64' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.18' // шифр услуги приёма фельдшера для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.364' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.318' // шифр услуги приёма мобильного фельдшера для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.61' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.19' // шифр услуги приёма гинеколога для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.361' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.319' // шифр услуги приёма мобильного гинеколога для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.62' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.20' // шифр услуги приёма акушера для профосмотра
  endif
  If ( i := AScan( arr_osm, {| x | ValType( x[ 5 ] ) == 'C' .and. x[ 5 ] == '70.7.362' } ) ) > 0
    arr_osm[ i, 5 ] := '72.7.320' // шифр услуги приёма мобильного акушера для профосмотра
  endif

  return Nil

// 16.03.26 проверка входит ли услуга ДВН в список обязательных
function control_obyazat_usl_dvn( mdate, mobil, shifr )

  local i, arr, lRet := .f., j

  default mdate to Date()
  default mobil to 0
  shifr := AllTrim( shifr )
  arr := dvn_obyazat_usl( mdate, mobil )
  if Len( arr ) > 0
    for i := 1 to len( arr )
      if ValType( arr[ i ] ) == 'C' .and. shifr == arr[ i ]
        lRet := .t.
        exit
      elseif ValType( arr[ i ] ) == 'A'
        if ascan( arr[ i ], shifr ) > 0
          lRet := .t.
          exit
        endif
      endif
    next
  endif

  return lRet

// 17.03.26
function is_Recto_dvn_II( lshifr )

  return eq_any( lshifr, '10.6.710', '10.4.701' )

// 17.03.26
function is_Tomogr_dvn_II( lshifr )

  return eq_any( lshifr, '7.2.701', '7.2.703', '7.2.704', '7.2.705', '7.2.702' )

// 15.03.26
function is_ekg_dvn_new( lshifr )

  return eq_any( lshifr, '13.1.701', '13.1.707', '13.1.703', '13.1.704' )

// 15.03.26
function is_MamoGr_dvn_new( lshifr )

  return eq_any( lshifr, '7.57.703', '7.57.709', '7.57.705', '7.57.706' )

// 15.03.26
function is_Fluor_dvn_new( lshifr )

  return eq_any( lshifr, '7.61.703', '7.61.709', '7.61.705', '7.61.706' )

// 15.03.26
function is_Cit_dvn_new( lshifr )

  return eq_any( lshifr, '4.20.701', '4.20.709', '4.20.703', '4.20.704' )

// 05.09.21
Function read_arr_dvn( lkod, is_all )

  Local arr, i, sk
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  Private mvar

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers',, 'TPERS' )
  Endif

  arr := read_arr_dispans( lkod )
  Default is_all To .t.
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case arr[ i, 1 ] == 'VB' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1veteran := arr[ i, 2 ]
      Case arr[ i, 1 ] == '0' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1mobilbr := arr[ i, 2 ]
      Case arr[ i, 1 ] == '1' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1kurenie := arr[ i, 2 ]
      Case arr[ i, 1 ] == '2' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1riskalk := arr[ i, 2 ]
      Case arr[ i, 1 ] == '3' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1pod_alk := arr[ i, 2 ]
      Case arr[ i, 1 ] == '3.1' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1psih_na := arr[ i, 2 ]
      Case arr[ i, 1 ] == '4' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1fiz_akt := arr[ i, 2 ]
      Case arr[ i, 1 ] == '5' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ner_pit := arr[ i, 2 ]
      Case arr[ i, 1 ] == '6' .and. ValType( arr[ i, 2 ] ) == 'N'
        mWEIGHT := arr[ i, 2 ]
      Case arr[ i, 1 ] == '7' .and. ValType( arr[ i, 2 ] ) == 'N'
        mHEIGHT := arr[ i, 2 ]
      Case arr[ i, 1 ] == '8' .and. ValType( arr[ i, 2 ] ) == 'N'
        mOKR_TALII := arr[ i, 2 ]
      Case arr[ i, 1 ] == '9' .and. ValType( arr[ i, 2 ] ) == 'N'
        mad1 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '10' .and. ValType( arr[ i, 2 ] ) == 'N'
        mad2 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '11' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1addn := arr[ i, 2 ]
      Case arr[ i, 1 ] == '12' .and. ValType( arr[ i, 2 ] ) == 'N'
        mholest := arr[ i, 2 ]
      Case arr[ i, 1 ] == '13' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1holestdn := arr[ i, 2 ]
      Case arr[ i, 1 ] == '14' .and. ValType( arr[ i, 2 ] ) == 'N'
        mglukoza := arr[ i, 2 ]
      Case arr[ i, 1 ] == '15' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1glukozadn := arr[ i, 2 ]
      Case arr[ i, 1 ] == '16' .and. ValType( arr[ i, 2 ] ) == 'N'
        mssr := arr[ i, 2 ]
      Case is_all .and. eq_any( arr[ i, 1 ], '21', '22', '23', '24', '25' ) .and. ;
          ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 7
        sk := Right( arr[ i, 1 ], 1 )
        pole_diag := 'mdiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1stadia := 'm1stadia' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_1dop := 'm1dop' + sk
        pole_1usl := 'm1usl' + sk
        pole_1san := 'm1san' + sk
        pole_d_diag := 'mddiag' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If ValType( arr[ i, 2, 1 ] ) == 'C'
          &pole_diag := arr[ i, 2, 1 ]
        Endif
        If ValType( arr[ i, 2, 2 ] ) == 'N'
          &pole_1pervich := arr[ i, 2, 2 ]
        Endif
        If ValType( arr[ i, 2, 3 ] ) == 'N'
          &pole_1stadia := arr[ i, 2, 3 ]
        Endif
        If ValType( arr[ i, 2, 4 ] ) == 'N'
          &pole_1dispans := arr[ i, 2, 4 ]
        Endif
        If ValType( arr[ i, 2, 5 ] ) == 'N' .and. Type( pole_1dop ) == 'N'
          &pole_1dop := arr[ i, 2, 5 ]
        Endif
        If ValType( arr[ i, 2, 6 ] ) == 'N' .and. Type( pole_1usl ) == 'N'
          &pole_1usl := arr[ i, 2, 6 ]
        Endif
        If ValType( arr[ i, 2, 7 ] ) == 'N' .and. Type( pole_1san ) == 'N'
          &pole_1san := arr[ i, 2, 7 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 8 .and. ValType( arr[ i, 2, 8 ] ) == 'D' .and. Type( pole_d_diag ) == 'D'
          &pole_d_diag := arr[ i, 2, 8 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 9 .and. ValType( arr[ i, 2, 9 ] ) == 'D' .and. Type( pole_d_dispans ) == 'D'
          &pole_d_dispans := arr[ i, 2, 9 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 10 .and. ValType( arr[ i, 2, 10 ] ) == 'D' .and. Type( pole_dn_dispans ) == 'D'
          &pole_dn_dispans := arr[ i, 2, 10 ]
        Endif
      Case is_all .and. arr[ i, 1 ] == '29' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_usl_otkaz := arr[ i, 2 ]
      Case arr[ i, 1 ] == '30' .and. ValType( arr[ i, 2 ] ) == 'N'
        // m1GRUPPA := arr[i,2]
      Case arr[ i, 1 ] == '31' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1prof_ko := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '40' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_otklon := arr[ i, 2 ]
      Case arr[ i, 1 ] == '41' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl1 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '42' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl2 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '43' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl3 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '44' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ot_nasl4 := arr[ i, 2 ]
      Case arr[ i, 1 ] == '45' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1dispans  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '46' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1nazn_l   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '47'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1dopo_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1dopo_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_dopo_na := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '48' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ssh_na   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '49' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1spec_na  := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '50'   // .and. valtype(arr[i,2]) == 'N'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1sank_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1sank_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_sanat := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '51' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1p_otk  := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '52'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_v_mo  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_v_mo  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_mo := TPERS->tab_nom
          Endif
        Endif
      Case is_all .and. arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_mo_spec := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '54'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_stac := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_stac := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_stac := TPERS->tab_nom
          Endif
        Endif
      Case is_all .and. arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_stac := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '56'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_reab := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_reab := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_reab := TPERS->tab_nom
          Endif
        Endif
      Case is_all .and. arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_kojki := arr[ i, 2 ]
      Endcase
    Endif
  Next

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  Return Nil

// 22.02.26
Function save_arr_dvn( lkod, mk_data )

  Local arr := {}, i, sk, ta
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'TPERS' )
  Endif

  If Type( 'mfio' ) == 'C'
    AAdd( arr, { 'mfio', AllTrim( mfio ) } )
  Endif
  If Type( 'mdate_r' ) == 'D'
    AAdd( arr, { 'mdate_r', mdate_r } )
  Endif
  AAdd( arr, { 'VB', m1veteran } )  // 'N',ветеран ВОВ (блокадник)
  AAdd( arr, { '0', m1mobilbr } )   // 'N',мобильная бригада
  AAdd( arr, { '1', m1kurenie } )   // 'N',Курение
  AAdd( arr, { '2', m1riskalk } )   // 'N',Алкоголь
  AAdd( arr, { '3', m1pod_alk } )   // 'N',наркотики
  AAdd( arr, { '3.1', m1psih_na } )   // 'N',        направлен к психиатру-наркологу
  AAdd( arr, { '4', m1fiz_akt } )   // 'N',Низкая физическая активность
  AAdd( arr, { '5', m1ner_pit } )   // 'N',Нерациональное питание
  AAdd( arr, { '6', mWEIGHT } )     // 'N',Вес
  AAdd( arr, { '7', mHEIGHT } )     // 'N',рост
  AAdd( arr, { '8', mOKR_TALII } )  // 'N',окружность талии
  AAdd( arr, { '9', mad1 } )        // 'N',Артериальное давление
  AAdd( arr, { '10', mad2 } )        // 'N',Артериальное давление
  AAdd( arr, { '11', m1addn } )      // 'N',Гипотензивная терапия
  AAdd( arr, { '12', mholest } )     // 'N',Общий холестерин
  AAdd( arr, { '13', m1holestdn } )  // 'N',Гиполипидемическая терапия
  AAdd( arr, { '14', mglukoza } )    // 'N',Глюкоза
  AAdd( arr, { '15', m1glukozadn } ) // 'N',Гипогликемическая терапия
  AAdd( arr, { '16', mssr } )        // 'N',Суммарный сердечно-сосудистый риск
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_1pervich := 'm1pervich' + sk
    pole_1stadia := 'm1stadia' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_1dop := 'm1dop' + sk
    pole_1usl := 'm1usl' + sk
    pole_1san := 'm1san' + sk
    pole_d_diag := 'mddiag' + sk
    pole_d_dispans := 'mddispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    If !Empty( &pole_diag )
      ta := { &pole_diag, ;
        &pole_1pervich, ;
        &pole_1stadia, ;
        &pole_1dispans }
      If Type( pole_1dop ) == 'N' .and. Type( pole_1usl ) == 'N' .and. Type( pole_1san ) == 'N'
        AAdd( ta, &pole_1dop )
        AAdd( ta, &pole_1usl )
        AAdd( ta, &pole_1san )
      Else
        AAdd( ta, 0 )
        AAdd( ta, 0 )
        AAdd( ta, 0 )
      Endif
      If Type( pole_d_diag ) == 'D' .and. Type( pole_d_dispans ) == 'D'
        AAdd( ta, &pole_d_diag )
        AAdd( ta, &pole_d_dispans )
      Else
        AAdd( ta, CToD( '' ) )
        AAdd( ta, CToD( '' ) )
      Endif
      If Type( pole_dn_dispans ) == 'D'
        AAdd( ta, &pole_dn_dispans )
      Else
        AAdd( ta, CToD( '' ) )
      Endif
      AAdd( arr, { lstr( 20 + i ), ta } )
    Endif
  Next i
  If !Empty( arr_usl_otkaz )
    AAdd( arr, { '29', arr_usl_otkaz } ) // массив
  Endif
  AAdd( arr, { '30', m1GRUPPA } )    // 'N1',группа здоровья после дисп-ии
  If Type( 'm1prof_ko' ) == 'N'
    AAdd( arr, { '31', m1prof_ko } )    // 'N1',вид проф.консультирования
  Endif
  AAdd( arr, { '40', arr_otklon } ) // массив
  AAdd( arr, { '41', m1ot_nasl1 } )
  AAdd( arr, { '42', m1ot_nasl2 } )
  AAdd( arr, { '43', m1ot_nasl3 } )
  AAdd( arr, { '44', m1ot_nasl4 } )
  AAdd( arr, { '45', m1dispans } )
  AAdd( arr, { '46', m1nazn_l } )
  If mk_data >= 0d20210801
    If mtab_v_dopo_na != 0
      If TPERS->( dbSeek( Str( mtab_v_dopo_na, 5 ) ) )
        AAdd( arr, { '47', { m1dopo_na, TPERS->kod } } )
      Else
        AAdd( arr, { '47', { m1dopo_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '47', { m1dopo_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '47', m1dopo_na } )
  Endif
  AAdd( arr, { '48', m1ssh_na } )
  AAdd( arr, { '49', m1spec_na } )
  If mk_data >= 0d20210801
    If mtab_v_sanat != 0
      If TPERS->( dbSeek( Str( mtab_v_sanat, 5 ) ) )
        AAdd( arr, { '50', { m1sank_na, TPERS->kod } } )
      Else
        AAdd( arr, { '50', { m1sank_na, 0 } } )
      Endif
    Else
      AAdd( arr, { '50', { m1sank_na, 0 } } )
    Endif
  Else
    AAdd( arr, { '50', m1sank_na } )
  Endif
  If Type( 'm1p_otk' ) == 'N'
    AAdd( arr, { '51', m1p_otk } )
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_v_mo' ) == 'N'
      If mtab_v_mo != 0
        If TPERS->( dbSeek( Str( mtab_v_mo, 5 ) ) )
          AAdd( arr, { '52', { m1napr_v_mo, TPERS->kod } } )
        Else
          AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
        Endif
      Else
        AAdd( arr, { '52', { m1napr_v_mo, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_v_mo' ) == 'N'
      AAdd( arr, { '52', m1napr_v_mo } )
    Endif
  Endif
  If Type( 'arr_mo_spec' ) == 'A'   // .and. !empty(arr_mo_spec)
    AAdd( arr, { '53', arr_mo_spec } ) // массив
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_stac' ) == 'N'
      If mtab_v_stac != 0
        If TPERS->( dbSeek( Str( mtab_v_stac, 5 ) ) )
          AAdd( arr, { '54', { m1napr_stac, TPERS->kod } } )
        Else
          AAdd( arr, { '54', { m1napr_stac, 0 } } )
        Endif
      Else
        AAdd( arr, { '54', { m1napr_stac, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_stac' ) == 'N'
      AAdd( arr, { '54', m1napr_stac } )
    Endif
  Endif
  If Type( 'm1profil_stac' ) == 'N'
    AAdd( arr, { '55', m1profil_stac } )
  Endif
  If mk_data >= 0d20210801
    If Type( 'm1napr_reab' ) == 'N'
      If mtab_v_reab != 0
        If TPERS->( dbSeek( Str( mtab_v_reab, 5 ) ) )
          AAdd( arr, { '56', { m1napr_reab, TPERS->kod } } )
        Else
          AAdd( arr, { '56', { m1napr_reab, 0 } } )
        Endif
      Else
        AAdd( arr, { '56', { m1napr_reab, 0 } } )
      Endif
    Endif
  Else
    If Type( 'm1napr_reab' ) == 'N'
      AAdd( arr, { '56', m1napr_reab } )
    Endif
  Endif
  If Type( 'm1profil_kojki' ) == 'N'
    AAdd( arr, { '57', m1profil_kojki } )
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  save_arr_dispans( lkod, arr )

  Return Nil

// 11.06.24
Function fget_spec_dvn( k, r, c, a_spec, lFull )

  Static as := { ;
    { 8, 2 }, ;
    { 255, 1 }, ;
    { 112, 1 }, ;
    { 58, 1 }, ;
    { 65, 1 }, ;
    { 113, 1 }, ;
    { 133, 1 }, ;
    { 257, 1 }, ;
    { 114, 1 }, ;
    { 258, 1 }, ;
    { 115, 1 }, ;
    { 66, 1 }, ;
    { 116, 1 }, ;
    { 10, 1 }, ;
    { 32, 1 }, ;
    { 260, 1 }, ;
    { 118, 1 }, ;
    { 139, 2 }, ;
    { 59, 1 }, ;
    { 67, 1 }, ;
    { 120, 1 }, ;
    { 134, 1 }, ;
    { 14, 2 }, ;
    { 140, 1 }, ;
    { 261, 1 }, ;
    { 123, 1 }, ;
    { 17, 1 }, ;
    { 19, 2 }, ;
    { 20, 2 }, ;
    { 23, 1 }, ;
    { 262, 1 }, ;
    { 125, 1 }, ;
    { 138, 1 }, ;
    { 263, 1 }, ;
    { 126, 1 }, ;
    { 141, 1 }, ;
    { 75, 1 }, ;
    { 28, 1 }, ;
    { 145, 2 }, ;
    { 29, 1 }, ;
    { 30, 2 }, ;
    { 31, 1 }, ;
    { 97, 1 };
    }
  local s, blk, t_arr[ BR_LEN ], n_file := cur_dir() + 'tmpspecdvn', i
  Local tmp_select := Select()

  default lFull to .f.

  If !hb_FileExists( n_file + sdbf() )
    dbCreate( n_file, { ;
      { 'name', 'C', 30, 0 }, ;
      { 'kod', 'C', 4, 0 }, ;
      { 'kod_up', 'C', 4, 0 }, ;
      { 'name1', 'C', 50, 0 }, ;
      { 'isn', 'N', 1, 0 }, ;
      { 'is', 'L', 1, 0 } ;
    } )
    Use ( n_file ) New Alias SDVN
    Use ( cur_dir() + 'tmp_v015' ) index ( cur_dir() + 'tmpkV015' ) New Alias tmp_ga
    Go Top
    Do While !Eof()
      if lFull
        Select SDVN
        Append Blank
        sdvn->name := AfterAtNum( '.', tmp_ga->name, 1 )
        sdvn->kod := tmp_ga->kod
//        sdvn->isn := as[ i, 2 ]
        s := ''
        Select TMP_GA
        rec := RecNo()
        Do While !Empty( tmp_ga->kod_up )
          find ( tmp_ga->kod_up )
          If Found()
            s += AllTrim( AfterAtNum( '.', tmp_ga->name, 1 ) ) + '/'
          Else
            Exit
          Endif
        Enddo
        Goto ( rec )
        sdvn->name1 := s
      else
        If ( i := AScan( as, { | x | lstr( x[ 1 ] ) == RTrim( tmp_ga->kod ) } ) ) > 0
          Select SDVN
          Append Blank
          sdvn->name := AfterAtNum( '.', tmp_ga->name, 1 )
          sdvn->kod := tmp_ga->kod
          sdvn->isn := as[ i, 2 ]
          s := ''
          Select TMP_GA
          rec := RecNo()
          Do While !Empty( tmp_ga->kod_up )
            find ( tmp_ga->kod_up )
            If Found()
              s += AllTrim( AfterAtNum( '.', tmp_ga->name, 1 ) ) + '/'
            Else
              Exit
            Endif
          Enddo
          Goto ( rec )
          sdvn->name1 := s
        Endif
      endif
      Skip
    Enddo
    sdvn->( dbCloseArea() )
    tmp_ga->( dbCloseArea() )
  Endif
  Use ( n_file ) New Alias tmp_ga
  Do While !Eof()
    tmp_ga->is := ( AScan( a_spec, Int( Val( tmp_ga->kod ) ) ) > 0 )
    Skip
  Enddo
  if lFull
    Index On Upper( name ) + kod to ( n_file )
  else
    If metap == 3
      Index On Upper( name ) + kod to ( n_file )
    Else
      Index On Upper( name ) + kod to ( n_file ) For isn == 1
    Endif
  endif
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    t_arr[ BR_BOTTOM ] := MaxRow() -2
  Else
    t_arr[ BR_BOTTOM ] := r - 1
    t_arr[ BR_TOP ] := 2
  Endif
  blk := {|| iif( tmp_ga->is, { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_LEFT ] := 0
  t_arr[ BR_RIGHT ] := 79
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .f. }
  t_arr[ BR_COLUMN ] := { ;
    { ' ', {|| iif( tmp_ga->is, '', ' ' ) }, blk }, ;
    { 'Код', {|| Left( tmp_ga->kod, 3 ) }, blk }, ;
    { Center( 'Медицинская специальность', 26 ), {|| PadR( tmp_ga->name, 26 ) }, blk }, ;
    { Center( 'подчинение', 45 ), {|| Left( tmp_ga->name1, 45 ) }, blk };
    }
  t_arr[ BR_EDIT ] := { | nk, ob | f1get_spec_dvn( nk, ob, 'edit' ) }
  t_arr[ BR_STAT_MSG ] := { || status_key( '^<Esc>^ - выход;  ^<Ins>^ - отметить специальность/снять отметку со специальности' ) }
  Go Top
  edit_browse( t_arr )
  s := ''
  ASize( a_spec, 0 )
  Go Top
  Do While !Eof()
    if lFull
      If tmp_ga->is
        s += AllTrim( tmp_ga->kod ) + ','
        AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
      Endif
    else
      If iif( metap == 3, .t., tmp_ga->isn == 1 ) .and. tmp_ga->is
        s += AllTrim( tmp_ga->kod ) + ','
        AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
      Endif
    endif
    Skip
  Enddo
  If Empty( s )
    s := '---'
  Else
    s := Left( s, Len( s ) -1 )
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )

  Return { 1, s }

// 11.11.17
Function f1get_spec_dvn( nKey, oBrow, regim )

  If regim == 'edit' .and. nkey == K_INS
    tmp_ga->is := !tmp_ga->is
    Keyboard Chr( K_TAB )
  Endif

  Return 0

// 25.03.26 рабочая ли услуга ДВН в зависимости от этапа, возраста и пола
Function f_is_usl_oms_sluch_dvn( mdata, mobil, i, _etap, _vozrast, _pol, /*@*/_diag,/*@*/_otkaz,/*@*/_ekg)

  Local fl := .f., ars := {}, ar, aTemp

  aTemp := dvn_arr_usl( mdata, mobil )
  if mdata >= 0d20260101 .and. _etap == 2
//  if _etap == 2
    aTemp := del_usl_10_3_713_I_etap( aTemp )
  endif
  ar := aTemp[ i ]

  If ValType( ar[ 3 ] ) == 'N'
    fl := ( ar[ 3 ] == _etap )
  Else
    fl := AScan( ar[ 3 ], _etap ) > 0
  Endif
  _diag := ( ar[ 4 ] == 1 )
  _otkaz := 0
  _ekg := .f.
  If ValType( ar[ 2 ] ) == 'C'
    AAdd( ars, ar[ 2 ] )
  Else
    ars := AClone( ar[ 2 ] )
  Endif
  If eq_any( _etap, 1, 3 ) .and. ar[ 5 ] == 1 .and. ( ( AScan( ars, '4.20.1' ) == 0 ) .or. ( AScan( ars, '4.20.701' ) == 0 ) )
    _otkaz := 1 // можно ввести отказ
    If ValType( ar[ 2 ] ) == 'C' .and. eq_ascan( ars, '7.57.3', '7.61.3', '4.1.12', ;
        '7.57.703', '7.61.703', '4.1.712', '4.1.713' )
      _otkaz := 2 // можно ввести невозможность
      If ( AScan( ars, '4.1.12' ) > 0 ) .or. ( AScan( ars, '4.1.712' ) > 0 ) .or. ( AScan( ars, '4.1.713' ) > 0 ) // взятие мазка
        _otkaz := 3 // заменить на приём фельдшера-акушера
      Endif
    Endif
  Endif
  If fl .and. eq_any( _etap, 1, 4, 5 )
    If _etap == 1
      i := iif( _pol == 'М', 6, 7 )
    Elseif Len( ar ) < 14
      Return .f.
    Else
      i := iif( _pol == 'М', 13, 14 )
    Endif
    If ValType( ar[ i ] ) == 'N' // специально для услуги 'Электрокардиография','13.1.1' ранее 18 года
      fl := ( ar[ i ] != 0 )
      If ar[ i ] < 0  // ЭКГ
        _ekg := ( _vozrast < Abs( ar[ i ] ) ) // необязательный возраст
      Endif
    Else // для 1,4,5 этапа возраст указан массивом
      fl := AScan( ar[ i ], _vozrast ) > 0
    Endif
  Endif
  If fl .and. eq_any( _etap, 2, 3 )
//    i := iif( _pol == 'М', 8, 9 )
    i := iif( _pol == 'М', 6, 7 )
    If ValType( ar[ i ] ) == 'N'
      fl := ( ar[ i ] != 0 )
//    Elseif Type( 'is_disp_19' ) == 'L' .and. is_disp_19
    Elseif ValType( ar[ i ] ) == 'A'
      fl := AScan( ar[ i ], _vozrast ) > 0
//    Else // для 2 этапа и профилактики возраст указан диапазоном
//      fl := Between( _vozrast, ar[ i, 1 ], ar[ i, 2 ] )
    else
      fl := AScan( ar[ i ], _vozrast ) > 0
    Endif
  Endif

  Return fl

// 15.06.19
Function ret_etap_dvn( lkod_h, lkod_k )

  Local ae := { {}, {} }, fl, i, d1 := Year( mn_data )

  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humankk', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  human->( dbSeek( Str( lkod_k, 7 ) ) )
  Do While human->kod_k == lkod_k .and. ! human->( Eof() )
    fl := ( lkod_h != human->( RecNo() ) )
    If fl .and. human->schet > 0 .and. human_->oplata == 9
      fl := .f. // лист учёта снят по акту и выставлен повторно
    Endif
    If fl .and. Between( human->ishod, 201, 205 ) // ???
      i := human->ishod -200
      If Year( human->n_data ) == d1 // текущий год
        AAdd( ae[ 1 ], { i, human->k_data, human_->RSLT_NEW } )
        // elseif i >= 3 .and. mk_data < 0d20190501 .and. year(human->n_data) == d1-1 // профилактика прошлый год ???
        // aadd(ae[2], {i,human->k_data,human_->RSLT_NEW})
      Endif
    Endif
    human->( dbSkip() )
  Enddo
  dbCloseAll()

  Return ae

// 27.03.26 добавить шифр манипуляции в свой справочник MO_SU
Function append_shifr_mo_su( lshifr, fl_commit )

  Local lu_kod := 0, arr := {}

  Default fl_commit To .t.
  Select MOSU
  Set Order To 3 // по шифру ФФОМС
  mosu->( dbSeek( PadR( lshifr, 20 ) ) )    //  find ( PadR( lshifr, 20 ) )
  Do While mosu->shifr1 == PadR( lshifr, 20 ) .and. ! mosu->( Eof() )
    AAdd( arr, { iif( Left( mosu->shifr, 1 ) == '*', 1, 0 ), mosu->kod } )
    Skip
  Enddo
  If !Empty( arr )
    ASort( arr, , , {| x, y| x[ 1 ] < y[ 1 ] } ) // все старые стомат.услуги со звёздочкой в конец массива
    lu_kod := arr[ 1, 2 ]
  Else
    Select LUSLF
    luslf->( dbSeek( PadR( lshifr, 20 ) ) )   //  find ( PadR( lshifr, 20 ) )
    Select MOSU
    Set Order To 1
    mosu->( dbseek( Str( -1, 6 ) ) )    //  find ( Str( -1, 6 ) )
    If mosu->( Found() )
      g_rlock( 'forever' )
    Else
      addrec( 6 )
    Endif
    lu_kod := mosu->kod := RecNo()
    mosu->name := luslf->name
    mosu->shifr1 := lshifr
    mosu->PROFIL := m1PROFIL
    If fl_commit
      Unlock
      Commit
    Endif
  Endif

  Return lu_kod

// 06.05.15 вернуть 'правильный' профиль для диспансеризации/профилактики
Function ret_profil_dispans( lprofil, lprvs )

  If lprofil == 34 // если профиль по 'клинической лабораторной диагностике'
    If ret_old_prvs( lprvs ) == 2013 // и спец-ть 'Лабораторное дело'
      lprofil := 37 // сменим на профиль по 'лабораторному делу'
    Elseif ret_old_prvs( lprvs ) == 2011 // или 'Лабораторная диагностика'
      lprofil := 38 // сменим на профиль по 'лабораторной диагностике'
    Endif
  Endif

  Return lprofil

// 08.08.13 вернуть тип массы в строке
Function ret_tip_mas( _WEIGHT, _HEIGHT, /*@*/ret )

  Static mm_tip_mas := { { 'Дефицит массы тела', 0, 18.4 }, ;
    { 'Нормальная масса тела', 18.5, 24.9 }, ;
    { 'Избыточная масса тела', 25.0, 29.9 }, ;
    { 'Ожирение I степени', 30.0, 34.9 }, ;
    { 'Ожирение II степени', 35.0, 39.9 }, ;
    { 'Ожирение III степени', 40.0, 9999 } }
  Local i, k, s := ''

  ret := 2
  If !emptyany( _WEIGHT, _HEIGHT )
    _HEIGHT /= 100  // рост из сантиметров в метры
    k := Round( _WEIGHT / _HEIGHT / _HEIGHT, 1 ) // индекс Кетле
    If ( i := AScan( mm_tip_mas, {| x| Between( k, x[ 2 ], x[ 3 ] ) } ) ) > 0
      ret := i
      s := mm_tip_mas[ i, 1 ]
    Endif
  Endif

  Return PadR( s, 21 )

// 24.03.26
Function ret_ndisp( lkod_h, lkod_k, /*@*/new_etap, /*@*/msg )

  Local i, i1, i2, i3, i4, i5, is_disp, ar, fl := .t.

  is_disp_19 := !( mk_data < 0d20190501 )
  ret_arrays_disp( mk_data )
  msg := ' '
  new_etap := metap
  is_dostup_2_year := .f.
  If m1veteran == 1
    mdvozrast := ret_vozr_dvn_veteran( mdvozrast, mk_data )
  Endif
  
  If !( is_disp := AScan( ret_arr_vozrast_dvn( mk_data ), mdvozrast ) > 0 )
//    If !is_disp_19 // по старому приказу МЗ РФ
//      is_dostup_2_year := AScan( arr2m_vozrast_DVN(), mdvozrast ) > 0
//      If !is_dostup_2_year .and. mpol == 'Ж'
//        is_dostup_2_year := AScan( arr2g_vozrast_DVN(), mdvozrast ) > 0
//      Endif
//    Endif
  Endif
  If metap == 0
    If is_disp
      new_etap := 1
    Else
      new_etap := 3
    Endif
  Elseif metap == 3
    If is_disp
      new_etap := 1
    Else
      // остаётся = 3
    Endif
  Else
    If is_disp
      // остаётся = 1 или 2
    Elseif new_etap < 4
      new_etap := 3
    Endif
  Endif
  ar := ret_etap_dvn( lkod_h, lkod_k )
  If new_etap != 3
    If Empty( ar[ 1 ] ) // в этом году ещё ничего не делали
      // оставляем 1
    Else
      i1 := i2 := i3 := i4 := i5 := 0
      For i := 1 To Len( ar[ 1 ] )
        Do Case
        Case ar[ 1, i, 1 ] == 1 // дисп-ия 1 этап
          i1 := i
        Case ar[ 1, i, 1 ] == 2 // дисп-ия 2 этап
          i2 := i
        Case ar[ 1, i, 1 ] == 3 // профилактика
          i3 := i
          msg := date_8( ar[ 1, i, 2 ] ) + 'г. уже проведён профилактический медосмотр!'
        Case ar[ 1, i, 1 ] == 4 // дисп-ия 1 этап 1 раз в 2 года
          i4 := i
          msg := 'В ' + lstr( Year( mn_data ) ) + ' году уже проведена диспансеризации 1 раз в 2 года'
        Case ar[ 1, i, 1 ] == 5 // дисп-ия 2 этап 1 раз в 2 года
          i5 := i
          msg := 'В ' + lstr( Year( mn_data ) ) + ' году уже проведена диспансеризации 1 раз в 2 года'
        Endcase
      Next
      If eq_any( new_etap, 1, 2 ) .and. new_etap != metap
        If i1 == 0
          new_etap := 1 // делаем 1 этап
        Elseif i2 == 0
          new_etap := 2 // делаем 2 этап
        Endif
      Endif
      If i1 > 0 .and. i2 > 0
        msg := 'В ' + lstr( Year( mn_data ) ) + ' году уже проведены оба этапа диспансеризации!'
      Elseif i1 > 0 .and. !Empty( ar[ 1, i1, 2 ] ) .and. ar[ 1, i1, 2 ] > mn_data
        msg := 'Диспансеризация I этапа закончилась ' + date_8( ar[ 1, i1, 2 ] ) + 'г.!'
      Endif
      If eq_any( new_etap, 4, 5 ) .and. new_etap != metap
        If i4 == 0
          new_etap := 4 // делаем 1 этап
        Elseif i5 == 0
          new_etap := 5 // делаем 2 этап
        Endif
      Endif
      If i4 > 0 .and. i5 > 0
        msg := 'В ' + lstr( Year( mn_data ) ) + ' году уже проведены оба этапа диспансеризации (раз в 2 года)!'
      Elseif i4 > 0 .and. !Empty( ar[ 1, i4, 2 ] ) .and. ar[ 1, i4, 2 ] > mn_data
        msg := 'Диспансеризация I этапа (раз в 2 года) закончилась ' + date_8( ar[ 1, i4, 2 ] ) + 'г.!'
      Endif
    Endif
  Else // if new_etap == 3
    If Empty( ar[ 1 ] ) // в этом году ещё ничего не делали
      If Empty( ar[ 2 ] ) // посмотрим прошлый год
        // оставляем 3
      Elseif AScan( ar[ 2 ], {| x| x[ 1 ] == 3 } ) > 0 // профилактика была в прошлом году
        If is_dostup_2_year
          new_etap := 4 // сразу разрешаем дисп-ию 1 раз в 2 года, т.к. в прошлом
        Else
          msg := 'Профилактика проводится 1 раз в 2 года (' + date_8( ar[ 2, 1, 2 ] ) + 'г. уже проведена)'
        Endif
      Endif
    Else
      i1 := i2 := i3 := i4 := i5 := 0
      For i := 1 To Len( ar[ 1 ] )
        Do Case
        Case ar[ 1, i, 1 ] == 1 // дисп-ия 1 этап
          i1 := i
          msg := date_8( ar[ 1, i, 2 ] ) + 'г. уже проведена диспансеризация I этапа!'
        Case ar[ 1, i, 1 ] == 2 // дисп-ия 2 этап
          i2 := i
          msg := date_8( ar[ 1, i, 2 ] ) + 'г. уже проведена диспансеризация II этапа!'
        Case ar[ 1, i, 1 ] == 3 // профилактика
          i3 := i
          msg := date_8( ar[ 1, i, 2 ] ) + 'г. уже проведён профилактический медосмотр!'
        Case ar[ 1, i, 1 ] == 4 // дисп-ия 1 этап раз в 2 года
          i4 := i
        Case ar[ 1, i, 1 ] == 5 // дисп-ия 2 этап раз в 2 года
          i5 := i
        Endcase
      Next
      If i4 > 0
        If i5 > 0
          msg := 'В ' + lstr( Year( mn_data ) ) + ' году уже проведены оба этапа диспансеризации (раз в 2 года)!'
        Elseif !Empty( ar[ 1, i4, 2 ] ) .and. ar[ 1, i4, 2 ] > mn_data
          msg := 'Диспансеризация I этапа (раз в 2 года) закончилась ' + date_8( ar[ 1, i4, 2 ] ) + 'г.!'
        Else
          new_etap := 5 // делаем 2 этап
        Endif
      Endif
    Endif
  Endif
altd()
  If Empty( msg )
    metap := new_etap
    mndisp := inieditspr( A__MENUVERT, mm_ndisp_dvn(), metap )
  Else
    metap := 0
    mndisp := Space( 23 )
    func_error( 4, fam_i_o( mfio ) + ' ' + msg )
  Endif

  Return fl

// 15.06.18 скорректировать возраст диспансеризации для ветеранов
Function ret_vozr_dvn_veteran( _dvozrast, _data )

  Local i, _arr_vozrast_DVN := ret_arr_vozrast_dvn( _data )

  If AScan( _arr_vozrast_DVN, _dvozrast ) == 0
    If _dvozrast < _arr_vozrast_DVN[ 1 ]
      _dvozrast := _arr_vozrast_DVN[ 1 ]
    Elseif _dvozrast > ATail( _arr_vozrast_DVN )
      _dvozrast := ATail( _arr_vozrast_DVN )
    Else
      For i := 2 To Len( _arr_vozrast_DVN )
        If Between( _dvozrast, _arr_vozrast_DVN[ i -1 ], _arr_vozrast_DVN[ i ] )
          If _dvozrast == _arr_vozrast_DVN[ i -1 ] + 1
            _dvozrast := _arr_vozrast_DVN[ i -1 ]
          Else
            _dvozrast := _arr_vozrast_DVN[ i ]
          Endif
          Exit
        Endif
      Next
    Endif
  Endif

  Return _dvozrast

// 15.06.19 вернуть массив возрастов дисп-ии для старого или нового Приказов МЗ РФ
Function ret_arr_vozrast_dvn( _data )

  Static sp := 0, arr := {}
  Local i, p := iif( _data < 0d20190501, 1, 2 )

  If p != sp
    arr := AClone( arr_vozrast_DVN() ) // по старому Приказу МЗ РФ
    If ( sp := p ) == 2 // по новому Приказу МЗ РФ
      ASize( arr, 7 ) // уберём хвост после 39 лет {21, 24, 27, 30, 33, 36, 39,
      ins_array( arr, 1, 18 ) // вставим в начало =18 лет
      For i := 40 To 99
        AAdd( arr, i ) // добавим в конец подряд с 40 по 99 лет
      Next
    Endif
  Endif

  Return arr
