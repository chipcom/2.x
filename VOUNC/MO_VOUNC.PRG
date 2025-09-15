// реестры/счета 2019 года (и ВОУНЦ)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Function vounc_begin_task()

  Static n_zapusk := 0
  Local fl := .t.

  If n_zapusk == 0
    ++n_zapusk
    Public sem_vagno_VOUNC := 'Важный режим в задаче VOUNC', ;
      mm_tip_mnn := { ;
        { 'ингибитор кальцинейрина', 0 }, ;
        { 'микофенолат            ', 1 } ;
      }, ;
      mm_lf_lat := { { 'mg', 0 }, { 'mg/ml', 1 } }, ;
      mm_lf := { { 'мг   ', 0 }, { 'мг/мл', 1 } }
    vounc_sprav_nastr( 1 )
  Endif
  If g_sislock( sem_vagno_VOUNC )
    fl := func_error( 'В задаче выполняется важная операция. Доступ временно запрещён!' )
  Elseif copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
    vounc_tools_ini( 1, 0, 0 )
  Else
    fl := .f.
  Endif
  Return fl

//
Function vounc_input_nazn()

  Static si := 2
  Local arr, ret, buf, str_sem := 'vounc_input_nazn'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  Private ltip_mnn
  If polikl1_kart() > 0
    arr := AClone( mm_tip_mnn )
    AAdd( arr, { 'все назначения', 2 } )
    popup_2array( arr, T_ROW, T_COL + 5, si, 1, @ret, , , color5 )
    If ValType( ret ) == 'A'
      ltip_mnn := si := ret[ 2 ]
    Endif
    If ltip_mnn != NIL
      buf := SaveScreen()
      Private blk_open := {|| r_use( dir_server() + 'vouncmnn', , 'MNN' ), ;
        r_use( dir_server() + 'vounctrn', , 'TRN' ), ;
        dbSetRelation( 'MNN', {|| mnn }, 'mnn' ), ;
        g_use( dir_server() + 'vouncnaz', , 'NAZN' ), ;
        dbSetRelation( 'TRN', {|| tovar }, 'tovar' ) }
      Eval( blk_open )
      Index On Str( FIELD->kod_k, 7 ) + Str( Descend( FIELD->DATE_NAZ ), 10 ) to ( cur_dir() + 'tmp_nazn' )
      If ltip_mnn < 2
        Set Filter To mnn->tip_mnn == ltip_mnn
      Endif
      Private fl_found, str_find, muslovie
      str_find := Str( glob_kartotek, 7 )
      muslovie := 'nazn->kod_k == glob_kartotek'
      find ( str_find )
      fl_found := Found()
      arr_blk := { {|| findfirst( str_find ) }, ;
        {|| findlast( str_find ) }, ;
        {| n| skippointer( n, muslovie ) }, ;
        str_find, muslovie;
        }
      If !fl_found
        Keyboard Chr( K_INS )
      Endif
      alpha_browse( T_ROW, 0, 23, 79, 'f1_vounc_input_nazn', color0, glob_k_fio, 'BG+/GR', ;
        .f., .t., arr_blk, , 'f2_vounc_input_nazn', , ;
        { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B', .t., 180 } )
      Close databases
      RestScreen( buf )
    Endif
  Endif
  g_sunlock( str_sem )
  Return Nil

//
Function f1_vounc_input_nazn( oBrow )

  Local oColumn, blk := {|| iif( mnn->tip_mnn == 1, { 3, 4 }, { 1, 2 } ) }

  //
  oColumn := TBColumnNew( '   Дата;назначения', {|| full_date( nazn->date_naz ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'МКБ10', {|| nazn->kod_diag } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Назнач;кол-во', {|| put_val_0( nazn->KOL_NAZ, 6, 1 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Кол;уп.', {|| put_val( nazn->KOL_UP, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( ' Препарат', {|| PadR( trn->name, 30 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Дози-;ровка', {|| put_val_0( trn->doza, 6, 1 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Ед.;изм.', {|| iif( Empty( trn->name ), Space( 4 ), inieditspr( A__MENUVERT, mm_lf, trn->c_lf ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Кол.;в уп', {|| put_val( trn->n_lf, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  status_key( '^<Esc>^-выход; ^<Enter>^-редактирование; ^<Ins>^-добавление; ^<Del>^-удаление' )
  Return Nil

//
Function f2_vounc_input_nazn( nKey, oBrow )

  Local flag := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1, c1, bg := {| o, k| get_mkb10( o, k, .t. ) }

  Do Case
  Case ( nKey == K_ENTER .and. nazn->kod_k > 0 ) .or. nKey == K_INS
    rec := nazn->( RecNo() )
    Private mdate_naz := sys_date, mkod_diag := vounc_mem_diag, ;
      m1tovar := 0, mkol_naz := 0, mtovar, mkol_up := 1, ;
      gl_area := { 1, 0, 23, 79, 0 }
    If nKey == K_INS
      If fl_found
        Do While .t.
          If iif( ltip_mnn == 2, .t., mnn->tip_mnn == ltip_mnn )
            mkod_diag := nazn->kod_diag
            m1tovar   := nazn->tovar
            mkol_naz  := nazn->kol_naz
            mkol_up   := nazn->kol_up
            Exit
          Endif
          Skip
          If !&muslovie .or. Eof()
            Exit
          Endif
        Enddo
        Goto ( rec )
      Else
        ColorWin( T_ROW + 4, 0, T_ROW + 4, 79, 'N/N', 'W+/N' )
        ColorWin( T_ROW + 4, 0, T_ROW + 4, 79, 'N/N', 'BG+/B' )
      Endif
    Else // nKey == K_ENTER
      mdate_naz := nazn->date_naz
      mkod_diag := nazn->kod_diag
      m1tovar   := nazn->tovar
      mkol_naz  := nazn->kol_naz
      mkol_up   := nazn->kol_up
    Endif
    Close databases
    mtovar := vounc_ret_name_trn( m1tovar, 1, .t. )
    r1 := 14
    c1 := 2
    buf1 := box_shadow( r1, c1, 21, 77, color8, ;
      iif( nKey == K_INS, 'Добавление', 'Редактирование' ) + ' назначения', cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, c1 + 2 Say 'Дата назначения' Get mdate_naz
    @ r1 + 3, c1 + 2 Say 'Код заболевания (по МКБ-10)' Get mkod_diag Pict '@K@!' ;
      reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
    @ r1 + 4, c1 + 2 Say 'Назначаемый препарат' Get mtovar ;
      reader {| x| menu_reader( x, { {| k, r, c| vounc_get_tovar( k, r, c, ltip_mnn ) } }, A__FUNCTION, , , .f. ) }
    @ r1 + 5, c1 + 2 Say 'Количество назначенного препарата в сутки' Get mkol_naz Pict '9999.9'
    @ r1 + 6, c1 + 2 Say 'Количество упаковок в рецепте' Get mkol_up Pict '99'
    status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
    myread()
    Eval( blk_open )
    Set Index to ( cur_dir() + 'tmp_nazn' )
    Goto ( rec )
    If LastKey() != K_ESC .and. !emptyany( mdate_naz, mkod_diag, m1tovar, mkol_naz ) .and. f_esc_enter( 1 )
      fl_found := .t.
      If nKey == K_INS
        addrec( 7 )
        nazn->KOD_K := glob_kartotek
        rec := RecNo()
      Else
        g_rlock( forever )
      Endif
      nazn->DATE_NAZ := mdate_naz
      nazn->KOD_DIAG := mkod_diag
      nazn->TOVAR    := m1tovar
      nazn->KOL_NAZ  := mkol_naz
      nazn->KOL_UP   := mkol_up
      nazn->DATE_E   := c4sys_date
      nazn->KOD_P    := kod_polzovat    // код оператора
      Unlock
      Commit
    Endif
    rest_box( buf1 )
    If ltip_mnn < 2
      Set Filter To mnn->tip_mnn == ltip_mnn
    Endif
    Goto ( rec )
    flag := 0
  Case nKey == K_DEL .and. nazn->KOD_K > 0 .and. f_esc_enter( 2, .t. )
    deleterec()
    find ( str_find )
    flag := iif( Found(), 0, 1 )
  Otherwise
    Keyboard ''
  Endcase
  Return flag

//
Function vounc_input_recept()

  Local buf, str_sem := 'vounc_input_recept'

  If !g_slock( str_sem )
    Return func_error( 4, err_slock() )
  Endif
  If polikl1_kart() > 0
    buf := SaveScreen()
    Private blk_open := {|| r_use( dir_server() + 'vouncmnn', , 'MNN' ), ;
      r_use( dir_server() + 'vounctrn', , 'TRN' ), ;
      dbSetRelation( 'MNN', {|| mnn }, 'mnn' ), ;
      g_use( dir_server() + 'vouncrec', , 'RCP' ), ;
      dbSetRelation( 'TRN', {|| tovar }, 'tovar' ) }
    Eval( blk_open )
    Index On Str( FIELD->kod_k, 7 ) + Str( Descend( FIELD->DATE_R ), 10 ) + Str( 999999 - FIELD->NUMBER_R, 6 ) to ( cur_dir() + 'tmp_rcp' )
    Private fl_found, str_find, muslovie
    str_find := Str( glob_kartotek, 7 )
    muslovie := 'rcp->kod_k == glob_kartotek'
    find ( str_find )
    fl_found := Found()
    arr_blk := { {|| findfirst( str_find ) }, ;
      {|| findlast( str_find ) }, ;
      {| n| skippointer( n, muslovie ) }, ;
      str_find, muslovie;
      }
    If !fl_found
      Keyboard Chr( K_INS )
    Endif
    alpha_browse( T_ROW, 0, 23, 79, 'f1_vounc_input_recept', color0, glob_k_fio, 'BG+/GR', ;
      .f., .t., arr_blk, , 'f2_vounc_input_recept', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, BG+/B, R/BG, W+/R', .t., 180 } )
    Close databases
    RestScreen( buf )
  Endif
  g_sunlock( str_sem )
  Return Nil

//
Function f1_vounc_input_recept( oBrow )

  Local oColumn, blk := {|| iif( rcp->annul == 1, { 5, 6 }, iif( mnn->tip_mnn == 1, { 3, 4 }, { 1, 2 } ) ) }

  oColumn := TBColumnNew( '   Дата;  рецепта', {|| full_date( rcp->date_r ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Номер;рецепт', {|| put_val( rcp->NUMBER_R, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Назнач;кол-во', {|| put_val_0( rcp->KOL_NAZ, 6, 1 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Кол;уп.', {|| put_val( rcp->KOL_UP, 3 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'МКБ10', {|| rcp->kod_diag } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( ' Препарат', {|| PadR( trn->name, 21 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Дози-;ровка', {|| put_val_0( trn->doza, 6, 1 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Ед.;изм.', {|| iif( Empty( trn->name ), Space( 4 ), inieditspr( A__MENUVERT, mm_lf, trn->c_lf ) ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Кол.;в уп', {|| put_val( trn->n_lf, 4 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( '   ', {|| iif( rcp->annul == 1, 'анн', '   ' )  } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  //
  status_key( '^<Esc>^ выход ^<Del>^ аннулирование ^<Enter>^ редакт-ие ^<Ins>^ добавление ^<F9>^ печать' )
  Return Nil

//
Function f2_vounc_input_recept( nKey, oBrow )

  Static st_vrach := 0, si := 1
  Local arr, i, k, fl_recept := .f.
  Local flag := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
    tmp_color := SetColor(), r1, c1, bg := {| o, k| get_mkb10( o, k, .t. ) }

  Do Case
  Case nKey == K_F9
    If rcp->annul == 1
      func_error( 4, 'Данный рецепт аннулирован ' + full_date( rcp->d_annul ) + 'г.' )
    Else
      fl_recept := .t.
    Endif
  Case nKey == K_INS
    rec := rcp->( RecNo() )
    Close databases
    Private mkod_diag, m1tovar, mkol_naz, mkol_up, mtovar, ;
      mdate_r := sys_date, mnumber_r := 0, MTAB_NOM := 0, ;
      m1vrach := st_vrach, mvrach := Space( 10 ), gl_area := { 1, 0, 23, 79, 0 }
    If fl_found
      //
    Else
      ColorWin( T_ROW + 4, 0, T_ROW + 4, 79, 'N/N', 'W+/N' )
      ColorWin( T_ROW + 4, 0, T_ROW + 4, 79, 'N/N', 'BG+/B' )
    Endif
    //
    r_use( dir_server() + 'vouncmnn', , 'MNN' )
    r_use( dir_server() + 'vounctrn', , 'TRN' )
    dbSetRelation( 'MNN', {|| mnn }, 'mnn' )
    g_use( dir_server() + 'vouncnaz', , 'NAZN' )
    dbSetRelation( 'TRN', {|| tovar }, 'tovar' )
    Index On Str( Descend( FIELD->DATE_NAZ ), 10 ) to ( cur_dir() + 'tmp_nazn' ) For FIELD->kod_k == glob_kartotek
    k := { 0, 0 }
    arr := {}
    Go Top
    Do While !Eof()
      i := mnn->tip_mnn + 1
      If Between( i, 1, 2 ) .and. k[ i ] < iif( i == 1, 5, 3 )
        k[ i ] ++
        s := AllTrim( str_0( nazn->KOL_NAZ, 6, 1 ) ) + ' ' + ;
          AllTrim( inieditspr( A__MENUVERT, mm_lf, trn->c_lf ) ) + ;
          iif( nazn->KOL_UP == 1, ' ', '(' + lstr( nazn->KOL_UP ) + 'уп.) ' ) + ;
          date_8( nazn->DATE_NAZ ) + ' - ' + vounc_ret1_name_trn( 1 )
        AAdd( arr, { s, nazn->( RecNo() ) } )
      Endif
      If k[ 1 ] == 5 .and. k[ 2 ] == 3
        Exit
      Endif
      Select NAZN
      Skip
    Enddo
    If Len( arr ) == 0
      func_error( 4, 'Не было назначений данному человеку!' )
    Elseif ( i := popup_2array( arr, T_ROW, T_COL + 5, si, 1, , ;
        'По какому назначению выписывается рецепт', 'B/W', color5 ) ) > 0
      si := i
      Goto ( i )
      mkod_diag := nazn->kod_diag
      m1tovar   := nazn->tovar
      mkol_naz  := nazn->kol_naz
      mkol_up   := nazn->kol_up
      If m1vrach > 0
        r_use( dir_server() + 'mo_pers', , 'P2' )
        Goto ( m1vrach )
        mvrach := fam_i_o( p2->fio )
        MTAB_NOM := p2->tab_nom
      Endif
    Endif
    Close databases
    fl := .t.
    If m1tovar != NIL
      mtovar := vounc_ret_name_trn( m1tovar, 1, .t. )
      If vounc_mem_regim == 2  // автоматическая нумерация
        If !vounc_tools_ini( 1, 0, 0 ) // перечитать последний рецепт
          fl := func_error( 4, 'Не удалось прочитать номер последнего рецепта. Попытайтесь снова.' )
        Endif
        mnumber_r := vounc_mem_last_rc + 1
      Endif
      If fl
        r1 := 11
        c1 := 2
        buf1 := box_shadow( r1, c1, 21, 77, color8, ;
          'Добавление нового рецепта', cDataPgDn )
        Do While .t.
          SetColor( cDataCGet )
          @ r1 + 2, c1 + 2 Say 'Дата рецепта' Get mdate_r
          If vounc_mem_regim == 2  // автоматическая нумерация
            @ r1 + 3, c1 + 2 Say 'Номер рецепта' Get mnumber_r Pict '999999' When .f. Color cDataPgDn
          Else
            @ r1 + 3, c1 + 2 Say 'Номер рецепта' Get mnumber_r Pict '999999'
          Endif
          @ r1 + 4, c1 + 2 Say 'Врач, выписавший рецепт' Get mtab_nom Picture '99999' ;
            valid {| g| v_kart_vrach( g ) }
          @ Row(), Col() + 1 Get mvrach When .f. Color cDataPgDn
          @ r1 + 5, c1 + 2 Say 'Количество упаковок в рецепте' Get mkol_up Pict '99'
          @ r1 + 6, c1 + 2 Say 'Код заболевания (по МКБ-10)' Get mkod_diag Pict '@K@!' ;
            reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
          @ r1 + 7, c1 + 2 Say 'Препарат' Get mtovar ;
            reader {| x| menu_reader( x, { {| k, r, c| vounc_get_tovar( k, r, c ) } }, A__FUNCTION, , , .f. ) }
          @ r1 + 8, c1 + 2 Say 'Количество назначенного препарата в сутки' Get mkol_naz Pict '9999.9'
          status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
          myread()
          If LastKey() != K_ESC .and. !emptyany( mdate_r, mkod_diag, m1tovar, mkol_naz ) .and. f_esc_enter( 1 )
            mywait()
            fl := .t.
            If fl .and. Empty( mnumber_r )
              fl := func_error( 4, 'Не введен номер рецепта' )
            Endif
            If fl .and. !Between( mnumber_r, vounc_mem_nom1, vounc_mem_nom2 )
              fl := func_error( 4, 'Номер рецепта не попадает в диапазон с ' + ;
                lstr( vounc_mem_nom1 ) + ' по ' + lstr( vounc_mem_nom2 ) )
            Endif
            If fl .and. Empty( m1vrach )
              fl := func_error( 4, 'Не введен врач, выписавший рецепт' )
            Endif
            If fl
              r_use( dir_server() + 'vouncrec', , 'RCP' )
              Index On Str( FIELD->number_r, 6 ) to ( cur_dir() + 'tmp_rcp1' ) For Year( FIELD->date_r ) == Year( mdate_r )
              find ( Str( mnumber_r, 6 ) )
              If Found()
                fl := func_error( 4, 'В этом году уже был введен рецепт № ' + lstr( mnumber_r ) )
                If vounc_mem_regim == 2  // автоматическая нумерация
                  ++mnumber_r
                Endif
              Endif
              If fl
                Set Index To
                Locate For rcp->kod_k == glob_kartotek .and. ;
                  m1tovar == rcp->tovar .and. ;
                  Left( DToS( mdate_r ), 6 ) == Left( DToS( rcp->date_r ), 6 )
                If Found()
                  buf2 := SaveScreen()
                  f_message( { 'В этом месяце на данный препарат уже был выписан', ;
                    'рецепт № ' + lstr( rcp->number_r ) }, , 'GR+/R', 'W+/R', 16 )
                  mybell( 2 )
                  fl := ( f_alert( { PadC( 'Выберите действие', 60, '.' ) }, ;
                    { ' Нет записи ', ' Записать рецепт ' }, ;
                    1, 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N, n/BG' ) ) == 2
                  RestScreen( buf2 )
                Endif
              Endif
              Use
            Endif
            If fl
              fl_found := fl_recept := .t.
              g_use( dir_server() + 'vouncrec', , 'RCP' )
              addrecn()
              rec := RecNo()
              rcp->KOD_K    := glob_kartotek
              rcp->DATE_R   := mdate_r
              rcp->NUMBER_R := MNUMBER_R
              rcp->KOD_DIAG := mkod_diag
              rcp->TOVAR    := m1tovar
              rcp->VRACH    := m1vrach
              rcp->KOL_NAZ  := mkol_naz
              rcp->KOL_UP   := mkol_up
              rcp->DATE_E   := c4sys_date
              rcp->KOD_P    := kod_polzovat    // код оператора
              Unlock
              Commit
              st_vrach := m1vrach
              If nKey == K_INS .and. vounc_mem_regim == 2  // автоматическая нумерация
                vounc_mem_last_rc := mnumber_r
                If !vounc_tools_ini( 2, 0, 0 )
                  func_error( 4, 'Не удалось записать номер последнего рецепта. Проверьте и исправьте.' )
                Endif
              Endif
              Index On Str( FIELD->kod_k, 7 ) + Str( Descend( FIELD->DATE_R ), 10 ) + Str( 999999 - FIELD->NUMBER_R, 6 ) to ( cur_dir() + 'tmp_rcp' )
              Use
            Else
              Loop
            Endif
          Endif
          Exit
        Enddo
        rest_box( buf1 )
      Endif
    Endif
    Eval( blk_open )
    Set Index to ( cur_dir() + 'tmp_rcp' )
    Goto ( rec )
    flag := iif( fl_found, 0, 1 )
  Case nKey == K_ENTER .and. rcp->kod_k > 0
    If rcp->annul == 1
      func_error( 4, 'Данный рецепт аннулирован ' + full_date( rcp->d_annul ) + 'г.' )
      Return flag
    Endif
    rec := rcp->( RecNo() )
    Private mkod_diag := rcp->KOD_DIAG, ;
      mtovar, m1tovar := rcp->TOVAR, ;
      mkol_naz := rcp->KOL_NAZ, ;
      mkol_up := rcp->KOL_UP, ;
      mdate_r := rcp->DATE_R, ;
      mnumber_r := rcp->NUMBER_R, ;
      MTAB_NOM := 0, m1vrach := rcp->VRACH, mvrach := Space( 10 ), ;
      gl_area := { 1, 0, 23, 79, 0 }
    mtovar := vounc_ret1_name_trn( 1, .t. )
    If m1vrach > 0
      r_use( dir_server() + 'mo_pers', , 'P2' )
      Goto ( m1vrach )
      mvrach := fam_i_o( p2->fio )
      MTAB_NOM := p2->tab_nom
    Endif
    Close databases
    r1 := 11
    c1 := 2
    buf1 := box_shadow( r1, c1, 21, 77, color8, ;
      'Редактирование рецепта', cDataPgDn )
    SetColor( cDataCGet )
    @ r1 + 2, c1 + 2 Say 'Дата рецепта' Get mdate_r When .f.
    @ r1 + 3, c1 + 2 Say 'Номер рецепта' Get mnumber_r Pict '999999' When .f.
    @ r1 + 4, c1 + 2 Say 'Врач, выписавший рецепт' Get mtab_nom Picture '99999' ;
      valid {| g| v_kart_vrach( g ) }
    @ Row(), Col() + 1 Get mvrach When .f. Color cDataPgDn
    @ r1 + 5, c1 + 2 Say 'Количество упаковок в рецепте' Get mkol_up Pict '99'
    @ r1 + 6, c1 + 2 Say 'Код заболевания (по МКБ-10)' Get mkod_diag Pict '@K@!' ;
      reader {| o| mygetreader( o, bg ) } Valid val2_10diag()
    @ r1 + 7, c1 + 2 Say 'Препарат' Get mtovar ;
      reader {| x| menu_reader( x, { {| k, r, c| vounc_get_tovar( k, r, c ) } }, A__FUNCTION, , , .f. ) }
    @ r1 + 8, c1 + 2 Say 'Количество назначенного препарата в сутки' Get mkol_naz Pict '9999.9'
    status_key( '^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода' )
    myread()
    Eval( blk_open )
    Set Index to ( cur_dir() + 'tmp_rcp' )
    Goto ( rec )
    If LastKey() != K_ESC .and. !emptyany( mdate_r, mnumber_r, m1vrach, mkod_diag, m1tovar, mkol_naz ) .and. f_esc_enter( 1 )
      Goto ( rec )
      fl_recept := .t.
      g_rlock( forever )
      rcp->KOD_DIAG := mkod_diag
      rcp->TOVAR    := m1tovar
      rcp->VRACH    := m1vrach
      rcp->KOL_NAZ  := mkol_naz
      rcp->KOL_UP   := mkol_up
      rcp->DATE_E2  := c4sys_date
      rcp->KOD_P2   := kod_polzovat    // код оператора
      Unlock
      Commit
    Endif
    rest_box( buf1 )
    flag := 0
  Case nKey == K_DEL .and. rcp->kod_k > 0
    Private mdate
    If rcp->annul == 1
      arr := { 'Данный рецепт уже аннулирован ' + full_date( rcp->d_annul ) + 'г.', ;
        Space( 11 ) + 'Возможна отмена аннулирования - введите дату' }
    Else
      arr := { 'Рецепт № ' + StrZero( rcp->number_r, 6 ) + ' выписан ' + full_date( rcp->DATE_R ) + 'г.', ;
        Space( 19 ) + 'Введите дату аннулирования' }
    Endif
    If ( mdate := input_value( 18, 2, 21, 77, color1, arr, sys_date ) ) != NIL ;
        .and. f_esc_enter( iif( rcp->annul == 1, 'отмены ', '' ) + 'аннулирования', .t. )
      g_rlock( forever )
      rcp->annul   := iif( rcp->annul == 1, 0, 1 )
      rcp->d_annul := mdate
      rcp->DATE_E2 := c4sys_date
      rcp->KOD_P2  := kod_polzovat    // код оператора
      Unlock
      Commit
    Endif
    flag := 0
  Otherwise
    Keyboard ''
  Endcase
  If fl_recept
    clrline( 24, color0 )
    Keyboard ''
    If f_alert( { 'Распечатать рецепт номер ' + lstr( rcp->number_r ) + ' ?' }, ;
        { ' ~Да ', ' ~Нет ' }, ;
        1, 'N+/BG', 'R/BG', 18, , col1menu ) == 1
      vounc_print_recept()
    Endif
  Endif
  rest_box( buf )
  Return flag

//
Function vounc_print_recept()

  Local arr, adbf := { ;
    { 'SHTAMP',     'C',      5,      0 }, ;
    { 'OGRN',       'C',     30,      0 }, ;
    { 'KOD_LGOT',   'C',      3,      0 }, ;
    { 'MKB',        'C',      5,      0 }, ;
    { 'RC_SER',     'C',     10,      0 }, ;
    { 'RC_NOM',     'C',      6,      0 }, ;
    { 'RC_DATE',    'C',     10,      0 }, ;
    { 'FIO',        'C',     50,      0 }, ;
    { 'DATE_R',     'C',     10,      0 }, ;
    { 'SNILS',      'C',     20,      0 }, ;
    { 'POLIS',      'C',     25,      0 }, ;
    { 'ADRES',      'C',     80,      0 }, ;
    { 'FIO_VRACH',  'C',     50,      0 }, ;
    { 'KOD_VRACH',  'C',      5,      0 }, ;
    { 'MTRN',       'C',     80,      0 }, ;
    { 'KOL',        'C',     10,      0 }, ;
    { 'SIGNA',      'C',     30,      0 };
    }
  Local d

  If ( d := input_value( 18, 10, 20, 69, color1, ;
      { Space( 10 ) + 'Введите дату выписки рецепта', ;
      SubStr( full_date( rcp->date_r ), 3 ) }, ;
      Day( sys_date ), '99' ) ) == NIL
    Return Nil
  Endif
  delfrfiles()
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  Append Blank
  r_use( dir_server() + 'mo_pers', , 'P2' )
  Goto ( rcp->vrach )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Goto ( rcp->kod_k )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  Goto ( rcp->kod_k )
  r_use( dir_server() + 'organiz', , 'ORG' )
  frd->OGRN := org->ogrn
  frd->KOD_LGOT := kart_->KOD_LGOT
  frd->MKB := rcp->kod_diag
  frd->RC_SER := vounc_mem_ser
  frd->RC_NOM := StrZero( rcp->number_r, 6 )
  frd->RC_DATE := iif( d <= 0, '  ', StrZero( d, 2 ) ) + SubStr( full_date( rcp->date_r ), 3 )
  frd->FIO := kart->fio
  frd->DATE_R := full_date( kart->DATE_R )
//  frd->SNILS := iif( Empty( kart->snils ), '', Transform( kart->SNILS, picture_pf ) )
  frd->SNILS := iif( Empty( kart->snils ), '', Transform_SNILS( kart->SNILS ) )
  frd->POLIS := make_polis( kart_->spolis, kart_->npolis )
  frd->ADRES := lstr( kart->kod_vu )
  frd->FIO_VRACH := p2->fio
  frd->KOD_VRACH := StrZero( p2->kod_dlo, 5 )
  frd->MTRN := vounc_ret1_name_trn( 2, .f. )
  frd->KOL := LTrim( Str( rcp->kol_up * trn->n_lf ) )
  frd->SIGNA := AllTrim( str_0( rcp->kol_naz, 6, 1 ) ) + ' мг в сутки'
  org->( dbCloseArea() )
  p2->( dbCloseArea() )
  kart->( dbCloseArea() )
  kart_->( dbCloseArea() )
  //
  arr := {}
  If Empty( frd->OGRN )
    AAdd( arr, 'Пустое поле "ОГРН ЛПУ"' )
  Endif
  If Empty( frd->KOD_LGOT )
    AAdd( arr, 'Пустое поле "Код льготы"' )
  Endif
  If Empty( frd->MKB )
    AAdd( arr, 'Пустое поле "Диагноз"' )
  Endif
  If Empty( frd->RC_SER )
    AAdd( arr, 'Пустое поле "Серия рецепта"' )
  Endif
  If Empty( frd->RC_NOM )
    AAdd( arr, 'Пустое поле "Номер рецепта"' )
  Endif
  If Empty( frd->RC_DATE )
    AAdd( arr, 'Пустое поле "Дата рецепта"' )
  Endif
  If Empty( frd->FIO )
    AAdd( arr, 'Пустое поле "ФИО"' )
  Endif
  If Empty( frd->DATE_R )
    AAdd( arr, 'Пустое поле "Дата рождения"' )
  Endif
  If Empty( frd->SNILS )
    AAdd( arr, 'Пустое поле "СНИЛС"' )
  Endif
  If Empty( frd->POLIS )
    AAdd( arr, 'Пустое поле "Полис ОМС"' )
  Endif
  If frd->ADRES == '0'
    AAdd( arr, 'Пустое поле "Номер амбулаторной карты (номер в участке)"' )
  Endif
  If Empty( frd->FIO_VRACH )
    AAdd( arr, 'Пустое поле "ФИО врача"' )
  Endif
  If frd->KOD_VRACH == '00000'
    AAdd( arr, 'Пустое поле "Код врача для рецептов по ДЛО"' )
  Endif
  If Empty( frd->MTRN )
    AAdd( arr, 'Пустое поле "Наименование препарата"' )
  Endif
  If frd->KOL == '0'
    AAdd( arr, 'Пустое поле "Кол-во упаковок"' )
  Endif
  If Empty( rcp->kol_naz )
    AAdd( arr, 'Пустое поле "Кол-во назначенного препарата"' )
  Endif
  If !Empty( arr )
    n_message( arr, , 'GR+/B', 'W+/B', , , 'G+/B' )
  Endif
  //
  frd->( dbCloseArea() )
  call_fr( 'mo_rcp' )
  Select RCP
  Return Nil

//
Function vounc_info_nazn()

  ne_real()
  Return Nil

//
Function vounc_info_recept( k )

  Static sk := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { '~Количество рецептов', ;
      'Препараты по ~месяцам', ;
      'Больные + ~препараты' }
    mas_msg := { 'Подсчёт количества выписанных рецептов', ;
      'Итоговое значение выписанных препаратов по месяцам за год', ;
      'Больные + препараты, выписанные за период времени' }
    mas_fun := { 'vounc_info_recept(1)', ;
      'vounc_info_recept(2)', ;
      'vounc_info_recept(3)' }
    popup_prompt( T_ROW, T_COL - 5, sk, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    f1vounc_info_recept()
  Case k == 2
    f2vounc_info_recept()
  Case k == 3
    f3vounc_info_recept()
  Endcase
  If k > 0
    sk := k
  Endif
  Return Nil

// 28.02.13
Function f1vounc_info_recept()

  Static sn := 5, ;
    mm_menu := { { 'Понедельник', 2 }, ;
    { 'Вторник', 3 }, ;
    { 'Среда', 4 }, ;
    { 'Четверг', 5 }, ;
    { 'Пятница', 6 }, ;
    { 'Суббота', 7 }, ;
    { 'Воскресенье', 1 } }
  Local sh, HH := 58, buf := save_maxrow(), n_file := cur_dir() + 'kol_rcp.txt', ;
    arr_m, last_d, skol := 0, am := {}, i, j, m

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  sh := 80
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( 'Количество рецептов', sh ) )
  add_string( Center( 'с ' + date_8( arr_m[ 5 ] ) + 'г. по ' + date_8( arr_m[ 6 ] ) + 'г.', sh ) )
  last_d := arr_m[ 5 ]
  add_string( '' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  r_use( dir_server() + 'vouncrec', , 'RCP' )
  Set Relation To kod_k into KART
  Index On DToS( FIELD->DATE_R ) + Str( FIELD->NUMBER_R, 6 ) to ( cur_dir() + 'tmp_rcp' ) ;
    For Between( FIELD->date_r, arr_m[ 5 ], arr_m[ 6 ] ) .and. FIELD->annul == 0
  Go Top
  Do While !Eof()
    verify_ff( HH, .t., sh )
    add_string( Str( ++skol, 4 ) + '. ' + Left( DToC( rcp->date_r ), 5 ) + Str( rcp->number_r, 7 ) + ;
      ' ' + RTrim( kart->fio ) )
    m := Month( rcp->date_r )
    If ( i := AScan( am, {| x| x[ 1 ] == m } ) ) == 0
      AAdd( am, { m, 0, {} } )
      i := Len( am )
    Endif
    am[ i, 2 ] ++
    If ( j := AScan( am[ i, 3 ], {| x| x[ 1 ] == rcp->date_r } ) ) == 0
      AAdd( am[ i, 3 ], { rcp->date_r, 0 } )
      j := Len( am[ i, 3 ] )
    Endif
    am[ i, 3, j, 2 ] ++
    last_d := rcp->date_r
    Select RCP
    Skip
  Enddo
  add_string( Replicate( '─', sh ) )
  For i := 1 To Len( am )
    For j := 1 To Len( am[ i, 3 ] )
      verify_ff( HH, .t., sh )
      add_string( full_date( am[ i, 3, j, 1 ] ) + ' -' + Str( am[ i, 3, j, 2 ], 4 ) + ' рецептов' )
    Next
    add_string( Replicate( '─', sh ) )
    add_string( PadR( mm_month[ am[ i, 1 ] ], 10 ) + ' -' + Str( am[ i, 2 ], 4 ) + ' рецептов' )
    add_string( Replicate( '─', sh ) )
  Next
  rest_box( buf )
  Close databases
  add_string( 'с ' + date_8( arr_m[ 5 ] ) + 'г. по ' + date_8( last_d ) + ;
    'г. итого рецептов: ' + lstr( skol ) )
  FClose( fp )
  Keyboard Chr( K_END )
  viewtext( n_file, , , , .t., , , 2, , , .f. )
  Return Nil

// 28.07.25
Function f2vounc_info_recept()

  Local sh, HH := 57, buf := save_maxrow(), n_file := cur_dir() + 'trn_year.txt', ;
    arr_m, adbf, i, arr_title, s

  If ( arr_m := year_month(, , , 4 ) ) == NIL
    Return Nil
  Endif
  mywait()
  adbf := { { 'TOVAR', 'N', 5, 0 }, ;
            { 'kol', 'N', 6, 0 } }
  For i := 1 To 12
    AAdd( adbf, { 'kol' + lstr( i ), 'N', 6, 0 } )
  Next
  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' )
  Index On Str( FIELD->tovar, 5 ) to ( cur_dir() + 'tmp' )
  r_use( dir_server() + 'vouncrec', , 'RCP' )
  Go Top
  Do While !Eof()
    If Between( rcp->date_r, arr_m[ 5 ], arr_m[ 6 ] ) .and. rcp->annul == 0
      pole := 'tmp->kol' + lstr( Month( rcp->date_r ) )
      Select TMP
      find ( Str( rcp->tovar, 5 ) )
      If !Found()
        Append Blank
        tmp->tovar := rcp->tovar
      Endif
      tmp->kol += rcp->KOL_UP
      &pole := &pole + rcp->KOL_UP
    Endif
    Select RCP
    Skip
  Enddo
  rest_box( buf )
  If tmp->( LastRec() ) == 0
    func_error( 4, 'Не было выписано рецептов ' + arr_m[ 4 ] )
  Else
    arr_title := { '─', ' ', '─' }
    For i := 1 To 12
      arr_title[ 1 ] += '───┬'
      arr_title[ 2 ] += Left( mm_month[ i ], 3 ) + '│'
      arr_title[ 3 ] += '───┴'
    Next
    arr_title[ 1 ] += '─────┬─────────────────────────────────'
    arr_title[ 2 ] += 'Всего│  Наименование препаратов        '
    arr_title[ 3 ] += '─────┴─────────────────────────────────'
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( n_file )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Препараты в рецептах ' + arr_m[ 4 ], sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + 'vouncmnn', , 'MNN' )
    r_use( dir_server() + 'vounctrn', , 'TRN' )
    Set Relation To mnn into MNN
    Select TMP
    Set Relation To tovar into TRN
    Index On Str( mnn->TIP_MNN, 1 ) + Upper( trn->name ) + Str( trn->c_lf, 1 ) + Str( trn->doza, 6, 1 ) + Str( trn->n_lf, 4 ) to ( cur_dir() + 'tmp' )
    Go Top
    Do While !Eof()
      s := ''
      For i := 1 To 12
        pole := 'tmp->kol' + lstr( i )
        s += put_val( &pole, 4 )
      Next
      s += put_val( tmp->kol, 6 ) + ' ' + AllTrim( trn->name ) + ' ' + ;
        AllTrim( str_0( trn->doza, 6, 1 ) ) + ;
        ' ' + AllTrim( inieditspr( A__MENUVERT, mm_lf, trn->c_lf ) ) + ;
        ' N' + lstr( trn->n_lf )
      add_string( s )
      Skip
    Enddo
    FClose( fp )
    Close databases
    viewtext( n_file, , , , ( sh > 80 ), , , 2 )
  Endif
  Close databases
  Return Nil

// 28.05.25
Function f3vounc_info_recept()

  Local sh, HH := 54, buf := save_maxrow(), n_file := cur_dir() + 'pac_trn.txt', ;
    arr_m, adbf, i, arr_title, s, ii

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  mywait()
  adbf := { { 'kod_k', 'N', 7, 0 }, ;
            { 'TOVAR', 'N', 5, 0 }, ;
            { 'kol', 'N', 6, 0 } }
  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' )
  Index On Str( FIELD->kod_k, 7 ) + Str( FIELD->tovar, 5 ) to ( cur_dir() + 'tmp' )
  r_use( dir_server() + 'vouncrec', , 'RCP' )
  Go Top
  Do While !Eof()
    If Between( rcp->date_r, arr_m[ 5 ], arr_m[ 6 ] ) .and. rcp->annul == 0
      Select TMP
      find ( Str( rcp->kod_k, 7 ) + Str( rcp->tovar, 5 ) )
      If !Found()
        Append Blank
        tmp->kod_k := rcp->kod_k
        tmp->tovar := rcp->tovar
      Endif
      tmp->kol += rcp->KOL_UP
    Endif
    Select RCP
    Skip
  Enddo
  rest_box( buf )
  If tmp->( LastRec() ) == 0
    func_error( 4, 'Не было выписано рецептов ' + arr_m[ 4 ] )
  Else
    r_use( dir_server() + 'vouncmnn', , 'MNN' )
    r_use( dir_server() + 'vounctrn', , 'TRN' )
    Set Relation To mnn into MNN
    Select TMP
    Set Relation To tovar into TRN
    Index On FIELD->tovar to ( cur_dir() + 'tmp' ) unique
    arr := {}
    Go Top
    Do While !Eof()
      AAdd( arr, { mnn->TIP_MNN, trn->name, trn->c_lf, trn->doza, trn->n_lf, tovar } )
      Skip
    Enddo
    ASort( arr, , , {| x, y| iif( x[ 1 ] == y[ 1 ], ;
      iif( x[ 2 ] == y[ 2 ], ;
      iif( x[ 3 ] == y[ 3 ], ;
      iif( x[ 4 ] == y[ 4 ], x[ 5 ] < y[ 5 ], x[ 4 ] < y[ 4 ] ), ;
      x[ 3 ] < y[ 3 ] ), ;
      x[ 2 ] < y[ 2 ] ), ;
      x[ 1 ] < y[ 1 ] ) } )
    arr_title := Array( 9 )
    n := 50
    For i := 1 To 9
      If eq_any( i, 1, 9 )
        arr_title[ i ] := Replicate( '─', n )
      Elseif i == 5
        arr_title[ i ] := PadC( 'Ф.И.О. пациента', n )
      Else
        arr_title[ i ] := Space( n )
      Endif
    Next
    For i := 1 To Len( arr )
      arr_title[ 1 ] += '┬────'
      arr_title[ 2 ] += '│' + SubStr( arr[ i, 2 ], 1, 4 )
      arr_title[ 3 ] += '│' + SubStr( arr[ i, 2 ], 5, 4 )
      arr_title[ 4 ] += '│' + SubStr( arr[ i, 2 ], 9, 4 )
      arr_title[ 5 ] += '│' + SubStr( arr[ i, 2 ], 13, 4 )
      arr_title[ 6 ] += '│' + PadC( AllTrim( str_0( arr[ i, 4 ], 6, 1 ) ), 4 )
      arr_title[ 7 ] += '│' + PadC( AllTrim( inieditspr( A__MENUVERT, mm_lf, arr[ i, 3 ] ) ), 4 )
      arr_title[ 8 ] += '│' + PadC( 'N' + lstr( arr[ i, 5 ] ), 4 )
      arr_title[ 9 ] += '┴────'
    Next
    sh := Len( arr_title[ 1 ] )
    fp := FCreate( n_file )
    n_list := 1
    tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Больные + препараты в рецептах ' + arr_m[ 4 ], sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + 'kartotek', , 'KART' )
    Select TMP
    Set Relation To kod_k into KART
    Index On Upper( kart->fio ) + Str( FIELD->kod_k, 7 ) to ( cur_dir() + 'tmp' )
    old_kart := -1
    s := ''
    ii := 0
    Go Top
    Do While !Eof()
      If old_kart != tmp->kod_k
        If !Empty( s )
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( s )
          add_string( Replicate( '─', sh ) )
        Endif
        old_kart := tmp->kod_k
        s := PadR( lstr( ++ii ) + '(' + lstr( kart->kod_vu ) + ') ' + kart->fio, n ) + ;
          Space( 5 * Len( arr ) )
      Endif
      If ( i := AScan( arr, {| x| x[ 6 ] == tmp->tovar } ) ) > 0
        s := Stuff( s, n + 5 * ( i - 1 ), 5, put_val( tmp->kol, 5 ) )
      Endif
      Skip
    Enddo
    Close databases
    If !Empty( s )
      add_string( s )
      add_string( Replicate( '─', sh ) )
    Endif
    FClose( fp )
    Private yes_albom := .t.
    viewtext( n_file, , , , ( sh > 80 ), , , 5 )
  Endif
  Close databases
  Return Nil

//
Function vounc_info_sprav()

  Local sh := 64, HH := 57, buf := save_maxrow(), n_file := cur_dir() + 'mnn_trn.txt', ;
    old_tip_mnn := -1

  mywait()
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( '' )
  add_string( Center( Expand( 'Список лекарственных препаратов' ), sh ) )
  r_use( dir_server() + 'vounctrn', , 'TRN' )
  Index On Str( FIELD->mnn, 5 ) + Upper( FIELD->name ) + Str( FIELD->c_lf, 1 ) + Str( FIELD->doza, 6, 1 ) + Str( n_lf, 4 ) to ( cur_dir() + 'tmp_trn' )
  r_use( dir_server() + 'vouncmnn', , 'MNN' )
  Index On Str( FIELD->TIP_MNN, 1 ) + Upper( FIELD->name ) to ( cur_dir() + 'tmp_mnn' )
  Go Top
  Do While !Eof()
    If old_tip_mnn != mnn->tip_mnn
      old_tip_mnn := mnn->tip_mnn
      add_string( '' )
      add_string( inieditspr( A__MENUVERT, mm_tip_mnn, mnn->tip_mnn ) )
    Endif
    add_string( Space( 5 ) + AllTrim( mnn->name ) + ' (' + AllTrim( mnn->name_lat ) + ')' )
    Select TRN
    find ( Str( mnn->( RecNo() ), 5 ) )
    Do While mnn->( RecNo() ) == trn->mnn .and. !Eof()
      add_string( Space( 10 ) + AllTrim( trn->name ) + ' ' + AllTrim( str_0( trn->doza, 6, 1 ) ) + ;
        ' ' + AllTrim( inieditspr( A__MENUVERT, mm_lf, trn->c_lf ) ) + ;
        ' N' + lstr( trn->n_lf ) + ;
        ' (' + AllTrim( trn->name_lat ) + ')' )
      Skip
    Enddo
    Select MNN
    Skip
  Enddo
  Close databases
  FClose( fp )
  rest_box( buf )
  viewtext( n_file )
  Return Nil

//
Function vounc_sprav_trn()

  Local arr[ US_LEN ], blk

  arr[ US_TOP      ] := T_ROW
  arr[ US_BOTTOM   ] := 23
  arr[ US_LEFT     ] := 0
  arr[ US_RIGHT    ] := 79
  arr[ US_BASE     ] := dir_server() + 'vounctrn'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .t. }
  arr[ US_COLUMN   ] := { { ' Наименование', {|| Left( name, 20 ) }, blk }, ;
    { 'дозир.', {|| str_0( doza, 6, 1 ) }, blk }, ;
    { 'ед.из', {|| inieditspr( A__MENUVERT, mm_lf, c_lf ) }, blk }, ;
    { 'в уп', {|| Str( n_lf, 4 ) }, blk }, ;
    { ' По латыни', {|| Left( name_lat, 18 ) }, blk }, ;
    { ' МНН', {|| Left( inieditspr( A__POPUPMENU, dir_server() + 'vouncmnn', mnn ), 21 ) }, blk } }
  arr[ US_BLK_DEL  ] := {| _k| vounc_del_trn( _k ) }
  arr[ US_ROD_PADEG ] := arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'ТРН'
  arr[ US_EDIT_SPR ] := { { 'name',    'C', 60, 0, , , Space( 60 ), , 'Наименование' }, ;
    { 'name_lat', 'C', 60, 0, , , Space( 60 ), , 'По латыни   ' }, ;
    { 'doza', 'N', 6, 1, , , 0, , 'Дозировка' }, ;
    { 'c_lf', 'N', 1, 0, nIL, ;
    {| x| menu_reader( x, mm_lf, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_lf, x ) }, ;
    'Единицы измерения' }, ;
    { 'n_lf', 'N', 4, 0, , , 0, , 'Количество в упаковке' }, ;
    { 'mnn', 'N', 5, 0, , ;
    {| x| menu_reader( x, { dir_server() + 'vouncmnn' }, A__POPUPMENU, , , .f. ) }, ;
    1, {| x| inieditspr( A__POPUPMENU, dir_server() + 'vouncmnn', x ) }, ;
    'МНН' };
    }
  edit_u_spr( 1, arr )
  Return Nil

//
Function vounc_del_trn( k )

  Local _fl, buf := save_maxrow()

  mywait()
  r_use( dir_server() + 'vouncnaz', , '__B' )
  Index On Str( FIELD->tovar, 5 ) to ( cur_dir() + 'tmp_nazn' )
  find ( Str( k, 5 ) )
  _fl := Found()
  dbCloseArea()
  If !_fl
    r_use( dir_server() + 'vouncrec', , '__B' )
    Index On Str( FIELD->tovar, 5 ) to ( cur_dir() + 'tmp_recp' )
    find ( Str( k, 5 ) )
    _fl := Found()
    dbCloseArea()
  Endif
  rest_box( buf )
  Return !_fl

//
Function vounc_sprav_mnn()

  Local arr[ US_LEN ]

  arr[ US_TOP      ] := T_ROW
  arr[ US_BOTTOM   ] := 23
  arr[ US_LEFT     ] := 0
  arr[ US_RIGHT    ] := 79
  arr[ US_BASE     ] := dir_server() + 'vouncmnn'
  arr[ US_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .t. }
  arr[ US_COLUMN   ] := { { ' МНН', {|| Left( name, 27 ) } }, ;
    { ' По латыни', {|| Left( name_lat, 26 ) } }, ;
    { ' Тип', {|| PadR( inieditspr( A__MENUVERT, mm_tip_mnn, tip_mnn ), 23 ) } } }
  arr[ US_BLK_DEL  ] := {| _k| vounc_del_mnn( _k ) }
  arr[ US_ROD_PADEG ] := arr[ US_IM_PADEG ] := arr[ US_SEMAPHORE ] := 'МНН'
  arr[ US_EDIT_SPR ] := { { 'name',    'C', 60, 0, , , Space( 60 ), , 'Наименование' }, ;
    { 'name_lat', 'C', 60, 0, , , Space( 60 ), , 'По латыни   ' }, ;
    { 'tip_mnn', 'N', 1, 0, nIL, ;
    {| x| menu_reader( x, mm_tip_mnn, A__MENUVERT, , , .f. ) }, ;
    0, {| x| inieditspr( A__MENUVERT, mm_tip_mnn, x ) }, ;
    'Тип' };
    }
  edit_u_spr( 1, arr )
  Return Nil

//
Function vounc_del_mnn( k )

  Local _fl

  r_use( dir_server() + 'vounctrn', , '__B' )
  dblocateprogress( {|| __b->mnn == k } )
  _fl := !Found()
  dbCloseArea()
  Return _fl

//
Function vounc_sprav_nastr( reg )

  Static mm_regim := { { 'вручную      ', 1 }, { 'автоматически', 2 } }
  Local mm_tmp := {}, str_sem

  Do Case
  Case reg == 1 // определить
    Public vounc_mem_regim   := 1, ;
      vounc_mem_last_rc := 0, ;
      vounc_mem_nom1    := 1, ;
      vounc_mem_nom2    := 999999, ;
      vounc_mem_diag    := 'Z94.0', ;
      vounc_mem_ser     := Space( 10 )
  Case reg == 2 .and. vounc_tools_ini( 1, 0, 0 ) // редактирование
    If ! hb_user_curUser:isadmin()
      Return func_error( 4, err_admin() )
    Endif
    str_sem := 'Редактирование настроек VOUNC'
    If g_slock( str_sem )
      Close databases
      Delete file tmp.dbf
      AAdd( mm_tmp, { 'regim', 'N', 1, 0, nIL, ;
        {| x| menu_reader( x, mm_regim, A__MENUVERT ) }, ;
        1, {| x| inieditspr( A__MENUVERT, mm_regim, x ) }, ;
        'Каким образом проставляется номер рецепта при добавлении' } )
      AAdd( mm_tmp, { 'last_rc', 'N', 6, 0, nIL, ;
        NIL, ;
        0, nIL, ;
        'Номер последнего (автоматически) добавленного рецепта', , ;
        {|| vounc_val_nom() } } )
      AAdd( mm_tmp, { 'nom1', 'N', 6, 0, nIL, ;
        NIL, ;
        0, nIL, ;
        'Введите начальный номер рецепта', ;
        {|| vounc_val_nom() } } )
      AAdd( mm_tmp, { 'nom2', 'N', 6, 0, nIL, ;
        NIL, ;
        0, nIL, ;
        'Введите конечный номер рецепта', ;
        {|| vounc_val_nom() } } )
      AAdd( mm_tmp, { 'ser', 'C', 10, 0, '@!', ;
        NIL, ;
        '', nIL, ;
        'Серия для печати рецептов' } )
      AAdd( mm_tmp, { 'diag', 'C', 5, 0, '@!', ;
        NIL, ;
        '', nIL, ;
        'Диагноз по умолчанию' } )
      init_base( cur_dir() + 'tmp', , mm_tmp, 0 )
      Use ( cur_dir() + 'tmp' ) new
      Append Blank
      tmp->regim   := vounc_mem_regim
      tmp->last_rc := vounc_mem_last_rc
      tmp->ser     := vounc_mem_ser
      tmp->diag    := vounc_mem_diag
      tmp->nom1    := vounc_mem_nom1
      tmp->nom2    := vounc_mem_nom2
      Close databases
      If f_edit_spr( A__EDIT, mm_tmp, 'настройке программы', ;
          'g_use(cur_dir() + "tmp", , , .t., .t.)', 0, 1, 'spr_nastr' ) > 0
        Use ( cur_dir() + 'tmp' ) new
        vounc_mem_regim   := tmp->regim
        vounc_mem_last_rc := tmp->last_rc
        vounc_mem_ser     := tmp->ser
        vounc_mem_diag    := tmp->diag
        vounc_mem_nom1    := tmp->nom1
        vounc_mem_nom2    := tmp->nom2
        vounc_tools_ini( 2, 0, 0 )
      Endif
      Close databases
      g_sunlock( str_sem )
    Else
      func_error( 4, err_slock() )
    Endif
  Endcase
  Return Nil

//
Static Function vounc_val_nom()

  If mnom1 <= 0 .or. mnom2 <= 0
    func_error( 4, 'Начальный (конечный) номер должен быть положительным числом' )
  Elseif mnom1 > mnom2
    func_error( 4, 'Начальный номер рецепта должен быть меньше конечного' )
  Elseif !Between( mlast_rc, mnom1 - 1, mnom2 )
    func_error( 4, 'Номер последнего (автоматически) добавленного рецепта не попадает в диапазон' )
  Endif
  Return .t.

//
Function vounc_tools_ini( reg, k1, k2 )

  Static arr := { { 'vounc_mem_regim',  'N' }, ;
    { 'vounc_mem_last_rc', 'N' }, ;
    { 'vounc_mem_diag',   'C' }, ;
    { 'vounc_mem_nom1',   'N' }, ;
    { 'vounc_mem_nom2',   'N' }, ;
    { 'vounc_mem_ser',    'C' } }
  Local name_section := 'ВОУНЦ'
  Local i, j, ta := {}, v, fl

  If ( fl := semaphor_tools_ini( 1 ) )
    name_section += '-' + lstr( k1 ) + '-' + lstr( k2 )
    If reg == 1 // чтение
      ta := getinisect( tools_ini, name_section ) // вернуть двумерный массив содержимого секции {{'наим.','знач.'},...}
      For j := 1 To Len( ta )
        If ( i := AScan( arr, {| x| Upper( x[ 1 ] ) == ta[ j, 1 ] } ) ) > 0
          &( arr[ i, 1 ] ) := iif( arr[ i, 2 ] == 'C', ta[ j, 2 ], Val( ta[ j, 2 ] ) )
          If arr[ i, 2 ] == 'N' .and. Len( arr[ i ] ) == 2
            &( arr[ i, 1 ] ) := Int( Val( ta[ j, 2 ] ) )
          Endif
        Endif
      Next
    Else // запись
      For i := 1 To Len( arr )
        v := &( arr[ i, 1 ] )
        AAdd( ta, { arr[ i, 1 ], iif( arr[ i, 2 ] == 'C', v, lstr( v ) ) } )
      Next
      setinisect( tools_ini, name_section, ta ) // запись секции в ini.файл
    Endif
    semaphor_tools_ini( 2 )
  Endif
  Return fl

//
Static Function vounc_ret_name_trn( ltovar, k, fl_upak )

  Local ret := Space( 10 )

  If ltovar > 0
    r_use( dir_server() + 'vounctrn', , 'TRN' )
    Goto ( ltovar )
    ret := vounc_ret1_name_trn( k, fl_upak )
    Use
  Endif
  Return ret

//
Static Function vounc_ret1_name_trn( k, fl_upak )

  Local ret

  Default fl_upak To .t.
  If k == 1  // по русски
    ret := AllTrim( trn->name ) + ' ' + AllTrim( str_0( trn->doza, 6, 1 ) ) + ' ' + ;
      AllTrim( inieditspr( A__MENUVERT, mm_lf, trn->c_lf ) )
    If fl_upak
      ret += ' N' + lstr( trn->n_lf )
    Endif
  Else  // по латыни
    ret := AllTrim( trn->name_lat ) + ' ' + AllTrim( str_0( trn->doza, 6, 1 ) ) + ' ' + ;
      AllTrim( inieditspr( A__MENUVERT, mm_lf_lat, trn->c_lf ) )
    If fl_upak
      ret += ' N' + lstr( trn->n_lf )
    Endif
  Endif
  Return ret

//
Function vounc_get_tovar( k, r, c, _tip_mnn )

  Local arr_name := {}, arr_kod := {}
  Local buf := SaveScreen(), ret, i, r1, r2, c1, c2, l := 0, s

  Default _tip_mnn To 2
  r_use( dir_server() + 'vouncmnn', , 'MNN' )
  r_use( dir_server() + 'vounctrn', , 'TRN' )
  Index On Upper( FIELD->name ) to ( cur_dir() + 'tmp_trn' )
  dbSetRelation( 'MNN', {|| mnn }, 'mnn' )
  Go Top
  Do While !Eof()
    If iif( _tip_mnn == 2, .t., _tip_mnn == mnn->tip_mnn )
      AAdd( arr_name, vounc_ret1_name_trn( 1 ) )
      AAdd( arr_kod, RecNo() )
      l := Max( l, Len( ATail( arr_name ) ) )
    Endif
    Skip
  Enddo
  Close databases
  If Len( arr_kod ) == 0
    s := 'Пустой справочник препаратов'
    If eq_any( _tip_mnn, 0, 1 )
      s += ' "' + Upper( AllTrim( mm_tip_mnn[ _tip_mnn + 1, 1 ] ) ) + '"'
    Endif
    func_error( 4, s )
  Else
    If k != NIL
      i := AScan( arr_kod, k )
    Endif
    r2 := r - 1
    r1 := r2 - Len( arr_kod ) -1
    If r1 < 2
      r1 := 2
    Endif
    c1 := c
    c2 := c1 + l + 3
    If c2 > 77
      c2 := 77
      c1 := c2 - l - 3
      If c1 < 0
        c1 := 0
      Endif
    Endif
    status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор препарата' )
    If ( k := Popup( r1, c1, r2, c2, arr_name, i, color0, .t. ) ) > 0
      ret := { arr_kod[ k ], arr_name[ k ] }
    Endif
  Endif
  RestScreen( buf )
  Return ret
