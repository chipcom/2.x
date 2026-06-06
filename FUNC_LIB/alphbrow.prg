#include 'function.ch'
#include 'inkey.ch'

// 05.06.26
FUNCTION Alpha_Browse( nTop, nLeft, nBottom, nRight, ;
                       mfunction, mcolor, titul, titul_color, ;
                       fl_index, fl_noclear, arr_block, ;
                       m1function, n_func, arr_mouse, arr_Browse )

  // nTop, nLeft, nBottom, nRight - габариты окна
  // mfunction - функция для составления столбцов TBrowse
  // mcolor - цвет TBrowse
  // titul, titul_color - заголовок и его цвет
  // fl_index - лог.величина, указывающая, проиндексирована ли БД по алфавиту
  // fl_noclear - лог.величина, указывающая, восстанавливать ли экран
  // arr_block - массив блоков кода
  //             1 - блок кода Top
  //             2 - блок кода Bottom
  //             3 - блок кода Skip
  //             4 - строка, добавляемая в начало FIND для поиска по нач.букве
  //             5 - условие для проверки поиска по начальной букве
  //                 (это второй параметр в функции блока кода Skip)
  // m1function - функция, вызываемая на каждом шаге TBrowse (рисование)
  // n_func - функция, вызываемая при нажатии определенных клавиш
  // arr_mouse - массив областей для мыши
  // arr_Browse - массив других параметров для TBrowse:
  //              1 - oBrowse:headSep
  //              2 - oBrowse:colSep
  //              3 - oBrowse:footSep
  //              4 - oBrowse:colorSpec
  //              5 - .t. или .f. (по умолчанию .f.) - в случае .t. запрещает
  //                  выход по <Enter> (<Enter> обрабатывается ф-ией n_func)
  //              6 - "время на раздумье" в секундах, по умолчанию - 60 сек.
  //                  если = 0, то нет самостоятельного выхода из Browse
  //              7 - строка символов, не обрабатываемая стандартным образом
  //                  при поиске по начальным буквам
  //              8 - .t. или .f. (по умолчанию .f.) - в случае .t. выводит
  //                  справа от таблицы полосу прокрутки - это уместно, если
  //                  DBF-файл не проиндексирован и заранее отсортирован

  LOCAL lCont := .T., nKey := 256, buf := savescreen(), ;
      t_color := setcolor(), i, j, nsec := seconds(), ;
      fl_mouse, x_mouse := 0, y_mouse := 0, km, fl_rbrd := .f., COUNT, NSTR,;
      color_find, static_find := '', buf_static, len_static
//  local mfunction1, endmfunc := '', stF

  Private oBrowse, tmp, pr1, pr2, pc1, pc2
  DEFAULT fl_index TO .t., fl_noclear TO .f., mfunction TO '', ;
        m1function TO '', n_func TO '', ;
        arr_Browse TO { '═╤═', ' │ ', '═╧═', NIL, .f., 60, '*+-', .f. }
  if len( arr_Browse ) < 8
    asize( arr_Browse, 8 )
  endif
  DEFAULT arr_Browse[ 1 ] TO '═╤═',;
        arr_Browse[ 2 ] TO ' │ ',;
        arr_Browse[ 3 ] TO '═╧═',;
        arr_Browse[ 5 ] TO .f.  ,;
        arr_Browse[ 6 ] TO 60   ,;
        arr_Browse[ 7 ] TO '*+-',;
        arr_Browse[ 8 ] TO .f.
  if !empty( m1function ) .and. !( '(' $ m1function )
    m1function += '()'
  endif
  if !empty( n_func ) .and. '(' $ n_func
    n_func := beforatnum( '(', n_func )
  endif
  if mcolor != NIL
    setcolor( mcolor )
  endif
  if !arr_Browse[ 5 ]  // если не редактируем
    status_key( '^^' + if( fl_index, ' или начальная буква', '' ) + ;
             ' - просмотр;  ^<Esc>^ - выход;  ^<Enter>^ - выбор' )
  endif
  pr1 := nTop
  pr2 := nBottom
  pc1 := nLeft
  pc2 := nRight

  box_shadow( nTop, nLeft, nBottom, nRight, mcolor, titul, titul_color )
  // Создание нового TBrowse объекта
  oBrowse := TBrowseDB( nTop + 1, nLeft + 1, nBottom, nRight - 1 )
  //  задание установок TBrowse
  oBrowse:headSep := arr_Browse[ 1 ]
  oBrowse:colSep  := arr_Browse[ 2 ]
  oBrowse:footSep := arr_Browse[ 3 ]
  if arr_Browse[ 4 ] != NIL
    oBrowse:colorSpec := arr_Browse[ 4 ]
  endif

