// operators.prg - информация по операторам
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// записать объём работы операторов
Function write_work_oper( _pt, _tp, _ae, _kk, _kp, _open )

  // {"PD",      'C',   4,   0}, ; // дата ввода c4tod(pd)
  // {"PO",      'C',   1,   0}, ; // код оператора asc(po)
  // {"PT",      'C',   1,   0}, ; // код задачи
  // {"TP",      'C',   1,   0}, ; // тип (1-карточка, 2-л/у, 3-услуги)
  // {"AE",      'C',   1,   0}, ; // 1-добавление, 2-редактирование, 3-удаление
  // {"KK",      'C',   3,   0}, ; // кол-во (карточек, л/у или услуг)
  // {"KP",      'C',   3,   0};  // количество введённых полей
  Static llen := 6

  Default _kk To 1, _kp To 0, _open To .t.
  If yes_parol .and. hb_FileExists( dir_server() + 'mo_opern' + sdbf() ) .and. ;
      iif( _open, g_use( dir_server() + 'mo_opern', dir_server() + 'mo_opern', 'OP' ), .t. )
    _pt := Chr( _pt )
    _tp := Chr( _tp )
    _ae := Chr( _ae )
    find ( c4sys_date + kod_polzovat + _pt + _tp + _ae )
    If Found()
      g_rlock( 'forever' )
      op->kk := ft_Sqzn( _kk + ft_Unsqzn( op->kk, llen ), llen )
      op->kp := ft_Sqzn( _kp + ft_Unsqzn( op->kp, llen ), llen )
    Else
      g_rlock( .t., 'forever' )
      op->PD := c4sys_date
      op->PO := kod_polzovat
      op->pt := _pt
      op->tp := _tp
      op->ae := _ae
      op->kk := ft_Sqzn( _kk, llen )
      op->kp := ft_Sqzn( _kp, llen )
    Endif
    If _open
      op->( dbCloseArea() )
    Endif
  Endif

  Return Nil

