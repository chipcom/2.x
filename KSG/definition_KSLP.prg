#include 'function.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

// 27.02.21
Function buildstringkslp( row )

  // row - �������� ���ᨢ ����뢠�騩 ����
  Local ret

  ret := Str( row[ CODE_KSLP ], 2 ) + '.' + row[ NAME_KSLP ]

  Return ret

// 15.02.25 �㭪�� �롮� ��⠢� ����, �����頥� { ��᪠,��ப� ������⢠ ���� }, ��� nil
Function selectkslp( lkslp, savedKSLP, dateBegin, dateEnd, DOB, mdiagnoz )

  // lkslp - ���祭�� ���� (��࠭�� ����)
  // savedKSLP - ��࠭����� � HUMAN_2 ���� ��� ����
  // dateBegin - ��� ��砫� �����祭���� ����
  // dateEnd - ��� ����砭�� �����祭���� ����
  // DOB - ��� ஦����� ��樥��
  // mdiagnoz - ᯨ᮪ ��࠭��� ���������

  Local mlen, t_mas := {}, ret, ;
    i, tmp_select := Select()
  Local r1 := 0 // ���稪 ����ᥩ
  Local strArr := '', age

  Local m1var := '', s := '', countKSLP := 0
  Local row
  Local nLast, srok := dateEnd - dateBegin
  Local permissibleKSLP := {}, isPermissible
  Local sAsterisk := ' * ', sBlank := '   '
  Local fl := .f.

  Local aKSLP := getkslptable( dateEnd )  // ᯨ᮪ �����⨬�� ���� ��� ��㣨
  Local aa := list2arr( savedKSLP ) // ����稬 ���ᨢ ��࠭��� ����

  Default DOB To sys_date
  Default dateBegin To sys_date
  Default dateEnd To sys_date

  permissibleKSLP := list2arr( lkslp )

  age := count_years( DOB, dateEnd )

  For Each row in aKSLP
    r1++

    isPermissible := AScan( permissibleKSLP, row[ CODE_KSLP ] ) > 0

    If ( AScan( aa, {| x| x == row[ CODE_KSLP ] } ) > 0 ) .and. isPermissible
      strArr := sAsterisk
    Else
      strArr := sBlank
    Endif
    If ( row[ CODE_KSLP ] == 3 .and. Year( dateEnd ) == 2023 ) ;    // ���� 75 ���
      .or. ( row[ CODE_KSLP ] == 3 .and. Year( dateEnd ) == 2022 ) ;
        .or. ( row[ CODE_KSLP ] == 1 .and. Year( dateEnd ) == 2021 )
      If ( age >= 75 ) .and. ( Year( dateEnd ) == 2021 ) .and. isPermissible
        strArr := sAsterisk
        strArr += buildstringkslp( row )
      Elseif ( age >= 75 ) .and. ( Year( dateEnd ) == 2022 ) .and. isPermissible
        strArr += buildstringkslp( row )
      Else
        strArr := sBlank
        strArr += buildstringkslp( row )
      Endif
      AAdd( t_mas, { strArr, ( age >= 75 ), row[ CODE_KSLP ] } )
    Elseif ( ( row[ CODE_KSLP ] == 1 .and. Year( dateEnd ) == 2023 ) .or. ;
        ( row[ CODE_KSLP ] == 2 .and. Year( dateEnd ) == 2023 ) .or. ;
        ( row[ CODE_KSLP ] == 1 .and. Year( dateEnd ) == 2022 ) .or. ;
        ( row[ CODE_KSLP ] == 2 .and. Year( dateEnd ) == 2022 ) .or. ;
        ( row[ CODE_KSLP ] == 3 .and. Year( dateEnd ) == 2021 ) ) ;
        .and. isPermissible  // ���� ��������� �।�⠢�⥫�
      If ( age < 4 )
        strArr := sAsterisk
        strArr += buildstringkslp( row )
      Elseif ( age < 18 )
        strArr += buildstringkslp( row )
      Else
        strArr := sBlank
        strArr += buildstringkslp( row )
      Endif
      AAdd( t_mas, { strArr, ( age < 18 ), row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 4 .and. Year( dateEnd ) == 2021 ) .and. isPermissible  // ���㭨���� ���
      If ( age < 18 )
        strArr += buildstringkslp( row )
      Else
        strArr := sBlank
        strArr += buildstringkslp( row )
      Endif
      AAdd( t_mas, { strArr, ( age < 18 ), row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 9 .and. Year( dateEnd ) == 2021 ) // ���� ᮯ������騥 �����������
      fl := conditionkslp_9_21(, DToC( DOB ), DToC( dateBegin ),,,, arr2slistn( mdiagnoz ), )
      If !fl
        strArr := sBlank
      Else
        // strArr := sAsterisk
      Endif
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, fl, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 10 .and. Year( dateEnd ) == 2021 ) .and. isPermissible // ��祭�� ��� 70 ���� ᮣ��᭮ ������樨
      strArr := iif( srok > 70, sAsterisk, sBlank )
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, .f., row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 19 .and. Year( dateEnd ) == 2023 ) .and. isPermissible  // �஢������ 1 �⠯� ����樭᪮� ॠ�����樨 ��樥�⮢
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 20 .and. Year( dateEnd ) == 2023 ) .and. isPermissible   // �஢������ ᮯ஢���⥫쭮� ������⢥���� �࠯��
      // �� �������⢥���� ������ࠧ������� � ������ �
      // ��樮����� �᫮���� � ᮮ⢥��⢨� � ������᪨�� ४�������ﬨ
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 21 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // ࠧ����뢠��� �������㠫쭮�� ����
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 22 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // ����稥 � ��樥�� �殮��� ᮯ������饩
      // ��⮫����, �ॡ��饩 �������� ����樭᪮�
      // ����� � ��ਮ� ��ᯨ⠫���樨
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 23 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ��⠭��� ���ࣨ�᪨�
      // ����⥫��� ��� �஢������
      // ����⨯��� ����権 �� ����� �࣠��� (�஢��� 1)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 24 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ��⠭��� ���ࣨ�᪨�
      // ����⥫��� ��� �஢������
      // ����⨯��� ����権 �� ����� �࣠��� (�஢��� 2)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 25 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ��⠭��� ���ࣨ�᪨�
      // ����⥫��� ��� �஢������
      // ����⨯��� ����権 �� ����� �࣠��� (�஢��� 3)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 26 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ��⠭��� ���ࣨ�᪨�
      // ����⥫��� ��� �஢������
      // ����⨯��� ����権 �� ����� �࣠��� (�஢��� 4)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 27 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ��⠭��� ���ࣨ�᪨�
      // ����⥫��� ��� �஢������
      // ����⨯��� ����権 �� ����� �࣠��� (�஢��� 5)
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 28 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ᮯ஢���⥫쭮�
      // ������⢥���� �࠯�� �� �������⢥����
      // ������ࠧ������� � ������ � �᫮���� ��������
      // ��樮��� � ᮮ⢥��⢨� � ������᪨�� ४�������ﬨ
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Elseif ( row[ CODE_KSLP ] == 29 .and. Year( dateEnd ) == 2023 .and. dateEnd >= 0d20230501 ) .and. isPermissible   // �஢������ ���஢���� �� ������
      // �ᯨ����� ������� ����������� (�ਯ��,
      // ����� ��஭�����᭮� ��䥪樨 COVID-19) � ��ਮ� ��ᯨ⠫���樨
      strArr := sBlank
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Else
      strArr += buildstringkslp( row )
      AAdd( t_mas, { strArr, isPermissible, row[ CODE_KSLP ] } )
    Endif
  Next

  strStatus := '^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - �⬥��� / ���� �⬥��'

  mlen := Len( t_mas )

  // �ᯮ��㥬 popupN �� ������⥪� FunLib
  If ( ret := popupn( 4, 10, 4 + mlen + 1, 71, t_mas, i, color0, .t., 'fmenu_readerN', , ;
      '�⬥��� ����', col_tit_popup,, strStatus ) ) > 0
    For i := 1 To mlen
      If '*' == SubStr( t_mas[ i, 1 ], 2, 1 )
        m1var += AllTrim( Str( t_mas[ i, 3 ] ) ) + ','
        countKSLP += 1
      Endif
    Next
    If ( nLast := RAt( ',', m1var ) ) > 0
      m1var := SubStr( m1var, 1, nLast -1 )  // 㤠��� ��᫥���� �� �㦭�� ','
    Endif
    s := m1var
  Endif

  Select( tmp_select )

  Return s

