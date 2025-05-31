#include "inkey.ch"
#include "function.ch"

Static max_FR_date_dbf := 9

#define lat_find   70   // <F>ind
#define lat_lfind 102   // f
#define rus_find  128   // русская "А" на том же месте, что и F
#define rus_lfind 160   // а
#define lat_next   78   // <N>ext
#define lat_lnext 110   // n
#define rus_next  146   // русская "Т" на том же месте, что и N
#define rus_lnext 226   // т

// вызывается по умолчанию из viewtext для печати файла
// Обрабатываемые клавиши:
// <F6> - встать на указанный лист (перемещение
// документа в окне просмотра на определенный лист).
// <F7> - печать указанного листа.
// <F8> - печать нескольких листов (с какого-то
// по какой-то; для печати до конца документа введите
// второе значение = 9999).
// <F9> - печать всего документа.
//
Function pr_view( keystroke, regim, inst_print, name_file, yes_FF, is_question )

  Local s, s1, fl := .f., rec1 := ft_recno(), buf := save_maxrow(), ;
    nepr_print, tm, m_nlq := 0, kol_list, lport := 1, is_albom, ;
    k := 0, l_margin := "", _i, t_list, sh1, sh2, sh3, sh4, sh5, ;
    fl_exit, rec, fl_begin, sh

  If keystroke == K_F10
    export_to_win_editor()
    ft_goto( rec1 )
    rest_box( buf )
    Return .t.
  Endif
  Default is_question To .t. // задавать вопросы перед печатью
  If !eq_any( keystroke, K_F9, K_F8, K_F7, K_F6, K_CTRL_PGUP, K_CTRL_PGDN, ;
      lat_find, rus_find, lat_next, rus_next, ;
      lat_lfind, rus_lfind, lat_lnext, rus_lnext )
    Return .f.
  Endif
  If !( Type( "_p_list_2" ) == "N" )
    Private _p_list_2 := 0, _p_list_3 := 0, ;
      _p_list_4 := 0, _p_list_5 := 0, _p_list_6 := 0
  Endif
  is_albom := _upr_isalbom()
  yes_FF := _upr_yes_ff( yes_FF )
  // name_file := "ttt.txt"   // для отладки
  Do Case
  Case keystroke == K_F9  // весь документ
    tm := { .t., 1, 9999 }
    ft_gotop()
  Case keystroke == K_F8  // с какого-то листа по какой-то лист
    tm := input_list( 2 )
  Case keystroke == K_F7  // один лист
    tm := input_list( 1 )
  Case keystroke == K_F6  // встать на лист
    tm := input_list( 1 )
    fl := tm[ 1 ]
  Case keystroke == K_CTRL_PGUP  // на предыдущий лист
    fl := find_list( -1 )
  Case keystroke == K_CTRL_PGDN  // на следующий лист
    fl := find_list( 1 )
  Case equalany( keystroke, lat_find, rus_find, lat_lfind, rus_lfind )
    fl := find_stroke( 1 )
  Case equalany( keystroke, lat_next, rus_next, lat_lnext, rus_lnext )
    fl := find_stroke( 2 )
  Endcase
  If eq_any( keystroke, K_F7, K_F8, K_F9 ) .and. tm[ 1 ]
    If _upr_windows() // печать через Windows
      prn_window( regim, tm, is_albom )
      ft_goto( rec1 )
      rest_box( buf )
      Return fl
    Endif
    s := inst_print
    If regim == 8  // Condensed суперкомпакт
      k := 17
      inst_print := "Condensed"
      m_nlq := 1
    Elseif regim % 3 == 0  // Condensed
      k := 17
      inst_print := "Condensed"
      m_nlq := 1
    Elseif regim % 3 == 2  // Elita
      k := 12
      inst_print := "Elite"
    Elseif regim % 3 == 1  // Pica
      k := 10
      inst_print := "Pica"
    Endif
    inst_print += iif( regim < 4, "6", "8" )
    If !Empty( s ) // если на входе другая функция управления кодами принтера
      inst_print := s
    Endif
    If k > 0 // расчет левого отступа
      If ( k := Round( _upr_otstup() * k / 2.54, 0 ) ) > 0
        l_margin := Space( k )
      Endif
    Endif
    // 
    end_print := .f.
    kol_list := tm[ 3 ] - tm[ 2 ] + 1
    lport := _upr_port()
    nepr_print := ( _upr_nepr() == 2 )
    If is_question // задать вопросы
      fl_begin := ( m_nlq := yes_nlq( m_nlq, _upr_epson() ) ) > 0 .and. ;
        if( Empty( name_file ), print_flag( lport ), .t. )
    Else  // просто проверить порт принтера
      m_nlq := 1 ; _p_list_2 := 0 ; nepr_print := .t.
      If !( fl_begin := PrintReady( lport ) )
        stat_msg( 'Принтер не готов.' )
        mybell( 1 )
      Endif
    Endif
    If ( fl := fl_begin )
      status_key( "^<Esc>^ - прекращение печати" )
      Set Device To Print
      If !Empty( name_file )
        set printer to &(name_file)
      Elseif lport == 2
        Set Printer To LPT2
      Endif
      put_code( _upr_init() )
      If is_albom
        put_code( _upr_albom() )  // включить альбомную печать ESC+"&l1O"
      Endif
      SetPRC( 0, 0 )
      k := &( inst_print + "(1)" )
      If m_nlq == 2
        put_code( _upr_nlq() )
      Endif
      Private bSaveHandler := ErrorBlock( {| x| Break( x ) } )
      Begin Sequence
        If _p_list_2 == 0 // обычная печать
          sh := 0
          Do While !ft_eof()
            s := ft_readln()
            If f_stroke_next_page( s )
              kol_list--
              If kol_list == 0 ; exit ; Endif
              If nepr_print ; myeject(, yes_FF,, sh )
              else          ; myeject( 1, yes_FF,, sh )
              Endif
            Else
              @ PRow() + 1, 0 Say l_margin + s
              sh := Max( sh, Len( l_margin + s ) )
            Endif
            If stop_print()
              fl := .f.
              Exit
            Endif
            ft_skip()
          Enddo
        Else  // "разрезание" листа на части при печати
          fl_exit := .f.
          t_list := retshcut( @sh1, @sh2, @sh3, @sh4, @sh5 )
          Do While !ft_eof()
            rec := ft_recno()
            For _i := 1 To t_list
              If _i > 1
                ft_goto( rec )
              Endif
              Do While .t.
                s := ft_readln()
                If f_stroke_next_page( s ) .or. ft_eof()
                  If _i == t_list
                    kol_list--
                    If kol_list == 0
                      fl_exit := .t.
                      Exit
                    Endif
                  Endif
                  If iif( _i == t_list, !ft_eof(), .t. )
                    If nepr_print ; myeject(, yes_FF, iif( _i == t_list, 0, _i + 1 ), sh )
                    else          ; myeject( 1, yes_FF, iif( _i == t_list, 0, _i + 1 ), sh )
                    Endif
                    ft_skip()
                  Endif
                  Exit
                Else
                  s1 := rets1cut( _i, s, sh1, sh2, sh3, sh4, sh5 )
                  @ PRow() + 1, 0 Say l_margin + s1
                  sh := Len( l_margin + s1 )
                Endif
                If stop_print()
                  fl_exit := .t.
                  Exit
                Endif
                ft_skip()
              Enddo
              If fl_exit ; exit ; Endif
            Next
            If fl_exit ; exit ; Endif
          Enddo
          fl := !fl_exit
        Endif
        Set Device To Print
        myeject(, yes_FF )
        If m_nlq == 2
          put_code( _upr_draft() )
        Endif
        If is_albom
          put_code( _upr_portr() )  // включить портретную печать ESC+"&l0O"
        Endif
        k := &( inst_print + "(2)" )
        If !Empty( name_file ) .or. lport == 2
          Set Printer To
        Endif
      RECOVER USING error
        Set Device To Screen
        fl := func_error( "Ошибка принтера" )
      End
      // Восстановление начальной программы обработки ошибок
      ErrorBlock( bSaveHandler )
      Set Device To Screen
    Endif
    ft_goto( rec1 )
  Endif
  rest_box( buf )

  Return fl