// 13.07.26 статистика по работе операторов
Function st_operator() 

  Local i, j, k, buf24, sh := 0, arr_oper := {}, arr_g, ;
    s0, s1, s2, s3, s4, buf, name_file := cur_dir() + 'operator.txt', ;
    arr_title, reg_print := 2, ls, fl_orto := .f., r1 := 9, ;
    arrNtitle, llen, ldec, fl_old, fl_new, s, n

  local _po, _pt, _ae, _tp

  Private koef0, koef1 := 20, koef2 := 9, koef21 := 3, koef3 := 1, ;
    stoim := 0.012, mprocent := 0, ;
    koef_orto := 22, koef1_orto := 22

  koef0 := koef1 - koef2
  If !currentuser():isadmin()
    Return func_error( 4, 'Доступ в данный режим разрешен только администратору системы!' )
  Endif
  If ( arr_g := year_month() ) == NIL
    Return Nil
  Endif
  r_use( dir_server() + 'mo_oper', dir_server() + 'mo_oper', 'OP' )
  dbSeek( arr_g[ 7 ], .t. )
  fl_old := ( op->pd <= arr_g[ 8 ] .and. !op->( Eof() ) )
  dbCloseAll()
  //
  r_use( dir_server() + 'mo_opern', dir_server() + 'mo_opern', 'OP' )
  dbSeek( arr_g[ 7 ], .t. )
  fl_new := ( op->pd <= arr_g[ 8 ] .and. !op->( Eof() ) )
  dbCloseAll()
  buf24 := save_maxrow()
  If fl_old
    If is_task( X_ORTO )
      fl_orto := .t. ; r1 -= 2
    Endif
    SetColor( cDataCGet )
    buf := box_shadow( r1, 10, 22, 69 )
    str_center( r1 + 2, 'Вам предлагаются следующие коэффициенты трудоемкости', color8 )
    str_center( r1 + 3, '(которые имеется возможность отредактировать):', color8 )
    j := r1 + 5
    @ j, 13 Say 'Заполнение картотеки (РЕГИСТРАТУРА)               ' ;
      Get koef0 Pict '99' valid {| g| fst_operator( g ) }
    @ ++j, 13 Say 'Ввод полных реквизитов при вводе листа учёта      ' ;
      Get koef1 Pict '99' valid {| g| fst_operator( g ) }
    @ ++j, 13 Say 'Выбор из картотеки при вводе листа учёта          ' ;
      Get koef2 Pict '99' valid {| g| fst_operator( g ) }
    @ ++j, 13 Say 'Повторный выбор пациента из картотеки при вводе   ' ;
      Get koef21 Pict '99' valid {| g| fst_operator( g ) }
    @ ++j, 13 Say 'Коэффициент трудоемкости при вводе одной услуги   ' ;
      Get koef3 Pict '99' When .f.
    If fl_orto
      @ ++j, 13 Say 'Заполнение картотеки в задаче ОРТОПЕДИЯ           ' ;
        Get koef1_orto Pict '99' valid {| g| fst_operator( g ) }
      @ ++j, 13 Say 'Заполнение ортопедической карточки больного       ' ;
        Get koef_orto Pict '99' valid {| g| fst_operator( g ) }
    Endif
    @ ++j, 13 Say 'Цена одной условной единицы информации в рублях' ;
      Get stoim Pict '9.999'
    @ ++j, 13 Say 'Процент надбавки' Get mprocent Pict '99'
    status_key( '^<Esc>^ - выход из режима;  ^<Enter>^ - подтверждение ввода' )
    myread()
    rest_box( buf )
    If LastKey() == K_ESC
      Return Nil
    Endif
    If mprocent > 0
      reg_print := 3
    Endif
    mywait()
    arr_title := Array( 5 )
    arr_title[ 1 ] := '────────────────────┬─────────┬─────────┬─────────┬─────────┬──────┬───────┬────────'
    arr_title[ 2 ] := '       Ф.И.О.       │Карточка │ Полные  │Выбор из │  Кол-во │Объём │ Объём │Заработ.'
    arr_title[ 3 ] := '     операторов     │(реги-ра)│реквизиты│картотеки│  услуг  │в усл.│ работ │ сумма  '
    arr_title[ 4 ] := '                    │' + PadC( '( *' + lstr( koef0 ) + ' )', 9 ) + ;
      '│' + PadC( '( *' + lstr( koef1 ) + ' )', 9 ) + ;
      '│' + PadC( '( *' + lstr( koef2 ) + '/' + lstr( koef21 ) + ' )', 9 ) + ;
      '│' + PadC( '( *' + lstr( koef3 ) + ' )', 9 ) + ;
      '│един. │  в %  │ в руб. '
    arr_title[ 5 ] := '────────────────────┴─────────┴─────────┴─────────┴─────────┴──────┴───────┴────────'
    If mprocent > 0
      arr_title[ 1 ] := arr_title[ 1 ] + '┬────────'
      arr_title[ 2 ] := arr_title[ 2 ] + '│Зарплата'
      arr_title[ 3 ] := arr_title[ 3 ] + '│ в руб.'
      arr_title[ 4 ] := arr_title[ 4 ] + '│' + PadC( '(+ ' + lstr( mprocent ) + '%)', 8 )
      arr_title[ 5 ] := arr_title[ 5 ] + '┴────────'
    Endif
    sh := Len( arr_title[ 1 ] )
  Endif
  If fl_new
    arrNtitle := Array( 5 )
    arrNtitle[ 1 ] := '──────────────────────────────┬────────────┬────────────┬────────────┬──────────'
    arrNtitle[ 2 ] := '                              │ Картотека  │ Лист учёта │   Услуги   │Всего от- '
    arrNtitle[ 3 ] := '  Ф.И.О. операторов           ├─────┬──────┼─────┬──────┼─────┬──────┤редактиро-'
    arrNtitle[ 4 ] := '                              │ чел.│ полей│ л/у │ полей│услуг│ полей│вано полей'
    arrNtitle[ 5 ] := '──────────────────────────────┴─────┴──────┴─────┴──────┴─────┴──────┴──────────'
    sh := Max( sh, Len( arrNtitle[ 1 ] ) )
  Endif
  fp := FCreate( 'operator.txt' )
  tek_stroke := 0
  n_list := 1
  add_string( '' )
  add_string( Center( 'Объём работы операторов', sh ) )
  add_string( Center( arr_g[ 4 ], sh ) )
  add_string( '' )
  If fl_old
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server() + 'base1', , 'B1' )
    r_use( dir_server() + 'mo_oper', dir_server() + 'mo_oper', 'OP' )
    op->( dbSeek( arr_g[ 7 ], .t. ) )
    Do While op->pd <= arr_g[ 8 ] .and. !op->( Eof() )
      If ( i := AScan( arr_oper, {| x| x[ 1 ] == op->task } ) ) == 0
        AAdd( arr_oper, { op->task, {} } ) ; i := Len( arr_oper )
      Endif
      If op->app_edit == 1 .and. ;
          AScan( arr_oper[ i, 2 ], {| x| x[ 1 ] == op->po .and. x[ 10 ] == 0 } ) == 0
        b1->( dbGoto( Asc( op->po ) ) )
        AAdd( arr_oper[ i, 2 ], { op->po, ;
          Crypt( b1->p1, gpasskod ), ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0 } )
      Endif
      If ( k := AScan( arr_oper[ i, 2 ], ;
          {| x| x[ 1 ] == op->po .and. x[ 10 ] == op->app_edit } ) ) == 0
        b1->( dbGoto( Asc( op->po ) ) )
        AAdd( arr_oper[ i, 2 ], { op->po, ;
          Crypt( b1->p1, gpasskod ), ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          op->app_edit } )
        k := Len( arr_oper[ i, 2 ] )
      Endif
      If op->app_edit == 0
        llen := 6
        ldec := 0
      Else
        llen := 7
        ldec := 2
      Endif
      arr_oper[ i, 2, k, 3 ] += ft_Unsqzn( op->v0, llen, ldec )
      arr_oper[ i, 2, k, 4 ] += ft_Unsqzn( op->vr, llen, ldec )
      arr_oper[ i, 2, k, 5 ] += ft_Unsqzn( op->vk, 6, 0 )  // всегда целое число
      arr_oper[ i, 2, k, 6 ] += ft_Unsqzn( op->vu, llen, ldec )
      Skip
    Enddo
    Store 0 To s0, s1, s2, s3, s4, skart, skart2
    ASort( arr_oper, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    For i := 1 To Len( arr_oper )
      ASort( arr_oper[ i, 2 ], , , {| x, y| if( x[ 2 ] == y[ 2 ], x[ 10 ] < y[ 10 ], x[ 2 ] < y[ 2 ] ) } )
      AEval( arr_oper[ i, 2 ], {| x| s0 += x[ 3 ], s1 += x[ 4 ], s2 += x[ 5 ], s3 += x[ 6 ] } )
      If eq_any( arr_oper[ i, 1 ], 3, 4 )  // ОРТОПЕДИЯ
        AEval( arr_oper[ i, 2 ], {| x, j| arr_oper[ i, 2, j, 7 ] := ;
          Round( koef1_orto * x[ 3 ] + koef_orto * x[ 5 ] + koef3 * x[ 6 ], 0 ) } )
      Else
        AEval( arr_oper[ i, 2 ], {| x, j| arr_oper[ i, 2, j, 7 ] := ;
          Round( koef0 * x[ 3 ] + ;
          koef1 * x[ 4 ] + ;
          iif( x[ 10 ] == 0, koef2, koef21 ) * x[ 5 ] + ;
          koef3 * x[ 6 ], 0 ) ;
          } )
      Endif
      AEval( arr_oper[ i, 2 ], {| x, j| s4 += arr_oper[ i, 2, j, 7 ] } )
    Next
    dbCloseAll()
    s4 := Round( s4, 0 ) // объем в условных единицах - целое число
    If s4 > 0
      For i := 1 To Len( arr_oper )
        For j := 1 To Len( arr_oper[ i, 2 ] )
          If arr_oper[ i, 2, j, 10 ] == 1 .and. j > 1 ;
              .and. arr_oper[ i, 2, j -1, 10 ] == 0 ;
              .and. arr_oper[ i, 2, j -1, 1 ] == arr_oper[ i, 2, j, 1 ]
            arr_oper[ i, 2, j -1, 7 ] += arr_oper[ i, 2, j, 7 ]
          Endif
          If arr_oper[ i, 2, j, 10 ] == 0   // учет только добавлений
            skart += ( arr_oper[ i, 2, j, 4 ] + arr_oper[ i, 2, j, 5 ] )
          Endif
          If arr_oper[ i, 2, j, 10 ] == 1   // учет вторичных выборов
            skart2 += arr_oper[ i, 2, j, 5 ]
          Endif
          arr_oper[ i, 2, j, 8 ] := arr_oper[ i, 2, j, 7 ] * 100 / s4
        Next
      Next
      // подсчет процентов
      For i := 1 To Len( arr_oper )
        For j := 1 To Len( arr_oper[ i, 2 ] )
          arr_oper[ i, 2, j, 8 ] := arr_oper[ i, 2, j, 7 ] * 100 / s4
        Next
      Next
      k := ssum := szrp := 0 ; fl_orto := .f.
      For i := 1 To Len( arr_oper )
        sum1 := zrp1 := 0
        s := 'СТРАХОВАЯ МЕДИЦИНА'
        If arr_oper[ i, 1 ] == 1
          s := 'РЕГИСТРАТУРА'
        Elseif arr_oper[ i, 1 ] == 2
          s := 'ПЛАТНЫЕ УСЛУГИ'
        Elseif eq_any( arr_oper[ i, 1 ], 3, 4 )
          s := 'ОРТОПЕДИЯ ' + iif( arr_oper[ i, 1 ] == 3, 'ПЛАТНАЯ', 'БЕСПЛАТНАЯ' )
          If !fl_orto
            arr_title[ 4 ] := Stuff( arr_title[ 4 ], 22, 9, PadC( '( *' + lstr( koef1_orto ) + ' )', 9 ) )
            arr_title[ 4 ] := Stuff( arr_title[ 4 ], 42, 9, PadC( '( *' + lstr( koef_orto ) + ' )', 9 ) )
            add_string( '' )
            AEval( arr_title, {| x| add_string( x ) } )
            fl_orto := .t.
          Endif
        Endif
        add_string( Center( Expand( s ), sh ) )
        For j := 1 To Len( arr_oper[ i, 2 ] )
          If arr_oper[ i, 2, j, 7 ] > 0
            If arr_oper[ i, 2, j, 10 ] == 0
              ++k
              ls := Round( arr_oper[ i, 2, j, 7 ] * stoim, 2 )
              sum1 += ls
              ssum += ls
              s := arr_oper[ i, 2, j, 2 ] + ;
                put_val( arr_oper[ i, 2, j, 3 ], 9 ) + ;
                put_val( arr_oper[ i, 2, j, 4 ], 10 ) + ;
                put_val( arr_oper[ i, 2, j, 5 ], 10 ) + ;
                put_val( arr_oper[ i, 2, j, 6 ], 10 ) + ;
                put_val( arr_oper[ i, 2, j, 7 ], 8 ) + ;
                put_val( arr_oper[ i, 2, j, 8 ], 8, 2 ) + ;
                put_kope( ls, 9 )
              If mprocent > 0
                ls := Round( ls * ( 100 + mprocent ) / 100, 2 )
                s += put_kope( ls, 9 )
                zrp1 += ls
                szrp += ls
              Endif
            Else
              s := Space( 20 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 3 ], 9 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 4 ], 10 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 5 ], 10 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 6 ], 10 )
            Endif
            add_string( s )
          Endif
        Next
        add_string( Space( sh -25 ) + Replicate( '-', 25 ) )
        s := PadL( 'Итого : ' + lput_kop( sum1 ), 84 )
        If mprocent > 0
          s += put_kope( zrp1, 9 )
        Endif
        add_string( s )
      Next
      If k > 1
        add_string( Replicate( '─', sh ) )
        s := PadL( 'Итого : ', 20 ) + put_dec_oper( s0, 9, .f. ) + ;
          put_dec_oper( s1, 10, .f. ) + ;
          put_dec_oper( s2, 10, .f. ) + ;
          put_dec_oper( s3, 10, .f. ) + ;
          put_val( s4, 8 ) + ;
          Space( 8 ) + ;
          put_kope( ssum, 9 )
        If mprocent > 0
          s += put_kope( szrp, 9 )
        Endif
        add_string( s )
      Endif
      add_string( Replicate( '─', sh ) )
      add_string( '  Количество введенных карточек : ' + lstr( skart ) )
      If skart2 > 0
        add_string( '  повторных выборов из картотеки: ' + lstr( skart2 ) )
      Endif
    Endif
  Endif
  If fl_new
    dbCreate( cur_dir() + 'tmp', { ;
      { 'PO', 'N',  3, 0 }, ; // код оператора
      { 'FO', 'C', 20, 0 }, ; // ФИО оператора
      { 'PT', 'N',  3, 0 }, ; // код задачи
      { 'TP', 'N',  1, 0 }, ; // тип (1-карточка, 2-л/у, 3-услуги)
      { 'AE', 'N',  1, 0 }, ; // 1-добавление, 2-редактирование, 3-удаление
      { 'KK', 'N',  9, 0 }, ; // кол-во (карточек, л/у или услуг)
      { 'KP', 'N',  9, 0 } ;  // количество введённых полей
    } )
    Use ( cur_dir() + 'tmp' ) new
    Index On Str( FIELD->pt, 3 ) + Str( FIELD->po, 3 ) + Str( FIELD->ae, 1 ) + Str( FIELD->tp, 1 ) to ( cur_dir() + 'tmp' )
    r_use( dir_server() + 'base1', , 'B1' )
    r_use( dir_server() + 'mo_opern', dir_server() + 'mo_opern', 'OP' )
    op->( dbSeek( arr_g[ 7 ], .t. ) )
    Do While op->pd <= arr_g[ 8 ] .and. !op->( Eof() )
      _po := Asc( op->po )
      _pt := Asc( op->pt )
      _ae := Asc( op->ae )
      _tp := Asc( op->tp )
      llen := 6
      Select TMP