//  if !empty( mfunction ) .and. '(' $ mfunction
//    mfunction1 := SubStr( mfunction, 1, At( '(', mfunction ) - 1 )
//    endmfunc := SubStr( mfunction, At( '(', mfunction ) + 1 )
//  else
//    mfunction1 := mfunction
//  endif

//  if empty( endmfunc )
    nKey := &( mfunction + '(oBrowse)' )   // добавление столбцов
//  else
//    stF := mfunction1 + '(oBrowse,' + endmfunc
//    nKey := &( mfunction1 + '(oBrowse,' + endmfunc )   // добавление столбцов
//  endif

  if arr_block != NIL .and. valtype( arr_block ) == 'A'
    oBrowse:goTopBlock := arr_block[ 1 ]
    oBrowse:goBottomBlock := arr_block[ 2 ]
    oBrowse:skipBlock := arr_block[ 3 ]
  endif
  color_find := color_find( oBrowse:colorSpec )     // =============
  buf_static := save_box( nTop, nLeft, nTop, nRight )  // =============
  len_static := nRight - nLeft - 3                // =============
  nTop += nBottom - nTop - oBrowse:rowCount - 1
  @ nTop, nLeft  say '╠'
  @ nTop, nRight say '╣'
  if arr_Browse[ 8 ]
    NSTR := oBrowse:rowCount
    COUNT := lastrec()
    if NSTR < COUNT .and. NSTR > 4 .and. ;
                 !( arr_block != NIL .and. valtype( arr_block ) == 'A' )
      fl_rbrd := .t.
      Private last_k := 2
      @ nTop + 1, nRight    say chr( 30 )
      @ nBottom - 1, nRight say chr( 31 )
      for i := nTop + 2 to nBottom - 2
        @ i, nRight say chr( 176 )
      next
      @ nTop + last_k, nRight say chr( 8 )
      oBrowse:goTopBlock := ;
         { || dbGoTop(), right_side( fl_rbrd, recno(), COUNT, nTop, nRight, NSTR ) }
      oBrowse:goBottomBlock := ;
         { || dbGoBottom(), right_side( fl_rbrd, recno(), COUNT, nTop, nRight, NSTR ) }
      oBrowse:skipBlock := ;
         { | nSkip, n | n := SkipPointer( nSkip, '.t.' ), right_side( fl_rbrd, recno(), COUNT, nTop, nRight, NSTR ), n }
    endif
  endif
  fl_mouse := SETPOSMOUSE()
  if type( 'alpha_1_rect' ) != 'L'
    Private alpha_1_rect := .f.
  endif
  DO WHILE lCont   // главный цикл просмотра
    if nKey != 0
      oBrowse:refreshCurrent()  // Устанавливает текущей строке стандартные цвета
      oBrowse:forcestable()  // стабилизация
      if oBrowse:colCount > 1 .and. !alpha_1_rect
        // Выделение цветом всей текущей строки
        i := 2
        if arr_Browse[ 4 ] != NIL
          tmp := ( oBrowse:getColumn( 1 ) ):colorBlock
          i := eval( tmp )
          if valtype( i ) == 'A'
            i := i[ 2 ]
          else
            i := 2
          endif
        endif
        oBrowse:colorRect( { oBrowse:rowPos, 1, oBrowse:rowPos, oBrowse:colCount }, { i, i } )
        oBrowse:forcestable()  // стабилизация
      endif
      if !empty( m1function )
        tmp := &m1function
      endif
      FT_MSHOWCRS( fl_mouse )
    endif
    nKey := 0
    /*if fl_mouse
      if ( km := FT_MGETPOS() ) == 2
        nKey := K_ESC
      elseif km == 1
        x_mouse := FT_MGETX()
        y_mouse := FT_MGETY()
        if between( x_mouse, nLeft+1, nRight - 1 )
          if between( y_mouse, nTop + 1, nBottom - 1 )
            if y_mouse == ( i := nTop + oBrowse:rowPos )
              nKey := K_ENTER
            elseif y_mouse > i
              for j := 1 to y_mouse - i
                keyboard chr( K_TAB )  //  keysend( CHR( 9 ) + CHR( 15 ), .t. )  // KS_TAB
              next
            else
              for j := 1 to i - y_mouse
                keyboard chr( K_SH_TAB )  //  keysend( CHR( 0 ) + CHR( 15 ), .t. ) // KS_SH_TAB
              next
            endif
            clear_mouse()
          elseif y_mouse == nTop
            nKey := K_SH_TAB
          elseif y_mouse == nBottom
            nKey := K_TAB
          endif
        elseif fl_rbrd .and. x_mouse == nRight
          if between( y_mouse, nTop + 2, nBottom - 2 )
            if y_mouse < nTop+last_k
              nKey := K_PGUP
            elseif y_mouse > nTop + last_k
              nKey := K_PGDN
            endif
          elseif y_mouse == nTop + 1
            nKey := K_SH_TAB
          elseif y_mouse == nBottom - 1
            nKey := K_TAB
          endif
          clear_mouse()
        endif
        if nKey == 0 .and. arr_mouse != NIL
          if ( i := ascan( arr_mouse, { | x | between( x_mouse, x[ 2 ], x[ 4 ] ) .and. ;
                                       between( y_mouse, x[ 1 ], x[ 3 ] ) } ) ) > 0
            clear_mouse()
            //aeval(arr_mouse[ i, 5 ], { | x | keysend( x, .t. ) } )
          endif
        endif
      endif
    endif*/
    if nKey == 0
      nKey := INKEYTRAP()
    endif
    if fl_index .and. nKey != 0 .and. ;                          // =============
        !( ( ( ( len( static_find ) > 0 .and. nKey == 32 ) .or. between( nKey, 33, 255 ) ) ;
        .and. !( chr( nKey ) $ arr_Browse[ 7 ] ) ) .or. nKey == K_BS ) // =============
      static_find := ''
      rest_box(buf_static)                   // =============
    endif                                                        // =============
    if arr_Browse[ 6 ] > 0
      if nKey == 0
        if seconds() - nsec > arr_Browse[ 6 ]   // если не трогали клавиатуру,
          keyboard chr( K_ESC )                 // то выйти из функции
        endif
      else
        nsec := seconds()
      endif
    endif
    DO CASE  // обработка нажатых клавиш
      CASE nKey == K_LEFT .and. alpha_1_rect
        FT_MHIDECRS( fl_mouse )
        oBrowse:left()
      CASE nKey == K_RIGHT .and. alpha_1_rect
        FT_MHIDECRS( fl_mouse )
        oBrowse:right()
      CASE nKey == K_UP .or. nKey == K_SH_TAB
        FT_MHIDECRS( fl_mouse )
        oBrowse:up()
      CASE nKey == K_DOWN .or. nKey == K_TAB
        FT_MHIDECRS( fl_mouse )
        oBrowse:down()
      CASE nKey == K_PGUP
        FT_MHIDECRS( fl_mouse )
        oBrowse:pageUp()
      CASE nKey == K_PGDN
        FT_MHIDECRS( fl_mouse )
        oBrowse:pageDown()
      CASE nKey == K_HOME .or. nKey == K_CTRL_PGUP .or. nKey == K_CTRL_HOME
        FT_MHIDECRS( fl_mouse )
        oBrowse:goTop()
      CASE nKey == K_END .or. nKey == K_CTRL_PGDN .or. nKey == K_CTRL_END
        FT_MHIDECRS( fl_mouse )
        oBrowse:goBottom()
      CASE nKey == K_ESC .OR. ( nKey == K_ENTER .and. !arr_Browse[ 5 ] )
        lCont := .F.
      CASE fl_index .and. nKey != 0 .and. indexord() > 0 .and. ;
          ( ( ( ( len( static_find ) > 0 .and. nKey == 32 ) .or. between( nKey, 33, 255 ) ) ;
             .and. !(chr( nKey ) $ arr_Browse[ 7 ] ) ) .or. nKey == K_BS )
        FT_MHIDECRS( fl_mouse )
        oBrowse:goTop()
        if nKey == K_BS
          if len( static_find ) > 1
            static_find := left( static_find, len( static_find ) - 1 )
          else
            static_find := ''
          endif
        else
          if len( static_find ) < len_static
            static_find += Upper( CHR( nKey ) )
          endif
        endif
        put_static( buf_static, static_find, color_find )
        if !empty( static_find )
          if arr_block != NIL .and. valtype( arr_block) == 'A' ;
                            .and. len( arr_block ) > 3
            tmp := arr_block[ 4 ] + static_find
          else
            tmp := static_find
          endif
          dbseek( tmp, .t. )
          if arr_block != NIL .and. valtype( arr_block ) == 'A' ;
                            .and. len( arr_block ) > 4 .and. !&( arr_block[ 5 ] )
            DBSKIP( -1 )
          ENDIF
          IF EOF()
            oBrowse:goBottom()
          ELSE
            oBrowse:refreshAll()
          ENDIF
        endif
      CASE nKey != 0 .and. !empty( n_func )
        FT_MHIDECRS(fl_mouse)
        if ( i := &( n_func + '(' + lstr( nKey ) + ', oBrowse)' ) ) == 0
          oBrowse:refreshAll()   // функция должна возвратить 0 для
        elseif i == 1            // обновления TBrowse, иначе -1 (ничего)
          lCont := .f.           // или 1 для выхода из TBrowse
        endif
        nsec := seconds()
        nKey := 256
    ENDCASE
  ENDDO
  if fl_mouse
    clear_mouse()
    FT_MHIDECRS()
  endif
  setcolor( t_color )
  if !fl_noclear
    restscreen( buf )
  endif

RETURN ( nKey != K_ESC )