//
Static Function input_list( par )

  Static nom_list := 1
  Local rec1 := ft_recno(), flag := .f., buf, nom2_list, ;
    buf1 := save_maxrow(), i := 1, tmp_color := SetColor( color0 + ",,,B/BG" )

  status_key( "^<Esc>^ - отказ;  ^<Enter>^ - подтверждение ввода" )
  If par == 1
    buf := box_shadow( 20, 20, 22, 59 )
    @ 21, 28 Say "Введите номер листа" Get nom_list Picture "9999"
  Elseif par == 2
    nom2_list := nom_list
    buf := box_shadow( 20, 2, 22, 77 )
    @ 21, 11 Say "Введите, с какого" Get nom_list Picture "9999"
    @ 21, 34 Say "по какой" Get nom2_list Picture "9999" Range nom_list, 9999
    @ 21, 48 Say "лист печатать документ"
  Endif
  myread( { "confirm" } )
  If LastKey() != K_ESC
    ft_gotop()
    If nom_list == 1
      flag := .t.
    Else
      mywait()
      Do While !ft_eof()
        s := ft_readln()
        If f_stroke_next_page( s )
          If++i == nom_list
            flag := .t.
            ft_skip()
            Exit
          Endif
        Endif
        ft_skip()
      Enddo
    Endif
    If !flag
      func_error( 3, "Нет такого листа" )
      ft_goto( rec1 )
    Endif
  Endif
  rest_box( buf )
  rest_box( buf1 )
  SetColor( tmp_color )
  If par == 1
    nom2_list := nom_list
  Endif

  Return { flag, nom_list, nom2_list }

