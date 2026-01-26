#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 24.01.26 жидкостная цитология рака шейки матки
Function oms_sluch_g_cit( Loc_kod, kod_kartotek )

  // Loc_kod - код по БД human.dbf (если = 0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  Static st_N_DATA, sv1 := 0
  static st_MOP := 1
  Local arr_del := {}, mrec_hu := 0, buf := SaveScreen(), tmp_color := SetColor(), ;
    a_smert := {}, p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
    i, j, k, n, s, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, larr, lu_kod, ;
    tmp_help := chm_help_code, fl_write_sluch := .f., t_arr[ 2 ], ;
    bg := {| o, k| get_mkb10( o, k, .t. ) }
  Local top2 := 11

  If Empty( glob_klin_diagn() )
    Return func_error( 4, 'В вашем учреждении не разрешены специальные лабораторные исследования' )
  Endif
  //
  Default st_N_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  //
  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      Return Nil
    Endif
  Endif
  chm_help_code := 3002

  Private tmp_V040 := create_classif_ffoms( 2, 'V040' ) // MOP

  Private mfio := Space( 50 ), mpol, mdate_r, madres, mvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    M1VZ := 1, ;
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
    MKOD_DIAG   := 'Z01.7', ; // шифр 1-ой осн.болезни
    m1rslt  := 314, ; // результат лечения
    m1ishod := 304, ; // исход = без перемен
    m1NPR_MO := '', mNPR_MO := Space( 10 ), mNPR_DATE := CToD( '' ), ;
    MN_DATA := st_N_DATA, ; // дата начала лечения
    MK_DATA, ;
    MVRACH := Space( 10 ), ; // фамилия и инициалы лечащего врача
    M1VRACH := 0, MTAB_NOM := sv1, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
    m1povod  := 1, ;   // Лечебно-диагностический
    m1travma := 0
  Private m1MOP := st_MOP, mMOP := Space( 25 )    // место обращения (посещения) tmp_V040
  private m1MO_PR := Space( 6 ), mMO_PR := Space( 20 ) // МО прикрепления
  private m1profil_m := 0
  //
  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
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

    m1MO_PR := code_TFOMS_to_FFOMS( kart2->mo_pr )
    if Empty( m1MO_PR )
      mMO_PR := Space( 20 )
    else
      mMO_PR := Substr( inieditspr( A__MENUVERT, get_f032_prik(), m1MO_PR ), 1, 20 )
    endif

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
      mnameismo := ret_inogsmo_name( 1, , .t. ) // открыть и закрыть
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
    m1NPR_MO    := human_->NPR_MO
    mNPR_DATE   := human_2->NPR_DATE
    m1VRACH     := human_->vrach
    MKOD_DIAG   := human->KOD_DIAG
    m1MO_PR     := human->mo_pr
    MPOLIS      := human->POLIS         // серия и номер страхового полиса
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
    m1MOP      := human->MOP           // место обращения
    //
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. ! hu->( Eof() )
      AAdd( arr_usl, hu->( RecNo() ) )
      Select HU
      hu->( dbSkip() )
    Enddo
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif
  Endif
  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  Endif
  If m1vrach > 0
    r_use( dir_server() + 'mo_pers', , 'P2' )
    Goto ( m1vrach )
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
    // mvrach := padr(fam_i_o(p2->fio) + ' ' + ret_tmp_prvs(m1prvs), 36)
    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_str_spec( p2->PRVS_021 ), 36 )
  Endif
  Close databases
  is_talon := .t.
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  If !Empty( m1NPR_MO )
    mNPR_MO := ret_mo( m1NPR_MO )[ _MO_SHORT_NAME ]
  Endif
  MKOD_DIAG := PadR( MKOD_DIAG, 6 )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf(), m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  mMOP      := SubStr( inieditspr( A__MENUVERT, getv040(), m1MOP ), 1, 25 )

  if Empty( m1MO_PR )
    mMO_PR := Space( 20 )
  else
    mMO_PR := Substr( inieditspr( A__MENUVERT, get_f032_prik(), m1MO_PR ), 1, 20 )
  endif

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
  str_1 := ' случая леч.-диагн.процедуры при проведении '
  If AScan( glob_klin_diagn(), 1 ) > 0
    str_1 += 'жидкостной цитологии'
  Elseif AScan( glob_klin_diagn(), 2 ) > 0
    str_1 += 'пренатального скрининга'
  Endif
  If Loc_kod == 0
    str_1 := 'Добавление' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := 'Редактирование' + str_1
  Endif
  SetColor( color8 )
  myclear( top2 )
  @ top2 -1, 0 Say PadC( str_1, 80 ) Color 'B/BG*'
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  SetColor( cDataCGet )
  diag_screen( 0 )
  Do While .t.
    Close databases
    j := top2
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( 'Лист учета № ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    @ ++j, 1 Say 'Учреждение' Get mlpu When .f. Color cDataCSay
    @ Row(), Col() + 2 Say 'Отделение' Get motd When .f. Color cDataCSay
    //
    @ ++j, 1 Say 'ФИО' Get mfio_kart ;
      reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ), ;
      update_get( 'mspolis' ), update_get( 'mnpolis' ), ;
      update_get( 'mvidpolis' ) }
    @ Row(), Col() + 5 Say 'Д.р.' Get mdate_r When .f. Color color14
    //
    @ ++j, 1 Say 'Направление: дата' Get mNPR_DATE
    @ j, Col() + 1 Say 'из МО' Get mNPR_MO ;
      reader {| x| menu_reader( x, { {| k, r, c| f_get_mo( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      Color colget_menu
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

    @ ++j, 1 Say 'МО прикрепления' Get mMO_PR ;
      reader {| x| menu_reader( x, get_f032_prik(), A__MENUVERT_SPACE, , , .f., , , , 19 ) } // с возможностью очистки по SPACE

    if glob_otd[ 3 ] == USL_OK_POLYCLINIC
      @ j, Col() + 1 Say 'Место обращения' Get mMOP ;
        reader {| x| menu_reader( x, tmp_V040, A__MENUVERT, , , .f., , , , 25 ) }
    endif

    //
    @ ++j, 1 To j, 78
    @ ++j, 1 Say 'Дата процедуры' Get mn_data ;
      valid {| g| f_k_data( g, 1 ), mk_data := mn_data, f_k_data( g, 2 ) }

    @ ++j, 1 Say '№ амбулаторной карты' Get much_doc Picture '@!' ;
      When diag_screen( 2 ) .and. ;
      ( !( is_uchastok == 1 .and. is_task( X_REGIST ) ) .or. mem_edit_ist == 2 )
    @ ++j, 1 Say 'Основной диагноз' Get mkod_diag Picture pic_diag reader {| o| mygetreader( o, bg ) } When when_diag() Valid val1_10diag( .t., .t., .t., mn_data, mpol )
    @ ++j, 1 Say 'Табельный номер лечащего врача' ;
      Get MTAB_NOM Pict '99999' valid {| g| v_kart_vrach( g, .t. ) } ;
      When diag_screen( 2 )
    @ Row(), Col() + 1 Get mvrach When .f. Color color14
    status_key( '^<Esc>^ - выход без записи; ^<PgDn>^ - запись' )
    If !Empty( a_smert )
      n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
    Endif
    count_edit += myread( , , ++k_read )
    diag_screen( 2 )
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
      Elseif m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, 'Не заполнен номер полиса' )
        Loop
      Elseif mpol == 'М'
        func_error( 4, 'Данная процедура выполняется только для женщин.' )
        Loop
      Elseif Empty( mn_data )
        func_error( 4, 'Не введена дата процедуры.' )
        Loop
      Elseif Empty( MTAB_NOM )
        func_error( 4, 'Не введен табельный номер врача' )
        Loop
      Elseif Empty( m1NPR_MO )
        func_error( 4, 'Не введена направившая медицинская организация' )
        Loop
      Elseif Left( mkod_diag, 1 ) == 'Z' .and. !( AllTrim( mkod_diag ) == 'Z01.7' )
        func_error( 4, 'Основной диагноз на Z может быть только Z01.7' )
        Loop
      Endif
      If Empty( mkod_diag )
        mkod_diag := 'Z01.7 '
      Endif
      arr_iss := Array( 1, 9 )
      afillall( arr_iss, 0 )
      r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2' )
      find ( Str( MTAB_NOM, 5 ) )
      If Found()
        arr_iss[ 1, 1 ] := p2->kod
        arr_iss[ 1, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
      Endif
      arr_iss[ 1, 4 ] := 34 // профиль - клиническая лабораторная диагностика
      If AScan( glob_klin_diagn(), 1 ) > 0 // жидкостной цитологии
        arr_iss[ 1, 5 ] := '4.20.702' // шифр услуги
      Elseif AScan( glob_klin_diagn(), 2 ) > 0 // пренатального скрининга
        arr_iss[ 1, 5 ] := '4.15.746' // шифр услуги
      Endif
      err_date_diap( mn_data, 'Дата диагностики' )
      //
      message_save_LU()
      mywait()
      //
      sv1 := MTAB_NOM
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
          arr_iss[ i, 7 ] := foundourusluga( arr_iss[ i, 5 ], mn_data, arr_iss[ i, 4 ], M1VZROS_REB, @mu_cena )
          arr_iss[ i, 8 ] := mu_cena
          mcena_1 += mu_cena
          AAdd( arr_usl_dop, arr_iss[ i ] )
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
      If IsBit( mem_oms_pole, 7 )  // место обращения (посещения) tmp_V040  7
        st_MOP := m1MOP
      endif
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
      human_->KOD_DIAG0 := ''
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOD_DIAG2  := ''
      human->KOD_DIAG3  := ''
      human->KOD_DIAG4  := ''
      human->SOPUT_B1   := ''
      human->SOPUT_B2   := ''
      human->SOPUT_B3   := ''
      human->SOPUT_B4   := ''
      human->diag_plus  := ''            //
      human->ZA_SMO     := 0
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MN_DATA       // дата окончания лечения
      human->CENA := human->CENA_1 := MCENA_1 // стоимость лечения
      human->ishod      := 98 // жидкостная цитология рака шейки матки
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human->MOP        := m1MOP
      human->MO_PR      := m1MO_PR
      human->PROFIL_M   := m1profil_m
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      human_->DISPANS   := Replicate( '0', 16 )
      human_->STATUS_ST := ''
      human_->POVOD     := 9 // {'2.6-Посещение по другим обстоятельствам', 9,'2.6'}, ;
      // human_->TRAVMA    := m1travma
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( '' )
      human_->POL2      := ''
      human_->USL_OK    := 3
      human_->VIDPOM    := 13
      human_->PROFIL    := 34 // клинической лабораторной диагностике
      human_->IDSP      := 4 // лечебно-диагностическая процедура
      human_->NPR_MO    := m1NPR_MO
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := 314 // динамическое наблюдение
      human_->ISHOD_NEW := 304 // исход = без перемен
      human_->VRACH     := arr_iss[ 1, 1 ]
      human_->PRVS      := arr_iss[ 1, 2 ]
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
      human_2->NPR_DATE := mNPR_DATE
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
        hu->kod_as  := 0
        hu->u_koef  := 1
        hu->u_kod   := arr_usl_dop[ i, 7 ]
        hu->u_cena  := arr_usl_dop[ i, 8 ]
        hu->is_edit := 0
        hu->date_u  := dtoc4( mn_data )
        hu->otd     := m1otd
        hu->kol := hu->kol_1 := 1
        hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
        Select HU_
        Do While hu_->( LastRec() ) < mrec_hu
          hu_->( dbAppend() )
        Enddo
        Goto ( mrec_hu )
        g_rlock( forever )
        If i > i1 .or. !valid_guid( hu_->ID_U )
          hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
        Endif
        hu_->PROFIL := arr_usl_dop[ i, 4 ]
        hu_->PROFIL_M := m1profil_m
        hu_->PRVS   := arr_usl_dop[ i, 2 ]
        hu_->kod_diag := mkod_diag
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
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( 'Запись завершена!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  diag_screen( 2 )
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