//      find ( Str( _pt, 3 ) + Str( _po, 3 ) + Str( _ae, 1 ) + Str( _tp, 1 ) )
      tmp->( dbSeek( Str( _pt, 3 ) + Str( _po, 3 ) + Str( _ae, 1 ) + Str( _tp, 1 ) ) )
      If !tmp->( Found() )
//        Append Blank
        tmp->( dbAppend() )
        tmp->pt := _pt
        tmp->po := _po
        tmp->ae := _ae
        tmp->tp := _tp
        b1->( dbGoto( _po ) )
        tmp->fo := Crypt( b1->p1, gpasskod )
      Endif
      tmp->kk += ft_Unsqzn( op->kk, llen )
      tmp->kp += ft_Unsqzn( op->kp, llen )
      Select OP
      op->( dbSkip() )
    Enddo
    arr_task := { ;
      { 'Регистратура', X_REGIST }, ;
      { 'Приёмный покой', X_PPOKOJ }, ;
      { 'ОМС', X_OMS   }, ;
      { 'Платные услуги', X_PLATN }, ;
      { 'Ортопедия ПЛАТНАЯ', X_ORTO  }, ;
      { 'Ортопедия БЮДЖЕТ', X_ORTO + 100 }, ;
      { 'Касса МО', X_KASSA };
      }
    AEval( arrNtitle, {| x| add_string( x ) } )
    Select TMP
    For i := 1 To Len( arr_task )