//
Static Function find_list( k )

  Local rec1 := ft_recno(), fl := .f., buf := save_maxrow(), i := 0

  mywait()
  If k == 1  // следующий лист
    If ft_recno() < ft_lastrec()
      fl := .t.
      Do While !ft_eof()
        If++i > 1 .and. f_stroke_next_page( ft_readln() )
          Exit
        Endif
        ft_skip()
      Enddo
    Endif
    If ft_recno() == ft_lastrec()
      Keyboard Chr( K_END )
    Endif
  Else  // предыдущий лист
    If ft_recno() > 1
      fl := .t.
      Do While ft_recno() > 1
        If++i > 1 .and. f_stroke_next_page( ft_readln() )
          Exit
        Endif
        ft_skip( -1 )
      Enddo
    Endif
    If ft_recno() == 1
      Keyboard Chr( K_HOME )
    Endif
  Endif
  If !fl
    ft_goto( rec1 )
    // mybell()
  Endif
  rest_box( buf )

  Return fl

// 05.10.17
Static Function find_stroke( par )

  Static str_find := ""
  Local rec1 := ft_recno(), fl := .f., buf := save_maxrow(), k, arr := {}

  If par == 1
    If ( k := input_value( 20, 2, 22, 77, color0, ;
        "Введите ключ для поиска", PadR( str_find, 48 ), "@K@!" ) ) != NIL
      If !Empty( k )
        fl := .t.
        str_find := AllTrim( Upper( k ) )
      Endif
    Endif
  Elseif par == 2
    If !Empty( str_find )
      fl := .t.
    Endif
  Endif
  If fl
    For k := 1 To NumToken( str_find, "|" )
      AAdd( arr, AllTrim( Token( str_find, "|", k ) ) )
    Next
    fl := .f.
    mywait()
    If par == 2
      ft_skip()
    Endif
    Do While !ft_eof()
      s := Upper( ft_readln() )
      For k := 1 To Len( arr )
        If arr[ k ] $ s
          fl := .t.
        Endif
      Next
      If fl ; exit ; Endif
      ft_skip()
    Enddo
    If !fl
      func_error( 3, "Неудачный поиск!" )
      ft_goto( rec1 )
    Endif
    rest_box( buf )
  Endif

  Return fl

//
Static Function retshcut( sh1, sh2, sh3, sh4, sh5 )

  Static max_sh := 768
  Local t_list := 2

  sh1 := _p_list_2
  If _p_list_3 == 0
    sh2 := max_sh
  Else
    t_list := 3 ; sh2 := _p_list_3
    If _p_list_4 == 0
      sh3 := max_sh
    Else
      t_list := 4 ; sh3 := _p_list_4
      If _p_list_5 == 0
        sh4 := max_sh
      Else
        t_list := 5 ; sh4 := _p_list_5
        If _p_list_6 == 0
          sh5 := max_sh
        Else
          t_list := 6 ; sh5 := _p_list_6
        Endif
      Endif
    Endif
  Endif

  Return t_list

