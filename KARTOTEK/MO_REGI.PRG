// mo_regi.prg функции подзадачи 'Регистратура'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

//
Function begin_task_regist()

  Static n_zapusk := 0
  Local fl := .t.

  If n_zapusk == 0
    ++n_zapusk
    regi_nastr( 1 )
  Endif
  If copy_tools_ini()
    tools_ini_oms( 1, 0, 0 )
  Else
    fl := .f.
  Endif

  Return fl

//
Function regi_stat( k )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 0
  Do Case
  Case k == 0
    mas_pmt := { '~Количество листов учета', ;
      '~Список листов учета', ;
      '~Новые пациенты' }
    mas_msg := { 'Подсчет количества листов учета', ;
      'Список зарегистрированных и распечатанных листов учета', ;
      'Журнал регистрации новых пациентов' }
    mas_fun := { 'regi_stat(1)', ;
      'regi_stat(2)', ;
      'regi_stat(3)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 1
    f1regi_stat()
  Case k == 2
    f2regi_stat( 1 )
  Case k == 3
    f2regi_stat( 2 )
  Endcase
  If k > 0
    si1 := k
  Endif

  Return Nil

//
Function f1regi_stat()

  Local arr_g, sh, HH := 57, reg_print := 1, n_file := cur_dir() + 'reg1stat.txt', ;
    buf := save_maxrow(), arr_otd := {}, arr_vp := {}, i, j1, j2, ;
    arr_p := {}, arr_title, ssumma := 0

  If ( arr_g := year_month() ) != NIL
    mywait()
    j1 := j2 := j3 := 0
    r_use( dir_server() + 'mo_regi', dir_server() + 'mo_regi2', 'RU' )
    dbSeek( arr_g[ 7 ], .t. )
    Do While ru->pdate <= arr_g[ 8 ]
      k := Asc( ru->kod_p )
      If ( i := AScan( arr_p, {| x| x[ 2 ] == k } ) ) == 0
        AAdd( arr_p, { ru->uch, k, 0, '' } )
        i := Len( arr_p )
      Endif
      arr_p[ i, 3 ] ++
      j3 := 1
      If ru->tip == 1
        If ( i := AScan( arr_otd, {| x| x[ 2 ] == ru->op } ) ) == 0
          AAdd( arr_otd, { ru->uch, ru->op, 0, '' } )
          i := Len( arr_otd )
        Endif
        arr_otd[ i, 3 ] ++
        j1 := 1
      Else
        If ( i := AScan( arr_vp, {| x| x[ 1 ] == ru->uch .and. x[ 2 ] == ru->op } ) ) == 0
          AAdd( arr_vp, { ru->uch, ru->op, 0, '' } )
          i := Len( arr_vp )
        Endif
        arr_vp[ i, 3 ] ++
        j2 := 1
      Endif
      Skip
    Enddo
    Close databases
    If emptyall( j1, j2, j3 )
      func_error( 4, 'Нет информации!' )
    Else
      AEval( arr_otd, {| x, i| arr_otd[ i, 4 ] := ;
        AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', x[ 2 ] ) ) + ;
        ' (' + AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', x[ 1 ] ) ) + ')' } )
      ASort( arr_otd, , , {| x, y| x[ 4 ] < y[ 4 ] } )
      //
      AEval( arr_vp, {| x, i| arr_vp[ i, 4 ] := ;
        AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'p_priem', x[ 2 ] ) ) + ;
        ' (' + AllTrim( inieditspr( A__POPUPMENU, dir_server() + 'mo_uch', x[ 1 ] ) ) + ')' } )
      ASort( arr_vp, , , {| x, y| x[ 4 ] < y[ 4 ] } )
      //
      r_use( dir_server() + 'base1', , 'BASE1' )
      For i := 1 To Len( arr_p )
        Goto ( arr_p[ i, 2 ] )
        If !Eof() .and. !Empty( base1->p1 )
          arr_p[ i, 4 ] := AllTrim( Crypt( base1->p1, gpasskod ) )
        Endif
      Next
      Use
      ASort( arr_p, , , {| x, y| Upper( x[ 4 ] ) < Upper( y[ 4 ] ) } )
      fp := FCreate( n_file )
      tek_stroke := 0
      n_list := 1
      arr_title := { ;
        '─────────────────────────────────────────────────────────┬──────', ;
        '                                                         │Кол-во', ;
        '─────────────────────────────────────────────────────────┴──────' }
      sh := Len( arr_title[ 1 ] )
      add_string( '' )
      add_string( Center( 'Количество листов учета', sh ) )
      add_string( Center( arr_g[ 4 ], sh ) )
      add_string( '' )
      AEval( arr_title, {| x| add_string( x ) } )
      If j1 > 0
        For i := 1 To Len( arr_otd )
          If arr_otd[ i, 3 ] > 0
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( PadR( arr_otd[ i, 4 ], 57 ) + Str( arr_otd[ i, 3 ], 7 ) )
            ssumma += arr_otd[ i, 3 ]
          Endif
        Next
      Endif
      add_string( Replicate( '─', sh ) )
      If j2 > 0
        For i := 1 To Len( arr_vp )
          If arr_vp[ i, 3 ] > 0
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( PadR( arr_vp[ i, 4 ], 57 ) + Str( arr_vp[ i, 3 ], 7 ) )
            ssumma += arr_vp[ i, 3 ]
          Endif
        Next
      Endif
      add_string( Replicate( '─', sh ) )
      If j3 > 0
        For i := 1 To Len( arr_p )
          If arr_p[ i, 3 ] > 0
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( PadR( arr_p[ i, 4 ], 57 ) + Str( arr_p[ i, 3 ], 7 ) )
          Endif
        Next
      Endif
      add_string( Replicate( '─', sh ) )
      add_string( PadL( 'И Т О Г О : ', 57 ) + Str( ssumma, 7 ) )
      FClose( fp )
      viewtext( n_file, , , , ( sh > 80 ), , , reg_print )
    Endif
    rest_box( buf )
  Endif

  Return Nil

