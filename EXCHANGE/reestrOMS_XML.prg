// реестры/счета с 2019 года
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// 20.11.25
Function create1reestr19( _recno, _nyear, _nmonth, p_tip_reestr )

  Local buf := SaveScreen(), i, j, pole
  local lenPZ := 0  // кол-во строк план заказа на год составления реестра
  local reg_sort

  Private mpz, oldpz, atip

  lenPZ := len( p_array_PZ )

  mpz := Array( lenPZ + 1 )
  oldpz := Array( lenPZ + 1 )
  atip := Array( lenPZ + 1 )

  For j := 0 To lenPZ    // для таблицы _moXunit 03.02.23
    pole := 'tmp->PZ' + lstr( j )
    mpz[ j + 1 ] := oldpz[ j + 1 ] := &pole
    atip[ j + 1 ] := '-'
    If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j } ) ) > 0
      atip[ j + 1 ] := p_array_PZ[ i, 4 ]
    Endif
  Next

  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma
  private p_blk := {| mkol, msum| f_blk_create1reestr19() }

  dbCloseAll()
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Use ( cur_dir() + 'tmpb' ) New Alias TMP
  Set Relation To FIELD->kod_human into HUMAN
  Index On Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' ) For FIELD->kod_tmp == _recno
  Go Top
  Eval( p_blk )
  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestr19', color0, ;
      'Составление реестра случаев за ' + mm_month()[ _nmonth ] + Str( _nyear, 5 ) + ' года', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestr19', , ;
      { '═', '░', '═', 'N/BG, W+/N, B/BG, W+/B', , 300 } )
    If pkol > 0 .and. ( reg_sort := f_alert( { '', ;
        'Каким образом сортировать реестр, отправляемый в ТФОМС', ;
        '' }, ;
        { ' по ~ФИО пациента ', ' по ~убыванию стоимости ' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6, , 'BG+/RB, W+/R, W+/RB, GR+/R' ) ) > 0
      f_message( { 'Системная дата: ' + date_month( sys_date, .t. ), ;
        'Обращаем Ваше внимание, что', ;
        'реестр будет создан с этой датой.', ;
        '', ;
        'Изменить её будет НЕВОЗМОЖНО!', ;
        '', ;
        'Сортировка реестра: ' + { 'по ФИО пациента', 'по убыванию стоимости лечения' }[ reg_sort ] }, , ;
        'GR+/R', 'W+/R' )
      If f_esc_enter( 'составления реестра' )
        RestScreen( buf )
        create2reestr19( _recno, _nyear, _nmonth, reg_sort, p_tip_reestr )
      Endif
    Endif
  Endif
  dbCloseAll()
  RestScreen( buf )
  Return Nil

// 03.01.26
Function f_blk_create1reestr19()  // 

  Local i, s, ta[ 2 ], sh := MaxCol() + 1

  s := 'Случаев - ' + expand_value( pkol ) + ' на сумму ' + expand_value( psumma, 2 ) + ' руб.'
  @ 0, 0 Say PadC( s, sh ) Color color1
  s := ''
  For i := 1 To Len( mpz )
    If !Empty( mpz[ i ] )
      s += AllTrim( str_0( mpz[ i ], 9, 2 ) ) + ' ' + atip[ i ] + ', '
    Endif
  Next
  If !Empty( s )
    s := '(п/з: ' + SubStr( s, 1, Len( s ) -2 ) + ')'
  Endif
  perenos( ta, s, sh )
  For i := 1 To 2
    @ i, 0 Say PadC( AllTrim( ta[ i ] ), sh ) Color color1
  Next
  Return Nil

// 19.01.20
Function f_p_z19( _pzkol, _pz, k )

  Local s, s2, i

  s2 := AllTrim( str_0( _pzkol, 9, 2 ) )
  s := atip[ _pz + 1 ]
  If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == _pz } ) ) > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
    s2 += p_array_PZ[ i, 5 ]
  Endif
  Return iif( k == 1, s, s2 )