//
Static Function rets1cut( i, s, sh1, sh2, sh3, sh4, sh5 )

  Local s1 := ""

  If i == 1
    s1 := Left( s, sh1 - 1 )
  Elseif i == 2
    s1 := SubStr( s, sh1, sh2 - sh1 )
  Elseif i == 3
    s1 := SubStr( s, sh2, sh3 - sh2 )
  Elseif i == 4
    s1 := SubStr( s, sh3, sh4 - sh3 )
  Elseif i == 5
    s1 := SubStr( s, sh4, sh5 - sh4 )
  Else
    s1 := SubStr( s, sh5 )
  Endif

  Return s1

//
Function pica6()

  put_code( _upr_10cpi() )

  Return Nil

//
Function elite6( k )

  If k == 1
    put_code( _upr_12cpi() )
  Else
    put_code( _upr_10cpi() )
  Endif

  Return Nil

//
Function condensed6( k )

  If k == 1
    put_code( _upr_17cpi() )
  Else
    put_code( _upr_10cpi() )
  Endif

  Return Nil

//
Function pica8( k )

  If k == 1
    put_code( _upr_8lpi() ) ; put_code( _upr_10cpi() )
  Else
    put_code( _upr_6lpi() ) ; put_code( _upr_10cpi() )
  Endif

  Return Nil

//
Function elite8( k )

  If k == 1
    put_code( _upr_8lpi() ) ; put_code( _upr_12cpi() )
  Else
    put_code( _upr_6lpi() ) ; put_code( _upr_10cpi() )
  Endif

  Return Nil

//
Function condensed8( k )

  If k == 1
    put_code( _upr_8lpi() ) ; put_code( _upr_17cpi() )
  Else
    put_code( _upr_6lpi() ) ; put_code( _upr_10cpi() )
  Endif

  Return Nil

//
Static Function yes_nlq( k, is_epson )

  Static mnlq := 1
  Local m := mnlq, tmp_color := SetColor( color0 ), buf

  If is_epson
    If k == 0
      buf := box_shadow( 11, 6, 15, 72,, "Выбор режима печати" )
      @ 13, 12 Prompt " Обычная печать (Draft) "
      @ 13, 39 Prompt " Качественная печать (NLQ) "
      Menu To m
      If m > 0
        mnlq := m
      Endif
      rest_box( buf )
    Else
      m := k
    Endif
  Else
    m := 1
  Endif
  SetColor( tmp_color )

  Return m

//
Static Function put_code( s )

  Local kol, j, s1

  If ( kol := NumToken( s, " " ) ) == 0
    Return Nil
  Endif
  For j := 1 To kol
    s1 := Int( Val( Token( s, " ", j ) ) )
    @ PRow(), PCol() Say Chr( s1 )
  Next

  Return Nil

//
Function export_to_win_editor()

  Local k, s, name_win := "WIN_FILE.txt"

  Delete File ( name_win )
  If File( name_win )
    Return func_error( 4, "Файл с именем " + name_win + " открыт другим приложением" )
  Endif
  mywait()
  fp := FCreate( name_win )
  ft_gotop()
  Do While !ft_eof()
    s := ft_readln()
    If f_stroke_next_page( s )
      add_string( Chr( 12 ) )
    Else
      add_string( hb_OEMToANSI( s ) )
    Endif
    ft_skip()
  Enddo
  FClose( fp )
  k := _upr_winedit()
  If !Between( k, 0, 2 )
    k := 0
  Endif
  s := { "write.exe", "Winword.exe", "swriter.exe" }[ k + 1 ]
  stat_msg( "Выгрузка файла в редактор " + s )
  // ShellExecute(GetDeskTopWindow(),'open',s,cur_dir+'\'+name_win,,1)
  shellexecute( getdesktopwindow(), 'open', s, name_win,, 1 )

  Return Nil

#include "FastRepH.ch"

