#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// согласно письму ТФОМС 09-30-276 от 29.08.22 года - отменено
// согласно письму ТФОМС 09-30-376/1 от 09.11.22 года
#define CHILD_EXIST .f. // учитывать несовершеннолетних или нет

// 25.06.24 добавление или редактирование случая (листа учета)
Function oms_sluch_onko_disp( Loc_kod, kod_kartotek )

  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)
  Static SKOD_DIAG := '     ', st_N_DATA, st_K_DATA, ;
    st_vrach := 0, st_profil := 0, st_profil_k := 0, ;
    st_rslt := 314, ; // динамическое наблюдение
  st_ishod := 304 // без перемен

  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, ;
    buf, tmp_color := SetColor(), a_smert := {}, ;
    p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    fl_write_sluch := .f., when_uch_doc := .t., ;
    arr_del := {}, mrec_hu := 0
  Local mm_da_net := { { 'нет', 0 }, { 'да ', 1 } }
  Local caption_window
  Local top2, s
  Local mtip_h
  Local vozrast
  Local lshifr := PadR( '2.5.2', 10 )

  Default st_N_DATA To sys_date, st_K_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  If kod_kartotek == 0 // добавление в картотеку
    If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      Return Nil
    Endif
  Endif
  buf := SaveScreen()
  If is_uchastok == 1 .and. is_task( X_REGIST ) // У23/12356 и есть 'Регистратура'
    when_uch_doc := ( mem_edit_ist == 2 )
  Endif
  //
  // ДЛЯ ПАЦИЕНТА ИЗ КАРТОТЕКИ
  Private mkod := Loc_kod,  ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    mfio := Space( 50 ),  mpol, mdate_r, madres, mmr_dol, ;
    M1FIO_KART := 1, MFIO_KART, ;
    M1VZROS_REB, MVZROS_REB, mpolis, M1RAB_NERAB, ;
    MUCH_DOC    := Space( 10 ), ; // вид и номер учетного документа
  m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-ОМС, 1-компании, 3-комитеты/ЛПУ, 5-личный счет
  msmo := '34007',  rec_inogSMO := 0, ;
    mokato, m1okato := '',  mismo, m1ismo := '',  mnameismo := Space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ),  mnpolis := Space( 20 )

  //
  Private tmp_V006 := create_classif_ffoms( 2, 'V006' ) // USL_OK
  Private tmp_V002 := create_classif_ffoms( 2, 'V002' ) // PROFIL
  Private tmp_V020 := create_classif_ffoms( 2, 'V020' ) // PROFIL_K
  // Private tmp_V009 := cut_glob_array(getV009(), sys_date) // rslt
  // Private tmp_V012 := cut_glob_array(getV012(),sys_date) // ishod
  Private tmp_V009 := getv009( sys_date ) // rslt
  Private tmp_V012 := getv012( sys_date ) // ishod
  Private mm_N002
  Private mm_rslt, mm_ishod, rslt_umolch := 0, ishod_umolch := 0
  //
  Private ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    MKOD_DIAG   := SKOD_DIAG, ; // шифр 1-ой осн.болезни
  MKOD_DIAG0  := Space( 6 ), ; // шифр первичного диагноза
  MKOD_DIAG2  := Space( 5 ), ; // шифр 2-ой осн.болезни
  MKOD_DIAG3  := Space( 5 ), ; // шифр 3-ой осн.болезни
  MKOD_DIAG4  := Space( 5 ), ; // шифр 4-ой осн.болезни
  MSOPUT_B1   := Space( 5 ), ; // шифр 1-ой сопутствующей болезни
  MSOPUT_B2   := Space( 5 ), ; // шифр 2-ой сопутствующей болезни
  MSOPUT_B3   := Space( 5 ), ; // шифр 3-ой сопутствующей болезни
  MSOPUT_B4   := Space( 5 ), ; // шифр 4-ой сопутствующей болезни
  MDIAG_PLUS  := Space( 8 ), ; // дополнения к диагнозам
  MOSL1 := Space( 6 ), ; // шифр 1-ого диагноза осложнения заболевания
  MOSL2 := Space( 6 ), ; // шифр 2-ого диагноза осложнения заболевания
  MOSL3 := Space( 6 ), ; // шифр 3-ого диагноза осложнения заболевания
  mrslt, m1rslt := st_rslt, ; // результат
  mishod, m1ishod := st_ishod, ; // исход
  MN_DATA     := st_N_DATA, ; // дата начала лечения
  MK_DATA     := st_K_DATA, ; // дата окончания лечения
  MCENA_1     := 0, ; // стоимость лечения
  MVRACH      := Space( 10 ), ; // фамилия и инициалы лечащего врача
  M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // код, таб.№ и спец-ть лечащего врача
  m1USL_OK := USL_OK_POLYCLINIC, mUSL_OK, ;             // амбулаторно
    m1PROFIL := st_profil, mPROFIL, ;
    m1PROFIL_K := st_profil_k, mPROFIL_K, ;
    m1IDSP   := 29, ;                     // за посещение
    mdate_next := sys_date, ;  // ctod('')                // дата следующего посещения
  mSTAD, m1STAD := 0 // Стадия заболевания      Заполняется в соответствии со справочником N002

  Private mm_profil := { { 'педиатрия', 68 }, ;
    { 'гематология', 12 }, ;
    { 'детская онкология', 18 }, ;
    { 'онкология', 60 }, ;
    { 'общей врачебной практики', 57 } }

  //
  r_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'SL' )
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
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ОКАТО субъекта РФ территории страхования
    msmo        := kart_->SMO
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
    // find (str(mkod_k, 7))
    // do while human->kod_k == mkod_k .and. !eof()
    // if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
    // human_->oplata != 9 .and. human_->NOVOR == 0
    // a_smert := {'Данный больной умер!', ;
    // 'Лечение с ' + full_date(human->N_DATA) + ' по ' + full_date(human->K_DATA)}
    // exit
    // endif
    // skip
    // enddo
    arr_patient_died_during_treatment( mkod_k, loc_kod )
    Set Index To
  Endif
  If Loc_kod > 0
    Select HUMAN
    Goto ( Loc_kod )
    MTIP_H      := human->tip_h
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    // будем брать из картотеки
    // mfio        := human->fio
    // mpol        := human->pol
    // mdate_r     := human->date_r
    // M1VZROS_REB := human->VZROS_REB
    // MADRES      := human->ADRES         // адрес больного
    // MMR_DOL     := human->MR_DOL        // место работы или причина безработности
    // M1RAB_NERAB := human->RAB_NERAB     // 0-работающий, 1-неработающий
    //
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MKOD_DIAG   := human->KOD_DIAG
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
    m1USL_OK   := human_->USL_OK
    m1PROFIL   := human_->PROFIL
    m1PROFIL_K := human_2->PROFIL_K
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    // m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    mcena_1    := human->CENA_1
    mdate_next := c4tod( human->DATE_OPL )
    //
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // открыть и закрыть
    Endif

    Select SL
    find ( Str( Loc_kod, 7 ) )
    If Found()
      m1STAD := sl->STAD
    Endif
    mm_N002 := f_define_tnm( 2, mkod_diag )
    mSTAD  := PadR( inieditspr( A__MENUVERT, mm_N002, m1STAD ), 5 )

    // выберем услуги
    r_use( dir_server() + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      If mrec_hu == 0
        mrec_hu := hu->( RecNo() )
      Else
        AAdd( arr_del, hu->( RecNo() ) )
      Endif
      Select HU
      Skip
    Enddo
    For i := 1 To Len( arr_del )
      Select HU
      Goto ( arr_del[ i ] )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
    Next
  Endif

  // готовим список профилей по возрасту
  vozrast := count_years( mdate_r, mk_data )
  If vozrast < 18 .and. CHILD_EXIST
    hb_ADel( mm_profil, 5, .t. )
    hb_ADel( mm_profil, 4, .t. )
  Elseif vozrast < 18 .and. ! CHILD_EXIST
    func_error( 4, 'Данный лист учета допустим только для совершеннлетних пациентов' )
    Close databases
    Return Nil
  Else
    hb_ADel( mm_profil, 5, .t. )
    hb_ADel( mm_profil, 3, .t. )
    // hb_ADel(mm_profil, 2, .t.)
    hb_ADel( mm_profil, 1, .t. )
  Endif

  If m1PROFIL == 0
    If vozrast < 18 .and. CHILD_EXIST
      m1PROFIL := 18  // детская онкология
    Else
      m1PROFIL := 60  // онкология
    Endif
  Endif
  mPROFIL := inieditspr( A__MENUVERT, mm_profil, m1PROFIL )

  If !( Left( msmo, 2 ) == '34' ) // не Волгоградская область
    m1ismo := msmo
    msmo := '34'
  Endif

  If Loc_kod == 0
    r_use( dir_server() + 'mo_otd', , 'OTD' )
    Goto ( m1otd )
    m1USL_OK := otd->IDUMP
    If Empty( m1PROFIL )
      m1PROFIL := otd->PROFIL
    Endif
    If Empty( m1PROFIL_K )
      m1PROFIL_K := otd->PROFIL_K
    Endif
  Endif
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  Goto ( m1lpu )
  mlpu := RTrim( uch->name )

  If m1vrach > 0
    r_use( dir_server() + 'mo_pers', , 'P2' )
    Goto ( m1vrach )
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
    // mvrach := padr(fam_i_o(p2->fio) + ' ' + ret_tmp_prvs(m1prvs), 36)
    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_str_spec( p2->PRVS_021 ), 36 )
  Endif

  Close databases
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  If Empty( m1USL_OK )
    m1USL_OK := USL_OK_POLYCLINIC
  Endif // на всякий случай
  mishod    := inieditspr( A__MENUVERT, getv012(), m1ishod )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  motd      := inieditspr( A__POPUPMENU, dir_server() + 'mo_otd',  m1otd )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany  := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  caption_window := ' случая постановки на диспансерный учет онкологического пациента'
  If Loc_kod == 0
    caption_window := 'Добавление' + caption_window
    mtip_h := yes_vypisan
  Else
    caption_window := 'Редактирование' + caption_window
  Endif

  SetColor( color8 )
  top2 := 10
  myclear( top2 )
  @ top2 -1, 0 Say PadC( caption_window, 80 ) Color "B/BG*"
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  @ MaxRow(), 0 Say PadC( '<Esc> - выход;  <PgDn> - запись', MaxCol() + 1 ) Color color0
  mark_keys( { '<F1>', '<Esc>', '<PgDn>' }, 'R/BG' )
  SetColor( cDataCGet )
  make_diagp( 1 )  // сделать "шестизначные" диагнозы
  diag_screen( 0 )

  Private rdiag := 1, rpp := 1

  Do While .t.
    j := top2
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( 'Лист учета № ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    pos_read := 0
    //
    @ ++j, 1 Say 'Учреждение' Get mlpu When .f. Color cDataCSay
    @ Row(), Col() + 2 Say 'Отделение' Get motd When .f. Color cDataCSay
    //
    //
    ++j
    @ ++j, 1 Say 'ФИО' Get mfio_kart ;
      reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
      valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ), ;
      update_get( 'mspolis' ), update_get( 'mnpolis' ), ;
      update_get( 'mvidpolis' ) }
    //
    //
    @ ++j, 1 Say 'Принадлежность счёта' Get mkomu ;
      reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_komu( g, o ) } ;
      Color colget_menu
    @ Row(), Col() + 1 Say '==>' Get mcompany ;
      reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
      When diag_screen( 2 ) .and. m1komu < 5 ;
      valid {| g| func_valid_ismo( g, m1komu, 38 ) }
    //
    @ ++j, 1 Say 'Полис ОМС: серия' Get mspolis When m1komu == 0
    @ Row(), Col() + 3 Say 'номер' Get mnpolis When m1komu == 0
    @ Row(), Col() + 3 Say 'вид'   Get mvidpolis ;
      reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
      When m1komu == 0 ;
      Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
    //
    ++j
    //
    //
    @ ++j, 1 Say '№ амб.карты (истории)' Get much_doc Picture '@!' When when_uch_doc
    //
    @ ++j, 1 Say 'Профиль' Get mPROFIL ;
      reader {| x| menu_reader( x, mm_profil, A__MENUVERT, , , .f. ) } // ; color colget_menu
    //
    @ ++j, 1 Say 'Дата постановки на диспансерный учет' Get mn_data valid {| g| f_k_data( g, 1 ) }
    //
    //
    ++j
    @ j, 1 Say 'Дата следующей явки для диспансерного наблюдения' Get mdate_next valid ( mdate_next > MN_DATA )
    //
    ++j
    @ j, 1 Say 'Основной диагноз' Get mkod_diag Picture pic_diag ;
      reader {| o| mygetreader( o, bg ) } ;
      When when_diag() ;
      valid {|| val1_10diag( .t., .t., .t., mn_data, mpol ),  f_valid_onko_diag( mkod_diag, mdate_r, MN_DATA, CHILD_EXIST ) }

    @ Row(), Col() + 1 Say 'Стадия заболевания:' Get mSTAD ;
      reader {| x| menu_reader( x, mm_N002, A__MENUVERT, , , .f. ) } ;
      valid {| g| f_valid_tnm( g ),  mSTAD := PadR( mSTAD, 5 ),  .t. } ;
      Color colget_menu

    // @ row(), col() + 1 say 'Врач' get MTAB_NOM pict '99999' ;
    @ ++j, 1 Say 'Врач' Get MTAB_NOM Pict '99999' ;
      valid {| g| v_kart_vrach( g, .t. ), f_valid_onko_vrach( MTAB_NOM, mdate_r, MN_DATA, CHILD_EXIST ) } When diag_screen( 2 )
    @ Row(), Col() + 1 Get mvrach When .f. Color color14
    //

    count_edit += myread(, @pos_read )

    k := f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
      { ' Выход без записи ',  ' Запись ',  ' Возврат в редактирование ' }, ;
      iif( LastKey() == K_ESC, 1, 2 ),  'W+/N',  'N+/N', MaxRow() -2, , 'W+/N,N/BG' )
    If k == 3
      Loop
    Elseif k == 2 // запись информации
      If Empty( mn_data )
        func_error( 4, 'Не введена дата постановки на учет' )
        Loop
      Endif
      MK_DATA := MN_DATA  // даты должны совпадать
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
      If Empty( mfio )
        func_error( 4, 'Не введены Ф.И.О. Нет записи!' )
        Loop
      Endif
      If Empty( mdate_r )
        func_error( 4, 'Не заполнена дата рождения' )
        Loop
      Endif
      If Empty( mdate_next )
        func_error( 4, 'Не заполнена дата следующего посещения' )
        Loop
      Endif
      If mdate_next <= MK_DATA
        func_error( 4, 'Не верная дата следующего посещения' )
        Loop
      Endif
      // if eq_any(m1vid_ud,3,14) .and. !empty(mser_ud) .and. empty(del_spec_symbol(mmesto_r))
      // func_error(4,iif(m1vid_ud == 3, 'Для свид-ва о рождении', 'Для паспорта РФ') + ;
      // ' обязательно заполнение поля "Место рождения"')
      // loop
      // endif
      If Empty( mkod_diag )
        func_error( 4, 'Не введен шифр основного заболевания.' )
        Loop
      Endif

      mywait( 'Ждите. Производится запись листа учёта ...' )
      // далее проверки и запись

      make_diagp( 2 )  // сделать 'пятизначные' диагнозы
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
        dir_server() + 'uslugi1s' }, 'USL1' )
      Private mu_kod, mu_cena
      mu_kod := foundourusluga( lshifr, mk_data, m1PROFIL, M1VZROS_REB, @mu_cena )

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
      human->TIP_H      := B_STANDART
      human->FIO        := MFIO          // Ф.И.О. больного
      human->POL        := MPOL          // пол
      human->DATE_R     := MDATE_R       // дата рождения больного
      human->VZROS_REB  := M1VZROS_REB   // 0-взрослый, 1-ребенок, 2-подросток
      human->ADRES      := MADRES        // адрес больного
      human->MR_DOL     := MMR_DOL       // место работы или причина безработности
      human->RAB_NERAB  := M1RAB_NERAB   // 0-работающий, 1-неработающий
      human->KOD_DIAG   := MKOD_DIAG     // шифр 1-ой осн.болезни
      human->KOMU       := M1KOMU        // от 0 до 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // серия и номер страхового полиса
      human->LPU        := M1LPU         // код учреждения
      human->OTD        := M1OTD         // код отделения
      human->UCH_DOC    := MUCH_DOC      // вид и номер учетного документа
      human->N_DATA     := MN_DATA       // дата начала лечения
      human->K_DATA     := MK_DATA       // дата окончания лечения
      human->CENA       := MCENA_1       // стоимость лечения
      human->CENA_1     := MCENA_1       // стоимость лечения
      human->DATE_OPL := dtoc4( mdate_next )  // дата следующего посещения
      human_->DISPANS   := '2000000000000000'  // поставлен на диспансерный учет
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // это поле вернётся из ТФОМС в случае иногороднего
      human_->USL_OK    := m1USL_OK
      human_->PROFIL    := m1PROFIL
      human_->IDSP      := m1IDSP   // 29
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // уберём '2',  если отредактировали запись из реестра СП и ТК
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
      human_2->PROFIL_K := m1PROFIL_K
      human_2->p_per  := iif( eq_any( m1USL_OK, USL_OK_HOSPITAL, USL_OK_DAY_HOSPITAL ),  m1p_per, 0 )

      use_base( 'human_u' )
      Select HU
      If mrec_hu == 0
        add1rec( 7 )
        mrec_hu := hu->( RecNo() )
      Else
        Goto ( mrec_hu )
        g_rlock( forever )
      Endif
      Replace hu->kod     With human->kod, ;
        hu->kod_vr  With m1vrach, ;
        hu->kod_as  With 0, ;
        hu->u_koef  With 1, ;
        hu->u_kod   With mu_kod, ;
        hu->u_cena  With mu_cena, ;
        hu->is_edit With 0, ;
        hu->date_u  With dtoc4( MK_DATA ), ;
        hu->otd     With m1otd, ;
        hu->kol     With 1, ;
        hu->stoim   With mu_cena, ;
        hu->kol_1   With 1, ;
        hu->stoim_1 With mu_cena, ;
        hu->KOL_RCP With 0
      Select HU_
      Do While hu_->( LastRec() ) < mrec_hu
        Append Blank
      Enddo
      Goto ( mrec_hu )
      g_rlock( forever )
      If Loc_kod == 0 .or. !valid_guid( hu_->ID_U )
        hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
      Endif
      hu_->PROFIL   := m1PROFIL
      hu_->PRVS     := m1PRVS
      hu_->kod_diag := mkod_diag
      hu_->zf       := ''

      g_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl',  'SL' )
      find ( Str( mkod, 7 ) )
      If Found()
        g_rlock( forever )
      Else
        addrec( 7 )
        sl->kod := mkod
      Endif
      sl->DS1_T := 4  // согласно письма ТФОМС
      sl->STAD := m1STAD

      g_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco',  'CO' )
      find ( Str( mkod, 7 ) )
      If Found()
        g_rlock( forever )
      Else
        addrec( 7 )
        co->kod := mkod
      Endif
      co->PR_CONS := 0  // Отсутствует необходимость проведения консилиума

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
  If fl_write_sluch // если записали - запускаем проверку
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil

// * 23.11.22
Function f_valid_onko_diag( diag, dob, date_post, children_acceptable )

  // diag - онкологический диагноз
  // dob - дата рождения
  // date_post - дата постановки на учет

  // для взрослых один из рубрик C00-D09
  // для детей один из рубрик C00-D89
  Local vozrast, fl := .f., diagBeg := 'C00', diagAdult := 'D09', diagChild := 'D89'
  Local mshifr
  Local aDiag

  Private mvar := Upper( ReadVar() )

  mshifr := AllTrim( &mvar )
  vozrast := count_years( dob, date_post )
  If vozrast < 18 .and. ! children_acceptable
    fl := .f.
    func_error( 4, 'допустимо только для совершеннолетних пациентов!' )
    Return fl
  Endif
  aDiag := { ;
    { 'C00', 'C97' }, ;
    { 'D00', iif( vozrast < 18, diagChild, diagAdult ) } ;
    }
  fl := between_diag_array( mshifr, aDiag )

  If ! fl
    func_error( 4, 'Недопустимый диагноз, допустимый диапазон с ' + diagBeg + ' по ' + iif( vozrast < 18, diagChild, diagAdult ) + '!' )
    Return fl
  Endif
  mm_N002 := f_define_tnm( 2, diag )

  Return fl

// * 09.09.22
Function f_valid_onko_vrach( tabnom, dob, date_post, children_acceptable )

  // tab_nom - табельный номер врача
  // dob - дата рождения
  // date_post - дата постановки на учет
  Local vozrast, fl := .f.
  Local med_spec_child_V021 := { 9, 19, 49, 102 } // допустимые специальности для детей
  Local med_spec_adult_V021 := { 9, 41 }  // допустимые специальности для взрослых только "гематология" и "онкология"

  vozrast := count_years( dob, date_post )
  If vozrast < 18 .and. ! children_acceptable
    fl := .f.
    func_error( 4, 'допустимо только для совершеннолетних пациентов!' )
    Return fl
  Endif
  If AScan( iif( vozrast < 18, med_spec_child_V021, med_spec_adult_V021 ), get_spec_vrach_v021_by_tabnom( tabnom ) ) > 0
    fl := .t.
  Endif
  If ! fl
    func_error( 4, 'Недопустимая специальность врача!' )
  Endif

  Return fl
