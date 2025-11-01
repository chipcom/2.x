#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 05.01.16
Function edit_bolnich( par )

  Local arr_m, buf := SaveScreen(), mkod := 0, fl := .f., mtitul, ;
    arr_blk, fl_schet := .f., str_error := "Не найдено нужных записей!"

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  Private begin_date := arr_m[ 5 ], end_date := arr_m[ 6 ], pr_regim := par
  Private mr1 := 2
  mtitul := "Окончившие лечение " + arr_m[ 4 ]
  mywait()
  r_use( dir_server() + "mo_otd",, "OTD" )
  r_use( dir_server() + "mo_uch",, "UCH" )
  g_use( dir_server() + "human_",, "HUMAN_" )
  g_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To lpu into UCH, To otd into OTD
  dbSeek( DToS( begin_date ), .t. )
  Index On Upper( fio ) + DToS( k_data ) to ( cur_dir() + "tmp_h" ) ;
    For human_->oplata < 9 .and. !Between( ishod, 101, 305 ) ;
    While k_data <= end_date
  Go Top
  If Eof()
    func_error( 4, str_error )
  Else
    alpha_browse( mr1, 2, MaxRow() -2, 77, "f1_e_boln", color0, mtitul, "W+/GR",, .t., arr_blk,, "f2_e_boln",, ;
      { '═', '░', '═', "N/BG,W+/N,B/BG,BG+/B", .t., 600 } )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