// 11.12.25
Function f1create1reestr19( oBrow )

  Local oColumn, tmp_color, blk_color := {|| if( tmp->plus, { 1, 2 }, { 3, 4 } ) }, n := 32

  oColumn := TBColumnNew( ' ', {|| if( tmp->plus, '', ' ' ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( 'Ф.И.О. больного', n ), {|| iif( tmp->ishod == 89, PadR( Upper( human->fio ), n -4 ) + ' 2сл', PadR( Upper( human->fio ), n ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'План-заказ', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 1 ), 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Кол-во', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 2 ), 6 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Нача-; ло', {|| Left( DToC( tmp->n_data ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( 'Окончан.;лечения', {|| date_8( tmp->k_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' Стоимость; лечения', {|| put_kope( tmp->cena_1, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  tmp_color := SetColor( 'N/BG' )
  @ MaxRow() -3, 0 Say PadR( ' <Esc> - выход     <Enter> - подтверждение составления реестра', 80 )
  @ MaxRow() -2, 0 Say PadR( ' <Ins> - отметить одного пациента или снять отметку с одного пациента', 80 )
  @ MaxRow() -1, 0 Say PadR( ' <+> - отметить всех пациентов (или по одному виду ПЛАНА-ЗАКАЗА) ', 80 )
  @ MaxRow() -0, 0 Say PadR( ' <-> - снять со всех отметки (никто не попадает в реестр)', 80 )
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<+>', '<->', '<F9>' }, 'R/BG' )
  SetColor( tmp_color )
  Return Nil

// 19.01.20
Function f2create1reestr19( nKey, oBrow )

  Local buf, rec, k := -1, i, j, mas_pmt := {}, arr, r1, r2

  Do Case
  Case nkey == K_INS
    Replace tmp->plus With !tmp->plus
    j := tmp->pz + 1
    i := AScan( p_array_PZ, {| x| x[ 1 ] == tmp->PZ } )
    If tmp->plus
      psumma += tmp->cena_1
      pkol++
      If i > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
        mpz[ j ] ++
      Else
        mpz[ j ] += tmp->PZKOL
      Endif
    Else
      psumma -= tmp->cena_1
      pkol--
      If i > 0 .and. !Empty( p_array_PZ[ i, 5 ] )
        mpz[ j ] --
      Else
        mpz[ j ] -= tmp->PZKOL
      Endif
    Endif
    Eval( p_blk )
    k := 0
    Keyboard Chr( K_TAB )
  Case nkey == 43  // +
    arr := {}
    AAdd( mas_pmt, 'Отметить всех пациентов' )
    AAdd( arr, -1 )
    If !Empty( oldpz[ 1 ] )
      AAdd( mas_pmt, 'Отметить неопределённых пациентов' )
      AAdd( arr, 0 )
    Endif
    For j := 2 To Len( oldpz )
      If !Empty( oldpz[ j ] ) .and. ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j -1 } ) ) > 0
        AAdd( mas_pmt, 'Отметить "' + p_array_PZ[ i, 3 ] + '"' )
        AAdd( arr, j -1 )
      Endif
    Next
    r1 := 12
    r2 := r1 + Len( mas_pmt ) + 1
    If r2 > MaxRow() -2
      r2 := MaxRow() -2
      r1 := r2 - Len( mas_pmt ) -1
      If r1 < 2
        r1 := 2
      Endif
    Endif
    If ( j := popup_scr( r1, 12, r2, 67, mas_pmt, 1, color5, .t. ) ) > 0
      j := arr[ j ]
      rec := RecNo()
      buf := save_maxrow()
      mywait()
      If j == -1
        tmp->( dbEval( {|| tmp->plus := .t. } ) )
        psumma := old_summa
        pkol := old_kol
        AEval( mpz, {| x, i| mpz[ i ] := oldpz[ i ] } )
      Else
        psumma := pkol := 0
        AFill( mpz, 0 )
        mpz[ j + 1 ] := oldpz[ j + 1 ]
        Go Top
        Do While !Eof()
          If tmp->pz == j
            tmp->plus := .t.
            psumma += tmp->cena_1
            pkol++
          Else
            tmp->plus := .f.
          Endif
          Skip
        Enddo
      Endif
      Goto ( rec )
      rest_box( buf )
      Eval( p_blk )
      k := 0
    Endif
  Case nkey == 45  // -
    rec := RecNo()
    buf := save_maxrow()
    mywait()
    tmp->( dbEval( {|| tmp->plus := .f. } ) )
    Goto ( rec )
    rest_box( buf )
    psumma := pkol := 0
    AFill( mpz, 0 )
    Eval( p_blk )
    k := 0
  Endcase
  Return k