//
Function f2regi_stat( par )

  Local arr_g, sh, HH := 58, reg_print := 2, n_file := cur_dir() + 'reg2stat.txt', ;
    buf := save_maxrow(), i, j1, arr_title, a_f[ 10 ], a_a[ 10 ], kf, ka, ;
    nf, na, a_o[ 10 ], ko

  If ( arr_g := year_month() ) != NIL
    mywait()
    j1 := 0
    fp := FCreate( n_file )
    tek_stroke := 0
    n_list := 1
    arr_title := { ;
      '──────────┬─────────────────────────┬──────────┬─────────────────────┬──────────────', ;
      '  Номер   │         Ф.И.О.          │   Дата   │        Адрес        │ Регистратор  ', ;
      'амб.карты │                         │ рождения │                     │              ', ;
      '──────────┴─────────────────────────┴──────────┴─────────────────────┴──────────────' }
    nf := 25
    na := 21
    no := 14
    sh := Len( arr_title[ 1 ] )
    add_string( '' )
    If par == 1
      add_string( Center( 'Список зарегистрированных листов учета', sh ) )
    Else
      add_string( Center( 'Журнал регистрации новых больных', sh ) )
      r_use( dir_server() + 'human', dir_server() + 'humankk', 'HU' )
    Endif
    add_string( Center( arr_g[ 4 ], sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    //
    r_use( dir_server() + 'base1', , 'BASE1' )
    r_use( dir_server() + 'kartotek', , 'KART' )
    r_use( dir_server() + 'mo_regi', dir_server() + 'mo_regi2', 'RU' )
    Set Relation To kod_k into KART
    dbSeek( arr_g[ 7 ], .t. )
    Index On Upper( kart->fio ) to ( cur_dir() + 'tmp_ru' ) While ru->pdate <= arr_g[ 8 ]
    Go Top
    Do While !Eof()
      fl := .t.
      If par == 2
        Select HU
        find ( Str( ru->kod_k, 7 ) )
        fl := !Found()
      Endif
      If fl
        lnomer := amb_kartan()
        kf := perenos( a_f, kart->fio, nf )
        ka := perenos( a_a, CharOne( ' ', kart->adres ), na )
        If ru->tip == 1
          ko := perenos( a_o, inieditspr( A__POPUPMENU, dir_server() + 'mo_otd', ru->op ), no )
        Else
          ko := perenos( a_o, inieditspr( A__POPUPMENU, dir_server() + 'p_priem', ru->op ), no )
        Endif
        s := PadR( lnomer, 10 ) + ' ' + ;
          PadR( a_f[ 1 ], nf ) + ' ' + ;
          full_date( kart->date_r ) + ' ' + ;
          PadR( a_a[ 1 ], na ) + ' '
        If Asc( ru->kod_p ) > 0
          Select BASE1
          Goto ( Asc( ru->kod_p ) )
          If !Eof() .and. !Empty( base1->p1 )
            s += AllTrim( Crypt( base1->p1, gpasskod ) )
          Endif
        Endif
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        ++j1
        add_string( s )
        For i := 2 To Min( 10, Max( kf, ka, ko + 1 ) )
          add_string( Space( 11 ) + ;
            PadR( a_f[ i ], nf ) + ' ' + ;
            Space( 11 ) + ;
            PadR( a_a[ i ], na ) + ' ' + ;
            a_o[ i -1 ] )
        Next
      Endif
      Select RU
      Skip
    Enddo
    Close databases
    add_string( Replicate( '─', sh ) )
    add_string( PadC( 'Итого: ' + lstr( j1 ) + ' человек', sh ) )
    FClose( fp )
    viewtext( n_file, , , , ( sh > 80 ), , , reg_print )
    rest_box( buf )
  Endif

  Return Nil

//
Function edit_priem()

  popup_edit( dir_server() + 'p_priem', T_ROW, T_COL -10, T_ROW + 11, , 1, , ;
    'fdel_priem', , , , , , 'Первичные приемы', col_tit_popup )

  Return Nil

//
Function fdel_priem( mkod )

  Local fl := .t., buf := save_maxrow()

  stat_msg( 'Ждите! Производится проверка на допустимость удаления данного приема' )
  r_use( dir_server() + 'mo_regi', , 'RU' )
  Locate For ru->tip == 2 .and. ru->op == mkod progress
  fl := !Found()
  Use
  If !fl
    func_error( 4, 'Данный первичный прием встречается в других базах данных. Удаление запрещено!' )
  Endif
  rest_box( buf )

  Return fl

// 14.04.15
Function regi_nastr( k )

  Static cgreen := 'G+/B'
  Local buf := SaveScreen(), i, arr, ;
    mm_lu_stt := { { 'в виде ЛИСТА УЧЕТА', 1 }, { 'в виде СТАТ.ТАЛОНА', 2 } }, ;
    mm_op := { { 'Отделение', 1 }, { 'Первичный врачебный прием', 2 } }, ;
    mm_regi_p := { { 'Всегда регистрировать посещение', 1 }, ;
    { 'Запрос: регистрация / просто печать', 2 } }, ;
    mm_razmer := { { 'формат A4', 1 }, ;
    { '1/2 формата A4 (вертикально)', 2 }, ;
    { '1/2 формата A4 (горизонтально)', 3 }, ;
    { 'ф.A4, отрывные талоны на платные услуги', 5 }, ;
    { 'Собственный шаблон', 6 } }, ;
    mm_razmt12 := { { 'формат A4', 1 }, ;
    { '1/2 формата A4 (горизонтально) (A5)', 2 } }, ;
    mm_025u := { { 'медицинская амбулаторная карта в упрощённом текстовом виде', 0 }, ;
    { 'стр.1 формы 025/у на листе А5', 1 }, ;
    { 'стр.1, 2 формы 025/у каждая на своей стороне листа А5', 2 }, ;
    { 'стр.1 формы 025/у на листе А4', 3 }, ;
    { 'стр.1, 2 формы 025/у каждая на своей стороне листа А4', 4 }, ;
    { 'стр.1, 2 формы 025/у на одной стороне листа А4 друг под другом', 5 }, ;
    { 'Ваш вариант графической формы 025/у', 6 } }, ;
    mm_025_1u := { { 'стр.1, 2 формы 025-1/у каждая на своей стороне листа А4', 1 }, ;
    { 'стр.1 формы 025-1/у на листе А4', 2 }, ;
    { 'Ваш вариант графической формы 025-1/у', 6 } }, ;
    mm_da_net := { { 'да', 1 }, { 'нет', 2 } }, mm_6op, mm_6regi_p

  mm_6op := AClone( mm_op )
  ins_array( mm_6op, 1, { 'Ничего не печатать', 0 } )
  mm_6regi_p := AClone( mm_regi_p )
  ins_array( mm_6regi_p, 1, { 'Не регистрировать посещение', 0 } )
  Private is_talon := ret_is_talon()
  // help_code := H_Edit_scroll
  If k == 1
    Public mem_lu_stt := 1, ;
      mem_op     := 2, ;
      mem_6op     := 0, ;
      mem_fio_r  := 2, ;
      mem_6fio_r  := 2, ;
      mem_time   := 2, ;
      mem_6time   := 2, ;
      mem_razmer := 1, ;
      mem_file5  := 'SMY', ;
      mem_t_025u := 0, ;
      mem_razt12 := 1, ;
      mem_2_lt12 := 2, ;
      mem_2_l066 := 1, ;
      mem_file4  := 'LIST_066.SHB', ;
      mem_file6  := 'TALON12.SHB', ;
      mem_file7  := 'LIST_ULR.SHB', ;
      mem_file8  := 'LIST_U_8.SHB', ;
      mem_file9  := 'LIST_U_9.SHB', ;
      mem_file9l := '', ;
      mem_filg6  := '', ;
      mem_filg8  := '', ;
      mem_reg_lr := Space( 100 ), ; // путь к регистру федеральных льготников
    mem_2_list := 1, ;
      mem_posl_p := 1, ;
      mem_regi_p := 1, ;
      mem_regi6p := 0, ;
      mem_fluor  := 2
    If hb_FileExists( 'memvar' + smem() )
      Restore From Memvar Additive
    Else
      Save All Like mem_* To memvar
    Endif
    If !is_talon
      mem_lu_stt := 1
    Endif
    // ////
  Elseif k == 2
    // ////
    Private m1a_op    := mem_op, ma_op, ;
      m1a_fio_r := mem_fio_r, ma_fio_r, ;
      m1a_time  := mem_time, ma_time, ;
      m1a_razmer := mem_razmer, ma_razmer, ;
      m1a_razmt12 := mem_razt12, ma_razmt12, ;
      m1a_2_lt12 := mem_2_lt12, ma_2_lt12, ;
      m1a_2_l066 := mem_2_l066, ma_2_l066, ;
      m1a_t_025u := mem_t_025u, ma_t_025u, ;
      mfile5    := PadR( mem_file5, 3 ), ;
      mfile4    := PadR( mem_file4, 12 ), ;
      mfile6    := PadR( mem_file6, 12 ), ;
      mgfile6   := PadR( mem_filg6, 8 ), ;
      mfile7    := PadR( mem_file7, 12 ), ;
      mfile8    := PadR( mem_file8, 12 ), ;
      mgfile8   := PadR( mem_filg8, 8 ), ;
      mfile9    := PadR( mem_file9, 12 ), ;
      mfile9l   := PadR( mem_file9l, 12 ), ;
      mreg_lr   := m1reg_lr := PadR( mem_reg_lr, 100 ), ;
      m1a_2_list := mem_2_list, ma_2_list, ;
      m1a_posl_p := mem_posl_p, ma_posl_p, ;
      m1a_regi_p := mem_regi_p, ma_regi_p, ;
      m1a_6op    := mem_6op, ma_6op, ;
      m1a_6fio_r := mem_6fio_r, ma_6fio_r, ;
      m1a_6time  := mem_6time, ma_6time, ;
      m1a_6regi_p := mem_regi6p, ma_6regi_p, ;
      m1a_fluor := mem_fluor, ma_fluor
    ma_op     := inieditspr( A__MENUVERT, mm_op, m1a_op )
    ma_fio_r  := inieditspr( A__MENUVERT, mm_da_net, m1a_fio_r )
    ma_time   := inieditspr( A__MENUVERT, mm_da_net, m1a_time )
    ma_razmer := inieditspr( A__MENUVERT, mm_razmer, m1a_razmer )
    ma_razmt12 := inieditspr( A__MENUVERT, mm_razmt12, m1a_razmt12 )
    ma_2_list := inieditspr( A__MENUVERT, mm_da_net, m1a_2_list )
    ma_t_025u := inieditspr( A__MENUVERT, mm_025u, m1a_t_025u )
    ma_2_lt12 := inieditspr( A__MENUVERT, mm_025_1u, m1a_2_lt12 )
    ma_2_l066 := inieditspr( A__MENUVERT, mm_da_net, m1a_2_l066 )
    ma_posl_p := inieditspr( A__MENUVERT, mm_da_net, m1a_posl_p )
    ma_regi_p := inieditspr( A__MENUVERT, mm_regi_p, m1a_regi_p )
    ma_6op    := inieditspr( A__MENUVERT, mm_6op, m1a_6op )
    ma_6fio_r := inieditspr( A__MENUVERT, mm_da_net, m1a_6fio_r )
    ma_6time  := inieditspr( A__MENUVERT, mm_da_net, m1a_6time )
    ma_6regi_p := inieditspr( A__MENUVERT, mm_6regi_p, m1a_6regi_p )
    ma_fluor  := inieditspr( A__MENUVERT, mm_da_net, m1a_fluor )
    If is_talon
      Private m1a_lu_stt := mem_lu_stt
      Private ma_lu_stt  := inieditspr( A__MENUVERT, mm_lu_stt, m1a_lu_stt )
    Endif
    //
    pr_1_str( 'Редактирование настроек по умолчанию для регистратуры' )
    SetColor( cDataCGet )
    myclear( 1 )
    status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запись;  ^<F1>^ - помощь' )
    init_vget()
    j := 0
    ++j
    @ j, 1 VSAY 'Расширение для файлов шаблонов сокращенных листов учета (по <F5>)' VGET mfile5 Pict '@!'
    ++j
    @ j, 1 VSAY 'Отображать данные по флюорографии больного?' VGET ma_fluor ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY 'Печать листа учета (<F9>):' Color cgreen
    If is_talon
      ++j
      @ j, 1 VSAY '- в каком виде печатать лист учета больного?' VGET ma_lu_stt ;
        reader {| x| menu_reader( x, mm_lu_stt, A__MENUVERT, , , .f. ) }
    Endif
    ++j
    @ j, 1 VSAY '- что печатать в правом верхнем углу листа учета' VGET ma_op ;
      reader {| x| menu_reader( x, mm_op, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- печатать на листе учета ФИО регистратора?' VGET ma_fio_r ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- печатать на листе учета время выдачи?' VGET ma_time ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- на каком листе печать' VGET ma_razmer ;
      reader {| x| menu_reader( x, mm_razmer, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- наименование файла шаблона листа учета (по <F9>)' VGET mfile9 Pict '@!'
    // ++j
    // @ ++j, 1 VSAY '- файл шаблона листа учета (по <F9>) для федеральных льготников' VGET mfile9l pict '@!'
    ++j
    @ j, 1 VSAY '- печатать оборотную сторону листа учета (стат.талона)?' VGET ma_2_list ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- выводить при распечатке листа учета дату последнего посещения?' VGET ma_posl_p ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- выводить или нет перед распечаткой листа учета запрос на регистрацию'
    ++j
    @ j, 1 VSAY '  данного л/учета как посещения?' VGET ma_regi_p ;
      reader {| x| menu_reader( x, mm_regi_p, A__MENUVERT, , , .f. ) }
    //
    ++j
    @ j, 1 VSAY 'Печать медицинской амбулаторной карты (<F8>):' Color cgreen
    ++j
    @ j, 1 VSAY '- наименование файла шаблона упрощённой амбулаторной карты' VGET mfile8 Pict '@!'
    ++j
    @ j, 1 VSAY '- в каком виде и на каком листе распечатывается медицинская амбулаторная'
    ++j
    @ j, 1 VSAY '  карта?' VGET ma_t_025u ;
      reader {| x| menu_reader( x, mm_025u, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- наименование шаблона (.FR3) Вашей графической амбулаторной карты' VGET mgfile8 Pict '@!' ;
      When m1a_t_025u == 6
    //
    ++j
    @ j, 1 VSAY 'Печать талона амбулаторного пациента №025-1/у (приказ №834н) (<F6>):' Color cgreen
    ++j
    @ j, 1 VSAY '- что печатать?' VGET ma_2_lt12 ;
      reader {| x| menu_reader( x, mm_025_1u, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- наименование шаблона (.FR3) Вашего графического талона амб.пациента' VGET mgfile6 Pict '@!' ;
      When m1a_2_lt12 == 6
    ++j
    @ j, 1 VSAY '- что запрашивать (печатать в определенном месте талона)' VGET ma_6op ;
      reader {| x| menu_reader( x, mm_6op, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- печатать на талона ФИО регистратора?' VGET ma_6fio_r ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- печатать на талона время выдачи?' VGET ma_6time ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    ++j
    @ j, 1 VSAY '- выводить или нет перед распечаткой талона запрос на регистрацию'
    ++j
    @ j, 1 VSAY '  данного талона как посещения?' VGET ma_6regi_p ;
      reader {| x| menu_reader( x, mm_6regi_p, A__MENUVERT, , , .f. ) }
    //
    ++j
    @ j, 1 VSAY 'Печать статистической карты выбывшего из стационара (приказ №413) (<F4>):' Color cgreen
    ++j
    @ j, 1 VSAY '- наименование файла шаблона стат.карты выбывшего из стационара' VGET mfile4 Pict '@!'
    ++j
    @ j, 1 VSAY '- печатать оборотную сторону стат.карты выбывшего из стационара?' VGET ma_2_l066 ;
      reader {| x| menu_reader( x, mm_da_net, A__MENUVERT, , , .f. ) }
    // ++j ; @ j, 1 VSAY 'Печать листа учета льготных рецептов (<F7>):' color cgreen
    // ++j ; @ j, 1 VSAY '- наименование файла шаблона листа учета льготных рецептов' VGET mfile7 pict '@!'
    // ++j
    // @ j, 1 VSAY '- путь к регистру федеральных льготников (это файл с наименованием'
    // ++j
    // @ j, 1 VSAY '  R_MU.DBF)' VGET mreg_lr ;
    // reader {|x| menu_reader(x,{{|k,r,c| mng_file(k,r,c,'LR_Registr', ,'*.dbf') }},A__FUNCTION, , , .f.)}
    If scrollread( 1, 0, MaxRow() -1, MaxCol(), cDataCGet )
      mem_op      := m1a_op
      mem_fio_r   := m1a_fio_r
      mem_time    := m1a_time
      mem_razmer  := m1a_razmer
      mem_razt12  := m1a_razmt12
      mem_file4   := AllTrim( mfile4 )
      mem_file5   := AllTrim( mfile5 )
      mem_file6   := AllTrim( mfile6 )
      mem_filg6   := AllTrim( mgfile6 )
      mem_file7   := AllTrim( mfile7 )
      mem_file8   := AllTrim( mfile8 )
      mem_filg8   := AllTrim( mgfile8 )
      mem_file9   := AllTrim( mfile9 )
      mem_file9l  := AllTrim( mfile9l )
      mem_reg_lr  := AllTrim( mreg_lr )
      mem_2_list  := m1a_2_list
      mem_t_025u  := m1a_t_025u
      mem_2_lt12  := m1a_2_lt12
      mem_2_l066  := m1a_2_l066
      mem_posl_p  := m1a_posl_p
      mem_regi_p  := m1a_regi_p
      mem_6op     := m1a_6op
      mem_6fio_r  := m1a_6fio_r
      mem_6time   := m1a_6time
      mem_regi6p  := m1a_6regi_p
      mem_fluor   := m1a_fluor
      If is_talon
        mem_lu_stt := m1a_lu_stt
      Endif
      Save All Like mem_* To memvar
      // if !empty(mem_reg_lr) .and. !('R_MU.DBF' $ upper(mem_reg_lr))
      // func_error(4, 'Неверно выбран регистр федеральных льготников (должен быть файл R_MU.DBF)')
      // endif
      arr := { mem_file4, mem_file8, mem_file9 }
      If m1a_t_025u == 6
        AAdd( arr, mem_filg8 + sfr3() )
      Endif
      If m1a_2_lt12 == 6
        AAdd( arr, mem_filg6 + sfr3() )
      Endif
      For i := 1 To Len( arr )
        If !Empty( arr[ i ] ) .and. search_file( arr[ i ] ) == NIL
          func_error( 4, 'Не обнаружен файл шаблона ' + arr[ i ] )
        Endif
      Next
    Endif
    Close databases
  Endif
  help_code := -1
  RestScreen( buf )

  Return Nil

// 17.11.25
Function r_list_uch( par, name_func )

  // 0 - 'ind_karta' инд.карта или 'f_f025u' форма 025
  // 1 - 'list_uch' лист учета (отделение)
  // 2 - 'list_uch' лист учета (первичный прием)
  // 3 - 'f_list_ulr' лист учета льготных рецептов
  // 4 - 'talon12' талон амб.пациента
  // 5 - 'f_f066' стат.карта выбывшего из стационара

  Local i := 1, j, k, s, fl, buf := save_maxrow()
  Local luchast := '', arr, m1vid_ud, ;
    m1kategor := ATail( stm_kategor )[ 2 ]  // т.е. прочие (последнее значение)
  Private name_lpu, name_otd, mvzros_reb, mreg_lech, mmest_inog, mrab_nerab, ;
    m1komu := 0, mkomu, name_org, mmi_git, mkategor, mvid_ud, mnom, mser, ;
    l1nomer, lnomer, mrajon_git, mrajon_fin, mpolis, msrok_polis, ;
    mregistrator := '', mtime, mfio, mpol, mdate_r, madres, madresp, mmr_dol, ;
    muchastok, s_prim1 := {}, mfio1 := '', mvid_ud1 := '', mser1 := '', ;
    mnom1 := '', msnils := '', mbeg_polis := '', ;
    mvidpolis := '', mmesto_rog := '', mphone := ''

  menu_mest  := { { 'город', 0 }, { 'область', 1 }, { 'иногородний', 2 } }
  mywait()
  //
  name_lpu := AllTrim( glob_uch[ 2 ] )
  name_otd := AllTrim( glob_otd[ 2 ] )
  If eq_any( par, 1, 2, 4 )
    j := 1
    If mem_regi_p == 2
      rest_box( buf )
      j := f_alert( { '', ;
        'Необходима регистрация и печать листа учета или только печать', ;
        '' }, ;
        { ' ~Регистрация и печать ', ' Только ~печать ' }, ;
        1, 'W/RB', 'G+/RB', 18, , 'BG+/RB, W+/R, W+/RB, GR+/R' )
      mywait()
    Endif
    If j == 0
      rest_box( buf )
      Return Nil
    Endif
    If j == 1
      g_use( dir_server() + 'mo_regi', { dir_server() + 'mo_regi1', ;
        dir_server() + 'mo_regi2', ;
        dir_server() + 'mo_regi3' }, 'RU' )
      addrec( 1 )
      ru->kod_k := kart->kod
      ru->tip := par
      ru->uch := glob_uch[ 1 ]
      ru->pdate := dtoc4( sys_date )
      ru->CTIME := hour_min( Seconds() )
      If par == 1
        ru->op := glob_otd[ 1 ]
        name_otd := AllTrim( glob_otd[ 2 ] )
      Else
        ru->op := glob_priem[ 1 ]
        name_otd := AllTrim( glob_priem[ 2 ] )
      Endif
      ru->kod_p := kod_polzovat // код оператора записывать всегда
      ru->( dbCloseArea() )
    Endif
  Endif
  r_use( dir_server() + 'k_prim1', dir_server() + 'k_prim1', 'K_PRIM1' )
  find ( Str( kart->kod, 7 ) )
  Do While k_prim1->kod == kart->kod .and. !Eof()
    AAdd( s_prim1, RTrim( k_prim1->name ) )
    Skip
  Enddo
  k_prim1->( dbCloseArea() )
  If Len( s_prim1 ) == 0
    AAdd( s_prim1, '' )
  Endif
  If !( kod_polzovat == Chr( 0 ) )
    mregistrator := AllTrim( currentuser():FIO )
  Endif
  mfio := Upper( kart->fio )
  mpolis := kart->polis
  //
//  msnils := Expand( Transform( kart->SNILS, picture_pf ) )
  msnils := Expand( Transform_SNILS( kart->SNILS ) )
  mpol := kart->pol
  mdate_r := full_date( kart->date_r )
  madres := iif( emptyall( kart_->okatog, kart->adres ), '', ;
    ret_okato_ulica( kart->adres, kart_->okatog ) )
  madresp := iif( emptyall( kart_->okatop, kart_->adresp ), '', ;
    ret_okato_ulica( kart_->adresp, kart_->okatop ) )
  mmr_dol := kart->mr_dol
  mtime := hour_min( Seconds() )
  mbeg_polis := full_date( c4tod( kart_->beg_polis ) )
  msrok_polis := full_date( c4tod( kart->srok_polis ) )
  mvzros_reb := Upper( inieditspr( A__MENUVERT, menu_vzros, kart->vzros_reb ) )
  mmi_git    := okato_mi_git( kart_->okatog )
  mrajon_git := okato_rajon( kart_->okatog )
  If !emptyall( kart_->PHONE_H, kart_->PHONE_M, kart_->PHONE_W )
    If !Empty( kart_->PHONE_H )
      mphone += ' дом.' + kart_->PHONE_H
    Endif
    If !Empty( kart_->PHONE_M )
      mphone += ' моб.' + kart_->PHONE_M
    Endif
    If !Empty( kart_->PHONE_W )
      mphone += ' раб.' + kart_->PHONE_W
    Endif
  Endif
  mmest_inog := mrajon_fin := ''
  If kart->MI_GIT == 9
    m1komu := kart->KOMU
  Endif
  If m1komu == 0
    mkomu := 'СМО - '
    If AllTrim( kart_->SMO ) == '34'
      s := ret_inogsmo_name( 1 )
      mkomu += iif( Empty( s ), 'ТФОМС (иногородние)', s )
      mmest_inog := inieditspr( A__MENUVERT, glob_array_srf(), kart_->KVARTAL_D ) // ОКАТО субъекта РФ территории страхования
    Elseif Left( kart_->SMO, 2 ) == '34'
//      mkomu += AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( kart_->smo ) ) ) )
      mkomu += AllTrim( inieditspr( A__MENUVERT, smo_volgograd(), Int( Val( kart_->smo ) ) ) )
      mmest_inog := 'Волгоградская область'
    Elseif !Empty( kart_->SMO )
      mkomu += init_ismo( kart_->SMO )
      mmest_inog := inieditspr( A__MENUVERT, glob_array_srf(), kart_->KVARTAL_D ) // ОКАТО субъекта РФ территории страхования
    Endif
  Else
    mkomu := ''
    If m1komu == 1
      mkomu := 'пр.компания - '
    Elseif m1komu == 3
      mkomu := 'комитет/МО - '
    Endif
    mkomu += f4_view_list_schet( m1komu, '', kart->str_crb )
  Endif
  mrab_nerab := Upper( inieditspr( A__MENUVERT, menu_rab, kart->rab_nerab ) )
  m1vid_ud := kart_->vid_ud
  mnom     := kart_->nom_ud
  mser     := kart_->ser_ud
  mvidpolis := ' (' + AllTrim( inieditspr( A__MENUVERT, mm_vid_polis, kart_->vpolis ) ) + ')'
  mmesto_rog := AllTrim( kart_->mesto_r )
  If Empty( stm_kategor2 )
    m1kategor := kart_->kategor
    mkategor := Upper( inieditspr( A__MENUVERT, stm_kategor, m1kategor ) )
  Else
    m1kategor := kart_->kategor2
    mkategor := Upper( inieditspr( A__MENUVERT, stm_kategor2, m1kategor ) )
  Endif
  mvid_ud :=  get_name_vid_ud( m1vid_ud )

  If Empty( mser )
    mser := Space( 10 )
  Endif
  If Empty( mnom )
    mnom := Space( 10 )
  Endif
  //
  lnomer := l1nomer := lstr( kart->kod )
  muchastok := put_val( kart->uchast, 2 )
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
  lnomer := Expand( lnomer ) + luchast
  If !Empty( name_func ) .and. !( '(' $ name_func )
    name_func += '()'
  Endif
  k := &name_func
  rest_box( buf )

  Return Nil

// 17.11.25
Function new_list_uch( par, name_func )

  // 0 - 'f_f025u' форма 025/у
  // 4 - 'talon025' талон амб.пациента 025-1/у
  Static sb1 := '<b><u>', sb2 := '</u></b>'
  Local i := 1, j, k, s, fl, buf := save_maxrow()
  Local luchast := '', arr, m1vid_ud

  mywait()
  //
  If iif( par == 4, mem_6op, mem_op ) == 1
    name_otd := AllTrim( glob_otd[ 2 ] )
  Else
    name_otd := AllTrim( glob_priem[ 2 ] )
  Endif
  If eq_any( par, 1, 2, 4 )
    j := iif( par == 4, mem_regi6p, mem_regi_p )
    If j == 2
      rest_box( buf )
      j := f_alert( { '', ;
        'Необходима регистрация и печать талона или только печать', ;
        '' }, ;
        { ' ~Регистрация и печать ', ' Только ~печать ' }, ;
        1, 'W/RB', 'G+/RB', 18, , 'BG+/RB, W+/R, W+/RB, GR+/R' )
      mywait()
    Endif
    If j == 1
      g_use( dir_server() + 'mo_regi', { dir_server() + 'mo_regi1', ;
        dir_server() + 'mo_regi2', ;
        dir_server() + 'mo_regi3' }, 'RU' )
      addrec( 1 )
      ru->kod_k := kart->kod
      ru->uch := glob_uch[ 1 ]
      ru->pdate := dtoc4( sys_date )
      ru->CTIME := hour_min( Seconds() )
      If iif( par == 4, mem_6op, mem_op ) == 1
        ru->tip := 1
        ru->op := glob_otd[ 1 ]
      Else
        ru->tip := 2
        ru->op := glob_priem[ 1 ]
      Endif
      ru->kod_p := kod_polzovat // код оператора записывать всегда
      ru->( dbCloseArea() )
    Endif
  Endif
  mregistrator := ''
  If !( kod_polzovat == Chr( 0 ) )
    mregistrator := AllTrim( currentuser():FIO )
  Endif
  delfrfiles()
  r_use( dir_server() + 'organiz', , 'ORG' )
  adbf := { { 'name_org', 'C', 255, 0 }, ;
    { 'adres_org', 'C', 255, 0 }, ;
    { 'ogrn', 'C', 15, 0 }, ;
    { 'okpo', 'C', 12, 0 }, ;
    { 'date_sys', 'C', 10, 0 }, ;
    { 'd_sys', 'C', 2, 0 }, ;
    { 'm_sys', 'C', 2, 0 }, ;
    { 'y_sys', 'C', 4, 0 }, ;
    { 'nomer_kart', 'C', 25, 0 }, ;
    { 'fio', 'C', 130, 0 }, ;
    { 'fam', 'C', 50, 0 }, ;
    { 'ima', 'C', 50, 0 }, ;
    { 'ots', 'C', 50, 0 }, ;
    { 'pol', 'C', 50, 0 }, ;
    { 'date_r', 'C', 10, 0 }, ;
    { 'd_dr', 'C', 2, 0 }, ;
    { 'm_dr', 'C', 2, 0 }, ;
    { 'y_dr', 'C', 4, 0 }, ;
    { 'subekt', 'C', 50, 0 }, ;
    { 'rajon', 'C', 50, 0 }, ;
    { 'gorod', 'C', 50, 0 }, ;
    { 'nas_p', 'C', 50, 0 }, ;
    { 'adres', 'C', 200, 0 }, ;
    { 'adresL', 'C', 200, 0 }, ;
    { 'phone', 'C', 15, 0 }, ;
    { 'phones', 'C', 50, 0 }, ;
    { 'gorod_selo', 'C', 50, 0 }, ;
    { 'ser_polis', 'C', 10, 0 }, ;
    { 'nom_polis', 'C', 20, 0 }, ;
    { 'polis', 'C', 25, 0 }, ;
    { 'snils', 'C', 14, 0 }, ;
    { 'smo', 'C', 100, 0 }, ;
    { 'kod_lgot', 'C', 2, 0 }, ;
    { 'name_doc', 'C', 20, 0 }, ;
    { 'ser_doc', 'C', 20, 0 }, ;
    { 'nom_doc', 'C', 20, 0 }, ;
    { 'zanyat', 'C', 255, 0 }, ;
    { 'invalid', 'C', 100, 0 }, ;
    { 'mr_dol', 'C', 50, 0 }, ;
    { 'perv_priem', 'C', 50, 0 }, ;
    { 'registrato', 'C', 50, 0 }, ;
    { 'time_regi', 'C', 50, 0 }, ;
    { 'mesto_rog', 'C', 100, 0 }, ;
    { 'kategor', 'C', 40, 0 }, ;
    { 'subektp', 'C', 50, 0 }, ;
    { 'rajonp', 'C', 50, 0 }, ;
    { 'gorodp', 'C', 50, 0 }, ;
    { 'nas_pp', 'C', 50, 0 }, ;
    { 'adresp', 'C', 200, 0 }, ;
    { 'adrespL', 'C', 200, 0 }, ;
    { 'platel', 'C', 100, 0 }, ;
    { 'platel1', 'C', 100, 0 }, ;
    { 'fio1', 'C', 130, 0 }, ;
    { 'kemvyd', 'C', 150, 0 }, ;
    { 'kogdavyd', 'C', 10, 0 }, ;
    { 'bukva', 'C', 1, 0 }, ;
    { 'uchast', 'C', 2, 0 }, ;
    { 'kod_vu', 'C', 5, 0 }, ;
    { 'kod_kart', 'C', 7, 0 };
    }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name_org := glob_mo()[ _MO_FULL_NAME ]
  frt->adres_org := glob_mo()[ _MO_ADRES ]
  frt->ogrn := org->ogrn
  frt->okpo := org->okpo
  org->( dbCloseArea() )
  //
  s := full_date( sys_date )
  frt->date_sys := s
  frt->d_sys := SubStr( s, 1, 2 )
  frt->m_sys := SubStr( s, 4, 2 )
  frt->y_sys := SubStr( s, 7, 4 )
  arr := retfamimot( 1, .f. )
  frt->fam := arr[ 1 ]
  frt->ima := arr[ 2 ]
  frt->ots := arr[ 3 ]
  frt->fio := Expand( Upper( arr[ 1 ] + ' ' + arr[ 2 ] + ' ' + arr[ 3 ] ) )
  frt->fio1 := Upper( arr[ 1 ] + ' ' + arr[ 2 ] + ' ' + arr[ 3 ] )
  frt->ser_polis := kart_->SPOLIS
  frt->nom_polis := kart_->NPOLIS
  frt->polis := LTrim( AllTrim( kart_->SPOLIS ) + ' ' + kart_->NPOLIS )
//  frt->snils := Transform( kart->SNILS, picture_pf )
  frt->snils := Transform_SNILS( kart->SNILS )
  frt->pol := iif( kart->pol == 'М', sb1 + 'муж. - 1' + sb2 + ', жен. - 2', 'муж. - 1, ' + sb1 + 'жен. - 2' + sb2 )
  mdate_r := full_date( kart->date_r )
  frt->date_r := mdate_r
  frt->d_dr := SubStr( mdate_r, 1, 2 )
  frt->m_dr := SubStr( mdate_r, 4, 2 )
  frt->y_dr := SubStr( mdate_r, 7, 4 )
  arr := ret_okato_array( kart_->okatop )
  frt->subektp := arr[ 1 ]
  frt->rajonp  := arr[ 2 ]
  frt->gorodp  := arr[ 3 ]
  frt->nas_pp  := arr[ 4 ]
  arr := ret_okato_array( kart_->okatog )
  frt->subekt := arr[ 1 ]
  frt->rajon  := arr[ 2 ]
  frt->gorod  := arr[ 3 ]
  frt->nas_p  := arr[ 4 ]
  If f_is_selo()
    frt->gorod_selo := 'городская - 1, ' + sb1 + 'сельская - 2' + sb2
  Else
    frt->gorod_selo := sb1 + 'городская - 1' + sb2 + ', сельская - 2'
  Endif
  frt->mr_dol   := kart->mr_dol
  frt->bukva    := kart->bukva
  frt->kod_kart := lstr( kart->kod )
  If kart->uchast > 0
    frt->uchast := lstr( kart->uchast )
  Endif
  If kart->kod_vu > 0
    frt->kod_vu := lstr( kart->kod_vu )
  Endif
  If !emptyall( kart_->PHONE_H, kart_->PHONE_M, kart_->PHONE_W )
    s := ''
    If !Empty( kart_->PHONE_M )
      s += 'моб.' + kart_->PHONE_M + ' '
    Endif
    If !Empty( kart_->PHONE_H )
      s += 'дом.' + kart_->PHONE_H + ' '
    Endif
    If !Empty( kart_->PHONE_W )
      s += 'раб.' + kart_->PHONE_W
    Endif
    frt->phone := s
    frt->phones := s
  Endif
  If Empty( kart->adres )
    s := 'улица' + sb1 + Space( 30 ) + sb2 + ' дом' + sb1 + Space( 5 ) + sb2 + ;
      ' квартира' + sb1 + Space( 5 ) + sb2
  Else
    s := sb1 + PadR( kart->adres, 60 ) + sb2
  Endif
  frt->adres := s + '   тел. ' + sb1 + frt->phones + sb2
  If Empty( kart->adres )
    s := 'улица' + Space( 30 ) + ' дом' + Space( 5 ) + ' квартира' + Space( 5 )
  Else
    s := PadR( kart->adres, 60 )
  Endif
  frt->adresL := s // +'   тел. '+frt->phones
  // второй адрес
  If emptyall( kart_->okatop, kart_->adresp )
    If Empty( kart->adres )
      s := 'улица' + sb1 + Space( 30 ) + sb2 + ' дом' + sb1 + Space( 5 ) + sb2 + ;
        ' квартира' + sb1 + Space( 5 ) + sb2
    Else
      s := sb1 + PadR( kart->adres, 60 ) + sb2
    Endif
  Else
    s := sb1 + PadR( kart_->adresp, 60 ) + sb2
  Endif
  frt->adresp := s + '   тел. ' + sb1 + frt->phones + sb2
  If emptyall( kart_->okatop, kart_->adresp )
    If Empty( kart->adres )
      s := 'улица' + Space( 30 ) + ' дом' + Space( 5 ) + ' квартира' + Space( 5 )
    Else
      s := PadR( kart->adres, 60 )
    Endif
  Else
    s := PadR( kart_->adresp, 60 )
  Endif
  frt->adrespL := s // +'   тел. '+frt->phones
  //
  If ( i := AScan( stm_kategor, {| x| x[ 2 ] == kart_->kategor } ) ) > 0 ;
      .and. Between( stm_kategor[ i, 3 ], 1, 9 )
    frt->kod_lgot := lstr( stm_kategor[ i, 3 ] )
  Endif
  If AllTrim( kart_->SMO ) == '34'
    If Empty( s := ret_inogsmo_name( 1 ) )
      s := 'иногородние'
    Endif
    frt->smo := '(' + AllTrim( kart_->KVARTAL_D ) + ') ' + s
  Elseif Left( kart_->SMO, 2 ) == '34'
//    frt->smo := AllTrim( inieditspr( A__MENUVERT, glob_arr_smo, Int( Val( kart_->smo ) ) ) )
    frt->smo := AllTrim( inieditspr( A__MENUVERT, smo_volgograd(), Int( Val( kart_->smo ) ) ) )
  Elseif !Empty( kart_->SMO )
    frt->smo := '(' + AllTrim( kart_->KVARTAL_D ) + ') ' + init_ismo( kart_->SMO )
  Endif
  s := iif( kart->rab_nerab == 0, sb1, '' ) + 'работает - 1' + iif( kart->rab_nerab == 0, sb2, '' ) + ',    ' + ;
    'проходит военную службу и приравненную к ней службу - 2;    ' + ;
    iif( kart_->PENSIONER == 1, sb1, '' ) + 'пенсионер(ка) - 3' + iif( kart_->PENSIONER == 1, sb2, '' ) + ',    ' + ;
    iif( kart->rab_nerab == 2, sb1, '' ) + 'студент(ка) - 4' + iif( kart->rab_nerab == 2, sb2, '' ) + ',    ' + ;
    iif( kart->rab_nerab == 1, sb1, '' ) + 'не работает - 5' + iif( kart->rab_nerab == 1, sb2, '' ) + ',    ' + ;
    'прочие - 6'
  frt->zanyat := s
  frt->name_doc := get_name_vid_ud( kart_->vid_ud )
  frt->ser_doc := kart_->ser_ud
  frt->nom_doc := kart_->nom_ud
  //
  lnomer := l1nomer := lstr( kart->kod )
  muchastok := put_val( kart->uchast, 2 )
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
  lnomer := Expand( lnomer ) + luchast
  frt->nomer_kart := lnomer
  frt->mesto_rog  := AllTrim( kart_->mesto_r )
  If Empty( stm_kategor2 )
    frt->kategor := inieditspr( A__MENUVERT, stm_kategor, kart_->kategor )
  Else
    frt->kategor := inieditspr( A__MENUVERT, stm_kategor2, kart_->kategor2 )
  Endif
  If iif( par == 4, mem_6op > 0, .t. )
    frt->perv_priem := name_otd
  Endif
  If iif( par == 4, mem_6fio_r == 1, .t. )
    frt->registrato := mregistrator
  Endif
  If iif( par == 4, mem_6time == 1, .t. )
    frt->time_regi := date_8( sys_date ) + 'г.  ' + hour_min( Seconds() )
  Endif
  Private m1company := 0, mcompany := ' ', mm_company := {}
  Private m1KOMU := 0, MKOMU, M1STR_CRB := 0
  If kart->MI_GIT == 9
    m1KOMU    := kart->KOMU
    M1STR_CRB := kart->STR_CRB
  Endif
  mkomu := inieditspr( A__MENUVERT, mm_komu, m1komu )
  If m1komu == 0
    m1company := Int( Val( kart_->SMO ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  If m1komu == 0 // ОМС
//    mm_company := AClone( glob_arr_smo )
    mm_company := AClone( smo_volgograd() )
  Elseif m1komu == 1 // Прочие компании
    r_use( dir_server() + 'str_komp' )
    Index On Upper( name ) To tmp_comp For !Between( tfoms, 44, 47 )
    dbEval( {|| AAdd( mm_company, { AllTrim( name ), kod } ) } )
    str_komp->( dbCloseArea() )
  Elseif m1komu == 3 // Комитеты/МО
    r_use( dir_server() + 'komitet' )
    Index On Upper( name ) To tmp_comp
    dbEval( {|| AAdd( mm_company, { AllTrim( name ), kod } ) } )
    komitet->( dbCloseArea() )
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  frt->platel  := mkomu
  If m1komu == 0  // ОМС
    frt->platel1 := frt->smo
  Else
    frt->platel1 := mcompany
  Endif
  // кем выдан паспорт
  r_use( dir_server() + 's_kemvyd' )
  goto( kart_->kemvyd )
  frt->kemvyd := s_kemvyd->name
  s_kemvyd->( dbCloseArea() )
  frt->kogdavyd := full_date( kart_->kogdavyd )
  frt->( dbCloseArea() )
  If !Empty( name_func ) .and. !( '(' $ name_func )
    name_func += '()'
  Endif
  k := &name_func
  rest_box( buf )

  Return Nil

// инд.карта
Function ind_karta()

  Local file_sh, k := 10, arr, sh, HH, reg_print, n_file
  Local tmp_file := cur_dir() + '___tmp.txt', lfp, s

  If ( file_sh := search_file( f_file8() ) ) == NIL
    Return func_error( 4, 'Не обнаружен файл шаблона ' + f_file8() )
  Endif
  n_file := strippath( BeforAtNum( '.', file_sh ) ) + stxt()
  arr := print_shablon( file_sh, , n_file, .f. )
  If ValType( arr ) == 'A'
    sh := arr[ 1 ]
    HH := arr[ 2 ]
    reg_print := arr[ 3 ]
    Private yes_albom := arr[ 5 ]
    viewtext( n_file, , , , ( k + sh > 80 ), , , reg_print, , , .f., ( f_ff_lu() == 1 ) )
  Endif

  Return Nil

//
Static Function f_file8()

  Local k := mem_file8

  If eq_any( glob_task, X_PLATN, X_ORTO )
    k := mem_ort_f8
  Endif

  Return k

//
Static Function f_ff_lu()

  Local k := mem_ff_lu

  If eq_any( glob_task, X_PLATN, X_ORTO )
    k := mem_ortfflu
  Endif

  Return k

//
Function pr_sh_f5()

  Private file_sh

  If !Empty( mem_file5 ) .and. ;
      !Empty( file_sh := menu_shablon( 3, 3, dir_exe() + '*.' + mem_file5, color8, .f., .f. ) )
    Private msnils := '', mlgota := '', ;
      madres_lpu := '', mogrn := '', name_lpu
    r_use( dir_server() + 'organiz', , 'ORG' )
    name_lpu := AllTrim( org->name )
    madres_lpu := AllTrim( org->adres )
    mogrn := AllTrim( org->ogrn )
    /*if is_r_mu .and. !r_mushrt->(eof())
      msnils := alltrim(r_mushrt->snils)
      mlgota := alltrim(r_mushrt->lgota)
      if select('katl') == 0
        use_base('katl')
      endif
      select KATL
      find (mlgota)
      if len(alltrim(katl->name_katl)) > 3
        mlgota += ' ' + alltrim(katl->name_katl)
      endif
      if len(mlgota) > 48
        mlgota := left(mlgota, 45) + '...'
      endif
    endif
    */
    If Empty( msnils ) .and. !Empty( kart->SNILS )
//      msnils := Transform( kart->SNILS, picture_pf )
      msnils := Transform_SNILS( kart->SNILS )
    Endif
    r_list_uch( 0, 'f1_pr_shab(file_sh)' )
  Endif

  Return Nil

//
Function f1_pr_shab( lsh )

  Local arr := print_shablon( lsh, , , .f. )
  Local width, regim, n_file

  width := arr[ 1 ]
  regim := arr[ 3 ]
  n_file := strippath( BeforAtNum( '.', lsh ) ) + stxt()
  Private yes_albom := arr[ 5 ]
  If glob_mo()[ _MO_KOD_TFOMS ] == '175303' // ксп-3
    If regim == 6
      regim := 8
    Endif
  Endif
  viewtext( n_file, , , , ( width > 80 ), , , regim, , , , ( mem_ff_lu == 1 ) )

  Return Nil

// стат.карта выбывшего из стационара
Function f_f066()

  Local file_sh

  If ( file_sh := search_file( mem_file4 ) ) == NIL
    Return func_error( 4, 'Не обнаружен файл шаблона ' + mem_file4 )
  Endif
  r_use( dir_server() + 'organiz', , 'ORG' )
  name_lpu := AllTrim( org->name )
  f1_pr_shab( file_sh )

  Return Nil

// 15.10.15 форма 025
Function f_f025u()

  Static arr_f := { 'mo_025uA5_1', 'mo_025uA5_2', 'mo_025uA4_1', 'mo_025uA4_2', ;
    'mo_025uA4_k' }
  Local i := mem_t_025u

  If !Between( i, 1, 6 )
    i := 1
  Endif
  If i == 6
    If Empty( mem_filg8 )
      func_error( 4, 'Не настроено имя файла шаблона для печати амбулаторной карты' )
    Elseif hb_FileExists( mem_filg8 + sfr3() )
      call_fr( mem_filg8 )
    Else
      func_error( 4, 'Не обнаружен файл шаблона ' + mem_filg8 + sfr3() )
    Endif
  Else
    call_fr( arr_f[ i ] )
  Endif

  Return Nil

// 15.10.15 талон 025
Function f_talon025()

  If mem_2_lt12 == 1
    call_fr( 'mo_025_1u' )
  Elseif mem_2_lt12 == 2
    call_fr( 'mo_025_1u_' )
  Else
    If Empty( mem_filg6 )
      func_error( 4, 'Не настроено имя файла шаблона для печати талона' )
    Elseif hb_FileExists( mem_filg6 + sfr3() )
      call_fr( mem_filg6 )
    Else
      func_error( 4, 'Не обнаружен файл шаблона ' + mem_filg6 + sfr3() )
    Endif
  Endif

  Return Nil

// лист учета (1 - отделение), (2 - первичный прием)
Function list_uch( is_lgotnik )

  Local sh := 80, HH := 55, buf := save_maxrow(), regim_print := 2
  Local i := 1, j, k, tmp[ 2 ], tmp1, w1 := 65, s, fl, rec
  Local n_file := cur_dir() + 'list_uch.txt', arr, mfam1, mima1, mots1, m1vid_ud, ;
    m1kategor := ATail( stm_kategor )[ 2 ]  // т.е. прочие (последнее значение)

  //
  Default is_lgotnik To .f.
  is_lgotnik := .f. // временно
  If is_lgotnik .and. ( file_sh := search_file( mem_file9l ) ) != NIL
   /* rec := kart->(recno())
    if select('r_mu') == 0
      use_base('r_mu')
    endif
    select R_MU
    find (r_mushrt->snils)
    Private msnils := alltrim(r_mu->ss), ;
          mlgota := '', m1lgota := '', minvalid := ''
    if select('l_mu') == 0
      use_base('l_mu')
    endif
    select L_MU
    find (msnils)
    if select('katl') == 0
      use_base('katl')
    endif
    select KATL
    // find (l_mu->(__c_katl()))
    // mlgota := l_mu->(__c_katl())
    if len(alltrim(katl->name_katl)) > 3
      mlgota += ' (' + alltrim(katl->name_katl) + ')'
    endif
    //m1lgota := l_mu->(__c_katl()) + ': '
    // (наименование, N, серия, дата, кем выдан)
    //m1lgota += alltrim(l_mu->NAME_DL) + ' серия ' + alltrim(l_mu->(__ser_dl())) + ' N ' + ;
    //           alltrim(l_mu->(__numb_dl()))
    if dlo_version==3 .and. !empty(l_mu->DATE_VD)
      m1lgota += ' дата '+date_8(s_2_d(l_mu->DATE_VD)) + 'г.'
    endif
    if dlo_version==3 .and. !empty(l_mu->NAME_VD)
      m1lgota += ' выдан ' + alltrim(l_mu->NAME_VD)
    endif
    if eq_any(l_mu->(__c_katl()),'010','081','082','083','084')
      minvalid := alltrim(katl->name_katl)
    endif
    f1_pr_shab(file_sh)
    use_base('kartotek')
    goto (rec)
    return NIL*/
  Else
    Do Case
    Case mem_razmer == 1   // формат A4
      //
    Case mem_razmer == 2   // 1/2 формата A4 (вертикально)
      HH := 53
      regim_print := 6
    Case mem_razmer == 3   // 1/2 формата A4 (горизонтально)
      HH := 37
      regim_print := 5
    Case mem_razmer == 4   // 1/2 ф.A4 (горизонально - впечатывание)
      HH := 37
      regim_print := 5
    Case mem_razmer == 5   // ф.A4, отрывные талоны на платные услуги
      HH := 53
      regim_print := 5
    Case mem_razmer == 6   // собственный шаблон
      If ( file_sh := search_file( mem_file9 ) ) == NIL
        Return func_error( 4, 'Не обнаружен файл шаблона ' + mem_file9 )
      Endif
      rec := kart->( RecNo() )
      f1_pr_shab( file_sh )
      use_base( 'kartotek' )
      Goto ( rec )
      Return Nil
    Endcase
  Endif
  //
  fp := FCreate( n_file )
  tek_stroke := 0
  n_list := 1
  // ЮРА
//  Private msnils := Transform( kart->SNILS, picture_pf )
  Private msnils := Transform_SNILS( kart->SNILS )
  If mem_lu_stt == 1
    add_string( PadR( name_lpu, sh / 2 ) + PadL( name_otd, sh / 2 ) )
    add_string( '' )
    add_string( Center( 'Л_И_С_Т  У_Ч_Е_Т_А', sh ) )
    add_string( Center( 'М_Е_Д_И_Ц_И_Н_С_К_И_Х  У_С_Л_У_Г  N  ' + lnomer, sh ) )
    add_string( '' )
  Else
    add_string( PadR( name_lpu + ' (' + name_otd + ')', sh -18 ) + PadL( 'Форма 025-10у-97', 18 ) )
    If !eq_any( mem_razmer, 3, 4 )
      add_string( '' )
    Endif
    add_string( Center( 'ТАЛОН  АМБУЛАТОРНОГО  ПАЦИЕНТА  N  ' + lnomer, sh ) )
    If !eq_any( mem_razmer, 3, 4 )
      add_string( '' )
    Endif
  Endif
  add_string( '  Ф.И.О.: ' + mfio + '          Пол: ' + mpol )
  // ЮРА
  add_string( '  Дата рождения: ' + mdate_r + ' (' + AllTrim( mvzros_reb ) + ')    СНИЛС: ' + msnils )
  s := '  Место жительства: ' + mmi_git
  If !Empty( mrajon_git )
    s += ' (' + AllTrim( mrajon_git ) + ')'
  Endif
  add_string( s )
  k := perenos( tmp, 'Адрес регистрации: ' + madres, sh -2 )
  add_string( '  ' + tmp[ 1 ] )
  For i := 2 To k
    add_string( PadL( AllTrim( tmp[ 2 ] ), sh ) )
  Next
  If !Empty( madresp )
    k := perenos( tmp, 'Адрес пребывания: ' + madresp, sh -2 )
    add_string( '  ' + tmp[ 1 ] )
    For i := 2 To k
      add_string( PadL( AllTrim( tmp[ 2 ] ), sh ) )
    Next
  Endif
  s := '  Статус пациента: ' + mrab_nerab
  If mem_lu_stt == 2 .and. !Empty( mkategor )
    s += Space( 11 ) + 'Код категории льготы: ' + mkategor
  Endif
  add_string( s )
  If !Empty( mmr_dol )
    add_string( '  Место работы/учебы: ' + mmr_dol )
  Endif
  If m1komu == 0  // 27.06.12
    add_string( '  Регион финансирования: ' + mmest_inog )
  Endif
  add_string( '  Принадлежность счета: ' + mkomu )
  If m1komu == 0  // 27.06.12
    add_string( '  Страховой полис: ' + mpolis + mvidpolis + '     действителен до: ' + msrok_polis )
  Endif
  If !( mem_lu_stt == 2 .and. eq_any( mem_razmer, 2, 3, 4, 5 ) )
    add_string( '' )
  Endif
  add_string( '  Условия оказания мед.помощи: ______________' )
  If mem_razmer != 4
    If mem_lu_stt == 1
      add_string( '  Шифр основного заболевания: _____.' )
      add_string( '  Сопутствующие заболевания : _____, _____, _____, _____, _____, _____, _____.' )
    Else
      add_string( '  ------------------------------------------------------------------------------' )
      add_string( '    Код  |                                                     |Характер|Диспан.' )
      add_string( '   МКБ-10| Диагноз основной (уточненный)                       |заболев.| учет  ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         | Сопутствующие                                       |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  -------|-----------------------------------------------------|--------|-------' )
      add_string( '         |                                                     |  1  2  | 1 2 3 ' )
      add_string( '  ------------------------------------------------------------------------------' )
      If !( mem_lu_stt == 2 .and. eq_any( mem_razmer, 2, 3, 4, 5 ) )
        add_string( '' )
      Endif
    Endif
  Endif
  add_string( '  Результат обращения: ______________       Исход заболевания: _____________' )
  If mem_lu_stt == 2
    add_string( '           Повод обращения: ______________       Вид травмы: _______________' )
  Endif
  If !( mem_lu_stt == 2 .and. eq_any( mem_razmer, 3, 4 ) )
    add_string( '' )
  Endif
  add_string( Center( 'Срок лечения с  ' + Expand( full_date( sys_date ) ) + '  по  ____.____.____', sh ) )
  If !( mem_lu_stt == 2 .and. eq_any( mem_razmer, 3, 4 ) )
    add_string( '' )
  Endif
  add_string( '  Временная нетрудоспособность (больничный) ___ [ с ___.___.___ по ___.___.___ ]' )
  add_string( '  Уд-ие: ' + mvid_ud + '  серия: ' + mser + ' номер: ' + mnom )
  If !Empty( mmesto_rog )
    add_string( '  Место рождения: ' + mmesto_rog )
  Endif
  If mem_razmer != 4
    If !Empty( s_prim1[ 1 ] )
      add_string( '  Примечание: ' + s_prim1[ 1 ] )
      For k := 2 To Len( s_prim1 )
        add_string( Space( 14 ) + s_prim1[ k ] )
      Next
    Endif
    If tek_stroke < HH - 7
      add_string( '' )
      add_string( Center( 'О_К_А_З_А_Н_Ы   У_С_Л_У_Г_И', sh ) )
      reg_title( 2, 1 )
    Endif
    Do While tek_stroke < HH
      reg2title()
    Enddo
  Endif
  If mem_fio_r == 1 .and. !( kod_polzovat == Chr( 0 ) )
    s := 'Регистратор: ' + mregistrator
    If mem_time == 1
      s += ' [' + mtime + ']'
    Endif
    add_string( PadL( s, sh ) )
  Endif
  If mem_razmer == 5   // ф.A4, отрывные талоны на платные услуги
    tmp := f_otr_plat( name_otd, l1nomer, mfio )
    For j := 1 To 2
      add_string( Replicate( '-', sh ) )
      For k := 1 To Len( tmp )
        If tek_stroke < 80
          add_string( tmp[ k ] + '|' + tmp[ k ] )
        Endif
      Next
    Next
  Endif
  If mem_ff_lu == 1 .and. mem_2_list == 1
    add_string( Chr( 12 ) )
    tek_stroke := 0
    n_list++
    reg_title( 2, 2 )
    Do While tek_stroke < HH -7
      reg2title()
    Enddo
    add_string( '                                                                  _____________ ' )
    add_string( '                                            Общая сумма лечения: |             |' )
    add_string( '                                                                 |_____________|' )
    add_string( '' )
    add_string( Center( 'Оператор ________________________', sh ) )
  Endif
  FClose( fp )
  rest_box( buf )
  viewtext( n_file, , , , .f., , , regim_print, , , , ( mem_ff_lu == 1 ) )

  Return Nil

//
Function reg_title( k1, k2 )

  Default k1 To 1
  If k1 == 2
    add_string( '--------------------------------------------------------------------------------' )
    add_string( ' Отде-|Дата оказа-|  Код  |   Шифр   | На  |           |           | Количество ' )
    add_string( ' ление|ния услуги |  МКБ  |  услуги  |дому?|   Врач    | Ассистент |   услуг    ' )
    add_string( '--------------------------------------------------------------------------------' )
    If k2 == 1
      reg2title()
    Endif
    If k2 == 2
      reg2title()
    Endif
  Endif

  Return Nil

//
Function reg2title()

  add_string( '      |           |       |          |     |           |           |            ' )
  add_string( '______|___________|_______|__________|_____|___________|___________|____________' )

  Return Nil

//
Function f_otr_plat( lotd, lnomer, lfio )

  Local sh := 39, arr[ 12 ], i

  AFill( arr, Space( sh ) )
  arr[ 1 ] := PadR( lotd, sh -15 ) + '   ___.___.' + lstr( Year( Date() ) )
  arr[ 3 ] := PadR( ' ' + lnomer + ' ' + fam_i_o( lfio ), sh -14 ) + ' Диагноз _____'
  arr[ 4 ] := '----+--------+------+------+-----+-----'
  arr[ 5 ] := 'Отд.| Услуга | Врач |Кол-во| м/с | сан.'
  arr[ 6 ] := '----+--------+------+------+-----+-----'
  For i := 8 To Len( arr ) Step 2
    arr[ i ] := Replicate( '-', sh )
  Next

  Return arr

//
Function f_msek_do_posle( lcel, lgrup )

  Local s := ''

  If lcel == 1
    s := lstr( lgrup ) + ' гр.'
  Elseif lcel == 2 .and. lgrup > 0
    s := Str( lgrup, 3 ) + ' %'
  Endif

  Return PadC( s, 5 )

//
Function fluorogr_lpu()

  Local date_end, s, lcolor

  If Type( 'mem_fluor' ) == 'N' .and. mem_fluor == 1
    s := ' Флюорография: '
    lcolor := 'W+/GR'
    If !Eof() .and. !Empty( kart_->date_fl )
      If kart_->gr_risk > 0 // есть группа риска - период полгода
        date_end := c4tod( kart_->date_fl ) + 183
      Else // период год
        date_end := c4tod( kart_->date_fl ) + 365
      Endif
      s += full_date( c4tod( kart_->date_fl ) )
      If date_end > sys_date
        lcolor := 'W+/G'
      Else
        lcolor := 'W+/R'
      Endif
    Endif
    @ 1, 51 Say PadR( s, 26 ) Color lcolor
  Endif

  Return Nil

// * специально для Поликлиники №4

//
Function p4_travma( r, c )

  Static snomer := 0, sdost, svrach, stravma := 11, sd_obr, sd_travm
  Local buf := SaveScreen(), mtitul, k, fl_dost := ( Type( 'arr_dost' ) == 'A' ), ;
    fl := .f.

  Default sdost To Space( 10 ), svrach To Space( 10 ), ;
    sd_obr To sys_date, sd_travm To sys_date
  Private m1travma := stravma
  mnomer := snomer
  mdate_obr := sd_obr
  mdate_travm := sd_travm
  mtravma := inieditspr( A__MENUVERT, stm_travma, stravma )
  mvrach := svrach
  mdost := sdost
  mtitul := AllTrim( kart->fio )
  k := MaxRow() -14
  box_shadow( k, 0, MaxRow() -1, MaxCol(), color1, mtitul, color8 )
  str_center( k + 1, 'Ввод реквизитов для печати в Травматологическом отделении', 'G+/B' )
  SetColor( cDataCGet )
  ++k
  @ ++k, 4 Say 'Порядковый номер по журналу' Get mnomer Pict '999999'
  @ ++k, 4 Say 'Врач' Get mvrach ;
    reader {| x| menu_reader( x, arr_vrach, A__MENUVERT, , , .f. ) }
  @ ++k, 4 Say 'Дата обращения' Get mdate_obr
  @ ++k, 4 Say 'Дата получения травмы' Get mdate_travm
  @ ++k, 4 Say 'Вид травмы' Get mtravma ;
    reader {| x| menu_reader( x, stm_travma, A__MENUVERT, , , .f. ) }
  If fl_dost
    @ ++k, 4 Say 'Как доставлен' Get mdost ;
      reader {| x| menu_reader( x, arr_dost, A__MENUVERT, , , .f. ) }
  Endif
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение печати' )
  myread()
  SetColor( color0 )
  RestScreen( buf )
  If LastKey() != K_ESC
    fl := .t.
    If fl_dost
      sdost := mdost
    Endif
    snomer := mnomer
    svrach := mvrach
    stravma := m1travma
    sd_obr := mdate_obr
    sd_travm := mdate_travm
  Endif

  Return fl

// 27.02.20
Function prn_kartoteka( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1
  Local mas_pmt, mas_msg, mas_fun, j, r, nuch, nsmo

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { 'Сводный DBF-~файл' }
    mas_msg := { 'Сводная информация (создание DBF-файла по участку/по СМО)' }
    mas_fun := { 'prn_kartoteka(11)' }
    If glob_mo()[ _MO_IS_UCH ]
      AAdd( mas_pmt, 'Создание файла для ~ЛИС' )
      AAdd( mas_msg, 'Создание файла для ЛИС в ГБУЗ "ВОМИАЦ" (письмо №1337 от 30.11.15г.)' )
      AAdd( mas_fun, 'prn_kartoteka(12)' )
      AAdd( mas_pmt, 'Прикреплённое ~население' )
      AAdd( mas_msg, 'Просмотр прикреплённого населения' )
      AAdd( mas_fun, 'prn_kartoteka(13)' )
    Endif
    AAdd( mas_pmt, 'Информация по ~инвалидам' )
    AAdd( mas_msg, 'Просмотр сводной информации по инвалидам' )
    AAdd( mas_fun, 'prn_kartoteka(14)' )
    // выгрузка в Excel
    AAdd( mas_pmt, 'Выгрузка в Excel' )
    AAdd( mas_msg, 'Выгрузка картотеки в Excel' )
    AAdd( mas_fun, 'prn_kartoteka(41)' )
    If T_ROW > 8
      r := T_ROW - Len( mas_pmt ) -3
    Else
      r := T_ROW
    Endif
    popup_prompt( r, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    If ( j := popup_prompt( T_ROW, T_COL + 5, si2, { 'по ~участку', 'по ~СМО' } ) ) > 0
      si2 := j
      If j == 1
        If ( nuch := input_uchast() ) != NIL
          f0_prn_kartotek( 1, nuch )
        Endif
      Elseif j == 2
        If ( j := popup_prompt( T_ROW, T_COL + 5, si2, ;
            { 'КапиталЪ Медстрах', 'ОАО "СОГАЗ-Мед"', 'ООО "МСК-Максимус"', 'ООО "РГС-Медицина"' } ) ) > 0
          f0_prn_kartotek( 2, , { '34001', '34002', '34006', '34007' }[ j ] )
        Endif
      Endif
    Endif
  Case k == 12
    create_dbf_for_lis()
  Case k == 13
    mas_pmt := { '~Сводная информация', ;
      'Прикреплённые к нашей ~МО', ;
      'Прикреплённые к ~другим МО', ;
      '~Не прикреплённые ни к одной МО' }
    mas_msg := { 'Итоговая информация по прикреплённому населению из нашей картотеки', ;
      'Просмотр/печать населения, прикреплённого к нашей МО', ;
      'Просмотр/печать населения, прикреплённого к другим МО', ;
      'Просмотр/печать населения, не прикреплённого ни к одной МО' }
    mas_fun := { 'prn_kartoteka(21)', ;
      'prn_kartoteka(22)', ;
      'prn_kartoteka(23)', ;
      'prn_kartoteka(24)' }
    Private arr_mo := {}, arr_no := {}
    popup_prompt( T_ROW -3 - Len( mas_pmt ), T_COL + 5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 14
    pr_invalid()
  Case k == 21
    pripisnoe_naselenie_view()
  Case k == 22
    mas_pmt := { 'Весь список прикреплённых к ~МО', ;
      '~Итого по участковым врачам', ;
      'Количество по ~участкам' }
    mas_msg := { 'Просмотр/печать населения, прикреплённого к нашей МО', ;
      'Подсчёт количества пациентов, прикреплённых к участковым врачам', ;
      'Подсчёт количества прикреплённого населения по участкам' }
    mas_fun := { 'prn_kartoteka(31)', ;
      'prn_kartoteka(32)', ;
      'prn_kartoteka(33)' }
    popup_prompt( T_ROW, T_COL + 5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 23
    spisok_pripisnoe_naselenie( 2 )
  Case k == 24
    spisok_pripisnoe_naselenie( 3 )
  Case k == 31
    spisok_pripisnoe_naselenie( 1 )
  Case k == 32
    prn_itogo_uch_vrach()
  Case k == 33
    kol_uch_pripisnoe_naselenie()
  Case k == 41
    kartotektoexcel()
  Case k == 42
  Case k == 43
  Case k == 44
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Endif
  Endif

  Return Nil

// 15.09.23
Function pr_invalid()

  Static suchast := 0, sinvalid := 0, sprik := 1, sspisok := 1, ;
    mm_invalid := { { 'все', 0 }, { '1 группа', 1 }, { '2 группа', 2 }, { '3 группа', 3 }, { 'дети-инвалиды', 4 } }, ;
    mm_prik := { { 'все', 0 }, { 'прикреплён к нашей МО', 1 }, { 'прикреплён к другим МО', 2 }, { 'прикрепление неизвестно', 3 } }, ;
    mm_pol := { { 'все', 0 }, { 'мужчины', 1 }, { 'женщины', 2 } }, ;
    mm_rab := { { 'все', 0 }, { 'работающие', 1 }, { 'неработающие', 2 } }, ;
    mm_pens := { { 'все', 0 }, { 'пенсионеры', 1 }, { 'не пенсионеры', 2 } }, ;
    mm_gorod := { { 'все', 0 }, { 'город', 1 }, { 'село', 2 } }, ;
    mm_spisok := { { 'список инвалидов', 1 }, { 'общее количество', 2 } }
  Local buf := SaveScreen(), r := 14, sh, HH := 60, name_file := cur_dir() + 'invalid.txt', k_fio, tt_fio[ 2 ]

  SetColor( cDataCGet )
  myclear( r )
  Private muchast := suchast, ;
    m1INVALID := sinvalid, mINVALID, ;
    m1prik := sprik, mprik, ;
    m1pol := 0, mpol := 'все', ;
    m1rab := 0, mrab := 'все', ;
    m1pens := 0, mpens := 'все', ;
    m1gorod := 0, mgorod := 'все', ;
    m1spisok := sspisok, mspisok := mm_spisok[ sspisok, 1 ], ;
    gl_area := { r, 0, MaxRow() -1, MaxCol(), 0 }
  minvalid := inieditspr( A__MENUVERT, mm_invalid, m1invalid )
  mprik := inieditspr( A__MENUVERT, mm_prik, m1prik )
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - запустить поиск' )
  //
  @ r, 0 To r + 9, MaxCol() Color color8
  str_center( r, ' Запрос в картотеке информации по инвалидам ', color14 )
  @ r + 1, 2 Say 'Инвалидность' Get minvalid reader {| x| menu_reader( x, mm_invalid, A__MENUVERT, , , .f. ) }
  @ r + 2, 2 Say 'Прикрепление' Get mprik reader {| x| menu_reader( x, mm_prik, A__MENUVERT, , , .f. ) }
  @ r + 3, 2 Say 'Номер участка (0 - по всем участкам)' Get muchast Pict '99999'
  @ r + 4, 2 Say 'Пол' Get mpol reader {| x| menu_reader( x, mm_pol, A__MENUVERT, , , .f. ) }
  @ r + 5, 2 Say 'Работающий?' Get mrab reader {| x| menu_reader( x, mm_rab, A__MENUVERT, , , .f. ) }
  @ r + 6, 2 Say 'Пенсионер?' Get mpens ;
    reader {| x| menu_reader( x, mm_pens, A__MENUVERT, , , .f. ) }
  @ r + 7, 2 Say 'Город/село' Get mgorod ;
    reader {| x| menu_reader( x, mm_gorod, A__MENUVERT, , , .f. ) }
  @ r + 8, 2 Say 'Как выводить результат поиска?' Get mspisok ;
    reader {| x| menu_reader( x, mm_spisok, A__MENUVERT, , , .f. ) }
  myread()
  If LastKey() != K_ESC
    mywait()
    suchast := muchast
    sinvalid := m1invalid
    sprik := m1prik
    sspisok := m1spisok
    //
    dbCreate( cur_dir() + 'tmp', { ;
      { 'kod',       'N',  7, 0 }, ;
      { 'INVALID',   'N',  1, 0 }, ; // группа инвалидности
    { 'UCHAST',   'N',  2, 0 }, ; // номер участка
    { 'POL',   'C',  1, 0 }, ; // пол
    { 'DATE_R', 'D',  8, 0 }, ; // дата рождения пациента
    { 'pens',   'N',  1, 0 }, ; //
    { 'rab',   'N',  1, 0 }, ; //
    { 'gorod',   'N',  1, 0 }, ; //
    { 'LET',   'N',  2, 0 }, ; // сколько лет в этом году
    { 'MO_PR',     'C',  6, 0 }; // код МО приписки
    }, , .t., 'TMP' )
    r_use( dir_server() + 'kartotek', , 'KART' )
    r_use( dir_server() + 'kartote2', , 'KART2' )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Set Relation To RecNo() into KART, RecNo() into KART2
    Index On Str( kart->kod, 7 ) to ( cur_dir() + 'tmp_kart' ) For Between( kart_->INVALID, 1, 4 )
    Go Top
    Do While !Eof()
      f1_pr_invalid()
      Select KART_
      Skip
    Enddo
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      func_error( 4, 'Нет сведений!' )
    Else
      fp := FCreate( name_file )
      n_list := 1
      tek_stroke := 0
      add_string( '' )
      add_string( Center( Expand( 'ИНФОРМАЦИЯ ПО ИНВАЛИДАМ' ), sh ) )
      add_string( '' )
      add_string( ' == ПАРАМЕТРЫ ПОИСКА ==' )
      If m1spisok == 1 // список инвалидов
        arr_title := { '', '', '', '' }
        If muchast == 0
          arr_title[ 1 ] += '──┬'
          arr_title[ 2 ] += '№№│'
          arr_title[ 3 ] += 'уч│'
          arr_title[ 4 ] += '──┴'
        Endif
        arr_title[ 1 ] += '───────────────────────────────────────────┬──┬──────────┬───┬───────────────────────────────────'
        arr_title[ 2 ] += '             Ф.И.О. пациента               │Ле│   дата   │Гр.│              Адрес                '
        arr_title[ 3 ] += '                (телефон)                  │т │ рождения │инв│                                   '
        arr_title[ 4 ] += '───────────────────────────────────────────┴──┴──────────┴───┴───────────────────────────────────'
        reg_print := f_reg_print( arr_title, @sh, 2 )
      Else
        sh := 2
        reg_print := 2
      Endif
      If m1invalid > 0
        add_string( 'Группа инвалидности: ' + inieditspr( A__MENUVERT, mm_invalid, m1invalid ) )
      Endif
      If !Empty( muchast )
        add_string( 'Участок: ' + lstr( muchast ) )
      Endif
      If !Empty( m1prik )
        add_string( 'Отношение к прикреплению: ' + inieditspr( A__MENUVERT, mm_prik, m1prik ) )
      Endif
      If m1gorod > 0
        add_string( 'Место жительства: ' + inieditspr( A__MENUVERT, mm_gorod, m1gorod ) )
      Endif
      If !Empty( m1pol )
        add_string( 'Пол: ' + inieditspr( A__MENUVERT, mm_pol, m1pol ) )
      Endif
      If m1rab > 0
        add_string( Upper( inieditspr( A__MENUVERT, mm_rab, m1rab ) ) )
      Endif
      If m1pens > 0
        add_string( Upper( inieditspr( A__MENUVERT, mm_pens, m1pens ) ) )
      Endif
      add_string( '' )
      If m1spisok == 1 // список инвалидов
        AEval( arr_title, {| x| add_string( x ) } )
        ii := 0
        r_use( dir_server() + 'kartote2', , 'KART2' )
        r_use( dir_server() + 'kartote_', , 'KART_' )
        r_use( dir_server() + 'kartotek', , 'KART' )
        Set Relation To RecNo() into KART_, To RecNo() into KART2
        Use ( cur_dir() + 'tmp' ) new
        Set Relation To kod into KART
        Index On Upper( kart->fio ) to ( cur_dir() + 'tmp' )
        Select TMP
        Go Top
        Do While !Eof()
          ++ii
          @ MaxRow(), 1 Say Str( ii / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorSt2Msg
          s1 := ''
          If muchast == 0
            s1 += put_val( kart->uchast, 2 ) + ' '
          Endif
          s := ''
          If !Empty( kart_->PHONE_H )
            s += 'д.' + AllTrim( kart_->PHONE_H ) + ' '
          Endif
          If !Empty( kart_->PHONE_M )
            s += 'м.' + AllTrim( kart_->PHONE_M ) + ' '
          Endif
          If !Empty( kart_->PHONE_W )
            s += 'р.' + AllTrim( kart_->PHONE_W )
          Endif
          s := AllTrim( kart->fio ) + ' ' + s
          k_fio := perenos( tt_fio, s, 43 )
          s1 += PadR( tt_fio[ 1 ], 43 ) + Str( tmp->let, 3 ) + ' ' + full_date( kart->date_r )
          If tmp->INVALID < 4
            s1 += Str( tmp->INVALID, 3 ) + '  '
          Else
            s1 += ' дет '
          Endif
          s1 += AllTrim( kart->adres )
          If verify_ff( HH, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( s1 )
          For i := 2 To k_fio
            s1 := ''
            If muchast == 0
              s1 += Space( 3 )
            Endif
            s1 += PadR( tt_fio[ i ], 44 )
            add_string( s1 )
          Next
          Select TMP
          Skip
        Enddo
      Else // общее количество
        arr := Array( 4 )
        afillall( arr, 0 )
        Use ( cur_dir() + 'tmp' ) new
        Go Top
        Do While !Eof()
          arr[ tmp->INVALID ] ++
          Select TMP
          Skip
        Enddo
        add_string( '1 группа      ' + lstr( arr[ 1 ] ) )
        add_string( '2 группа      ' + lstr( arr[ 2 ] ) )
        add_string( '3 группа      ' + lstr( arr[ 3 ] ) )
        add_string( 'дети-инвалиды ' + lstr( arr[ 4 ] ) )
      Endif
      add_string( '' )
      add_string( 'Итого количество пациентов: ' + lstr( tmp->( LastRec() ) ) + ' чел.' )
      FClose( fp )
      Close databases
      RestScreen( buf )
      viewtext( name_file, , , , .t., , , reg_print )
    Endif
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 17.03.20
Static Function f1_pr_invalid()

  Local i, j, k, n, s, arr, fl := .t., god_r, arr1

  // За исключением умерших (по сведению ТФОМС)

  fl := !( Left( kart2->PC2, 1 ) == '1' )
  If fl
    If fl .and. !Empty( m1prik )
      If m1prik == 1 // к нашей МО
        fl := ( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
      Elseif m1prik == 2 // к другим МО
        fl := !( kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
      Else // прикрепление неизвестно
        fl := Empty( kart2->MO_PR ) .or. kart2->MO_PR == '000000'
      Endif
    Endif
    If muchast > 0
      fl := ( kart->uchast == muchast )
    Endif
    If fl .and. !Empty( m1pol )
      If kart->pol == 'М'
        fl := ( m1pol == 1 )
      Else
        fl := ( m1pol == 2 )
      Endif
    Endif
    is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )
    If fl .and. m1gorod > 0
      If is_selo
        fl := ( m1gorod == 1 )
      Else
        fl := ( m1gorod == 2 )
      Endif
    Endif
    If fl .and. m1pens > 0
      If kart_->PENSIONER == 1
        fl := ( m1pens == 1 )
      Else
        fl := ( m1pens == 2 )
      Endif
    Endif
    If fl .and. m1invalid > 0
      fl := ( m1invalid == kart_->INVALID )
    Endif
    If fl .and. m1rab > 0
      fl := ( kart->rab_nerab == m1rab -1 )
    Endif
    //
    If fl
      If ( k := Year( sys_date ) - Year( kart->date_r ) ) > 99
        k := 99
      Endif
      Select TMP
      Append Blank
      tmp->kod     := kart->kod
      tmp->INVALID := kart_->INVALID
      tmp->UCHAST  := kart->uchast
      tmp->POL     := kart->pol
      tmp->DATE_R  := kart->date_r
      tmp->pens    := iif( kart_->PENSIONER == 1, 1, 2 )
      tmp->rab     := kart->rab_nerab + 1
      tmp->gorod   := iif( is_selo, 2, 1 )
      tmp->LET     := k
      tmp->MO_PR   := kart2->MO_PR
    Endif
  Endif

  Return Nil


// 12.09.25 Создание файла для ЛИС в ГБУЗ 'ВОМИАЦ' (письмо №1337 от 30.11.15г.)
Function create_dbf_for_lis( par )

  Local adbf := { ;
    { 'FAM',   'C', 50, 0 }, ; // Ф. пациента
    { 'IM',   'C', 50, 0 }, ; // И. пациента
    { 'OT',   'C', 50, 0 }, ; // О. пациента
    { 'POL',   'C',  1, 0 }, ; // пол
    { 'DATE_R', 'C', 10, 0 }, ; // дата рождения пациента
    { 'vid_ud',    'N',  2, 0 }, ; // вид удостоверения личности;по кодировке ФФОМС
    { 'ser_ud',    'C', 10, 0 }, ; // серия удостоверения личности
    { 'nom_ud',    'C', 20, 0 }, ; // номер удостоверения личности
    { 'mesto_r',   'C', 100, 0 }, ; // место рождения
    { 'VPOLIS',    'N',  1, 0 }, ; // вид полиса (от 1 до 3);1-старый, 2-врем., 3-новый;по умолчанию 1 - старый
    { 'SPOLIS',    'C', 10, 0 }, ; // серия полиса
    { 'NPOLIS',    'C', 25, 0 }, ; // номер полиса
    { 'OKATO',  'C', 11, 0 }, ; //
    { 'SNILS',   'C', 14, 0 }, ;
    { 'KOD_SMO',   'C',  5, 0 };  //
  }
  Local i := 0, hGauge, n_file, arr_fio, fl_exit := .f.

  Default par To 1
  If par == 2 // Создание файла для ЛИС из БД КДП2 (пациенты с кодом ЛИС и, возможно, изменёнными реквизитами)
    AAdd( adbf, { 'kod_LIS',   'C', 10, 0 } )
  Endif
  n_file := 'L' + glob_mo()[ _MO_KOD_TFOMS ]
  dbCreate( n_file, adbf )
  Use ( n_file ) New Alias TMP
  hGauge := gaugenew(, , , 'Создание файла ' + Upper( n_file + sdbf() ), .t. )
  gaugedisplay( hGauge )
  r_use( dir_server() + 'mo_kfio', , 'KFIO' )
  Index On Str( kod, 7 ) to ( cur_dir() + 'tmp_kfio' )
  r_use_base( 'kartotek' )
  Set Order To 2
  Go Top
  Do While !Eof()
    gaugeupdate( hGauge, ++i / LastRec() )
    If Inkey() == K_ESC
      fl_exit := .t.
      Exit
    Endif
    If !kart2->( Eof() ) .and. iif( par == 1, kart2->mo_pr == glob_mo()[ _MO_KOD_TFOMS ], !Empty( Int( Val( kart2->kod_AK ) ) ) )
      Select TMP
      Append Blank
      arr_fio := retfamimot( 1, .f., .t. )
      tmp->fam := f_s_csv( arr_fio[ 1 ] )
      tmp->im  := f_s_csv( arr_fio[ 2 ] )
      tmp->ot  := f_s_csv( arr_fio[ 3 ] )
      tmp->POL := kart->pol                   // пол
      tmp->DATE_R := full_date( kart->date_r )  // дата рождения пациента
      tmp->mesto_r := f_s_csv( kart_->mesto_r ) // место рождения
      tmp->OKATO := kart_->okatog
      tmp->KOD_SMO := kart_->smo
      tmp->vpolis := kart_->vpolis
      tmp->spolis := LTrim( kart_->SPOLIS )
      tmp->npolis := LTrim( kart_->NPOLIS )
//      tmp->SNILS  := iif( Empty( kart->SNILS ), '', Transform( kart->SNILS, picture_pf ) )
      tmp->SNILS  := iif( Empty( kart->SNILS ), '', Transform_SNILS( kart->SNILS ) )
      tmp->vid_ud := kart_->vid_ud        // вид удостоверения личности по кодировке ФФОМС
      tmp->ser_ud := LTrim( kart_->ser_ud ) // серия удостоверения личности
      tmp->nom_ud := LTrim( kart_->nom_ud ) // номер удостоверения личности
      If par == 2
        tmp->kod_LIS := kart2->kod_AK
      Endif
      If tmp->( RecNo() ) % 500 == 0
        Commit
      Endif
    Endif
    Select KART
    Skip
  Enddo
  i := tmp->( LastRec() )
  Close databases
  closegauge( hGauge )
  If fl_exit
    func_error( 4, 'Операция прервана!' )
  Elseif i  == 0
    func_error( 4, 'Некого включать в файл!' )
  Else
    n_message( { 'В каталоге ' + cur_dir() + ' создан файл ' + Upper( n_file + sdbf() ), ;
      lstr( i ) + ' пациентов.' }, , ;
      cColorSt2Msg, cColorStMsg, , , 'G+/R' )
  Endif

  Return Nil

// 12.09.25
Function f0_prn_kartotek( par, nuch, nsmo )

  Static si1 := 2
  Local adbf := { ;
    { 'UCHAST',   'N',  2, 0 }, ; // номер участка
    { 'KOD_VU',   'C', 10, 0 }, ; // код в участке
    { 'FIO',   'C', 50, 0 }, ; // Ф.И.О. больного
    { 'POL',   'C',  1, 0 }, ; // пол
    { 'DATE_R', 'C', 10, 0 }, ; // дата рождения больного
    { 'VZROS_REB', 'C',  9, 0 }, ; // 0-взрослый, 1-ребенок, 2-подросток
    { 'mesto_r',   'C', 100, 0 }, ; // место рождения;;
    { 'OKATOR',  'C', 11, 0 }, ; //
    { 'ADRESR',  'C', 100, 0 }, ; // адрес больного
    { 'OKATOP',  'C', 11, 0 }, ; //
    { 'ADRESP',  'C', 100, 0 }, ; // адрес больного
    { 'MR_DOL',   'C', 50, 0 }, ; // место работы или причина безработности
    { 'RABOTA',   'C', 12, 0 }, ; // {'RAB_NERAB','N', 1, 0}0-работ, 1-нераб
    { 'beg_polis', 'C', 10, 0 }, ; // дата начала действия полиса ;в формате dtoc4();'поле ''beg_polis'' из файла ''k_inog'' для иногородних'
    { 'end_polis', 'C', 10, 0 }, ; // срок действия полиса
    { 'VPOLIS',    'C',  6, 0 }, ; // вид полиса (от 1 до 3);1-старый, 2-врем., 3-новый;по умолчанию 1 - старый
    { 'POLIS',     'C', 30, 0 }, ; // серия полиса;;для наших - разделить по пробелу
    { 'KOD_SMO',   'C',  5, 0 }, ; //
    { 'SMO',       'C', 80, 0 }, ; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
    { 'SNILS',   'C', 14, 0 }, ;
    { 'vid_ud',    'C', 30, 0 }, ; // вид удостоверения личности;по кодировке ФФОМС;'PKRT_VID из ''APP_BASE'''
    { 'ser_ud',    'C', 10, 0 }, ; // серия удостоверения личности;;'PKRT_SER из ''APP_BASE'''
    { 'nom_ud',    'C', 20, 0 }, ; // номер удостоверения личности;;'PKRT_NOM из ''APP_BASE'''
    { 'kemvyd',    'C', 150, 0 }, ; // кем выдан документ - справочник 's_kemvyd'
    { 'kogdavyd',  'C', 10, 0 }, ; // когда выдан документ;;'PKRT_KOGDA из ''APP_BASE'''
    { 'PENSIONER', 'C', 11, 0 }, ; // является пенсионером?;0-нет, 1-да;
    { 'MO_PR',     'C',  6, 0 }, ; // код МО приписки
    { 'MONAME_PR', 'C', 60, 0 }, ; // наименование МО приписки
    { 'DATE_PR', 'C', 10, 0 }, ;  // дата приписки
    { 'PHONE_H',   'C', 11, 0 }, ; // телефон домашний;;
    { 'PHONE_M',   'C', 11, 0 }, ; // телефон мобильный;;
    { 'PHONE_W',   'C', 11, 0 }; // телефон рабочий;;
  }
  Local i := 0, hGauge, pr_uchast, n_file, fl_exit := .f.

  Private mdate_r, m1vzros_reb := 0
  Do Case
  Case par == 1
    If ( pr_uchast := popup_prompt( T_ROW, T_COL + 5, si1, ;
        { 'Сортировка по ~Ф.И.О.', 'Сортировка по ~коду' } ) ) == 0
      Return Nil
    Endif
    si1 := pr_uchast
    n_file := cur_dir() + 'uchast' + StrZero( nuch, 2 )
    dbCreate( n_file, adbf )
    Use ( n_file ) New Alias TMP
    hGauge := gaugenew(, , , 'Создание файла ' + Upper( n_file + sdbf() ), .t. )
    gaugedisplay( hGauge )
    //
    r_use( dir_server() + 's_kemvyd', , 'SKEM' )
    r_use( dir_server() + 'kartote2', , 'KART2' )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Set Relation To kemvyd into SKEM
    r_use( dir_server() + 'kartotek', , 'KART' )
    Set Relation To RecNo() into KART_, To RecNo() into KART2
    If pr_uchast == 1 // по фио
      Set Index to ( dir_server() + 'kartoten' )
      // index on if(kod>0,'1','0')+ upper(fio)+dtos(date_r) to (dir_server() + 'kartoten') progress
    Else
      If is_uchastok == 1
        Set Index to ( dir_server() + 'kartoteu' )
        // index on strzero(uchast, 2)+strzero(kod_vu, 5) to (dir_server() + 'kartoteu') progress
      Else
        Set Index to ( dir_server() + 'kartotek' )
        // index on str(kod, 7) to (dir_server() + 'kartotek') progress
      Endif
    Endif
    Select KART
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, ++i / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t.
        Exit
      Endif
      If kart->uchast == nuch
        Select TMP
        Append Blank
        tmp->UCHAST := kart->UCHAST
        If is_uchastok == 1
          tmp->KOD_VU := LTrim( kart->BUKVA + lstr( kart->UCHAST ) + '/' + lstr( kart->KOD_VU ) )
        Elseif is_uchastok == 2
          tmp->KOD_VU := LTrim( kart->BUKVA + lstr( kart->UCHAST ) + '/' + lstr( kart->KOD ) )
        Else
          tmp->KOD_VU := LTrim( kart->BUKVA + '/' + lstr( kart->KOD ) )
        Endif
        tmp->FIO        := kart->fio               // Ф.И.О. больного
        tmp->POL        := kart->pol               // пол
        tmp->DATE_R     := full_date( kart->date_r ) // дата рождения больного
        mdate_r := kart->date_r
        fv_date_r(, .f. )
        tmp->VZROS_REB  := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
        tmp->mesto_r    := kart_->mesto_r // место рождения;;
        tmp->OKATOR     := kart_->okatog
        tmp->ADRESR     := ret_okato_ulica( kart->adres, kart_->okatog ) // адрес больного
        tmp->OKATOP     := kart_->okatop
        tmp->ADRESP     := ret_okato_ulica( kart_->adresp, kart_->okatop ) // адрес больного
        tmp->MR_DOL     := kart->MR_DOL // место работы или причина безработности
        tmp->RABOTA     := inieditspr( A__MENUVERT, menu_rab, kart->RAB_NERAB )
        tmp->beg_polis  := full_date( c4tod( kart_->beg_polis ) ) // дата начала действия полиса ;в формате dtoc4();'поле ''beg_polis'' из файла ''k_inog'' для иногородних'
        tmp->END_POLIS  := full_date( c4tod( kart->SROK_POLIS ) ) // срок действия полиса
        tmp->KOD_SMO    := kart_->smo
        tmp->SMO        := smo_to_screen( 1 )
        tmp->vpolis     := inieditspr( A__MENUVERT, mm_vid_polis, kart_->vpolis )
        tmp->polis      := LTrim( kart_->NPOLIS )
//        tmp->SNILS      := iif( Empty( kart->SNILS ), '', Transform( kart->SNILS, picture_pf ) )
        tmp->SNILS      := iif( Empty( kart->SNILS ), '', Transform_SNILS( kart->SNILS ) )
        tmp->vid_ud     := inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) // вид удостоверения личности;по кодировке ФФОМС;'PKRT_VID из ''APP_BASE'''
        tmp->ser_ud     := LTrim( kart_->ser_ud ) // серия удостоверения личности;;'PKRT_SER из ''APP_BASE'''
        tmp->nom_ud     := LTrim( kart_->nom_ud ) // номер удостоверения личности;;'PKRT_NOM из ''APP_BASE'''
        tmp->kemvyd     := skem->name
        tmp->kogdavyd   := full_date( kart_->kogdavyd )
        tmp->PENSIONER  := iif( kart_->PENSIONER == 1, 'пенсионер', '' )
        tmp->PHONE_H    := kart_->PHONE_H // телефон домашний;;
        tmp->PHONE_M    := kart_->PHONE_M // телефон мобильный;;
        tmp->PHONE_W    := kart_->PHONE_W // телефон рабочий;;
        If !Empty( tmp->mo_pr := kart2->mo_pr )
          tmp->MONAME_PR := ret_mo( kart2->mo_pr )[ _MO_SHORT_NAME ]
          If !Empty( kart2->pc4 )
            tmp->DATE_PR := kart2->pc4
          Else
            tmp->DATE_PR := full_date( kart2->DATE_PR )
          Endif
        Endif
        If tmp->( RecNo() ) % 2000 == 0
          Commit
        Endif
      Endif
      Select KART
      Skip
    Enddo
    i := tmp->( LastRec() )
    Close databases
    closegauge( hGauge )
  Case par == 2
    n_file := cur_dir() + 'smo' + nsmo
    dbCreate( n_file, adbf )
    Use ( n_file ) New Alias TMP
    hGauge := gaugenew(, , , 'Создание файла ' + Upper( n_file + sdbf() ), .t. )
    gaugedisplay( hGauge )
    //
    r_use( dir_server() + 's_kemvyd', , 'SKEM' )
    r_use( dir_server() + 'kartote2', , 'KART2' )
    r_use( dir_server() + 'kartote_', , 'KART_' )
    Set Relation To kemvyd into SKEM
    r_use( dir_server() + 'kartotek', dir_server() + 'kartoten', 'KART' )
    Set Relation To RecNo() into KART_, To RecNo() into KART2
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, ++i / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t.
        Exit
      Endif
      If kart_->smo == nsmo
        Select TMP
        Append Blank
        tmp->UCHAST := kart->UCHAST
        If is_uchastok == 1
          tmp->KOD_VU := LTrim( kart->BUKVA + lstr( kart->UCHAST ) + '/' + lstr( kart->KOD_VU ) )
        Elseif is_uchastok == 2
          tmp->KOD_VU := LTrim( kart->BUKVA + lstr( kart->UCHAST ) + '/' + lstr( kart->KOD ) )
        Else
          tmp->KOD_VU := LTrim( kart->BUKVA + '/' + lstr( kart->KOD ) )
        Endif
        tmp->FIO        := kart->fio               // Ф.И.О. больного
        tmp->POL        := kart->pol               // пол
        tmp->DATE_R     := full_date( kart->date_r ) // дата рождения больного
        mdate_r := kart->date_r
        fv_date_r(, .f. )
        tmp->VZROS_REB  := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
        tmp->mesto_r    := kart_->mesto_r // место рождения;;
        tmp->OKATOR     := kart_->okatog
        tmp->ADRESR     := ret_okato_ulica( kart->adres, kart_->okatog ) // адрес больного
        tmp->OKATOP     := kart_->okatop
        tmp->ADRESP     := ret_okato_ulica( kart_->adresp, kart_->okatop ) // адрес больного
        tmp->MR_DOL     := kart->MR_DOL // место работы или причина безработности
        tmp->RABOTA     := inieditspr( A__MENUVERT, menu_rab, kart->RAB_NERAB )
        tmp->beg_polis  := full_date( c4tod( kart_->beg_polis ) ) // дата начала действия полиса ;в формате dtoc4();'поле ''beg_polis'' из файла ''k_inog'' для иногородних'
        tmp->END_POLIS  := full_date( c4tod( kart->SROK_POLIS ) ) // срок действия полиса
        tmp->KOD_SMO    := kart_->smo
        tmp->SMO        := smo_to_screen( 1 )
        tmp->vpolis     := inieditspr( A__MENUVERT, mm_vid_polis, kart_->vpolis )
        tmp->polis      := LTrim( kart_->NPOLIS )
//        tmp->SNILS      := iif( Empty( kart->SNILS ), '', Transform( kart->SNILS, picture_pf ) )
        tmp->SNILS      := iif( Empty( kart->SNILS ), '', Transform_SNILS( kart->SNILS ) )
        tmp->vid_ud     := inieditspr( A__MENUVERT, getvidud(), kart_->vid_ud ) // вид удостоверения личности;по кодировке ФФОМС;'PKRT_VID из ''APP_BASE'''
        tmp->ser_ud     := LTrim( kart_->ser_ud ) // серия удостоверения личности;;'PKRT_SER из ''APP_BASE'''
        tmp->nom_ud     := LTrim( kart_->nom_ud ) // номер удостоверения личности;;'PKRT_NOM из ''APP_BASE'''
        tmp->kemvyd     := skem->name
        tmp->kogdavyd   := full_date( kart_->kogdavyd )
        tmp->PENSIONER  := iif( kart_->PENSIONER == 1, 'пенсионер', '' )
        tmp->PHONE_H    := kart_->PHONE_H // телефон домашний;;
        tmp->PHONE_M    := kart_->PHONE_M // телефон мобильный;;
        tmp->PHONE_W    := kart_->PHONE_W // телефон рабочий;;
        If !Empty( tmp->mo_pr := kart2->mo_pr )
          tmp->MONAME_PR := ret_mo( kart2->mo_pr )[ _MO_SHORT_NAME ]
          If !Empty( kart2->pc4 )
            tmp->DATE_PR := kart2->pc4
          Else
            tmp->DATE_PR := full_date( kart2->DATE_PR )
          Endif
        Endif
        If tmp->( RecNo() ) % 2000 == 0
          Commit
        Endif
      Endif
      Select KART
      Skip
    Enddo
    i := tmp->( LastRec() )
    Close databases
    closegauge( hGauge )
  Endcase
  If fl_exit
    func_error( 4, 'Операция прервана!' )
  Endif
  n_message( { 'Создан файл ' + Upper( n_file + sdbf() ), ;
    lstr( i ) + ' человек.' } )

  Return Nil

// 09.09.25
Function pripisnoe_naselenie_view()

  Local i, j, s, arr_mo := {}, n_file := cur_dir() + 'pr_nas.txt', ;
    sh := 80, HH := 60, buf := save_maxrow()

  mywait()
  r_use_base( 'kartotek' )
  Go Top
  Do While !Eof()
    If ( i := AScan( arr_mo, {| x| x[ 1 ] == kart2->mo_pr } ) ) == 0
      AAdd( arr_mo, { kart2->mo_pr, 0, 0 } )
      i := Len( arr_mo )
    Endif
    arr_mo[ i, 2 ] ++
    If Left( kart2->PC2, 1 ) == '1'
      arr_mo[ i, 3 ] ++
    Endif
    Skip
  Enddo
  Close databases
  ASort( arr_mo, , , {| x, y| x[ 1 ] < y[ 1 ] } )
  fp := FCreate( n_file )
  tek_stroke := 0
  n_list := 1
  add_string( '' )
  add_string( Center( 'Состав картотеки (прикреплённое население)', sh ) )
  add_string( '──────┬──────┬──────┬───────────────────────────────────────────────────────────' )
  add_string( 'припи-│в т.ч.│      │                                                           ' )
  add_string( 'сано  │умерло│Код МО│ Наименование МО                                           ' )
  add_string( '──────┴──────┴──────┴───────────────────────────────────────────────────────────' )
  For i := 1 To Len( arr_mo )
    s := Str( arr_mo[ i, 2 ], 6 ) + put_val( arr_mo[ i, 3 ], 7 ) + ' ' + arr_mo[ i, 1 ] + ' '
    If ( j := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == arr_mo[ i, 1 ] } ) ) > 0
      s += glob_arr_mo()[ j, _MO_SHORT_NAME ]
    Else
      s += 'не прикреплено к медицинской организации'
    Endif
    verify_ff( HH, .t., sh )
    If arr_mo[ i, 1 ] == glob_mo()[ _MO_KOD_TFOMS ]
      add_string( Replicate( '=', sh ) )
    Endif
    add_string( s )
    If arr_mo[ i, 1 ] == glob_mo()[ _MO_KOD_TFOMS ]
      add_string( Replicate( '=', sh ) )
    Endif
  Next
  FClose( fp )
  rest_box( buf )
  viewtext( n_file, , , , .t., , , 5 )

  Return Nil

// 12.10.15 поиск пациентов в картотеке с изменившимися участками (СНИЛС участкового врача)
Function find_change_snils( /*@*/curr)

  Local k := 2, hGauge

  clrline( MaxRow(), color0 )
  dbCreate( cur_dir() + 'tmpu', { { 'kod', 'N', 7, 0 }, { 'kodp', 'N', 5, 0 } } )
  Use ( cur_dir() + 'tmpu' ) new
  hGauge := gaugenew(, , , 'Поиск пациентов в картотеке с изменившимися участками', .t. )
  gaugedisplay( hGauge )
  curr := 0
  r_use( dir_server() + 'mo_pers', , 'P2' )
  r_use( dir_server() + 'mo_uchvr', , 'UV' )
  Index On Str( uch, 2 ) to ( cur_dir() + 'tmp_uv' )
  r_use_base( 'kartotek' )
  Set Order To 2
  find ( '1' )
  Do While kart->kod > 0 .and. !Eof()
    gaugeupdate( hGauge, ++curr / LastRec() )
    If kart->uchast > 0 .and. !kart2->( Eof() .and. !( Left( kart2->PC2, 1 ) == '1' ) ) ;
        .and. kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] .and. !Empty( kart2->SNILS_VR )
      fl := .f.
      Select UV
      find ( Str( kart->uchast, 2 ) )
      If Found() .and. !emptyall( uv->vrach, uv->vrachv, uv->vrachd )
        If count_years( kart->date_r, sys_date ) < 18 // дети
          If emptyall( uv->vrach, uv->vrachd )
            // aadd(aerr, 'на участке ' + lstr(kart->uchast) + ' не привязан участковый врач к детям')
          Else
            If !Empty( uv->vrach )
              p2->( dbGoto( uv->vrach ) )
            Else
              p2->( dbGoto( uv->vrachd ) )
            Endif
            fl := p2->kateg == 1 .and. !Empty( p2->snils ) .and. !( p2->snils == kart2->SNILS_VR )
          Endif
        Else
          If emptyall( uv->vrach, uv->vrachv )
            // aadd(aerr, 'на участке ' + lstr(kart->uchast) + ' не привязан участковый врач к взрослым')
          Else
            If !Empty( uv->vrach )
              p2->( dbGoto( uv->vrach ) )
            Else
              p2->( dbGoto( uv->vrachv ) )
            Endif
            fl := p2->kateg == 1 .and. !Empty( p2->snils ) .and. !( p2->snils == kart2->SNILS_VR )
          Endif
        Endif
      Else
        // aadd(aerr, 'к участку ' + lstr(kart->uchast) + ' не привязан участковый врач')
      Endif
      If fl
        Select TMPU
        Append Blank
        tmpu->kod := kart->kod
        tmpu->kodp := p2->kod
        @ MaxRow(), 1 Say lstr( tmpu->( RecNo() ) ) Color color0
        If tmpu->( RecNo() ) % 500 == 0
          Commit
        Endif
      Endif
    Endif
    Select KART
    Skip
  Enddo
  curr := tmpu->( LastRec() )
  Close databases
  closegauge( hGauge )
  If curr == 0
    func_error( 4, 'Не найдено пациентов с изменившимися участками (СНИЛС участкового врача)' )
  Else
    k := 3
  Endif
  clrline( MaxRow(), color0 )

  Return k

// 26.07.15
Function f1_p_f_prikreplenie( nKey, oBrow, regim )

  Local lkod, luchast := 0, buf, r1, rec, i, ret := -1, tmp_color

  If regim == 'edit'
    Do Case
    Case nKey == K_ENTER
      buf := save_maxrow()
      Private md_prik := tmp_krtp->d_prik, muchast := kart->uchast
      If muchast > 0
        Keyboard Chr( K_TAB )
      Endif
      tmp_color := SetColor( 'W+/B*, W+/R*, , , BG+/B*' )
      r1 := Row()
      @ r1, 45 Get muchast Pict '99'
      @ r1, 48 Get md_prik
      status_key( '^<Esc>^ - отказ от редактирования;  ^<Enter>^ - запись даты прикрепления' )
      myread()
      rest_box( buf )
      SetColor( tmp_color )
      If LastKey() != K_ESC
        If krtp->D_PRIK != md_prik
          Select KRTP
          Goto ( tmp_krtp->rec )
          g_rlock( forever )
          krtp->D_PRIK := md_prik
          Unlock
          Commit
        Endif
        If kart->uchast != muchast
          Select KART
          g_rlock( forever )
          kart->uchast := muchast
          Unlock
          Commit
        Endif
        Select TMP_KRTP
        tmp_krtp->d_prik := md_prik
        tmp_krtp->uchast := muchast
        If ( i := popup_2array( arr_prik1, r1 -5, 56, tmp_krtp->s_prik ) ) > 0 .and. ;
            tmp_krtp->s_prik != i
          If krtp->S_PRIK != i
            Select KRTP
            Goto ( tmp_krtp->rec )
            g_rlock( forever )
            krtp->S_PRIK := i
            Unlock
            Commit
          Endif
          Select TMP_KRTP
          tmp_krtp->s_prik := i
        Endif
      Endif
      buf := SaveScreen()
      kartotek_to_screen( 14, 23 )
      @ 13, 0 To 13, 79 Color 'G+/B'
      str_center( 13, ' Просмотр карточки пациента ', 'G+/B' )
      stat_msg( 'Нажмите любую клавишу...' )
      Inkey( 0 )
      RestScreen( buf )
      ret := 0
    Case nKey == K_INS
      Select TMP_KRTP
      rec := lkod := tmp_krtp->kod_k
      Set Relation To
      If ( lkod := f2_p_f_prikreplenie( lkod, @luchast ) ) > 0
        Select TMP_KRTP
        Set Order To 2
        find ( Str( lkod, 7 ) )
        If Found()
          func_error( 1, 'Данный пациент уже добавлен в этот список' )
        Else
          i := 2
          md_prik := sys_date
          If kart2->mo_pr == glob_mo()[ _MO_KOD_TFOMS ]
            lkod := rec
            func_error( 4, 'Данный пациент уже прикреплён к Вашей МО с ' + ;
              iif( Empty( kart2->pc4 ), full_date( kart2->DATE_PR ), AllTrim( kart2->pc4 ) ) + 'г.' )
              /*i := 1
              if !empty(kart2->DATE_PR)
                md_prik := kart2->DATE_PR
              endif
              func_error(1,'Данный пациент уже прикреплён к Вашему МО с ' + full_date(md_prik) + 'г.')*/
          Else
            rec := lkod
            Select KRTP
            addrec( 6 )
            krtp->REESTR := 0
            krtp->S_PRIK := i
            krtp->D_PRIK := md_prik
            krtp->KOD_K := lkod
            Unlock
            Commit
            Select TMP_KRTP
            Append Blank
            Replace rec With krtp->( RecNo() ), kod_k With krtp->kod_k, ;
              s_prik With krtp->S_PRIK, d_prik With krtp->D_PRIK, ;
              uchast With luchast
          Endif
        Endif
      Endif
      Select KART
      Set Order To 0
      Select TMP_KRTP
      Set Relation To kod_k into KART
      Set Order To 2
      oBrow:gotop()
      If LastRec() == 0
        ret := 1
      Else
        find ( Str( lkod, 7 ) )
        Set Order To 1
        ret := 0
      Endif
    Case nKey == K_DEL .and. f_esc_enter( 2 )
      Select KRTP
      Goto ( tmp_krtp->rec )
      deleterec()
      Select TMP_KRTP
      Delete
      Pack
      oBrow:gotop()
      ret := 0
      If LastRec() == 0
        ret := 1
      Endif
    Endcase
  Endif

  Return ret

// 26.07.15
Function f2_p_f_prikreplenie( lkod, /*@*/luchast)

  Local blk, t_arr[ BR_LEN ]

  Private str_find := '1', muslovie := 'kart->kod > 0'

  Select KART
  Set Order To 2
  If lkod > 0
    Goto ( lkod )
  Else
    find ( str_find )
  Endif
  t_arr[ BR_TOP ] := 2
  t_arr[ BR_BOTTOM ] := MaxRow() -2
  t_arr[ BR_LEFT ] := 33
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_TITUL ] := 'Картотека - прикрепление'
  t_arr[ BR_TITUL_COLOR ] := 'BG+/GR'
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .f., 72 }
  t_arr[ BR_ARR_BLOCK ] := { {|| findfirst( str_find ) }, ;
    {|| findlast( str_find ) }, ;
    {| _n| skippointer( _n, muslovie ) }, ;
    str_find, muslovie ;
    }
  blk := {|| iif( kart2->mo_pr == glob_mo()[ _MO_KOD_TFOMS ], { 1, 2 }, { 3, 4 } ) }
  t_arr[ BR_COLUMN ] := { { Center( 'Ф.И.О.', 35 ), {|| Left( kart->fio, 32 ) }, blk }, ;
    { 'Дата рожд.', {|| full_date( kart->date_r ) }, blk } }
  t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход; ^^ или нач.буква - поиск; ^<Enter>^ - выбрать для прикрепления' ) }
  lkod := 0
  t_arr[ BR_ENTER ] := {|| lkod := kart->kod, luchast := kart->uchast }
  edit_browse( t_arr )

  Return lkod

// 11.03.13
Function f3_p_f_prikreplenie()

  @ tr -3, 48 Say PadC( 'Отмечено пациентов: ' + lstr( tmp_krtp->( LastRec() ) ), 29 ) Color 'B/W*'

  Return Nil

// 10.06.14
Function view_otkrep_pripisnoe_naselenie()

  Local buf := SaveScreen()

  Private goal_dir := dir_server() + dir_XML_TF() + hb_ps()

  r_use( dir_server() + 'mo_krtf', , 'KRTF' )
  Index On DToS( dfile ) to ( cur_dir() + 'tmp_krtf' ) For TIP_IN == _CSV_FILE_OTKREP DESCENDING
  Go Top
  If Eof()
    func_error( 4, 'Нет принятых файлов открепления' )
  Else
    alpha_browse( T_ROW, 0, 23, 79, 'f1_view_otkrep_pr_nas', color0, , , , , , , ;
      'f2_view_otkrep_pr_nas', , { '═', '░', '═', 'N/BG, W+/N, R/BG, BG+/R', .t., 180 } )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 10.06.14
Function f1_view_otkrep_pr_nas( oBrow )

  Local oColumn, ;
    blk := {|| iif( hb_FileExists( goal_dir + AllTrim( krtf->FNAME ) + szip() ), { 1, 2 }, { 3, 4 } ) }

  oColumn := TBColumnNew( 'Дата файла', {|| full_date( krtf->dfile ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '  Кол-во;пациентов', {|| Str( krtf->kol, 6 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Наименование файла', {|| PadR( krtf->FNAME, 20 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' К какому МО прикреплены', {|| PadR( ret_mo( krtf->mo_pr )[ _MO_SHORT_NAME ], 36 ) } )
  oColumn:colorBlock := blk
  oBrow:addcolumn( oColumn )
  status_key( '^<Esc>^ - выход;  ^<F3>^ - информация о файле открепления' )

  Return Nil

// 10.06.14
Function f2_view_otkrep_pr_nas( nKey, oBrow )

  Local ret := -1, buf := SaveScreen()

  Do Case
  Case nKey == K_F3
    viewtext( devide_into_pages( goal_dir + AllTrim( krtf->FNAME ) + stxt(), 60, 80 ), , , , .t., , , 2 )
    ret := 0
  Endcase
  RestScreen( buf )

  Return ret

  // 09.02.26 чтение в память и анализ CSV-файла
Function read_csv_from_tf( cFile, nTypeFile, nkod_reestr )

  Local aerr := {}, j, nCountWithErr := 0, adbf, go_to_answer := .f., ;
    go_to_otkrep := .f., buf := save_maxrow()

  mywait( 'Производится анализ файла ' + cFile )
  Private cReadFile := name_without_ext( cFile ), ;
    cTimeBegin := hour_min( Seconds() )
  Private cFileProtokol := cReadFile + stxt()
  StrFile( Space( 10 ) + 'Протокол обработки файла: ' + cFile + ;
    hb_eol(), cFileProtokol )
  StrFile( Space( 10 ) + full_date( sys_date ) + 'г. ' + cTimeBegin + ;
    hb_eol(), cFileProtokol, .t. )
  // читаем файл в память
  If eq_any( nTypeFile, _CSV_FILE_PRIKFLK, _CSV_FILE_PRIKANS ) // тип принимаемого файла;6-ФЛК на реестр
    AAdd( aerr, 'Данный тип файлов *.CSV больше не обрабатывается' )
    // read_CSV_FILE_PRIK_FLK_ANS(cFile,aerr,nTypeFile,nkod_reestr)
    go_to_answer := Empty( aerr )
  Elseif nTypeFile == _CSV_FILE_ANSWER // тип принимаемого файла;2-ответ на реестр
    read_csv_file_answer( _tmp_dir1() + cFile, aerr, nkod_reestr )
    go_to_answer := Empty( aerr )
  Elseif nTypeFile == _CSV_FILE_OTKREP // тип принимаемого файла;3-открепление
    read_csv_file_otkrep( _tmp_dir1() + cFile, aerr )
    go_to_otkrep := Empty( aerr )
  Elseif nTypeFile == _CSV_FILE_SVERKAO // тип принимаемого файла;4-ответ на запрос для сверки
    read_csv_file_sverkao( _tmp_dir1() + cFile, aerr, nkod_reestr )
    go_to_answer := Empty( aerr )
  Elseif nTypeFile == _CSV_FILE_SVERKAO2 // тип принимаемого файла;8-ответ на запрос для сверки для МО без прикрепления
    read_csv_file_sverkao2( _tmp_dir1() + cFile, aerr, nkod_reestr )
    go_to_answer := Empty( aerr )
  Endif
  Close databases
  rest_box( buf )
  If Empty( aerr )
    // запишем принимаемый файл
    chip_copy_zipxml( full_zip, dir_server() + dir_XML_TF() )
    // запишем файл протокола обработки
    chip_copy_zipxml( cFileProtokol, dir_server() + dir_XML_TF() )
  Endif
  If !Empty( aerr )
    AEval( aerr, {| x| StrFile( x + hb_eol(), cFileProtokol, .t. ) } )
  Endif
  viewtext( devide_into_pages( cFileProtokol, 60, 80 ), , , , .t., , , 2 )
  Delete File ( cFileProtokol )
  If go_to_answer // если
    Keyboard Chr( K_ESC ) + Chr( K_LEFT ) + Chr( K_ENTER ) + Chr( K_HOME ) + Replicate( Chr( K_TAB ), 4 ) + Chr( K_ENTER )
  Elseif go_to_otkrep // если
    Keyboard Chr( K_ESC ) + Chr( K_LEFT ) + Chr( K_ENTER ) + Chr( K_HOME ) + Replicate( Chr( K_TAB ), 5 ) + Chr( K_ENTER )
  Endif

  Return Nil


#define CSV_A_NREC   1
#define CSV_A_ENP    2
#define CSV_A_CERR   3

// 30.03.23 чтение и анализ CSV-файла ответа на новый файл прикрепления
Function read_csv_file_prik_flk_ans( cFile, aerr, nTypeFile, nkod_reestr, nkod_file )

  Local i, j, k, jp := 0, je := 0, s, arr_csv, buf := save_maxrow()

  mywait()
  If nTypeFile == _CSV_FILE_PRIKFLK
    StrFile( Space( 10 ) + 'Журнал форматно-логического контроля для файла прикрепления' + ;
      hb_eol() + hb_eol(), cFileProtokol, .t. )
  Else
    StrFile( Space( 10 ) + 'Протокол обработки для файла прикрепления' + ;
      hb_eol() + hb_eol(), cFileProtokol, .t. )
  Endif
  use_base( 'kartotek' )
  // список карточек в реестрах на прикрепление
  g_use( dir_server() + 'mo_krtp', , 'KRTP' )
  Index On Str( rees_zap, 6 ) to ( cur_dir() + 'tmp_krtp' ) For reestr == nkod_reestr
  // список ошибок в реестрах на прикрепление
  g_use( dir_server() + 'mo_krte', , 'KRTE' )
  Index On Str( reestr, 6 ) + Str( REES_ZAP, 6 ) + Str( REFREASON, 3 ) to ( cur_dir() + 'tmp_krte' )
  // Реестр сведений о прикреплении
  g_use( dir_server() + 'mo_krtr', , 'KRTR' )
  Goto ( nkod_reestr )
  // Список отосланных и принятых CSV-файлов
  g_use( dir_server() + 'mo_krtf', , 'KRTF' )
  If nkod_file == NIL
    Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_krtf' )
  Endif
  arr_csv := read_csv_to_array( cFile )
  k := Len( arr_csv )
  If k == 1 .and. AllTrim( arr_csv[ 1, 1 ] ) == 'N'
    arr_csv := {} // т.е. нет ошибок
    StrFile( hb_eol() + Space( 10 ) + 'Ошибок не обнаружено.' + ;
      hb_eol(), cFileProtokol, .t. )
    k := 0
    jp := krtr->KOL
  Else
    For i := 1 To k
      arr_csv[ i, CSV_A_NREC ] := Int( Val( arr_csv[ i, CSV_A_NREC ] ) )
      Select KRTP
      find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
      If !Found()
        AAdd( aerr, 'Не найден пациент с номером записи ' + lstr( arr_csv[ i, CSV_A_NREC ] ) )
      Endif
      // сбор ошибок в массив
      s := arr_csv[ i, CSV_A_CERR ]
      arr_csv[ i, CSV_A_CERR ] := {}
      If !Empty( s )
        For j := 1 To NumToken( s, ',', 1 )
          AAdd( arr_csv[ i, CSV_A_CERR ], Int( Val( AllTrim( Token( s, ',', j, 1 ) ) ) ) )
        Next
      Endif
      If !Empty( aerr )
        Exit
      Endif
    Next
  Endif
  If Empty( aerr )
    Select KRTF
    If nkod_file == NIL
      addrec( 6 )
      krtf->KOD   := RecNo()
      krtf->FNAME := cReadFile
      krtf->DFILE := krtr->DFILE
      krtf->TFILE := hour_min( Seconds() )
      krtf->TIP_IN := nTypeFile
      krtf->TIP_OUT := 0
      krtf->DREAD := sys_date
      krtf->TREAD := hour_min( Seconds() )
      krtf->KOL := Len( arr_csv )
      krtf->REESTR := nkod_reestr
      krtf->MO_PR := ''
    Else
      Goto ( nkod_file )
      g_rlock( forever )
    Endif
    krtf->DWORK := sys_date
    krtf->TWORK1 := cTimeBegin
    For i := 1 To k
      Select KRTP
      find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
      g_rlock( forever )
      If Empty( arr_csv[ i, CSV_A_CERR ] )
        If nTypeFile == _CSV_FILE_PRIKFLK
          ++jp
          krtp->OPLATA := 1
          krtp->D_PRIK1 := krtp->D_PRIK
        Endif
      Else
        ++je
        krtp->OPLATA := 2
        krtp->D_PRIK1 := CToD( '' )
      Endif
      dbUnlock()
      If Len( arr_csv[ i, CSV_A_CERR ] ) > 0
        Select KART
        Goto ( krtp->KOD_K )
        s := lstr( arr_csv[ i, CSV_A_NREC ] ) + '. ' + AllTrim( kart->fio ) + ' - ошибка'
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        For j := 1 To Len( arr_csv[ i, CSV_A_CERR ] )
          Select KRTE
          find ( Str( nkod_reestr, 6 ) + Str( arr_csv[ i, CSV_A_NREC ], 6 ) + Str( arr_csv[ i, CSV_A_CERR, j ], 3 ) )
          If !Found()
            addrec( 6 )
            krte->REESTR := nkod_reestr
            krte->REES_ZAP := arr_csv[ i, CSV_A_NREC ]
            krte->KOD_K := krtp->KOD_K
            krte->REFREASON := arr_csv[ i, CSV_A_CERR, j ]
            dbUnlock()
          Endif
          StrFile( Space( Len( lstr( arr_csv[ i, CSV_A_NREC ] ) ) + 2 ) + lstr( krte->REFREASON ) + ' ' + ;
            inieditspr( A__MENUVERT, get_err_csv_prik(), krte->REFREASON ) + ;
            hb_eol(), cFileProtokol, .t. )
        Next
      Endif
    Next
    If nTypeFile == _CSV_FILE_PRIKFLK
      Select KRTR
      Goto ( nkod_reestr )
      If jp == krtr->kol
        k := krtr->kol
      Endif
      If k != krtr->kol
        Select KRTP
        Go Top
        Do While !Eof()
          If krtp->OPLATA == 0 // т.е. не было в файле ответа
            g_rlock( forever )
            ++je
            krtp->OPLATA := 2
            krtp->D_PRIK1 := CToD( '' )
            dbUnlock()
            Select KART
            Goto ( krtp->KOD_K )
            s := lstr( krtp->REES_ZAP ) + '. ' + AllTrim( kart->fio ) + ' - ошибка'
            StrFile( s + hb_eol(), cFileProtokol, .t. )
            Select KRTE
            find ( Str( nkod_reestr, 6 ) + Str( krtp->REES_ZAP, 6 ) + Str( 99, 3 ) )
            If !Found()
              addrec( 6 )
              krte->REESTR := nkod_reestr
              krte->REES_ZAP := krtp->REES_ZAP
              krte->KOD_K := krtp->KOD_K
              krte->REFREASON := 99
              dbUnlock()
            Endif
            StrFile( Space( Len( lstr( krtp->REES_ZAP ) ) + 2 ) + lstr( krte->REFREASON ) + ' ' + ;
              inieditspr( A__MENUVERT, get_err_csv_prik(), krte->REFREASON ) + ;
              hb_eol(), cFileProtokol, .t. )
          Endif
          Select KRTP
          Skip
        Enddo
      Endif
    Endif
    Select KRTR
    Goto ( nkod_reestr )
    g_rlock( forever )
    krtr->ANSWER := 1  // 1-был прочитан ответ
    If nTypeFile == _CSV_FILE_PRIKFLK
      krtr->KOL_P := jp
    Endif
    //
    krtf->TWORK2 := hour_min( Seconds() )
    dbUnlockAll()
    Commit
  Endif
  rest_box( buf )

  Return Nil

#define CSV_A_NREC   1
#define CSV_A_PID    2
#define CSV_A_ENP    3
#define CSV_A_MO     4
#define CSV_A_DT     5
#define CSV_A_D_PRIK 6
#define CSV_A_STATUS 7
#define CSV_A_CERR   8

// 30.03.23 чтение в память и анализ CSV-файла ответа на файл прикрепления
Function read_csv_file_answer( cFile, aerr, nkod_reestr )

  Local i, j, s, arr_csv, kol1 := 0, mmo_pr, md_prik, ar[ 2 ], fl_et, buf := save_maxrow()

  stat_msg( 'Чтение файла ' + Upper( strippath( cFile ) ) )
  fp := FCreate( cFileProtokol )
  tek_stroke := 0
  n_list := 1
  add_string( Space( 10 ) + 'Протокол обработки файла ' + Upper( strippath( cFile ) ) )
  add_string( Space( 10 ) + full_date( sys_date ) + 'г. ' + cTimeBegin )
  add_string( Space( 10 ) + 'Протокол обработки для файла прикрепления' )
  add_string( '' )
  use_base( 'kartotek' )
  // список прикреплений по пациенту во времени
  g_use( dir_server() + 'mo_kartp', dir_server() + 'mo_kartp', 'KARTP' )
  // список карточек в реестрах на прикрепление
  g_use( dir_server() + 'mo_krtp', , 'KRTP' )
  Index On Str( rees_zap, 6 ) to ( cur_dir() + 'tmp_krtp' ) For reestr == nkod_reestr
  // список ошибок в реестрах на прикрепление
  g_use( dir_server() + 'mo_krte', , 'KRTE' )
  Index On Str( reestr, 6 ) + Str( rees_zap, 6 ) + Str( REFREASON, 3 ) to ( cur_dir() + 'tmp_krte' )
  // открыть собственный сегмент застрахованных
  g_use( dir_server() + 'kart_et' )
  Index On Str( kod_tf, 10 ) to ( cur_dir() + 'tmp_kart_et' )
  g_use( dir_server() + 'kart_etk' )
  Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp_kart_etk' )
  // Реестр сведений о прикреплении
  g_use( dir_server() + 'mo_krtr', , 'KRTR' )
  Goto ( nkod_reestr )
  // Список отосланных и принятых CSV-файлов
  g_use( dir_server() + 'mo_krtf', , 'KRTF' )
  Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_krtf' )
  arr_csv := read_csv_to_array( cFile )
  k := Len( arr_csv )
  If k != krtr->kol
    FClose( fp )
    AAdd( aerr, 'В файле запроса ' + lstr( krtr->kol ) + ' пациентов, а в файле ответа ' + lstr( k ) + '. Ошибка!' )
    Return Nil
  Endif
  For i := 1 To k
    arr_csv[ i, CSV_A_NREC ]   := Int( Val( arr_csv[ i, CSV_A_NREC ] ) )
    arr_csv[ i, CSV_A_PID ]    := Int( Val( arr_csv[ i, CSV_A_PID ] ) )
    arr_csv[ i, CSV_A_DT ]     := SToD( arr_csv[ i, CSV_A_DT ] )
    arr_csv[ i, CSV_A_D_PRIK ] := SToD( arr_csv[ i, CSV_A_D_PRIK ] )
    arr_csv[ i, CSV_A_STATUS ] := Int( Val( arr_csv[ i, CSV_A_STATUS ] ) )
    Select KRTP
    find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
    If Found()
      Select KART
      Goto ( krtp->KOD_K )
      If !eq_any( arr_csv[ i, CSV_A_STATUS ], 1, 2 )
        AAdd( aerr, 'У пациента с номером записи ' + lstr( arr_csv[ i, CSV_A_NREC ] ) + ' не тот статус операции = ' + lstr( arr_csv[ i, CSV_A_STATUS ] ) )
      Elseif arr_csv[ i, CSV_A_STATUS ] == 1 .and. Empty( arr_csv[ i, CSV_A_D_PRIK ] )
        AAdd( aerr, 'У пациента с номером записи ' + lstr( arr_csv[ i, CSV_A_NREC ] ) + ' статус операции = 1 и нет даты прикрепления' )
      Endif
    Else
      AAdd( aerr, 'Не найден пациент с номером записи ' + lstr( arr_csv[ i, CSV_A_NREC ] ) )
    Endif
    // сбор ошибок в массив
    s := arr_csv[ i, CSV_A_CERR ]
    arr_csv[ i, CSV_A_CERR ] := {}
    If !Empty( s )
      For j := 1 To NumToken( s, ',', 1 )
        AAdd( arr_csv[ i, CSV_A_CERR ], Int( Val( AllTrim( Token( s, ',', j, 1 ) ) ) ) )
      Next
    Endif
  Next
  If Empty( aerr )
    Select KRTF
    addrec( 6 )
    krtf->KOD   := RecNo()
    krtf->FNAME := cReadFile
    krtf->DFILE := krtr->DFILE
    krtf->TFILE := hour_min( Seconds() )
    krtf->TIP_IN := _CSV_FILE_ANSWER
    krtf->TIP_OUT := 0
    krtf->DREAD := sys_date
    krtf->TREAD := hour_min( Seconds() )
    krtf->DWORK := sys_date
    krtf->TWORK1 := cTimeBegin
    krtf->KOL := k
    krtf->REESTR := nkod_reestr
    krtf->MO_PR := ''
    For i := 1 To k
      @ MaxRow(), 0 Say Str( i / k * 100, 6, 2 ) + '%' Color cColorSt2Msg
      Select KRTP
      find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
      g_rlock( forever )
      krtp->OPLATA := arr_csv[ i, CSV_A_STATUS ]
      krtp->D_PRIK1 := iif( arr_csv[ i, CSV_A_STATUS ] == 1, arr_csv[ i, CSV_A_D_PRIK ], CToD( '' ) )
      dbUnlock()
      Select KART
      Goto ( krtp->KOD_K )
      s := lstr( arr_csv[ i, CSV_A_NREC ] ) + '. ' + AllTrim( kart->fio ) + ' (д.р.' + full_date( kart->date_r ) + ') '
      s_death := '0'
      n_del := 0
      fl_et := .f.
      If krtp->OPLATA == 1
        If Empty( arr_csv[ i, CSV_A_PID ] )
          s += 'не прикрепл' + iif( kart->pol == 'М', 'ён', 'ена' ) + hb_eol() + ;
            Space( Len( lstr( i ) ) + 2 ) + '(проверьте реквизиты пациента / отправьте ХОДАТАЙСТВО в ТФОМС)'
          add_string( s )
        Else
          s += 'ПРИКРЕПЛ' + iif( kart->pol == 'М', 'ЁН', 'ЕНА' ) + ' с ' + date_8( arr_csv[ i, CSV_A_D_PRIK ] )
          add_string( s )
          ++kol1
          // если прикреплён к нам - запоминаем
          Select KARTP
          find ( Str( krtp->KOD_K, 7 ) + DToS( arr_csv[ i, CSV_A_D_PRIK ] ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 7 )
            kartp->KOD_K := krtp->KOD_K
            kartp->D_PRIK := arr_csv[ i, CSV_A_D_PRIK ]
          Endif
          kartp->MO_PR := glob_mo()[ _MO_KOD_TFOMS ]
          kartp->DFILE := krtr->DFILE
          kartp->SNILS_VR := krtp->SNILS_VR
          fl_et := f_put_et_etk( arr_csv[ i, CSV_A_PID ], arr_csv[ i, CSV_A_ENP ], ;
            arr_csv[ i, CSV_A_D_PRIK ], krtp->UCHAST, ;
            glob_mo()[ _MO_KOD_TFOMS ], krtp->SNILS_VR, kart->kod, 2 )
        Endif
      Else
        If !emptyany( arr_csv[ i, CSV_A_MO ], arr_csv[ i, CSV_A_DT ] )
          // если прислано прикрепление (м.б.не наше) - запоминаем
          Select KARTP
          find ( Str( krtp->KOD_K, 7 ) + DToS( arr_csv[ i, CSV_A_DT ] ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 7 )
            kartp->KOD_K := krtp->KOD_K
            kartp->D_PRIK := arr_csv[ i, CSV_A_DT ]
          Endif
          kartp->MO_PR := arr_csv[ i, CSV_A_MO ]
          kartp->DFILE := krtr->DFILE     // заносим дату файла
          If !( kartp->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
            kartp->SNILS_VR := ''
          Endif
          s += hb_eol() + ;
            Space( Len( lstr( i ) ) + 2 ) + '(уже прикрепл' + iif( kart->pol == 'М', 'ён', 'ена' ) + ;
            ' с ' + date_8( arr_csv[ i, CSV_A_DT ] ) + ;
            ' к ' + ret_mo( arr_csv[ i, CSV_A_MO ] )[ _MO_SHORT_NAME ] + ')'
          fl_et := f_put_et_etk( arr_csv[ i, CSV_A_PID ], arr_csv[ i, CSV_A_ENP ], ;
            arr_csv[ i, CSV_A_DT ], 0, ;
            arr_csv[ i, CSV_A_MO ], '', kart->kod, 0 )
        Else
          s += 'не прикрепл' + iif( kart->pol == 'М', 'ён', 'ена' )
          // в этом случае в kart_et(k) не удаляем/не изменяем ничего
        Endif
        add_string( s )
        For j := 1 To Len( arr_csv[ i, CSV_A_CERR ] )
          Select KRTE
          find ( Str( nkod_reestr, 6 ) + Str( arr_csv[ i, CSV_A_NREC ], 6 ) + Str( arr_csv[ i, CSV_A_CERR, j ], 3 ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 6 )
            krte->REESTR := nkod_reestr
            krte->REES_ZAP := arr_csv[ i, CSV_A_NREC ]
            krte->REFREASON := arr_csv[ i, CSV_A_CERR, j ]
          Endif
          krte->KOD_K := krtp->KOD_K
          dbUnlock()
          s := lstr( krte->REFREASON ) + ' ' + RTrim( inieditspr( A__MENUVERT, get_err_csv_prik(), krte->REFREASON ) )
          If krte->REFREASON == 525
            s += ' (' + AllTrim( arr_csv[ i, CSV_A_ENP ] ) + ')'
          Elseif krte->REFREASON == 704 // Дата прикрепления больше даты смерти
            s_death := '1' // Застрахованный умер до отправки файла MO2...
          Elseif eq_any( krte->REFREASON, 404, 703 )
            n_del := 1
          Endif
          n := Len( lstr( i ) ) + 2
          For j1 := 1 To perenos( ar, s, 80 - n )
            add_string( Space( n ) + ar[ j1 ] )
          Next
        Next
        If fl_et // если найден или добавлен в 'kart_et'
          kart_et->PC2 := s_death
        Endif
      Endif
      f_put_date_prik( krtp->KOD_K, arr_csv[ i, CSV_A_PID ], arr_csv[ i, CSV_A_ENP ], 3, s_death, n_del )
      If i % 2000 == 0
        dbUnlockAll()
        Commit
      Endif
    Next
    dbUnlockAll()
    Commit
    Select KRTR
    Goto ( nkod_reestr )
    g_rlock( forever )
    krtr->KOL_P := kol1
    krtr->ANSWER := 1  // 0-не было ответа, 1-был прочитан ответ
    //
    Select KRTF
    g_rlock( forever )
    krtf->TWORK2 := hour_min( Seconds() )
    dbUnlockAll()
    Commit
  Endif
  FClose( fp )
  rest_box( buf )

  Return Nil

#define CSV_O_PID    1
#define CSV_O_ENP    2
#define CSV_O_MO1    3
#define CSV_O_DT1    4
#define CSV_O_TIPP   5
#define CSV_O_SNP    6
#define CSV_O_ENP_   7
#define CSV_O_FAM    8
#define CSV_O_IM     9
#define CSV_O_OT    10
#define CSV_O_DR    11
#define CSV_O_MR    12
#define CSV_O_TIPD  13
#define CSV_O_SND   14
#define CSV_O_DVD   15
#define CSV_O_OVD   16
#define CSV_O_SNILS 17
#define CSV_O_MO    18
#define CSV_O_SPR   19
#define CSV_O_TPR   20
#define CSV_O_DPR   21

// 29.03.23 чтение в память и анализ CSV-файла открепления
Function read_csv_file_otkrep( cFile, aerr )

  Local i, j, s, arr_csv, kol1 := 0, md_prik, mmo1, mmo2, buf := save_maxrow()

  mmo1 := SubStr( cReadFile, 3, 6 )  // предыдущее МО прикрепления
  mywait()
  StrFile( Space( 10 ) + 'Протокол обработки для файла открепления' + ;
    hb_eol() + hb_eol(), cFileProtokol, .t. )
  use_base( 'kartotek' )
  // список прикреплений по пациенту во времени
  g_use( dir_server() + 'mo_kartp', dir_server() + 'mo_kartp', 'KARTP' )
  // список карточек в реестрах на открепление
  g_use( dir_server() + 'mo_krto', , 'KRTO' )
  Index On Str( kod_krtf, 6 ) to ( cur_dir() + 'tmp_krto' )
  // открыть собственный сегмент застрахованных
  g_use( dir_server() + 'kart_et' )
  Index On Str( kod_tf, 10 ) to ( cur_dir() + 'tmp_kart_et' )
  g_use( dir_server() + 'kart_etk' )
  Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp_kart_etk' )
  // Список отосланных и принятых CSV-файлов
  g_use( dir_server() + 'mo_krtf', , 'KRTF' )
  Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_krtf' )
  arr_csv := read_csv_to_array( cFile )

  For i := 1 To Len( arr_csv )
    arr_csv[ i, CSV_O_PID ] := Int( Val( arr_csv[ i, CSV_O_PID ] ) )
    arr_csv[ i, CSV_O_TIPD ] := Int( Val( arr_csv[ i, CSV_O_TIPD ] ) )
    If Empty( arr_csv[ i, CSV_O_MO1 ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введено предыдущее МО прикрепления' )
    Elseif !( arr_csv[ i, CSV_O_MO1 ] == mmo1 )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' неверное предыдущее МО прикрепления=' + arr_csv[ i, CSV_O_MO1 ] )
    Endif
    arr_csv[ i, CSV_O_DT1 ] := SToD( arr_csv[ i, CSV_O_DT1 ] )
    If Empty( arr_csv[ i, CSV_O_DT1 ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введена дата открепления от пред.МО' )
    Endif
    If Empty( arr_csv[ i, CSV_O_FAM ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введена фамилия' )
    Endif
    If Empty( arr_csv[ i, CSV_O_IM ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введено имя' )
    Endif
    arr_csv[ i, CSV_O_DR ] := SToD( arr_csv[ i, CSV_O_DR ] )
    If Empty( arr_csv[ i, CSV_O_DR ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введена дата рождения' )
    Endif
    If Empty( arr_csv[ i, CSV_O_MO ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введено МО прикрепления' )
    Else
      mmo2 := arr_csv[ i, CSV_O_MO ]
    Endif
    arr_csv[ i, CSV_O_DPR ] := SToD( arr_csv[ i, CSV_O_DPR ] )
    If Empty( arr_csv[ i, CSV_O_DPR ] )
      AAdd( aerr, 'У пациента с номером записи ' + lstr( i ) + ' не введена дата прикрепления' )
    Endif
  Next
  If Empty( aerr )
    Select KRTF
    addrec( 6 )
    krtf->KOD   := RecNo()
    krtf->FNAME := cReadFile
    krtf->DFILE := SToD( SubStr( cReadFile, 9, 8 ) )
    krtf->TFILE := hour_min( Seconds() )
    krtf->TIP_IN := _CSV_FILE_OTKREP
    krtf->TIP_OUT := 0
    krtf->DREAD := sys_date
    krtf->TREAD := hour_min( Seconds() )
    krtf->DWORK := sys_date
    krtf->TWORK1 := cTimeBegin
    krtf->REESTR := 0
    krtf->MO_PR := mmo2
    For i := 1 To Len( arr_csv )
      afio := { arr_csv[ i, CSV_O_FAM ], arr_csv[ i, CSV_O_IM ], arr_csv[ i, CSV_O_OT ] }
      mfio := AllTrim( afio[ 1 ] ) + ' ' + AllTrim( afio[ 2 ] ) + ' ' + AllTrim( afio[ 3 ] )
      lkod_k := 0
      mfio := PadR( mfio, 50 )
      Select KART
      Set Order To 2
      s := Upper( Left( mfio, 20 ) )
      find ( '1' + s )
      Do While s == Upper( Left( kart->fio, 20 ) ) .and. !Eof()
        If Upper( Left( mfio, 50 ) ) == Upper( Left( kart->fio, 50 ) ) .and. arr_csv[ i, CSV_O_DR ] == kart->DATE_R
          lkod_k := kart->kod
          Exit
        Endif
        Skip
      Enddo
      Select KRTO
      addrec( 6 )
      krto->kod_krtf := krtf->KOD // код по файлу 'mo_krtf'
      krto->kod_tf := arr_csv[ i, CSV_O_PID ] // код по кодировке ТФОМС (PID)
      krto->KOD_K := lkod_k // код пациента по файлу 'kartotek', если найден
      krto->MO_PR  := arr_csv[ i, CSV_O_MO ]  // код МО прикрепления
      krto->D_PRIK := arr_csv[ i, CSV_O_DPR ] // дата прикрепления
      krto->FILE_ZAP := i  // номер строки в файле
      s := lstr( i ) + '. ' + AllTrim( mfio ) + ;
        ' (д.р.' + full_date( arr_csv[ i, CSV_O_DR ] ) + ') ' + date_8( arr_csv[ i, CSV_O_DT1 ] ) + ' откреплён от Вашего МО'
      StrFile( s + hb_eol(), cFileProtokol, .t. )
      s := Space( Len( lstr( i ) ) + 2 ) + 'и прикреплён ' + date_8( arr_csv[ i, CSV_O_DPR ] ) + ' к: ' + ret_mo( arr_csv[ i, CSV_O_MO ] )[ _MO_SHORT_NAME ]
      StrFile( s + hb_eol(), cFileProtokol, .t. )
      If lkod_k > 0 // нашли в картотеке
        // старое прикрепление даже не проверяем
        If ValType( arr_csv[ i, CSV_O_DPR ] ) == 'D'
          // занесём новое прикрепление
          Select KARTP
          find ( Str( lKOD_K, 7 ) + DToS( arr_csv[ i, CSV_O_DPR ] ) )
          If Found()
            g_rlock( forever )
          Else
            addrec( 7 )
            kartp->KOD_K := lKOD_K
            kartp->D_PRIK := arr_csv[ i, CSV_O_DPR ]
          Endif
          kartp->MO_PR := arr_csv[ i, CSV_O_MO ]
          kartp->DFILE := krtf->DFILE
          If !( kartp->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] )
            kartp->SNILS_VR := ''
          Endif
          dbUnlock()
        Endif
        Select kart_et
        find ( Str( arr_csv[ i, CSV_O_PID ], 10 ) )
        If Found()
          g_rlock( forever )
          kart_et->kod_mis := arr_csv[ i, CSV_O_ENP ]
          kart_et->DATE_PR := arr_csv[ i, CSV_O_DPR ]
          kart_et->MO_PR   := arr_csv[ i, CSV_O_MO ] // не к нам
          dbUnlock()
        Endif
        Select kart_etk
        find ( Str( lkod_k, 7 ) )
        If Found()
          g_rlock( forever )
          kart_etk->kod_tf := arr_csv[ i, CSV_O_PID ] // перезаписать PID
          kart_etk->PRIOR := 0
          dbUnlock()
        Endif
        f_put_date_prik( lKOD_K, arr_csv[ i, CSV_O_PID ], arr_csv[ i, CSV_O_ENP ], 4 )
      Else
        j := Len( lstr( i ) ) + 2
        s := Space( j ) + '!!! данный пациент не найден в нашей картотеке по ключу ФИО+дата рождения'
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        s := Space( j ) + 'PID: ' + lstr( arr_csv[ i, CSV_O_PID ] )
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        s := Space( j ) + 'ЕНП: ' + arr_csv[ i, CSV_O_ENP ]
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        s := Space( j ) + 'Полис: ' + iif( Empty( arr_csv[ i, CSV_O_SNP ] ), arr_csv[ i, CSV_O_ENP_ ], arr_csv[ i, CSV_O_SNP ] )
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        s := Space( j ) + 'Место рождения: ' + arr_csv[ i, CSV_O_MR ]
        StrFile( s + hb_eol(), cFileProtokol, .t. )
        s := Space( j ) + inieditspr( A__MENUVERT, getvidud(),  arr_csv[ i, CSV_O_TIPD ] ) + ' ' + arr_csv[ i, CSV_O_SND ]
        StrFile( s + hb_eol(), cFileProtokol, .t. )
      Endif
    Next
    //
    krtf->KOL := Len( arr_csv )
    krtf->TWORK2 := hour_min( Seconds() )
    dbUnlockAll()
  Endif
  rest_box( buf )

  Return Nil

#define CSV_A_NREC   1
#define CSV_A_PID    2
#define CSV_A_ENP    3
#define CSV_A_MO     4
#define CSV_A_PODR   5
#define CSV_A_UCH    6
#define CSV_A_VRACH  7
#define CSV_A_DT     8
#define CSV_A_DT_MO  9
#define CSV_A_CERR  10

// 30.03.23 чтение в память и анализ CSV-файла ответа на запрос для сверки
Function read_csv_file_sverkao( cFile, aerr, nkod_reestr )

  Local i, j, k1, k, s, arr_csv, te := {}, kol1 := 0, kol2 := 0, kol3 := kol4 := 0, ;
    fl_et, au := {}, mmo_pr, md_prik, buf := save_maxrow()

  stat_msg( 'Предварительная обработка' )
  StrFile( Space( 10 ) + 'Протокол обработки для файла ответа на запрос по сверке' + ;
    hb_eol() + hb_eol(), cFileProtokol, .t. )
  use_base( 'kartotek' )
  // список прикреплений по пациенту во времени
  g_use( dir_server() + 'mo_kartp', dir_server() + 'mo_kartp', 'KARTP' )
  // список карточек в реестрах на прикрепление
  g_use( dir_server() + 'mo_krtp', , 'KRTP' )
  Index On Str( rees_zap, 6 ) to ( cur_dir() + 'tmp_krtp' ) For reestr == nkod_reestr
  // список ошибок в реестрах на прикрепление
  g_use( dir_server() + 'mo_krte', , 'KRTE' )
  Index On Str( reestr, 6 ) + Str( rees_zap, 6 ) + Str( REFREASON, 3 ) to ( cur_dir() + 'tmp_krte' )
  // открыть собственный сегмент застрахованных
  g_use( dir_server() + 'kart_et' )
  Index On Str( kod_tf, 10 ) to ( cur_dir() + 'tmp_kart_et' )
  g_use( dir_server() + 'kart_etk' )
  Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp_kart_etk' )
  // Реестр сведений о прикреплении
  g_use( dir_server() + 'mo_krtr', , 'KRTR' )
  Goto ( nkod_reestr )
  // Список отосланных и принятых CSV-файлов
  g_use( dir_server() + 'mo_krtf', , 'KRTF' )
  Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_krtf' )
  arr_csv := read_csv_to_array( cFile )
  k := Len( arr_csv )
  If k != krtr->kol
    AAdd( aerr, 'В файле запроса ' + lstr( krtr->kol ) + ' пациентов, а в файле ответа ' + lstr( k ) + '. Ошибка!' )
    Return Nil
  Endif
  For i := 1 To k
    @ MaxRow(), 0 Say Str( i / k * 100, 6, 2 ) + '%' Color cColorSt2Msg
    arr_csv[ i, CSV_A_NREC ]  := Int( Val( arr_csv[ i, CSV_A_NREC ] ) )
    arr_csv[ i, CSV_A_PID ]   := Int( Val( arr_csv[ i, CSV_A_PID ] ) )
    arr_csv[ i, CSV_A_UCH ]   := Int( Val( arr_csv[ i, CSV_A_UCH ] ) )
    arr_csv[ i, CSV_A_DT ]    := SToD( arr_csv[ i, CSV_A_DT ] )
    arr_csv[ i, CSV_A_DT_MO ] := SToD( arr_csv[ i, CSV_A_DT_MO ] )
    Select KRTP
    find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
    If !Found()
      AAdd( aerr, 'Не найден пациент с номером записи ' + lstr( arr_csv[ i, CSV_A_NREC ] ) )
    Endif
    // сбор ошибок в массив
    s := arr_csv[ i, CSV_A_CERR ]
    arr_csv[ i, CSV_A_CERR ] := {}
    If !Empty( s )
      For j := 1 To NumToken( s, ',', 1 )
        AAdd( arr_csv[ i, CSV_A_CERR ], Int( Val( AllTrim( Token( s, ',', j, 1 ) ) ) ) )
      Next
    Endif
  Next
  kol_death := 0
  If Empty( aerr )
    stat_msg( 'Запись в базу данных' )
    Select KRTF
    addrec( 6 )
    krtf->KOD   := RecNo()
    krtf->FNAME := cReadFile
    krtf->DFILE := krtr->DFILE
    krtf->TFILE := hour_min( Seconds() )
    krtf->TIP_IN := _CSV_FILE_SVERKAO
    krtf->TIP_OUT := 0
    krtf->DREAD := sys_date
    krtf->TREAD := hour_min( Seconds() )
    krtf->DWORK := sys_date
    krtf->TWORK1 := cTimeBegin
    krtf->KOL := k
    krtf->REESTR := nkod_reestr
    krtf->MO_PR := ''
    For i := 1 To k
      @ MaxRow(), 0 Say Str( i / k * 100, 6, 2 ) + '%' Color cColorSt2Msg
      mstatus := 2
      If !emptyany( arr_csv[ i, CSV_A_MO ], arr_csv[ i, CSV_A_DT ] )
        If arr_csv[ i, CSV_A_MO ] == glob_mo()[ _MO_KOD_TFOMS ]
          mstatus := 1
        Else
          mstatus := 3
          If ( j := AScan( au, {| x| x[ 1 ] == arr_csv[ i, CSV_A_MO ] } ) ) == 0
            AAdd( au, { arr_csv[ i, CSV_A_MO ], 0 } )
            j := Len( au )
          Endif
          au[ j, 2 ] ++
        Endif
      Endif
      Select KRTP
      find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
      g_rlock( forever )
      krtp->OPLATA := mstatus
      if arr_csv[ i, CSV_A_UCH ] <= 99
        krtp->UCHAST   := arr_csv[ i, CSV_A_UCH ] // номер участка
      else
        krtp->UCHAST  := 0
        arr_csv[ i, CSV_A_UCH ] := 0
      endif  
      krtp->SNILS_VR := arr_csv[ i, CSV_A_VRACH ] // СНИЛС участкового врача
      krtp->KOD_PODR := arr_csv[ i, CSV_A_PODR ] // код подразделения по паспорту ЛПУ
      krtp->D_PRIK1 := iif( eq_any( mstatus, 1, 3 ), arr_csv[ i, CSV_A_DT ], CToD( '' ) )
      Select KART
      Goto ( krtp->KOD_K )
      s := lstr( arr_csv[ i, CSV_A_NREC ] ) + '. ' + AllTrim( kart->fio ) + ;
        ' (д.р.' + full_date( kart->date_r ) + ') '
      fl_et := .f.
      If mstatus == 2  // не прикреплён ни к кому
        ++kol2
        If Empty( Len( arr_csv[ i, CSV_A_CERR ] ) )
          AAdd( arr_csv[ i, CSV_A_CERR ], -99 )
        Endif
        If !Empty( arr_csv[ i, CSV_A_PID ] ) // всё-таки найден в регистре застрахованных
          Select kart_et
          find ( Str( arr_csv[ i, CSV_A_PID ], 10 ) )
          If Found()
            g_rlock( forever )
            kart_et->kod_mis := arr_csv[ i, CSV_A_ENP ]
            kart_et->MO_PR   := '' // не прикреплён ни к кому
            fl_et := .t.
          Endif
          Select kart_etk
          find ( Str( kart->kod, 7 ) )
          If Found()
            deleterec( .t. ) // если ни к кому не прикреплён, - удалить совсем
          Endif
        Endif
      Else // !emptyany(arr_csv[i, CSV_A_MO], arr_csv[i, CSV_A_DT])
        If mstatus == 1 // прикреплен к нам



          fl_et := f_put_et_etk( arr_csv[ i, CSV_A_PID ], arr_csv[ i, CSV_A_ENP ], ;
            arr_csv[ i, CSV_A_DT ], arr_csv[ i, CSV_A_UCH ], ;
            glob_mo()[ _MO_KOD_TFOMS ], arr_csv[ i, CSV_A_VRACH ], ;
            kart->kod, 1 )
        Elseif arr_csv[ i, CSV_A_PID ] > 0  // прикреплён не к нам
          Select kart_et
          find ( Str( arr_csv[ i, CSV_A_PID ], 10 ) )
          If Found()
            g_rlock( forever )
            kart_et->kod_mis := arr_csv[ i, CSV_A_ENP ]
            kart_et->DATE_PR := arr_csv[ i, CSV_A_DT ]
            kart_et->MO_PR   := arr_csv[ i, CSV_A_MO ]
            fl_et := .t.
          Endif
          Select kart_etk
          find ( Str( kart->kod, 7 ) )
          If Found()
            g_rlock( forever )
            kart_etk->kod_tf := arr_csv[ i, CSV_A_PID ]
            kart_etk->PRIOR := 0 // приоритет = 0
          Endif
        Endif
        // занесём указанное прикрепление
        Select KARTP
        find ( Str( krtp->KOD_K, 7 ) + DToS( arr_csv[ i, CSV_A_DT ] ) )
        If Found()
          g_rlock( forever )
        Else
          addrec( 7 )
          kartp->KOD_K := krtp->KOD_K
          kartp->D_PRIK := arr_csv[ i, CSV_A_DT ]
        Endif
        kartp->DFILE := krtr->DFILE
        kartp->MO_PR := arr_csv[ i, CSV_A_MO ]
        If kartp->MO_PR == glob_mo()[ _MO_KOD_TFOMS ]
          kartp->SNILS_VR := krtp->SNILS_VR
        Else
          kartp->SNILS_VR := ''
        Endif
        If krtp->OPLATA == 1
          ++kol1
        Else
          ++kol3
        Endif
      Endif
      s_death := '0'
      n_del := 0
      For j := 1 To Len( arr_csv[ i, CSV_A_CERR ] )
        Select KRTE
        find ( Str( nkod_reestr, 6 ) + Str( arr_csv[ i, CSV_A_NREC ], 6 ) + Str( arr_csv[ i, CSV_A_CERR, j ], 3 ) )
        If Found()
          g_rlock( forever )
        Else
          addrec( 6 )
          krte->REESTR := nkod_reestr
          krte->REES_ZAP := arr_csv[ i, CSV_A_NREC ]
          krte->REFREASON := arr_csv[ i, CSV_A_CERR, j ]
        Endif
        krte->KOD_K := krtp->KOD_K
        If ( j1 := AScan( te, {| x| x[ 1 ] == krte->REFREASON } ) ) == 0
          AAdd( te, { krte->REFREASON, 0 } )
          j1 := Len( te )
        Endif
        te[ j1, 2 ] ++
        If krte->REFREASON == 706
          s_death := '1' // Застрахованный умер
        Endif
        If eq_any( krte->REFREASON, 706, 708, 709, 802, 803 )
          n_del := 1
        Endif
      Next
      If fl_et // если найден или добавлен в 'kart_et'
        kart_et->PC2 := s_death
      Endif
      kol4 := f_put_date_prik( krtp->KOD_K, ;
        arr_csv[ i, CSV_A_PID ], ;
        arr_csv[ i, CSV_A_ENP ], ;
        5, ;
        s_death, ;
        n_del, ;
        arr_csv[ i, CSV_A_MO ], arr_csv[ i, CSV_A_DT_MO ] )
      If i % 2000 == 0
        dbUnlockAll()
        Commit
      Endif
    Next
    dbUnlockAll()
    Commit
    Select KRTR
    Goto ( nkod_reestr )
    g_rlock( forever )
    krtr->KOL_P := kol1
    krtr->ANSWER := 1  // 0-не было ответа, 1-был прочитан ответ
    //
    Select KRTF
    g_rlock( forever )
    krtf->TWORK2 := hour_min( Seconds() )
    dbUnlockAll()
    Commit
    StrFile( hb_eol() + ;
      'Обработано всего       : ' + lstr( k ) + hb_eol(), cFileProtokol, .t. )
    StrFile( 'Прикреплено к нашей  МО: ' + lstr( kol1 ) + hb_eol(), cFileProtokol, .t. )
    // strfile('---прикреплено к нашей  МО: ' + lstr(kol4) + hb_eol(), cFileProtokol, .t.)
    StrFile( 'Прикреплено к другим МО: ' + lstr( kol3 ) + hb_eol(), cFileProtokol, .t. )
    ASort( au, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    For j := 1 To Len( au )
      StrFile( PadL( iif( j == 1, 'в т.ч.', '' ), 15 ) + Str( au[ j, 2 ], 6 ) + ' - ' + ret_mo( au[ j, 1 ] )[ _MO_SHORT_NAME ] + hb_eol(), cFileProtokol, .t. )
    Next
    ASort( te, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    StrFile( 'Список ошибок:' + hb_eol(), cFileProtokol, .t. )
    Private mm_err := { { 'Не имеет текущего страхования', 708 }, ; // !!!
    { 'ТФОМС не вернул никакой информации', -99 } } // !!!
    For j1 := 1 To Len( te )
      If AScan( mm_err, {| x| x[ 2 ] == te[ j1, 1 ] } ) > 0
        s := inieditspr( A__MENUVERT, mm_err, te[ j1, 1 ] )
      Else
        s := inieditspr( A__MENUVERT, get_err_csv_prik(), te[ j1, 1 ] )
      Endif
      StrFile( Str( te[ j1, 2 ], 6 ) + ' чел. - ' + Str( te[ j1, 1 ], 3 ) + ' ' + s + hb_eol(), cFileProtokol, .t. )
    Next
  Endif
  rest_box( buf )

Return Nil

#define CSV_A_NREC     1
#define CSV_A_PID      2    // Персональный идентификатор записи о ЗЛ в базе данных ТФОМС
#define CSV_A_ENP      3    // ЕНП
#define CSV_A_MO       7    // Регистрационный код МО, к которому прикреплено ЗЛ на дату обработки сведений. 
#define CSV_A_SMO      4    // Регистрационный код СМО
#define CSV_A_SMO_B    5    // Дата начала страхования
#define CSV_A_SMO_E    6    // Дата прекращения страхования
#define CSV_A_DT_MO_OT 9    // Дата открепления МО  
#define CSV_A_DT_MO    8    // Дата прикрепления к МО
#define CSV_A_CERR     10


  
  // 12.02.26 чтение в память и анализ CSV-файла ответа на запрос для НОВОЙ сверки 
Function read_csv_file_sverkao2( cFile, aerr, nkod_reestr )

  Local i, j, k1, k, s, arr_csv, te := {}, kol1 := 0, kol2 := 0, kol3 := kol4 := 0, ;
    fl_et, au := {}, mmo_pr, md_prik, buf := save_maxrow(), old_mo := {}

  stat_msg( 'Предварительная обработка' )
  StrFile( Space( 10 ) + 'Протокол обработки для файла ответа на запрос по Прикреплению' + ;
    hb_eol() + hb_eol(), cFileProtokol, .t. )
  use_base( 'kartotek' )
  // список прикреплений по пациенту во времени
  g_use( dir_server() + 'mo_kartp', dir_server() + 'mo_kartp', 'KARTP' )
  // список карточек в реестрах на прикрепление
  g_use( dir_server() + 'mo_krtp', , 'KRTP' )
  Index On Str( rees_zap, 6 ) to ( cur_dir() + 'tmp_krtp' ) For reestr == nkod_reestr
  // список ошибок в реестрах на прикрепление
  g_use( dir_server() + 'mo_krte', , 'KRTE' )
  Index On Str( reestr, 6 ) + Str( rees_zap, 6 ) + Str( REFREASON, 3 ) to ( cur_dir() + 'tmp_krte' )
  // открыть собственный сегмент застрахованных
  g_use( dir_server() + 'kart_et' )
  Index On Str( kod_tf, 10 ) to ( cur_dir() + 'tmp_kart_et' )
  g_use( dir_server() + 'kart_etk' )
  Index On Str( kod_k, 7 ) to ( cur_dir() + 'tmp_kart_etk' )
  // Реестр сведений о прикреплении
  g_use( dir_server() + 'mo_krtr', , 'KRTR' )
  Goto ( nkod_reestr )
  // список организаций 
  r_use( dir_exe() + '_mo_mo', , '_mo_mo' )
  Index On Padr( mcod, 6 ) to ( cur_dir() + "tmp_mo" )
  // Для коррекции HUMAN
  use_base( 'HUMAN' )
  select HUMAN
  set order to 2 
  // Список отосланных и принятых CSV-файлов
  g_use( dir_server() + 'mo_krtf', , 'KRTF' )
  Index On Str( kod, 6 ) to ( cur_dir() + 'tmp_krtf' )
  arr_csv := read_csv_to_array( cFile )
  k := Len( arr_csv )
  If k != krtr->kol
    AAdd( aerr, 'В файле запроса ' + lstr( krtr->kol ) + ' пациентов, а в файле ответа ' + lstr( k ) + '. Ошибка!' )
    Return Nil
  Endif
  For i := 1 To k
    @ MaxRow(), 0 Say Str( i / k * 100, 6, 2 ) + '%' Color cColorSt2Msg
    arr_csv[ i, CSV_A_NREC ]     := Int( Val( arr_csv[ i, CSV_A_NREC ] ) )  // 1
    arr_csv[ i, CSV_A_PID ]      := Int( Val( arr_csv[ i, CSV_A_PID ] ) )   // 2
    arr_csv[ i, CSV_A_SMO_B ]    := SToD( arr_csv[ i, CSV_A_SMO_B ] )       // 5
    arr_csv[ i, CSV_A_SMO_E ]    := SToD( arr_csv[ i, CSV_A_SMO_E ] )       // 6
    arr_csv[ i, CSV_A_DT_MO_OT ] := SToD( arr_csv[ i, CSV_A_DT_MO_OT ] )    // 9
    arr_csv[ i, CSV_A_DT_MO ]    := SToD( arr_csv[ i, CSV_A_DT_MO ] )       // 8
    // надо перекодировать МО прикрепления
    aadd(old_mo, arr_csv[ i, CSV_A_MO ])
    select _MO_MO
    find( padl(arr_csv[ i, CSV_A_MO ],6))
    if found()
      arr_csv[ i, CSV_A_MO ]    :=  _mo_mo->codem        // 7
    endif  
    Select KRTP
    find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
    If !Found()
      AAdd( aerr, 'Не найден пациент с номером записи ' + lstr( arr_csv[ i, CSV_A_NREC ] ) )
    Endif
    // сбор ошибок в массив
    s := arr_csv[ i, CSV_A_CERR ]
    arr_csv[ i, CSV_A_CERR ] := {}
    If !Empty( s )
      For j := 1 To NumToken( s, ',', 1 )
        AAdd( arr_csv[ i, CSV_A_CERR ], Int( Val( AllTrim( Token( s, ',', j, 1 ) ) ) ) )
      Next
    Endif
  Next
  _mo_mo->(dbCloseArea())
  kol_death := 0
  If Empty( aerr )
    stat_msg( 'Запись в базу данных' )
    Select KRTF
    addrec( 6 )
    krtf->KOD   := RecNo()
    krtf->FNAME := cReadFile
    krtf->DFILE := krtr->DFILE
    krtf->TFILE := hour_min( Seconds() )
    krtf->TIP_IN := _CSV_FILE_SVERKAO2
    krtf->TIP_OUT := 0
    krtf->DREAD := sys_date
    krtf->TREAD := hour_min( Seconds() )
    krtf->DWORK := sys_date
    krtf->TWORK1 := cTimeBegin
    krtf->KOL := k
    krtf->REESTR := nkod_reestr
    krtf->MO_PR := ''
    For i := 1 To k
      @ MaxRow(), 0 Say Str( i / k * 100, 6, 2 ) + '%' Color cColorSt2Msg
      mstatus := 2
      If !empty( arr_csv[ i, CSV_A_MO ] )
        If arr_csv[ i, CSV_A_MO ] == glob_mo()[ _MO_KOD_TFOMS ]
          mstatus := 1
        Else
          mstatus := 3
          If ( j := AScan( au, {| x| x[ 1 ] == arr_csv[ i, CSV_A_MO ] } ) ) == 0
            AAdd( au, { arr_csv[ i, CSV_A_MO ], 0 } )
            j := Len( au )
          Endif
          au[ j, 2 ] ++
        Endif
      Endif
      Select KRTP
      find ( Str( arr_csv[ i, CSV_A_NREC ], 6 ) )
      g_rlock( forever )
      krtp->OPLATA := mstatus
      //if arr_csv[ i, CSV_A_UCH ] <= 99
      //  krtp->UCHAST   := arr_csv[ i, CSV_A_UCH ] // номер участка
      //else
      //  krtp->UCHAST  := 0
      //  arr_csv[ i, CSV_A_UCH ] := 0
      //endif  
      //krtp->SNILS_VR := arr_csv[ i, CSV_A_VRACH ] // СНИЛС участкового врача
      //krtp->KOD_PODR := arr_csv[ i, CSV_A_PODR ] // код подразделения по паспорту ЛПУ
      krtp->D_PRIK1 := iif( eq_any( mstatus, 1, 3 ), arr_csv[ i, CSV_A_DT ], CToD( '' ) )
      // добавляем СМО
      Select KART
      Goto ( krtp->KOD_K )
      // пишем СМО в картотеку 
      g_rlock( forever )    
      kart->polis := arr_csv[ i, CSV_A_ENP ]
      Select KART_
      g_rlock( forever ) 
      kart_->npolis := arr_csv[ i, CSV_A_ENP ]
      kart_->spolis := ""
      kart_->smo    := alltrim(arr_csv[ i, CSV_A_SMO ])
      kart_->vpolis := 3
      select HUMAN 
      find ( str(kart->kod,7))
      do while kart->kod == human->kod_k .and. !eof()
        if year(human->k_data) > 2025 
          select human_
          goto (human->kod)
          if human_->schet_zap < 1 .and. human_->reestr < 1 // случ не в счете и не в реестре
            g_rlock( forever ) 
            human_->npolis := arr_csv[ i, CSV_A_ENP ]
            //human_->spolis := "" - думаю не надо - устарело
            human_->smo    := alltrim(arr_csv[ i, CSV_A_SMO ])
            human_->vpolis := 3
            unlock
            select HUMAN 
            g_rlock( forever ) 
            human->mo_pr :=  alltrim(old_mo[i])
            unlock
          endif   
        endif  
        select HUMAN
        skip 
      enddo  
      select KART_
      //
      s := lstr( arr_csv[ i, CSV_A_NREC ] ) + '. ' + AllTrim( kart->fio ) + ;
        ' (д.р.' + full_date( kart->date_r ) + ') '
      fl_et := .f.
      If mstatus == 2  // не прикреплён ни к кому
        ++kol2
        If Empty( Len( arr_csv[ i, CSV_A_CERR ] ) )
          AAdd( arr_csv[ i, CSV_A_CERR ], -99 )
        Endif
        If !Empty( arr_csv[ i, CSV_A_PID ] ) // всё-таки найден в регистре застрахованных
          Select kart_et
          find ( Str( arr_csv[ i, CSV_A_PID ], 10 ) )
          If Found()
            g_rlock( forever )
            kart_et->kod_mis := arr_csv[ i, CSV_A_ENP ]
            kart_et->MO_PR   := '' // не прикреплён ни к кому
            fl_et := .t.
          Endif
          Select kart_etk
          find ( Str( kart->kod, 7 ) )
          If Found()
            deleterec( .t. ) // если ни к кому не прикреплён, - удалить совсем
          Endif
        Endif
      Else // !emptyany(arr_csv[i, CSV_A_MO], arr_csv[i, CSV_A_DT])
       // If mstatus == 1 // прикреплен к нам - ПОКА НЕ ДЕЛАЕМ
       //   fl_et := f_put_et_etk( arr_csv[ i, CSV_A_PID ], arr_csv[ i, CSV_A_ENP ], ;
       //     arr_csv[ i, CSV_A_DT_MO ], 0, ;
       //     glob_mo()[ _MO_KOD_TFOMS ], 0, ;
       //     kart->kod, 1 )
          //Else 
        if arr_csv[ i, CSV_A_PID ] > 0  // прикреплён не к нам
          Select kart_et
          find ( Str( arr_csv[ i, CSV_A_PID ], 10 ) )
          If Found()
            g_rlock( forever )
            kart_et->kod_mis := arr_csv[ i, CSV_A_ENP ]
            kart_et->DATE_PR := arr_csv[ i, CSV_A_DT_MO ]
            kart_et->MO_PR   := arr_csv[ i, CSV_A_MO ]
            fl_et := .t.
          Endif
          Select kart_etk
          find ( Str( kart->kod, 7 ) )
          If Found()
            g_rlock( forever )
            kart_etk->kod_tf := arr_csv[ i, CSV_A_PID ]
            kart_etk->PRIOR := 0 // приоритет = 0
          Endif
        Endif
        */
        // занесём указанное прикрепление
        Select KARTP
        find ( Str( krtp->KOD_K, 7 ) + DToS( arr_csv[ i, CSV_A_DT_MO ] ) )
        If Found()
          g_rlock( forever )
        Else
          addrec( 7 )
          kartp->KOD_K := krtp->KOD_K
          kartp->D_PRIK := arr_csv[ i, CSV_A_DT ]
        Endif
        kartp->DFILE := krtr->DFILE
        kartp->MO_PR := arr_csv[ i, CSV_A_MO ]
        If kartp->MO_PR == glob_mo()[ _MO_KOD_TFOMS ]
          kartp->SNILS_VR := krtp->SNILS_VR
        Else
          kartp->SNILS_VR := ''
        Endif
        If krtp->OPLATA == 1
          ++kol1
        Else
          ++kol3
        Endif
      Endif
      s_death := '0'
      n_del := 0
      For j := 1 To Len( arr_csv[ i, CSV_A_CERR ] )
        Select KRTE
        find ( Str( nkod_reestr, 6 ) + Str( arr_csv[ i, CSV_A_NREC ], 6 ) + Str( arr_csv[ i, CSV_A_CERR, j ], 3 ) )
        If Found()
          g_rlock( forever )
        Else
          addrec( 6 )
          krte->REESTR := nkod_reestr
          krte->REES_ZAP := arr_csv[ i, CSV_A_NREC ]
          krte->REFREASON := arr_csv[ i, CSV_A_CERR, j ]
        Endif
        krte->KOD_K := krtp->KOD_K
        If ( j1 := AScan( te, {| x| x[ 1 ] == krte->REFREASON } ) ) == 0
          AAdd( te, { krte->REFREASON, 0 } )
          j1 := Len( te )
        Endif
        te[ j1, 2 ] ++
        If krte->REFREASON == 706
          s_death := '1' // Застрахованный умер
        Endif
        If eq_any( krte->REFREASON, 706, 708, 709, 802, 803 )
          n_del := 1
        Endif
      Next
      If fl_et // если найден или добавлен в 'kart_et'
        kart_et->PC2 := s_death
      Endif
      // запись !!!!
      kol4 := f_put_date_prik( krtp->KOD_K, ;
        arr_csv[ i, CSV_A_PID ], ;
        arr_csv[ i, CSV_A_ENP ], ;
        5, ;
        s_death, ;
        n_del, ;
        arr_csv[ i, CSV_A_MO ], arr_csv[ i, CSV_A_DT_MO ] )
      If i % 2000 == 0
        dbUnlockAll()
        Commit
      Endif
    Next
    dbUnlockAll()
    Commit
    Select KRTR
    Goto ( nkod_reestr )
    g_rlock( forever )
    krtr->KOL_P := kol1
    krtr->ANSWER := 1  // 0-не было ответа, 1-был прочитан ответ
    //
    Select KRTF
    g_rlock( forever )
    krtf->TWORK2 := hour_min( Seconds() )
    dbUnlockAll()
    Commit
    StrFile( hb_eol() + ;
      'Обработано всего       : ' + lstr( k ) + hb_eol(), cFileProtokol, .t. )
    StrFile( 'Прикреплено к нашей  МО: ' + lstr( kol1 ) + hb_eol(), cFileProtokol, .t. )
    // strfile('---прикреплено к нашей  МО: ' + lstr(kol4) + hb_eol(), cFileProtokol, .t.)
    StrFile( 'Прикреплено к другим МО: ' + lstr( kol3 ) + hb_eol(), cFileProtokol, .t. )
    ASort( au, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    For j := 1 To Len( au )
      StrFile( PadL( iif( j == 1, 'в т.ч.', '' ), 15 ) + Str( au[ j, 2 ], 6 ) + ' - ' + ret_mo( au[ j, 1 ] )[ _MO_SHORT_NAME ] + hb_eol(), cFileProtokol, .t. )
    Next
    ASort( te, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    StrFile( 'Список ошибок:' + hb_eol(), cFileProtokol, .t. )
    Private mm_err := { { 'Не имеет текущего страхования', 708 }, ; // !!!
    { 'ТФОМС не вернул никакой информации', -99 } } // !!!
    For j1 := 1 To Len( te )
      If AScan( mm_err, {| x| x[ 2 ] == te[ j1, 1 ] } ) > 0
        s := inieditspr( A__MENUVERT, mm_err, te[ j1, 1 ] )
      Else
        s := inieditspr( A__MENUVERT, get_err_csv_prik(), te[ j1, 1 ] )
      Endif
      StrFile( Str( te[ j1, 2 ], 6 ) + ' чел. - ' + Str( te[ j1, 1 ], 3 ) + ' ' + s + hb_eol(), cFileProtokol, .t. )
    Next
  Endif
  rest_box( buf )

  Return Nil

// 05.11.15
Function f_put_et_etk( lpid, lenp, ld_prik, luchast, lmo, lsnils, lkod_k, lprior )

  Local fl_et := .f.

  If lpid > 0
    Select kart_et
    find ( Str( lpid, 10 ) )
    If Found()
      g_rlock( forever )
    Else
      addrec( 10 )
      kart_et->kod_tf := lpid
    Endif
    kart_et->MO_PR := lmo
    If iif( Between( lprior, 1, 2 ), .t., Empty( kart_et->kod_mis ) )
      kart_et->kod_mis := lenp
    Endif
    If iif( Between( lprior, 1, 2 ), .t., Empty( kart_et->DATE_PR ) )
      kart_et->DATE_PR := ld_prik
    Endif
    If !Empty( luchast )
      kart_et->UCHAST := luchast // номер участка
    Endif
    If !Empty( lsnils )
      kart_et->SNILS_VR := lsnils  // СНИЛС участкового врача
    Endif
    //
    fl_et := .t.
    Select kart_etk
    find ( Str( lkod_k, 7 ) )
    If Found()
      g_rlock( forever )
    Else
      addrec( 10 )
      kart_etk->kod_k := lkod_k
      If lprior == 1
        kart_etk->PRIOR := lprior // приоритет = 1 для сверки
      Endif
    Endif
    kart_etk->kod_tf := lpid
    If eq_any( lprior, 0, 2 )
      kart_etk->PRIOR := lprior // приоритет = 2 для MO2 (или 0 для не наших)
    Endif
  Endif

  Return fl_et

// 10.03.18
Function f_put_date_prik( lkod_k, lpid, lenp, ltip_pr, ldeath, _n_del, lprik_mo, ldate_prik_mo )

  Static j := 0
  Local old_pr, arr := {}

  Default _n_del To 0, lprik_mo To '', ldate_prik_mo To CToD( '' )

  Select KARTP
  find ( Str( lkod_k, 7 ) )
  Do While kartp->KOD_K == lkod_k .and. !Eof()
    AAdd( arr, { kartp->MO_PR, ;
      kartp->D_PRIK, ;
      kartp->SNILS_VR, ;
      iif( Empty( kartp->DFILE ), kartp->D_PRIK, iif( kartp->D_PRIK > kartp->DFILE, kartp->D_PRIK, kartp->DFILE ) ) ;
      };
      )
    Skip
  Enddo

  Select KART2
  Do While kart2->( LastRec() ) < lkod_k
    g_rlock( .t., forever ) // бесконечная попытка добавить запись
    kart2->kod_tf := 0
    kart2->MO_PR := ''
    kart2->SNILS_VR := '' // уч.врач ещё не привязан
    kart2->PC2 := ''      // не умер
    kart2->PC4 := ''
  Enddo
  Goto ( lkod_k )
  g_rlock( forever )
  If !Empty( lpid )
    kart2->kod_tf := lpid
  Endif
  If !Empty( lenp )
    kart2->kod_mis := lenp
  Endif
  If ldeath != NIL
    kart2->PC2 := ldeath
  Endif
  If Empty( arr )
    If _n_del == 1
      kart2->MO_PR := ''
    Endif
  Else
    old_pr := kart2->MO_PR // то, что было записано
    // if len(arr) > 1 .and. !empty(arr[2, 1])
    // old_pr := arr[2, 1] // предыдущее прикрепление
    // endif
    ASort( arr, , , {| x, y| x[ 4 ] > y[ 4 ] } ) // в порядке убывания даты файла
    kart2->TIP_PR   := ltip_pr
    kart2->MO_PR    := iif( _n_del == 1, '', arr[ 1, 1 ] )
    kart2->DATE_PR  := arr[ 1, 2 ]
    kart2->SNILS_VR := arr[ 1, 3 ]
    If ltip_pr == 3
      If !Empty( kart2->MO_PR ) .and. ( !( old_pr == kart2->MO_PR ) .or. Empty( kart2->pc4 ) )
        kart2->pc4 := date_8( kart2->DATE_PR )
      Endif
    Elseif ltip_pr == 4
      kart2->pc4 := date_8( kart2->DATE_PR )
    Elseif !emptyany( lprik_mo, ldate_prik_mo ) .and. lprik_mo == kart2->MO_PR
      kart2->pc4 := date_8( ldate_prik_mo )
    Endif
  Endif
  If kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ]
    ++j
  Endif

  Return j
