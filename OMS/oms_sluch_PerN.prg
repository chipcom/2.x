#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 17.01.26 ПерН - добавление или редактирование случая (листа учета)
Function oms_sluch_pern( Loc_kod, kod_kartotek, f_print )

  // Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  // f_print - наименование функции для печати
  Static st_N_DATA, st_K_DATA, st_mo_pr := '      ', ;
    st_school := 0, st_tip_school := 0
  Local L_BEGIN_RSLT := 342
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
    i, j, k, n, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
    tmp_help := chm_help_code, fl_write_sluch := .f., _y, _m, _d, t_arr[ 2 ]
  //
  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0, f_print To ''
  //
  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      Return Nil
    Endif
  Endif
  chm_help_code := 3002
  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, mdvozrast, msvozrast := ' ', ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, M1VZ := 1, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС, 1-компании, 3-комитеты/ЛПУ, 5-личный счет
    msmo := '34007', rec_inogSMO := 0, ;
    mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := Space( 10 ), ; // вид и номер учетного документа
    MKOD_DIAG   := Space( 5 ), ; // шифр 1-ой осн.болезни
    MKOD_DIAG2  := Space( 5 ), ; // шифр 2-ой осн.болезни
    MKOD_DIAG3  := Space( 5 ), ; // шифр 3-ой осн.болезни
    MKOD_DIAG4  := Space( 5 ), ; // шифр 4-ой осн.болезни
    MSOPUT_B1   := Space( 5 ), ; // шифр 1-ой сопутствующей болезни
    MSOPUT_B2   := Space( 5 ), ; // шифр 2-ой сопутствующей болезни
    MSOPUT_B3   := Space( 5 ), ; // шифр 3-ой сопутствующей болезни
    MSOPUT_B4   := Space( 5 ), ; // шифр 4-ой сопутствующей болезни
    MDIAG_PLUS  := Space( 8 ), ; // дополнения к диагнозам
    adiag_talon[ 16 ], ; // из статталона к диагнозам
    m1rslt  := L_BEGIN_RSLT, ; // результат лечения
    m1ishod := 306, ; // исход = осмотр
    MN_DATA := st_N_DATA, ; // дата начала лечения
    MK_DATA := st_K_DATA, ; // дата окончания лечения
    MVRACH := Space( 10 ), ; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 4, ;   // Профилактический
    m1travma := 0, ;
    m1USL_OK := USL_OK_POLYCLINIC, ; // поликлиника
    m1VIDPOM :=  1, ; // первичная
    m1PROFIL := 68, ; // педиатрия
    m1IDSP   := 17   // законченный случай в п-ке
  //
  Private mperiod := 0, mshifr_zs := '', ;
    mMO_PR := Space( 10 ), m1MO_PR := st_mo_pr, ; // код МО прикрепления
  mschool := Space( 10 ), m1school := st_school, ; // код обр.учреждения
  mtip_school := Space( 10 ), m1tip_school := st_tip_school, ; // тип обр.учреждения
  mprotivo, m1protivo := 0, mgruppa := 0, m1GR_FIZ := 0
  Private mvar, m1var, m1lis := 0
  //
  For i := 1 To Len( nper_arr_issled() ) // исследования
    mvar := 'MTAB_NOMiv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMia' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATEi' + lstr( i )
    Private &mvar := CToD( '' )
    mvar := 'MREZi' + lstr( i )
    Private &mvar := Space( 17 )
    m1var := 'M1LIS' + lstr( i )
    Private &m1var := 0
    mvar := 'MLIS' + lstr( i )
    Private &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
  Next
  // педиатр
  Private MTAB_NOMpv1 := 0, MTAB_NOMpa1 := 0, MDATEp1 := CToD( '' ), MKOD_DIAGp1 := Space( 6 )
  //
  AFill( adiag_talon, 0 )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  If mkod_k > 0
    r_use( dir_server() + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server() + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    M1VZ        := kart->VZ
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR
    If kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    Endif
    If eq_any( is_uchastok, 1, 3 )
      MUCH_DOC := PadR( amb_kartan(), 10 )
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( mkod_k ), 10 )
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 1,, .t. ) // открыть и закрыть
    Endif
    // проверка исхода = СМЕРТЬ
    Select HUMAN
    Set Index to ( dir_server() + 'humankk' )
    arr_patient_died_during_treatment( mkod_k, loc_kod )
    Set Index To
    // a_smert := result_is_death(mkod_k, Loc_kod)
  Endif
  If Loc_kod > 0
    Select HUMAN
    Goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // адрес больного
    MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
    M1VZ        := human->VZ
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    m1okato    := human_->OKATO  // ОКАТО субъекта РФ территории страхования
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    //
    larr_i := Array( Len( nper_arr_issled() ) )
    AFill( larr_i, 0 )
    larr_p := {}
    mdate1 := mdate2 := CToD( '' )
    r_use( dir_server() + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      lshifr := AllTrim( lshifr )
      If Left( lshifr, 5 ) == '72.4.'
        mshifr_zs := lshifr
      Else
        fl := .t.
        For i := 1 To Len( nper_arr_issled() )
          If nper_arr_issled()[ i, 1 ] == lshifr
            fl := .f.
            larr_i[ i ] := hu->( RecNo() )
            Exit
          Endif
        Next
        If fl .and. eq_any( hu_->PROFIL, 68, 57 )
          AAdd( larr_p, { hu->( RecNo() ), c4tod( hu->date_u ) } )
        Endif
      Endif
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      Skip
    Enddo
    If Len( larr_p ) > 1 // если осмотров педиатра почему-то более 1
      ASort( larr_p, , , {| x, y| x[ 2 ] < y[ 2 ] } )  // отсортировать по дате
      ASize( larr_p, 1 ) // отрезать лишние приёмы
    Endif
    r_use( dir_server() + 'mo_pers', , 'P2' )
    For j := 1 To 2
      If j == 1
        _arr := larr_i
        bukva := 'i'
      Else
        _arr := larr_p
        bukva := 'p'
      Endif
      For i := 1 To Len( _arr )
        k := iif( j == 2, _arr[ i, 1 ], _arr[ i ] )
        If !Empty( k )
          hu->( dbGoto( k ) )
          If hu->kod_vr > 0
            p2->( dbGoto( hu->kod_vr ) )
            mvar := 'MTAB_NOM' + bukva + 'v' + lstr( i )
            &mvar := p2->tab_nom
          Endif
          If hu->kod_as > 0
            p2->( dbGoto( hu->kod_as ) )
            mvar := 'MTAB_NOM' + bukva + 'a' + lstr( i )
            &mvar := p2->tab_nom
          Endif
          mvar := 'MDATE' + bukva + lstr( i )
          &mvar := c4tod( hu->date_u )
          If j == 1
            m1var := 'm1lis' + lstr( i )
            If glob_yes_kdp2()[ TIP_LU_PERN ] .and. AScan( glob_arr_usl_LIS(), nper_arr_issled()[ i, 1 ] ) > 0 ;
                .and. hu->is_edit == 1
              &m1var := 1
            Endif
            mvar := 'mlis' + lstr( i )
            &mvar := inieditspr( A__MENUVERT, mm_kdp2, &m1var )
          Elseif !Empty( hu_->kod_diag ) .and. !( Left( hu_->kod_diag, 1 ) == 'Z' )
            mvar := 'MKOD_DIAG' + bukva + lstr( i )
            &mvar := hu_->kod_diag
          Endif
        Endif
      Next
    Next
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif
    read_arr_pern( Loc_kod )
  Endif
  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  Endif
  Close databases
  is_talon := .t.
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu( , -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  //
  If !Empty( m1MO_PR )
    mMO_PR := ret_mo( m1MO_PR )[ _MO_SHORT_NAME ]
  Endif
  mschool := inieditspr( A__POPUPMENU, dir_server() + 'mo_schoo', m1school )
  mtip_school := inieditspr( A__MENUVERT, mm_tip_school, m1tip_school )
  mprotivo := inieditspr( A__MENUVERT, mm_danet, m1protivo )
  //
  If !Empty( f_print )
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ',' + lstr( mvozrast ) + ')' )
  Endif
  //
  str_1 := ' случая периодического осмотра несовершеннолетних'
  If Loc_kod == 0
    str_1 := 'Добавление' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := 'Редактирование' + str_1
  Endif
  SetColor( color8 )
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  SetColor( cDataCGet )
  make_diagp( 1 )  // сделать 'шестизначные' диагнозы
  Do While .t.
    Close databases
    @ 0, 0 Say PadC( str_1, 80 ) Color 'B/BG*'
    j := 1
    myclear( j )
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( 'Лист учета № ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    @ ++j, 1 Say 'Учреждение' Get mlpu When .f. Color cDataCSay
    @ Row(), Col() + 2 Say 'Отделение' Get motd When .f. Color cDataCSay
    //
    @ ++j, 1 Say 'ФИО' Get mfio_kart ;
      reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      valid {| g, o| update_get( 'mdate_r' ), ;
      update_get( 'mkomu' ), update_get( 'mcompany' ) }
    @ Row(), Col() + 5 Say 'Д.р.' Get mdate_r When .f. Color color14
    @ ++j, 1 Say 'Принадлежность счёта' Get mkomu ;
      reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_komu( g, o ) } ;
      Color colget_menu
    @ Row(), Col() + 1 Say '==>' Get mcompany ;
      reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
      When m1komu < 5 ;
      valid {| g| func_valid_ismo( g, m1komu, 38 ) }
    @ ++j, 1 Say 'Полис ОМС: серия' Get mspolis When m1komu == 0
    @ Row(), Col() + 3 Say 'номер'  Get mnpolis When m1komu == 0
    @ Row(), Col() + 3 Say 'вид'    Get mvidpolis ;
      reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
      When m1komu == 0 ;
      Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
    @ ++j, 1 To j, 78
    @ ++j, 1 Say 'Сроки осмотра' Get mn_data ;
      valid {| g| f_k_data( g, 1 ), ;
      iif( mvozrast < 18, nil, func_error( 4, 'Это взрослый пациент!' ) ), ;
      msvozrast := PadR( count_ymd( mdate_r, mn_data ), 40 ), ;
      .t. ;
      }
    @ Row(), Col() + 1 Say '-' Get mk_data valid {| g| f_k_data( g, 2 ) }
    @ Row(), Col() + 3 Get msvozrast When .f. Color color14
    @ ++j, 1 Say '№ амбулаторной карты' Get much_doc Picture '@!' ;
      When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) ;
      .or. mem_edit_ist == 2
    ++j
    @ ++j, 1 Say 'МО прикрепления' Get mMO_PR ;
      reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION, , , .f. ) }
    @ ++j, 1 Say 'Общеобразовательное учреждение' Get mschool ;
      reader {| x| menu_reader( x, { dir_server() + 'mo_schoo', , , , , , 'Общеобразовательные учр-ия', 'B/BG' }, A__POPUPBASE1, , , .f. ) }
    @ ++j, 1 Say 'Тип общеобразовательного учреждения' Get mtip_school ;
      reader {| x| menu_reader( x, mm_tip_school, A__MENUVERT, , , .f. ) } ;
      valid {|| mperiod := iif( m1tip_school == 1, 1, 2 ), ;
      iif( mperiod == 1, ( MTAB_NOMiv3 := MTAB_NOMia3 := 0, MDATEi3 := CToD( '' ), MREZi3 := Space( 17 ) ), ), ;
      iif( mperiod == 2 .and. Empty( MDATEi3 ), MDATEi3 := mn_data, ), ;
      .t. }
    @ ++j, 1 To j, 78
    @ ++j, 1 Say 'Наименования исследований              Врач Ассис.  Дата     Результат' Color 'RB+/B'
    If mem_por_ass == 0
      @ j, 45 Say Space( 6 )
    Endif
    ++j
    If Empty( MDATEi1 )
      MDATEi1 := mn_data
    Endif
    @ j, 1 Say PadR( 'Общий анализ мочи', 38 )
    @ j, 39 Get MTAB_NOMiv1 Pict '99999' valid {| g| v_kart_vrach( g ) }
    If mem_por_ass > 0
      @ j, 45 Get MTAB_NOMia1 Pict '99999' valid {| g| v_kart_vrach( g ) }
    Endif
    @ j, 51 Get MDATEi1
    @ j, 62 Get MREZi1
    //
    ++j
    If Empty( MDATEi2 )
      MDATEi2 := mn_data
    Endif
    @ j, 1 Say PadR( 'Клинический анализ крови', 38 )
    If glob_yes_kdp2()[ TIP_LU_PERN ] .and. AScan( glob_arr_usl_LIS(), nper_arr_issled()[ 2, 1 ] ) > 0
      @ j, 34 Get mlis2 reader {| x| menu_reader( x, mm_kdp2, A__MENUVERT, , , .f. ) }
    Endif
    @ j, 39 Get MTAB_NOMiv2 Pict '99999' valid {| g| v_kart_vrach( g ) }
    If mem_por_ass > 0
      @ j, 45 Get MTAB_NOMia2 Pict '99999' valid {| g| v_kart_vrach( g ) }
    Endif
    @ j, 51 Get MDATEi2
    @ j, 62 Get MREZi2
    //
    ++j
    If mperiod == 1
      MTAB_NOMiv3 := MTAB_NOMia3 := 0
      MDATEi3 := CToD( '' )
      MREZi3 := Space( 17 )
    Elseif Empty( MDATEi3 )
      MDATEi3 := mn_data
    Endif
    @ j, 1 Say PadR( 'Анализ окиси углерода выдыхаем.воздуха', 38 )
    @ j, 39 Get MTAB_NOMiv3 Pict '99999' valid {| g| v_kart_vrach( g ) } ;
      When mperiod == 2
    If mem_por_ass > 0
      @ j, 45 Get MTAB_NOMia3 Pict '99999' valid {| g| v_kart_vrach( g ) } ;
        When mperiod == 2
    Endif
    @ j, 51 Get MDATEi3 When mperiod == 2
    @ j, 62 Get MREZi3 When mperiod == 2
    //
    @ ++j, 1 Say 'Наименование осмотра                   Врач Ассис.  Дата     Диагноз' Color 'RB+/B'
    If mem_por_ass == 0
      @ j, 45 Say Space( 6 )
    Endif
    ++j
    If Empty( MDATEp1 )
      MDATEp1 := mn_data
    Endif
    @ j, 1 Say PadR( 'педиатр (врач общей практики)', 38 ) Color color8
    @ j, 39 Get MTAB_NOMpv1 Pict '99999' valid {| g| v_kart_vrach( g ) }
    If mem_por_ass > 0
      @ j, 45 Get MTAB_NOMpa1 Pict '99999' valid {| g| v_kart_vrach( g ) }
    Endif
    @ j, 51 Get MDATEp1
    @ j, 62 Get MKOD_DIAGp1 Picture pic_diag ;
      reader {| o| mygetreader( o, bg ) } Valid val1_10diag( .t., .f., .f., mn_data, mpol )
    @ ++j, 1 To j, 78
    @ ++j, 1 Say 'Обнаружены медицинские противопоказания к продолжению учёбы?' Get mprotivo ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
    status_key( '^<Esc>^ - выход без записи; ^<PgDn>^ - запись' )
    If !Empty( a_smert )
      n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
    Endif
    count_edit += myread( , , ++k_read )
    k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
      { ' Выход без записи ', ' Запись ', ' Возврат в редактирование ' }, ;
      iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, N/BG' )
    If k == 3
      Loop
    Elseif k == 2
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0
          s := 'СМО'
        Elseif m1komu == 1
          s := 'компании'
        Else
          s := 'комитета/МО'
        Endif
        func_error( 4, 'Не заполнено наименование ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, 'Не заполнен номер полиса' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, 'Не введена дата начала лечения.' )
        Loop
      Endif
      If mvozrast >= 18
        func_error( 4, 'Периодический осмотр оказан взрослому пациенту!' )
        Loop
      Endif
      If !Between( mperiod, 1, 2 )
        func_error( 4, 'Не удалось определить возрастной период!' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, 'Не введена дата окончания лечения.' )
        Loop
      Elseif Year( mk_data ) == 2018
        func_error( 4, 'Периодические осмотры с 2018 года более не проводятся' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, 'Не заполнен номер амбулаторной карты' )
        Loop
      Endif
      If Empty( mmo_pr )
        func_error( 4, 'Не введено МО, к которому прикреплён несовершеннолетний.' )
        Loop
      Endif
      If Empty( m1school )
        func_error( 4, 'Не введено общеобразовательное учреждение.' )
        Loop
      Endif
      If mvozrast < 1
        mdef_diagnoz := 'Z00.1 '
      Elseif mvozrast < 14
        mdef_diagnoz := 'Z00.2 '
      Else
        mdef_diagnoz := 'Z00.3 '
      Endif
      arr_iss := Array( Len( nper_arr_issled() ), 10 )
      afillall( arr_iss, 0 )
      r_use( dir_exe() + '_mo_mkb', cur_dir() + '_mo_mkb', 'MKB_10' )
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
      max_date1 := max_date2 := mn_data
      fl := .t.
      ar := nPer_arr_1_etap[ mperiod ]
      For i := 1 To Len( nper_arr_issled() )
        If AScan( ar[ 5 ], nper_arr_issled()[ i, 1 ] ) > 0
          mvart := 'MTAB_NOMiv' + lstr( i )
          mvara := 'MTAB_NOMia' + lstr( i )
          mvard := 'MDATEi' + lstr( i )
          mvarr := 'MREZi' + lstr( i )
          If Empty( &mvard )
            fl := func_error( 4, 'Не введена дата иссл-ия "' + nper_arr_issled()[ i, 3 ] + '"' )
          Elseif Empty( &mvart )
            fl := func_error( 4, 'Не введен врач в иссл-ии "' + nper_arr_issled()[ i, 3 ] + '"' )
          Else
            Select P2
            find ( Str( &mvart, 5 ) )
            If Found()
              arr_iss[ i, 1 ] := p2->kod
              arr_iss[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
            Endif
            If !Empty( &mvara )
              Select P2
              find ( Str( &mvara, 5 ) )
              If Found()
                arr_iss[ i, 3 ] := p2->kod
              Endif
            Endif
            arr_iss[ i, 4 ] := nper_arr_issled()[ i, 5 ] // профиль
            arr_iss[ i, 5 ] := nper_arr_issled()[ i, 1 ] // шифр услуги
            arr_iss[ i, 6 ] := mdef_diagnoz
            arr_iss[ i, 9 ] := &mvard
            m1var := 'm1lis' + lstr( i )
            If glob_yes_kdp2()[ TIP_LU_PERN ] .and. &m1var == 1
              arr_iss[ i, 10 ] := 1 // кровь проверяют в КДП2
            Endif
            max_date1 := Max( max_date1, arr_iss[ i, 9 ] )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      If emptyany( MTAB_NOMpv1, MDATEp1 )
        fl := func_error( 4, 'Не введён педиатр (врач общей практики)' )
      Elseif MDATEp1 < max_date1
        fl := func_error( 4, 'Педиатр (врач общей практики) должен проводить осмотр последним!' )
      Endif
      If !fl
        Loop
      Endif
      m1rslt := L_BEGIN_RSLT
      //
      err_date_diap( mn_data, 'Дата начала лечения' )
      err_date_diap( mk_data, 'Дата окончания лечения' )
      //
      message_save_LU()
      mywait( 'Ждите. Производится запись листа учёта...' )
      m1lis := 0
      If glob_yes_kdp2()[ TIP_LU_PN ]
        For i := 1 To Len( nper_arr_issled() )
          If ValType( arr_iss[ i, 9 ] ) == 'D' .and. arr_iss[ i, 9 ] >= mn_data .and. Len( arr_iss[ i ] ) > 9 ;
              .and. ValType( arr_iss[ i, 10 ] ) == 'N' .and. arr_iss[ i, 10 ] == 1
            m1lis := 1 // в рамках диспансеризации
          Endif
        Next
      Endif
      arr_osm1 := {}
      // добавим педиатра
      AAdd( arr_osm1, add_pediatr_pern( MTAB_NOMpv1, MTAB_NOMpa1, MDATEp1, MKOD_DIAGp1 ) )
      i := Len( arr_osm1 )
      m1vrach  := arr_osm1[ i, 1 ]
      m1prvs   := arr_osm1[ i, 2 ]
      m1assis  := arr_osm1[ i, 3 ]
      m1PROFIL := arr_osm1[ i, 4 ]
      MKOD_DIAG := PadR( arr_osm1[ i, 6 ], 6 )
      // добавим код законченного случая
      AAdd( arr_osm1, Array( 9 ) )
      i := Len( arr_osm1 )
      arr_osm1[ i, 1 ] := arr_osm1[ i -1, 1 ]
      arr_osm1[ i, 2 ] := arr_osm1[ i -1, 2 ]
      arr_osm1[ i, 3 ] := arr_osm1[ i -1, 3 ]
      arr_osm1[ i, 4 ] := 48 // медицинским осмотрам (предварительным, периодическим)
      arr_osm1[ i, 5 ] := ret_shifr_zs_pern( mperiod )
      arr_osm1[ i, 6 ] := arr_osm1[ i -1, 6 ]
      arr_osm1[ i, 9 ] := mn_data
      Select MKB_10
      find ( MKOD_DIAG )
      If Found() .and. !between_date( mkb_10->dbegin, mkb_10->dend, mk_data )
        MKOD_DIAG := mdef_diagnoz // если диагноз не входит в ОМС, то умолчание
      Endif
      make_diagp( 2 )  // сделать 'пятизначные' диагнозы
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      Private mu_cena
      mcena_1 := 0
      arr_usl_dop := {}
      glob_podr := ''
      glob_otd_dep := 0
      For i := 1 To Len( arr_iss )
        If ValType( arr_iss[ i, 5 ] ) == 'C'
          arr_iss[ i, 7 ] := foundourusluga( arr_iss[ i, 5 ], mk_data, arr_iss[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_iss[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          AAdd( arr_usl_dop, arr_iss[ i ] )
        Endif
      Next
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == 'C'
          arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_osm1[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          AAdd( arr_usl_dop, arr_osm1[ i ] )
        Endif
      Next
      //
      use_base( 'human' )
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        mkod := Loc_kod
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace human->kod With mkod
      Endif
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      st_N_DATA := MN_DATA
      st_K_DATA := MK_DATA
      st_mo_pr := m1mo_pr
      st_school := m1school
      st_tip_school := m1tip_school
      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ''
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-лечение завершено
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий
      human->VZ         := M1VZ          // Вид занятости, указывается в соответствии со справочником V039 ФФОМС
      human->KOD_DIAG   := mkod_diag     // шифр 1-ой осн.болезни
      human->diag_plus  := mdiag_plus    //
      human->ZA_SMO     := 0
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 305
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := '' ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      // human_->POVOD     := m1povod
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( '' )
      human_->POL2      := ''
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := 17
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём '2', если отредактировали запись из реестра СП и ТК
      human_->ST_VERIFY := 0 // снова ещё не проверен
      If Loc_kod == 0  // при добавлении
        human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
        human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // код оператора
        human->date_e  := c4sys_date
      Else // при редактированиии
        human_->kod_p2  := kod_polzovat    // код оператора
        human_->date_e2 := c4sys_date
      Endif
      put_0_human_2()
      Private fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ОКАТО субъекта РФ территории страхования
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // заменяем '34' на код иногородней СМО
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        g_use( dir_server() + 'mo_hismo', , 'SN' )
        Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_ismo' )
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            sn->smo_name := mnameismo
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            sn->kod := mkod
            sn->smo_name := mnameismo
          Endif
        Endif
      Endif
      i1 := Len( arr_usl )
      i2 := Len( arr_usl_dop )
      use_base( 'human_u' )
      For i := 1 To i2
        Select HU
        If i > i1
          add1rec( 7 )
          hu->kod := human->kod
        Else
          Goto ( arr_usl[ i ] )
          g_rlock( forever )
        Endif
        mrec_hu := hu->( RecNo() )
        hu->kod_vr  := arr_usl_dop[ i, 1 ]
        hu->kod_as  := arr_usl_dop[ i, 3 ]
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[ i, 7 ]
        hu->u_cena  := arr_usl_dop[ i, 8 ]
        hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 9 .and. ValType( arr_usl_dop[ i, 10 ] ) == 'N', arr_usl_dop[ i, 10 ], 0 )
        hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
        Select HU_
        Do While hu_->( LastRec() ) < mrec_hu
          Append Blank
        Enddo
        Goto ( mrec_hu )
        g_rlock( forever )
        If i > i1 .or. !valid_guid( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->PROFIL := arr_usl_dop[ i, 4 ]
        hu_->PRVS   := arr_usl_dop[ i, 2 ]
        hu_->kod_diag := arr_usl_dop[ i, 6 ]
        hu_->zf := ''
        Unlock
      Next
      If i2 < i1
        For i := i2 + 1 To i1
          Select HU
          Goto ( arr_usl[ i ] )
          deleterec( .t., .f. )  // очистка записи без пометки на удаление
        Next
      Endif
      save_arr_pern( mkod )
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( 'Запись завершена!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // если записали - запускаем проверку
    If Type( 'fl_edit_DDS' ) == 'L'
      fl_edit_DDS := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil
