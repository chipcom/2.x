#include 'inkey.ch'
#include 'function.ch'

// просмотр текстового файла объектом TBROWSE (с возможностью печати)
Function viewtext( mfile, title, mf_print, plus_msg, fl_right, ;
    mcolor, t_help, mregim, pr_func, name_file, ;
    yes_clear, yes_FF, yes_edit, count_copy, ;
    nTop, nLeft, nBottom, nRight )

  // mfile    - наименование текстового файла
  // title    - строка заголовка
  // mf_print - имя функции пользователя (по умолчанию pr_view)
  // plus_msg - кусочек строки, добавляемый к сообщению
  // fl_right - флаг, разрешающий сдвиг текста вправо и влево
  // mcolor   - цвет
  // t_help   - код помощи
  // mregim   - режим печати (1 - Pica, 2 - Elite, 3 - Condensed,
  // 4 - Pica 8 lpi, 5 - Elite 8 lpi, 6 - Condensed 8 lpi)
  // pr_func  - функция для установки кодов принтера с одним параметром:
  // =1 - для установки кодов, =2 - для снятия кодов
  // (эта функция добавлена для того случая, если Вам не
  // достаточно стандартных режимов mregim)
  // name_file- имя файла для вывода документа (вместо вывода на принтер)
  // yes_clear- очищать ли буфер клавиатуры перед входом в функцию
  // (по умолчанию .t. - да)
  // yes_FF   - вставлять символ перевода формата или линию отрыва
  // yes_edit - разрешать включать редактор (по умолчанию .t. - да)
  // count_copy - сколько копий (по умолчанию 0 - бесконечность)
  Local oBrowse, oColumn, lCont, lEdit, j := 1, j1 := 0, ;
    i, buf, buf1, tmp_color := SetColor(), ;
    fl_plus := ( plus_msg == NIL ), lwidth, arr_keys := {}, ;
    s_msg := ' <Esc> - выход;    <Home> <End> <PgUp> <PgDn>', ;
    fl_mouse, x_mouse := 0, y_mouse := 0, raz := 0, ;
    tmp_help, tmp_nhelp, t_nhelp, s
  local nKey

