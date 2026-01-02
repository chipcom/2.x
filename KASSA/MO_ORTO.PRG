// mo_orto.prg
#include "set.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// 13.11.18
Function begin_task_orto()

  Static n_zapusk := 0

  If n_zapusk == 0
    ++n_zapusk
    Public smvzros_reb
    Public menu_okb := { { "платный    ", OU_PLAT  }, ;
      { "бесплатный ", OU_B_PLAT }, ;
      { "ДМС        ", OU_D_SMO }, ;
      { "взаимозачет", OU_PR_VZ } }
    Public menu_otip := { { "платная    ", OU_PLAT  }, ;
      { "бесплатная ", OU_B_PLAT }, ;
      { "ДМС        ", OU_D_SMO }, ;
      { "взаимозачет", OU_PR_VZ } }
  Endif
  If copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
    tools_ini_orto( 1, 0, 0 )
  Else
    Return .f.
  Endif
  If glob_kassa == 1
    f5_sist_fr( 1 )
  Endif
  Return .t.

//
Function orto_diag()

  Local t_arr[ BR_LEN ], ;
    mtitle := "Справочник ортопедических диагнозов"
  Private mm_col_f39 := { ;
    { "00 -- нет привязки --", 0 }, ;
    { "54 Патология твёрдых тканей", 54 }, ;
    { "55 Патологическая стираемость", 55 }, ;
    { "56 Частичное отсутствие зубов", 56 }, ;
    { "57 Полное отсутствие зубов", 57 }, ;
    { "58 Болезни пародонта", 58 }, ;
    { "59 Аномалии и деформации", 59 }, ;
    { "60 Сложно-челюстно-лицевая патология", 60 };
    }

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_OPEN ] := {|| f1_orto_diag(,, "open" ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t. }
  t_arr[ BR_COLUMN ] := { { " Шифр", {|| dbf1->shifr } }, ;
    { Center( "Наименование", 40 ), {|| PadR( dbf1->name, 40 ) } }, ;
    { PadR( "Колонка формы 39", 20 ), {|| PadR( inieditspr( A__MENUVERT, mm_col_f39, dbf1->col_f39 ), 20 ) } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_orto_diag( nk, ob, "edit" ) }
  edit_browse( t_arr )
  Return Nil

//
Function f1_orto_diag( nKey, oBrow, regim, lrec )

  Local ret := -1
  Local buf, fl := .f., k := 17, tmp_color

  Do Case
  Case regim == "open"
    g_use( dir_server() + "diag_ort", dir_server() + "diag_ort", "DBF1" )
    Go Top
    If ( ret := !Eof() ) .and. lrec != Nil .and. lrec > 0
      Goto ( lrec )
    Endif
  Case regim == "choice" .and. nKey == K_SPACE
    ret := 1
  Case regim == "edit"
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( dbf1->name ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/N" )
      Endif
      Private mshifr, mname, mcol_f39, m1col_f39, gl_area := { 1, 0, 23, 79, 0 }
      mshifr := if( nKey == K_INS, Space( 6 ), dbf1->shifr )
      mname := if( nKey == K_INS, Space( 40 ), dbf1->name )
      m1col_f39 := if( nKey == K_INS, 0, dbf1->col_f39 )
      tmp_color := SetColor( cDataCScr )
      mcol_f39 := inieditspr( A__MENUVERT, mm_col_f39, m1col_f39 )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Шифр" Get mshifr ;
        valid {| g| f2_orto_diag( g, nKey ) }
      @ k + 2, pc1 + 3 Say "Наименование" Get mname
      @ k + 3, pc1 + 3 Say "Привязка к форме 39" Get mcol_f39 ;
        reader {| x| menu_reader( x, mm_col_f39, A__MENUVERT,,, .f. ) }
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !emptyany( mshifr, mname ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrecn()
        Else
          g_rlock( forever )
        Endif
        dbf1->shifr   := mshifr
        dbf1->name    := mname
        dbf1->col_f39 := m1col_f39
        dbf1->( dbUnlock() )
        dbCommitAll()   // 19.04
        oBrow:gotop()
        find ( mshifr )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( dbf1->name ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

//
Function f2_orto_diag( get, nKey )

  Local fl := .t., rec := 0

  If mshifr != get:original
    rec := RecNo()
    find ( mshifr )
    If Found()
      fl := func_error( 4, "Данный шифр уже присутствует в справочнике!" )
    Endif
    Goto ( rec )
    If !fl
      mshifr := get:original
    Endif
  Endif
  Return fl

//
Function f_prich_pol()

  popup_edit( dir_server() + "ort_brk", T_ROW, T_COL - 10, T_ROW + 11,, 1,, ;
    "fdel_prich",,,,,, "Причины поломок протезов", col_tit_popup )
  Return Nil

// 13.11.18
Function fdel_prich( mkod )

  Local fl := .t., buf := save_row( MaxRow() )

  stat_msg( "Ждите! Производится проверка на допустимость удаления данной причины" )
  r_use( dir_server() + "hum_ort",, "HU" )
  Locate For hu->PRICH_POL == mkod progress
  fl := !Found()
  HU->( dbCloseArea() )
  If !fl
    func_error( 4, "Данная причина поломок встречается в других базах данных. Удаление запрещено!" )
  Endif
  rest_box( buf )
  Return fl

//
Function edit_ort( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, buf

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Согласование ~услуг", ;
      "Приведенные расходуемые ~материалы", ;
      "~Нормы расхода на каждую укрупненную услугу", ;
      "Печать норм расходов-1", ;
      "Печать норм расходов-2";
      }
    mas_fun := { "edit_ort(12)", ;
      "edit_ort(13)", ;
      "edit_ort(14)", ;
      "edit_ort(15)", ;
      "edit_ort(16)" }
    If glob_mo[ _MO_KOD_TFOMS ] == '395301' // Камышин СТОМ
      popup_prompt( T_ROW, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
    Else
      popup_prompt( T_ROW, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun )
    Endif
  Case k == 12
    sin_ysl()
  Case k == 13
    spr_ort_mat()
  Case k == 14
    spr_t_orto()
  Case k == 15
    oo_spmater()
  Case k == 16
    oo1spmater()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif
  Return Nil

//
Function spr_t_orto()

  Static mas_edit := { "~Просмотр", ;
    "~Редактирование", ;
    "~Добавление", ;
    "~Удаление" }
  Local i := 1, k, buf := SaveScreen()

  T_ROW := T_ROW -5
  Do While i > 0
    // добавление
    If ( i := popup_prompt( T_ROW, T_COL - 5, i, mas_edit,,,, .f. ) ) == A__APPEND
      dop_or_menu( A__APPEND )
    Elseif equalany( i, 1, 2 ) .and. ( k := input_t_orto( T_ROW + i + 1, T_COL - 10 ) ) != NIL
      dop_or_menu( i, k[ 1 ] )
    Elseif i != 0 .and. ( k := input_t_orto( T_ROW + i + 1, T_COL - 10 ) ) != NIL
      mt_use_base( 'tip_orto' )
      If fdel_t_orto( k[ 1 ] ) .and. f_esc_enter( 2 )
        mt_use_base( 'ortoped1' )
        Index On Str( kod_menu, 4 ) to ( cur_dir() + "tmp1" )
        find ( Str( k[ 1 ], 4 ) )
        Do While k[ 1 ] == kod_menu .and. !Eof()
          g_rlock( forever )
          Delete
          Unlock
          Skip
        Enddo
        Select TIP_ORTO
        Goto k[ 1 ]
        deleterec()
      Endif
      Close databases
    Endif
  Enddo
  RestScreen( buf )
  Return Nil

//  13.11.18
Function dop_or_menu( tip, kod )

  Local mm_tmp := {}, buf, len_orto := 0, mas_pit := {}
  Local mm_tehnik := { { "ТЕХНИКОВ", 0 }, ;
    { "ВРАЧЕЙ", 1 } }

  Default kod To 0
  buf := save_row( MaxRow() ) ; mywait()
  Close databases
  Delete file tmp.dbf
  AAdd( mm_tmp, { "name", "C", 40, 0, NIL, NIL, ;
    Space( 80 ), NIL, "Наименование услуги" } )
  AAdd( mm_tmp, { "tip", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_tehnik, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_tehnik, x ) }, ;
    'Нормы расхода предназначены для ' } )
  AAdd( mm_tmp, { "e_1", "C", 1, 0, NIL, ;
    NIL, ;
    " ", NIL, ;
    " ",, ;
    {|| .f. } } )
  AAdd( mm_tmp, { "e_2", "C", 1, 0, NIL, ;
    NIL, ;
    " ", NIL, ;
    "Нормы расхода материалов на одну услугу.",, ;
    {|| .f. } } )
  mt_use_base( 'ortoped' )
  Index On name to ( cur_dir() + "tmp2" )
  Go Top
  lOldDeleted := Set( _SET_DELETED, .f. )
  Do While !Eof()
    AAdd( mm_tmp, { "v_" + lstr( RecNo() ), "N", 7, 3, NIL, ;
      NIL, ;
      0, NIL, ;
      PadR( name, 65 ),, } )
    ++len_orto
    AAdd( mas_pit, RecNo() )
    Skip
  Enddo
  Set( _SET_DELETED, lOldDeleted )
  init_base( cur_dir() + "tmp",, mm_tmp, 0 )
  Use ( cur_dir() + "tmp" ) new
  If tip != A__APPEND
    Append Blank
    mt_r_use_base( 'tip_orto' )
    mt_r_use_base( 'ortoped1' )
    Index On Str( kod_menu, 4 ) + Str( kod_ort, 4 ) to ( cur_dir() + "tmp1" )
    Select TIP_ORTO
    Goto kod
    // G_RLock(forever)
    tmp->name := tip_orto->name
    tmp->tip  := tip_orto->tip
    // UnLock
    Select ORTOPED1
    For i := 1 To len_orto
      find ( Str( kod, 4 ) + Str( mas_pit[ i ], 4 ) )
      s := "tmp->v_" + lstr( mas_pit[ i ] )
      g_rlock( forever )
      &s := ortoped1->massa
      Unlock
    Next
  Endif
  Close databases
  If f_edit_spr( tip, mm_tmp, "настройке программы", "g_use(cur_dir()+'tmp',,,.t.,.t.)", 0, 1 ) > 0
    mt_r_use_base( 'ortoped' )
    mt_use_base( 'ortoped1' )
    Index On Str( kod_menu, 4 ) + Str( kod_ort, 4 ) to ( cur_dir() + "tmp1" )
    mt_use_base( 'tip_orto' )
    Use ( cur_dir() + "tmp" ) new
    Select TIP_ORTO
    If tip == 3
      addrecn()
      kod := RecNo()
    Else
      Goto kod
    Endif
    g_rlock( forever )
    tip_orto->name := tmp->name
    tip_orto->tip := tmp->tip
    Unlock
    Select ORTOPED1
    For i := 1 To len_orto
      find ( Str( kod, 4 ) + Str( mas_pit[ i ], 4 ) )
      If !Found()
        Append Blank
      Endif
      g_rlock( forever )
      s := "tmp->v_" + lstr( mas_pit[ i ] )
      ortoped1->massa := &s
      ortoped1->kod_ort := mas_pit[ i ]
      ortoped1->kod_menu := tip_orto->( RecNo() )
      Unlock
    Next
  Endif
  Close databases
  rest_box( buf )
  Return Nil

//
Function fdel_t_orto( k )

  Local fl := .t., buf := save_row( MaxRow() )

  Return fl

// 13.11.18
Function input_t_orto( r, c, mkod, top_bot )

  Static st := 0
  Local k, r1, r2, tmp_select

  Default mkod To st, top_bot To .t.  // т.е. привязка сверху
  If top_bot
    r1 := r ; r2 := MaxRow() -2
  Else
    r2 := r - 1 ; r1 := r2 - 8
  Endif
  If ( k := popup_edit( dir_server() + "tip_orto", r1, c, r2, ;
      mkod, 4,,,,,,, top_bot, "Услуги", "B/BG" ) ) != NIL
    st := k[ 1 ]
    If !top_bot .and. st != mkod
      tmp_select := Select()
      // G_Use(dir_server()+"tip_orto",,"ORT")
      // goto (st)
      // ort->(dbCloseArea())
      If tmp_select > 0
        Select ( tmp_select )
      Endif
      Keyboard Chr( K_ENTER )
    Endif
  Endif
  Return k

// 16.08.21
Function spr_ort_mat()

  Local t_arr[ BR_LEN ], mtitle := "Редактирование справочника материалов ОРТОПЕДИЯ"

  Private mm_orto_mat := { ;
    { "Нет привязки", 0 }, ;
    { "Бухгалтерия", 1 }, ;
    { "Руководство", 2 };
    }
  Private mm_orto_vash := { ;
    { "Нет", 0 }, ;
    { "Да",1 };
    }

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 75
  t_arr[ BR_OPEN ] := {|| f1_orto_mat(,, "open" ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t. }
  t_arr[ BR_COLUMN ] := { { Center( "Наименование материала", 40 ), {|| PadR( dbf1->name, 40 ) } }, ;
    { PadR( "  Документ", 12 ), {|| PadR( inieditspr( A__MENUVERT, mm_orto_mat, dbf1->kod ), 12 ) } }, ;
    { PadR( "  Важность", 12 ), {|| PadR( inieditspr( A__MENUVERT, mm_orto_vash, dbf1->kod1 ), 12 ) } } ;
    }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_orto_mat( nk, ob, "edit" ) }
  edit_browse( t_arr )
  Return Nil

// 16.11.16
Function f1_orto_mat( nKey, oBrow, regim, lrec )

  Local ret := -1
  Local buf, fl := .f., k := 16, tmp_color

  Do Case
  Case regim == "open"
    g_use( dir_server() + "ortoped",, "DBF1" )
    Index On Upper( name ) To tmp
    Go Top
    If ( ret := !Eof() ) .and. lrec != Nil .and. lrec > 0
      Goto ( lrec )
    Endif
  Case regim == "choice" .and. nKey == K_SPACE
    ret := 1
  Case regim == "edit"
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( dbf1->name ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/N" )
      Endif
      Private mshifr, mname, mcol_f39, m1col_f39, gl_area := { 1, 0, 23, 79, 0 }, ;
        m1vah_mat, mvah_mat
      mname := if( nKey == K_INS, Space( 80 ), dbf1->name )
      m1col_mat := if( nKey == K_INS, 0, dbf1->kod )
      m1vah_mat := if( nKey == K_INS, 0, dbf1->kod1 )
      tmp_color := SetColor( cDataCScr )
      mcol_mat := inieditspr( A__MENUVERT, mm_orto_mat, m1col_mat )
      mvah_mat := inieditspr( A__MENUVERT, mm_orto_vash, m1vah_mat )
      box_shadow( k, pc1 + 1, 20, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Наименование" Get mname Pict "@S40"
      @ k + 2, pc1 + 3 Say "Отношение к отчёту" Get mcol_mat ;
        reader {| x| menu_reader( x, mm_orto_mat, A__MENUVERT,,, .f. ) }
      @ k + 3, pc1 + 3 Say "Важный материал" Get mvah_mat ;
        reader {| x| menu_reader( x, mm_orto_vash, A__MENUVERT,,, .f. ) }
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !emptyany( mname ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrecn()
        Else
          g_rlock( forever )
        Endif
        dbf1->name := mname
        dbf1->kod  := m1col_mat
        dbf1->kod1  := m1vah_mat
        dbf1->( dbUnlock() )
        dbCommitAll()   // 19.04
        oBrow:gotop()
        find ( Upper( mname ) )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL
      func_error( 4, "Удаление запрещено!" )
      ret := 0
    Endcase
  Endcase
  Return ret

//
Function f_orto_uva()

  Local t_arr[ BR_LEN ], mtitle := "Услуги, где не вводится врач (техник/медсестра)"

  t_arr[ BR_TOP ] := T_ROW
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := T_COL - 20
  t_arr[ BR_RIGHT ] := t_arr[ BR_LEFT ] + 52
  t_arr[ BR_OPEN ] := {|| f1_orto_uva(,, "open" ) }
  t_arr[ BR_CLOSE ] := {|| dbCloseAll() }
  t_arr[ BR_SEMAPHORE ] := mtitle
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := mtitle
  t_arr[ BR_TITUL_COLOR ] := "B/BG"
  t_arr[ BR_ARR_BROWSE ] := {,,,, .t. }
  t_arr[ BR_COLUMN ] := { { "   Шифр", {|| dbf1->shifr } }, ;
    { "Врача нет?",   {|| PadC( if( dbf1->kod_vr == 1, "**", "" ), 10 ) } }, ;
    { "Техника нет?", {|| PadC( if( dbf1->kod_as == 1, "**", "" ), 12 ) } }, ;
    { "М/с нет?",     {|| PadC( if( dbf1->kod_ms == 1, "**", "" ), 8 )  } } }
  t_arr[ BR_EDIT ] := {| nk, ob| f1_orto_uva( nk, ob, "edit" ) }
  edit_browse( t_arr )
  Return Nil

//
Function f1_orto_uva( nKey, oBrow, regim, lrec )

  Local ret := -1, mm_da_net := { { "да ", 0 }, { "НЕТ", 1 } }
  Local buf, fl := .f., k := 16, tmp_color

  Do Case
  Case regim == "open"
    g_use( dir_server() + "orto_uva", dir_server() + "orto_uva", "DBF1" )
    Go Top
    If ( ret := !Eof() ) .and. lrec != Nil .and. lrec > 0
      Goto ( lrec )
    Endif
  Case regim == "edit"
    Do Case
    Case nKey == K_INS .or. ( nKey == K_ENTER .and. !Empty( dbf1->shifr ) )
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, "N/N", "W+/N" )
      Endif
      Private gl_area := { 1, 0, 23, 79, 0 }, ;
        mshifr := if( nKey == K_INS, Space( 10 ), dbf1->shifr ), ;
        mkod_vr, m1kod_vr := if( nKey == K_INS, 0, dbf1->kod_vr ), ;
        mkod_as, m1kod_as := if( nKey == K_INS, 0, dbf1->kod_as ), ;
        mkod_ms, m1kod_ms := if( nKey == K_INS, 0, dbf1->kod_ms )
      tmp_color := SetColor( cDataCScr )
      mkod_vr := inieditspr( A__MENUVERT, mm_da_net, m1kod_vr )
      mkod_as := inieditspr( A__MENUVERT, mm_da_net, m1kod_as )
      mkod_ms := inieditspr( A__MENUVERT, mm_da_net, m1kod_ms )
      box_shadow( k, pc1 + 1, 21, pc2 - 1,, ;
        if( nKey == K_INS, "Добавление", "Редактирование" ), ;
        cDataPgDn )
      SetColor( cDataCGet )
      @ k + 1, pc1 + 3 Say "Шифр услуги (шаблон)" Get mshifr ;
        valid {| g| f2_orto_diag( g, nKey ) }
      @ k + 2, pc1 + 3 Say "Вводится код врача?" Get mkod_vr ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ k + 3, pc1 + 3 Say "Вводится код техника?" Get mkod_as ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      @ k + 4, pc1 + 3 Say "Вводится код медсестры?" Get mkod_ms ;
        reader {| x| menu_reader( x, mm_da_net, A__MENUVERT,,, .f. ) }
      status_key( "^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода" )
      myread()
      If LastKey() != K_ESC .and. !Empty( mshifr ) ;
          .and. !emptyall( m1kod_vr, m1kod_as, m1kod_ms ) .and. f_esc_enter( 1 )
        If nKey == K_INS
          fl_found := .t.
          addrecn()
        Else
          g_rlock( forever )
        Endif
        dbf1->shifr  := mshifr
        dbf1->kod_vr := m1kod_vr
        dbf1->kod_as := m1kod_as
        dbf1->kod_ms := m1kod_ms
        dbf1->( dbUnlock() )
        dbCommitAll()   // 19.04
        oBrow:gotop()
        find ( mshifr )
        ret := 0
      Elseif nKey == K_INS .and. !fl_found
        ret := 1
      Endif
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL .and. !Empty( dbf1->shifr ) .and. f_esc_enter( 2 )
      deleterec()
      oBrow:gotop()
      ret := 0
      If Eof()
        ret := 1
      Endif
    Endcase
  Endcase
  Return ret

// 13.11.18 Причины поломок протезов
Function o_pr_polom()

  Local buf := save_row( MaxRow() ), sh, HH := 58, skol, arr, arr_title, ;
    begin_date, end_date, name_file := cur_dir() + "orto_pp.txt"

  arr_title := { ;
    "────────────────────────────────────────┬──────────────", ;
    "      Причины поломок протезов          │  Количество  ", ;
    "────────────────────────────────────────┴──────────────" }
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      3,      0 }, ;  // код поломки
  { "KOL",        "N",     10,      0 };   // кол-во услуг
  } )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 3 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Select HUMAN
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    If human->PRICH_POL > 0
      Select TMP
      find ( Str( human->PRICH_POL, 3 ) )
      If !Found()
        Append Blank
        tmp->kod := human->PRICH_POL
      Endif
      tmp->kol++
    Endif
    Select HUMAN
    Skip
  Enddo
  If tmp->( LastRec() ) == 0
    func_error( 4, "Нет информации" )
  Else
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    sh := Len( arr_title[ 1 ] )
    add_string( "" )
    add_string( Center( "Причины поломок протезов", sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( Center( "[ по дате окончания лечения ]", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + "ort_brk",, "PP" )
    Select TMP
    Set Relation To kod into PP
    Index On Upper( pp->name ) to ( cur_dir() + "tmp" )
    skol := 0
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( PadR( pp->name, 40 ) + Str( tmp->kol, 10 ) )
      skol += tmp->kol
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    add_string( Space( 40 ) + Str( skol, 10 ) )
    Close databases
    FClose( fp )
    viewtext( name_file )
  Endif
  Close databases
  rest_box( buf )
  Return Nil

// 05.09.18
// Список больных по поломкам
Function o_sb_pr_polom()

  Static sk
  Local buf := save_row( MaxRow() ), sh, HH := 58, skol, arr, arr_title, ;
    k, begin_date, end_date, name_file := "orto_pps.txt"

  arr_title := { ;
    "──────────────────────────────────────────────────┬──────────────┬─────", ;
    "                                                  │  Наряд-заказ │Таб.№", ;
    "      Ф.И.О. больного                             ├─────┬────────┤врача", ;
    "                                                  │  №  │  дата  │     ", ;
    "──────────────────────────────────────────────────┴─────┴────────┴─────" }
  If ( k := popup_edit( dir_server() + "ort_brk", ;
      T_ROW, T_COL - 5, MaxRow() -2, sk, PE_RETURN,,,,,,,, ;
      "Причины поломок протезов", col_tit_popup ) ) == NIL
    Return Nil
  Endif
  sk := k[ 1 ]
  If ( arr := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  begin_date := arr[ 5 ]
  end_date := arr[ 6 ]
  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      7,      0 };  // код наряда
  } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "hum_ort", dir_server() + "hum_ortd", "HUMAN" )
  Select HUMAN
  dbSeek( DToS( begin_date ), .t. )
  Do While human->k_data <= end_date .and. !Eof()
    If human->PRICH_POL == k[ 1 ]
      Select TMP
      Append Blank
      tmp->kod := human->( RecNo() )
    Endif
    Select HUMAN
    Skip
  Enddo
  If tmp->( LastRec() ) == 0
    func_error( 4, "Нет информации" )
  Else
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    sh := Len( arr_title[ 1 ] )
    add_string( "" )
    add_string( Center( "Список больных по поломке", sh ) )
    add_string( Center( '"' + AllTrim( k[ 2 ] ) + '"', sh ) )
    add_string( Center( arr[ 4 ], sh ) )
    add_string( Center( "[ по дате окончания лечения ]", sh ) )
    add_string( "" )
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + "mo_pers",, "PERSO" )
    r_use( dir_server() + "kartotek",, "KART" )
    Select HUMAN
    Set Order To 0
    Set Relation To kod_k into KART
    Select TMP
    Set Relation To kod into HUMAN
    Index On Upper( kart->fio ) + Str( human->nar_z, 5 ) to ( cur_dir() + "tmp" )
    skol := 0
    Go Top
    Do While !Eof()
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( PadR( kart->fio, 50 ) + Str( human->nar_z, 6 ) + ;
        " " + date_8( human->data ) + put_val( ret_tabn( human->kod_vr ), 6 ) )
      skol++
      Select TMP
      Skip
    Enddo
    add_string( Replicate( "─", sh ) )
    add_string( Center( "Итого нарядов: " + lstr( skol ), sh ) )
    Close databases
    FClose( fp )
    viewtext( name_file,,,, ( sh > 80 ),,, 2 )
  Endif
  Close databases
  rest_box( buf )
  Return Nil

// 10.03.19
Function opl_kart( mkod_human, mkod_lpu )

  // mkod_human - код по БД human
  Local buf := SaveScreen(), j := 0, tmp_color := SetColor( color1 ), ;
    l_color, mtitle, i, k
  mywait()
  use_base( "hum_ort" )
  Set Order To 0
  Goto ( mkod_human )
  //
  Private fl_found, str_find, muslovie, mvu[ 3, 2 ], mcena_opl := 0, flag_1 := .t.
  afillall( mvu, 0 )
  str_find := Str( human->( RecNo() ), 7 )
  muslovie := "ho->kod == human->(recno())"
  arr_blk := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  r_use( dir_server() + "mo_pers",, "PERSO" )
  SetColor( "BG/B" )
  l_color := "W+/B,W+/W,BG+/B,W+/BG,G+/B,W+/G,GR+/B,W+/GR"
  use_base( "hum_oro" )
  find ( str_find )
  If ( fl_found := Found() )
    dbEval( {|| mcena_opl += ho->cena_opl },, {|| ho->kod == human->( RecNo() ) } )
    find ( str_find )
    Keyboard Chr( K_RIGHT )
  Else
    Keyboard Chr( K_INS )
  Endif
  SetColor( color1 )
  cls
  @ 0, 0 Say PadC( "Оплата ортопед.услуг для < " + AllTrim( glob_k_fio ) + " >", 80 ) Color "W+/BG"
  @ 1, 1 Say "Наряд-заказ № " + lstr( human->nar_z ) + " от " + date_8( human->data ) + "г." Color "G+/B"
  mtitle := f_srok_lech( human->n_data, human->k_data )
  alpha_browse( 2, 0, MaxRow() -2, 79, "fe_o_kopl", color1, mtitle, col_tit_popup, ;
    .f., .t., arr_blk, "f1e_o_kopl", "f2e_o_kopl",, ;
    { '═', '░', '═', l_color, .t., 180 } )
  // были добавлены строки оплаты
  If yes_parol .and. ( mvu[ 1, 1 ] > 0 .or. mvu[ 2, 1 ] > 0 .or. mvu[ 3, 1 ] > 0 )
    // ;              .and. hb_FileExists(dir_server()+"mo_opern"+sdbf())
    k := glob_task + iif( human->tip_usl == OU_B_PLAT, 100, 0 )
    Close databases
    If g_use( dir_server() + "mo_opern", dir_server() + "mo_opern", "OP" )
      For i := 1 To 3
        If mvu[ i, 1 ] > 0
          write_work_oper( k, OPER_USL, i, mvu[ i, 1 ], mvu[ i, 2 ], .f. )
        Endif
      Next
    Endif
  Endif
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  Return mcena_opl

// 25.10.25
Function fe_o_kopl( oBrow )

  Local oColumn, blk_color
  Local tip_bank := { " бн ", "МИР", "VISA", "MаCа", "БАНК", "СБП" }

  blk_color := {|| { { 1, 2 }, { 3, 4 }, { 5, 6 }, { 7, 8 } }[ ho->tip_usl + 1 ] }
  If glob_kassa == 1
    oColumn := TBColumnNew( "     ", {|| iif( ho->sbank < 1, "    ", ;
      tip_bank[ ho->fr_tipkart + 1 ] + iif( ho->sbank == ho->cena_opl, " ", "Н" ) ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
    oColumn := TBColumnNew( "    ", {|| { "    ", Str( ho->kv_cia, 4 ), " " };
      [ho->is_kas+1] } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Else
    oColumn := TBColumnNew( "№ кв.;книжки", {|| put_val( ho->n_kvit, 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
    //
    oColumn := TBColumnNew( "№ кви-;танции", {|| put_val( ho->kv_cia, 6 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  //
  oColumn := TBColumnNew( "  Дата; оплаты", {|| date_8( c4tod( ho->pdate ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Сумма; оплаты", {|| put_kop( ho->cena_opl, 9 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " ", {|| { "П", " ", "з", "Д" }[ ho->tip_usl + 1 ] } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "  Вид;платеж", {|| { " аванс ", "ОПЛАТА ", "напыл-е", "." }[ ho->tip_opl + 1 ] } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Регистратор", {|| f0e_o_kopl( ho->kod_reg ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Примечание", {|| ho->prim } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If glob_kassa == 1
    oColumn := TBColumnNew( " Сумма;возврата", {|| put_kop( ho->sum_voz, 9 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  //
  If glob_kassa == 1
    status_key( "^<Esc>^-выход; ^<Enter>^-ред-ие; ^<Ins>^-добавление; ^<Del>^-удаление; ^<F10>^-печать чека" )
  Else
    status_key( "^<Esc>^ - выход; ^<Enter>^ - ред-ие; ^<Ins>^ - добавление; ^<Del>^ - удаление" )
  Endif
  Return Nil

//
Function f0e_o_kopl( reg )

  Local ret := "", t_order

  If reg > 0
    t_order := Select()
    r_use( dir_server() + "base1",, "BASE1" )
    Goto ( reg )
    If !Eof() .and. !Empty( base1->p1 )
      ret := AllTrim( Crypt( base1->p1, gpasskod ) )
    Endif
    base1->( dbCloseArea() )
    Select( t_order )
  Endif
  Return PadR( ret, 12 )

//
Function f1e_o_kopl()

  Local nRow := Row(), nCol := Col()

  If flag_1
    f3e_o_kopl()
    flag_1 := .f.
  Endif
  @ nRow, nCol Say ""
  Return Nil

//
Function f3e_o_kopl()

  @ 23, 2 Say PadL( "Итого: " + lstr( mcena_opl, 11, 2 ), 20 ) Color "W+/N"
  Return Nil

// 25.12.25
Function f2e_o_kopl( nKey, oBrow )

  Static skod_vr := 0, sn_kvit := 0
  Local flag := -1, buf := SaveScreen(), fl := .f., rec, ;
    i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := SetColor(), ;
    mrec_ho := ho->( RecNo() ), tmp_help := help_code, ln_chek := 0, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    mi_post, mphone_m, maddress, tip_kart := 2, tip_oplatFR := 4, ;
    fr_zavodnomer := "", ;
    menu_opl := { { "аванс               ", 0 }, ;
    { "окончательная оплата", 1 }, ;
    { "напыление           ", 2 } }
  Local menu_opl_chek := { { "аванс за ортопедические услуги по ", 0 }, ;
    { "окончательная оплата за ортопедические услуги по ", 1 }, ;
    { "за напыление по ", 2 } }
  Local err_close := "Данный лист учета ЗАКРЫТ. Доступ разрешен только администратору системы!"
  Local t_hum_rec, kart_kod, hum_o_kod, t_select

  //
  Private r1 := 13
  Private ldate_voz, lsum_voz, lfr_data, lfr_time
  If equalany( nKey, K_INS, K_ENTER, K_DEL )
    If !ver_pub_date( human->k_data, .t. )
      Return flag
    Endif
  Endif
  // 00.07.17 поиск номера или эл.почты
  t_hum_rec := ho->( RecNo() )
  kart_kod  := human->kod_k
  hum_o_kod := human->( RecNo() )
  mi_post   := Space( 30 )
  mphone_m  := Space( 11 )
  t_select := Select()
  Select HO
  Do While ho->kod == hum_o_kod  .and. !Eof()
    If Len( AllTrim( ho->i_post ) ) > 4
      mi_post := ho->i_post
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
  Select( t_select )
  //
  Do Case
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. ho->kod > 0 )
    If nKey == K_INS .and. !fl_found
      ColorWin( 6, 0, 6, 79, "B/B", "W+/W" )
      ColorWin( 6, 0, 6, 79, "B/B", "W+/BG" )
      ColorWin( 6, 0, 6, 79, "B/B", "W+/G" )
      ColorWin( 6, 0, 6, 79, "B/B", "W+/GR" )
    Endif
    Private mtip_opl, m1tip_opl := if( nKey == K_INS, 0, ho->tip_opl ), ;
      mtip_usl, m1tip_usl := if( nKey == K_INS, human->tip_usl, ho->tip_usl ), ;
      mpr_smo, m1pr_smo := if( nKey == K_INS, human->pr_smo, ho->pr_smo ), ;
      mpolis := if( nKey == K_INS, Space( 25 ), ho->d_polis ), ;
      mGP_NOMER := if( nKey == K_INS, Space( 16 ), ho->GP_NOMER ), ;
      mGP_DATE := if( nKey == K_INS, CToD( "" ), ho->GP_DATE ), ;
      mn_kvit := if( nKey == K_INS, sn_kvit, ho->n_kvit ), ;
      mkv_cia := if( nKey == K_INS, 0, ho->kv_cia ), ;
      mdate_o := if( nKey == K_INS, sys_date, c4tod( ho->pdate ) ), ;
      mkod_vr := if( nKey == K_INS, skod_vr, ho->kod_reg ), ;
      mtabn_vr := 0, mvrach := Space( 35 ), ;
      mkod_as := 0, mkod_ms := 0, ;
      mstoim := if( nKey == K_INS, 0, ho->cena_opl ), ;
      mprim := if( nKey == K_INS, Space( 15 ), ho->prim ), ;
      mplat_fio := if( nKey == K_INS, Space( 40 ), human->plat_fio ), ;
      mplat_inn := if( nKey == K_INS, Space( 12 ), human->plat_inn ), ;
      mplat_adres  := Space( 50 ), ; // адрес плательщика
    mplat_pasport :=  Space( 15 ), ;  // документ плательщика
    gl_area := { 1, 0, 23, 79, 0 }
    mtip_opl := inieditspr( A__MENUVERT, menu_opl, m1tip_opl )
    mtip_usl := inieditspr( A__MENUVERT, menu_okb, m1tip_usl )
    If m1tip_usl == OU_D_SMO
      mpr_smo := inieditspr( A__POPUPMENU, dir_server() + "p_d_smo", m1pr_smo )
    Elseif m1tip_usl == OU_PR_VZ
      mpr_smo := inieditspr( A__POPUPMENU, dir_server() + "p_pr_vz", m1pr_smo )
    Endif
    If mkod_vr > 0
      Select PERSO
      Goto ( mkod_vr )
      mvrach := PadR( perso->fio, 35 )
      mtabn_vr := perso->tab_nom
    Endif
    // 19.04
    If glob_kassa == 1
      //
    Else
      If mem_ort_ysl == 1
        r1 += 1
      Endif
      r1 += 1
    Endif
    //
    box_shadow( r1, 0, 23, 79, color8, ;
      iif( nKey == K_INS, "Добавление", "Редактирование" ) + ;
      " строки оплаты ортопедической услуги", "RB+/B" )
    Do While .t.
      SetColor( cDataCGet )
      @ r1 + 2, 2 Say "Категория больного" Get mtip_usl ;
        reader {| x| menu_reader( x, menu_okb, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| val_tip_usl( g, o, r1 + 2 ) }
      @ r1 + 2, 37 Say Space( 11 ) Get mpr_smo When m1tip_opl != OU_PLAT
      @ r1 + 3, 37 Say Space( 11 ) Get mpolis Picture "@!" When m1tip_opl != OU_PLAT
      val_tip_usl(, m1tip_usl, r1 + 2 )
      @ r1 + 4, 2 Say "Вид платежа" Get mtip_opl ;
        reader {| x| menu_reader( x, menu_opl, A__MENUVERT,,, .f. ) }
      @ r1 + 5, 2 Say "Дата оплаты" Get mdate_o
      @ r1 + 6, 2 Say "Сумма оплаты" Get mstoim Pict pict_cena()
      ii := 7
      If glob_kassa == 1
        //
      Else
        If mem_ort_ysl == 1
          @ r1 + ii, 2 Say "Номер квитанционной книжки" Get mn_kvit Pict "99999"
          ++ii
        Endif
        @ r1 + ii, 2 Say "Номер квитанции" Get mkv_cia Pict "999999"
        ++ii
      Endif
      If mem_ort_ysl == 1
        @ r1 + ii, 2 Say "Таб.№ регистратора" Get mtabn_vr Pict "99999" ;
          valid {| g| f0e_o_kopl( g ) }
      Endif
      @ r1 + ii, 28 Get mvrach When .f. Color color14
      // ++ii
      @ r1 + ii, 2 Say "Примечание" Get mprim
      status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи" )
      count_edit := myread(, @pos_read, ++k_read )
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      If LastKey() != K_ESC
        If emptyany( mdate_o, mstoim )
          func_error( 4, "Введены не все данные!" )
          Loop
        Else
          err_date_diap( mdate_o, "Дата оплаты" )
          mywait()
          Select HO
          If nKey == K_INS
            add1rec( 7 )
            ho->kod := human->( RecNo() )
            ho->cena_opl := 0 // на всякий случай обнуляем сумму оплату
            mrec_ho := ho->( RecNo() )
            If glob_kassa == 1
              ho->is_kas := 2
            Endif
            fl_found := .t.
            ++mvu[1,1 ]  // услуга добавлена оператором
            mvu[ 1, 2 ] += count_edit
          Else
            Goto ( mrec_ho )
            g_rlock( forever )
            ++mvu[2,1 ]  // услуга отредактирована оператором
            mvu[ 2, 2 ] += count_edit
          Endif
          Select HO
          If glob_kassa == 1 .and. ho->is_kas == 1 .and. ho->cena_opl > 0
            // стоит ФР и пробит чек
            func_error( 4, "Пробит ЧЕК! Редактирование ЗАПРЕЩЕНО!" )
          Else
            ho->tip_opl  := m1tip_opl
            ho->kod_reg  := mkod_vr
            ho->cena_opl := mstoim
            ho->pdate    := dtoc4( mdate_o )
            ho->n_kvit   := mn_kvit
            ho->kv_cia   := mkv_cia
            ho->prim     := mprim
            ho->tip_usl  := m1tip_usl
            If equalany( m1tip_usl, OU_D_SMO, OU_PR_VZ )
              ho->pr_smo := m1pr_smo
              ho->d_polis := mpolis
            Else
              ho->pr_smo := 0
              ho->d_polis := ""
            Endif
          Endif
          ho->( dbUnlock() ) // 19.04
          mcena_opl := 0
          Select HO
          find ( str_find )
          dbEval( {|| mcena_opl += ho->cena_opl - ho->sum_voz },, {|| ho->kod == human->( RecNo() ) } )
          Select HUMAN
          g_rlock( forever )
          human->cena_opl := mcena_opl
          human->( dbUnlock() )
          dbCommitAll()   // 19.04
          skod_vr := mkod_vr
          sn_kvit := mn_kvit
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found
      flag := 1
    Endif
    RestScreen( buf )
    f3e_o_kopl()
    Select HO
    oBrow:gotop()
    Goto ( mrec_ho )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. ho->kod > 0
    If glob_kassa == 1
      If ho->is_kas == 1 .and. ho->cena_opl > 0 // чек был пробит
        vozvrat_orto()
        mcena_opl := 0
        find ( str_find )
        dbEval( {|| mcena_opl += ho->cena_opl - ho->sum_voz },, {|| ho->kod == human->( RecNo() ) } )
        Select HUMAN
        g_rlock( forever )
        Replace human->cena_opl With mcena_opl
        human->( dbUnlock() )
        dbCommitAll() // 19.04
        flag := 0
        Select HO
        oBrow:gotop()
        find ( str_find )
        If !Found()
          fl_found := .f.
          flag := 1
        Endif
        RestScreen( buf )
      Else // чек не пробит - повторяю обычный кусок
        If f_esc_enter( 2 )
          mywait()
          ++mvu[3,1 ]  // услуга удалена оператором
          Select HO
          deleterec( .t., .f. )  // очистка записи без пометки на удаление
          mcena_opl := 0
          find ( str_find )
          dbEval( {|| mcena_opl += ho->cena_opl - ho->sum_voz },, {|| ho->kod == human->( RecNo() ) } )
          Select HUMAN
          g_rlock( forever )
          Replace human->cena_opl With mcena_opl
          human->( dbUnlock() )
          dbCommitAll() // 19.04
          flag := 0
          Select HO
          oBrow:gotop()
          find ( str_find )
          If !Found()
            fl_found := .f.
            flag := 1
          Endif
          RestScreen( buf )
          f3e_o_kopl()
        Endif
      Endif
    Else
      If f_esc_enter( 2 )
        mywait()
        ++mvu[3,1 ]  // услуга удалена оператором
        Select HO
        deleterec( .t., .f. )  // очистка записи без пометки на удаление
        mcena_opl := 0
        find ( str_find )
        dbEval( {|| mcena_opl += ho->cena_opl - ho->sum_voz },, {|| ho->kod == human->( RecNo() ) } )
        Select HUMAN
        g_rlock( forever )
        Replace human->cena_opl With mcena_opl
        human->( dbUnlock() )
        dbCommitAll() // 19.04
        flag := 0
        Select HO
        oBrow:gotop()
        find ( str_find )
        If !Found()
          fl_found := .f.
          flag := 1
        Endif
        RestScreen( buf )
        f3e_o_kopl()
      Endif
    Endif
  Case nKey == K_F10 .and. glob_kassa == 1 .and. ;
      ho->is_kas == 2 .and. ho->cena_opl > 0
    buf := SaveScreen()
    clrline( 23, color0 )
    adbf := { ;
      { "name", "C", 128, 0 }, ;
      { "vrach", "C", 40, 0 }, ;
      { "cena", "N", 10, 2 }, ;
      { "kol",  "N",  5, 1 }, ;
      { "nds20", "N",  1, 0 }, ; // 10.08.08
      { "nds22", "N",  1, 0 }, ; // 25.12.25
      { "nds18", "N",  1, 0 }, ; // 10.08.08
      { "nds10", "N",  1, 0 } }
    dbCreate( cur_dir() + "tmp", adbf )
    Use ( cur_dir() + "tmp" ) new
    adbf := {}
    Select TMP
    Append Blank
    tmp->name := inieditspr( A__MENUVERT, menu_opl_chek, ho->tip_opl ) + " наряду N " + lstr( human->nar_z )
    tmp->cena := round_5( ho->cena_opl, 2 )
    tmp->kol := round_5( 1, 0 )
    // 10.08.08 - НДС
    If ho->tip_opl == 0
      tip_oplatFR := 3 // аванс
    Else
      tip_oplatFR := 4
    Endif
    Private p_summa := round_5( ho->cena_opl, 2 ), fl_sdacha := .f., ;
      mplat_fio := "", mplat_inn := ""
    If glob_mo[ _MO_KOD_TFOMS ] == '605301' // ЗАО "Стоматолог"
      mplat_fio := if( nKey == K_INS, Space( 40 ), human->plat_fio )
      mplat_inn := if( nKey == K_INS, Space( 12 ), human->plat_inn )
    Endif
    v_summa := v_sdacha := v_bank := 0
    If yes_chek( @v_summa, @v_sdacha, @v_bank,, @maddress, @tip_kart ) .and. ;
        chek_fr( round_5( v_summa, 2 ), v_sdacha, @ln_chek, round_5( v_bank, 2 ), 2, @fr_zavodnomer, maddress, tip_kart, tip_oplatFR )
      Select HO
      g_rlock( forever )
      ho->is_kas  := 1
      ho->kv_cia  := ln_chek
      ho->sbank   := v_bank
      ho->fr_data := lfr_data
      ho->fr_time := lfr_time
      ho->KOD_REG := Asc( kod_polzovat )
      ho->FR_zavod := fr_zavodnomer
      ho->FR_tipkart := tip_kart
      ho->fr_tip     := 2
      ho->i_post     :=  maddress // 00.02.17
      Unlock
      ho->( dbCommit() ) // 16.04.08
      flag := 0
    Endif
    tmp->( dbCloseArea() )
    Select HO
    RestScreen( buf )
  Otherwise
    Keyboard ""
  Endcase
  help_code := tmp_help
  Return flag

// 25.12.25
Function vozvrat_orto()

  Local buf := SaveScreen(), ln_chek, ;
    sum_bank, sum_nal, tip_banka, ;
    menu_opl := { { "аванс               ", 0 }, ;
    { "окончательная оплата", 1 }, ;
    { "напыление           ", 2 } }
  Local menu_opl_chek := { { "аванс за ортопедические услуги по ", 0 }, ;
    { "окончательная оплата за ортопедические услуги по ", 1 }, ;
    { "за напыление по ", 2 } }

  Private  summa_oplat := 0, summa_oplat_bn := 0, p_summa := 0

  If !Empty( human->k_data ) .and. ! currentuser():isadmin()
    func_error( 4, "Пользователь не АДМИНИСТРАТОР, а наряд закрыт !" )
  Elseif ho->sum_voz > 0
    func_error( 4, "По даной оплате уже производился возврат денег!" )
  Else
    //
    summa_oplat := ho->cena_opl
    summa_oplat_bn := ho->sbank
    tip_banka := ho->fr_tipkart
    //
    adbf := { { "name_u", "C", 128, 0 }, ;
      { "vrach",  "C", 40, 0 }, ;
      { "u_cena", "N", 10, 2 }, ;
      { "vz_cena", "N", 10, 3 }, ;
      { "kol1",   "N",  5, 1 }, ;
      { "nds20",  "N",  1, 0 }, ; // 10.08.08
      { "nds22",  "N",  1, 0 }, ; // 25.12.25
      { "nds18",  "N",  1, 0 }, ; // 10.08.08
      { "nds10",  "N",  1, 0 } }
    dbCreate( cur_dir() + "tmp", adbf )
    Use ( cur_dir() + "tmp" ) new
    adbf := {}
    Select TMP
    Append Blank
    tmp->name_u := inieditspr( A__MENUVERT, menu_opl_chek, ho->tip_opl ) + " наряду N " + lstr( human->nar_z )
    tmp->u_cena := round_5( ho->cena_opl, 2 )
    tmp->vz_cena := round_5( ho->cena_opl, 2 )
    tmp->kol1   := round_5( 1, 0 )
    //
    p_summa := summa_oplat

    If f_esc_enter( "возврата", .t. )
      // вначале возвращаем наличку
      If p_summa <= ( summa_oplat - summa_oplat_bn )
        sum_bank  := 0
        tip_banka := 0
        sum_nal   := p_summa
      Else
        sum_nal   := summa_oplat - summa_oplat_bn
        sum_bank  := p_summa - sum_nal
      Endif
      fl := vozvrat_fr( sum_nal, sum_bank, @ln_chek, 2, tip_banka )
      // сам чек
      If fl
        // заносим возврат
        Select HO
        g_rlock( forever )
        ho->date_voz   := lfr_data // dtoc4(ldate_voz)
        ho->sum_voz    := summa_oplat
        ho->VZFR_DATA  := lfr_data
        ho->VZFR_TIME  := lfr_time
        ho->VZKOD_OPER := Asc( kod_polzovat )
        ho->VZFR_zavod := lstr( ln_chek )
        Unlock
        ho->( dbCommit() )
        stat_msg( "Сумма возврата записана!" ) ; mybell( 1, OK )
      Endif
    Endif
    tmp->( dbCloseArea() )
    ho->( dbCommit() )
    RestScreen( buf )
  Endif
  Return Nil

// 12.07.18
Function kart_orto( r )

  Static snar_z := 0
  Local i, j, r2, ln, buf, str_sem, arr_n := {}

  //
  If glob_kassa == 1 .and. mek_kassa == 1
    Private drvFR
    If ( drvFR := win_oleCreateObject( "AddIn.DrvFr" ) ) != NIL
      fr_zamena_otrezka()
    Else
      Return func_error( 4, "Ошибка запуска драйвера КАССЫ" )
    Endif
  Endif
  //
  If ( i := popup_prompt( T_ROW, T_COL + 5, 1, ;
      { "Поиск по ~ФИО (полису)", "Поиск по номеру ~наряда" } ) ) == 0
    Return Nil
  Elseif i == 2
    j := 0
    If ( ln := input_value( 18, 10, 20, 69, color0, ;
        "     Введите номер необходимого наряда-заказа", ;
        snar_z, "99999" ) ) != Nil .and. ln > 0
      snar_z := ln
      dbCreate( cur_dir() + "tmp_kart", { { "kod", "N", 7, 0 }, ;
        { "fio", "C", 50, 0 }, ;
        { "data", "D", 8, 0 }, ;
        { "rec_hum", "N", 7, 0 }, ;
        { "bukva", "C", 1, 0 }, ;
        { "uchast", "N", 2, 0 }, ;
        { "kod_vu", "N", 5, 0 } } )
      Use ( cur_dir() + "tmp_kart" ) Alias TMP
      Index On DToS( data ) to ( cur_dir() + "tmp_kart" ) descending
      //
      r_use( dir_server() + "kartotek",, "KART" )
      r_use( dir_server() + "hum_ort", dir_server() + "hum_ortn", "HUMAN" )
      Set Relation To kod_k into KART
      find ( Str( ln, 5 ) )
      Do While human->nar_z == ln
        Select TMP
        Append Blank
        tmp->kod := kart->kod ; tmp->fio := kart->fio
        tmp->bukva := kart->bukva
        tmp->uchast := kart->uchast
        tmp->kod_vu := kart->kod_vu
        tmp->data := human->data
        tmp->rec_hum := human->( RecNo() )
        //
        Select HUMAN
        Skip
      Enddo
      j := tmp->( LastRec() )
      Close databases
      If j == 0
        func_error( 4, "Наряд N " + lstr( ln ) + " не найден!" )
      Else
        buf := SaveScreen()
        r_use( dir_server() + "kartote2",, "KART2" )
        r_use( dir_server() + "kartote_",, "KART_" )
        r_use( dir_server() + "kartotek",, "KART" )
        Use ( cur_dir() + "tmp_kart" ) index ( cur_dir() + "tmp_kart" ) New Alias TMP
        Set Relation To kod into KART, To kod into KART_, To kod into KART2
        change_attr()
        top_frm := 14
        @ 13, 0 Say PadC( "_Просмотр картотеки_", 80, "░" ) Color "R/BG"
        r2 := iif( T_ROW + j > 9, 11, T_ROW + j + 4 )
        j := 0
        If alpha_browse( T_ROW, 10, r2, 77, "f1_k_orto", color0, ;
            "Наряд N " + lstr( ln ), col_tit_popup, .f., .t.,, ;
            "f2_v_fio",,, { "═", "░", "═",,, 0 } )
          glob_kartotek := tmp->kod
          glob_k_fio := AllTrim( tmp->fio )
          j := 1
        Endif
        Close databases
        RestScreen( buf )
      Endif
    Endif
    If j == 0
      Return Nil
    Endif
  Elseif i == 1 .and. polikl1_kart() <= 0
    Return Nil
  Endif
  str_sem := "ОРТ Редактирование человека " + lstr( glob_kartotek )
  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  buf := SaveScreen()
  Private fl_found, str_find, muslovie, regim := r
  str_find := Str( glob_kartotek, 7 )
  muslovie := "human->kod_k == glob_kartotek"
  use_base( "hum_ort" )
  find ( str_find )
  fl_found := Found()
  arr_blk := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find, -1 ) }, ;
    {| n| skippointer( n, muslovie ) }, ;
    str_find, muslovie;
    }
  If !fl_found ; Keyboard Chr( K_INS ) ; Endif
  mtitle := "Ортопедические услуги: " + glob_k_fio
  If mem_ort_ysl == 2
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, "f2_k_orto", color0, mtitle, "BG+/GR", ;
      .f., .t., arr_blk,, "f3_k_orto",, ;
      { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B,R/BG", .t., 180 } )
  Else
    alpha_browse( T_ROW, 0, MaxRow() -2, 79, "f2_k_orto", color0, mtitle, "BG+/GR", ;
      .f., .t., arr_blk,, "f3_k_orto",, ;
      {,,, "N/BG,W+/N,B/BG,BG+/B,R/BG", .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )
  g_sunlock( str_sem )
  Return Nil

//
Function f1_k_orto( oBrow )

  oBrow:addcolumn( TBColumnNew( "   Дата;  наряда", {|| full_date( tmp->data ) } ) )
  oBrow:addcolumn( TBColumnNew( Center( "Ф.И.О.", 50 ), {|| tmp->fio } ) )
  status_key( "^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор" )
  Return Nil

//
Function f2_k_orto( oBrow )

  // 02.12.2012 Ю
  Local oColumn, blk := {|| if( human->cena > 0, { 1, 2 }, { 3, 4 } ) }
  //
  oColumn := TBColumnNew( "Номер;наряда", {|| human->nar_z } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  // oColumn := TBColumnNew("  Дата; наряда", {|| date_8(human->data) })
  oColumn := TBColumnNew( "  Дата; наряда", {|| full_date( human->data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Начало; лечения", {|| full_date( human->n_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Окончание; лечения", {|| full_date( human->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Стоимость; лечения", {|| put_kop( human->cena, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Сумма;оплаты", {|| put_kop( human->cena_opl, 10 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  If mem_ort_ysl == 2
    oColumn := TBColumnNew( "Сумма;долга", {|| put_kop( human->cena - human->cena_opl, 10 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  //
  oColumn := TBColumnNew( " ", {|| { "П", "б", "з", "Д" }[ human->tip_usl + 1 ] } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  @ 23, 0 Say PadC( "<Esc>-выход <Enter>-редактирование <Ins>-добавление <Del>-удаление <F2>-материал", 80 ) Color "N/W"
  @ 24, 0 Say PadC( "<Ctrl>+<Enter>-ввод услуг <Ctrl>+<O>-ввод оплаты <F9/F10>-печать наряда/договора", 80 ) Color "N/W"
  mark_keys( { "<Esc>", "<Enter>", "<Ins>", "<Del>", "<F2>", "<Ctrl>+<Enter>", "<Ctrl>+<O>", "<F9/F10>" }, "R/W" )
  Return Nil

// 12.05.19
Function f3_k_orto( nKey, oBrow )

  Local j := 0, flag := -1, buf := save_row( MaxRow() ), buf1, fl := .f., rec, mkod, ;
    tmp_color := SetColor(), r, llpu, mkod_as, mn_data, buf2 := save_row( 23 ), ;
    fll := .t.

  Do Case
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. human->kod_k > 0 )
    If nKey == K_INS .and. !fl_found
      r := 6 + regim
      ColorWin( r, 0, r, 79, "N/N", "W+/N" )
      ColorWin( r, 0, r, 79, "N/N", "BG+/B" )
    Endif
    rec := RecNo()
    flag := f_ort_kart( nKey )
  Case nKey == K_F2 // 15.12.13 материал по наряду
    Private mmrec
    mmrec := rec := human->( RecNo() )
    ort_nar_material()
    use_base( "hum_ort" )
    Select HUMAN
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf2 )
    rest_box( buf ) ; flag := 0
  Case nKey == K_F5 // занос техника и даты начала лечения из шапки в услуги
    If f_esc_enter( "занесения техника в услуги" )
      mKOD_AS     := human->kod_as        // код зубного техника
      MN_DATA     := human->N_DATA        // дата начала лечения
      rec := human->( RecNo() )
      use_base( "hum_oru" )
      find ( Str( rec, 7 ) )
      Do While hu->kod == rec .and. !Eof()
        g_rlock( "forever" )
        hu->kod_as := mKOD_AS
        hu->date_u := dtoc4( mn_data )
        Unlock
        Skip
      Enddo
      hu->( dbCloseArea() )
      Select HUMAN
      Goto ( rec )
    Endif
  Case nKey == K_F6 // занос техника и даты начала лечения из шапки в услуги
    If f_esc_enter( "занесения ДАТЫ в услуги" )
      // mKOD_AS     := human->kod_as        // код зубного техника
      MN_DATA     := human->N_DATA        // дата начала лечения
      rec := human->( RecNo() )
      use_base( "hum_oru" )
      find ( Str( rec, 7 ) )
      Do While hu->kod == rec .and. !Eof()
        g_rlock( "forever" )
        hu->date_u := dtoc4( mn_data )
        Unlock
        Skip
      Enddo
      hu->( dbCloseArea() )
      Select HUMAN
      Goto ( rec )
    Endif

  Case nKey == K_F9 .or. nKey == K_F8
    Private mmrec
    mmrec := rec := human->( RecNo() )
    Private mmtip_oplat := { "Аванс за работу", ;
      "Окончательная оплата", ;
      "Напыление" }
    use_base( "hum_oro" )
    Private TIP_NARAD := ( nKey == K_F9 )
    pr_zak_nar( 1 ) // 16.04.08
    Close databases
    use_base( "hum_ort" )
    Select HUMAN
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf ) ; flag := 0
  Case nKey == K_F10 // 16.04.08
    Private mmrec
    mmrec := rec := human->( RecNo() )
    use_base( "hum_oro" )
    @ 23, 0 Say PadC( " ", 80 ) Color "N/W"
    pr_zak_nar( 2 )
    Close databases
    use_base( "hum_ort" )
    Select HUMAN
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf2 )
    rest_box( buf ) ; flag := 0
  Case nKey == K_DEL .and. ;
      human->kod_k > 0 .and. ver_pub_date( human->k_data, .t. )
    use_base( "hum_oro" )
    Select HO
    find ( Str( human->( RecNo() ), 7 ) )
    If Found()
      fll := .f.
    Endif
    ho->( dbCloseArea() )
    //
    If fll
      If f_esc_enter( 2, .t. )
        mywait()
        j := 0
        use_base( "hum_oru" )
        Do While .t.
          Select HU
          find ( Str( human->( RecNo() ), 7 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
          ++j
        Enddo
        hu->( dbCloseArea() )
        //
        use_base( "hum_oro" )
        Do While .t.
          Select HO
          find ( Str( human->( RecNo() ), 7 ) )
          If !Found() ; exit ; Endif
          deleterec( .t. )
          ++j
        Enddo
        ho->( dbCloseArea() )
        write_work_oper( glob_task + iif( human->tip_usl == OU_B_PLAT, 100, 0 ), ;
          OPER_USL, ;
          3, j )
        write_work_oper( glob_task + iif( human->tip_usl == OU_B_PLAT, 100, 0 ), ;
          OPER_LIST, ;
          3 )
        //
        Select HUMAN
        deleterec()
        oBrow:gotop()
        find ( str_find )
        If !Found()
          fl_found := .f.
        Endif
        stat_msg( "Ортопедический лист учета удален!" ) ; mybell( 1, OK )
        flag := 0
        If !fl_found
          flag := 1
        Endif
        rest_box( buf )
      Endif
    Else
      stat_msg( "Удалите оплату!" ) ; mybell( 1, OK )
    Endif
  Case nKey == K_CTRL_RET .and. human->kod_k > 0 .and. ;
      iif( mem_ort_ysl == 2, .t., !emptyall( human->n_data, human->k_data ) )
    rec := human->( RecNo() ) ; llpu := human->lpu
    Close databases
    usl_ort_kart( rec, llpu )
    use_base( "hum_ort" )
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf ) ; flag := 0
  Case nKey == K_CTRL_O .and. human->kod_k > 0
    rec := human->( RecNo() ) ; llpu := human->lpu
    Close databases
    opl_kart( rec, llpu )
    use_base( "hum_ort" )
    Goto ( rec )
    SetColor( tmp_color )
    rest_box( buf ) ; flag := 0
  Otherwise
    Keyboard ""
  Endcase
  Return flag

//
Function f_ort_kart( nKey )

  Static st_tip_usl := 0
  Local buf := SaveScreen(), tmp_color := SetColor(), str_1, fl, ;
    colget_menu := "R/W", i, k, tmp_help := help_code, s_msg, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    ret := -1, old_doc, old_k_data
  Private r1 := 6

  mywait()
  Private ;
    mNAR_Z      := 0,; // номер наряда-заказа
  mDATA       := sys_date,; // дата наряда-заказа
  MLPU, M1LPU := glob_uch[ 1 ],; // код учреждения
  MOTD, M1OTD := glob_otd[ 1 ],; // код отделения
  mUCH_DOC    := Space( 10 ),; // вид и номер учетного документа
  mKOD_VR     := 0,; // код врача
  mKOD_AS     := 0,; // код зубного техника
  mkod_ms     := 0,;
    mKOD_DIAG   := Space( 6 ),; // шифр болезни
  mKOD_DIAG2  := Space( 6 ),; // шифр болезни
  mKOD_DIAG3  := Space( 6 ),; // шифр болезни
  mKOD_DIAG4  := Space( 6 ),; // шифр болезни
  mKOD_DIAG5  := Space( 6 ),; // шифр болезни
  mKOD_DIAG6  := Space( 6 ),; // шифр болезни
  mKOD_DIAG7  := Space( 6 ),; // шифр болезни
  MN_DATA     := CToD( "" ),; // дата начала лечения
  MK_DATA     := CToD( "" ),; // дата окончания лечения
  mKOL_POS    := 0,; // количество посещений
  mn_och      := Space( 10 ),; // номер очереди (для бесплатных больных)
  MPRICH, M1PRICH := 0,; // причина поломки протеза
  MKOL_MOSTP  := 0,; // количество мостовидных протезов
  MKOL_CELNL  := 0,; // в т.ч. цельнолитых
  mprim       := Space( 15 ),; // примечание
  mtip_usl, m1tip_usl := st_tip_usl, ;
    mpr_smo := Space( 10 ), m1pr_smo := 0, ;
    mtabn_vr := 0, mtabn_as := 0, ;
    mvrach := massist := Space( 35 ), ;
    mcena := 0, mcena_opl := 0, ;
    MKOL_PR1    := 0, ;
    MKOL_PR2    := 0, ;
    MKOL_PR3    := 0, ;
    MKOL_PR4    := 0, ;
    MKOL_PR5    := 0, ;
    MKOL_PR6    := 0, ;
    mplat_fio   := Space( 40 ), ;
    mplat_inn   := Space( 12 ), ;
    mplat_adres  := Space( 50 ), ; // адрес плательщика
  mplat_pasport :=  Space( 15 )  // документ плательщика
  If nKey == K_INS
    r_use( dir_server() + "kartotek",, "KART" )
    Goto ( glob_kartotek )
    If is_uchastok == 1
      mbukva := kart->bukva
      muchast := lstr( kart->uchast )
      mkod_vu := lstr( kart->kod_vu )
      much_doc := ""
      If !emptyall( kart->bukva, kart->uchast, kart->kod_vu )
        If !Empty( kart->bukva )
          much_doc += kart->bukva
        Endif
        much_doc += lstr( kart->uchast, 2 )
        If kart->kod_vu > 0
          much_doc += "/" + lstr( kart->kod_vu )
        Endif
      Endif
      MUCH_DOC := PadR( much_doc, 10 )
      If mem_ortot1 == 2 .and. mem_kodotd == 1
        m1otd := mem_ortotd
      Endif
    Elseif mem_kodkrt == 2
      MUCH_DOC := PadR( lstr( glob_kartotek ), 10 )
    Endif
    Use
  Elseif nKey == K_ENTER
    MKOD_DIAG   := human->KOD_DIAG      // шифр 1-ой осн.болезни
    MKOD_DIAG2  := human->KOD_DIAG2     // шифр 2-ой осн.болезни
    MKOD_DIAG3  := human->KOD_DIAG3     // шифр 3-ей осн.болезни
    MKOD_DIAG4  := human->KOD_DIAG4     // шифр 4-ой осн.болезни
    MKOD_DIAG5  := human->KOD_DIAG5     // шифр 5-ой осн.болезни
    MKOD_DIAG6  := human->KOD_DIAG6     // шифр 6-ой осн.болезни
    MKOD_DIAG7  := human->KOD_DIAG7     // шифр 7-ой осн.болезни
    MKOL_PR1    := human->KOL_PR1
    MKOL_PR2    := human->KOL_PR2
    MKOL_PR3    := human->KOL_PR3
    MKOL_PR4    := human->KOL_PR4
    MKOL_PR5    := human->KOL_PR5
    MKOL_PR6    := human->KOL_PR6
    mNAR_Z      := human->nar_z         // номер наряда-заказа
    mDATA       := human->Data          // дата наряда-заказа
    M1LPU       := human->LPU           // код учреждения
    M1OTD       := human->OTD           // код отделения
    mUCH_DOC    := human->uch_doc       // вид и номер учетного документа
    mKOD_VR     := human->kod_vr        // код врача
    mKOD_AS     := human->kod_as        // код зубного техника
    MN_DATA     := human->N_DATA        // дата начала лечения
    MK_DATA     := human->K_DATA        // дата окончания лечения
    mKOL_POS    := human->kol_pos       // количество посещений
    M1PRICH     := human->PRICH_POL     // причина поломки протеза
    MKOL_MOSTP  := human->KOL_MOSTP     // количество мостовидных протезов
    MKOL_CELNL  := human->KOL_CELNL     // в т.ч. цельнолитых
    MCENA       := human->CENA          // стоимость лечения
    MCENA_OPL   := human->CENA_OPL      // сумма оплаты
    m1tip_usl   := human->tip_usl
    mplat_fio   := human->plat_fio
    mplat_inn   := human->plat_inn
    If m1tip_usl > 0
      m1pr_smo := human->pr_smo
    Endif
    mn_och      := human->n_och
    mprim       := human->prim
  Endif
  //
  r_use( dir_server() + "hum_orpl", dir_server() + "hum_orpl", "KPLAT" )
  find ( Str( human->( RecNo() ), 7 ) )
  If Found()
    mplat_adres   := KPLAT->ADRES
    mplat_pasport := KPLAT->PASPORT
  Endif
  KPLAT->( dbCloseArea() )
  mtip_usl := inieditspr( A__MENUVERT, menu_okb, m1tip_usl )
  mlpu := inieditspr( A__POPUPMENU, dir_server() + "mo_uch", m1lpu )
  motd := inieditspr( A__POPUPMENU, dir_server() + "mo_otd", m1otd )
  mprich := inieditspr( A__POPUPMENU, dir_server() + "ort_brk", m1prich )
  If m1tip_usl == OU_D_SMO
    mpr_smo := inieditspr( A__POPUPMENU, dir_server() + "p_d_smo", m1pr_smo )
  Elseif m1tip_usl == OU_PR_VZ
    mpr_smo := inieditspr( A__POPUPMENU, dir_server() + "p_pr_vz", m1pr_smo )
  Endif
  r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
  str_1 := " карточки лечения ортопедического больного"
  If nKey == K_INS
    str_1 := "Добавление" + str_1
  Else
    str_1 := "Редактирование" + str_1
    Select PERSO
    Goto ( mkod_vr )
    mvrach := PadR( perso->fio, 35 )
    mtabn_vr := perso->tab_nom
    Goto ( mkod_as )
    massist := PadR( perso->fio, 35 )
    mtabn_as := perso->tab_nom
  Endif
  old_doc := much_doc ; old_k_data := mk_data
  Private gl_area := { r1, 0, 23, 79, 0 }
  box_shadow( r1, 0, 23, 79, color1, str_1, color8 )
  status_key( "^<Esc>^ - выход;  ^<PgDn>^ - запись" )
  help_code := -1
  SetColor( cDataCGet )
  //
  Do While .t.
    If nKey == K_INS .or. mnar_z == 0
      @ 23, 37 Say " <F2> - поиск свободного номера наряда " Color "BG/B"
      mark_keys( { "<F2>" }, "G+/B" )
    Endif
    @ r1 + 1, 2 Say "Вид и номер учетного документа" Get much_doc Picture "@!"
    @ r1 + 2, 2 Say "Учреждение" Get mlpu ;
      reader {| x| menu_reader( x, { {| k, r, c| ret_uch_otd( k, r, c, sys_date,, X_ORTO ) } }, A__FUNCTION,,, .f. ) }
    @ r1 + 3, 2 Say "Отделение" Get motd When .f.
    @ r1 + 3, 45 Say "Категория больного" Get mtip_usl ;
      reader {| x| menu_reader( x, menu_okb, A__MENUVERT,,, .f. ) } ;
      valid {| g, o| val_tip_usl( g, o, r1 + 4 ) }
    @ r1 + 4, 37 Say Space( 11 ) Get mpr_smo
    val_tip_usl(, m1tip_usl, r1 + 4 )
    @ r1 + 5, 2 Say "Диагнозы" Get mkod_diag Picture "@!" Valid v_ort_diag()
    @ Row(), Col() Say "," Get mkod_diag2 Picture "@!" Valid v_ort_diag()
    @ Row(), Col() Say "," Get mkod_diag3 Picture "@!" Valid v_ort_diag()
    If mem_ort_f39 == 1
      @ Row(), Col() Say "," Get mkod_diag4 Picture "@!" Valid v_ort_diag()
      @ Row(), Col() Say "," Get mkod_diag5 Picture "@!" Valid v_ort_diag()
      @ Row(), Col() Say "," Get mkod_diag6 Picture "@!" Valid v_ort_diag()
      @ Row(), Col() Say "," Get mkod_diag7 Picture "@!" Valid v_ort_diag()
    Endif
    @ r1 + 6, 2 Say "Номер наряда-заказа" Get mnar_z Pict "99999"
    @ Row(), Col() + 5 Say "Дата наряда-заказа" Get mdata ;
      valid {| g| if( regim == 2 .and. Empty( mn_data ), ( mn_data := mdata ), nil ), ;
      update_get( "mn_data" ) }
    @ r1 + 7, 2 Say "Таб.№ врача" Get mtabn_vr Pict "99999" ;
      valid {| g| f5e_o_kusl( g, 2, 3 ) }
    @ Row(), Col() + 3 Get mvrach When .f. Color color14
    @ r1 + 8, 2 Say "Таб.№ зуб/техника" Get mtabn_as Pict "99999" ;
      valid {| g| f5e_o_kusl( g, 2, 4 ) }
    @ Row(), Col() + 3 Get massist When .f. Color color14
    @ r1 + 9, 2 Say "Номер очереди" Get mn_och
    @ Row(), Col() + 10 Say "Примечание" Get mprim
    @ r1 + 10, 2 Say "Причины поломок протезов" Get mprich reader ;
      {| x| menu_reader( x, ;
      { dir_server() + "ort_brk",,,,, color5, "Причины поломок", "B/W" }, ;
      A__POPUPBASE1,,, .f. );
      }
    If mem_ort_f39 == 0
      @ r1 + 11, 2 Say "Количество мостовидных протезов, всего:" Get MKOL_MOSTP Pict "9"
      @ Row(), Col() Say ", в т.ч. цельнолитых" Get MKOL_CELNL Pict "9"
    Else
      @ r1 + 11, 2 Say "Протезов пласт:" Get MKOL_PR1 Pict "9"
      @ Row(), Col() Say " мет-кер:"     Get MKOL_Pr2 Pict "9"
      @ Row(), Col() Say " на штифт:"    Get MKOL_Pr3 Pict "9"
      @ Row(), Col() Say " мет-акр:"     Get MKOL_Pr4 Pict "9"
      @ Row(), Col() Say " штампов:"     Get MKOL_Pr5 Pict "9"
      @ Row(), Col() Say " цельнол:"     Get MKOL_Pr6 Pict "9"
    Endif
    // Добавка Плательщика 01.04.13
    // Кроме бесплатных
    @ r1 + 12, 2 Say "Плательщик: ФИО" Get mplat_fio When m1tip_usl != OU_B_PLAT
    @ Row(), Col() Say ", ИНН" Get mplat_inn When m1tip_usl != OU_B_PLAT
    @ r1 + 13, 2 Say "АДРЕС" Get mplat_adres Pict "@S45" When m1tip_usl != OU_B_PLAT
    @ Row(), Col() Say ", N Док." Get mplat_pasport When m1tip_usl != OU_B_PLAT
    // конец Плательщик
    If regim == 2
      @ r1 + 14, 2 Say "Дата начала лечения" Get mn_data valid {| g| f_k_data( g, 1 ) }
      @ Row(), Col() + 2 Say "Дата окончания лечения" Get mk_data valid {| g| f_k_data( g, 2 ) }
      @ r1 + 15, 2 Say "Количество посещений" Get mkol_pos Pict "99"
      @ r1 + 16, 10 Say "Стоимость лечения " + lstr( mcena, 11, 2 ) Color "GR+/B"
    Endif
    @ r1 + 16, 50 Say "Сумма оплаты " + lstr( mcena_opl, 11, 2 ) Color "GR+/B"
    If nKey == K_INS .or. mnar_z == 0
      Set Key K_F2 To poisk_svob
    Endif
    If nKey == K_ENTER .and. !ver_pub_date( mk_data, .t. )
      Keyboard Chr( K_ESC )
    Endif
    count_edit := myread(, @pos_read, ++k_read )
    If nKey == K_INS .or. mnar_z == 0
      Set Key K_F2 To
    Endif
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      If m1lpu == 0
        func_error( 4, "Не введено лечебное учреждение!" )
        Loop
      Endif
      If Empty( mdata )
        func_error( 4, "Не введена дата наряда-заказа." )
        Loop
      Endif
      If regim == 2
        err_date_diap( mn_data, "Дата начала лечения" )
        err_date_diap( mk_data, "Дата окончания лечения" )
      Endif
      mywait()
      If !( old_doc == much_doc ) .and. is_uchastok == 1
        much_doc := LTrim( much_doc )
        mbukva := " "
        muchast := 0
        mkod_vu := 0
        If !Empty( much_doc )
          i := 1
          Do While !( SubStr( much_doc, i, 1 ) $ "0123456789" .and. i <= Len( much_doc ) )
            If i == 1
              mbukva := Left( much_doc, 1 )
            Endif
            ++i
          Enddo
          If ( muchast := Int( Val( SubStr( much_doc, i ) ) ) ) > 99
            muchast := 0
          Endif
          If ( i := At( "/", much_doc ) ) > 0
            If ( mkod_vu := Int( Val( SubStr( much_doc, i + 1 ) ) ) ) > 99999
              mkod_vu := 0
            Endif
          Endif
        Endif
        g_use( dir_server() + "kartotek", dir_server() + "kartoteu", "KART" )
        Goto ( glob_kartotek )
        g_rlock( forever )
        kart->bukva := mbukva
        kart->uchast := muchast
        kart->kod_vu := mkod_vu
        kart->( dbCloseArea() )  // 19.04
      Endif
      Select HUMAN
      If nKey == K_INS
        addrec( 7 )
        human->kod_k := glob_kartotek
      Else
        g_rlock( forever )
      Endif
      replace ;
        human->NAR_Z     With mNAR_Z, ;
        human->Data      With mDATA, ;
        human->LPU       With m1LPU, ;
        human->OTD       With m1OTD, ;
        human->UCH_DOC   With mUCH_DOC, ;
        human->KOD_VR    With mKOD_VR, ;
        human->KOD_AS    With mKOD_AS, ;
        human->N_DATA    With mN_DATA, ;
        human->K_DATA    With mK_DATA, ;
        human->KOL_POS   With mKOL_POS, ;
        human->tip_usl   With m1tip_usl, ;
        human->n_och     With mn_och, ;
        human->PRICH_POL With M1PRICH, ;
        human->KOL_MOSTP With MKOL_MOSTP, ;
        human->KOL_CELNL With MKOL_CELNL, ;
        human->prim      With mprim
      human->KOD_DIAG  := mKOD_DIAG
      human->KOD_DIAG2 := mKOD_DIAG2
      human->KOD_DIAG3 := mKOD_DIAG3
      human->KOD_DIAG4 := mKOD_DIAG4
      human->KOD_DIAG5 := mKOD_DIAG5
      human->KOD_DIAG6 := mKOD_DIAG6
      human->KOD_DIAG7 := mKOD_DIAG7
      human->plat_fio  := mplat_fio
      human->plat_inn  := mplat_inn
      If mem_ort_f39 == 1
        human->KOL_PR1 := MKOL_PR1
        human->KOL_PR2 := MKOL_PR2
        human->KOL_PR3 := MKOL_PR3
        human->KOL_PR4 := MKOL_PR4
        human->KOL_PR5 := MKOL_PR5
        human->KOL_PR6 := MKOL_PR6
      Endif
      If equalany( m1tip_usl, OU_D_SMO, OU_PR_VZ )
        human->pr_smo := m1pr_smo
      Else
        human->pr_smo := 0
      Endif
      If mem_ort_dat == 2 .and. Empty( human->n_data )
        human->N_DATA := mDATA
      Endif
      If regim == 1
        st_tip_usl := m1tip_usl
      Endif
      human->( dbUnlock() ) // 19.04
      dbCommitAll()
      g_use( dir_server() + "hum_orpl", dir_server() + "hum_orpl", "KPLAT" ) // только один индекс
      If Len( AllTrim( mplat_adres ) ) > 2 // .or. len(alltrim(mplat_pasport)) > 2
        find ( Str( human->( RecNo() ), 7 ) )
        If !Found()
          Append Blank
        Else
          g_rlock( forever )
        Endif
        KPLAT->kod     := human->( RecNo() )
        KPLAT->ADRES   := mplat_adres
        KPLAT->PASPORT := mplat_pasport
      Else
        find ( Str( human->( RecNo() ), 7 ) )
        If Found()
          deleterec( .t. )
        Endif
      Endif
      KPLAT->( dbCloseArea() )
      Select HUMAN
      write_work_oper( glob_task + iif( m1tip_usl == OU_B_PLAT, 100, 0 ), ;
        OPER_LIST, ;
        iif( nKey == K_INS, 1, 2 ), ;
        1, ;
        count_edit )
      ret := 0
    Elseif nKey == K_INS .and. !fl_found
      ret := 1
    Endif
    Exit
  Enddo
  perso->( dbCloseArea() )
  Select HUMAN
  SetColor( tmp_color )
  RestScreen( buf )
  help_code := tmp_help
  Return ret

// 15.11.18
Function v_ort_diag()

  Local n := 6, fl := .t., mshifr, tmp_select := Select()
  Private mvar := ReadVar()

  mshifr := AllTrim( &mvar )
  mshifr := PadR( mshifr, 6 )
  If !Empty( mshifr )
    r_use( dir_server() + "diag_ort", dir_server() + "diag_ort", "DBF1" )
    find ( mshifr )
    If !Found()
      &mvar := Space( n )
      fl := func_error( 4, "Ортопедический диагноз с таким шифром не найден!" )
    Endif
    DBF1->( dbCloseArea() )
    If tmp_select > 0
      Select ( tmp_select )
    Endif
  Endif
  If fl
    &mvar := PadR( mshifr, n )
  Endif
  Return fl

//
Static Function val_tip_usl( get, old, r )

  Local fl := .t., s := ""

  If !equalany( m1tip_usl, OU_D_SMO, OU_PR_VZ )
    m1pr_smo := 0 ; mpr_smo := Space( 30 )
  Endif
  If old != Nil .and. old != m1tip_usl
    m1pr_smo := 0 ; mpr_smo := Space( 30 )
  Endif
  get := get_pointer( "mpr_smo" )
  If m1tip_usl == OU_D_SMO
    s := "СМО"
    If get != NIL
      get:reader := {| x| menu_reader( x, ;
        { dir_server() + "p_d_smo",,,,, color0, "Добровольные СМО", "B/BG" }, ;
        A__POPUPBASE1,,, .f. );
        }
      get:PreBlock := {|| .t. }
    Endif
  Elseif m1tip_usl == OU_PR_VZ
    s := "Предприятие"
    If get != NIL
      get:reader := {| x| menu_reader( x, ;
        { dir_server() + "p_pr_vz",,,,, color0, "Предприятия по взаимозачету", "B/BG" }, ;
        A__POPUPBASE1,,, .f. );
        }
      get:PreBlock := {|| .t. }
    Endif
  Else
    get:reader := NIL
    get:PreBlock := {|| .f. }
  Endif
  @ r, 37 Say PadL( s, 11 )
  update_get( "mpr_smo" )
  Return fl

// 15.11.18
Function usl_ort_kart( mkod_human, mkod_lpu )

  // mkod_human - код по БД human
  Local adbf, buf := SaveScreen(), j := 0, tmp_color := SetColor( color1 ), ;
    k, l_color
  Private fl_found, mcena := 0, ;
    last_date := CToD( "01.01.1990" ), mvu[ 3, 2 ], mvp[ 3, 2 ], pr1otd, ;
    pr_arr := {}, pr_arr_otd := {}, pr1arr_otd := {}
  Private Glob_kod_ms := 0
  afillall( mvu, 0 ) ; afillall( mvp, 0 )
  mywait()
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( glob_kartotek )
  smvzros_reb := kart->vzros_reb
  kart->( dbCloseArea() )
  //
  r_use( dir_server() + "mo_otd",, "OTD" )
  dbEval( {|| AAdd( pr_arr, { otd->( RecNo() ), otd->name, otd->kod_lpu, "" } ) }, ;
    {|| otd->kod_lpu == mkod_lpu .and. between_date( otd->dbegino, otd->dendo, sys_date ) } )
  If yes_many_uch
    r_use( dir_server() + "mo_uch",, "UCH" )
    AEval( pr_arr, {| x, i| dbGoto( x[ 3 ] ), pr_arr[ i, 4 ] := uch->name } )
    // aeval(pr1arr_otd, {|x,i| dbGoto(x[3]), pr1arr_otd[i,4] := uch->name } )
    uch->( dbCloseArea() )
    //
    ASort( pr_arr,,, {| x, y| iif( x[ 3 ] == y[ 3 ], Upper( x[ 2 ] ) < Upper( y[ 2 ] ), ;
      Upper( x[ 4 ] ) < Upper( y[ 4 ] ) ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 4 ] + " " + x[ 2 ] ) } )
  Else
    ASort( pr_arr,,, {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
    AEval( pr_arr, {| x| AAdd( pr_arr_otd, x[ 2 ] ) } )
  Endif
  //
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" ) // 19.04
  // r_use_base("hum_oru") //19.04
  adbf := dbStruct()
  AAdd( adbf, { "date_u1", "D", 8, 0 } )
  AAdd( adbf, { "shifr_u", "C", 10, 0 } )
  AAdd( adbf, { "name_u", "C", 65, 0 } )
  AAdd( adbf, { "number", "N", 3, 0 } )
  AAdd( adbf, { "is_nul", "L", 1, 0 } )
  AAdd( adbf, { "rec_hu", "N", 7, 0 } )
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  If mem_ordusl == 1
    Index On DToS( date_u1 ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  Else
    Index On fsort_usl( shifr_u ) + DToS( date_u1 ) to ( cur_dir() + "tmp_usl" )
  Endif
  Select HU
  Set Relation To u_kod into USL
  find ( Str( mkod_human, 7 ) )
  If ( fl_found := Found() )
    adbf := Array( FCount() )
    Do While hu->kod == mkod_human .and. !Eof()
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select TMP
      Append Blank
      AEval( adbf, {| x, i| FieldPut( i, x ) } )
      tmp->date_u1 := c4tod( hu->date_u )
      tmp->shifr_u := usl->shifr
      tmp->name_u := usl->name
      tmp->is_nul := usl->is_nulp
      tmp->rec_hu := hu->( RecNo() )
      last_date := Max( tmp->date_u1, last_date )
      mcena += tmp->stoim
      Select HU
      Skip
    Enddo
  Endif
  tmp->( dbEval( {|| tmp->number := ++j } ) )
  Close databases
  //
  Private flag_1 := .t., arr_uva := {}
  r_use( dir_server() + "orto_uva",, "OU" )
  dbEval( {|| AAdd( arr_uva, { AllTrim( ou->shifr ), ou->kod_vr, ou->kod_as, ou->kod_ms } ) } )
  ou->( dbCloseArea() )
  If use_base( "hum_ort" ) .and. ;
      use_base( "hum_oru" ) .and. ;
      r_use( dir_server() + "uslugi", dir_server() + "uslugish", "USL" ) .and. ;
      r_use( dir_server() + "mo_otd",, "OTD" ) .and. ;
      r_use( dir_server() + "usl_otd", dir_server() + "usl_otd", "UO" ) .and. ;
      r_use( dir_server() + "mo_pers", dir_server() + "mo_pers", "PERSO" )
    Select HUMAN
    Set Order To 0
    Goto ( mkod_human )
    last_date := Max( human->n_data, last_date )
    pr1otd := human->otd
    Use ( cur_dir() + "tmp_usl" ) index ( cur_dir() + "tmp_usl" ) New Alias TMP
    Set Relation To otd into OTD
    Go Top
    cls
    pr_1_str( "Ортопед.услуги для больного < " + AllTrim( glob_k_fio ) + " >" )
    @ 1, 1 Say "Наряд-заказ N " + lstr( human->nar_z ) + " от " + date_8( human->data ) + "г." Color "G+/B"
    SetColor( "BG/B" )
    If yes_color
      SetColor( "BG/B" )
      l_color := "W+/B,W+/W,BG+/B,W+/BG,G+/B,W+/G,GR+/B,W+/GR"
    Else
      SetColor( "W/N" )
      l_color := "W+/N,N/W,W/N,N+/W,W/N,W+/N,W/N,W+/N"
    Endif
    @ MaxRow() -3, 0 Say "╒═══════════════════ Полное наименование услуги ═══════════════════╤══ Цена ═══╕"
    @ MaxRow() -2, 0 Say "│                                                                  │           │"
    @ MaxRow() -1, 0 Say "╘══════════════════════════════════════════════════════════════════╧═══════════╛"
    If fl_found
      Keyboard Chr( K_RIGHT )
    Else
      Keyboard Chr( K_INS )
    Endif
    SetColor( color1 )
    alpha_browse( 2, 0, MaxRow() -5, 79, "fe_o_kusl", color1, ;
      "Срок лечения с " + full_date( human->n_data ) + "г. по " + full_date( human->k_data ) + "г.", col_tit_popup, ;
      .f., .t.,, "f1e_o_kusl", "f2e_o_kusl",, ;
      { "═", "░", "═", l_color, .t., 180 } )
    If yes_parol .and. ( mvu[ 1, 1 ] > 0 .or. mvu[ 2, 1 ] > 0 .or. mvu[ 3, 1 ] > 0 .or. ;
        mvp[ 1, 1 ] > 0 .or. mvp[ 2, 1 ] > 0 .or. mvp[ 3, 1 ] > 0 )
      // ;   .and. hb_FileExists(dir_server()+"mo_opern"+sdbf())
      Close databases
      If g_use( dir_server() + "mo_opern", dir_server() + "mo_opern", "OP" )
        For i := 1 To 3
          If mvu[ i, 1 ] > 0
            write_work_oper( glob_task, OPER_USL, i, mvu[ i, 1 ], mvu[ i, 2 ], .f. )
          Endif
        Next
        For i := 1 To 3
          If mvp[ i, 1 ] > 0
            write_work_oper( glob_task + 100, OPER_USL, i, mvp[ i, 1 ], mvp[ i, 2 ], .f. )
          Endif
        Next
      Endif
    Endif
    Close databases
  Endif
  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  Return mcena

//
Function fe_o_kusl( oBrow )

  Local oColumn, blk_color := {|| if( tmp->t_edit > 1, { 3, 4 }, { 1, 2 } ) }

  blk_color := {|| { { 1, 2 }, { 3, 4 }, { 5, 6 }, { 7, 8 } }[ tmp->tip_usl + 1 ] }
  oColumn := TBColumnNew( " NN; пп", {|| tmp->number } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 1
    oColumn := TBColumnNew( "Дата;оказ.; усл.", {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "   Шифр;  услуги", {|| tmp->shifr_u } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  If mem_ordusl == 2
    oColumn := TBColumnNew( "Дата;оказ.; усл.", {|| Left( DToC( tmp->date_u1 ), 5 ) } )
    oColumn:colorBlock := blk_color
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( "Отде-;ление", {|| otd->short_name } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Наименование;услуги", ;
    {|| Left( tmp->name_u, 12 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Врач", {|| put_val( ret_tabn( tmp->kod_vr ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Зуб.Т", {|| put_val( ret_tabn( tmp->kod_as ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( "Ко-;лич.;усл.", {|| umest_val( tmp->kol, 4, 3 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " Общая; стоимость; услуги", {|| put_kop( tmp->stoim, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( " ", {|| { "П", "б", "з", "Д" }[ tmp->tip_usl + 1 ] } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F5>^ дублирование" )
  Return Nil

//
Function f1e_o_kusl()

  Local nRow := Row(), nCol := Col()

  @ MaxRow() -2, 2 Say tmp->name_u Color cDataCSay
  @ MaxRow() -2, 68 Say if( Empty( tmp->u_cena ), Space( 11 ), ;
    PadC( AllTrim( dellastnul( tmp->u_cena, 10, 2 ) ), 11 ) ) Color cDataCSay
  If flag_1
    f3e_o_kusl()
    flag_1 := .f.
  Endif
  @ nRow, nCol Say ""
  Return Nil

//
Function f3e_o_kusl()

  @ MaxRow() -4, 55 Say PadL( "Итого: " + lstr( mcena, 11, 2 ), 20 ) Color "W+/N"
  Return Nil

//
Function f2e_o_kusl( nKey, oBrow )

  Static st_tip_usl := 0
  Local flag := -1, buf := SaveScreen(), fl := .f., rec, ;
    i1, k, j := 0, s := 0, so := 0, adbf, adbf1, tmp_color := SetColor(), ;
    rec_tmp := tmp->( RecNo() ), mrec_hu := tmp->rec_hu, ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    tmp_help := help_code, uch_otd := saveuchotd()
  Private r1 := 11

  If equalany( nKey, K_F5, K_INS, K_ENTER, K_DEL )
    If !ver_pub_date( human->k_data, .t. )
      Return flag
    Endif
  Endif
  Do Case
  Case nKey == K_F5 .and. tmp->kod > 0
    If ( i1 := input_value( 18, 5, 20, 74, color0, ;
        "Введите, сколько еще копий необходимо сделать из текущей строки", ;
        1, "99" ) ) != Nil .and. i1 > 0 .and. f_esc_enter( "дублирования строки" )
      mywait()
      // услуги добавлены оператором
      If tmp->tip_usl == OU_B_PLAT
        mvp[ 1, 1 ] += i1
      Else
        mvu[ 1, 1 ] += i1
      Endif
      Select HU
      Goto ( mrec_hu )
      adbf := Array( FCount() )
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select TMP
      adbf1 := Array( FCount() )
      AEval( adbf1, {| x, i| adbf1[ i ] := FieldGet( i ) } )
      Private mdate_u1 := tmp->date_u1
      For k := 1 To i1
        mdate_u1++
        Select HU
        add1rec( 7 )
        AEval( adbf, {| x, i| FieldPut( i, x ) } )
        hu->date_u := dtoc4( mdate_u1 )
        mrec_hu := hu->( RecNo() )
        Unlock
        Select TMP
        Append Blank
        AEval( adbf1, {| x, i| FieldPut( i, x ) } )
        tmp->date_u1 := mdate_u1
        tmp->rec_hu := mrec_hu
      Next
      summa_usl( @mcena )
      Select HUMAN
      g_rlock( forever )
      human->cena := mcena
      human->( dbUnlock() ) // 19.04
      human->( dbCommit() )
      RestScreen( buf )
      f3e_o_kusl()
      Select TMP
      oBrow:gotop()
      Goto ( rec_tmp )
      SetColor( tmp_color )
      flag := 0
    Endif
  Case nKey == K_INS .or. ( nKey == K_ENTER .and. tmp->kod > 0 )
    // help_code := HM_Edit1_kart
    If nKey == K_INS .and. !fl_found
      ColorWin( 7, 0, 7, 79, "B/B", "W+/RB" )
    Endif
    If nKey == K_INS .and. tmp->( LastRec() ) == 0
      st_tip_usl := human->tip_usl
    Endif
    Private motd, m1otd := if( nKey == K_INS, ;
      if( pr1otd == NIL, 0, pr1otd ), tmp->otd ), ;
      mtip_usl, m1tip_usl := if( nKey == K_INS, st_tip_usl, tmp->tip_usl ), ;
      mu_kod := if( nKey == K_INS, 0, tmp->u_kod ), ;
      mdate_u1 := if( nKey == K_INS, last_date, tmp->date_u1 ), ;
      mu_cena := if( nKey == K_INS, 0, tmp->u_cena ), ;
      mis_nul := if( nKey == K_INS, .f., tmp->is_nul ), ;
      mkod_vr := if( nKey == K_INS, human->kod_vr, tmp->kod_vr ), ;
      mkod_as := if( nKey == K_INS, human->kod_as, tmp->kod_as ), ;
      mkod_ms := if( nKey == K_INS, glob_kod_ms, tmp->kod_ms ), ;
      mtabn_vr := 0, mtabn_as := 0, mtabn_ms := 0, ;
      mkol := if( nKey == K_INS, 0, tmp->kol ), ;
      mu_koef := if( nKey == K_INS, 1, tmp->u_koef ), ;
      mstoim := if( nKey == K_INS, 0, tmp->stoim ), ;
      mt_edit := if( nKey == K_INS, 0, tmp->t_edit ), ;
      mshifr := if( nKey == K_INS, Space( 10 ), tmp->shifr_u ), ;
      mname_u := if( nKey == K_INS, Space( 65 ), tmp->name_u ), ;
      mvrach := massist := mmedses := Space( 35 ), ;
      vr_uva := as_uva := ms_uva := .t., ;
      gl_area := { 1, 0, 23, 79, 0 }
    mtip_usl := inieditspr( A__MENUVERT, menu_otip, m1tip_usl )
    If nKey == K_INS .and. mem_ortot1 == 2 .and. mem_kodotd == 1
      m1otd := mem_ortotd
    Endif
    motd := inieditspr( A__POPUPMENU, dir_server() + "mo_otd", m1otd )
    If !Empty( mshifr )
      verify_o_uva()
    Endif
    If !emptyall( mkod_vr, mkod_as, mkod_ms )
      Select PERSO
      If mkod_vr > 0
        Goto ( mkod_vr )
        mvrach := PadR( perso->fio, 35 )
        mtabn_vr := perso->tab_nom
      Endif
      If mkod_as > 0
        Goto ( mkod_as )
        massist := PadR( perso->fio, 35 )
        mtabn_as := perso->tab_nom
      Endif
      If mkod_ms > 0
        Goto ( mkod_ms )
        mmedses := PadR( perso->fio, 35 )
        mtabn_ms := perso->tab_nom
      Endif
    Endif
    box_shadow( r1 - 1, 0, 23, 79, color8, ;
      if( nKey == K_INS, "Добавление новой", ;
      "Редактирование" ) + " ортопедической услуги", "RB+/B" )
    Do While .t.
      SetColor( cDataCGet )
      If mem_kodotd == 1
        If mem_ortot1 == 1
          @ r1 + 1, 2 Say "Отделение, в котором оказана услуга" Get motd ;
            reader {| x| menu_reader( x, ;
            { {|k, r, c| get_otd( k, r + 1, c, .t. ) } }, A__FUNCTION,,, .f. ) }
        Else
          @ r1 + 1, 2 Say "Отделение, в котором оказана услуга"
          @ Row(), Col() + 2 Get motd Color color14 When .f.
        Endif
      Else
        @ r1 + 1, 2 Say "Отделение, в котором оказана услуга"
        If mem_ortot1 == 1
          @ Row(), Col() Get m1otd Pict "99" ;
            when {| g| f5e_o_kusl( g, 1, 10 ) } ;
            valid {| g| f5e_o_kusl( g, 2, 10 ) }
        Endif
        @ Row(), Col() + 2 Get motd Color color14 When .f.
      Endif
      @ r1 + 2, 2 Say "Тип услуги" Get mtip_usl ;
        reader {| x| menu_reader( x, menu_otip, A__MENUVERT,,, .f. ) }
      // when empty(mshifr)
      @ Row(), Col() + 7 Say "Дата оказания услуги" Get mdate_u1 ;
        valid {| g| f5e_o_kusl( g, 2, 1 ) }
      @ r1 + 3, 2 Say "Шифр услуги" Get mshifr Pict "@!" ;
        when {| g| f5e_o_kusl( g, 1, 2 ) } ;
        valid {| g| f5e_o_kusl( g, 2, 2 ) }
      @ Row(), 40 Say "Цена услуги" Get mu_cena Pict pict_cena() ;
        When .f. Color color14
      @ r1 + 4, 2 Say "Услуга" Get mname_u When .f. Color color14
      ix := 4
      For x := 1 To 3
        If mem_por_vr == x
          ++ix
          @ r1 + ix, 2 Say "Таб.N врача" Get mtabn_vr Pict "99999" ;
            when {| g| f5e_o_kusl( g, 1, 3 ) } ;
            valid {| g| f5e_o_kusl( g, 2, 3 ) }
          @ Row(), Col() + 3 Get mvrach When .f. Color color14
        Endif
        If mem_por_ass == x
          ++ix
          @ r1 + ix, 2 Say "Таб.N зуб/техника" Get mtabn_as Pict "99999" ;
            when {| g| f5e_o_kusl( g, 1, 4 ) } ;
            valid {| g| f5e_o_kusl( g, 2, 4 ) }
          @ Row(), Col() + 3 Get massist When .f. Color color14
          If mem_ort_ms == 2
            ++ix
            @ r1 + ix, 2 Say "Таб.N медсестры" Get mtabn_ms Pict "99999" ;
              when {| g| f5e_o_kusl( g, 1, 41 ) } ;
              valid {| g| f5e_o_kusl( g, 2, 41 ) }
            @ Row(), Col() + 3 Get mmedses When .f. Color color14
          Endif
        Endif
        If mem_por_kol == x
          ++ix
          If mem_ort_ysl == 1
            @ r1 + ix, 2 Say "Количество услуг" Get mkol Pict "999.999" ;
              when {| g| f5e_o_kusl( g, 1, 5 ) } ;
              valid {| g| f5e_o_kusl( g, 2, 5 ) }
          Else
            @ r1 + ix, 2 Say "Количество услуг" Get mkol Pict "999.9" ;
              when {| g| f5e_o_kusl( g, 1, 5 ) } ;
              valid {| g| f5e_o_kusl( g, 2, 5 ) }
          Endif
        Endif
      Next
      @ r1 + 10, 2 Say "Общая стоимость услуги" Get mstoim Pict pict_cena() ;
        when {| g| mem_edit_s == 2 .and. f5e_o_kusl( g, 1, 7 ) } ;
        valid {| g| f5e_o_kusl( g, 2, 7 ) }
      If mt_edit > 1
        @ r1 + 10, 37 Say "[ редактировалась стоимость услуги ]" Color color13
      Endif
      status_key( "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи" )
      count_edit := myread(, @pos_read, ++k_read )
      SetKey( K_F2, NIL )
      SetKey( K_F3, NIL )
      If LastKey() != K_ESC
        If emptyany( mu_kod, mdate_u1 )
          func_error( 4, "Введены не все данные!" )
          Loop
        Elseif !mis_nul .and. Empty( mstoim ) // 20.03.13
          func_error( 4, "Не введена цена услуги!" )
          Loop
        Elseif mem_vv_v_a == 1 .and. emptyall( mkod_vr, mkod_as )
          func_error( 4, "Не введены врач и зубной техник!" )
          Loop
        Else
          err_date_diap( mdate_u1, "Дата оказания услуги" )
          mywait()
          Select HU
          If nKey == K_INS
            add1rec( 7 )
            mrec_hu := hu->( RecNo() )
            fl_found := .t.
            Select TMP
            Append Blank
            rec_tmp := tmp->( RecNo() )
            k := 1 // услуга добавлена оператором
          Else
            Goto ( mrec_hu )
            g_rlock( forever )
            Select TMP
            Goto ( rec_tmp )
            k := 2
          Endif
          If m1tip_usl == OU_B_PLAT
            mvp[ k, 1 ]++
            mvp[ k, 2 ] += count_edit
          Else
            mvu[ k, 1 ]++
            mvu[ k, 2 ] += count_edit
          Endif
          glob_kod_ms := mkod_ms
          Select HU
          Replace hu->kod     With human->( RecNo() ), ;
            hu->tip_usl With m1tip_usl, ;
            hu->kod_vr  With mkod_vr, ;
            hu->kod_as  With mkod_as, ;
            hu->kod_ms  With mkod_ms, ;
            hu->u_koef  With 1, ;
            hu->stoim   With mstoim, ;
            hu->u_kod   With mu_kod, ;
            hu->u_cena  With mu_cena, ;
            hu->t_edit  With mt_edit, ;
            hu->kol     With mkol, ;
            hu->date_u  With dtoc4( mdate_u1 ), ;
            hu->otd     With m1otd
          hu->( dbUnlock() ) // 19.04
          st_tip_usl := m1tip_usl
          pr1otd := m1otd
          adbf := Array( FCount() )
          AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
          Select TMP
          AEval( adbf, {| x, i| FieldPut( i, x ) } )
          tmp->date_u1 := mdate_u1
          tmp->shifr_u := mshifr
          tmp->name_u := mname_u
          tmp->rec_hu := mrec_hu
          tmp->is_nul := mis_nul // 15.12.13
          // last_date := max(tmp->date_u1,last_date) - так было
          last_date := tmp->date_u1  // - так стало
          summa_usl( @mcena )
          Select HUMAN
          g_rlock( forever )
          human->cena := mcena
          human->( dbUnlock() ) // 19.04
          dbCommitAll()
        Endif
      Endif
      Exit
    Enddo
    flag := 0
    If nKey == K_INS .and. !fl_found
      flag := 1
    Endif
    RestScreen( buf )
    f3e_o_kusl()
    Select TMP
    oBrow:gotop()
    Goto ( rec_tmp )
    SetColor( tmp_color )
  Case nKey == K_DEL .and. tmp->kod > 0
    If f_esc_enter( 2 )
      mywait()
      // услуги удалены оператором
      If tmp->tip_usl == OU_B_PLAT
        mvp[ 3, 1 ] ++
      Else
        mvu[ 3, 1 ] ++
      Endif
      Select HU
      Goto ( tmp->rec_hu )
      deleterec( .t., .f. )  // очистка записи без пометки на удаление
      Select TMP
      deleterec( .t. )  // с пометкой на удаление
      summa_usl( @mcena )
      Select HUMAN
      g_rlock( forever )
      human->cena := mcena
      human->( dbUnlock() ) // 19.04
      dbCommitAll()
      Select TMP
      oBrow:gotop()
      Go Top
      If Eof()
        fl_found := .f. ; Keyboard Chr( K_INS )
      Endif
      flag := 0
      RestScreen( buf )
      f3e_o_kusl()
    Endif
  Otherwise
    Keyboard ""
  Endcase
  help_code := tmp_help
  restuchotd( uch_otd )
  Return flag

//
Static Function summa_usl( s )

  Local j := 0

  s := 0
  Select TMP
  Go Top
  Do While !Eof()
    s += tmp->stoim
    tmp->number := ++j
    Skip
  Enddo
  s := Round( s, 2 )
  Return Nil

//
Function f5e_o_kusl( get, when_valid, k )

  Local fl := .t., s, old_kod, ;
    msg1_err := "Код врача равен коду зубного техника! Это недопустимо.", ;
    msg2_err := "Человека с таким кодом нет в базе данных персонала!", ;
    blk_sum := {|| mstoim := round_5( mu_cena * mkol, 2 ) }

  If when_valid == 1    // when
    If k == 2     // Шифр услуги
      If !Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 3 // Код врача
      fl := vr_uva
    Elseif k == 4 // Код зубного техника
      fl := as_uva
    Elseif k == 41 // Код медсестры
      fl := ms_uva
    Elseif k == 5 // Количество услуг
      If Empty( mshifr )
        fl := .f.
      Elseif mt_edit > 1
        fl := .f.
      Endif
    Elseif k == 7 // Общая стоимость услуги
      If Empty( mshifr )
        fl := .f.
      Endif
    Elseif k == 10  // код отделения
      SetKey( K_F3, {| p, l, v| get1_otd( p, l, v, get:Row, get:Col ) } )
      @ r1, 45 Say "<F3> - выбор отделения из меню" Color color13
    Endif
  Else                  // valid
    If k == 1     // Дата оказания услуги
      If !emptyany( human->n_data, mdate_u1 ) .and. mdate_u1 < human->n_data
        fl := func_error( 4, "Введенная дата меньше даты начала лечения!" )
      Elseif !emptyany( human->k_data, mdate_u1 ) .and. mdate_u1 > human->k_data
        fl := func_error( 4, "Введенная дата больше даты окончания лечения!" )
      Endif
    Elseif k == 2 // Шифр услуги
      If !Empty( mshifr ) .and. !( mshifr == get:original )
        mshifr := transform_shifr( mshifr )
        Select USL
        Set Order To 1
        find ( mshifr )
        If Found()
          mu_kod := usl->kod
          mname_u := usl->name
          mis_nul := usl->is_nulp
          mu_cena := 0
          mu_koef := 1
          If mis_nul  // услуга с нулевой ценой
            mu_cena := 0
          Else
            If m1tip_usl != OU_B_PLAT
              // сначала берем цену для платных услуг
              mu_cena := if( smvzros_reb == 0, usl->pcena, usl->pcena_d )
              If m1tip_usl == OU_D_SMO .and. usl->dms_cena > 0
                mu_cena := usl->dms_cena
              Endif
            Endif
          Endif
          If Empty( mu_cena )  // если не найдена, то берем обычную цену
            mu_cena := if( smvzros_reb == 0, usl->cena, usl->cena_d )
          Endif
          mkol := 1
          Eval( blk_sum )
          verify_o_uva()
          update_gets()
        Else
          fl := func_error( 4, "Такого шифра нет в базе данных услуг." )
        Endif
      Endif
    Elseif k == 3 // Код врача
      old_kod := mkod_vr
      If Empty( mtabn_vr )
        mkod_vr := 0
        mvrach := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_vr, 5 ) )
        If Found()
          If perso->kod == mkod_as
            fl := func_error( 4, msg1_err )
          Elseif perso->kod == mkod_ms
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
    Elseif k == 4 // Код зубного техника
      old_kod := mkod_as
      If Empty( mtabn_as )
        mkod_as := 0
        massist := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_as, 5 ) )
        If Found()
          If perso->kod == mkod_vr
            fl := func_error( 4, msg1_err )
          Elseif perso->kod == mkod_ms
            fl := func_error( 4, msg1_err )
          Else
            mkod_as := perso->kod
            massist := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_as
        update_get( "massist" )
      Endif
    Elseif k == 41 // Код медсестры
      old_kod := mkod_ms
      If Empty( mtabn_ms )
        mkod_ms := 0
        mmedses := Space( 35 )
      Else
        Select PERSO
        find ( Str( mtabn_ms, 5 ) )
        If Found()
          If perso->kod == mkod_vr
            fl := func_error( 4, msg1_err )
          Elseif perso->kod == mkod_as
            fl := func_error( 4, msg1_err )
          Else
            mkod_ms := perso->kod
            mmedses := PadR( perso->fio, 35 )
          Endif
        Else
          fl := func_error( 4, msg2_err )
        Endif
      Endif
      If old_kod != mkod_ms
        update_get( "mmedses" )
      Endif
    Elseif k == 5 // Количество услуг
      If !( Round( mkol, 3 ) == Round( get:original, 3 ) )
        Eval( blk_sum )
        update_gets()
      Endif
    Elseif k == 7 // Общая стоимость услуги
      If !( Round( mstoim, 2 ) == round_5( mu_cena * mkol, 2 ) )
        If mt_edit == 0
          mt_edit := 2
        Elseif mt_edit == 1
          mt_edit := 3
        Endif
        @ r1 + 9, 37 Say "[ редактировалась стоимость услуги ]" Color "W/B"
      Endif
    Elseif k == 10  // код отделения
      If ( i := AScan( pr_arr, {| x| x[ 1 ] == m1otd } ) ) > 0
        motd := pr_arr[ i, 2 ] ; update_get( "motd" )
        SetKey( K_F3, NIL )
        @ r1, 45 Say Space( 30 ) Color color13
      Else
        fl := func_error( 4, "Данный код отделения не найден!" )
      Endif
    Endif
    If !fl
      &( ReadVar() ) := get:original
    Endif
  Endif
  Return fl

// 12.09.25
Function pr_zak_nar( tip_print ) // 21.05.08

  Static st_tip_usl := 0
  Local i := 1, j, k, s, fl, buf := save_row( MaxRow() )
  Local luchast := "", arr, mfam1, mima1, mots1, m1vid_ud, ;
    m1kategor := ATail( stm_kategor )[ 2 ]  // т.е. прочие (последнее значение)
  Local lnomer, l1nomer
  Private file_sh1, mLnomer
  Private okato_adresr, okato_adresg, m1fio

  If human->tip_usl == OU_B_PLAT  // бесплатно
    file_sh1 := mem_ort_bp
  Else
    file_sh1 := mem_ort_pl
  Endif
  Private ;
    muchast     := 0,; // участок
  mkod_kart   := 0,; // код человека в картотеке
  mNAR_Z      := 0,; // номер наряда-заказа
  mDATA       := sys_date,; // дата наряда-заказа
  MLPU, M1LPU := glob_uch[ 1 ],; // код учреждения
  MOTD, M1OTD := glob_otd[ 1 ],; // код отделения
  mUCH_DOC    := Space( 10 ),; // вид и номер учетного документа
  mKOD_VR     := 0,; // код врача
  mKOD_AS     := 0,; // код зубного техника
  mkod_ms     := 0,;
    mKOD_DIAG   := Space( 6 ),; // шифр болезни
  mKOD_DIAG2  := Space( 6 ),; // шифр болезни
  mKOD_DIAG3  := Space( 6 ),; // шифр болезни
  MN_DATA     := CToD( "" ),; // дата начала лечения
  MK_DATA     := CToD( "" ),; // дата окончания лечения
  mKOL_POS    := 0,; // количество посещений
  mn_och      := Space( 10 ),; // номер очереди (для бесплатных больных)
  MPRICH, M1PRICH := 0,; // причина поломки протеза
  MKOL_MOSTP  := 0,; // количество мостовидных протезов
  MKOL_CELNL  := 0,; // в т.ч. цельнолитых
  mprim       := Space( 15 ),; // примечание
  mfio        := Space( 50 ),; // фио
  madres      := Space( 50 ),; // адрес
  mmr_dol     := Space( 50 ),; // место работы должность
  mdate_r     := CToD( "" ),; // дата рождения
  mst_summa   := "",; // сумма наряда          //16.04.08
  mkod_human,;
    mvid_ud,; // вид удостоверения
  mnom,;
    mser,;                          // к16.04.08
  mtip_usl, m1tip_usl := st_tip_usl, ;
    mtabn_vr := 0, mtabn_as := 0, ;
    mvrach := massist := Space( 35 ), ;
    mcena := 0, mcena_opl := 0, ;
    mplat_fio, mplat_inn,;
    mplat_adres, mplat_pasport, ;
    msnils := "", mphone_m
  //
  MKOD_DIAG   := human->KOD_DIAG      // шифр 1-ой осн.болезни
  MKOD_DIAG2  := human->KOD_DIAG2     // шифр 2-ой осн.болезни
  MKOD_DIAG3  := human->KOD_DIAG3     // шифр 3-ой осн.болезни
  mNAR_Z      := human->nar_z         // номер наряда-заказа
  mDATA       := human->Data          // дата наряда-заказа
  M1LPU       := human->LPU           // код учреждения
  M1OTD       := human->OTD           // код отделения
  mUCH_DOC    := human->uch_doc       // вид и номер учетного документа
  mKOD_VR     := human->kod_vr        // код врача
  mKOD_AS     := human->kod_as        // код зубного техника
  MN_DATA     := human->N_DATA        // дата начала лечения
  MK_DATA     := human->K_DATA        // дата окончания лечения
  mKOL_POS    := human->kol_pos       // количество посещений
  M1PRICH     := human->PRICH_POL     // причина поломки протеза
  MKOL_MOSTP  := human->KOL_MOSTP     // количество мостовидных протезов
  MKOL_CELNL  := human->KOL_CELNL     // в т.ч. цельнолитых
  MCENA       := human->CENA          // стоимость лечения
  MCENA_OPL   := human->CENA_OPL      // сумма оплаты
  mkod_kart   := human->kod_k         // код в картотеке
  m1tip_usl   := human->tip_usl
  mn_och      := human->n_och
  mprim       := human->prim
  mkod_human  := human->( RecNo() )
  mst_summa   := srub_kop( MCENA, .t. )  // 16.04.08
  mplat_fio   := human->plat_fio
  mplat_inn   := human->plat_inn
  //
  r_use( dir_server() + "hum_orpl", dir_server() + "hum_orpl", "KPLAT" )
  find ( Str( human->( RecNo() ), 7 ) )
  If Found()
    mplat_adres   := KPLAT->ADRES
    mplat_pasport := KPLAT->PASPORT
  Endif
  KPLAT->( dbCloseArea() )
  //
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( mkod_kart )
  muchast     := kart->uchast
  mfio        := kart->fio           // фио
  m1fio       := kart->fio
  madres      := kart->adres         // адрес
  mmr_dol     := kart->mr_dol        // место работы должность
  mdate_r     := kart->date_r        // дата рождения
  If !Empty( kart->SNILS )
//    msnils := Transform( kart->SNILS, picture_pf )
    msnils := Transform_SNILS( kart->SNILS )
  Endif
  // Номер карты
  lnomer := l1nomer := lstr( kart->kod )
  If is_uchastok == 1
    If !emptyall( kart->bukva, kart->uchast, kart->kod_vu )
      lnomer := ''
      If !Empty( kart->bukva )
        lnomer += kart->bukva
      Endif
      lnomer += lstr( kart->uchast, 2 )
      If kart->kod_vu > 0
        lnomer += '/' + lstr( kart->kod_vu )
      Endif
      l1nomer := lnomer
    Endif
  Elseif eq_any( is_uchastok, 2, 3 )
    If !emptyall( kart->bukva, kart->uchast )
      luchast := ' [уч-к '
      If !Empty( kart->bukva )
        luchast += kart->bukva
      Endif
      luchast += lstr( kart->uchast, 2 )
      luchast += '] '
    Endif
    If is_uchastok == 3
      luchast += AllTrim( kart2->kod_AK )
    Endif
  Endif
  mlnomer := lnomer + luchast
  kart->( dbCloseArea() )
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( mkod_kart )
  m1vid_ud := kart_->vid_ud
  mnom     := kart_->nom_ud
  mser     := kart_->ser_ud
  mphone_m := kart_->phone_m
  okato_adresg := ret_okato_ulica( "", kart_->okatog, 1, 2 )
  okato_adresr := ret_okato_ulica( "", kart_->okatop, 1, 2 )
  kart_->( dbCloseArea() )
  mphone_m := transformphone( mphone_m )
  //
  r_use( dir_server() + "mo_pers",, "PERSO" )
  Goto ( mkod_vr )
  mvrach := PadR( perso->fio, 35 )
  mtabn_vr := perso->tab_nom
  Goto ( mkod_as )
  massist := PadR( perso->fio, 35 )
  mtabn_as := perso->tab_nom
  perso->( dbCloseArea() )
  //
  mtip_usl := inieditspr( A__MENUVERT, menu_okb, m1tip_usl )
  mlpu := inieditspr( A__POPUPMENU, dir_server() + "mo_uch", m1lpu )
  motd := inieditspr( A__POPUPMENU, dir_server() + "mo_otd", m1otd )
  mprich := inieditspr( A__POPUPMENU, dir_server() + "ort_brk", m1prich )
  mvid_ud := get_name_vid_ud( m1vid_ud )
  If Empty( mser ) ; mser := Space( 10 ) ; Endif
  If Empty( mnom ) ; mnom := Space( 10 ) ; Endif
  // mkod_kart := lstr(mkod_kart)
  // mNAR_Z    := lstr(mNAR_Z)
  r_use( dir_server() + "uslugi",, "USL" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  adbf := dbStruct()
  AAdd( adbf, { "date_u1", "D", 8, 0 } )
  AAdd( adbf, { "shifr_u", "C", 10, 0 } )
  AAdd( adbf, { "name_u", "C", 65, 0 } )
  AAdd( adbf, { "full_name", "C", 255, 0 } )
  AAdd( adbf, { "number", "N", 3, 0 } )
  AAdd( adbf, { "rec_hu", "N", 7, 0 } )
  dbCreate( cur_dir() + "tmp_usl", adbf )
  Use ( cur_dir() + "tmp_usl" ) New Alias tmp
  If mem_ordusl == 1
    Index On DToS( date_u1 ) + fsort_usl( shifr_u ) to ( cur_dir() + "tmp_usl" )
  Else
    Index On fsort_usl( shifr_u ) + DToS( date_u1 ) to ( cur_dir() + "tmp_usl" )
  Endif
  Select HU
  Set Relation To u_kod into USL
  find ( Str( mkod_human, 7 ) )
  If ( fl_found := Found() )
    adbf := Array( FCount() )
    Do While hu->kod == mkod_human .and. !Eof()
      AEval( adbf, {| x, i| adbf[ i ] := FieldGet( i ) } )
      Select TMP
      Append Blank
      AEval( adbf, {| x, i| FieldPut( i, x ) } )
      tmp->date_u1 := c4tod( hu->date_u )
      tmp->shifr_u := usl->shifr
      tmp->name_u := usl->name
      tmp->full_name := usl->full_name
      tmp->rec_hu := hu->( RecNo() )
      Select HU
      Skip
    Enddo
  Endif
  usl->( dbCloseArea() )
  //
  // МАТЕРИАЛЫ
  //
  // Local arr, sh, HH := 58, s, s1, s2, s3, fl,;
  // begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_mt.txt",;
  // tip_tit, s4
  // Local reg, reg1, mperso, musluga, mkod
  // Local msl1usluga, msl2usluga, l_delen, mslusluga

  dbCreate( cur_dir() + "tmp11", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )
  dbCreate( cur_dir() + "tmp12", { ;
    { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
  { "tname",      "C",     80,      0 } ;  // стоимость лечения
  } )
  Use ( cur_dir() + "tmp12" ) new
  Use ( cur_dir() + "tmp11" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp11" )
  r_use( dir_server() + "tip_orto",, "ORT" )
  r_use( dir_server() + "ortoped",, "OR" )
  r_use( dir_server() + "ortoped1",, "OR1" )
  r_use( dir_server() + "ortoped2",, "OR2" )
  //
  Select HU
  find ( Str( mkod_human, 7 ) )
  Do While hu->kod == mkod_human .and. !Eof()
    Select TMP11
    find ( Str( hu->u_kod, 4 ) )
    If !Found()
      Append Blank
      tmp11->kod := hu->u_kod
    Endif
    tmp11->kol += hu->kol
    Select HU
    Skip
  Enddo
  // пересчет в материал
  arr_mt := {}
  Select TMP11
  Go Top
  Do While !Eof()
    Select OR2
    Go Top
    Locate For or2->kod_usl == tmp11->kod
    If Found()
      t := or2->kod_tip
      Select ORT
      Goto t
      If ort->tip == 0 // техники
        Select OR1
        Go Top
        Do While !Eof()
          If or1->kod_menu == t
            If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
              AAdd( arr_mt, { or1->kod_ort, 0, 0, "" } ) ; k := Len( arr_mt )
            Endif
            arr_mt[ k, 2 ] += tmp11->kol
            arr_mt[ k, 3 ] += or1->massa * tmp11->kol
          Endif
          Select OR1
          Skip
        Enddo
      Endif
    Endif
    Select TMP11
    Skip
  Enddo
  // присваиваем наименование
  If Len( arr_mt ) > 0
    Select OR
    For i := 1 To Len( arr_mt )
      Goto ( arr_mt[ i, 1 ] )
      arr_mt[ i, 4 ] := or->name
    Next
    Select TMP12
    Append Blank
    tmp12->tname := "   ТЕХНИК"
    Select OR
    For i := 1 To Len( arr_mt )
      If arr_mt[ i, 3 ] > 0
        Select TMP12
        Append Blank
        tmp12->tname := arr_mt[ i, 4 ]
        tmp12->kol   := arr_mt[ i, 3 ]
        Select OR
      Endif
    Next
  Endif
  //
  // Итого по техникам
  //
  Select TMP11
  Zap
  // my_debug(,print_array(arr_mt))
  // пересчет в материал
  Select HU
  find ( Str( mkod_human, 7 ) )
  Do While hu->kod == mkod_human .and. !Eof()
    Select TMP11
    find ( Str( hu->u_kod, 4 ) )
    If !Found()
      Append Blank
      tmp11->kod := hu->u_kod
    Endif
    tmp11->kol += hu->kol
    Select HU
    Skip
  Enddo

  // пересчет в материал
  arr_mt := {}
  Select TMP11
  Go Top
  Do While !Eof()
    Select OR2
    Go Top
    Locate For or2->kod_usl == tmp11->kod
    If Found()
      t := or2->kod_tip
      Select ORT
      Goto t
      If ort->tip == 1 // врачи
        Select OR1
        Go Top
        Do While !Eof()
          If or1->kod_menu == t
            If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
              AAdd( arr_mt, { or1->kod_ort, 0, 0, "" } ) ; k := Len( arr_mt )
            Endif
            arr_mt[ k, 2 ] += tmp11->kol
            arr_mt[ k, 3 ] += or1->massa * tmp11->kol
          Endif
          Select OR1
          Skip
        Enddo
      Endif
    Endif
    Select TMP11
    Skip
  Enddo
  // присваиваем наименование
  // my_debug(,print_array(arr_mt))
  If Len( arr_mt ) > 0
    Select OR
    For i := 1 To Len( arr_mt )
      Goto ( arr_mt[ i, 1 ] )
      arr_mt[ i, 4 ] := or->name
    Next
    Select TMP12
    Append Blank
    tmp12->tname := "   ВРАЧ"
    Select OR
    For i := 1 To Len( arr_mt )
      If arr_mt[ i, 3 ] > 0
        Select TMP12
        Append Blank
        tmp12->tname := arr_mt[ i, 4 ]
        tmp12->kol   := arr_mt[ i, 3 ]
        Select OR
      Endif
    Next
    add_string( "" )
  Endif
  //
  tmp11->( dbCloseArea() )
  hu->( dbCloseArea() )
  //
  orto_list_uch( tip_print )
  rest_box( buf )
  Close databases
  Return Nil

//
Function orto_list_uch( tip_print )

  Local sh := 80, HH := 55, buf := save_row( MaxRow() ), regim_print := 2
  Local i := 1, j, k, tmp[ 2 ], tmp1, w1 := 65, s, fl, rec
  Local n_file := cur_dir() + "narad.txt", arr, mfam1, mima1, mots1, m1vid_ud

  If tip_print == 1
    If !Empty( file_sh1 )
      f1_pr_shab( file_sh1 )
    Endif
  Else
    Private file_sh
    If !Empty( mem_ort_dog ) .and. ;
        !Empty( file_sh := menu_shablon( 3, 3, dir_exe() + "*." + AllTrim( mem_ort_dog ), color8, .f. ) )
      Select TMP
      Go Top
      f1_pr_shab( file_sh )
    Endif
  Endif
  Return Nil

// поиск свободного номера наряда (на 1 больше максимального)
Function poisk_svob()

  Local myear, buf := save_maxrow(), arr, mvar := ReadVar(), ;
    psvob := 0, REC, i, old_plat := mnar_z, vr_sel, rec1, ;
    nrow := Row(), ncol := Col(), icurs := SetCursor( 0 ), index_ord

  Save gets To arr
  If ( myear := input_value( 18, 2, 20, 77, cColorStMsg, ;
      Space( 11 ) + "По какому году искать свободный номер наряда", ;
      Year( sys_date ), "9999" ) ) != NIL
    mywait()
    rec := RecNo()
    vr_sel := Select()
    Select HUMAN
    rec1 := RecNo()
    index_ord := IndexOrd()
    Set Order To 4
    dbSeek ( DToS( BoY( mdata ) ), .t. )
    Do While !Eof()
      If m1tip_usl == human->tip_usl
        psvob := Max( psvob, human->nar_z )
      Endif
      Skip
    Enddo
    Set Order To index_ord
    Goto ( rec1 )
    Select( vr_sel )
    Goto ( rec )
    rest_box( buf )
    If psvob == 999999
      n_message( { "В " + lstr( myear ) + " году максимальный номер наряда - 999999.", ;
        "В принципе невозможно для одной организации за год" }, ;
        { "Нажмите любую клавишу" }, cColorStMsg, cColorStMsg, 17,, "BG+/R" )
      myear := NIL
    Else
      ++psvob
      If !Empty( old_plat )
        n_message( { "В " + lstr( myear ) + " году свободный номер наряда - " + lstr( psvob ) + "." },, ;
          cColorStMsg, cColorStMsg, 17,, "BG+/R" )
      Endif
    Endif
  Endif
  Restore gets From arr
  If myear != Nil .and. Empty( mnar_z ) .and. ;
      f_message( { "В " + lstr( myear ) + " году свободный номер наряда - " + lstr( psvob ) + ".", ;
      "При нажатии <Enter> это значение будет скопировано в поле ввода.", ;
      "<Esc> - отказ от копирования." }, "W", ;
      cColorStMsg, cColorStMsg, 17 ) == K_ENTER
    mnar_z := psvob
    update_get( "mnar_z" )
  Endif
  @ nrow, ncol Say ""
  If icurs != 0
    SetCursor()
  Endif
  Return Nil

//
Function input_uchast()

  Local such := 0
  Local nuch, fl := .f.

  If ( nuch := input_value( 18, 10, 20, 69, color0, ;
      Space( 16 ) + "Введите номер участка", ;
      such, "99" ) ) != Nil .and. nuch >= 0
    such := nuch ; fl := .t.
  Endif
  Return iif( fl, nuch, NIL )

// 26.12.19
Function ret_uchast( r, c )

  Static si1 := 1, such := 0
  Local mas_pmt, mas_msg, j, arr := {}, luch := "", s, i, k, k1, k2

  If is_uchastok > 0
    mas_pmt := { "По ~всем пациентам", ;
      "По одному ~участку", ;
      "По ~прикрепленным участкам" }
    mas_msg := { "Распечатка формы по всем пациентам", ;
      "Распечатка формы по пациентам конкретного участка", ;
      "Распечатка формы по прикрепленной территории" }
    arr := nil
    If ( j := popup_prompt( r, c, si1, mas_pmt, mas_msg ) ) > 0
      si1 := j
      If j == 1
        arr := {}
      Elseif j == 2
        If ( luch := input_value( 20, 15, 22, 64, color1, ;
            Space( 10 ) + "Введите номер участка", ;
            such, "99" ) ) != Nil .and. luch >= 0
          arr := { luch } ; such := luch
        Endif
      Elseif j == 3
        If hb_FileExists( file_uchast() )
          luch := FileStr( file_uchast() )
        Endif
        If ( luch := input_value( 20, 2, 22, 77, color1, ;
            "Прикрепленные участки (напр.: 1-20,23)", ;
            PadR( luch, 100 ), "@S34" ) ) != Nil .and. !Empty( luch )
          arr := {}
          For i := 1 To NumToken( luch, "," )
            s := Token( luch, ",", i )
            If "-" $ s
              k1 := Int( Val( Token( s, "-", 1 ) ) )
              k2 := Int( Val( Token( s, "-", 2 ) ) )
              For k := k1 To k2
                If k > 0
                  AAdd( arr, k )
                Endif
              Next
            Else
              k := Int( Val( s ) )
              If k > 0
                AAdd( arr, k )
              Endif
            Endif
          Next
          If Len( arr ) == 0
            arr := nil
            func_error( 4, "Некорректно введен список прикрепленных участков." )
          Else
            StrFile( AllTrim( luch ), file_uchast() )
          Endif
        Endif
      Endif
    Endif
  Endif
  Return arr

//
Function get_uchast( r, c )

  // должен быть определен "Private arr_uchast := {}"
  Local k := ret_uchast( r, c )
  If k == NIL
    arr_uchast := {}
    r := 0
  Else
    arr_uchast := AClone( k )
    r := iif( Len( k ) == 0, 0, 1 )
  Endif
  Return { r, init_uchast( arr_uchast ) }

//
Function init_uchast( arr )

  Local i, s := "все пациенты"

  If ValType( arr ) == "A" .and. Len( arr ) > 0
    If Len( arr ) == 1
      s := "№ " + lstr( arr[ 1 ] )
    Else
      If hb_FileExists( file_uchast() )
        s := FileStr( file_uchast() )
      Else
        s := ""
        For i := 1 To Len( arr )
          s += lstr( arr[ i ] ) + ","
        Next
        s := Left( s, Len( s ) -1 )
      Endif
    Endif
  Endif
  Return s

//
Function f_is_uchast( st_a_uchast, luch )

  Local fl := .t.

  If Len( st_a_uchast ) > 0
    fl := ( AScan( st_a_uchast, luch ) > 0 )
  Endif
  Return fl

//
Function title_uchast( st_a_uchast, sh )

  If st_a_uchast != Nil .and. Len( st_a_uchast ) > 0
    If Len( st_a_uchast ) == 1
      add_string( Center( "[ по участку номер " + lstr( st_a_uchast[ 1 ] ) + " ]", sh ) )
    Else
      add_string( Center( "[ по прикрепленной территории ]", sh ) )
    Endif
  Endif
  Return Nil

// 05.09.18
Function ort_nar_material()

  Local arr, sh, HH := 58, s, s1, s2, s3, fl, ;
    begin_date, end_date, fl_exit := .f., name_file := cur_dir() + "orto_mt.txt", ;
    tip_tit, s4, ;
    arr_title := { ;
    "────────────────────────────────────────────────────────────┬──────────────", ;
    "                    Наименование материала                  │    Расход    ", ;
    "────────────────────────────────────────────────────────────┴──────────────" }
  Local reg, reg1, mperso, musluga, mkod, buf := save_row( MaxRow() )
  Local msl1usluga, msl2usluga, l_delen, mslusluga

  waitstatus( "<Esc> - прервать поиск" ) ; mark_keys( { "<Esc>" } )
  fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
  sh := Len( arr_title[ 1 ] )
  add_string( "" )
  add_string( Center( "Предварительный Расход материалов", sh ) )
  add_string( "" )

  dbCreate( cur_dir() + "tmp", { ;
    { "KOD",        "N",      4,      0 }, ;  // код (услуги)
  { "KOL",        "N",     10,      3 }, ;  // кол-во услуг
  { "STOIM",      "N",     14,      2 } ;  // стоимость лечения
  } )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod, 4 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "tip_orto",, "ORT" )
  r_use( dir_server() + "ortoped",, "OR" )
  r_use( dir_server() + "ortoped1",, "OR1" )
  r_use( dir_server() + "ortoped2",, "OR2" )
  r_use( dir_server() + "hum_oru", dir_server() + "hum_oru", "HU" )
  //
  Select HU
  find ( Str( human->( RecNo() ), 7 ) )
  Do While hu->kod == human->( RecNo() ) .and. !Eof()
    Select TMP
    find ( Str( hu->u_kod, 4 ) )
    If !Found()
      Append Blank
      tmp->kod := hu->u_kod
    Endif
    tmp->kol += hu->kol
    Select HU
    Skip
  Enddo
  Select HUMAN
  Skip
  // пересчет в материал
  arr_mt := {}
  Select TMP
  Go Top
  Do While !Eof()
    Select OR2
    Go Top
    Locate For or2->kod_usl == tmp->kod
    If Found()
      t := or2->kod_tip
      Select ORT
      Goto t
      If ort->tip == 0 // техники
        Select OR1
        Go Top
        Do While !Eof()
          If or1->kod_menu == t
            If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
              AAdd( arr_mt, { or1->kod_ort, 0, 0, "" } ) ; k := Len( arr_mt )
            Endif
            arr_mt[ k, 2 ] += tmp->kol
            arr_mt[ k, 3 ] += or1->massa * tmp->kol
          Endif
          Select OR1
          Skip
        Enddo
      Endif
    Endif
    Select TMP
    Skip
  Enddo
  // присваиваем наименование
  If Len( arr_mt ) > 0
    Select OR
    For i := 1 To Len( arr_mt )
      Goto ( arr_mt[ i, 1 ] )
      arr_mt[ i, 4 ] := or->name
    Next
    add_string( "   ТЕХНИК" )
    AEval( arr_title, {| x| add_string( x ) } )
    For i := 1 To Len( arr_mt )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If arr_mt[ i, 3 ] > 0
        add_string( PadR( arr_mt[ i, 4 ], 60 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
      Endif
    Next
    add_string( "" )
  Endif
  //
  // Итого по техникам
  // пересчет в материал
  Select HU
  find ( Str( human->( RecNo() ), 7 ) )
  Do While hu->kod == human->( RecNo() ) .and. !Eof()
    Select TMP
    find ( Str( hu->u_kod, 4 ) )
    If !Found()
      Append Blank
      tmp->kod := hu->u_kod
    Endif
    tmp->kol += hu->kol
    Select HU
    Skip
  Enddo
  Select HUMAN
  Skip
  // пересчет в материал
  arr_mt := {}
  Select TMP
  Go Top
  Do While !Eof()
    Select OR2
    Go Top
    Locate For or2->kod_usl == tmp->kod
    If Found()
      t := or2->kod_tip
      Select ORT
      Goto t
      If ort->tip == 1 // врачи
        Select OR1
        Go Top
        Do While !Eof()
          If or1->kod_menu == t
            If ( k := AScan( arr_mt, {| x| x[ 1 ] == or1->kod_ort } ) ) == 0
              AAdd( arr_mt, { or1->kod_ort, 0, 0, "" } ) ; k := Len( arr_mt )
            Endif
            arr_mt[ k, 2 ] += tmp->kol
            arr_mt[ k, 3 ] += or1->massa * tmp->kol
          Endif
          Select OR1
          Skip
        Enddo
      Endif
    Endif
    Select TMP
    Skip
  Enddo
  // присваиваем наименование
  If Len( arr_mt ) > 0
    Select OR
    For i := 1 To Len( arr_mt )
      Goto ( arr_mt[ i, 1 ] )
      arr_mt[ i, 4 ] := or->name
    Next
    add_string( "   ВРАЧ" )
    AEval( arr_title, {| x| add_string( x ) } )
    For i := 1 To Len( arr_mt )
      If verify_ff( HH, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      If arr_mt[ i, 3 ] > 0
        add_string( PadR( arr_mt[ i, 4 ], 60 ) + " " + umest_val( arr_mt[ i, 3 ], 12, 3 ) )
      Endif
    Next
    add_string( "" )
  Endif
  //
  Close databases
  FClose( fp )
  rest_box( buf )
  If !fl_exit
    viewtext( name_file )
  Endif
  Return Nil

//
Function verify_o_uva( reg )

  Local i

  Default reg To 1
  If Len( arr_uva ) > 0 .and. ;
      ( i := AScan( arr_uva, {| x| Like( x[ 1 ], AllTrim( mshifr ) ) } ) ) > 0
    If arr_uva[ i, 2 ] == 1
      vr_uva := .f.
      mkod_vr := 0 ; mvrach := Space( 35 )
      mtabn_vr := 0
    Endif
    If arr_uva[ i, 3 ] == 1
      as_uva := .f.
      mkod_as := 0 ; massist := Space( 35 )
      mtabn_as := 0
    Endif
    If arr_uva[ i, 4 ] == 1
      ms_uva := .f.
      mkod_ms := 0 ; mmedses := Space( 35 )
      mtabn_ms := 0
    Endif
  Endif
  Return Nil