//      find ( Str( arr_task[ i, 2 ], 3 ) )
      tmp->( dbSeek( Str( arr_task[ i, 2 ], 3 ) ) )
      If tmp->( Found() )
        add_string( PadC( arr_task[ i, 1 ], sh, '_' ) )
        arr_oper := {}
//        find ( Str( arr_task[ i, 2 ], 3 ) )
        tmp->( dbSeek( Str( arr_task[ i, 2 ], 3 ) ) )
        Do While tmp->pt == arr_task[ i, 2 ] .and. !tmp->( Eof() )
          If AScan( arr_oper, {| x| x[ 2 ] == tmp->po } ) == 0
            AAdd( arr_oper, { tmp->fo, tmp->po } )
          Endif
          tmp->( dbSkip() )
        Enddo
        ASort( arr_oper, , , {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )
        For j := 1 To Len( arr_oper )
          For k := 1 To 3
            s := PadR( iif( k == 1, arr_oper[ j, 1 ], '' ), 21 )
            s += PadR( { 'добавлено', 'отредакт.', 'удалено' }[ k ], 9 )
            skp := 0
            For n := 1 To 3
//              find ( Str( arr_task[ i, 2 ], 3 ) + Str( arr_oper[ j, 2 ], 3 ) + Str( k, 1 ) + Str( n, 1 ) )
              tmp->( dbSeek( Str( arr_task[ i, 2 ], 3 ) + Str( arr_oper[ j, 2 ], 3 ) + Str( k, 1 ) + Str( n, 1 ) ) )
              s += put_val( tmp->kk, 5 ) + put_val( tmp->kp, 7 ) + ' '
              skp += tmp->kp
            Next
            s += put_val( skp, 9 )
            add_string( s )
          Next
        Next
      Endif
    Next
  Endif
  FClose( fp )
  dbCloseAll()
  rest_box( buf24 )
  viewtext( devide_into_pages( name_file, 60, 80 ), , , , .t., , , 2 )
  Return Nil

//
Function fst_operator( get )

  Local mvar := ReadVar(), s := 'Допустимый диапазон для данного коэффициента трудоемкости '

  If mvar == 'KOEF1' .and. !Between( &mvar, 15, 99 )
    &mvar := get:original
    Return func_error( 4, s + '15 - 99.' )
  Endif
  If ( mvar == 'KOEF0' .or. mvar == 'KOEF2' ) .and. !Between( &mvar, 3, 50 )
    &mvar := get:original
    Return func_error( 4, s + '3 - 50.' )
  Endif
  If mvar == 'KOEF21' .and. !Between( &mvar, 2, KOEF2 -1 )
    &mvar := get:original
    Return func_error( 4, s + '2 - ' + lstr( KOEF2 -1 ) + '.' )
  Endif
  Return .t.