//  Private nKey := 256, _p_list_2 := 0, _p_list_3 := 0, ;
  Private _p_list_2 := 0, _p_list_3 := 0, ;
    _p_list_4 := 0, _p_list_5 := 0, _p_list_6 := 0
  
  nKey := 256
  If !File( mfile )
    Return Nil
  Endif
  If t_help == NIL
    t_nhelp := 'Printer'
  Elseif ValType( t_help ) == 'C'
    t_nhelp := t_help
  Endif
  Default title To '', fl_right To .f., mf_print To 'pr_view', ;
    mcolor To 'W+/B, B/BG', t_help To 6, mregim To 1, pr_func To '', ;
    name_file To '', yes_clear To .t., ;
    yes_edit To .t., count_copy To 0, ;
    nTop To 0, nLeft To 0, nBottom To MaxRow() -1, nRight To MaxCol()
  If yes_clear
    Keyboard ''
  Endif
  Private name_view_file := Upper( mfile )
  If _upr_w_edit() // Выводить сразу в Windows-редактор без отображения в DOS-е
    ft_use( mfile )
    prn_window( mregim )
    ft_use()
    Return Nil
  Endif
  tmp_help := if( Type( 'chm_help_code' ) == 'N', chm_help_code, help_code )
  chm_help_code := help_code := t_help
  // для новой HELP-системы
  tmp_nhelp := ret_nhelp_code()
  nhelp_code := t_nhelp
  Save Screen To buf
  SetCursor( 0 )
  SetColor( mcolor )
  s_msg += if( fl_right, '  ', '' ) + ' - просмотр'
  Default plus_msg To PadL( '<F1> - помощь ', 77 - Len( s_msg ) )
  s_msg += if( !Empty( plus_msg ), ';  ', '' ) + plus_msg
  s_msg := PadR( s_msg, 80 )
  stat_msg( s_msg, .f. )
  mark_keys( { '<Esc>', '  <Home> <End> <PgUp> <PgDn>', ' ', '<F1>' } )
  If !( nTop == 0 .and. nLeft == 0 )
    box_shadow( nTop -1, nLeft -1, nBottom + 1, nRight + 1 )
  Endif
  lwidth := nRight + 1 - nLeft
  oBrowse := TBrowseNew( nTop, nLeft, nBottom, nRight )
  If !Empty( title )
    title := Center( title, lwidth )
  Endif
  oColumn := TBColumnNew( title, {|| str_v_text( j ) } )
  oColumn:width := lwidth
  oBrowse:addcolumn( oColumn )
  // сохраним клавиши управления
  AAdd( arr_keys, { K_F2, nil } )
  AAdd( arr_keys, { K_F3, nil } )
  AAdd( arr_keys, { K_F4, nil } )
  AAdd( arr_keys, { K_F7, nil } )
  AAdd( arr_keys, { K_F8, nil } )
  AAdd( arr_keys, { K_F9, nil } )
  AAdd( arr_keys, { K_F10, nil } )
  AAdd( arr_keys, { K_CTRL_F4, nil } )
  For i := 1 To Len( arr_keys )
    arr_keys[ i, 2 ] := SetKey( arr_keys[ i, 1 ], NIL )
  Next
  //
  If !Empty( title )
    oBrowse:headSep := '═╤═'
    nTop := 2
  Endif
  //
  oBrowse:colorSpec := mcolor
  oBrowse:goTopBlock := {|| ft_gotop() }
  oBrowse:goBottomBlock := {|| ft_gobottom() }
  oBrowse:skipBlock := {|nSkip, nVar|  nVar := ft_recno(), ft_skip( nSkip ), ;
    ft_recno() - nVar }
  Do While .t.
    lCont := .t. ; lEdit := .f.
    fl_mouse := setposmouse()
    ft_use( mfile )
    If++j1 == 1 .and. Type( 'recno_v_text' ) == 'N' .and. recno_v_text > 1
      ft_goto( recno_v_text )  // если надо, сразу переместиться на нужную строку
    Endif
    Do While lCont
      If nKey != 0
        oBrowse:forcestable()  // стабилизация
        If oBrowse:hitBottom .or. oBrowse:hitTop
          // TONE( 200, 1 )
        Endif
        ft_MShowCrs( fl_mouse )
      Endif
      nKey := 0
      /*if fl_mouse .and. (km := FT_MGETPOS()) == 1
        x_mouse := FT_MGETX() ; y_mouse := FT_MGETY()
        if y_mouse == 24
          do case
            case between(x_mouse,2,4)   ; nKey := K_ESC
            case x_mouse == 17          ; nKey := K_UP
            case x_mouse == 19          ; nKey := K_DOWN
            case between(x_mouse,22,25) ; nKey := K_HOME  ; clear_mouse()
            case between(x_mouse,29,31) ; nKey := K_END   ; clear_mouse()
            case between(x_mouse,35,38) ; nKey := K_PGUP  ; clear_mouse()
            case between(x_mouse,42,45) ; nKey := K_PGDN  ; clear_mouse()
            case x_mouse == 48          ; nKey := K_LEFT  ; clear_mouse()
            case x_mouse == 50          ; nKey := K_RIGHT ; clear_mouse()
            //case between(x_mouse,67,68) .and. fl_plus
              //clear_mouse(); FT_MHIDECRS(fl_mouse); help(); FT_MSHOWCRS(fl_mouse)
          endcase
        endif
      endif*/
      If nKey == 0
        nKey := inkeytrap()
      Endif
      Do Case
      Case nKey == K_RIGHT .and. fl_right
        ft_MHideCrs( fl_mouse )
        j += 10
        oBrowse:refreshall()
      Case nKey == K_LEFT .and. fl_right .and. j > 1
        ft_MHideCrs( fl_mouse )
        j -= 10
        oBrowse:refreshall()
      Case nKey == K_UP
        ft_MHideCrs( fl_mouse )
        oBrowse:up()
      Case nKey == K_DOWN
        ft_MHideCrs( fl_mouse )
        oBrowse:down()
      Case nKey == K_PGUP
        ft_MHideCrs( fl_mouse )
        oBrowse:pageup()
      Case nKey == K_PGDN
        ft_MHideCrs( fl_mouse )
        oBrowse:pagedown()
      Case nKey == K_HOME .or. nkey == K_CTRL_HOME
        ft_MHideCrs( fl_mouse )
        oBrowse:gotop()
      Case nKey == K_END .or. nkey == K_CTRL_END
        ft_MHideCrs( fl_mouse )
        buf1 := save_maxrow()
        mywait()
        oBrowse:gobottom()
        rest_box( buf1 )
      Case nKey == K_F3 .and. !Empty( mf_print ) // "разрезать" лист для раздельной печати.
        cutdocument( mfile, mregim )
        oBrowse:refreshall()
      Case nKey == K_F2 // вывести информацию о документе.
        infodocument( mfile, mregim )
      Case nKey == K_F4 .and. yes_edit .and. !Empty( mf_print ) // редактирование
        lCont := .f.
        lEdit := .t.
      Case nKey == K_ESC
        lCont := .f.
      Case nKey != 0 .and. !Empty( mf_print )
        s := mf_print + '(' + lstr( nKey ) + ',' + ;
          lstr( mregim ) + ',' + ;
          '"' + pr_func + '",' + ;
          '"' + name_file + '",'
        If !Empty( yes_FF )
          s += '"' + XToC( yes_FF ) + '"'
        Endif
        s += ')'
        if &( s )
          oBrowse:refreshall()   // функция должна возвратить .t. для
        Endif                    // обновления TBrowse, иначе .f.
        If count_copy > 0 .and. eq_any( nKey, K_F7, K_F8, K_F9 )
          If++raz >= count_copy
            lCont := .f.
          Endif
        Endif
        nKey := 256
      Endcase
    Enddo
    ft_use()
    If fl_mouse
      clear_mouse()
      ft_MHideCrs()
    Endif
    If lEdit
      vieweditor( mfile )
      oBrowse:refreshall()
    Else
      Exit
    Endif
  Enddo
  SetColor( tmp_color )
  Restore Screen From buf
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  // восстановим клавиши управления
  For i := 1 To Len( arr_keys )
    If arr_keys[ i, 2 ] != NIL
      SetKey( arr_keys[ i, 1 ], arr_keys[ i, 2 ] )
    Endif
  Next
  Return Nil

