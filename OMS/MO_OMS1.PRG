// mo_oms1.prg - ०��� ����� ������ ��� ����� ��� (�த�������)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// 28.09.18 �������� ��� 㤠���� ��⠫쬮���� � ���ᨢ ��� ��ᮢ��襭����⭨� ��� 12 ����楢
Function np_oftal_2_85_21( _period, _k_data )

  Static lshifr := '2.85.21'
  Local i

  If _period == 13 // 12 ����楢 � 1 ᥭ����
    i := AScan( np_arr_1_etap[ _period, 4 ], lshifr )
    If _k_data > 0d20180831 // � 1 ᥭ����
      If i == 0
        ins_array( np_arr_1_etap[ _period, 4 ], 4, lshifr ) // �������� ��� ����� 4-� ������⮬
      Endif
    Else
      If i > 0
        del_array( np_arr_1_etap[ _period, 4 ], i )
      Endif
    Endif
  Endif

  Return Nil

// 19.03.19 ������ ��� ��㣨 �����祭���� ���� ��� ��
Function ret_shifr_zs_pn( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( is_neonat, '72.2.37', '72.2.38' ) // 0 ����楢
  Case _period == 2
    lshifr := '72.2.39' // 1 �����
  Case _period == 3
    lshifr := iif( m1lis > 0, '72.2.41', '72.2.40' ) // 2 ���
  Case _period == 4
    lshifr := '72.2.43' // 3 �����
  Case eq_any( _period, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15 )
    lshifr := '72.2.42' // 4���, 5���, 6���, 7���, 8���, 9���, 10���, 11���, 1���3���, 1���6���
  Case _period == 13
    If AScan( np_arr_1_etap[ _period, 4 ], '2.85.21' ) > 0  // �᫨ ���� ��⠫쬮���
      lshifr := iif( m1lis > 0, '72.2.65', '72.2.64' ) // 12 ����楢 � 1 ᥭ����
    Else
      lshifr := iif( m1lis > 0, '72.2.45', '72.2.44' ) // 12 ����楢
    Endif
  Case _period == 16
    lshifr := '72.2.46' // 2 ����
  Case _period == 17
    lshifr := iif( m1lis > 0, '72.2.48', '72.2.47' ) // 3 ����
  Case eq_any( _period, 18, 19, 22, 23, 25, 26 )
    lshifr := '72.2.49' // 4 ����, 5 ���, 8 ���, 9 ���, 11 ���, 12���
  Case _period == 20
    lshifr := iif( m1lis > 0, '72.2.51', '72.2.50' ) // 6 ���
  Case _period == 21
    lshifr := iif( m1lis > 0, '72.2.53', '72.2.52' ) // 7 ���
  Case _period == 24
    lshifr := iif( m1lis > 0, '72.2.55', '72.2.54' ) // 10 ���
  Case _period == 27
    lshifr := '72.2.56' // 13 ���
  Case _period == 28
    lshifr := '72.2.57' // 14 ���
  Case _period == 29
    lshifr := iif( m1lis > 0, '72.2.59', '72.2.58' ) // 15 ���
  Case _period == 30
    lshifr := iif( m1lis > 0, '72.2.61', '72.2.60' ) // 16 ���
  Case _period == 31
    lshifr := iif( m1lis > 0, '72.2.63', '72.2.62' ) // 17 ���
  Endcase

  Return lshifr

// 28.01.18
Function add_pediatr_pn( _pv, _pa, _date, _diag )

  Local arr[ 10 ]

  AFill( arr, 0 )
  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // ��䨫�
  arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.85.15', '2.85.14' ) // ��� ��㣨
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 28.01.18 ������ �����⭮� ��ਮ� ��� ��䨫��⨪� ��ᮢ��襭����⭨�
Function ret_period_pn( ldate_r, ln_data, lk_data, /*@*/ls, /*@*/ret_i)

  Local i, _m, _d, _y, _m2, _d2, _y2, lperiod, sm, sm_, sm1, sm2, yn_data, yk_data

  Store 0 To _m, _d, _y, _m2, _d2, _y2, lperiod
  yn_data := Year( ln_data )
  yk_data := Year( lk_data )
  ls := ''
  count_ymd( ldate_r, ln_data, @_y, @_m, @_d ) // ॠ��� ������ �� ��砫�
  count_ymd( ldate_r, lk_data, @_y2, @_m2, @_d2 ) // ॠ��� ������ �� ����砭��
  ret_i := 31
  For i := Len( np_arr_1_etap ) To 1 Step -1
    If i > 17 // 4 ���� � ����
      If mdvozrast == np_arr_1_etap[ i, 2, 1 ]
        ret_i := lperiod := i
        ls := ' (' + lstr( mdvozrast ) + ' ' + s_let( mdvozrast ) + ')'
        If yn_data != yk_data
          lperiod := 0
          ls := '�訡��! ��砫� � ����砭�� ��䨫��⨪� ������ ���� � ����� �������୮� ����'
        Endif
        Exit
      Endif
    Elseif mdvozrast < 4 // �� 3 ��� (�����⥫쭮)
      sm1 := Round( Val( lstr( np_arr_1_etap[ i, 2, 1 ] ) + '.' + StrZero( np_arr_1_etap[ i, 2, 2 ], 2 ) ), 4 )
      sm2 := Round( Val( lstr( np_arr_1_etap[ i, 3, 1 ] ) + '.' + StrZero( np_arr_1_etap[ i, 3, 2 ], 2 ) ), 4 )
      sm := Round( Val( lstr( _y ) + '.' + StrZero( _m, 2 ) + StrZero( _d, 2 ) ), 4 )
      sm_ := Round( Val( lstr( _y2 ) + '.' + StrZero( _m2, 2 ) + StrZero( _d2, 2 ) ), 4 )
      If sm1 <= sm
        ret_i := i
        If sm_ <= sm2
          lperiod := i
          If lperiod == 1 // ����஦�����
            ls := '(����஦�����)'
            If _m2 == 1 .or. _d2 > 29
              lperiod := 0
              ls := '�訡��! ����஦������� ������ ���� �� ����� 29 ����'
            Endif
            Exit
          Elseif lperiod == 16 // 2 ����
            ls := ' (2 ����)'
            If mdvozrast > 2
              lperiod := 0
              ls := '�訡��! ����� � ' + lstr( yn_data ) + ' �������୮� ���� 㦥 �ᯮ������ 3 ����'
            Endif
            Exit
          Elseif lperiod == 17 // 3 ����
            ls := ' (3 ����)'
            Exit
          Endif
          ls := ' ('
          If np_arr_1_etap[ i, 2, 1 ] > 0
            ls += lstr( np_arr_1_etap[ i, 2, 1 ] ) + ' ' + s_let( np_arr_1_etap[ i, 2, 1 ] ) + ' '
          Endif
          If np_arr_1_etap[ i, 2, 2 ] > 0
            ls += lstr( np_arr_1_etap[ i, 2, 2 ] ) + ' ' + mes_cev( np_arr_1_etap[ i, 2, 2 ] )
          Endif
          ls := RTrim( ls ) + ')'
        Else
          ls := '������ ���� ��ਮ� ' + ;
            iif( np_arr_1_etap[ i, 2, 1 ] == 0, '', lstr( np_arr_1_etap[ i, 2, 1 ] ) + '�.' ) + ;
            iif( np_arr_1_etap[ i, 2, 2 ] == 0, '', lstr( np_arr_1_etap[ i, 2, 2 ] ) + '���.' ) + '-' + ;
            iif( np_arr_1_etap[ i, 3, 1 ] == 0, '', lstr( np_arr_1_etap[ i, 3, 1 ] ) + '�.' ) + ;
            iif( np_arr_1_etap[ i, 3, 2 ] == 0, '', lstr( np_arr_1_etap[ i, 3, 2 ] ) + '���.' ) + ', � � ��� ' + ;
            iif( _y == 0, '', lstr( _y ) + '�.' ) + ;
            iif( _m == 0, '', lstr( _m ) + '���.' ) + ;
            iif( _d == 0, '', lstr( _d ) + '��.' ) + '-' + ;
            iif( _y2 == 0, '', lstr( _y2 ) + '�.' ) + ;
            iif( _m2 == 0, '', lstr( _m2 ) + '���.' ) + ;
            iif( _d2 == 0, '', lstr( _d2 ) + '��.' )
        Endif
        Exit
      Endif
    Endif
  Next

  Return lperiod

// 04.02.16 ������ ��� ��㣨 �����祭���� ���� ��� �।�
Function ret_shifr_zs_predn( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( m1lis == 1, '72.3.5', '72.3.1' )// '�����祭�� ��砩 �।���⥫쭮�� �ᬮ�� ��ᮢ��襭����⭨� �� ����㯫���� � ��� 1 �⠯'
  Case _period == 2
    lshifr := iif( m1lis == 1, '72.3.6', '72.3.2' )// '�����祭�� ��砩 �।���⥫쭮�� �ᬮ�� ��ᮢ��襭����⭨� �� ����㯫���� � ��� 1 �⠯'
  Case _period == 3
    lshifr := iif( m1lis == 1, '72.3.7', '72.3.3' )// '�����祭�� ��砩 �।���⥫쭮�� �ᬮ�� ��ᮢ��襭����⭨� �� ����㯫���� � �� ���, ���, ���, �� ��� ��⥩-��� �� 0 �� 14 ��� 1 �⠯'
  Case _period == 4
    lshifr := iif( m1lis == 1, '72.3.8', '72.3.4' )// '�����祭�� ��砩 �।���⥫쭮�� �ᬮ�� ��ᮢ��襭����⭨� �� ����㯫���� � �� ���, ���, ���, �� ��� ��⥩-��� � 15 ��� 1 �⠯'
  Endcase

  Return lshifr

// 14.08.13
Function add_pediatr_predn( _pv, _pa, _date, _diag )

  Local arr[ 9 ]

  AFill( arr, 0 )

  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // ��䨫�
  arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.86.15', '2.86.14' ) // ��� ��㣨
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 25.08.13 ������ ��� ��㣨 �����祭���� ���� ��� ����
Function ret_shifr_zs_pern( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( m1lis == 1, '72.4.3', '72.4.1' ) // '�����祭�� ��砩 ��ਮ���᪮�� �ᬮ�� ��ᮢ��襭����⭨�, ��������� � ���
  Case _period == 2
    lshifr := iif( m1lis == 1, '72.4.4', '72.4.2' ) // '�����祭�� ��砩 ��ਮ���᪮�� �ᬮ�� ��ᮢ��襭����⭨�, ��������� � ���, �� ���, ���, ���, �� ��� ��⥩-���
  Endcase

  Return lshifr

// 25.08.13
Function add_pediatr_pern( _pv, _pa, _date, _diag )

  Local arr[ 9 ]

  AFill( arr,  0 )
  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // ��䨫�
  // arr[5] := iif(eq_any(arr[2], 1110,-16), '2.3.2', '2.3.1') // ��� ��㣨
  arr[ 5 ] := '2.3.2' // ��� ��㣨
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 04.01.25 ������ ⨯ ��������� ���� ����
Function ret_tip_lu( /*@*/stip)

  Local k := 0, tmp_select

  stip := '   '
  If Between( human->ishod, 101, 102 )
    k := iif( !Empty( human->ZA_SMO ), TIP_LU_DDS, TIP_LU_DDSOP )
    If human->ishod == 101
//      stip := iif( !Empty( human->ZA_SMO ), '��1', '��1' )
      stip := iif( !Empty( human->ZA_SMO ), '��1', '��2' )   // ���쬮 ����� 09-20-674 �� 19.12.24
    Else // 102
//      stip := iif( !Empty( human->ZA_SMO ), '��2', '��2' )
      stip := iif( !Empty( human->ZA_SMO ), '��3', '��4' )   // ���쬮 ����� 09-20-674 �� 19.12.24
    Endif
  Elseif Between( human->ishod, 201, 205 )
    k := TIP_LU_DVN
    If human->ishod == 201
      if human->k_data < 0d20250101
        stip := '��1'
      else
        stip := '��4'   // ���쬮 ����� 09-20-674 �� 19.12.24
      endif
    Elseif eq_any( human->ishod, 202, 205 )
      stip := '��2'
    Elseif human->ishod == 204
      stip := '��3'
    Else // 203
      stip := '���'
    Endif
  Elseif Between( human->ishod, 301, 302 )
    k := TIP_LU_PN
    If human->ishod == 301
//      stip := '��1'
      stip := '��1'   // ���쬮 ����� 09-20-674 �� 19.12.24
    Else // 302
//      stip := '��2'
      stip := '��2'   // ���쬮 ����� 09-20-674 �� 19.12.24
    Endif
  Elseif Between( human->ishod, 303, 304 )
    k := TIP_LU_PREDN
    If human->ishod == 303
      stip := '��1'
    Else // 304
      stip := '��2'
    Endif
  Elseif human->ishod == 305
    k := TIP_LU_PERN
    stip := '���'
  // Elseif Between( human->ishod, 401, 402 )  // �� 㣫㡫����� ��ᯠ��ਧ�樨 ��᫥ COVID
  Elseif is_sluch_dispanser_COVID( human->ishod )  // �� 㣫㡫����� ��ᯠ��ਧ�樨 ��᫥ COVID
    k := TIP_LU_DVN_COVID
    If human->ishod == 401
      stip := '��1'             // ��� 1-�� �⠯�
    Else // 402
      stip := '��2'             // ��� 2-�� �⠯�
    Endif
  // Elseif Between( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 )  // �� ��ᯠ��ਧ�樨 ९த�⨢���� ���஢��
  Elseif is_sluch_dispanser_DRZ( human->ishod )  // �� ��ᯠ��ਧ�樨 ९த�⨢���� ���஢��
    k := TIP_LU_DRZ
    If human->ishod == BASE_ISHOD_RZD + 1
      stip := '��1'             // ��� 1-�� �⠯�
    Else // 502
      stip := '��2'             // ��� 2-�� �⠯�
    Endif
  Elseif human->ishod == 98
    k := TIP_LU_G_CIT
  Elseif human->ishod == 99
    k := TIP_LU_PREND
  Endif

  If k == 0
    tmp_select := Select()
    r_use( dir_server() + 'mo_otd', , '__OTD' )
    __otd->( dbGoto( glob_otd[ 1 ] ) )
    k := __otd->TIPLU
    __otd->( dbCloseArea() )
    If tmp_select > 0
      Select( tmp_select )
    Endif
  Endif

  Return k

// 06.11.19 �ࠢ����� ��䨫�� � ���⮬ ��������� �ࠢ�� � 2014 ����
Function f_profil_ginek_otolar( lp1, lp2 )

  Static arr_ginek := { 2, 136 } // �������� � �����������
  Static arr_otolar := { 64, 162 } // �⮫�ਭ�������
  Local i, fl := .f.

  If ValType( lp1 ) == 'N'
    lp1 := { lp1 }
  Endif
  For i := 1 To Len( lp1 )
    If lp1[ i ] == lp2
      fl := .t.
    Elseif AScan( arr_ginek, lp1[ i ] ) > 0
      fl := ( AScan( arr_ginek, lp2 ) > 0 )
    Elseif AScan( arr_otolar, lp1[ i ] ) > 0
      fl := ( AScan( arr_otolar, lp2 ) > 0 )
    Endif
    If fl
      Exit
    Endif
  Next i

  Return fl
