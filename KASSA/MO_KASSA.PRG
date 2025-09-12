//**************************************************************************
// mo_kassa.prg
//**************************************************************************
// begin_task_kassa()
// fk_usl_cena()
// f0_usl_cen(oBrow)
// f1_usl_cen(nKey,oBrow)
// f2_usl_cen()
// fk_usl_dogov()
// f1_usl_dogov(nKey,oBrow)
// f2_usl_dogov()
// nastr_kassa(k)
// 03.03.13 kassa_r_list_uch(par,name_func)
// 22.07.16 kas_plat()
// f2_kas_plat(oBrow)
// f21_ksa_plat(rec)
// f22_ksa_plat(rec)
// f3_kas_plat(nKey,oBrow)
// 22.07.16 f4_kas_plat(fl_edit)
// fe_kp_kusl(oBrow)
// f3e_kp_kusl()
// f2e_kp_kusl(nKey,oBrow)
// f5e_kp_kusl(get,when_valid,k,ipl_ort)
// regi_s_plat(k)
// f2r_s_plat(reg)
// pl_priemden()
// pl_dogovor()
// pl_2dogovor()
// inputNpozic(r,c,fl_max)
// f_is_pozic(arr_s,pozic)
//**************************************************************************
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static smvzros_reb

//
Function begin_task_kassa()

  Static n_zapusk := 0

  If n_zapusk == 0
    ++n_zapusk
    Public glob_smena, glob_nar := { 0, 0, 0, 0, 0, 0, CToD( "" ) }, ;
      mm_kas_tip := { { "сложный", LPU_KAS_SLOG }, ;
      { "простой", LPU_KAS_PROS } }, ;
      mm_kas_vid := { { "бесплатные",   LPU_KAS_B_PL }, ;  // 1
    { "платные",      LPU_KAS_PLAT }, ;  // 2
    { "пл.со скидкой", LPU_KAS_PL_S }, ;  // 3
    { "ДМС",          LPU_KAS_DMS }, ;  // 4
    { "взаимозачет",  LPU_KAS_VZ  } }   // 5
    nastr_kassa( 1 )
    f5_sist_fr( 1 )
  Endif
  If copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
    tools_ini_platn( 1, 0, 0 )
  Else
    Return .f.
  Endif
  If ( glob_smena := input_value( 20, 29, 22, 51, color1, ;
      "Номер смены (1-2)", 1, "9" ) ) == NIL
    Return .f.
  Endif
  If !Between( glob_smena, 1, 2 )
    Return func_error( 4, "Неверно введен номер смены!" )
  Endif
  If hb_FileExists( "__kassa_.log" ) .and. FileSize( "__kassa_.log" ) > 5000000
    Delete file __kassa_.log
  Endif
  blk_ekran := {| _s| _s := AllTrim( fio_polzovat ) + ;
    ", смена: " + lstr( glob_smena ) + ", " + ;
    full_date( sys_date ), ;
    DevPos( MaxRow() -2, MaxCol() -Len( _s ) ), ;
    DevOut( _s, "W+/N*" ) }
  Return .t.

