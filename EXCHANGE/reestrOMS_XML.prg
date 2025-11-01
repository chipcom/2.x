// ॥����/��� � 2019 ����
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// Static sadiag1

// 17.10.25
Function create1reestr19( _recno, _nyear, _nmonth, p_tip_reestr )

  Local buf := SaveScreen(), s, i, j, pole
  local lenPZ := 0  // ���-�� ��ப ���� ������ �� ��� ��⠢����� ॥���
  local reg_sort

  Private mpz, oldpz, atip

  lenPZ := len( p_array_PZ )

  mpz := Array( lenPZ + 1 )
  oldpz := Array( lenPZ + 1 )
  atip := Array( lenPZ + 1 )

  For j := 0 To lenPZ    // ��� ⠡���� _moXunit 03.02.23
    pole := 'tmp->PZ' + lstr( j )
    mpz[ j + 1 ] := oldpz[ j + 1 ] := &pole
    atip[ j + 1 ] := '-'
    If ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j } ) ) > 0
      atip[ j + 1 ] := p_array_PZ[ i, 4 ]
    Endif
  Next

  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma, p_blk := {| mkol, msum| f_blk_create1reestr19( _nyear ) }
  Close databases
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  Use ( cur_dir() + 'tmpb' ) New Alias TMP
  Set Relation To kod_human into HUMAN
  Index On Upper( human->fio ) + DToS( tmp->k_data ) to ( cur_dir() + 'tmpb' ) For kod_tmp == _recno
  Go Top
  Eval( p_blk )
  If alpha_browse( 3, 0, MaxRow() -4, 79, 'f1create1reestr19', color0, ;
      '���⠢����� ॥��� ��砥� �� ' + mm_month[ _nmonth ] + Str( _nyear, 5 ) + ' ����', 'BG+/GR', ;
      .t., .t., , , 'f2create1reestr19', , ;
      { '�', '�', '�', 'N/BG, W+/N, B/BG, W+/B', , 300 } )
    If pkol > 0 .and. ( reg_sort := f_alert( { '', ;
        '����� ��ࠧ�� ���஢��� ॥���, ��ࠢ�塞� � �����', ;
        '' }, ;
        { ' �� ~��� ��樥�� ', ' �� ~�뢠��� �⮨���� ' }, ;
        1, 'W/RB', 'G+/RB', MaxRow() -6, , 'BG+/RB, W+/R, W+/RB, GR+/R' ) ) > 0
      f_message( { '���⥬��� ���: ' + date_month( sys_date, .t. ), ;
        '���頥� ��� ��������, ��', ;
        '॥��� �㤥� ᮧ��� � �⮩ ��⮩.', ;
        '', ;
        '�������� �� �㤥� ����������!', ;
        '', ;
        '����஢�� ॥���: ' + { '�� ��� ��樥��', '�� �뢠��� �⮨���� ��祭��' }[ reg_sort ] }, , ;
        'GR+/R', 'W+/R' )
      If f_esc_enter( '��⠢����� ॥���' )
        RestScreen( buf )
        create2reestr19( _recno, _nyear, _nmonth, reg_sort, p_tip_reestr )
      Endif
    Endif
  Endif
  Close databases
  RestScreen( buf )
  Return Nil

// 21.05.17
Function f_blk_create1reestr19( _nyear )

  Local i, s, ta[ 2 ], sh := MaxCol() + 1

  s := '���砥� - ' + expand_value( pkol ) + ' �� �㬬� ' + expand_value( psumma, 2 ) + ' ��.'
  @ 0, 0 Say PadC( s, sh ) Color color1
  s := ''
  For i := 1 To Len( mpz )
    If !Empty( mpz[ i ] )
      s += AllTrim( str_0( mpz[ i ], 9, 2 ) ) + ' ' + atip[ i ] + ', '
    Endif
  Next
  If !Empty( s )
    s := '(�/�: ' + SubStr( s, 1, Len( s ) -2 ) + ')'
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

// 06.02.19
Function f1create1reestr19( oBrow )

  Local oColumn, tmp_color, blk_color := {|| if( tmp->plus, { 1, 2 }, { 3, 4 } ) }, n := 32

  oColumn := TBColumnNew( ' ', {|| if( tmp->plus, '', ' ' ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( Center( '�.�.�. ���쭮��', n ), {|| iif( tmp->ishod == 89, PadR( human->fio, n -4 ) + ' 2�', PadR( human->fio, n ) ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '����-�����', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 1 ), 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '���-��', {|| PadC( f_p_z19( tmp->pzkol, tmp->pz, 2 ), 6 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '���-; ��', {|| Left( DToC( tmp->n_data ), 5 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( '����砭.;��祭��', {|| date_8( tmp->k_data ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  oColumn := TBColumnNew( ' �⮨�����; ��祭��', {|| put_kope( tmp->cena_1, 10 ) } )
  oColumn:colorBlock := blk_color
  oBrow:addcolumn( oColumn )
  tmp_color := SetColor( 'N/BG' )
  @ MaxRow() -3, 0 Say PadR( ' <Esc> - ��室     <Enter> - ���⢥ত���� ��⠢����� ॥���', 80 )
  @ MaxRow() -2, 0 Say PadR( ' <Ins> - �⬥��� ������ ��樥�� ��� ���� �⬥�� � ������ ��樥��', 80 )
  @ MaxRow() -1, 0 Say PadR( ' <+> - �⬥��� ��� ��樥�⮢ (��� �� ������ ���� �����-������) ', 80 )
  @ MaxRow() -0, 0 Say PadR( ' <-> - ���� � ��� �⬥⪨ (���� �� �������� � ॥���)', 80 )
  mark_keys( { '<Esc>', '<Enter>', '<Ins>', '<+>', '<->', '<F9>' }, 'R/BG' )
  SetColor( tmp_color )
  Return Nil

// 19.01.20
Function f2create1reestr19( nKey, oBrow )

  Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2

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
    AAdd( mas_pmt, '�⬥��� ��� ��樥�⮢' )
    AAdd( arr, -1 )
    If !Empty( oldpz[ 1 ] )
      AAdd( mas_pmt, '�⬥��� ����।����� ��樥�⮢' )
      AAdd( arr, 0 )
    Endif
    For j := 2 To Len( oldpz )
      If !Empty( oldpz[ j ] ) .and. ( i := AScan( p_array_PZ, {| x| x[ 1 ] == j -1 } ) ) > 0
        AAdd( mas_pmt, '�⬥��� "' + p_array_PZ[ i, 3 ] + '"' )
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