// 09.03.19
Function prn_window( regim, tm, is_albom )

  Default tm TO { .t., 1, 9999 }, is_albom To _upr_isalbom()
  Private lShowCustName := .t.
  Private FrPrn := frreportmanager():new(, .t. ) // .t. ошибки выводятся в OEM кодировке
  FrPrn:seticon( "MAIN_ICON" )
  If Type( "name_view_file" ) == "C"
    FrPrn:settitle( fr_oemtoansi( Lower( name_view_file ) ) )
  Endif
  FrPrn:startmanualbuild( {|| mytxtfr( regim, tm, is_albom ) }, iif( is_albom, 1, 0 ), , FR_CM )
  FrPrn:showreport()
  FrPrn:cleardatasets()
  lShowCustName := .f.
  FrPrn:destroyfr()

  Return

//
Procedure mytxtfr( iRegim, tm, is_albom )

  Local msize, len_stroke, kol_list, s, s1, nwidth, widthList, _top, ;
    nLeft, nRight, nTop, nBottom, ;
    nlpi := 2.54 / iif( iRegim < 4, 6, 8 ) * 1.05, ; // перевод 6 или 8 lpi в см
    rec, _i, t_list, sh1, sh2, sh3, sh4, sh5, fl_exit
  //
  If iRegim == 8
    nlpi := 2.54 / iif( iRegim < 4, 6, 9 ) * 1.05 // перевод 6 или 8 lpi в см
    iRegim := 6
  Endif
  kol_list := tm[ 3 ] - tm[ 2 ] + 1
  len_stroke := ft_strlen()
  FrPrn:setdefaultfontproperty( "Name", "Lucida Console" )
  If iRegim = 1 .or. iRegim = 4    // Pica
    msize := iif( len_stroke < 65, 12, 11 )
  Elseif iRegim = 2  // Elite
    msize := iif( len_stroke < 85, 10, 9 )
  Elseif iRegim = 5  // Elite
    msize := 9
  Elseif iRegim = 3 .or. iRegim = 6  // Condensed
    // FrPrn:SetDefaultFontProperty("Style", 1) // Bold
    msize := iif( len_stroke < 110, 8, 7 )
  Endif
  FrPrn:setdefaultfontproperty( "Size", msize )
  If is_albom
    widthList := 29.7
    nLeft   := _upr_otstup( "b" )
    nright  := _upr_otstup( "t" )
    nTop    := _upr_otstup( "l" )
    nBottom := _upr_otstup( "r" )
  Else
    widthList := 21
    nLeft   := _upr_otstup( "l" )
    nright  := _upr_otstup( "r" )
    nTop    := _upr_otstup( "t" )
    nBottom := _upr_otstup( "b" )
  Endif
  _top := nTop
  nWidth := widthList - nLeft - nright
  If _p_list_2 == 0 // обычная печать
    Do While !ft_eof()
      s := ft_readln()
      If f_stroke_next_page( s )
        If--kol_list == 0 ; exit ; Endif
        FrPrn:newpage()
        _top := nTop
      Else
        FrPrn:memoat( fr_oemtoansi( s ), nLeft, _top, nWidth, nlpi )
        _top += nlpi
      Endif
      ft_skip()
    Enddo
  Else  // "разрезание" листа на части при печати
    fl_exit := .f.
    t_list := retshcut( @sh1, @sh2, @sh3, @sh4, @sh5 )
    Do While !ft_eof()
      rec := ft_recno()
      For _i := 1 To t_list
        If _i > 1
          ft_goto( rec )
          _top := nTop
        Endif
        Do While .t.
          s := ft_readln()
          If f_stroke_next_page( s ) .or. ft_eof()
            If _i == t_list
              If--kol_list == 0
                fl_exit := .t.
                Exit
              Endif
            Endif
            If iif( _i == t_list, !ft_eof(), .t. )
              FrPrn:newpage()
              _top := nTop
              ft_skip()
            Endif
            Exit
          Else
            s1 := rets1cut( _i, s, sh1, sh2, sh3, sh4, sh5 )
            FrPrn:memoat( fr_oemtoansi( s1 ), nLeft, _top, nWidth, nlpi )
            _top += nlpi
          Endif
          ft_skip()
        Enddo
        If fl_exit ; exit ; Endif
      Next
      If fl_exit ; exit ; Endif
    Enddo
  Endif

  Return