// 13.01.22 �᫨ ����, ��१������ ���祭�� ���� � ���� � HUMAN_2
Function put_str_kslp_kiro( arr, fl )

  Local lpc1 := '', lpc2 := ''

  If Len( arr ) > 4 .and. !Empty( arr[ 5 ] )
    If Year( human->k_data ) < 2021  // added 29.01.21
      lpc1 := lstr( arr[ 5, 1 ] ) + ',' + lstr( arr[ 5, 2 ], 5, 2 )
      If Len( arr[ 5 ] ) >= 4
        lpc1 += ',' + lstr( arr[ 5, 3 ] ) + ',' + lstr( arr[ 5, 4 ], 5, 2 )
      Endif
    Endif
  Endif
  If Len( arr ) > 5 .and. !Empty( arr[ 6 ] )
    lpc2 := lstr( arr[ 6, 1 ] ) + ',' + lstr( arr[ 6, 2 ], 5, 2 )
  Endif
  If !( PadR( lpc1, 20 ) == human_2->pc1 .and. PadR( lpc2, 10 ) == human_2->pc2 )
    Default fl To .t. // �����஢��� � ࠧ�����஢��� ������ � HUMAN_2
    Select HUMAN_2
    If fl
      g_rlock( forever )
    Endif

    // �������� ����� ����
    tmSel := Select( 'HUMAN_2' )
    If ( tmSel )->( dbRLock() )
      If Year( human->k_data ) < 2021  // added 29.01.21
        human_2->pc1 := lpc1
      Endif
      human_2->pc2 := lpc2
      ( tmSel )->( dbRUnlock() )
    Endif
    Select( tmSel )
    If fl
      Unlock
    Endif
  Endif

  Return Nil