// редактирование файла
Function vieweditor( name_file )

  Local s, buf := SaveScreen(), tmp_color := SetColor(), ;
    tmp_help, tmp_nhelp, width, bSaveHandler
  local oError

  If !File( name_file )
    Return func_error( 'На диске нет файла ' + name_file )
  Endif
  tmp_help := if( Type( 'chm_help_code' ) == 'N', chm_help_code, help_code )
  mywait()
  If !Empty( s := _upr_dosedit() )  // внешний редактор
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    Begin Sequence
      Run ( s + ' ' + name_file )
    RECOVER USING oError
      func_error( 'Ошибка запуска внешнего редактора' )
    End
    // Восстановление начальной программы обработки ошибок
    ErrorBlock( bSaveHandler )
  Else  // внутренний редактор
    ft_use( name_file )
    width := ft_strlen()
    ft_use()
    //
    SetKey( K_ESC, {|| __Keyboard( Chr( 23 ) ) } )  // KS_CTRL_W
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    Begin Sequence
      s := MemoRead( name_file )
      status_key( '^<Esc>^ - выход для просмотра/печати;  ^<F1>^ - помощь' )
      chm_help_code := help_code := 10  // H_MemoEdit
      // для новой HELP-системы
      tmp_nhelp := ret_nhelp_code()
      nhelp_code := 'MemoEdit'
      pr_1_str( 'Редактирование файла ' + Upper( name_file ) )
      SetColor( 'W+/B, B/BG' )
      SetCursor()
      s := MemoEdit( s, 1, 0, 23, 79, .t., , width )
      s := StrTran( s, Hos, eos ) // atrepl(Hos,@s,eos)
      MemoWrit( name_file, s )
    RECOVER USING oError
      func_error( 4, 'Ошибка запуска внутреннего редактора' )
    End
    // Восстановление начальной программы обработки ошибок
    ErrorBlock( bSaveHandler )
    chm_help_code := help_code := tmp_help
    nhelp_code := tmp_nhelp
    SetKey( K_ESC, NIL )
  Endif
  SetCursor( 0 )
  RestScreen( buf )
  SetColor( tmp_color )
  Return Nil