// конвертирует DOS-строку в WINDOWS-строку специально для FR
Function fr_oemtoansi( dos_str )

  Local len_str, i, cur_char, win_str := ""

  len_str := Len( dos_str )
  For i := 1 To len_str
    cur_asc := Asc( SubStr( dos_str, i, 1 ) )
    Do Case
    Case Between( cur_asc, 128, 175 )     // А-п
      cur_asc := cur_asc + 64
    Case Between( cur_asc, 176, 223 )
      If Between( cur_asc, 176, 182 )     // ░▒▓│┤╡╢
        cur_asc := 124               // |
      Elseif Between( cur_asc, 183, 184 ) // ╖╕
        cur_asc := 43                // +
      Elseif Between( cur_asc, 185, 186 ) // ╣║
        cur_asc := 124               // |
      Elseif Between( cur_asc, 187, 194 ) // ╗╝╜╛┐└┴┬
        cur_asc := 43                // +
      Elseif cur_asc == 195           // ├
        cur_asc := 124               // |
      Elseif cur_asc == 196           // ─
        cur_asc := 150               // -
      Elseif cur_asc == 197           // ┼
        cur_asc := 43                // +
      Elseif Between( cur_asc, 198, 199 ) // ╞╟
        cur_asc := 124               // |
      Elseif Between( cur_asc, 200, 203 ) // ╚╔╩╦
        cur_asc := 43                // +
      Elseif cur_asc == 204           // ╠
        cur_asc := 124               // |
      Elseif cur_asc == 205           // ═
        cur_asc := 150               // -
      Elseif Between( cur_asc, 206, 218 ) // ╬╧╨╤╥╙╘╒╓╫╪┘┌
        cur_asc := 43                // +
      Elseif cur_asc == 219           // █
        cur_asc := 124               // |
      Elseif cur_asc == 220           // ▄
        cur_asc := 95                // _
      Elseif Between( cur_asc, 221, 222 ) // ▌▐
        cur_asc := 124               // |
      Elseif cur_asc == 223           // ▀
        cur_asc := 126               // ~
      Endif
    Case Between( cur_asc, 224, 239 )     // р-я
      cur_asc := cur_asc + 16
    Case cur_asc == 91  // [
      cur_asc := 40    // (
    Case cur_asc == 93  // ]
      cur_asc := 41    // )
    Case cur_asc == 240 // Ё
      cur_asc := 168
    Case cur_asc == 241 // ё
      cur_asc := 184
    Case cur_asc == 252 // №
      cur_asc := 185
    Case cur_asc == 255 //
      cur_asc := 32
    End Case
    win_str += Chr( cur_asc )
  Next

  Return ( win_str )

// удалить файлы данных для отчетов FR ("_data.dbf" и "_titl.dbf")
Function delfrfiles()

  Local j, nfile

  Delete File ( fr_titl + sdbf )
  Delete File ( fr_data + sdbf )
  Delete File ( fr_data + sntx() )
  For j := 1 To max_FR_date_dbf
    nfile := fr_data + LTrim( Str( j ) )
    Delete File ( nfile + sdbf )
    Delete File ( nfile + sntx() )
  Next

  Return Nil

