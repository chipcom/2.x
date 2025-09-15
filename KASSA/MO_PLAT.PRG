// mo_plat.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

//
Function begin_task_plat()

  Static n_zapusk := 0

  If n_zapusk == 0
    ++n_zapusk
    Public menu_kb := { { "платный", PU_PLAT }, ;
      { "ДМС    ", PU_D_SMO }, ;
      { "в/зачет", PU_PR_VZ } }
    Public arr_opl_7, len_arr_7
    Public count_otd := 1
    Public count_uch := 1
    Public is_all_uch := .t.
    Public gmenu_kateg := { { "врач", 1 }, ;
      { "средний мед.персонал", 2 }, ;
      { "младший мед.персонал", 3 }, ;
      { "прочие", 4 } }
  Endif
  If copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
    tools_ini_platn( 1, 0, 0 )
  Else
    Return .f.
  Endif
  If glob_kassa == 1
    If hb_FileExists( "__kassa_.log" ) .and. FileSize( "__kassa_.log" ) > 5000000
      Delete file __kassa_.log
    Endif
    f5_sist_fr( 1 )
  Endif

  Return .t.

//
Function s_pl_meds( reg )

  Local t_arr[ BR_LEN ], mtitle := "Справочник " + { "медсестер", "санитарок" }[ reg ]
  Private str_find := Str( reg, 1 ), muslovie := "dbf1->tip==" + lstr( reg )

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 10
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 29
  t_arr[ BR_OPEN ] := {|| f1_dbf1(,, "open", reg ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t. }
  t_arr[ BR_COLUMN ] := { { " Код", {|| dbf1->tab_nom } }, ;
    { Center( "Ф.И.О.", 20 ), {|| PadR( dbf1->fio, 20 ) } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_dbf1( nk, ob, "edit", reg ) }
  edit_browse( t_arr )

  Return Nil

//
Function f1_dbf1( nKey, oBrow, regim, lregim )

  Local ret := -1
  Local buf, fl := .f., rec, rec1, k := 17, tmp_color

  Do Case
  Case regim == "open"
    g_use( dir_server() + "plat_ms", dir_server() + "plat_ms", "DBF1" )
    find ( str_find )
    ret := Found()
  Case regim == "choice" .and. nKey == K_SPACE
    ret := 1
  Case regim == "edit"
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( dbf1->tab_nom ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/N" )
      Endif
      Private mshifr, mname, gl_area := { 1, 0, 23, 79, 0 }
      mtab_nom := if( nKey == K_INS, 0, dbf1->tab_nom )
      mfio := if( nKey == K_INS, Space( 20 ), dbf1->fio )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Код" Get mtab_nom Pict "99999"
      @ k + 2, pc1 + 3 Say "Ф.И.О."
      @ k + 3, pc1 + 8 Get mfio
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. Updated() .and. ;
          !emptyany( mtab_nom, mfio ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrec( 1 )
          Replace dbf1->tip With lregim
        Else
          g_rlock( forever )
        Endif
        Replace dbf1->tab_nom With mtab_nom, dbf1->fio With mfio
        Unlock
        Commit
        oBrow:gotop()
        find ( str_find + Str( mtab_nom, 5 ) )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( dbf1->tab_nom ) .and. f_esc_enter( 2 )
      buf := save_row( MaxRow() )
      stat_msg( "Ждите! Производится проверка на допустимость удаления" )
      rec := dbf1->( RecNo() )
      g_use( dir_server() + "hum_p_u",, "HU" )
      If lregim == 1
        Locate For equalany( rec, hu->med1, hu->med2, hu->med3 ) progress
      Else
        Locate For equalany( rec, hu->san1, hu->san2, hu->san3 ) progress
      Endif
      fl := Found()
      Use
      If fl
        func_error( 4, "Данный человек встречается в других базах данных. Удаление запрещено!" )
      Endif
      rest_box( buf )
      Select DBF1
      If !fl
        deleterec()
        oBrow:gotop()
        find ( str_find )
        ret := 0
        If !Found()
          ret := 1
        Endif
      Endif
    Endcase
  Endcase

  Return ret

//
Function oplata_vz()

  Static spar := 1
  Local i, j, k, fl, s, buf := SaveScreen(), t_arr[ BR_LEN ], blk, mtitle
  Private par, muslovie, str_find, ;
    menu_opl := { { "безналичн.", 0 }, ;
    { "наличными ", 1 }, ;
    { "в/зачет   ", 2 } }

  If ( par := popup_prompt( T_ROW, T_COL + 5, spar, ;
      { "Предприятия по взаимо~зачету", ;
      "~Добровольное страхование" } ) ) == 0
    Return Nil
  Endif
  spar := par
  Do Case
  Case par == 1
    If !input_pr_vz( T_ROW, T_COL + 5 )
      Return Nil
    Endif
  Case par == 2
    If !input_d_smo( T_ROW, T_COL + 5 )
      Return Nil
    Endif
    If polikl1_kart() <= 0
      Return Nil
    Endif
  Endcase
  If par == 1
    str_find := "2" + Str( glob_pr_vz[ 1 ], 6 ) + Str( 0, 7 )
    muslovie := "opl->tip==2 .and. opl->pr_smo==glob_pr_vz[1] .and. opl->kod_k==0"
    mtitle := glob_pr_vz[ 2 ]
  Elseif par == 2
    str_find := "1" + Str( glob_d_smo[ 1 ], 6 ) + Str( glob_kartotek, 7 )
    muslovie := "opl->tip==1 .and. opl->pr_smo==glob_d_smo[1] .and. opl->kod_k==glob_kartotek"
    mtitle := glob_d_smo[ 2 ]
    box_shadow( 0, 41, 2, 77, color13 )
    @ 1, 42 Say PadC( fam_i_o( glob_k_fio ), 35 ) Color color8
  Endif
  If !g_slock( str_find )
    Return func_error( 4, err_slock() )
  Endif
  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL + 5
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 51
  t_arr[ BR_OPEN ] := {|| fi_opl_vz(,, "open" ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find, -1 ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "W+/GR"
  t_arr[ BR_ARR_BROWSE ] := { "═", "░", "═", "N/BG,W+/N,B/BG,W+/B", .t., 300 }
  t_arr[ BR_COLUMN ] := {}
  AAdd( t_arr[ BR_COLUMN ], { PadC( "Дата", 10 ), {|| full_date( opl->date_opl ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { "Тип оплаты", {|| inieditspr( A__MENUVERT, menu_opl, opl->tip_opl ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { "  Сумма", {|| put_kop( opl->summa_opl, 10 ) }, blk } )
  AAdd( t_arr[ BR_COLUMN ], { "  Примечание", {|| opl->prim }, blk } )
  s := "^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление"
  If is_task( X_ORTO ) .and. par == 2
    s += " ^<F3>^ортопедия"
  Endif
  t_arr[ BR_STAT_MSG ] := {|| status_key( s ) }
  t_arr[ BR_EDIT ] := {| nk, ob| fi_opl_vz( nk, ob, "edit" ) }
  edit_browse( t_arr )
  RestScreen( buf )
  g_sunlock( str_find )

  Return Nil

//  10.03.19
Function fi_opl_vz( nKey, oBrow, regim, lregim )

  Local ret := -1
  Local buf, fl := .f., rec, rec1, k := 14, tmp_color, arr, mdate, nfile, sh := 60

  Do Case
  Case regim == "open"
    g_use( dir_server() + "plat_vz", dir_server() + "plat_vz", "OPL" )
    find ( str_find )
    ret := Found()
  Case regim == "edit"
    Do Case
    Case is_task( X_ORTO ) .and. par == 2 .and. nKey == K_F3
      arr := {}
      use_base( "hum_oro" )
      r_use_base( "hum_ort" )
      find ( Str( glob_kartotek, 7 ) )
      Do While human->kod_k == glob_kartotek
        Select HO
        find ( Str( human->( RecNo() ), 7 ) )
        Do While ho->kod == human->( RecNo() )
          If ho->tip_usl == OU_D_SMO ; // ДМС
            .and. ( mdate := c4tod( ho->pdate ) ) > sys_date - 366 // на год назад
            AAdd( arr, { mdate, ho->cena_opl, ho->prim } )
          Endif
          Skip
        Enddo
        Select HUMAN
        Skip
      Enddo
      ho->( dbCloseArea() )
      human->( dbCloseArea() )
      Select OPL
      If Empty( arr )
        func_error( 4, "Нет информации по оплате ДМС ортопедических услуг за последний год!" )
      Else
        ASort( arr,,, {| x, y| x[ 1 ] < y[ 1 ] } )
        nfile := cur_dir() + "_dms_ort.txt"
        StrFile( Center( "Оплата по ДМС ортопедических услуг за последний год", sh ) + hb_eol(), nfile )
        StrFile( Center( glob_k_fio, sh ) + hb_eol() + hb_eol(), nfile, .t. )
        StrFile( "─────────────┬─────────────────────┬────────────────────────" + hb_eol(), nfile, .t. )
        StrFile( " Дата оплаты │ Сумма оплаты по ДМС │      Примечание        " + hb_eol(), nfile, .t. )
        StrFile( "─────────────┼─────────────────────┼────────────────────────" + hb_eol(), nfile, .t. )
        ss := 0
        For k := 1 To Len( arr )
          StrFile( PadC( full_date( arr[ k, 1 ] ), 13 ) + "│" + ;
            Str( arr[ k, 2 ], 14, 2 ) + "       │  " + ;
            arr[ k, 3 ] + hb_eol(), nfile, .t. )
          ss += arr[ k, 2 ]
        Next
        StrFile( "─────────────┴─────────────────────┴────────────────────────" + hb_eol(), nfile, .t. )
        StrFile( PadC( "Итого:", 13 ) + Str( ss, 15, 2 ) + hb_eol(), nfile, .t. )
        viewtext( nfile )
      Endif
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. opl->tip > 0 )
      If nKey == K_ENTER .and. !ver_pub_date( opl->date_opl, .t. )
        Return ret
      Endif
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/N" )
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/B" )
      Endif
      rec := RecNo()
      Private mtip_opl, m1tip_opl := if( nkey == K_INS, 0, opl->tip_opl ), ;
        mdate_opl := if( nKey == K_INS, sys_date, opl->date_opl ), ;
        msumma_opl := if( nKey == K_INS, 0, opl->summa_opl ), ;
        mprim := if( nKey == K_INS, Space( 15 ), opl->prim ), ;
        gl_area := { 1, 0, 23, 79, 0 }
      mtip_opl := inieditspr( A__MENUVERT, menu_opl, m1tip_opl )
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 2, pc1 + 3 Say "Тип оплаты" Get mtip_opl ;
        reader {| x| menu_reader( x, menu_opl, A__MENUVERT,,, .f. ) }
      @ k + 3, pc1 + 3 Say "Дата оплаты" Get mdate_opl
      @ k + 4, pc1 + 3 Say "Сумма оплаты" Get msumma_opl Pict pict_cena()
      @ k + 5, pc1 + 3 Say "Примечание" Get mprim
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !Empty( msumma_opl ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrec( 1 )
          If par == 1
            opl->tip := 2
            opl->pr_smo := glob_pr_vz[ 1 ]
          Else
            opl->tip := 1
            opl->pr_smo := glob_d_smo[ 1 ]
            opl->kod_k := glob_kartotek
          Endif
          rec := RecNo()
        Else
          g_rlock( forever )
        Endif
        opl->tip_opl   := m1tip_opl
        opl->date_opl  := mdate_opl
        opl->summa_opl := msumma_opl
        opl->prim      := mprim
        Unlock
        Commit
        oBrow:gotop()
        Goto ( rec )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. opl->tip > 0
      If ver_pub_date( opl->date_opl, .t. ) .and. f_esc_enter( 2 )
        deleterec()
        oBrow:gotop()
        find ( str_find )
        ret := 0
        If !Found()
          ret := 1
        Endif
      Endif
    Endcase
  Endcase

  Return ret

// 01.04.23
Function edit_pr_vz()

  Static mas_edit := { '~Просмотр', ;
    '~Редактирование', ;
    '~Добавление', ;
    '~Удаление' }
  Local i := 1, k, buf := SaveScreen(), str_sem := 'Редактирование предприятий по взаимозачету'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Do While i > 0
    If ( i := popup_prompt( T_ROW, T_COL -5, i, mas_edit, , , , .f. ) ) == A__APPEND
      If ( k := f_edit_spr( A__APPEND, get_dms(), 'предприятию по взаимозачету', ;
          "G_Use(dir_server() + 'p_pr_vz')", 0, , , , , , 'f_emp_strah' ) ) > 0
        glob_pr_vz[ 1 ] := k
      Endif
    Elseif i != 0 .and. input_pr_vz( T_ROW + i + 1, T_COL -10 )
      f_edit_spr( i, get_dms(), 'предприятию по взаимозачету', ;
        "G_Use(dir_server() + 'p_pr_vz')", 0, glob_pr_vz[ 1 ], , 'fdel_pr_vz', , , 'f_emp_strah' )
    Endif
  Enddo
  g_sunlock( str_sem )
  RestScreen( buf )

  Return Nil

//
Function input_pr_vz( r, c )

  Local fl := .f., k

  If ( k := popup_edit( dir_server() + "p_pr_vz", r, c, r + 10, glob_pr_vz[ 1 ], 4 ) ) != NIL
    glob_pr_vz := { k[ 1 ], AllTrim( k[ 2 ] ) } ; fl := .t.
  Endif

  Return fl

//
Function fdel_pr_vz( mkod )

  Local fl := .t., buf := save_row( MaxRow() )

  stat_msg( "Ждите! Производится проверка на допустимость удаления данного предприятия" )
  r_use( dir_server() + "hum_p",, "HP" )
  Locate For tip_usl == PU_PR_VZ .and. pr_smo == mkod progress
  fl := !Found()
  hp->( dbCloseArea() )
  //
  r_use( dir_server() + "hum_oro",, "HP" )
  Locate For tip_usl == 2 .and. pr_smo == mkod progress
  fl := !Found()
  hp->( dbCloseArea() )
  If !fl
    func_error( 4, "Данное предприятие встречается в других базах данных. Удаление запрещено!" )
  Endif
  rest_box( buf )

  Return fl

// 01.04.23
Function edit_d_smo()

  Static mas_edit := {  '~Просмотр', ;
    '~Редактирование', ;
    '~Добавление', ;
    '~Удаление' }
  Local i := 1, k, buf := SaveScreen(), str_sem := 'Редактирование добровольных СМО'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Do While i > 0
    If ( i := popup_prompt( T_ROW, T_COL -5, i, mas_edit, , , , .f. ) ) == A__APPEND
      If ( k := f_edit_spr( A__APPEND, get_dms(), 'добровольному СМО', ;
          "G_Use(dir_server() + 'p_d_smo')", 0, , , , , , 'f_emp_strah' ) ) > 0
        glob_d_smo[ 1 ] := k
      Endif
    Elseif i != 0 .and. input_d_smo( T_ROW + i + 1, T_COL -10 )
      f_edit_spr( i, get_dms(), 'добровольному СМО', ;
        "G_Use(dir_server() + 'p_d_smo')", 0, glob_d_smo[ 1 ], , 'fdel_d_smo', , , 'f_emp_strah' )
    Endif
  Enddo
  g_sunlock( str_sem )
  RestScreen( buf )

  Return Nil

//
Function input_d_smo( r, c )

  Local fl := .f., k

  If ( k := popup_edit( dir_server() + "p_d_smo", r, c, r + 10, glob_d_smo[ 1 ], 4 ) ) != NIL
    glob_d_smo := { k[ 1 ], AllTrim( k[ 2 ] ) } ; fl := .t.
  Endif

  Return fl

//
Function fdel_d_smo( mkod )

  Local fl := .t., buf := save_row( MaxRow() )

  stat_msg( "Ждите! Производится проверка на допустимость удаления данной компании" )
  r_use( dir_server() + "hum_p",, "HP" )
  Locate For tip_usl == PU_D_SMO .and. pr_smo == mkod progress
  fl := !Found()
  hp->( dbCloseArea() )
  //
  r_use( dir_server() + "hum_oro",, "HP" )
  Locate For tip_usl == 3 .and. pr_smo == mkod progress
  fl := !Found()
  hp->( dbCloseArea() )
  If !fl
    func_error( 4, "Данная компания встречается в других базах данных. Удаление запрещено!" )
  Endif
  rest_box( buf )

  Return fl

// проверить дату, по которую (включительно) запрещено редактировать данные
Function ver_pub_date( ldate, is_msg )

  Default is_msg To .f.
  is_public_date := .t.
  If Type( "public_date" ) == "D" .and. !Empty( public_date ) ;
      .and. !Empty( ldate ) .and. public_date >= ldate
    is_public_date := .f.
    If is_msg
      func_error( 2, "По " + full_date( public_date ) + "г. включительно данные закрыты для редактирования!" )
    Endif
  Endif

  Return is_public_date
