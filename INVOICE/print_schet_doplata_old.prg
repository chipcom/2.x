#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// ��ᬮ�� � ����� �믨ᠭ��� ��⮢/॥��஢ �� �������
Function print_schet_doplata( reg )

  // reg = 1 - ������ �����
  // reg = 2 - ������ �����
  Local arr_title, arr1title, sh, HH := 57, n_file := cur_dir + 'schetd' + stxt, ;
    s, i, j, j1, a_shifr[ 10 ], k1, k2, k3, lshifr, v_doplata, rec, ;
    buf := save_maxrow(), t_arr[ 2 ], llpu, lbank, ssumma := 0, ;
    fl_numeration, is_20_11, sdate := SToD( '20121120' ) // 20.11.2012�.

  If schet_->NREGISTR == 0 // ��ॣ����஢���� ���
    is_20_11 := ( date_reg_schet() >= sdate )
  Else
    is_20_11 := ( schet_->DSCHET > SToD( '20121210' ) ) // 10.12.2012�.
  Endif
  s1 := iif( reg == 2, Space( 11 ), '� ᮯ����. ' )
  s2 := iif( reg == 2, Space( 11 ), '��������   ' )
  arr_title := { ;
    '��������������������������������������������������������������������������������', ;
    '�   �� ��� �� ��� �� ���客�������    ����       ����        ������� ��    ', ;
    '�����               ����� �    ���� ��������祭- ��᭮�����  ������� ��㣥 ', ;
    '樨 �               ���� �� �������     �����      ���������   ��� �।��    ', ;
    '॥�               �            �        �����    �' + s1 +     '���� ' + iif( reg == 2, '����� ', '����� ' ), ;
    '�� �               �            �        �          �' + s2 +     '�(�㡫��)      ', ;
    '��������������������������������������������������������������������������������', ;
    ' 1  �       2       �      3     �   4    �    5     �     6     �       7      ', ;
    '��������������������������������������������������������������������������������' }
  arr1title := { ;
    '��������������������������������������������������������������������������������', ;
    ' 1  �       2       �      3     �   4    �    5     �     6     �       7      ', ;
    '��������������������������������������������������������������������������������' }
  //
  use_base( 'lusl' )
  use_base( 'lusld' )
  use_base( 'luslf' )
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To u_kod into USL
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + 'organiz', , 'ORG' )
  r_use( dir_server + 'schetd', , 'SD' )
  Index On Str( kod, 6 ) to ( cur_dir + 'tmp_sd' )
  //
  sh := Len( arr_title[ 1 ] )
  fp := FCreate( n_file )
  n_list := 1
  tek_stroke := 0
  add_string( Center( '��� � ' + AllTrim( schet_->nschet ) + ' �� ' + full_date( schet_->dschet ) + ' �.', sh ) )
  s := '�� ������ ����樭᪮� ����� �� ��� �।�� ��� ' + iif( reg == 2, '����ࠫ쭮��', '�����ਠ�쭮��' ) + ' 䮭�� '
  s += '��易⥫쭮�� ����樭᪮�� ���客���� ' + iif( reg == 2, '', '������ࠤ᪮� ������ ' ) + '�� �ணࠬ�� ����୨��樨 ��ࠢ���࠭���� '
  s += '������ࠤ᪮� ������ �� 2011-2012 ���� � ��� ॠ����樨 ��ய��⨩ �� '
  s += '���⠯���� ����७�� �⠭���⮢ ����樭᪮� �����'
  For k := 1 To perenos( t_arr, s, sh )
    add_string( Center( AllTrim( t_arr[ k ] ), sh ) )
  Next
  add_string( '' )
  sinn := org->inn
  skpp := ''
  If '/' $ sinn
    skpp := AfterAtNum( '/', sinn )
    sinn := BeforAtNum( '/', sinn )
  Endif
  sname    := org->name
  sbank    := org->bank
  sr_schet := org->r_schet
  sbik     := org->smfo
  If reg == 2
    If !Empty( org->r_schet2 )
      sbank    := org->bank2
      sr_schet := org->r_schet2
      sbik     := org->smfo2
    Endif
    If !Empty( org->name2 )
      sname := org->name2
    Endif
  Endif
  k := perenos( t_arr, sname, sh -11 )
  add_string( '���⠢騪: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 11 ) + t_arr[ 2 ] )
  Next
  add_string( '���: ' + PadR( sinn, 12 ) + ', ���: ' + skpp )
  add_string( '����: ' + RTrim( org->adres ) )
  k := perenos( t_arr, sbank, sh -17 )
  add_string( '���� ���⠢騪�: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 17 ) + t_arr[ 2 ] )
  Next
  add_string( '������ ���: ' + AllTrim( sr_schet ) + ', ���: ' + AllTrim( sbik ) )
  add_string( '' )
  add_string( '' )
  If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) == 0
    j := Len( get_rekv_smo() ) // �᫨ �� ��諨 - ���⠥� ४������ �����
  Endif
  k := perenos( t_arr, get_rekv_smo()[ j, 2 ], sh -12 )
  add_string( '���⥫�騪: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 12 ) + t_arr[ 2 ] )
  Next
  add_string( '���: ' + get_rekv_smo()[ j, 3 ] + ', ���: ' + get_rekv_smo()[ j, 4 ] )
  k := perenos( t_arr, get_rekv_smo()[ j, 6 ], sh -7 )
  add_string( '����: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 7 ) + t_arr[ 2 ] )
  Next
  k := perenos( t_arr, get_rekv_smo()[ j, 7 ], sh -18 )
  add_string( '���� ���⥫�騪�: ' + t_arr[ 1 ] )
  For i := 2 To k
    add_string( Space( 18 ) + t_arr[ 2 ] )
  Next
  add_string( '������ ���: ' + AllTrim( get_rekv_smo()[ j, 8 ] ) + ', ���: ' + AllTrim( get_rekv_smo()[ j, 9 ] ) )
  add_string( '' )
  add_string( '' )
  add_string( Center( '������ ��� � ' + AllTrim( schet_->nschet ) + ' �� ' + full_date( schet_->dschet ) + ' �.', sh ) )
  add_string( '' )
  AEval( arr_title, {| x| add_string( x ) } )
  Select SCHET
  fl_numeration := emptyany( schet_->nyear, schet_->nmonth )
  rec := RecNo()
  Set Index To
  j := 0
  Select SD
  find ( Str( rec, 6 ) )
  Do While sd->kod == rec .and. !Eof()
    schet->( dbGoto( sd->kod2 ) )
    j1 := 0
    Select HUMAN
    find ( Str( sd->kod2, 6 ) )
    Do While human->schet == sd->kod2 .and. !Eof()
      lshifr := ''
      v_doplata := r_doplata := 0
      ret_zak_sl( @lshifr, @v_doplata, @r_doplata, , , iif( is_20_11, sdate, nil ) )
      If iif( reg == 1, !Empty( r_doplata ), .t. )
        a_diag := diag_for_xml(, .t., , , .t. )
        s_diag := a_diag[ 1 ]
        If reg == 1 .and. Len( a_diag ) > 1 .and. !Empty( a_diag[ 2 ] )
          s_diag += ' ' + a_diag[ 2 ]
        Endif
        s := PadR( lstr( ++j ), 5 ) + ;
          PadC( AllTrim( schet_->nschet ), 15 ) + ' ' + ;
          PadR( Str( iif( fl_numeration, ++j1, human_->SCHET_ZAP ), 7 ), 13 ) + ;
          date_8( schet_->dschet ) + ' ' + ;
          PadC( lshifr, 10 ) + ;
          PadC( AllTrim( s_diag ), 13 ) + ;
          Str( iif( reg == 2, v_doplata, r_doplata ), 11, 2 )
        ssumma += iif( reg == 2, v_doplata, r_doplata )
        If verify_ff( HH, .t., sh )
          AEval( arr1title, {| x| add_string( x ) } )
        Endif
        add_string( s )
      Endif
      //
      Select HUMAN
      Skip
    Enddo
    Select SD
    Skip
  Enddo
  If verify_ff( HH -8, .t., sh )
    AEval( arr1title, {| x| add_string( x ) } )
  Endif
  add_string( Replicate( '�', sh ) )
  add_string( PadL( '�ᥣ�: ' + lstr( ssumma, 14, 2 ), sh -3 ) )
  add_string( '' )
  k := perenos( t_arr, '� �����: ' + srub_kop( ssumma, .t. ), sh )
  add_string( t_arr[ 1 ] )
  For j := 2 To k
    add_string( PadL( AllTrim( t_arr[ j ] ), sh ) )
  Next
  add_string( '' )
  add_string( '  ������ ��� ����樭᪮� �࣠����樨      _____________ / ' + AllTrim( org->ruk ) + ' /' )
  add_string( '  ������ ��壠��� ����樭᪮� �࣠����樨 _____________ / ' + AllTrim( org->bux ) + ' /' )
  add_string( '                                        �.�.' )
  FClose( fp )

  rest_box( buf )
  close_use_base( 'lusl' )
  lusld->( dbCloseArea() )
  close_use_base( 'luslf' )
  usl->( dbCloseArea() )
  hu->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  org->( dbCloseArea() )
  sd->( dbCloseArea() )
  If Select( 'USL1' ) > 0
    usl1->( dbCloseArea() )
  Endif
  Select SCHET
  If !( Round( ssumma, 2 ) == Round( schet->summa, 2 ) )
    // �᫨ ����� ������ 業��� - ��१���襬 �㬬� ����
    Goto ( rec )
    g_rlock( forever )
    schet->summa := schet->summa_ost := ssumma
    Unlock
    Commit
  Endif
  Set Index to ( cur_dir + 'tmp_sch' )
  Goto ( rec )
  viewtext( n_file, , , , .t., , , 2 )

  Return Nil