// 19.10.24 запустить генератор отчетов
Function call_fr( cFile_Otchet, ltip, cFile_Export, bMasterDetail, is_open )

  Static sExt := '.fr3'
  Local i, j, nfile, buf := SaveScreen(), tmp_select := Select(), fl, is_ot := .t.

  Default ltip To 1, cFile_Export To '', bMasterDetail TO { || .t. }, is_open To .t.
  //
  stat_msg( 'Ждите! Запуск генератора отчетов FastReport.' )
  // Now load and init FastReport
  Private FrPrn := frreportmanager():new(, .t. ), ; // .t. ошибки выводятся в OEM кодировке
    lShowCustName := .t.
  FrPrn:seticon( 'MAIN_ICON' )
  If File( fr_data + sdbf )
    Use ( fr_data ) NEW
    If File( fr_data + sntx() )
      Set Index to ( fr_data )
    Endif
    Go Top
    FrPrn:setworkarea( fr_data, Select(), .t. ) // .t. dbf-файл в OEM кодировке
  Endif
  If File( fr_titl + sdbf )
    Use ( fr_titl ) NEW
    Go Top
    FrPrn:setworkarea( fr_titl, Select(), .t. ) // .t. dbf-файл в OEM кодировке
  Endif
  For j := 1 To max_FR_date_dbf
    nfile := fr_data + LTrim( Str( j ) )
    If File( nfile + sdbf )
      Use ( nfile ) NEW
      If File( nfile + sntx() )
        Set Index to ( nfile )
      Endif
      Go Top
      FrPrn:setworkarea( nfile, Select(), .t. ) // .t. dbf-файл в OEM кодировке
    Endif
  Next
  Eval( bMasterDetail )
  If ValType( cFile_Otchet ) == 'C'
    If !( sExt $ Lower( cFile_Otchet ) )
      cFile_Otchet += sExt
    Endif
    If hb_FileExists( dir_exe + cFile_Otchet )
      FrPrn:loadfromfile( hb_OEMToANSI( dir_exe + cFile_Otchet ) )   // 14.09.17
      FrPrn:settitle( Lower( cFile_Otchet ) )
    Else
      is_ot := func_error( 4, 'Не обнаружен файл отчёта ' + dir_exe + cFile_Otchet )
    Endif
  Else
    fl := .t.
    For i := 1 To Len( cFile_Otchet )
      If !( sExt $ Lower( cFile_Otchet[ i ] ) )
        cFile_Otchet[ i ] += sExt
      Endif
      If hb_FileExists( dir_exe + cFile_Otchet[ i ] )
        FrPrn:loadfromfile( hb_OEMToANSI( dir_exe + cFile_Otchet[ i ] ) )
        FrPrn:loadfromfile( cFile_Otchet[ i ] )
        FrPrn:preparereport( iif( fl, nil, FR_NOTCLEARLASTREPORT ) )
        fl := .f.
      Else
        func_error( 4, 'Не обнаружен файл отчёта ' + dir_exe + cFile_Otchet[ i ] )
      Endif
    Next
    If fl
      is_ot := .f.
    Endif
  Endif
  Do Case
  Case ltip == 1 .and. is_ot
    If ValType( cFile_Otchet ) == 'C'
      FrPrn:showreport()
    Else
      FrPrn:showpreparedreport()
    Endif
  Case ltip == 2
    // FrPrn:DesignReport()
  Case ltip == 3 .and. is_ot
    Private cExpObj := 'XLSExport', cExpFile, cExtention := '.xls'
    If cFile_Export == NIL
      cExpFile := strippath( cFile_Otchet )
    Else
      cExpFile := cFile_Export
    Endif
    If ( j := At( '.', cExpFile ) ) > 0
      cExpFile := Left( cExpFile, j - 1 )
    Endif
    cExpFile += cExtention
    FrPrn:preparereport()
    // не запрашивать окно диалога
    FrPrn:setproperty( cExpObj, 'ShowDialog', .f. )
    // открыть Excel и загрузить в него отчет
    FrPrn:setproperty( cExpObj, 'OpenExcelAfterExport', is_open )
    // имя таблицы Excel, записываемой в текущий каталог
    FrPrn:setproperty( cExpObj, 'FileName', cExpFile )
    // запрет вывода заголовков страниц, начиная со 2-ой
    FrPrn:setproperty( cExpObj, 'SuppressPageHeadersFooters', .t. )
    // не выводить пустые строки
    FrPrn:setproperty( cExpObj, 'EmptyLines', .f. )
    // не делать перевод страниц
    FrPrn:setproperty( cExpObj, 'PageBreaks', .f. )
    FrPrn:doexport( cExpObj )
  Endcase
  FrPrn:cleardatasets()
  lShowCustName := .f.
  // Unload FastReport
  FrPrn:destroyfr()
  //
  If File( fr_data + sdbf )
    &fr_data.->( dbCloseArea() )
  Endif
  If File( fr_titl + sdbf )
    &fr_titl.->( dbCloseArea() )
  Endif
  For j := 1 To max_FR_date_dbf
    nfile := fr_data + LTrim( Str( j ) )
    If File( nfile + sdbf )
      &nfile.->( dbCloseArea() )
    Endif
  Next
  Select ( tmp_select )
  RestScreen( buf )
  Keyboard ''

  Return Nil

// 10.09.13
Static Function f_stroke_next_page( s )
  Return Left( s, 1 ) == '' .or. Left( s, 2 ) == 'FF'
