#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'

// 12.09.25
Function edit_u_spr( k, _arr, r1 )

  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, c1, c2, len_browse

  Default k To 1, r1 To T_ROW
  Do Case
  Case k == 1
    Private t_arr := _arr, __pr1 := r1
    If !( _arr[ US_LEFT ] == 0 .and. _arr[ US_RIGHT ] == MaxCol() )
      c1 := _arr[ US_LEFT ]
      len_browse := _arr[ US_RIGHT ] - _arr[ US_LEFT ]
      c2 := c1 + len_browse
      If c2 > MaxCol() -2
        c2 := MaxCol() -2
        c1 := c2 - len_browse
      Endif
      If c1 < 0
        c1 := 0
      Endif
      t_arr[ US_LEFT ] := c1
      t_arr[ US_RIGHT ] := c2
    Endif
    VALDEFAULT t_arr[ US_ADD_MENU ],'A' TO {}
    VALDEFAULT t_arr[ US_SEMAPHORE ],'С' To ''
    VALDEFAULT t_arr[ US_BLK_DEL ],'B' TO {|| .t. }
    VALDEFAULT t_arr[ US_TITUL ],'C' To t_arr[ US_IM_PADEG ]
    VALDEFAULT t_arr[ US_TITUL_COLOR ], 'C' To 'B/BG'
    If ValType( t_arr[ US_TITUL ] ) == 'C' .and. Len( t_arr[ US_TITUL ] ) > 1
      t_arr[ US_TITUL ] := Upper( Left( t_arr[ US_TITUL ], 1 ) ) + SubStr( t_arr[ US_TITUL ], 2 )
    Endif
    //
    mas_pmt := { '~Редактирование' }
    mas_msg := { 'Редактирование справочника ' + t_arr[ US_ROD_PADEG ] }
    mas_fun := { 'edit_u_spr(11)' }
    // if !(type('tip_polzovat') == 'N')
    // Private tip_polzovat := 0
    // endif

    // if valtype(t_arr[US_BLK_DUBL]) == 'B' .and. tip_polzovat == 0  // для администратора
    If ValType( t_arr[ US_BLK_DUBL ] ) == 'B' .and. hb_user_curUser:isadmin()  // для администратора
      AAdd( mas_pmt, '~Удаление дубликатов' )
      AAdd( mas_msg, 'Удаление дубликатов из справочника ' + t_arr[ US_ROD_PADEG ] )
      AAdd( mas_fun, 'edit_u_spr(12)' )
    Endif
    For k := 1 To Len( t_arr[ US_ADD_MENU ] )
      AAdd( mas_pmt, t_arr[ US_ADD_MENU, k, 1 ] )
      AAdd( mas_msg, t_arr[ US_ADD_MENU, k, 2 ] )
      AAdd( mas_fun, t_arr[ US_ADD_MENU, k, 3 ] )
    Next
    If !Empty( t_arr[ US_SEMAPHORE ] )
      If !g_slock( t_arr[ US_SEMAPHORE ] )
        Return func_error( 4, 'Сейчас с данным режимом работает другой пользователь!' )
      Endif
    Endif
    If Len( mas_pmt ) == 1
      edit_u_spr( 11 )
    Else
      If __pr1 > 11
        __pr1 := __pr1 - Len( mas_pmt ) -3
      Endif
      popup_prompt( __pr1, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
    Endif
    If !Empty( t_arr[ US_SEMAPHORE ] )
      g_sunlock( t_arr[ US_SEMAPHORE ] )
    Endif
  Case k == 11
    If ValType( t_arr[ US_COLUMN ] ) == 'A'
      Private arr2[ BR_LEN ]
      Default t_arr[ US_TOP ] To __pr1, ;
        t_arr[ US_ARR_BROWSE ] TO { '═', '░', '═', , .t. }
      arr2[ BR_TOP ]    := t_arr[ US_TOP ]
      arr2[ BR_BOTTOM ] := t_arr[ US_BOTTOM ]
      arr2[ BR_LEFT ]   := t_arr[ US_LEFT ]
      arr2[ BR_RIGHT ]  := t_arr[ US_RIGHT ]
      arr2[ BR_OPEN ]   := {| nk, ob| f1_e_u_spr( nk, ob, 'open', t_arr[ US_BLK_INDEX ] ) }
      arr2[ BR_CLOSE ]  := {|| dbCloseAll() }
      arr2[ BR_COLOR ]       := t_arr[ US_COLOR ]
      arr2[ BR_TITUL ]       := t_arr[ US_TITUL ]
      arr2[ BR_TITUL_COLOR ] := t_arr[ US_TITUL_COLOR ]
      arr2[ BR_FL_INDEX ]    := t_arr[ US_FL_INDEX ]
      arr2[ BR_COLUMN ]      := t_arr[ US_COLUMN ]
      arr2[ BR_ARR_BROWSE ]  := t_arr[ US_ARR_BROWSE ]
      arr2[ BR_EDIT ]        := {| nk, ob| f1_e_u_spr( nk, ob, 'edit' ) }
      edit_browse( arr2 )
    Else
      popup_edit( t_arr[ US_BASE ], __pr1, T_COL -5, 22, , , , 'fdel_u_spr', , , , , , ;
        t_arr[ US_TITUL ], t_arr[ US_TITUL_COLOR ] )
    Endif
  Case k == 12
    del_d_u_spr()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

//
Function f1_e_u_spr( nKey, oBrow, regim, blk_index )

  Local ret := -1, __pole_kod, _len_pole_kod, f_dostup
  Local buf, fl := .f., rec, i, j, k := 19, tmp_color

  Do Case
  Case regim == 'open'
    g_use( t_arr[ US_BASE ], , '__US' )
    If blk_index == NIL
      Index On Upper( name ) To tmp___us
    Else
      Eval( blk_index )
    Endif
    If t_arr[ US_BLK_FILTER ] != NIL
      Eval( t_arr[ US_BLK_FILTER ] )  // блок кода фильтрации БД
    Endif
    Go Top
    ret := !Eof()
  Case regim == 'edit'
    If nKey == K_INS
      If ( __pole_kod := ( FieldNum( 'KOD' ) > 0 ) )
        _len_pole_kod := FieldSize( FieldNum( 'KOD' ) )
      Endif
      i := 0
      If __pole_kod // для БД с полем KOD
        i := Int( Val( Replicate( '9', _len_pole_kod ) ) )
      Elseif Type( 'max_dop_rec' ) == 'N'
        i := max_dop_rec
      Endif
      If i > 0
        rec := RecNo()
        If t_arr[ US_BLK_FILTER ] != NIL
          Set Filter To
        Endif
        j := 0
        dbEval( {|| ++j } )
        If t_arr[ US_BLK_FILTER ] != NIL
          Eval( t_arr[ US_BLK_FILTER ] )  // блок кода фильтрации БД
        Endif
        Goto ( rec )
        If j >= i
          func_error( 4, 'Количество записей достигло ' + lstr( i ) + '. Добавление запрещено!' )
          Return ret
        Endif
      Endif
    Endif
    Do Case
    Case nKey == K_INS .or. nKey == K_ENTER
      rec := RecNo()
      Private gl_area := { 1, 0, 23, pc2, 0 }
      Save Screen To buf
      If nkey == K_INS .and. !fl_found
        ColorWin( pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N' )
      Endif
      For i := 1 To Len( t_arr[ US_EDIT_SPR ] )
        --k
        tmp1 := t_arr[ US_EDIT_SPR, i, A__NAME ]
        tmp := 'm' + tmp1
        Private &tmp
        If nKey == K_ENTER
          &tmp := __us->&tmp1
        Else
          &tmp := t_arr[ US_EDIT_SPR, i, A__INIT ]
        Endif
        If ( tmp2 := is_element( t_arr[ US_EDIT_SPR, i ], A__FIND ) ) != NIL
          tmp1 := 'm1' + tmp1
          Private &tmp1 := &tmp
          &tmp := Eval( tmp2, &tmp )
        Endif
      Next
      tmp_color := SetColor( cDataCScr )
      box_shadow( k, t_arr[ US_LEFT ], 22, t_arr[ US_RIGHT ], , ;
        if( nKey == K_INS, 'Добавление', 'Редактирование' ), cDataPgDn )
      SetColor( cDataCGet )
      shirina := t_arr[ US_RIGHT ] - t_arr[ US_LEFT ]
      Do While .t.
        old_set := __SetCentury( 'on' )
        For i := 1 To Len( t_arr[ US_EDIT_SPR ] )
          tmp := 'm' + t_arr[ US_EDIT_SPR, i, A__NAME ]
          tmp1 := shirina -3 - Len( t_arr[ US_EDIT_SPR, i, A__SAY ] )
          If t_arr[ US_EDIT_SPR, i, A__PICTURE ] == NIL
            If Type( tmp ) == 'C'
              mpic := if( Len( &tmp ) > tmp1, '@S' + lstr( tmp1 ), '' )
            Elseif t_arr[ US_EDIT_SPR, i, A__TYPE ] == 'N'
              mpic := Replicate( '9', t_arr[ US_EDIT_SPR, i, A__LEN ] )
              If t_arr[ US_EDIT_SPR, i, A__DEC ] > 0
                mpic := Stuff( mpic, Len( mpic ) - t_arr[ US_EDIT_SPR, i, A__DEC ], 1, '.' )
              Endif
            Else
              mpic := ''
            Endif
          Elseif Type( tmp ) == 'C' .and. Len( &tmp ) > tmp1
            mpic := t_arr[ US_EDIT_SPR, i, A__PICTURE ] + '@S' + lstr( tmp1 )
          Else
            mpic := t_arr[ US_EDIT_SPR, i, A__PICTURE ]
          Endif
          @ k + 1 + i, t_arr[ US_LEFT ] + 2 Say t_arr[ US_EDIT_SPR, i, A__SAY ] ;
            get &tmp Picture mpic
          GetList[ i ]:reader := t_arr[ US_EDIT_SPR, i, A__BLOCK ]
          GetList[ i ]:preBlock := is_element( t_arr[ US_EDIT_SPR, i ], A__WHEN )
          GetList[ i ]:postBlock := is_element( t_arr[ US_EDIT_SPR, i ], A__VALID )
        Next
        status_key( '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода' )
        myread()
        __SetCentury( old_set )
        If LastKey() != K_ESC .and. f_esc_enter( 1 )
          If Empty( mname )
            func_error( 4, 'Введена не вся информация!' )
            Loop
          Endif
          Select __US
          f_dostup := .t.
          If nKey == K_INS
            If t_arr[ US_BLK_FILTER ] != NIL
              Set Filter To
            Endif
            f_dostup := addrecn()
            If t_arr[ US_BLK_FILTER ] != NIL
              Eval( t_arr[ US_BLK_FILTER ] )  // блок кода фильтрации БД
            Endif
          Endif
          If f_dostup
            If nKey == K_INS
              fl_found := .t.
              rec := RecNo()
              If FieldNum( 'kod' ) > 0
                Replace kod With rec
              Endif
              If t_arr[ US_BLK_WRITE ] != NIL
                Eval( t_arr[ US_BLK_WRITE ] )  // запись других полей
              Endif
            Else
              g_rlock( forever )
            Endif
            For i := 1 To Len( t_arr[ US_EDIT_SPR ] )
              tmp1 := t_arr[ US_EDIT_SPR, i, A__NAME ]
              tmp := 'm' + tmp1
              If is_element( t_arr[ US_EDIT_SPR, i ], A__FIND ) != NIL
                tmp2 := 'm1' + tmp1
                replace &tmp1 with &tmp2
              Else
                replace &tmp1 with &tmp
              Endif
            Next
            Unlock
            Commit
          Endif
          oBrow:gotop()
          Goto ( rec )
          ret := 0
        Elseif nKey == K_INS .and. !fl_found
          ret := 1
        Endif
        Exit
      Enddo
      Select __US
      SetColor( tmp_color )
      Restore Screen From buf
    Case nKey == K_DEL
      If fdel_u_spr( __us->( RecNo() ) ) .and. f_esc_enter( 2 )
        deleterec()
        Go Top
        oBrow:gotop()
        ret := 0
        If Eof()
          ret := 1
        Endif
      Endif
    Endcase
  Endcase

  Return ret

//
Function fdel_u_spr( mkod )

  Local fl, buf := save_maxrow(), tmp_select := Select()

  stat_msg( 'Производится проверка на наличие данной строки в других базах данных.' )
  fl := Eval( t_arr[ US_BLK_DEL ], mkod )  // возврат .t., если можно удалять
  If !fl
    func_error( 4, 'Данная строка присутствует в других базах данных. Удаление запрещено!' )
  Endif
  If tmp_select > 0
    Select ( tmp_select )
  Endif
  rest_box( buf )

  Return fl

//
Static Function input_u_spr( r, c )

  Static sk
  Local k

  k := popup_edit( t_arr[ US_BASE ], r, c, 22, sk, PE_RETURN, , , , , , , , ;
    t_arr[ US_TITUL ], t_arr[ US_TITUL_COLOR ] )

  If k != NIL
    sk := k[ 1 ]
    k[ 2 ] := AllTrim( k[ 2 ] )
  Endif

  Return k

//
Static Function del_d_u_spr()

  Local buf := SaveScreen(), s1, s2, k1, k2

  If !Empty( t_arr[ US_SEMAPHORE ] )
    If g_scount( sem_task() ) > 1
      Return func_error( 'В данный момент УДАЛЕНИЕ ДУБЛИКАТА запрещено. Работает другая задача.' )
    Endif
    g_slock( sem_vagno() )
  Endif
  n_message( { 'Данный режим предназначен для удаления одной строки', ;
    '"' + t_arr[ US_ROD_PADEG ] + '" и переноса всей', ;
    'относящейся к ней информации другой строке' }, , ;
    cColorStMsg, cColorStMsg, , , cColorSt2Msg )
  f_message( { 'Выберите удаляемую строку' }, , color1, color8, 0 )
  If ( k1 := input_u_spr( __pr1, T_COL -7 ) ) != NIL
    s1 := k1[ 2 ]
    RestScreen( buf )
    f_message( { 'Выберите строку, на которую переносится информация', ;
      'от <.. ' + s1 + ' ..>' }, , ;
      color1, color8, 0 )
    If ( k2 := input_u_spr( __pr1, T_COL -7 ) ) != NIL
      RestScreen( buf )
      If k1[ 1 ] == k2[ 1 ]
        func_error( 4, 'Два раза выбрано одно и то же значение ' + t_arr[ US_IM_PADEG ] )
      Else
        RestScreen( buf )
        s2 := k2[ 2 ]
        f_message( { 'Удаляемая строка:', ;
          '"' + s1 + '".', ;
          'Вся информация переносится в строку:', ;
          '"' + s2 + '".' },, ;
          color1, color8 )
        If f_esc_enter( 'удаления', .t. )
          mywait()
          Eval( t_arr[ US_BLK_DUBL ], k1[ 1 ], k2[ 1 ] )
          //
          g_use( t_arr[ US_BASE ] )
          Goto ( k1[ 1 ] )
          deleterec( .t. )
          Close databases
          stat_msg( 'Операция завершена!' )
          music_m( 'OK' )
          Inkey( 2 )
        Endif
      Endif
    Endif
  Endif
  RestScreen( buf )
  If !Empty( t_arr[ US_SEMAPHORE ] )
    g_sunlock( sem_vagno() )
  Endif

  Return .t.
