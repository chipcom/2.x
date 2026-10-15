#include 'function.ch'
#include 'inkey.ch'
#include 'chip_color.ch'

// 12.10.26 вывести окно с сообщением и ожидание нажатия <Esc> или <Enter>
Function f_esc_enter( j, fl )

  Local buf, i := 0, s := '', s1, s2, r1, r2, c1, c2, tmp_color := SetColor(), ;
    tmp_mas := { 'записи', 'удаления', 'исправления' }

  Default fl To .f.
  r1 := MaxRow() - 4
  r2 := r1 + 3
  c1 := 8
  c2 := MaxCol() - 8
  buf := box_shadow( r1, c1, r2, c2, CCOLORTEXT )
  SetColor( CCOLORTEXT )
  If ValType( j ) == 'N' .and. Between( j, 1, Len( tmp_mas ) )
    s := ' ' + tmp_mas[ j ]
  Elseif ValType( j ) == 'C'
    s := ' ' + AllTrim( j )
  Endif
  s1 := 'Для подтверждения' + s + ' нажмите <Enter>'
  s2 := '<Esc> - отказ от' + s
  str_center( r1 + 1, s1 )
  str_center( r1 + 2, s2 )
  If fl
    For j := 1 To 5
      Keyboard ''     // на всякий случай
      Inkey( 0.1 )      // для особо ответственных операций
    Next
  Else
    Keyboard ''
  Endif
  SetCursor( 0 )
  Do While !( i == K_ENTER .or. i == K_ESC )
    i := Inkey( 0 )
  Enddo
/*
  If fl .and. Type( 'p_f_Esc_Enter' ) == 'L' .and. p_f_Esc_Enter
    box_shadow( r1, c1, r2, c2, CCOLORST2MSG )
    SetColor( CCOLORSTMSG )
    s1 := 'Для подтверждения' + s + ' нажмите <Ctrl+F12>'
    s2 := '<Esc> - отказ от' + s
    str_center( r1 + 1, s1 )
    str_center( r1 + 2, s2 )
    j := 0
    Do While !( j == K_CTRL_F12 .or. j == K_ESC )
      j := Inkey( 0 )
    Enddo
    If j == K_CTRL_F12
      i := K_ENTER
    Else
      i := K_ESC
    Endif
  Endif
*/
  SetColor( tmp_color )
  rest_box( buf )

  Return ( i == K_ENTER )

// 12.10.26
Function str_center( nline, cmsg, mcolor )  //  , DELAY_SPRD )

  // DELAY_SPRD - время задержки для разворачивания строк

  Local mdelay := 6, tmp_color := SetColor( mcolor )

//  Default DELAY_SPRD To 0

  If Type( 'DELAY_SPRD' ) == 'N'   // если определена переменная 'DELAY_SPRD',
    mdelay := DELAY_SPRD         // установить новое время задержки
  Endif                          // при развертывании строки
  If mdelay == 0
    @ nline, ( MaxCol() + 1 - Len( cmsg ) ) / 2 + 1 Say cmsg
  Else
    SaySpread( cmsg, mdelay, nline )
  Endif
  SetColor( tmp_color )

  Return Nil