// 04.02.21 �����頥� �㬬� �⮣����� ���� �� ��᪥ ���� � ��� ����
Function calckslp( cKSLP, dateSl )

  // cKSLP - ��ப� ��࠭��� ����
  // dateSl - ��� �����祭���� ����
  Local summ := 1, i
  Local fl := .f.
  Local arrKSLP := getkslptable( dateSl )
  Local maxKSLP := 1.8  // �� ������樨 �� 21 ���
  Local aSelected := slist2arr( cKSLP )

  For i := 1 To Len( aSelected )
    summ += ( arrKSLP[ Val( aSelected[ i ] ), 4 ] -1 )
  Next
  If summ > maxKSLP
    summ := maxKSLP
  Endif

  Return summ

// 15.02.25 ��।����� ����-� ᫮����� ��祭�� ��樥�� � �������� 業�
Function f_cena_kslp( /*@*/_cena, _lshifr, _date_r, _n_data, _k_data, lkslp, arr_usl, lPROFIL_K, arr_diag, lpar_org, lad_cr, usl_ok )

  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  Static s_20 := 0d20201231
  Static s_kslp17 := { ;
    { 1, 1.1, 0,  3 }, ;   // �� 4 ���
    { 2, 1.1, 75, 999 } ;    // 75 ��� � ����
    }
  Static s_kslp16 := { ;
    { 1, 1.1, 0,  3 }, ;   // �� 4 ���
    { 2, 1.05, 75, 999 } ;    // 75 ��� � ����
    }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  Local countDays := _k_data - _n_data // ���-�� ���� ��祭��

  Local savedKSLP, newKSLP := '', nLast
  Local nameFunc := '', argc, row

  Default lad_cr To Space( 10 )

  _lshifr := AllTrim( _lshifr ) // ��७��

  If _k_data > s_20
    If Empty( lkslp )
      Return _akslp
    Endif
    // �.3 ������樨
    // ������ ��樥�� ��।������ �� ������ ����㯫���� �� ��樮��୮� ��祭��.
    // �� ��砨 �ਬ������ ���� (�� �᪫�祭��� ����1) �����࣠���� �ᯥ�⭮�� ����஫�.
    count_ymd( _date_r, _n_data, @y )
    lkslp := list2arr( lkslp )  // �८�ࠧ㥬 ��ப� �����⨬�� ���� � ���ᨢ

    savedKSLP := iif( Empty( HUMAN_2->PC1 ), '"' + '"', '"' + AllTrim( HUMAN_2->PC1 ) + '"' )  // ����稬 ��࠭���� ����

    argc := '(' + savedKSLP + ',' + ;
      '"' + DToC( _date_r ) + '",' + '"' + DToC( _k_data ) + '",' + ;
      lstr( lPROFIL_K ) + ',' + '"' + _lshifr + '",' + lstr( lpar_org ) + ',' + ;
      '"' + arr2slistn( arr_diag ) + '",' + lstr( countDays ) + ',' + lstr( usl_ok ) + ',"' + ;
      + AllTrim( lad_cr ) + '")'

    For Each row in getkslptable( _k_data )
      nameFunc := 'conditionKSLP_' + AllTrim( Str( row[ 1 ], 2 ) ) + '_' + last_digits_year( _k_data )
      nameFunc := namefunc + argc

      If AScan( lkslp, row[ 1 ] ) > 0 .and. &nameFunc
        newKSLP += AllTrim( Str( row[ 1 ], 2 ) ) + ','
        AAdd( _akslp, row[ 1 ] )
        AAdd( _akslp, row[ 4 ] )
      Endif
    Next
    If ( nLast := RAt( ',', newKSLP ) ) > 0
      newKSLP := SubStr( newKSLP, 1, nLast -1 )  // 㤠��� ��᫥���� �� �㦭�� ','
    Endif
    // ��⠭���� 業� � ��⮬ ����
    If !Empty( _akslp )

      If Year( _k_data ) == 2021
        _cena := round_5( _cena * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )  // � 2019 ���� 業� ���㣫���� �� �㡫��
      Elseif Year( _k_data ) >= 2022
        _cena := round_5( _cena + baserate( _k_data, human_->USL_OK ) * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )
//      Elseif Year( _k_data ) == 2023  // ᮮ�騫 �맣�� 01.02.23
//        _cena := round_5( _cena + baserate( _k_data, human_->USL_OK ) * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )
//      Elseif Year( _k_data ) == 2024
//        _cena := round_5( _cena + baserate( _k_data, human_->USL_OK ) * ret_koef_kslp_21( _akslp, Year( _k_data ) ), 0 )
      Endif

      If Year( _k_data ) >= 2021
        // �������� ����� ����
        tmSel := Select( 'HUMAN_2' )
        If ( tmSel )->( dbRLock() )
          If Year( human->k_data ) < 2021  // added 29.01.21
            human_2->pc1 := newKSLP
          Endif
          ( tmSel )->( dbRUnlock() )
        Endif
        Select( tmSel )
      Endif
    Endif

  Elseif _k_data > s_19  // � 2019 ����
    If !Empty( lkslp )
      If _lshifr == 'ds02.005' // ���, lkslp = 12,13,14
        s_kslp := { ;
          { 12, 0.60 }, ;
          { 13, 1.10 }, ;
          { 14, 0.19 } ;
          }
        For i := 1 To Len( arr_usl )
          If ValType( arr_usl[ i ] ) == 'A'
            AAdd( ausl, AllTrim( arr_usl[ i, 1 ] ) )  // ���ᨢ ���������
          Else
            AAdd( ausl, AllTrim( arr_usl[ i ] ) )    // ���ᨢ ��������
          Endif
        Next i
        j := 0 // ���� - 1 �奬�
        If AScan( ausl, 'A11.20.031' ) > 0  // �ਮ
          j := 13  // 6 �奬�
          If AScan( ausl, 'A11.20.028' ) > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          Endif
        Elseif AScan( ausl, 'A11.20.025.001' ) > 0  // ���� �⠯
          j := 12  // 3 �奬�
          If AScan( ausl, 'A11.20.036' ) > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          Elseif AScan( ausl, 'A11.20.028' ) > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          Endif
        Elseif AScan( ausl, 'A11.20.030.001' ) > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        Endif
        If ( i := AScan( s_kslp, {| x| x[ 1 ] == j } ) ) > 0
          AAdd( _akslp, s_kslp[ i, 1 ] )
          AAdd( _akslp, s_kslp[ i, 2 ] )
          _cena := round_5( _cena * s_kslp[ i, 2 ], 0 )  // � 2019 ���� 業� ���㣫���� �� �㡫��
        Endif
        If !Empty( _akslp ) .and. _k_data > 0d20191231 // � 2020 ����
          _akslp[ 1 ] += 3 // �.�. � 2020 ���� ���� ��� ��� 15,16,17
        Endif
      Else // ��⠫�� ���
        s_kslp := { ;
          { 1, 1.10, 0,  0 }, ;  // �� 1 ����
          { 2, 1.10, 1,  3 }, ;  // �� 1 �� 3 ��� �����⥫쭮
          { 4, 1.02, 75, 999 }, ;  // 75 � ����
          { 5, 1.10, 60, 999 } ;   // 60 � ���� � ��⥭��
        }
        count_ymd( _date_r, _n_data, @y )
        lkslp := list2arr( lkslp )
        For j := 1 To Len( lkslp )
          If ( i := AScan( s_kslp, {| x| x[ 1 ] == lkslp[ j ] } ) ) > 0 // �⮨� ����� ���� � ��࠭��� ���
            If Between( y, s_kslp[ i, 3 ], s_kslp[ i, 4 ] )
              fl := .t.
              If lkslp[ j ] == 4
                fl := ( lprofil_k != 16 ; // ��樥�� ����� �� �� ��஭⮫����᪮� �����
                .and. !( _lshifr == 'st38.001' ) )
              Elseif lkslp[ j ] == 5
                sop_diag := AClone( arr_diag )
                del_array( sop_diag, 1 )
                fl := ( lprofil_k == 16 .and. ; // ��樥�� ����� �� ��஭⮫����᪮� �����
                !( _lshifr == 'st38.001' ) .and. ;// !(alltrim(arr_diag[1]) == 'R54') .and. ; // � �᭮��� ��������� �� <R54-������>
                AScan( sop_diag, {| x| AllTrim( x ) == 'R54' } ) > 0 ) // � ᮯ.��������� ���� <R54-������>
              Endif
              If fl
                AAdd( _akslp, s_kslp[ i, 1 ] )
                AAdd( _akslp, s_kslp[ i, 2 ] )
                Exit
              Endif
            Endif
          Endif
        Next
        If AScan( lkslp, 11 ) > 0 .and. lpar_org > 1 // ࠧ�襭� ����=11 � ������� ���� �࣠��
          AAdd( _akslp, 11 )
          AAdd( _akslp, 1.2 )
        Endif
        If AScan( lkslp, 18 ) > 0 .and. 'cr6' $ lad_cr // ࠧ�襭� ����=18 � ��� ᫮����� COVID-19
          AAdd( _akslp, 18 )
          AAdd( _akslp, 1.2 )
        Endif
        If !Empty( _akslp )
          _cena := round_5( _cena * ret_koef_kslp( _akslp ), 0 )  // � 2019 ���� 業� ���㣫���� �� �㡫��
        Endif
      Endif
    Endif
  Elseif _k_data > s_18  // � 2018 ����
    If !Empty( lkslp )
      If _lshifr == '2005.0' // ���, lkslp = 12,13,14
        s_kslp := { ;
          { 12, 0.60 }, ;
          { 13, 1.10 }, ;
          { 14, 0.19 } ;
          }
        For i := 1 To Len( arr_usl )
          If ValType( arr_usl[ i ] ) == 'A'
            AAdd( ausl, AllTrim( arr_usl[ i, 1 ] ) )  // ���ᨢ ���������
          Else
            AAdd( ausl, AllTrim( arr_usl[ i ] ) )    // ���ᨢ ��������
          Endif
        Next i
        j := 0 // ���� - 1 �奬�
        If AScan( ausl, 'A11.20.031' ) > 0  // �ਮ
          j := 13  // 6 �奬�
          If AScan( ausl, 'A11.20.028' ) > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          Endif
        Elseif AScan( ausl, 'A11.20.025.001' ) > 0  // ���� �⠯
          j := 12  // 3 �奬�
          If AScan( ausl, 'A11.20.036' ) > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          Elseif AScan( ausl, 'A11.20.028' ) > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          Endif
        Elseif AScan( ausl, 'A11.20.030.001' ) > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        Endif
        If ( i := AScan( s_kslp, {| x| x[ 1 ] == j } ) ) > 0
          AAdd( _akslp, s_kslp[ i, 1 ] )
          AAdd( _akslp, s_kslp[ i, 2 ] )
          _cena := round_5( _cena * s_kslp[ i, 2 ], 1 )
        Endif
      Else // ��⠫�� ���
        s_kslp := { ;
          { 1, 1.10, 0,  0 }, ;  // �� 1 ����
          { 2, 1.10, 1,  3 }, ;  // �� 1 �� 3 ��� �����⥫쭮
          { 4, 1.05, 75, 999 }, ;  // 75 � ����
          { 5, 1.10, 60, 999 } ;   // 60 � ���� � ��⥭��
        }
        count_ymd( _date_r, _n_data, @y )
        lkslp := list2arr( lkslp )
        For j := 1 To Len( lkslp )
          If ( i := AScan( s_kslp, {| x| x[ 1 ] == lkslp[ j ] } ) ) > 0
            If Between( i, 1, 5 ) .and. Between( y, s_kslp[ i, 3 ], s_kslp[ i, 4 ] )
              AAdd( _akslp, s_kslp[ i, 1 ] )
              AAdd( _akslp, s_kslp[ i, 2 ] )
              _cena := round_5( _cena * s_kslp[ i, 2 ], 1 )
              Exit
            Endif
          Endif
        Next
      Endif
    Endif
  Elseif _k_data > s_1_may ;                 // � 1 ��� 2016 ����
      .and. Left( _lshifr, 1 ) == '1' ; // ��㣫������ ��樮���
      .and. !( '.' $ _lshifr )         // �� ��� ���
    count_ymd( _date_r, _n_data, @y )
    vksg := Int( Val( Right( _lshifr, 3 ) ) ) // ��᫥���� �� ���� - ��� ���
    If ( fl := vksg < 900 ) // �� ������
      If Year( _k_data ) > 2016
        s_kslp := s_kslp17
        If y < 1 .and. Between( vksg, 105, 111 ) // �� 1 ���� � ����� ���� �� ஦�����
          fl := .f.
        Endif
      Else
        s_kslp := s_kslp16
      Endif
      If fl
        For i := 1 To Len( s_kslp )
          If Between( y, s_kslp[ i, 3 ], s_kslp[ i, 4 ] )
            AAdd( _akslp, s_kslp[ i, 1 ] )
            AAdd( _akslp, s_kslp[ i, 2 ] )
            _cena := round_5( _cena * s_kslp[ i, 2 ], 1 )
            Exit
          Endif
        Next
      Endif
    Endif
  Endif

  Return _akslp