//
Function fk_usl_cena()

  Local buf := SaveScreen(), adbf

  Private fl_found := .f.

  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  mywait()
  r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
  adbf := { { "kod", "N", 4, 0 }, ;
    { "shifr", "C", 10, 0 }, ;
    { "name", "C", 64, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On fsort_usl( shifr ) to ( cur_dir() + "tmp" )
  g_use( dir_server() + "kas_usl",, "KU" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmp_ku" )
  Go Top
  Do While !Eof()
    fl_found := .t.
    Select USL
    Goto ( ku->u_kod )
    Select TMP
    Append Blank
    tmp->kod := ku->u_kod
    tmp->shifr := usl->shifr
    tmp->name := usl->name
    Select KU
    Skip
  Enddo
  Select TMP
  Go Top
  If !fl_found ; Keyboard Chr( K_INS ) ; Endif
  box_shadow( 0, 2, 0, 77, "GR+/RB", "Список услуг, при вводе которых разрешается редактировать цену",, 0 )
  alpha_browse( 2, 1, 23, 77, "f0_usl_cen", color0,,, .t., .t.,,, "f1_usl_cen",, ;
    { "═", "░", "═", "N/BG,W+/N,B/BG", .t., 58 } )
  Close databases
  RestScreen( buf )
  Return Nil

//
Function f0_usl_cen( oBrow )

  Local oColumn

  oColumn := TBColumnNew( "   Шифр", {|| tmp->shifr } )
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( "Наименование услуги", 64 ), {|| tmp->name } )
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ - выход;  ^<Ins>^ - добавление;  ^<Del>^ - удаление" )
  Return Nil

//
Function f1_usl_cen( nKey, oBrow )

  Local j := 0, k := -1, buf := save_row( MaxRow() ), buf1, fl := .f., ;
    tmp_color := SetColor(), r1 := 14, c1 := 2, ;
    rec_tmp := tmp->( RecNo() )

  Do Case
  Case nKey == K_INS
    If !fl_found
      ColorWin( 5, 0, 5, 79, "N/N", "W+/N" )
    Endif
    Private mkod := 0, ;
      mname := Space( 60 ), ;
      mshifr := Space( 10 ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    buf1 := box_shadow( r1, c1, 21, 77, color8, ;
      "Добавление новой услуги в список", cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, pc1 + 3 Say "Шифр услуги" Get mshifr Picture "@!" ;
      Valid f2_usl_cen()
    @ r1 + 3, pc1 + 3 Say "Наименование услуги"
    @ r1 + 4, pc1 + 5 Get mname When .f.
    status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
    myread()
    If LastKey() != K_ESC .and. !Empty( mshifr ) .and. f_esc_enter( 1 )
      mywait()
      fl_found := .t.
      Select TMP
      Append Blank
      tmp->kod := mkod
      tmp->shifr := mshifr
      tmp->name := mname
      rec_tmp := tmp->( RecNo() )
      Select KU
      find ( Str( mkod, 4 ) )
      If !Found()
        addrec( 4 )
        ku->u_kod := mkod
        Unlock
      Endif
      Select TMP
      Commit
      k := 0
    Elseif !fl_found
      k := 1
    Endif
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
    rest_box( buf ) ; rest_box( buf1 )
  Case nKey == K_DEL .and. !Empty( tmp->shifr ) .and. f_esc_enter( 2 )
    mywait()
    Select KU
    find ( Str( tmp->kod, 4 ) )
    If Found()
      deleterec( .t. )
    Endif
    Select TMP
    deleterec( .t. )
    Commit
    k := 0
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f. ; k := 1
    Endif
    rest_box( buf )
  Otherwise
    Keyboard ""
  Endcase
  Return k

//
Function f2_usl_cen()

  Local fl := valid_shifr()

  If fl
    Select USL
    find ( mshifr )
    If Found()
      Select KU
      find ( Str( usl->kod, 4 ) )
      If Found()
        fl := func_error( 4, "Данная услуга уже была добавлена в список!" )
      Else
        mkod := usl->kod
        mname := usl->name
      Endif
    Else
      fl := func_error( 4, "Нет такого шифра в базе данных услуг!" )
    Endif
  Endif
  Return fl

//
Function fk_usl_dogov()

  Local buf := SaveScreen(), adbf
  Private fl_found := .f.

  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  mywait()
  r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
  adbf := { { "kod", "N", 4, 0 }, ;
    { "shifr", "C", 10, 0 }, ;
    { "name", "C", 64, 0 } }
  dbCreate( cur_dir() + "tmp", adbf )
  Use ( cur_dir() + "tmp" ) New Alias TMP
  Index On fsort_usl( shifr ) to ( cur_dir() + "tmp" )
  g_use( dir_server() + "kas_usld",, "KU" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmp_ku" )
  Go Top
  Do While !Eof()
    fl_found := .t.
    Select USL
    Goto ( ku->u_kod )
    Select TMP
    Append Blank
    tmp->kod := ku->u_kod
    tmp->shifr := usl->shifr
    tmp->name := usl->name
    Select KU
    Skip
  Enddo
  Select TMP
  Go Top
  If !fl_found ; Keyboard Chr( K_INS ) ; Endif
  box_shadow( 0, 2, 0, 77, "GR+/RB", "Список услуг, исключаемых из журнала регистрации",, 0 )
  alpha_browse( 2, 1, 23, 77, "f0_usl_cen", color0,,, .t., .t.,,, "f1_usl_cen",, ;
    { "═", "░", "═", "N/BG,W+/N,B/BG", .t., 58 } )
  Close databases
  RestScreen( buf )
  Return Nil

//
Function f1_usl_dogov( nKey, oBrow )

  Local j := 0, k := -1, buf := save_row( MaxRow() ), buf1, fl := .f., ;
    tmp_color := SetColor(), r1 := 14, c1 := 2, ;
    rec_tmp := tmp->( RecNo() )

  Do Case
  Case nKey == K_INS
    If !fl_found
      ColorWin( 5, 0, 5, 79, "N/N", "W+/N" )
    Endif
    Private mkod := 0, ;
      mname := Space( 60 ), ;
      mshifr := Space( 10 ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    buf1 := box_shadow( r1, c1, 21, 77, color8, ;
      "Добавление новой услуги в список", cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, pc1 + 3 Say "Шифр услуги" Get mshifr Picture "@!" ;
      Valid f2_usl_dogov()
    @ r1 + 3, pc1 + 3 Say "Наименование услуги"
    @ r1 + 4, pc1 + 5 Get mname When .f.
    status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
    myread()
    If LastKey() != K_ESC .and. !Empty( mshifr ) .and. f_esc_enter( 1 )
      mywait()
      fl_found := .t.
      Select TMP
      Append Blank
      tmp->kod := mkod
      tmp->shifr := mshifr
      tmp->name := mname
      rec_tmp := tmp->( RecNo() )
      Select KU
      find ( Str( mkod, 4 ) )
      If !Found()
        addrec( 4 )
        ku->u_kod := mkod
        Unlock
      Endif
      Select TMP
      ku->( dbCommit() )
      k := 0
    Elseif !fl_found
      k := 1
    Endif
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
    rest_box( buf ) ; rest_box( buf1 )
  Case nKey == K_DEL .and. !Empty( tmp->shifr ) .and. f_esc_enter( 2 )
    mywait()
    Select KU
    find ( Str( tmp->kod, 4 ) )
    If Found()
      deleterec( .t. )
    Endif
    Select TMP
    deleterec( .t. )
    ku->( dbCommit() )
    k := 0
    Select TMP
    oBrow:gotop()
    Go Top
    If Eof()
      fl_found := .f. ; k := 1
    Endif
    rest_box( buf )
  Otherwise
    Keyboard ""
  Endcase
  Return k

//
Function f2_usl_dogov()

  Local fl := valid_shifr()

  If fl
    Select USL
    find ( mshifr )
    If Found()
      Select KU
      find ( Str( usl->kod, 4 ) )
      If Found()
        fl := func_error( 4, "Данная услуга уже была добавлена в список!" )
      Else
        mkod := usl->kod
        mname := usl->name
      Endif
    Else
      fl := func_error( 4, "Нет такого шифра в базе данных услуг!" )
    Endif
  Endif
  Return fl

//
Function nastr_kassa( k )

  Static mm_da_net := { { "нет", 1 }, { "да ", 2 } }
  Local mm_tmp := {}, buf, fl := .f.

  If k == 1
    Public mem_pl_ext  := "PLK", ;
      mem_or_ext  := "ORK", ;
      mem_vozvra  := 1, ;
      mem_dop_st  := 1
    If hb_FileExists( "_lpukas_.mem" )
      Restore From _lpukas_ Additive
    Else
      Save All Like mem_ * To _lpukas_
    Endif
    //**********
  Elseif k == 2
    //**********
    buf := save_row( MaxRow() ) ; mywait()
    Close databases
    Delete file tmp.dbf
    AAdd( mm_tmp, { "pl_ext", "C", 3, 0, "@!", ;
      NIL, ;
      "", NIL, ;
      'Расширение для шаблонов документов по платным услугам' } )
    AAdd( mm_tmp, { "e_1", "C", 1, 0, NIL, ;
      NIL, ;
      " ", NIL, ;
      " ",, ;
      {|| .f. } } )
    AAdd( mm_tmp, { "vozvrat", "N", 1, 0, NIL, ;
      {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
      1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
      "Разрешить администратору возвраты без КАССЫ?" } )
    AAdd( mm_tmp, { "dop_str", "N", 1, 0, NIL, ;  // 21.05.08
    {| x| menu_reader( x, mm_da_net, A__MENUVERT ) }, ;
      1, {| x| inieditspr( A__MENUVERT, mm_da_net, x ) }, ;
      "В журналах договоров разделять чеки строкой?" } )
    If is_task( X_ORTO )
      AAdd( mm_tmp, { "or_ext", "C", 3, 0, "@!", ;
        NIL, ;
        "", NIL, ;
        'Расширение для шаблонов документов по ортопедическим услугам' } )
    Endif
    init_base( cur_dir() + "tmp",, mm_tmp, 0 )
    Use ( cur_dir() + "tmp" ) new
    Append Blank
    tmp->pl_ext  := mem_pl_ext
    tmp->vozvrat := mem_vozvra
    tmp->dop_str := mem_dop_st // 21.05.08
    If is_task( X_ORTO )
      tmp->or_ext := mem_or_ext
    Endif
    Close databases
    If f_edit_spr( A__EDIT, mm_tmp, 'настройке работы с задачей "Касса МО"', ;
        "g_use(cur_dir()+'tmp',,,.t.,.t.)", 0, 1 ) > 0
      Use ( cur_dir() + "tmp" ) new
      mem_pl_ext  := tmp->pl_ext
      mem_vozvra  := tmp->vozvrat
      mem_dop_st  := tmp->dop_str
      If is_task( X_ORTO )
        mem_or_ext := tmp->or_ext
      Endif
      Save All Like mem_ * To _lpukas_
    Endif
    Close databases
    rest_box( buf )
  Endif
  Return Nil

// 12.09.25
Function kassa_r_list_uch( par, name_func )

  // 1 - платные услуги
  // 2 - ортопедические услуги
  Local i := 1, k, s, buf := save_row( MaxRow() )
  Local luchast := "", arr, m1vid_ud, ;
    m1kategor := ATail( stm_kategor )[ 2 ]  // т.е. прочие (последнее значение)
  Private name_lpu, name_otd, mvzros_reb, mreg_lech, mmest_inog, mrab_nerab, ;
    mkomu, name_org, mmi_git, mkategor := " ", mvid_ud, mnom, mser, ;
    l1nomer, lnomer, mrajon_git, mrajon_fin, mpolis, msrok_polis, ;
    mregistrator := "", mtime, mfio, mpol, mdate_r, madres, mmr_dol, ;
    muchastok, s_prim1 := {}, mfio1 := "", mvid_ud1 := "", mser1 := "", ;
    mnom1 := "", msnils := "", mokatog := "", mokatop := ""
  mywait()
  //
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( glob_kartotek )
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( glob_kartotek )
  r_use( dir_server() + "organiz",, "ORG" )
  name_lpu := AllTrim( org->name )
  name_otd := ""
  r_use( dir_server() + "k_prim1", dir_server() + "k_prim1", "K_PRIM1" )
  find ( Str( kart->kod, 7 ) )
  Do While k_prim1->kod == kart->kod .and. !Eof()
    AAdd( s_prim1, RTrim( k_prim1->name ) )
    Skip
  Enddo
  k_prim1->( dbCloseArea() )
  If Len( s_prim1 ) == 0
    AAdd( s_prim1, "" )
  Endif
  If human->KOD_OPER > 0
    r_use( dir_server() + "base1",, "BASE1" )
    Goto ( human->KOD_OPER )
    If !Eof() .and. !Empty( base1->p1 )
      mregistrator := AllTrim( Crypt( base1->p1, gpasskod ) )
    Endif
  Endif
  mfio := Upper( kart->fio )
  mpolis := kart->polis
//  msnils := Expand( Transform( kart->SNILS, picture_pf ) )
  msnils := Expand( Transform_SNILS( kart->SNILS ) )
  mpol := kart->pol
  mdate_r := full_date( kart->date_r )
  madres := iif( emptyall( kart_->okatog, kart->adres ), "", ;
    ret_okato_ulica( kart->adres, kart_->okatog ) )
  mmr_dol := kart->mr_dol
  mtime := hour_min( Seconds() )
  msrok_polis := full_date( c4tod( kart->srok_polis ) )
  mvzros_reb := Upper( inieditspr( A__MENUVERT, menu_vzros, kart->vzros_reb ) )
  mmi_git    := okato_mi_git( kart_->okatog )
  mrajon_git := okato_rajon( kart_->okatog )
  mmest_inog := mrajon_fin := ""
  mkomu := "СМО: "
  If AllTrim( kart_->SMO ) == '34'
    s := ret_inogsmo_name( 1 )
    mkomu += iif( Empty( s ), "ТФОМС (иногородние)", s )
    mmest_inog := inieditspr( A__MENUVERT, glob_array_srf, kart_->KVARTAL_D ) // ОКАТО субъекта РФ территории страхования
  Elseif Left( kart_->SMO, 2 ) == '34'
    mkomu += AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( kart_->smo ) ) ) )
    mmest_inog := 'Волгоградская область'
  Elseif !Empty( kart_->SMO )
    mkomu += init_ismo( kart_->SMO )
    mmest_inog := inieditspr( A__MENUVERT, glob_array_srf, kart_->KVARTAL_D ) // ОКАТО субъекта РФ территории страхования
  Endif
  mrab_nerab := Upper( inieditspr( A__MENUVERT, menu_rab, kart->rab_nerab ) )
  m1vid_ud := kart_->vid_ud
  mnom     := kart_->nom_ud
  mser     := kart_->ser_ud
  If Empty( stm_kategor2 )
    m1kategor := kart_->kategor
    mkategor := Upper( inieditspr( A__MENUVERT, stm_kategor, m1kategor ) )
  Else
    m1kategor := kart_->kategor2
    mkategor := Upper( inieditspr( A__MENUVERT, stm_kategor2, m1kategor ) )
  Endif
  mvid_ud := get_name_vid_ud( m1vid_ud )
  If Empty( mser ) ; mser := Space( 10 ) ; Endif
  If Empty( mnom ) ; mnom := Space( 10 ) ; Endif
  //
  lnomer := l1nomer := lstr( kart->kod )
  muchastok := put_val( kart->uchast, 2 )
  If is_uchastok == 1
    If !emptyall( kart->bukva, kart->uchast, kart->kod_vu )
      lnomer := ""
      If !Empty( kart->bukva )
        lnomer += kart->bukva
      Endif
      lnomer += lstr( kart->uchast, 2 )
      If kart->kod_vu > 0
        lnomer += "/" + lstr( kart->kod_vu )
      Endif
      l1nomer := lnomer
    Endif
  Elseif eq_any( is_uchastok, 2, 3 )
    If !emptyall( kart->bukva, kart->uchast )
      luchast := " [уч-к "
      If !Empty( kart->bukva )
        luchast += kart->bukva
      Endif
      luchast += lstr( kart->uchast, 2 )
      luchast += "] "
    Endif
    If is_uchastok == 3
      luchast += AllTrim( kart2->kod_AK )
    Endif
  Endif
  lnomer := Expand( lnomer ) + luchast
  If !Empty( name_func ) .and. !( "(" $ name_func )
    name_func += "()"
  Endif
  k := &name_func
  rest_box( buf )
  Return Nil

// 02.07.18
Function kas_plat()

  Local buf, str_sem

  //
  If  mek_kassa == 1 // .and. mek_nkassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      fr_zamena_otrezka()
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif
  //
  If polikl1_kart() > 0
    str_sem := "KASSA - Редактирование человека " + lstr( glob_kartotek )
    If !g_slock( str_sem )
      Return func_error( 4, err_slock )
    Endif
    buf := SaveScreen()
    Private fl_found, str_find, muslovie
    str_find := Str( glob_kartotek, 7 )
    muslovie := "human->kod_k == glob_kartotek"
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    use_base( "kas_pl_u", "HU" )
    Set Relation To u_kod into USL
    use_base( "kas_pl", "HUMAN" )
    find ( str_find )
    fl_found := Found()
    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find, -1 ) }, ;
      {| n| skippointer( n, muslovie ) }, ;
      str_find, muslovie;
      }
    If !fl_found ; Keyboard Chr( K_INS ) ; Endif
    mtitle := glob_k_fio
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, "f2_kas_plat", color0, mtitle, "BG+/GR", ;
      .f., .t., arr_blk,, "f3_kas_plat",, ;
      { "═", "░", "═", "N/BG,W+/N,B/BG,BG+/B", .t., 180 } )
    Close databases
    RestScreen( buf )
    g_sunlock( str_sem )
  Endif
  Return Nil

//
Function f2_kas_plat( oBrow )

  Local oColumn, blk := {|| iif( human->cena < 0, { 3, 4 }, { 1, 2 } ) }, ;
    tip_bank := { "бн", "МИ", "VI", "MC" }

  //
  oColumn := TBColumnNew( " № чека", {|| iif( human->sbank > 0, ;
    tip_bank[ human->fr_tipkart + 1 ] + iif( human->sbank == human->cena, " ", "Н" ) + put_val( human->n_chek, 5 ), ;
    put_val( human->n_chek, 8 ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Дата чека", {|| full_date( human->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Сумма чека", {|| put_kop( human->cena, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "     Услуги в чеке", {|| PadR( f21_ksa_plat( human->( RecNo() ) ), 36 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "  Кассир", {|| PadR( f22_ksa_plat( human->KOD_OPER ), 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  status_key( "^<Esc>^-выход; ^<Enter>^-редактирование чека; ^<Ins>^-добавление чека; ^<F9>^-печать" )
  Return Nil

//
Function f21_ksa_plat( rec )

  Local s := "", t_vr, tmp_select := Select()

  Select HU
  find ( Str( rec, 7 ) )
  Do While rec == hu->kod .and. !Eof()
    Select PERSO
    Goto ( hu->kod_vr )
    t_vr := perso->tab_nom
    s += AllTrim( usl->shifr ) + "-" + lstr( hu->kol ) + "(" + lstr( t_vr ) + ") "
    Select HU
    Skip
  Enddo
  Select ( tmp_select )
  Return s

//
Function f22_ksa_plat( rec )

  Local mregistrator := "", tmp_select := Select()

  If rec > 0
    r_use( dir_server() + "base1",, "BASE1" )
    Goto ( rec )
    If !Eof() .and. !Empty( base1->p1 )
      mregistrator := AllTrim( Crypt( base1->p1, gpasskod ) )
    Endif
    base1->( dbCloseArea() )
    Select ( tmp_select )
  Endif
  Return mregistrator

//
Function f3_kas_plat( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1 := 15, c1 := 2, adbf, ;
    t_hum_rec := 0, kart_kod, t_k_data, i
  Private ldate_voz, lsum_voz, nom_prihod := 0

  Do Case
  Case nKey == K_F9 .and. !Empty( human->cena )
    If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
      Return flag
    Endif
    rec := human->( RecNo() )
    t_hum_rec := human->( RecNo() )
    kart_kod := human->kod_k
    t_k_data := Year( human->k_data )
    Select HUMAN
    Do While human->kod_k == kart_kod .and. ;
        Year( human->k_data ) == t_k_data .and. !Eof()
      ++nom_prihod
      Skip
    Enddo
    Goto ( t_hum_rec )
    adbf := { { "shifr", "C", 10, 0 }, ;
      { "name", "C", 65, 0 }, ;
      { "vrach", "C", 40, 0 }, ;
      { "cena", "N", 10, 2 }, ;
      { "kol",  "N", 4, 0 } }
    dbCreate( cur_dir() + "tmp", adbf )
    Use ( cur_dir() + "tmp" ) new
    adbf := {}
    Select HU
    find ( Str( rec, 7 ) )
    Index On Str( kod_vr, 4 ) + fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" ) While hu->kod == rec
    Go Top
    Do While !Eof()
      If hu->kod_vr > 0 .and. AScan( adbf, hu->kod_vr ) == 0
        AAdd( adbf, hu->kod_vr )  // массив врачей
      Endif
      Skip
    Enddo
    Go Top
    Do While !Eof()
      Select TMP
      Append Blank
      tmp->shifr := usl->shifr
      tmp->name := usl->name
      If hu->kod_vr > 0 .and. ( i := AScan( adbf, hu->kod_vr ) ) > 0
        perso->( dbGoto( hu->kod_vr ) )
        tmp->vrach := fam_i_o( perso->fio ) + " <" + lstr( perso->tab_nom ) + ">"
        del_array( adbf, i )
      Endif
      tmp->cena := hu->U_CENA
      tmp->kol := hu->kol
      Select HU
      Skip
    Enddo
    Private file_sh
    If !Empty( mem_pl_ext ) .and. ;
        !Empty( file_sh := menu_shablon( 3, 3, dir_exe() + "*." + mem_pl_ext, color8, .f. ) )
      Select TMP
      Go Top
      kassa_r_list_uch( 1, "f1_pr_shab(file_sh)" )
    Endif
    Close databases
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    use_base( "kas_pl_u", "HU" )
    Set Relation To u_kod into USL
    use_base( "kas_pl", "HUMAN" )
    Goto ( rec )
  Case nKey == K_ENTER
    rec := human->( RecNo() )
    Close databases
    use_base( "kas_pl", "HUMAN" )
    Goto ( rec )
    f4_kas_plat( 2 )
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    use_base( "kas_pl_u", "HU" )
    Set Relation To u_kod into USL
    Select HUMAN
    Goto ( rec )
  Case nKey == K_INS
    If !fl_found
      ColorWin( 7, 0, 7, 79, "N/N", "W+/N" )
      ColorWin( 7, 0, 7, 79, "N/N", "BG+/B" )
    Endif
    addrec( 7 )
    human->KOD_K := glob_kartotek
    human->N_CHEK := 0
    human->SMENA := glob_smena
    human->K_DATA := sys_date
    human->CENA := human->sbank := 0
    human->KOD_OPER := Asc( kod_polzovat )
    human->( dbCommit() ) // 16.06.08
    Unlock
    rec := human->( RecNo() )
    Close databases
    use_base( "kas_pl", "HUMAN" )
    Goto ( rec )
    If f4_kas_plat( 1 )  // запись чека
      flag := 0
    Else
      use_base( "kas_pl_u", "HU" )
      Do While .t.
        find ( Str( rec, 7 ) )
        If !Found() ; exit ; Endif
        deleterec( .t. )
      Enddo
      hu->( dbCloseArea() )
      Select HUMAN
      Goto ( rec )
      deleterec()
      flag := 1
    Endif
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "uslugi",, "USL" )
    use_base( "kas_pl_u", "HU" )
    Set Relation To u_kod into USL
    Select HUMAN
    Goto ( rec )
  Case nKey == K_DEL .and. human->KOD_K > 0 .and. human->N_CHEK == 0 .and. f_esc_enter( 2 )
    rec := human->( RecNo() )
    Select HU
    Do While .t.
      find ( Str( rec, 7 ) )
      If !Found() ; exit ; Endif
      deleterec( .t. )
    Enddo
    Select HUMAN
    Goto ( rec )
    deleterec()
    flag := 1
  Otherwise
    Keyboard ""
  Endcase
  Return flag

// 04.07.17
Function f4_kas_plat( fl_edit )

  Local fl := .f., adbf, buf := SaveScreen(), tmp_color := SetColor( color1 ), ;
    j, l_color, mtitle, ln_chek := 0, fl_opl_vozvr := 0, rec, t_date, ;
    fr_zavodnomer := "", mi_post, mphone_m, maddress, tip_kart := 2, ;
    summa_oplat := 0, summa_oplat_bn := 0, tip_banka := 1, ;
    v_sdacha := 0
  Private fl_found := .f., mcena := 0, pr_kod_vr := 0, flg_edit := fl_edit, ;
    is_open_u1 := .f., lfr_data, lfr_time

  //
  lfr_data := dtoc4( Date() )
  lfr_time := TimeToSec()
  //
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( glob_kartotek )
  smvzros_reb := kart->vzros_reb
  kart->( dbCloseArea() )
  g_use( dir_server() + "kas_usl",, "KU" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmp_ku" )
  adbf := { ;
    { "rec_hu",   "N",     7,     0 }, ; // номер записи по БД "HU"
  { "KOD_VR",   "N",     4,     0 }, ; // код врача
  { "U_KOD",   "N",     4,     0 }, ; // код услуги
    { "U_CENA",   "N",    10,     2 }, ; // цена услуги
  { "KOL",   "N",     3,     0 }, ; // количество услуг
  { "STOIM",   "N",    10,     2 }, ; // итоговая стоимость услуги
    { "shifr_u",   "C",    10,     0 }, ;
    { "name_u",   "C",   128,     0 } }
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  Index On fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  use_base( "kas_pl_u", "HU" )
  r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" )
  r_use( dir_server() + "usl_otd", dir_server() + "usl_otd", "UO" )
  g_use( dir_server() + "pu_date", dir_server() + "pu_date", "PUD" )
  g_use( dir_server() + "pu_cena", { dir_server() + "pu_cena", ;
    dir_server() + "pu_cenau" }, "PUC" )
  r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
  cls
  pr_1_str( "Ввод чека для больного < " + AllTrim( glob_k_fio ) + " >" )
  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"
  mtitle := "Дата оплаты: " + full_date( human->k_data ) + "г."
  //
  Private flag_1 := .t.
  If fl_edit == 2
    Select HU
    rec := human->( RecNo() )
    find ( Str( rec, 7 ) )
    Do While rec == hu->kod .and. !Eof()
      Select TMP
      Append Blank
      tmp->rec_hu  := hu->( RecNo() )
      tmp->KOD_VR  := hu->kod_vr
      tmp->U_KOD   := hu->u_kod
      tmp->U_CENA  := hu->u_cena
      tmp->KOL     := hu->kol
      tmp->STOIM   := hu->stoim
      Select USL
      Goto ( hu->u_kod )
      tmp->shifr_u := usl->shifr
      tmp->name_u  := usl->name
      Select HU
      Skip
    Enddo
    Select TMP
    Go Top
  Else
    Keyboard Chr( K_INS )
  Endif
  Do While .t.
    alpha_browse( 2, 0, MaxRow() -2, 79, "fe_kp_kusl", color1, mtitle, col_tit_popup, ;
      .f., .t.,,, "f2e_kp_kusl",, ;
      { "═", "░", "═", l_color, .t., 180 } )
    If Empty( mcena )
      j := 1
    Else
      If flg_edit == 1
        j := f_alert( { PadC( "Выберите действие", 60, "." ) }, ;
          { " Выход без записи ", " Печать чека ", " Возврат в редактирование " }, ;
          2, "W+/N", "N+/N", MaxRow() -2,, "W+/N,N/BG" )
      Else
        j := 1
      Endif
    Endif
    If j == 1
      Exit
    Elseif j == 2
      tmp->( dbCloseArea() )
      // 00.07.17 поиск номера или э.почты.
      t_hum_rec := human->( RecNo() )
      kart_kod  := human->kod_k
      mi_post   := Space( 30 )
      mphone_m  := Space( 11 )
      Select HUMAN
      Do While human->kod_k == kart_kod  .and. !Eof()
        If Len( AllTrim( human->i_post ) ) > 4
          mi_post := human->i_post
        Endif
        Skip
      Enddo
      Goto ( t_hum_rec )
      // поиск телефона
      r_use( dir_server() + "kartote_",, "KR_" ) // 00.02.17
      goto( human->kod_k )
      mphone_m := kr_->phone_m
      kr_->( dbCloseArea() )
      mphone_m := transformphone( mphone_m )
      // выбираем приоритетом телефон
      If Len( AllTrim( mphone_m ) ) < 11
        maddress := mi_post
      Else
        maddress := mphone_m
      Endif
      //
      Use ( cur_dir() + "tmp_usl" ) New index ( cur_dir() + "tmp_usl" )
      adbf := { { "name",   "C", 128, 0 }, ; // 24.12.17
      { "name_u", "C", 128, 0 }, ;
        { "vrach",  "C", 40, 0 }, ;
        { "cena",   "N", 10, 2 }, ;
        { "U_CENA", "N", 10, 2 }, ;
        { "vz_cena", "N",  9, 3 }, ;
        { "kol",    "N",  4, 0 }, ;
        { "kol1",   "N",  4, 0 }, ;
        { "nds20",  "N",  1, 0 }, ; // 10.08.08
      { "nds18",  "N",  1, 0 }, ; // 10.08.08
      { "nds10",  "N",  1, 0 } }
      dbCreate( cur_dir() + "tmp", adbf )
      Use ( cur_dir() + "tmp" ) new
      adbf := {}
      Select TMP_USL
      Go Top
      Do While !Eof()
        If tmp_usl->kod_vr > 0 .and. AScan( adbf, tmp_usl->kod_vr ) == 0
          AAdd( adbf, tmp_usl->kod_vr )  // массив врачей
        Endif
        Skip
      Enddo
      fl := .t.
      Select TMP_USL
      Go Top
      Do While !Eof()
        Select TMP
        Append Blank
        Select USL
        Goto ( tmp_usl->U_KOD )
        If mek_kod_usl > 1
          If Len( AllTrim( usl->full_name ) ) > 3
            tmp->name_u := AllTrim( usl->full_name )
            tmp->name := AllTrim( usl->full_name )
          Else
            tmp->name_u := AllTrim( usl->name )
            tmp->name := AllTrim( usl->name )
          Endif
        Else
          If Len( AllTrim( usl->full_name ) ) > 3
            tmp->name_u := AllTrim( usl->shifr ) + " " + AllTrim( usl->full_name )
            tmp->name := AllTrim( usl->shifr ) + " " + AllTrim( usl->full_name )
          Else
            tmp->name_u := AllTrim( usl->shifr ) + " " + AllTrim( usl->name )
            tmp->name := AllTrim( usl->shifr ) + " " + AllTrim( usl->name )
          Endif
        Endif
        Select TMP
        If tmp_usl->kod_vr > 0 .and. fl
          perso->( dbGoto( tmp_usl->kod_vr ) )
          tmp->vrach := fam_i_o( perso->fio ) + " <" + lstr( perso->tab_nom ) + ">"
          If Len( adbf ) == 1  // если врач один,
            fl := .f.        // то печатаем его только в 1-ой услуге
          Endif
        Endif
        tmp->cena    := tmp_usl->U_CENA
        tmp->u_cena  := tmp_usl->U_CENA
        tmp->vz_cena := tmp_usl->U_CENA
        Select USL
        Goto ( tmp_usl->U_KOD )
        If Round( tmp->cena, 2 ) == Round( usl->pcena_d, 2 ) // дети-взрослые
          // дети
          If round_5( usl->pnds_d, 2 ) > 0
            If round_5( usl->pnds_d, 0 ) == 18
              tmp->nds18 := 1
            Elseif round_5( usl->pnds_d, 0 ) == 20
              tmp->nds20 := 1
            Elseif round_5( usl->pnds_d, 0 ) == 10
              tmp->nds10 := 1
            Endif
          Endif
        Else
          If round_5( usl->pnds, 2 ) > 0
            If round_5( usl->pnds, 0 ) == 18
              tmp->nds18 := 1
            Elseif round_5( usl->pnds, 0 ) == 20
              tmp->nds20 := 1
            Elseif round_5( usl->pnds, 0 ) == 10
              tmp->nds10 := 1
            Endif
          Endif
        Endif
        If tmp_usl->kol < 0 // призн. возврата
          fl_opl_vozvr := 1
          tmp->kol  := tmp_usl->kol * ( -1 )
          tmp->kol1 := tmp_usl->kol * ( -1 )
        Else
          tmp->kol := tmp_usl->kol
        Endif
        Select TMP_USL
        Skip
      Enddo
      Private p_summa := round_5( mcena, 2 ), fl_sdacha := .f.
      v_summa := v_sdacha := v_bank := round_5( 0, 2 )
      fl := .f.
      If fl_opl_vozvr == 0
        If yes_chek( @v_summa, @v_sdacha, @v_bank,, @maddress, @tip_kart ) .and. ;
            chek_fr( round_5( v_summa, 2 ), v_sdacha, @ln_chek, round_5( v_bank, 2 ),, @fr_zavodnomer, maddress, tip_kart )
          fl := .t.
          Select HUMAN
          g_rlock( forever )
          human->N_CHEK := ln_chek
          human->cena := mcena
          human->sbank := v_bank
          t_date := human->k_data
          human->k_data := c4tod( lfr_data )
          human->fr_data := lfr_data
          human->fr_time := lfr_time
          human->FR_zavod := fr_zavodnomer
          human->FR_tipkart := tip_kart
          human->fr_tip     := 2
          human->i_post     :=  maddress // 00.02.17
          Unlock
          human->( dbCommit() )
          If t_date != human->k_data
            fl := func_error( 4, "ВНИМАНИЕ! Дата в чеке " + full_date( human->k_data ) + "  Дата в компьютере" + full_date( t_date ) )
          Endif
        Endif
      Else  // возврат
        v_summa := mcena * ( -1 )
        If mem_vozvra == 2 .and. hb_user_curUser:isadmin() // 07.04.08
          fl := .t.                                 // возврат без кассы
          Select HUMAN
          g_rlock( forever )
          human->N_CHEK := 0
          human->cena := mcena
          human->sbank := mcena // 18.11.14
          Unlock
          human->( dbCommit() ) // 16.06.08
        Else
          summa_oplat    := 0
          summa_oplat_bn := 0
          tip_banka      := 1
          maddress       := ""
          v_sdacha       := 0
          //
          p_summa := round_5( mcena, 2 )

          If yes_chek( @summa_oplat, @v_sdacha, @summa_oplat_bn,, @maddress, @tip_banka )
            p_summa := p_summa * ( -1 )
            // вначале возвращаем чистый безнал
            If Round( p_summa, 2 ) ==  Round( summa_oplat_bn, 2 )
              sum_nal   := 0
              sum_bank  := p_summa
            Elseif p_summa <= ( summa_oplat - summa_oplat_bn )
              // чистый нал
              sum_bank  := 0
              tip_banka := 0
              sum_nal   := p_summa
            Else
              sum_nal   := p_summa - summa_oplat_bn
              sum_bank  := summa_oplat_bn
            Endif
            fl := vozvrat_fr( sum_nal, sum_bank, @ln_chek, 1, tip_banka )
            // сам чек
            If fl
              // заносим возврат
              Select HUMAN
              g_rlock( forever )
              human->N_CHEK := ln_chek
              human->cena := mcena
              human->sbank := 0
              t_date := human->k_data            // 25.06.08 Н
              human->k_data := c4tod( lfr_data )
              human->fr_data := lfr_data
              human->fr_time := lfr_time
              // replace ho->date_voz    with dtoc4(ldate_voz), ;
              // ho->sum_voz     with summa_oplat
                   /* ,;
                    ho->vzfr_data   with ,;
                    ho->vzfr_time   with ,;
                    ho->vzkod_oper  with ,;
                    ho->vzfr_zavod   with
                  */
              Unlock
              stat_msg( "Сумма возврата записана!" ) ; mybell( 1, OK )
            Endif
          Endif
          human->( dbCommit() )
        Endif
      Endif
      tmp_usl->( dbCloseArea() )
      RestScreen( buf )
      Exit
    Elseif j == 3
      Loop
    Endif
  Enddo
  tmp->( dbCloseArea() )
  If is_open_u1
    u1k->( dbCloseArea() )
    uk->( dbCloseArea() )
    is_open_u1 := .f.
  Endif
  perso->( dbCloseArea() )
  usl->( dbCloseArea() )
  uo->( dbCloseArea() )
  puc->( dbCloseArea() )
  pud->( dbCloseArea() )
  ku->( dbCloseArea() )
  hu->( dbCloseArea() )
  Select HUMAN
  SetColor( tmp_color )
  RestScreen( buf )
  Return fl

//
Function fe_kp_kusl( oBrow )

  Local oColumn, blk_color := {|| iif( tmp->stoim < 0, { 3, 4 }, { 1, 2 } ) }

  oColumn := TBColumnNew( "   Шифр;  услуги", {|| tmp->shifr_u } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "  Наименование;  услуги", {|| Left( tmp->name_u, 34 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Врач", {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Ко-;лич.;усл.", {|| tmp->kol } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "   Цена;  услуги", {|| put_kop( tmp->u_cena, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Общая; стоимость; услуги", {|| put_kop( tmp->stoim, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If flg_edit == 2
    status_key( "^<Enter>^ ред-ие" )
  Else
    status_key( "^<Esc>^ выход для печати чека ^<Enter>^ ред-ие ^<Ins>^ добавление ^<Del>^ удаление" )
  Endif
  Return Nil

//
Function f3e_kp_kusl()

  @ 23, 60 Say PadL( "Итого: " + lstr( mcena, 11, 2 ), 19 ) Color "W+/N"
  Return Nil

//
Function f2e_kp_kusl( nKey, oBrow )

  Local flag := -1, buf := SaveScreen(), fl := .f., ;
    j := 0, s := 0, so := 0, tmp_color := SetColor(), ;
    rec_tmp := tmp->( RecNo() ), mrec_hu := tmp->rec_hu
  Private r1 := 13

  Do Case
  Case ( nKey == K_INS .and. flg_edit == 1 ) .or. ( nKey == K_ENTER .and. tmp->rec_hu > 0 )
    chm_help_code := 1// HM_Edit1_kart
    If nKey == K_INS .and. !fl_found
      ColorWin( 7, 0, 7, 79, "B/B", "W+/RB" )
    Endif
    Private mu_kod := if( nKey == K_INS, 0, tmp->u_kod ), ;
      mu_cena := if( nKey == K_INS, 0, tmp->u_cena ), ;
      mkod_vr := if( nKey == K_INS, pr_kod_vr, tmp->kod_vr ), ;
      mtabn_vr := 0, mvrach := Space( 35 ), ;
      mkol := if( nKey == K_INS, 0, tmp->kol ), ;
      mstoim := if( nKey == K_INS, 0, tmp->stoim ), ;
      mshifr := if( nKey == K_INS, Space( 10 ), tmp->shifr_u ), ;
      mname_u := if( nKey == K_INS, Space( 65 ), tmp->name_u ), ;
      pr_k_usl := {}, ;  // массив комплексных услуг
    gl_area := { 1, 0, 23, 79, 0 }
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mvrach := PadR( perso->fio, 35 )
      mtabn_vr := perso->tab_nom
    Endif
    box_shadow( r1, 0, 23, 79, color8, ;
      if( nKey == K_INS, "Добавление новой", ;
      "Редактирование" ) + " платной услуги в чеке", "RB+/B" )
    Do While .t.
      SetColor( cDataCGet )
      @ r1 + 2, 2 Say "Шифр услуги" Get mshifr Pict "@!" ;
        when {| g| f5e_kp_kusl( g, 1, 1, 1 ) } ;
        valid {| g| f5e_kp_kusl( g, 2, 1, 1 ) }
      @ r1 + 3, 2 Say "Цена услуги" Get mu_cena Pict pict_cena ;
        when {| g| Len( pr_k_usl ) == 0 .and. f5e_kp_kusl( g, 1, 2 ) } ;
        valid {| g| f5e_kp_kusl( g, 2, 2 ) }
      @ r1 + 4, 2 Say "Услуга" Get mname_u When .f. Color color14
      @ r1 + 5, 2 Say "Таб.№ врача" Get mtabn_vr Pict "99999" ;
        valid {| g| f5e_kp_kusl( g, 2, 3 ) }
      @ Row(), Col() + 3 Get mvrach When .f. Color color14
      @ r1 + 6, 2 Say "Количество услуг" Get mkol Pict "999" ;
        valid {| g| f5e_kp_kusl( g, 2, 5 ) } When iif( flg_edit == 2, .f., .t. )
      @ r1 + 7, 2 Say "Общая стоимость услуги" Get mstoim Pict pict_cena ;
        When .f.
      status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи" )
      myread()
      If LastKey() != K_ESC
        If Len( pr_k_usl ) == 0 .and. emptyany( mu_kod, mstoim )
          func_error( 4, "Не введена услуга!" )
          Loop
        Elseif Len( pr_k_usl ) == 0 .and. Empty( mstoim )
          func_error( 4, "Не введена цена услуги!" )
          Loop
        Elseif Empty( mkod_vr )
          func_error( 4, "Не введен врач!" )
          Loop
        Else
          mywait()
          If nKey == K_INS .and. Len( pr_k_usl ) > 0
            // комплексная услуга
            For i := 1 To Len( pr_k_usl )
              mshifr := pr_k_usl[ i, 1 ]
              mu_kod := pr_k_usl[ i, 3 ]
              mname_u := pr_k_usl[ i, 4 ]
              mu_cena := pr_k_usl[ i, 5 ]
              mt_edit := pr_k_usl[ i, 7 ]
              mis_nul := pr_k_usl[ i, 9 ]
              mstoim := round_5( mu_cena * mkol, 2 )
              //
              Select HU
              addrec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
              //
              Select HU
              Replace hu->kod     With human->( RecNo() ), ;
                hu->kod_vr  With mkod_vr, ;
                hu->stoim   With mstoim, ;
                hu->u_kod   With mu_kod, ;
                hu->u_cena  With mu_cena, ;
                hu->kol     With mkol
              Unlock
              Select TMP
              tmp->rec_hu := mrec_hu
              tmp->KOD_VR := mkod_vr
              tmp->U_KOD := mu_kod
              tmp->U_CENA := mu_cena
              tmp->KOL := mkol
              tmp->STOIM := mstoim
              tmp->shifr_u := mshifr
              tmp->name_u := mname_u
              pr_kod_vr := tmp->kod_vr
            Next
          Else  // одна услуга
            Select HU
            If nKey == K_INS
              addrec( 7 )
              mrec_hu := hu->( RecNo() )
              fl_found := .t.
              Select TMP
              Append Blank
              rec_tmp := tmp->( RecNo() )
            Else
              Goto ( mrec_hu )
              g_rlock( forever )
              Select TMP
              Goto ( rec_tmp )
            Endif
            Select HU
            Replace hu->kod     With human->( RecNo() ), ;
              hu->kod_vr  With mkod_vr, ;
              hu->stoim   With mstoim, ;
              hu->u_kod   With mu_kod, ;
              hu->u_cena  With mu_cena, ;
              hu->kol     With mkol
            Unlock
            Select TMP
            tmp->rec_hu := mrec_hu
            tmp->KOD_VR := mkod_vr
            tmp->U_KOD := mu_kod
            tmp->U_CENA := mu_cena
            tmp->KOL := mkol
            tmp->STOIM := mstoim
            tmp->shifr_u := mshifr
            tmp->name_u := mname_u
            pr_kod_vr := tmp->kod_vr
          Endif
          summa_usl( @mcena )
          HU->( dbCommit() ) // 16.06.08
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found
      flag := 1
    Endif
    RestScreen( buf )
    f3e_kp_kusl()
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. tmp->rec_hu > 0 .and. flg_edit == 1
    If f_esc_enter( 2 )
      mywait()
      Select HU
      Goto ( tmp->rec_hu )
      deleterec( .t. )
      Select TMP
      deleterec( .t. )
      summa_usl( @mcena )
      Select HUMAN
      g_rlock( forever )
      Replace human->cena With mcena
      Unlock
      Commit
      Select TMP
      oBrow:gotop()
      Go Top
      If Eof()
        fl_found := .f. ; Keyboard Chr( K_INS )
      Endif
      flag := 0
      RestScreen( buf )
      f3e_kp_kusl()
    Endif
  Otherwise
    Keyboard ""
  Endcase
  Return flag

//
Static Function summa_usl( s )

  Local j := 0

  s := 0
  Select TMP
  Go Top
  Do While !Eof()
    s += tmp->stoim
    Skip
  Enddo
  s := Round( s, 2 )
  Return Nil

//
Function f5e_kp_kusl( get, when_valid, k, ipl_ort )

  Local fl := .t., old_kod, ar, ;
    msg1_err := "Код врача равен коду техника! Это недопустимо.", ;
    msg2_err := "Человека с таким кодом нет в базе данных персонала!", ;
    blk_sum := {|| mstoim := round_5( mu_cena * mkol, 2 ) }

  If when_valid == 1    // when
    If k == 1     // Шифр услуги
      If !Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 2     // цена услуги
      If !Empty( mu_kod )
        Select KU
        find ( Str( mu_kod, 4 ) )
        fl := Found()
      Endif
    Elseif k == 5 // Количество услуг
      If Empty( mshifr )
        fl := .f.
      Elseif mt_edit > 1
        fl := .f.
      Endif
    Endif
  Else                  // valid
    If k == 1 // Шифр услуги
      If !Empty( mshifr ) .and. !( mshifr == get:original )
        mshifr := transform_shifr( mshifr )
        Select USL
        Set Order To 1
        find ( mshifr )
        If Found()
          mu_kod := usl->kod
          mname_u := usl->name
          mu_cena := 0
          If iif( ipl_ort == 1, .t., ( m1vid != LPU_KAS_B_PL ) )
            // сначала берем цену для платных услуг
            // mu_cena := if(smvzros_reb==0, usl->pcena, usl->pcena_d)
            If ipl_ort == 1 // для платных услуг
              ar := cenausldate( human->k_data, mu_kod )
            Else  // для ортопедии - по дате открытия наряда
              ar := cenausldate( glob_nar[ 7 ], mu_kod )
            Endif
            mu_cena := if( smvzros_reb == 0, ar[ 1 ], ar[ 2 ] )
          Endif
          mkol := 1
          Eval( blk_sum )
          update_gets()
        Elseif ipl_ort == 1 .and. get_k_usluga( mshifr, smvzros_reb, @fl )
          box_shadow( r1 - 5, 40, r1 - 3, 77, cColorStMsg, ;
            "Комплексная услуга", cColorSt2Msg )
          @ r1 - 4, 41 Say PadC( "Количество услуг - " + lstr( Len( pr_k_usl ) ), 36 ) Color cColorStMsg
          mkol := 1
          If fl  // сменить код врача и ассистента
            mvrach := Space( 35 )
            mtabn_vr := ret_tabn( mkod_vr )
            If mkod_vr > 0
              Select PERSO
              Goto ( mkod_vr )
              If !Eof() .and. !Deleted()
                mvrach := PadR( perso->fio, 35 )
              Endif
            Endif
          Endif
          fl := update_gets()
        Else
          fl := func_error( 4, "Такого шифра нет в базе данных услуг." )
        Endif
      Endif
    Elseif k == 2 // цена услуги
      Eval( blk_sum )
      update_gets()
    Elseif k == 3 // Код врача
      old_kod := mkod_vr
      If Empty( mtabn_vr )
        mkod_vr := 0
        mvrach := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_vr, 5 ) )
        If Found()
          If Type( "mkod_tex" ) == "N" .and. perso->kod == mkod_tex
            fl := func_error( 4, msg1_err )
          Else
            mkod_vr := perso->kod
            mvrach := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_vr
        update_get( "mvrach" )
      Endif
    Elseif k == 4 // Код техника
      old_kod := mkod_tex
      If Empty( mtabn_tex )
        mkod_tex := 0
        mtexnik := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_tex, 5 ) )
        If Found()
          If perso->kod == mkod_vr
            fl := func_error( 4, msg1_err )
          Else
            mkod_tex := perso->kod
            mtexnik := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_tex
        update_get( "mtexnik" )
      Endif
    Elseif k == 5 // Количество услуг
      If mkol != get:original
        Eval( blk_sum )
        update_gets()
      Endif
    Endif
    If !fl
      &( ReadVar() ) := get:original
    Endif
  Endif
  Return fl

//
Function regi_s_plat( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 0
  If k == 0
    mas_pmt := { "~Персонал + услуги", ;
      "Персонал + услуги + ~больные", ;
      "~Услуги + персонал", ;
      "~Журнал Регистрации", ;
      "~Настраиваемый журнал Регистрации", ; // 21.05.08
    "Свод по услугам", ;
      "Реестр по платным услугам" }
    mas_msg := { "Персонал + услуги (за период времени)", ;
      "Персонал + услуги + больные (за период времени)", ;
      "Услуги + персонал (за период времени)", ;
      "Журнал регистрации договоров", ;
      "Настраиваемый Журнал регистрации договоров", ; // 21.05.08
    "Свод по услугам", ;
      "Реестр по платным услугам за период" }
    mas_fun := { "regi_s_plat(1)", ;
      "regi_s_plat(2)", ;
      "regi_s_plat(3)", ;
      "regi_s_plat(4)", ;
      "regi_s_plat(5)", ;
      "regi_s_plat(6)", ;
      "regi_s_plat(7)" }
    popup_prompt( T_ROW, T_COL - 5, si4, mas_pmt, mas_msg, mas_fun )
  Else
    Do Case
    Case k == 1
      f2r_s_plat( 3 )  // персонал + услуги за период времени
    Case k == 2
      f2r_s_plat( 5 )  // персонал + услуги + больные за период времени
    Case k == 3
      f2r_s_plat( 4 )  // услуги + персонал за период времени
    Case k == 4
      pl_dogovor() // 10.05
    Case k == 5
      pl_2dogovor() // 10.05  21.05.08
    Case k == 6
      pl_priemden()
    Case k == 7
      prn_k_plat( 2 )   // 09.10.17
    Endcase
  Endif
  If k > 0
    si4 := k
  Endif
  Return Nil

//
Function f2r_s_plat( reg )

  Static snomer := 1, sreg1 := 1
  Local i, j, k, arr[ 2 ], buf := save_row( MaxRow() ), buf1, ;
    fl_exit := .f., sh, HH := 57, reg_print, ;
    arr_title, name_file := cur_dir() + "n_kvit.txt", ;
    vstoim := 0, sstoim := 0, old := 0, ;
    speriod, begin_date, end_date, cp := " "

  // if input_uch(T_ROW,T_COL-5,.f.) == NIL
  // return NIL
  // endif
  // if (up_usl := ret_up_usl()) == NIL
  // return NIL
  // endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  speriod := arr_m[ 4 ]
  begin_date := arr_m[ 5 ]
  end_date := arr_m[ 6 ]
  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  //
  dbCreate( cur_dir() + "tmp", { { "U_KOD","N", 4, 0 }, ; // код услуги
  { "KOD_VR", "N", 4, 0 }, ; // код врача
  { "KOD_B", "N", 7, 0 }, ; // код больного
  { "KOL","N", 5, 0 }, ; // количество услуг
  { "STOIM","N", 10, 2 } } ) // итоговая стоимость услуги
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_vr, 4 ) + Str( u_kod, 4 ) + Str( kod_b, 7 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "uslugi", dir_server() + "uslugi", "USL" )
  r_use( dir_server() + "kas_pl", dir_server() + "kas_pl2", "KP" )
  r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "KPU" )
  Select KP
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While kp->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    Select KPU
    find ( Str( kp->( RecNo() ), 7 ) )
    Do While kp->( RecNo() ) == kpu->kod .and. !Eof()
      Select TMP
      find ( Str( kpu->kod_vr, 4 ) + Str( kpu->u_kod, 4 ) + Str( 0, 7 ) )
      If !Found()
        Append Blank
        tmp->kod_vr := kpu->kod_vr
        tmp->u_kod  := kpu->u_kod
      Endif
      tmp->kol += kpu->kol
      tmp->stoim += kpu->stoim
      If reg == 5
        Select TMP
        find ( Str( kpu->kod_vr, 4 ) + Str( kpu->u_kod, 4 ) + Str( kp->kod_k, 7 ) )
        If !Found()
          Append Blank
          tmp->kod_vr := kpu->kod_vr
          tmp->u_kod  := kpu->u_kod
          tmp->kod_b  := kp->kod_k
        Endif
        tmp->kol += kpu->kol
        tmp->stoim += kpu->stoim
      Endif
      Select KPU
      Skip
    Enddo
    Select KP
    Skip
  Enddo
  j := tmp->( LastRec() )
  Close databases
  rest_box( buf )
  If fl_exit
    // ничего
  Elseif j == 0
    func_error( 4, "Нет сведений за указанный период времени" )
  Else
    mywait()
    reg_print := 2
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "mo_pers",, "PERSO" )
    Use ( cur_dir() + "tmp" ) New Alias TMP
    Set Relation To kod_vr into PERSO, To u_kod into USL
    If equalany( reg, 1, 3 )
      Index On Str( kod_vr, 4 ) + fsort_usl( usl->shifr ) to ( cur_dir() + "tmp" )
    Elseif equalany( reg, 2, 4 )
      Index On Str( u_kod, 4 ) + fsort_usl( usl->shifr ) + Str( kod_vr, 4 ) to ( cur_dir() + "tmp" )
    Elseif reg == 5
      cp := "."
      r_use( dir_server() + "kartotek",, "KART" )
      Select TMP
      Set Relation To kod_b into KART Additive
      Index On Str( kod_vr, 4 ) + fsort_usl( usl->shifr ) + Upper( Left( kart->fio, 20 ) ) to ( cur_dir() + "tmp" )
    Endif
    arr_title := { ;
      "───────────────────────────────────────────────────────────┬─────┬─────────────", ;
      "                                                           │ Кол.│  Стоимость  ", ;
      "                                                           │услуг│    услуг    ", ;
      "───────────────────────────────────────────────────────────┴─────┴─────────────" }
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( glob_uch[ 2 ] )
    add_string( "" )
    If reg == 3
      add_string( Center( "Реестр доплат [ персонал + услуги ]", sh ) )
    Elseif reg == 4
      add_string( Center( "Реестр доплат [ услуги + персонал ]", sh ) )
    Elseif reg == 5
      add_string( Center( "Реестр доплат [ персонал + услуги + больные ]", sh ) )
    Endif
    add_string( "" )
    add_string( Center( speriod, sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If equalany( reg, 1, 3, 5 )
        If old != tmp->kod_vr
          If old != 0
            add_string( Space( sh - 20 ) + Replicate( "-", 20 ) )
            add_string( Space( sh - 20 ) + "Итого:" + PadL( expand0value( vstoim, 2 ), 14 ) )
            vstoim := 0
          Endif
          add_string( "" )
          add_string( "[" + lstr( perso->tab_nom ) + "] " + AllTrim( perso->fio ) )
          old := tmp->kod_vr
        Endif
        k := perenos( arr, AllTrim( usl->shifr ) + ". " + AllTrim( usl->name ), 55 )
      Else
        If old != tmp->u_kod
          If old != 0
            add_string( Space( sh - 20 ) + Replicate( "-", 20 ) )
            add_string( Space( sh - 20 ) + "Итого:" + PadL( expand0value( vstoim, 2 ), 14 ) )
            vstoim := 0
          Endif
          add_string( "" )
          add_string( AllTrim( usl->shifr ) + ". " + AllTrim( usl->name ) )
          old := tmp->u_kod
        Endif
        k := perenos( arr, "[" + lstr( perso->tab_nom ) + "] " + AllTrim( perso->fio ), 55 )
      Endif
      If tmp->kod_b == 0
        add_string( Space( 4 ) + PadR( AllTrim( arr[ 1 ] ), 55, cp ) + ;
          PadL( lstr( tmp->kol ), 6, cp ) + ;
          PadL( expand0value( tmp->stoim, 2 ), 14, cp ) )
        For i := 2 To k
          add_string( Space( 4 ) + PadL( AllTrim( arr[ i ] ), 55 ) )
        Next
        vstoim += tmp->stoim ; sstoim += tmp->stoim
      Else
        add_string( Space( 8 ) + PadR( kart->fio, 51 ) + ;
          Str( tmp->kol, 6 ) + PadL( expand0value( tmp->stoim, 2 ), 14 ) )
      Endif
      Select TMP
      Skip
    Enddo
    add_string( Space( sh - 20 ) + Replicate( "-", 20 ) )
    add_string( Space( sh - 20 ) + "Итого:" + PadL( expand0value( vstoim, 2 ), 14 ) )
    add_string( Replicate( "═", sh ) )
    add_string( Space( sh - 20 ) + "ИТОГО:" + PadL( expand0value( sstoim, 2 ), 14 ) )
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  If buf1 != NIL
    rest_box( buf1 )
  Endif
  Return Nil

//
Function pl_priemden()

  Local fl := .t., buf := save_row( MaxRow() ), sm := 0, HH := 59, ;
    n_file := cur_dir() + "platn.txt", arr_m, sum3 := 0, sh
  Local arr_title := { ;
    "───────────────────────────────────────────────────┬────────┬───────────", ;
    "                  Услуги                           │ Кол-во │   Сумма   ", ;
    "───────────────────────────────────────────────────┴────────┴───────────";
    }

  sh := Len( arr_title[ 1 ] )
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  If !myfiledeleted( cur_dir() + "tmp" + sdbf() )
    Return Nil
  Endif
  //
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod",     "N", 4,   0 }, ;
    { "name",    "C", 60,  0 }, ;
    { "kod_1",   "C", 10,  0 }, ;
    { "kol_vo",  "N", 10,  0 }, ;
    { "summa",   "N", 12,  2 } } )
  Use ( cur_dir() + "tmp" ) new
  Index On kod to ( cur_dir() + "tmp_u" )
  r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "HUM_U" )
  r_use( dir_server() + "kas_pl",, "HUM" )
  Index On Str( kod_oper, 3 ) to ( cur_dir() + "tmp_hum" ) For Between( k_data, arr_m[ 5 ], arr_m[ 6 ] )
  Go Top
  Do While !Eof()
    Select HUM_U
    find ( Str( hum->( RecNo() ), 7 ) )
    Do While hum->( RecNo() ) == hum_u->kod .and. !Eof()
      Select TMP
      find ( hum_u->u_kod )
      If !Found()
        Append Blank
        tmp->kod := hum_u->u_kod
      Endif
      tmp->kol_vo += hum_u->kol
      tmp->summa  += hum_u->stoim
      Select HUM_U
      Skip
    Enddo
    Select HUM
    Skip
  Enddo
  r_use( dir_server() + "uslugi",, "USL" )
  Select TMP
  Set Relation To kod into USL
  Go Top
  Do While !Eof()
    tmp->name  := usl->name
    tmp->kod_1 := usl->shifr
    Skip
  Enddo
  Select TMP
  Index On fsort_usl( kod_1 ) to ( cur_dir() + "tmp_u" )
  fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
  add_string( Center( "Оплата услуг", sh ) )
  add_string( Center( "по дате НАЧАЛА лечения", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  add_string( "" )
  AEval( arr_title, {| x| add_string( x ) } )
  Go Top
  sm1 := sm2 := 0
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    add_string( tmp->kod_1 + PadR( tmp->name, 40 ) + ;
      Str( tmp->kol_vo, 9 ) + ;
      put_kope( tmp->summa, 12 ) )
    sm1 += tmp->kol_vo
    SM2 += tmp->summa
    Skip
  Enddo
  add_string( Replicate( "─", sh ) )
  add_string( PadR( "Итого: ", 50 ) + ;
    Str( SM1, 9 ) + ;
    put_kope( SM2, 12 ) )
  Close databases
  FClose( fp )
  viewtext( n_file,,,, ( sh > 80 ),,, 2 )
  rest_box( buf )
  Return Nil

//
Function pl_dogovor()

  Local buf := save_row( MaxRow() ), sh, HH := 49, arr_title, s, i, j, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis, name_file := cur_dir() + "jurnal.txt"

  arr_title := { ;
    "─────────────────────────────┬───────┬─────────────────────────────────────────────────────────────────┬───────┬────┬──────────┬──────────┬──────────", ;
    "        Ф.И.О., адрес        │ НОМЕР │                   Название медицинской услуги                   │  Цена │Кол.│ Сумма за │   Дата   │   Срок   ", ;
    "        застрахованного      │медицин│                                                                 │ каждой│оказ│все кол-во│  приема  │ оказания ", ;
    "                             │ карты │                                                                 │ услуги│ус- │оказ.услуг│   мед.   │   мед.   ", ;
    "                             │       │                                                                 │ (руб.)│луг │  (руб.)  │  услуги  │  услуги  ", ;
    "─────────────────────────────┴───────┴─────────────────────────────────────────────────────────────────┴───────┴────┴──────────┴──────────┴──────────" }
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( Center( "Ж У Р Н А Л", sh ) )
  add_string( Center( "учета заказов граждан на оказание им платных медицинских услуг(помощи)", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "HPU" )
  r_use( dir_server() + "kas_pl",, "HU" )
  Index On DToS( k_data ) + Str( n_chek, 6 ) to ( cur_dir() + "tmp_hum" ) For Between( k_data, arr_m[ 5 ], arr_m[ 6 ] )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select HU
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    ss += hu->cena
    Select KART
    Goto hu->kod_k
    kfio := perenos( afio, AllTrim( kart->fio ) + " " + AllTrim( kart->adres ), 29 )
    fl_hu := .t. ; i := 0
    Select HPU
    t_kod := hu->( RecNo() )
    find ( Str( t_kod, 7 ) )
    Do While t_kod == hpu->kod .and. !Eof()
      usl->( dbGoto( hpu->u_kod ) )
      If fl_hu
        fl_hu := .f.
        add_string( afio[ 1 ] + " " + ;
          PadR( lstr( hu->kod_k ), 7 ) + " " + ;
          PadR( usl->name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
          PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
          full_date( hu->k_data ) + " " + full_date( hu->k_data ) )
        i := 1
      Else
        ++i
        add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
          Space( 7 ) + " " + ;
          PadR( usl->name, 65 ) + " " + put_kop( hpu->u_cena, 7 ) + " " + ;
          PadR( lstr( hpu->kol ), 4 ) + " " + put_kop( hpu->stoim, 10 ) + " " + ;
          full_date( hu->k_data ) + " " + full_date( hu->k_data ) )
      Endif
      Select HPU
      Skip
    Enddo
    If i == 1
      add_string( iif( 1 < kfio, afio[ 2 ], Space( 29 ) ) )
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + Str( ss, 11, 2 ), sh - 12 ) )
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function pl_2dogovor()

  Local buf := save_row( MaxRow() ), sh, HH := 49, arr_title, s, i, k, sk, ss, ;
    arr2title, reg_print := 6, afio[ 10 ], lfio := 19, kfio, lsk, lss, adbf, ;
    aadres[ 2 ], kadres, apolis[ 10 ], kpolis, name_file := cur_dir() + "jurnal1.txt", ;
    t_vr, t_as, t_nvr, t_nas

  arr_title := { ;
    "─────────────────────────────┬──────────", ;
    "        Ф.И.О., адрес        │   Дата   ", ;
    "        застрахованного      │ рождения ", ;
    "                             │          ", ;
    "                             │          ", ;
    "─────────────────────────────┴──────────" }
  // номер карты
  arr_1 := { ;
    "┬───────", ;
    "│ НОМЕР ", ;
    "│медицин", ;
    "│ карты ", ;
    "│       ", ;
    "┴───────" }
  // номер чека
  arr_2 := { ;
    "┬──────", ;
    "│НОМЕР ", ;
    "│      ", ;
    "│ чека ", ;
    "│      ", ;
    "┴──────" }
  // дата оплаты услуги
  arr_3 := { ;
    "┬────────", ;
    "│  Дата  ", ;
    "│ оплаты ", ;
    "│  мед.  ", ;
    "│ услуги ", ;
    "┴────────" }
  // дата оказания услуги
  arr_4 := { ;
    "┬────────", ;
    "│  Дата  ", ;
    "│оказания", ;
    "│  мед.  ", ;
    "│ услуги ", ;
    "┴────────" }
  // шифр услуги
  arr_5 := { ;
    "┬──────────", ;
    "│ Код мани-", ;
    "│ пуляции  ", ;
    "│          ", ;
    "│          ", ;
    "┴──────────" }
  // наименование услуги
  arr_6 := { ;
    "┬──────────────────────────────────────────────────", ;
    "│                                                  ", ;
    "│       Вид (наименование) медицинской услуги      ", ;
    "│                                                  ", ;
    "│                                                  ", ;
    "┴──────────────────────────────────────────────────" }
  // код врач
  arr_7 := { ;
    "┬─────", ;
    "│     ", ;
    "│     ", ;
    "│Врач ", ;
    "│     ", ;
    "┴─────" }
  // код м/c
  arr_8 := { ;
    "┬─────", ;
    "│     ", ;
    "│     ", ;
    "│ М/с ", ;
    "│     ", ;
    "┴─────" }
  // фио врача+м/с
  arr_9  := { ;
    "┬───────────────", ;
    "│               ", ;
    "│     Врач      ", ;
    "├───────────────", ;
    "│     М/с       ", ;
    "┴───────────────" }
  // цена услуги
  arr_10 := { ;
    "┬───────", ;
    "│  Цена ", ;
    "│ каждой", ;
    "│ услуги", ;
    "│ (руб.)", ;
    "┴───────" }
  // количество услуг
  arr_11 := { ;
    "┬────", ;
    "│Кол.", ;
    "│оказ", ;
    "│ус- ", ;
    "│луг ", ;
    "┴────" }
  // сумма услуг
  arr_00 := { ;
    "┬──────────", ;
    "│ Сумма за ", ;
    "│все кол-во", ;
    "│оказ.услуг", ;
    "│  (руб.)  ", ;
    "┴──────────" }
  Private glob_pozic
  If ( glob_pozic := inputnpozic( T_ROW, T_COL + 5 ) ) == NIL
    Return Nil
  Endif
  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  // создаем заголовок
  For i := 0 To 10
    If f_is_pozic( glob_pozic, i )
      For j := 1 To 6
        arr_title[ j ] += &( "arr_" + lstr( i + 1 ) + "[j]" )
      Next
    Endif
  Next
  For j := 1 To 6
    arr_title[ j ] += arr_00[ j ]
  Next
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  r_use( dir_server() + "kas_usld",, "PUSL" )
  Index On Str( u_kod, 4 ) to ( cur_dir() + "tmp_ud" )
  r_use( dir_server() + "mo_pers",, "P2" )
  r_use( dir_server() + "organiz",, "ORG" )
  add_string( Center( "Ж У Р Н А Л", sh ) )
  add_string( Center( "учета заказов граждан на оказание им платных медицинских услуг(помощи)", sh ) )
  add_string( Center( arr_m[ 4 ], sh ) )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "kas_pl_u", dir_server() + "kas_pl1u", "HPU" )
  r_use( dir_server() + "kas_pl",, "HU" )
  Index On DToS( k_data ) + Str( n_chek, 6 ) to ( cur_dir() + "tmp_hum" ) For Between( k_data, arr_m[ 5 ], arr_m[ 6 ] )
  AEval( arr_title, {| x| add_string( x ) } )
  j := sk := ss := 0
  Select HU
  Go Top
  Do While !Eof()
    If verify_ff( HH, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
    Endif
    // проверка на услуги-продажи
    i := 0
    fl_prod := .f.
    Select HPU
    t_kod := hu->( RecNo() )
    find ( Str( t_kod, 7 ) )
    Do While t_kod == hpu->kod .and. !Eof()
      ++i
      If i > 1
        Exit // более 1 услуги
      Endif
      Select PUSL
      find ( Str( hpu->u_kod, 4 ) )
      If Found()
        fl_prod := .t.
      Endif
    Enddo
    If fl_prod // продажи выходим на начало
      Select HU
      Skip
      Loop
    Endif
    ss += hu->cena
    Select KART
    Goto hu->kod_k
    kfio := perenos( afio, AllTrim( kart->fio ) + " " + AllTrim( kart->adres ), 29 )
    fl_hu := .t.
    Select HPU
    // t_kod := hu->(recno())
    find ( Str( t_kod, 7 ) )
    Do While t_kod == hpu->kod .and. !Eof()
      usl->( dbGoto( hpu->u_kod ) )
      Select P2
      Goto ( hpu->kod_vr )
      t_vr := p2->tab_nom ; t_as := 0
      t_nvr := fam_i_o( p2->fio )
      If fl_hu
        fl_hu := .f.
        // goto (hpu->kod_as)
        // t_nas := "  "//fam_i_o(p2->fio)
        //
        add_string( afio[ 1 ] + " " + ;
          full_date( kart->date_r ) + " " + ; //
        iif( f_is_pozic( glob_pozic, 0 ), PadR( lstr( hu->kod_k ), 7 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 1 ), PadR( lstr( hu->n_chek ), 6 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 2 ), date_8( hu->k_data ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 3 ), date_8( hu->k_data ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 5 ), PadR( usl->name, 50 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadL( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 9 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 10 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
          put_kop( hpu->stoim, 10 ) )
        i := 1
      Else
        ++i
        add_string( iif( i <= kfio, afio[ i ], Space( 29 ) ) + " " + ;
          Space( 10 ) + " " + ;
          iif( f_is_pozic( glob_pozic, 0 ), Space( 8 ), "" ) + ;
          iif( f_is_pozic( glob_pozic, 1 ), Space( 7 ), "" ) + ;
          iif( f_is_pozic( glob_pozic, 2 ), Space( 8 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 3 ), date_8( hu->k_data ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 4 ), usl->shifr + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 5 ), PadR( usl->name, 50 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 6 ), iif( t_vr > 0, PadL( lstr( t_vr ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 7 ), iif( t_as > 0, PadL( lstr( t_as ), 5 ), Space( 5 ) ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 8 ), PadR( t_nvr, 15 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 9 ), put_kop( hpu->u_cena, 7 ) + " ", "" ) + ;
          iif( f_is_pozic( glob_pozic, 10 ), PadR( lstr( hpu->kol ), 4 ) + " ", "" ) + ;
          put_kop( hpu->stoim, 10 ) )
      Endif
      Select HPU
      Skip
    Enddo
    If i == 1 .and. 1 < kfio
      add_string( afio[ 2 ] )
    Endif
    If mem_dop_st == 2
      add_string( "" )
    Endif
    Select HU
    Skip
  Enddo
  Close databases
  add_string( Replicate( "─", sh ) )
  add_string( PadL( "Итого : " + lstr( ss, 14, 2 ), sh ) )
  add_string( "" )
  add_string( "" )
  add_string( Center( "Главный врач _________________                         Главный бухгалтер _________________", sh ) )
  FClose( fp )
  rest_box( buf )
  Private yes_albom := .t.
  viewtext( name_file,,,, ( sh > 80 ),,, reg_print )
  Return Nil

//
Function inputnpozic( r, c, fl_max )

  Static st_pozic := {}
  Local i, k, t_mas, ;
    buf := SaveScreen(), l_a_pozic
  Local mas_s := { "Номер карты", ;
    "Номер чека", ;
    "Дата оплаты мед.услуги", ;
    "Дата оказания мед.услуги", ;
    "Шифр мед.услуги", ;
    "Наименование мед.услуги", ;
    "Код Врача", ;
    "Код Медсестры", ;
    "ФИО врача+м/с", ;
    "Цена услуги", ;
    "Количество услуг" }

  Local mas := { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }

  Default fl_max To .f.
  If ( k := r + 11 ) > MaxRow() -2
    k := MaxRow() -2
  Endif
  If c + 35 > MaxCol() -2
    c := MaxCol() -2 -35
  Endif
  t_mas := AClone( mas_s )
  If fl_max  // принудительное полное заполнение
    AEval( mas, {| x| AAdd( st_pozic, x ) } )
  Endif
  AEval( t_mas, {| x, i| ;
    t_mas[ i ] := if( AScan( st_pozic, mas[ i ] ) > 0, " * ", "   " ) + t_mas[ i ] } )
  status_key( "^<Esc>^ - отказ ^<Enter>^ - подтверждение ^<Ins>^ - смена признака выбора" )
  Do While .t.
    l_a_pozic := NIL
    If Popup( r, c, k, c + 35, t_mas, i, color0, .t., "fmenu_reader",, "Колонки информации", "B/BG" ) > 0
      l_a_pozic := {} ; st_pozic := {}
      For i := 1 To 11
        If "*" == SubStr( t_mas[ i ], 2, 1 )
          AAdd( l_a_pozic, { ( i - 1 ), AllTrim( mas_s[ i ] ), } )
          AAdd( st_pozic, mas[ i ] )
        Endif
      Next
      If Empty( l_a_pozic )
        // func_error(4,"Необходимо отметить хотя бы один источник финансирования!")
        // loop
        Exit
      Else
        Exit
      Endif
    Else
      Exit
    Endif
  Enddo
  RestScreen( buf )
  Return l_a_pozic

//
Function f_is_pozic( arr_s, pozic )
  Return ( AScan( arr_s, {| x| pozic == x[ 1 ] } ) > 0 )