//
Function infodocument( name_file, reg_print )

  Local buf := SaveScreen(), tmp_color := SetColor(), ;
    r1 := 10, c1 := 10, c2 := 69, cregim, ;
    tmp_help, tmp_nhelp, CountPage

  If !File( name_file )
    Return func_error( 'На диске нет файла ' + name_file )
  Endif
  tmp_help := if( Type( 'chm_help_code' ) == 'N', chm_help_code, help_code )
  chm_help_code := help_code := -1
  // для новой HELP-системы
  tmp_nhelp := ret_nhelp_code()
  nhelp_code := 'InfoDocum'
  mywait()
  If !Between( reg_print, 1, 6 )
    reg_print := 1
  Endif
  If equalany( reg_print, 1, 4 )
    cregim := 'Pica'
  Elseif equalany( reg_print, 2, 5 )
    cregim := 'Elite'
  Else
    cregim := 'Condensed'
  Endif
  If reg_print < 4
    cregim += '  6 lpi'
  Else
    cregim += '  8 lpi'
  Endif
  If Type( 'yes_albom' ) == 'L' .and. yes_albom
    cregim += ' (альбомная печать)'
  Endif
  CountPage := ft_countpage()
  box_shadow( r1, c1, r1 + 8, c2, 'N/BG, W+/N', 'Информация о документе ' + name_file, 'W+/BG' )
  SetColor( 'N/BG, W+/N, , , B/BG' )
  @ r1 + 2, c1 + 2 Say 'Размер файла - ' + expand_value( ft_filesize() ) + ' байт'
  @ r1 + 3, c1 + 2 Say 'Ширина документа - ' + lstr( ft_strlen() ) + ' символов'
  @ r1 + 4, c1 + 2 Say 'Длина документа - ' + lstr( ft_lastrec() ) + ' строк'
  @ r1 + 5, c1 + 2 Say 'Количество листов в документе - ' + lstr( CountPage )
  @ r1 + 6, c1 + 2 Say 'Режим печати - ' + cregim
  status_key( '^<Esc>^ - выход' )
  inkeytrap( 0 )
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  RestScreen( buf )
  SetColor( tmp_color )
  Return Nil