// 23.01.19 ������ �⮣��� ����
Function ret_koef_kslp( akslp )

  Local k := 1

  If ValType( akslp ) == 'A' .and. Len( akslp ) >= 2
    k := akslp[ 2 ]
    If Len( akslp ) >= 4
      k += akslp[ 4 ] -1
    Endif
  Endif

  Return k

// 03.05.24 ������ �⮣��� ���� ��� 21 ����
Function ret_koef_kslp_21( akslp, nYear )

  Local k := 1  // ���� ࠢ�� 1
  Local i

  If ValType( akslp ) == 'A' .and. Len( akslp ) >= 2
    If nYear == 2021
      For i := 1 To Len( akslp ) Step 2
        If i == 1
          k := akslp[ 2 ]
        Else
          k += ( akslp[ i + 1 ] - 1 )
        Endif
      Next
      If k > 1.8
        k := 1.8  // ᮣ��᭮ �.3 ������樨
      Endif
      // elseif nYear == 2022
    Elseif nYear >= 2022
      k := 0
      For i := 1 To Len( akslp ) Step 2
        If i == 1 // �������� ⮫쪮 ���� ����
          k += akslp[ 2 ]
        else
          k += akslp[i + 1]
        Endif
      Next
    Endif
  Endif

  Return k

// 01.02.23 ������ �⮣��� ���� ��� �����⭮�� ����
Function ret_koef_kslp_21_xml( akslp, tKSLP, nYear )

  Local k := 1  // ���� ࠢ�� 1
  Local iAKSLP

  If ValType( akslp ) == 'A'
    If nYear == 2021
      For iAKSLP := 1 To Len( akslp )
        If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
          k += ( tKSLP[ cKSLP, 4 ] -1 )
        Endif
      Next
      If k > 1.8
        k := 1.8  // ᮣ��᭮ �.3 ������樨
      Endif
    Elseif nYear >= 2022
      k := 0
      For iAKSLP := 1 To Len( akslp )
        If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
          k += tKSLP[ cKSLP, 4 ]
        Endif
      Next
    Endif
  Endif

  Return k