//
Function f1_e_boln( oBrow )

  Local oColumn, blk := {|| if( human->bolnich > 0, { 3, 4 }, { 1, 2 } ) }, r := 29

  //
  oColumn := TBColumnNew( Center( "ФИО пациента", r ), {|| Left( human->fio, r ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  If yes_bukva // если в настройке - работа со статусом стом.больного
    oColumn := TBColumnNew( "Стом.", {|| Left( human_->STATUS_ST, 5 ) } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Else
    oColumn := TBColumnNew( " Учр.", {|| uch->short_name } )
    oColumn:colorBlock := blk
    oBrow:addcolumn( oColumn )
  Endif
  oColumn := TBColumnNew( " Отд.", {|| otd->short_name } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Диаг-;ноз", {|| human->kod_diag } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( " Начало;лечения", {|| date_8( human->n_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Окончан.;лечения", {|| date_8( human->k_data ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( "Больнич-;  ный", ;
    {|| PadC( if( human->bolnich > 0, "есть", "" ), 8 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( "^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<F2>^ - поиск" )

  Return Nil

//
Function f2_e_boln( nkey )

  Static menu_bolnich := { { "нет", 0 }, { "да ", 1 }, { "РОД", 2 } }
  Static tmp := " "
  Local buf := SaveScreen(), buf1, rec1 := RecNo(), fl := -1, r1, ;
    c, i, j, arr, mtitul, bg := {| o, k| get_without_input( o, k, .t. ) }
  Private tmp1

  If nkey == K_ENTER
    Private is_talon := .t.
    Private ;
      mn_data := human->n_data, ;
      mk_data := human->k_data, ;
      mpol := human->pol, ;
      M1VZROS_REB := human->VZROS_REB, ;    // 0-взрослый, 1-ребенок, 2-подросток
    mstatus_st  := human_->STATUS_ST, ;
      MKOD_DIAG  := human->KOD_DIAG, ;     // шифр 1-ой осн.болезни
      MKOD_DIAG2 := human->KOD_DIAG2, ;     // шифр 2-ой осн.болезни
    MKOD_DIAG3 := human->KOD_DIAG3, ;     // шифр 3-ой осн.болезни
      MKOD_DIAG4 := human->KOD_DIAG4, ;     // шифр 4-ой осн.болезни
    msoput_b1  := human->soput_b1, ;
      msoput_b2  := human->soput_b2, ;
      msoput_b3  := human->soput_b3, ;
      msoput_b4  := human->soput_b4, ;
      mdiag_plus := human->diag_plus, ;
      m1povod    := human_->POVOD, ;
      m1travma   := human_->TRAVMA, ;
      adiag_talon[ 16 ], ; // из статталона к диагнозам
    MBOLNICH, m1bolnich := human->bolnich, ; // больничный
    mdate_b_1 := c4tod( human->date_b_1 ), ; // дата начала больничного
    mdate_b_2 := c4tod( human->date_b_2 ), ; // дата окончания больничного
    mrodit_dr  := CToD( "" ), ; // дата рождения родителя
    mrodit_pol := " ", ; // пол родителя
    gl_area := { r1, 0, 23, 79, 0 }
    If m1bolnich == 2
      mrodit_dr  := human_->RODIT_DR
      mrodit_pol := human_->RODIT_POL
    Endif
    mbolnich := inieditspr( A__MENUVERT, menu_bolnich, m1bolnich )
    make_diagp( 1 )  // сделать "шестизначные" диагнозы
    AFill( adiag_talon, 0 )
    For i := 1 To 16
      adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
    Next
    Private mpovod  := inieditspr( A__MENUVERT, stm_povod, m1povod )
    Private mtravma := inieditspr( A__MENUVERT, stm_travma, m1travma )
    Private row_dop_diag := 7
    //
    mtitul := "Редактирование " + { "больничного", "стат.талона" }[ pr_regim ]
    box_shadow( 10, 0, 21, 79, color1, mtitul, color8 )
    SetColor( cDataCGet )
    @ 11, 1 Say "Вид и номер учетного документа: "
    @ Row(), Col() Say human->UCH_DOC Color "G+/B"
    @ 12, 1 Say "Ф.И.О.: "
    @ Row(), Col() Say human->fio Color "G+/B"
    @ 13, 1  Say "Дата рождения: "
    @ Row(), Col() Say human->DATE_R Color "G+/B"
    @ 14, 1 Say "Срок лечения с "
    @ Row(), Col() Say full_date( human->n_data ) Color color8
    @ Row(), Col() Say " по "
    @ Row(), Col() Say full_date( human->k_data ) Color color8
    If yes_bukva // если в настройке для отделения - работа со статусом стом.больного
      @ 15, 34 Say "Статус стоматологического больного" Get mstatus_st Picture "@!" ;
        valid {| g| f_valid_status_st( g ) }
    Endif
    If pr_regim == 1
      @ 16, 1 Say "Основной диагноз" Get mkod_diag When .f.
      @ 18, 1 Say "Больничный" Get mbolnich ;
        reader {| x| menu_reader( x, menu_bolnich, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_bolnich( g, o ) }
      @ Row(), Col() + 1 Say "==> с" Get mdate_b_1 When m1bolnich > 0
      @ Row(), Col() + 1 Say "по" Get mdate_b_2 When m1bolnich > 0
      @ Row(), Col() + 1 Say "Д.р.родителя" Get mrodit_dr When m1bolnich == 2
      If mem_pol == 1
        @ Row(), Col() + 1 Say "Пол" Get mrodit_pol ;
          reader {| x| menu_reader( x, menupol, A__MENUVERT,,, .f. ) } ;
          When m1bolnich == 2
      Else
        @ Row(), Col() + 1 Say "Пол" Get mrodit_pol Pict "@!" ;
          valid {| g| mrodit_pol $ "МЖ" } ;
          When m1bolnich == 2
      Endif
    Else
      @ 16, 1 Say "Основной диагноз       " Get mkod_diag  reader {| o| mygetreader( o, bg ) } When when_diag()
      @ 17, 1 Say "Сопутствующие диагнозы " Get mkod_diag2 reader {| o| mygetreader( o, bg ) } When when_diag()
      @ Row(), Col() Say ","                Get mkod_diag3 reader {| o| mygetreader( o, bg ) } When when_diag()
      @ Row(), Col() Say ","                Get mkod_diag4 reader {| o| mygetreader( o, bg ) } When when_diag()
      @ Row(), Col() Say ","                Get msoput_b1  reader {| o| mygetreader( o, bg ) } When when_diag()
      @ Row(), Col() Say ","                Get msoput_b2  reader {| o| mygetreader( o, bg ) } When when_diag()
      @ Row(), Col() Say ","                Get msoput_b3  reader {| o| mygetreader( o, bg ) } When when_diag()
      @ Row(), Col() Say ","                Get msoput_b4  reader {| o| mygetreader( o, bg ) } When when_diag()
      If mem_st_pov == 1
        @ 18, 1 Say "Повод обращения" Get mpovod ;
          reader {| x| menu_reader( x, stm_povod, A__MENUVERT,,, .f. ) }
      Else
        @ 18, 1 Say "Повод обращения" Get m1povod Pict "9" ;
          valid {| g| val_st_pov( g ) }
        @ Row(), Col() + 1 Get mpovod Color color14 When .f.
      Endif
      If .t. // is_travma // если в настройке для отделения - работа с травмой
        If mem_st_trav == 1
          @ 18, 43 Say "Вид травмы" Get mtravma ;
            reader {| x| menu_reader( x, stm_travma, A__MENUVERT,,, .f. ) }
        Else
          @ 18, 43 Say "Вид травмы" Get m1travma Pict "99" ;
            valid {| g| val_st_trav( g ) }
          @ Row(), Col() + 1 Get mtravma Color color14 When .f.
        Endif
      Endif
      put_dop_diag()
      Set Key K_F10 To inp_dop_diag
    Endif
    status_key( "^<Esc>^ - выход;  ^<PgDn>^ - запись" + iif( pr_regim == 2, ";  ^<F10>^ - доп.информация к диагнозу", "" ) )
    myread()
    If pr_regim == 2
      Set Key K_F10 To
    Endif
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      make_diagp( 2 )  // сделать "пятизначные" диагнозы
      Select HUMAN_
      g_rlock( forever )
      Select HUMAN
      g_rlock( forever )
      human_->STATUS_ST := LTrim( MSTATUS_ST )
      If pr_regim == 1
        human->bolnich    := m1bolnich
        human->date_b_1   := iif( m1bolnich == 0, "", dtoc4( mdate_b_1 ) )
        human->date_b_2   := iif( m1bolnich == 0, "", dtoc4( mdate_b_2 ) )
        human_->RODIT_DR  := iif( m1bolnich < 2, CToD( "" ), mrodit_dr )
        human_->RODIT_POL := iif( m1bolnich < 2, "", mrodit_pol )
      Else
        s := "" ; AEval( adiag_talon, {| x| s += Str( x, 1 ) } )
        human_->DISPANS := s
        human_->POVOD   := m1povod
        human_->TRAVMA  := m1travma
      Endif
      /*replace ;       т.е. диагнозы запрещено изменять
         human->KOD_DIAG  with MKOD_DIAG  , ;   // шифр 1-ой осн.болезни
         human->KOD_DIAG2 with MKOD_DIAG2 , ;   // шифр 2-ой осн.болезни
         human->KOD_DIAG3 with MKOD_DIAG3 , ;   // шифр 3-ой осн.болезни
         human->KOD_DIAG4 with MKOD_DIAG4 , ;   // шифр 4-ой осн.болезни
         human->SOPUT_B1  with MSOPUT_B1  , ;   // шифр 1-ой сопутствующей болезни
         human->SOPUT_B2  with MSOPUT_B2  , ;   // шифр 2-ой сопутствующей болезни
         human->SOPUT_B3  with MSOPUT_B3  , ;   // шифр 3-ой сопутствующей болезни
         human->SOPUT_B4  with MSOPUT_B4  , ;   // шифр 4-ой сопутствующей болезни
         human->diag_plus with mdiag_plus
      */
      Unlock
      Commit
    Endif
    Select HUMAN
    SetColor( color0 )
    RestScreen( buf )
    Return -1
  Endif
  If nkey != K_F2
    Return -1
  Endif
  buf1 := SaveScreen( 13, 4, 19, 77 )
  Do While .t.
    tmp1 := PadR( tmp, 50 )
    SetColor( color8 )
    box_shadow( 13, 14, 18, 67 )
    @ 15, 15 Say Center( " Введите шаблон для поиска фамилий", 52 )
    status_key( "^<Esc>^ - отказ от ввода;  ^<F1>^ - помощь" )
    @ 16, 16 Get tmp1 Picture "@K@!"
    myread()
    SetColor( color0 )
    If LastKey() == K_ESC .or. Empty( tmp1 )
      Exit
    Endif
    mywait()
    tmp := AllTrim( tmp1 )
    i := 0
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, ;
      k2 := 21, tmp2 := Upper( tmp ), ch := Left( tmp, 1 )
    If !( ch == "*" .or. ch == "?" )
      tmp1 := tmp2
      If "*" $ tmp1 ; tmp1 := BeforAtNum( "*", tmp1, 1 ) ; Endif
      If "?" $ tmp1 ; tmp1 := BeforAtNum( "?", tmp1, 1 ) ; Endif
      If Len( tmp1 ) > 12 ; tmp1 := Left( tmp1, 12 ) ; Endif
      ch := Len( tmp1 )
      find ( tmp1 )
      Do While tmp1 == Left( Upper( fio ), ch ) .and. !Eof()
        If Like( tmp2, Upper( fio ) )
          If++i > 4000 ; exit ; Endif
          AAdd( tmp_mas, human->fio ) ; AAdd( tmp_kod, human->( RecNo() ) )
        Endif
        Skip
      Enddo
    Else
      Go Top
      Do While !Eof()
        If Like( tmp2, Upper( fio ) )
          If++i > 4000 ; exit ; Endif
          AAdd( tmp_mas, human->fio ) ; AAdd( tmp_kod, human->( RecNo() ) )
        Endif
        Skip
      Enddo
    Endif
    If ( t_len := Len( tmp_kod ) ) = 0
      stat_msg( "Не найдено ни одной записи, удовлетворяющей данному шаблону!" )
      mybell( 2, ERR )
      RestScreen( 13, 4, 19, 77, buf1 )
      Loop
    Else
      box_shadow( mr1, 2, 22, 77 )
      SetColor( col_tit_popup )
      @ k1 - 2, 15 Say "Шаблон: " + tmp2
      SetColor( color0 )
      If k1 + t_len + 2 < 21
        k2 := k1 + t_len + 2
      Endif
      @ k1, 3 Say Center( " Количество найденных фамилий - " + lstr( t_len ), 74 )
      status_key( "^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор" )
      If ( i := Popup( k1 + 1, 13, k2, 66, tmp_mas, i, color0 ) ) > 0
        Goto ( tmp_kod[ i ] )
        fl := 0
      Endif
      Exit
    Endif
  Enddo
  If fl == -1
    Goto rec1
  Endif
  RestScreen( buf )

  Return fl
