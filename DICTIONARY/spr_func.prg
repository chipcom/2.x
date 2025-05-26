// различные функции используемые в справочниках - spr_func.prg
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 07.12.22 в GET'е выбрать значение из TMP_V015.DBF (глобального массива) с поиском по подстроке
Function fget_tmp_v015( k, r, c, a_spec )

  Local ret, fl, kolRec, nRec, tmp_select := Select(), s, blk, t_arr[ BR_LEN ]

  Use ( cur_dir() + 'tmp_v015' ) index ( cur_dir() + 'tmpsV015' ), ( cur_dir() + 'tmpkV015' ) New Alias tmp_ga
  kolRec := LastRec()
  If r <= MaxRow() / 2
    t_arr[ BR_TOP ] := r + 1
    If ( t_arr[ BR_BOTTOM ] := t_arr[ BR_TOP ] + kolRec + 3 ) > MaxRow() -2
      t_arr[ BR_BOTTOM ] := MaxRow() -2
    Endif
  Else
    t_arr[ BR_BOTTOM ] := r -1
    If ( t_arr[ BR_TOP ] := t_arr[ BR_BOTTOM ] - kolRec -3 ) < 1
      t_arr[ BR_TOP ] := 1
    Endif
  Endif
  If ValType( a_spec ) == 'A'
    blk := {|| iif( tmp_ga->isn == 1, { 1, 2 }, { 3, 4 } ) }
    If !Empty( a_spec )
      Go Top
      Do While !Eof()
        If AScan( a_spec, Int( Val( tmp_ga->kod ) ) ) > 0
          tmp_ga->isn := 1
        Endif
        Skip
      Enddo
    Endif
  Else
    blk := {|| iif( tmp_ga->vs == 'врач', { 1, 2 }, { 3, 4 } ) }
  Endif
  t_arr[ BR_LEFT ] := 2
  t_arr[ BR_RIGHT ] := 77
  t_arr[ BR_COLOR ] := color0
  t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', .f. }
  t_arr[ BR_COLUMN ] := { ;
    { 'Код', {|| tmp_ga->kod }, blk }, ;
    { Center( 'Медицинская специальность', 40 ), {|| PadR( f1get_tmp_v015(), 40 ) }, blk }, ;
    { ' ', {|| tmp_ga->vs }, blk }, ;
    { Center( 'подчинение', 21 ), {|| Left( tmp_ga->name_up, 21 ) }, blk } ;
    }
  t_arr[ BR_EDIT ] := {| nk, ob| f1get_tmp_ga( nk, ob, 'edit', a_spec ) }
  If ValType( a_spec ) == 'A'
    ins_array( t_arr[ BR_COLUMN ], 1, { ' ', {|| iif( tmp_ga->isn == 1, '', ' ' ) }, blk } )
    t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Ins>^ - отметить специальность;  ^<F2>^ - поиск по подстроке' ) }
  Else
    t_arr[ BR_ENTER ] := {|| iif( tmp_ga->uroven == 0, ( func_error( 4, 'Запрещается выбирать данную специальность' ), ret := nil ), ;
      ( ret := { tmp_ga->kod, AllTrim( tmp_ga->name ) } ) ) }
    t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - выбор;  ^<F2>^ - поиск по подстроке' ) }
  Endif
  fl := .f.
  nRec := 0
  If !( ValType( a_spec ) == 'A' ) .and. k != NIL
    Set Order To 2
    find ( k )
    If ( fl := Found() )
      nRec := RecNo()
    Endif
    Set Order To 1
  Endif
  If !fl
    nRec := 0
  Endif
  Go Top
  If nRec > 0
    If kolRec - nRec < t_arr[ BR_BOTTOM ] - t_arr[ BR_TOP ] -3 // последняя страница?
      Keyboard Chr( K_END ) + Replicate( Chr( K_UP ), kolRec - nRec -1 )
    Else
      Goto ( nRec )
    Endif
  Endif
  edit_browse( t_arr )
  If ValType( a_spec ) == 'A'
    s := ''
    ASize( a_spec, 0 )
    Go Top
    Do While !Eof()
      If tmp_ga->isn == 1
        s += AllTrim( tmp_ga->kod ) + ','
        AAdd( a_spec, Int( Val( tmp_ga->kod ) ) )
        tmp_ga->isn := 0
      Endif
      Skip
    Enddo
    If Empty( s )
      s := '---'
    Else
      s := Left( s, Len( s ) -1 )
    Endif
    ret := { 1, s }
  Endif
  tmp_ga->( dbCloseArea() )
  Select ( tmp_select )
  Return ret

// 07.08.16
Function f1get_tmp_v015()

  Local s := AfterAtNum( '.', tmp_ga->name, 1 )

  s := Space( 2 * tmp_ga->uroven ) + s
  Return s