//
Function cutdocument( name_file, reg_print )

  Local i, buf := SaveScreen(), tmp_color := SetColor(), ;
    r1 := 10, c1 := 10, c2 := 69, smsg := 'часть начинается с позиции', ;
    tmp_help, tmp_nhelp, width, fl := .f.

  tmp_help := if( Type( 'chm_help_code' ) == 'N', chm_help_code, help_code )
  chm_help_code := help_code := -1
  // для новой HELP-системы
  tmp_nhelp := ret_nhelp_code()
  nhelp_code := 'CutDocum'
  Private m2 := _p_list_2, m3 := _p_list_3, m4 := _p_list_4, ;
    m5 := _p_list_5, m6 := _p_list_6
  width := ft_strlen()
  box_shadow( r1, c1, r1 + 10, c2, 'N/BG, W+/N', 'Разрезание документа ' + name_file, 'W+/BG' )
  SetColor( 'N/BG, W+/N, , , B/BG' )
  @ r1 + 2, c1 + 2 Say 'Ширина документа - ' + lstr( width ) + ' символов'
  @ r1 + 3, c1 + 2 Say 'Документ при печати можно разделить на 2 (6) частей:' Color 'B/BG'
  @ r1 + 4, c1 + 2 Say PadR( 'Вторая',10 ) + smsg Get m2 Pict '999'
  @ r1 + 5, c1 + 2 Say PadR( 'Третья',10 ) + smsg Get m3 Pict '999'
  @ r1 + 6, c1 + 2 Say PadR( 'Четвертая', 10 ) + smsg Get m4 Pict '999'
  @ r1 + 7, c1 + 2 Say PadR( 'Пятая',10 ) + smsg Get m5 Pict '999'
  @ r1 + 8, c1 + 2 Say PadR( 'Шестая',10 ) + smsg Get m6 Pict '999'
  status_key( '^<Esc>^ - выход;  ^<Enter>^ - запомнить настройки' )
  myread()
  If LastKey() != K_ESC .and. m2 >= 0 .and. m3 >= 0
    For i := 2 To 6
      fl := vcutdocument( i, width )
      If !fl
        Exit
      Endif
    Next
    If fl
      _p_list_2 := m2
      _p_list_3 := m3
      _p_list_4 := m4
      _p_list_5 := m5
      _p_list_6 := m6
    Endif
  Endif
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  RestScreen( buf )
  SetColor( tmp_color )
  Return Nil

//
Static Function vcutdocument( i, width )

  Local fl := .t., pole1 := 'm' + lstr( i ), pole2 := 'm' + lstr( i -1 )

  If i > 2
    if &pole1 > 0 .and. &pole1 -1 <= &pole2
      fl := func_error( 4, 'Неверная позиция ' + lstr( i ) + '-й части!' )
    Endif
  Endif
  If fl .and. &pole1 > width
    fl := func_error( 4, 'Слишком большое ' + lstr( i ) + '-е значение!' )
  Endif
  Return fl

//
Function str_v_text( lj )

  Local s := ft_readln(), s1, ls

  If _p_list_2 == 0 .or. s == Chr( 12 ) .or. s == 'FF'
    s := SubStr( s, lj )
  Else
    ls := Chr( 221 ) + Chr( 27 ) + Chr( 26 ) + Chr( 222 )
    s1 := SubStr( s + Space( _p_list_2 ), 1, _p_list_2 -1 ) + ls
    If _p_list_3 == 0
      s1 += SubStr( s, _p_list_2 )
    Else
      s1 += SubStr( s + Space( _p_list_3 ), _p_list_2, _p_list_3 - _p_list_2 ) + ls
      If _p_list_4 == 0
        s1 += SubStr( s, _p_list_3 )
      Else
        s1 += SubStr( s + Space( _p_list_4 ), _p_list_3, _p_list_4 - _p_list_3 ) + ls
        If _p_list_5 == 0
          s1 += SubStr( s, _p_list_4 )
        Else
          s1 += SubStr( s + Space( _p_list_5 ), _p_list_4, _p_list_5 - _p_list_4 ) + ls
          If _p_list_6 == 0
            s1 += SubStr( s, _p_list_5 )
          Else
            s1 += SubStr( s + Space( _p_list_6 ), _p_list_5, _p_list_6 - _p_list_5 ) + ls
            s1 += SubStr( s, _p_list_6 )
          Endif
        Endif
      Endif
    Endif
    s := SubStr( s1, lj )
  Endif
  Return s
