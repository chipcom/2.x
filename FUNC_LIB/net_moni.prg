#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'

#define S_LOCK      1
#define S_OPEN      3
#define S_VALUE     6

Static tmp1monitor := 'tmp_mon1.dbf'
Static tmp2monitor := 'tmp_mon2.dbf'

// программа управления сетевым монитором
Function net_monitor( r, c, yes_admin )

  Local lCont := .t., nKey := 256, buf := SaveScreen(), ;
    t_color := SetColor( 'N/BG, W+/N' ), i, j, nsec := Seconds(), ;
    oBrowse, oColumn, pr1, pr2, pc1, pc2, blk, s := ''

  Default yes_admin To .t.
  If !f1_net_mon( 1 )
    Return func_error( 4, 'Недоступен файл семафора! Попытайтесь еще раз.' )
  Endif
  //
  If yes_admin
    s := ';  ^<Del>^ - удалить семафор'
  Endif
  status_key( '^<Esc>^ - выход' + s )
  If r > MaxRow() / 2
    r := Int( MaxRow() / 2 )
  Endif
  pr1 := r
  pr2 := MaxRow() - 4
  pc1 := 0
  pc2 := 79
  box_shadow( pr1, pc1, pr2, pc2, 'N/BG, W+/N', 'Сетевой монитор', 'B/BG' )
  // Создание нового TBrowse объекта
  oBrowse := TBrowseDB( pr1 + 1, pc1 + 1, pr2, pc2 - 1 )
  // задание установок TBrowse
  oBrowse:headSep := '═╤═'
  oBrowse:colSep  := ' │ '
  oBrowse:footSep := '═╧═'
  oBrowse:colorSpec := 'N/BG,W+/N,B/BG,BG+/B'
  // добавление столбцов
  blk := {|| iif( Empty( tmp2->kod ), { 3, 4 }, { 1, 2 } ) }
  oColumn := TBColumnNew( PadC( 'Дата', 10 ), {|| full_date( tmp2->data ) } )
  oColumn:colorBlock := blk
  oBrowse:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( 'Время', {|| hour_min( tmp2->task / 100 ) } )
  oColumn:colorBlock := blk
  oBrowse:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( PadC( 'Задача', 12 ), {|| tmp2->exe } )
  oColumn:colorBlock := blk
  oBrowse:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( PadC( 'Пользователь', 20 ), {|| tmp2->fio } )
  oColumn:colorBlock := blk
  oBrowse:addcolumn( oColumn )
  //
  oColumn := TBColumnNew( PadC( 'Компьютер', 17 ), {|| Left( tmp2->comp, 17 ) } )
  oColumn:colorBlock := blk
  oBrowse:addcolumn( oColumn )
  //
  j := pr2 - oBrowse:rowCount - 1
  @ j, pc1 Say '╠'
  @ j, pc2 Say '╣'
  @ MaxRow() -3, 0 To MaxRow() -1, 79 Color 'B+/B'
  @ MaxRow() -2, 1 Say Space( 78 ) Color 'B+/B'
  str_center( MaxRow() -3, ' Наименование режима ', 'B+/B' )
  Do While lCont   // главный цикл просмотра
    If nKey != 0
      oBrowse:refreshcurrent()  // Устанавливает текущей строке стандартные цвета
      oBrowse:forcestable()  // стабилизация
      If oBrowse:colCount > 1
        // Выделение цветом всей текущей строки
        i := Eval( blk )
        If ValType( i ) == 'A'
          i := i[ 2 ]
        Else
          i := 2
        Endif
        oBrowse:colorrect( { oBrowse:rowPos, 1, oBrowse:rowPos, oBrowse:colCount }, { i, i } )
        oBrowse:forcestable()  // стабилизация
      Endif
      @ MaxRow() -2, 1 Say PadC( AllTrim( tmp2->name ), 78 ) Color 'W+/B, W+/R'
    Endif
    nKey := inkeytrap()
    If Seconds() - nsec > 20     // каждые 20 сек.
      If f1_net_mon( 2 )           // перечитать семафор
        oBrowse:refreshall()
        nsec := Seconds()
        nKey := 256
      Endif
      nsec := Seconds()
    Endif
    Do Case  // обработка нажатых клавиш
    Case nKey == K_UP .or. nKey == K_SH_TAB
      oBrowse:up()
    Case nKey == K_DOWN .or. nKey == K_TAB
      oBrowse:down()
    Case nKey == K_PGUP ; oBrowse:pageup()
    Case nKey == K_PGDN ; oBrowse:pagedown()
    Case nKey == K_HOME .or. nKey == K_CTRL_PGUP .or. nKey == K_CTRL_HOME
      oBrowse:gotop()
    Case nKey == K_END .or. nKey == K_CTRL_PGDN .or. nKey == K_CTRL_END
      oBrowse:gobottom()
    Case nKey == K_DEL .and. yes_admin .and. f_esc_enter( 2 )
      del_sem_other( tmp2->task )
      Select TMP2
      deleterec()
      oBrowse:gotop()
    Case nKey == K_ESC
      lCont := .f.
    Endcase
  Enddo
  SetColor( t_color )
  Close databases
  RestScreen( buf )
  Return Nil

