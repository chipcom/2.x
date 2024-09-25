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

// 28.04.23 �㭪�� �롮� ��⠢� ����, �����頥� { ��᪠,��ப� ������⢠ ���� }, ��� nil
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
  Local row, oBox
  Local nLast, srok := dateEnd - dateBegin
  Local recN, permissibleKSLP := {}, isPermissible
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
  If ( ret := popupn( 5, 10, 5 + mlen + 1, 71, t_mas, i, color0, .t., 'fmenu_readerN', , ;
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

// 15.02.24
Function defenition_kiro( lkiro, ldnej, lrslt, lis_err, lksg, lDoubleSluch, lkdata )

  // lkiro - ᯨ᮪ ��������� ���� ��� ���
  // ldnej - ���⥫쭮��� ���� � �����-����
  // lrslt - १���� ���饭�� (�ࠢ�筨� V009)
  // lis_err - �訡�� (�����-�)
  // lksg - ��� ���
  // lDoubleSluch - �� ���� �������� ����
  // lkdata - ��� ����砭�� ����
  Local vkiro := 0
  Local cKSG := AllTrim( LTrim( lksg ) )

  Default lDoubleSluch To .f.
  If eq_any( cKSG, 'st37.002', 'st37.003', 'st37.006', 'st37.007', 'st37.024', 'st37.025', 'st37.026' ) .or. ;
      eq_any( cKSG, 'ds12.016', 'ds12.017', 'ds12.018', 'ds12.019', 'ds12.020', 'ds12.021', 'st37.026' )

    // ��� �� ��㣠� ���. ॠ�����樨 � ��樮��� � ������� ��樮���
    // ᮣ��᭮ ��㦥���� ����᪠ �맣��� �� 13.02.23 � ������樨 �� ��� ����� �� 24 ���
    If ( cKSG == 'st37.002' .and. ldnej < 14 ) .or. ;
        ( cKSG == 'st37.003' .and. ldnej < 20 ) .or. ;
        ( cKSG == 'st37.006' .and. ldnej < 12 ) .or. ;
        ( cKSG == 'st37.007' .and. ldnej < 18 ) .or. ;
        ( ( cKSG == 'st37.024' .or. cKSG == 'st37.025' .or. cKSG == 'st37.026' ) .and. ldnej < 30 ) .or. ;
        ( ( cKSG == 'ds12.016' .or. cKSG == 'ds12.017' .or. cKSG == 'ds12.018' .or. cKSG == 'ds12.019' ) .and. ldnej < 28 ) .or. ;
        ( ( cKSG == 'ds12.020' .or. cKSG == 'ds12.021' ) .and. ldnej < 30 )

      If lkdata >= 0d20240101
        vkiro := 7
      Else
        vkiro := 4
      Endif
      Return vkiro
    Endif
  Endif

  If lDoubleSluch // �� ���� �������� ����
    If AScan( lkiro, 3 ) > 0 .and. AScan( { 102, 105, 107, 110, 202, 205, 207 }, lrslt ) > 0
      vkiro := 3
    Elseif AScan( lkiro, 4 ) > 0 .and. AScan( { 102, 105, 107, 110, 202, 205, 207 }, lrslt ) > 0
      vkiro := 4
    Endif
  Endif
  If ldnej > 3 // ������⢮ ���� ��祭�� 4 � ����� ����
    If AScan( { 102, 105, 107, 110, 202, 205, 207 }, lrslt ) > 0  // �஢�६ १���� ��祭��
      If AScan( lkiro, 3 ) > 0
        vkiro := 3
      Elseif AScan( lkiro, 4 ) > 0
        vkiro := 4
      Elseif lis_err == 1 .and. AScan( lkiro, 6 ) > 0 // ������塞 ��� ��ᮡ���� �奬� 娬���࠯�� (����=6)
        vkiro := 6
      Endif
      Return vkiro
    Else
      Return vkiro
    Endif
  Else // ������⢮ ���� ��祭�� 3 � ����� ����
    If isklichenie_ksg_kiro( cKSG, lkdata )
      Return vkiro
    Endif
    If AScan( lkiro, 1 ) > 0
      vkiro := 1
    Elseif AScan( lkiro, 2 ) > 0
      vkiro := 2
    Elseif AScan( lkiro, 4 ) > 0  // ����砥��� � ������� �����
      vkiro := 4
    Elseif lis_err == 1 .and. AScan( lkiro, 5 ) > 0 // ������塞 ��� ��ᮡ���� �奬� 娬���࠯�� (����=5)
      vkiro := 5
    Endif
  Endif
  Return vkiro

// 30.11.21
Function f_cena_kiro( /*@*/_cena, lkiro, dateSl )

  // _cena - �����塞�� 業�
  // lkiro - �஢��� ����
  // dateSl - ��� ����
  Local _akiro := { 0, 1 }
  Local aKIRO, rowKIRO

  aKIRO := getkirotable( dateSl )
  For Each rowKIRO in aKIRO
    If rowKIRO[ 1 ] == lkiro
      If between_date( rowKIRO[ 5 ], rowKIRO[ 6 ], dateSl )
        _akiro := { lkiro, rowKIRO[ 4 ] }
      Endif
    Endif
  Next

  _cena := round_5( _cena * _akiro[ 2 ], 0 )  // ���㣫���� �� �㡫�� � 2019 ����

  Return _akiro

// 13.03.24 ��।����� ����-� ᫮����� ��祭�� ��樥�� � �������� 業�
Function f_cena_kslp( /*@*/_cena, _lshifr, _date_r, _n_data, _k_data, lkslp, arr_usl, lPROFIL_K, arr_diag, lpar_org, lad_cr)

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
      '"' + arr2slistn( arr_diag ) + '",' + lstr( countDays ) + ')'

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

// 25.09.24
Function isklichenie_ksg_kiro( cKSG, lkdata )

  Local i
  Local arrKSG := { ;
    'st02.001', ;
    'st02.002', ;
    'st02.003', ;
    'st02.004', ;
    'st02.010', ;
    'st02.011', ;
    'st03.002', ;
    'st05.008', ;
    'st08.001', ;
    'st08.002', ;
    'st08.003', ;
    'st12.010', ;
    'st12.011', ;
    'st14.002', ;
    'st15.008', ;
    'st15.009', ;
    'st16.005', ;
    'st19.007', ;
    'st19.038', ;
    'st19.125', ;
    'st19.126', ;
    'st19.127', ;
    'st19.128', ;
    'st19.129', ;
    'st19.130', ;
    'st19.131', ;
    'st19.132', ;
    'st19.133', ;
    'st19.134', ;
    'st19.135', ;
    'st19.136', ;
    'st19.137', ;
    'st19.138', ;
    'st19.139', ;
    'st19.140', ;
    'st19.141', ;
    'st19.142', ;
    'st19.143', ;
    'st19.082', ;
    'st19.090', ;
    'st19.094', ;
    'st19.097', ;
    'st19.100', ;
    'st20.005', ;
    'st20.006', ;
    'st20.010', ;
    'st21.001', ;
    'st21.002', ;
    'st21.003', ;
    'st21.004', ;
    'st21.005', ;
    'st21.006', ;
    'st21.009', ;
    'st25.004', ;
    'st27.012', ;
    'st30.006', ;
    'st30.010', ;
    'st30.011', ;
    'st30.012', ;
    'st30.014', ;
    'st31.017', ;
    'st32.002', ;
    'st32.012', ;
    'st32.016', ;
    'st34.002', ;
    'st36.001', ;
    'st36.007', ;
    'st36.009', ;
    'st36.010', ;
    'st36.011', ;
    'st36.024', ;
    'st36.025', ;
    'st36.026', ;
    'st36.028', ;
    'st36.029', ;
    'st36.030', ;
    'st36.031', ;
    'st36.032', ;
    'st36.033', ;
    'st36.034', ;
    'st36.035', ;
    'st36.036', ;
    'st36.037', ;
    'st36.038', ;
    'st36.039', ;
    'st36.040', ;
    'st36.041', ;
    'st36.042', ;
    'st36.043', ;
    'st36.044', ;
    'st36.045', ;
    'st36.046', ;
    'st36.047', ;
    'ds02.001', ;
    'ds02.006', ;
    'ds02.007', ;
    'ds02.008', ;
    'ds05.005', ;
    'ds08.001', ;
    'ds08.002', ;
    'ds08.003', ;
    'ds15.002', ;
    'ds15.003', ;
    'ds19.028', ;
    'ds19.033', ;
    'ds19.097', ;
    'ds19.098', ;
    'ds19.099', ;
    'ds19.100', ;
    'ds19.101', ;
    'ds19.102', ;
    'ds19.103', ;
    'ds19.104', ;
    'ds19.105', ;
    'ds19.106', ;
    'ds19.107', ;
    'ds19.108', ;
    'ds19.109', ;
    'ds19.110', ;
    'ds19.111', ;
    'ds19.112', ;
    'ds19.113', ;
    'ds19.114', ;
    'ds19.115', ;
    'ds19.057', ;
    'ds19.063', ;
    'ds19.067', ;
    'ds19.071', ;
    'ds19.075', ;
    'ds20.002', ;
    'ds20.003', ;
    'ds20.006', ;
    'ds21.002', ;
    'ds21.003', ;
    'ds21.004', ;
    'ds21.005', ;
    'ds21.006', ;
    'ds21.007', ;
    'ds25.001', ;
    'ds27.001', ;
    'ds34.002', ;
    'ds36.001', ;
    'ds36.012', ;
    'ds36.013', ;
    'ds36.015', ;
    'ds36.016', ;
    'ds36.017', ;
    'ds36.018', ;
    'ds36.019', ;
    'ds36.020', ;
    'ds36.021', ;
    'ds36.022', ;
    'ds36.023', ;
    'ds36.024', ;
    'ds36.025', ;
    'ds36.026', ;
    'ds36.027', ;
    'ds36.028', ;
    'ds36.029', ;
    'ds36.030', ;
    'ds36.031', ;
    'ds36.032', ;
    'ds36.033', ;
    'ds36.034', ;
    'ds36.035' ;
    }

  If Year( lkdata ) >= 2024
    // if ( i := AScan( arrKsg, Lower( 'st02.001' ) ) ) > 0
    //   hb_ADel( arrKSG, i, .t. )
    // endif
    // if ( i := AScan( arrKsg, Lower( 'st02.002' ) ) ) > 0
    //   hb_ADel( arrKSG, i, .t. )
    // endif
    // if ( i := AScan( arrKsg, Lower( 'st02.003' ) ) ) > 0
    //   hb_ADel( arrKSG, i, .t. )
    // endif
    // if ( i := AScan( arrKsg, Lower( 'st02.004' ) ) ) > 0
    //   hb_ADel( arrKSG, i, .t. )
    // endif
    // if ( i := AScan( arrKsg, Lower( 'st02.010' ) ) ) > 0
    //   hb_ADel( arrKSG, i, .t. )
    // endif
    // if ( i := AScan( arrKsg, Lower( 'st02.011' ) ) ) > 0
    //   hb_ADel( arrKSG, i, .t. )
    // endif
    AAdd( arrKSG, 'st09.011' )
    AAdd( arrKSG, 'st12.001' )
    AAdd( arrKSG, 'st12.002' )
    AAdd( arrKSG, 'st19.144' )
    AAdd( arrKSG, 'st19.145' )
    AAdd( arrKSG, 'st19.146' )
    AAdd( arrKSG, 'st19.147' )
    AAdd( arrKSG, 'st19.148' )
    AAdd( arrKSG, 'st19.149' )
    AAdd( arrKSG, 'st19.150' )
    AAdd( arrKSG, 'st19.151' )
    AAdd( arrKSG, 'st19.152' )
    AAdd( arrKSG, 'st19.153' )
    AAdd( arrKSG, 'st19.154' )
    AAdd( arrKSG, 'st19.155' )
    AAdd( arrKSG, 'st19.156' )
    AAdd( arrKSG, 'st19.157' )
    AAdd( arrKSG, 'st19.158' )
    AAdd( arrKSG, 'st19.159' )
    AAdd( arrKSG, 'st19.160' )
    AAdd( arrKSG, 'st19.161' )
    AAdd( arrKSG, 'st19.162' )
    AAdd( arrKSG, 'st30.016' )
  Endif

  Return AScan( arrKsg, Lower( cKSG ) ) > 0