//
Static Function f1_net_mon( par )

  Local rec := 0, fl := .f.

  If par == 1  // первый запуск
    Delete File ( tmp2monitor )
    fl := f2_net_mon()
  Else  // следующие запуски
    rec := tmp2->( RecNo() )
    Close databases
    fl := f2_net_mon()
  Endif
  If fl .or. File( tmp2monitor )
    Use ( tmp2monitor ) Index tmp2 New Alias TMP2
    Go Top
    If rec > 0
      Do While !Eof()  // пройти вперед до конца
        Skip
      Enddo
      Do While !Bof()  // а теперь назад до нужной записи
        If RecNo() == rec
          Exit
        Endif
        Skip -1
      Enddo
    Endif
  Endif
  Return fl

//
Static Function f2_net_mon()

  Local i := 0, adbf, fl := .f., buf := save_row( MaxRow() )
  Local bSaveHandler, oError

  mywait()
  Delete File ( tmp1monitor )
  Do While++i < 20
    //
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    //
    Begin Sequence
      Copy File ( dir_server() + 'semaphor.dbf' ) to ( tmp1monitor )
      If hb_FileExists( tmp1monitor )
        fl := .t.
      Endif
    RECOVER USING oError
      fl := .f.
    End
    //
    ErrorBlock( bSaveHandler )
    If fl
      Exit
    Endif
    Millisec( 20 )
  Enddo
  If fl
    Use ( tmp1monitor ) New Alias TMP1
    If File( tmp2monitor )
      Use ( tmp2monitor ) New Alias TMP2
      Zap
    Else
      Select TMP1
      adbf := dbStruct()
      dbCreate( tmp2monitor, adbf )
      Use ( tmp2monitor ) New Alias TMP2
    Endif
    Select TMP1
    Index On Str( FIELD->kod, 1 ) To tmp1
    find ( Str( S_OPEN, 1 ) )
    Do While tmp1->kod == S_OPEN .and. !Eof()
      Select TMP2
      Append Blank
      Replace task With tmp1->task, ;
        Data With tmp1->data, ;
        fio  With tmp1->fio,;
        comp With tmp1->comp, ;
        exe  With tmp1->exe
      Select TMP1
      Skip
    Enddo
    Select TMP2
    Index On Str( FIELD->task, 7 ) To tmp2
    //
    Select TMP1
    find ( Str( S_LOCK, 1 ) )
    Do While tmp1->kod == S_LOCK .and. !Eof()
      Select TMP2
      find ( Str( tmp1->task, 7 ) )
      If Found()
        tmp2->kod  := S_LOCK
        tmp2->name := tmp1->name
      Endif
      Select TMP1
      Skip
    Enddo
    //
    Select TMP1
    find ( Str( S_VALUE, 1 ) )
    Do While tmp1->kod == S_VALUE .and. !Eof()
      If tmp1->value > 0
        Select TMP2
        find ( Str( tmp1->task, 7 ) )
        If Found() .and. Empty( tmp2->kod )
          tmp2->kod  := S_VALUE
          tmp2->name := tmp1->name
        Endif
      Endif
      Select TMP1
      Skip
    Enddo
    Select TMP2
    Index On DToS( FIELD->data ) + Str( FIELD->task, 7 ) To tmp2
  Endif
  Close databases
  rest_box( buf )
  Return fl

// 18.09.25 удалить семафор вызовом из сетевого монитора (по имени задачи)
Function del_sem_other( t_name )

  Local fl := .f., tmp_select := Select(), bSaveHandler
  Local sbase, sem_dbf
  Local oError

  sbase := dir_server() + 'semaphor'
  sem_dbf := sbase + '.dbf'
  Do While .t.
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    Begin Sequence
      dbUseArea( .t., ;          // new
        , ;            // rdd
        sbase, ;    // db
        'SEMAPHOR', ;  // alias
        .f., ;          // !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
        , ;            // readonly
        'RU866' )
      fl := .t.
    RECOVER USING oError
      fl := .f.
      If Select( 'SEMAPHOR' ) > 0
        SEMAPHOR->( dbCloseArea() )
      Endif
    End
    ErrorBlock( bSaveHandler )
    If fl // при удачном открытии создаём индекс в рабочем каталоге
      Index On Str( FIELD->task, 7 ) To tmp_sem
      Do While .t.
        find ( Str( t_name, 7 ) )
        If !Found()
          exit
        Endif
        s_deleterec()
      Enddo
      SEMAPHOR->( dbCloseArea() )
    Else
      If f_alert( { 'Возникла ошибка!', ;
          'Невозможно открыть файл SEMAPHOR.DBF', ;
          'Вероятнее всего, он занят другим пользователем.', ;
          '' }, ;
          { ' <Esc> - отказ ', ' <Enter> - попытаться снова ' }, ;
          1, 'W/N', 'G+/N',,, 'W+/N,N/BG' ) == 2
        Loop
      Endif
    Endif
    Exit
  Enddo
  If tmp_select > 0
    Select ( tmp_select )
  Endif
  Return Nil
