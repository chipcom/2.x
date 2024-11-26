#include 'function.ch'
#include 'chip_mo.ch'
#include 'tbox.ch'

// 21.11.24
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
  local obyaz_kol_dnej := 0
  local is_opt_dlit_do_3_dnej := opt_dlitelnost_ksg_do_3dnej( cKSG, lkdata )

  Default lDoubleSluch To .f.

  // �஢�ਬ ��㣨 � ��易⥫�� �ப�� ��祭��
  if ( obyaz_kol_dnej := obyazat_srok_lech( lksg, lkdata ) ) != 0
    If lkdata >= 0d20240101
      If ( obyaz_kol_dnej >= ldnej ) .and. ( AScan( lkiro, 7 ) > 0 )
        vkiro := 7
      endif
    Else
      vkiro := 4
    Endif
    Return vkiro
  endif
//  If eq_any( cKSG, 'st37.002', 'st37.003', 'st37.006', 'st37.007', 'st37.024', 'st37.025', 'st37.026' ) .or. ;
//      eq_any( cKSG, 'ds12.016', 'ds12.017', 'ds12.018', 'ds12.019', 'ds12.020', 'ds12.021', 'st37.026' )

//    // ��� �� ��㣠� ���. ॠ�����樨 � ��樮��� � ������� ��樮���
//    // ᮣ��᭮ ��㦥���� ����᪠ �맣��� �� 13.02.23 � ������樨 �� ��� ����� �� 24 ���
//    If ( cKSG == 'st37.002' .and. ldnej < 14 ) .or. ;
//        ( cKSG == 'st37.003' .and. ldnej < 20 ) .or. ;
//        ( cKSG == 'st37.006' .and. ldnej < 12 ) .or. ;
//        ( cKSG == 'st37.007' .and. ldnej < 18 ) .or. ;
//        ( ( cKSG == 'st37.024' .or. cKSG == 'st37.025' .or. cKSG == 'st37.026' ) .and. ldnej < 30 ) .or. ;
//        ( ( cKSG == 'ds12.016' .or. cKSG == 'ds12.017' .or. cKSG == 'ds12.018' .or. cKSG == 'ds12.019' ) .and. ldnej < 28 ) .or. ;
//        ( ( cKSG == 'ds12.020' .or. cKSG == 'ds12.021' ) .and. ldnej < 30 )

//      If lkdata >= 0d20240101
//        vkiro := 7
//      Else
//        vkiro := 4
//      Endif
//      Return vkiro
//    Endif
//  Endif

  If lDoubleSluch // �� ���� �������� ����
    If AScan( lkiro, 3 ) > 0 .and. AScan( { 102, 105, 107, 110, 202, 205, 207 }, lrslt ) > 0
      vkiro := 3
    Elseif AScan( lkiro, 4 ) > 0 .and. AScan( { 102, 105, 107, 110, 202, 205, 207 }, lrslt ) > 0
      vkiro := 4
    Endif
  Endif

  if lkdata >= 0d20241001 // � 01.10.24 ���쬮 ����� 12-20-543 �� 08.10.24
    if ( ldnej <= 3 ) .and. ( lrslt == 101 .or. lrslt == 201 )
      if is_opt_dlit_do_3_dnej
        Return vkiro
      else
        If AScan( lkiro, 1 ) > 0
          vkiro := 1
        elseIf AScan( lkiro, 2 ) > 0
          vkiro := 2
        elseif AScan( lkiro, 5 ) > 0
          vkiro := 5
        endif
      endif
    elseif eq_any( lrslt, 102, 103, 105, 107, 110, 202, 203, 205, 207, 210 )
//      if is_opt_dlit_do_3_dnej
        If AScan( lkiro, 3 ) > 0
          vkiro := 3
        endif
//      else
        If AScan( lkiro, 4 ) > 0
          vkiro := 4
        elseif AScan( lkiro, 6 ) > 0
          vkiro := 6
        endif
//      endif
    endif
  else
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
      If is_opt_dlit_do_3_dnej .and. ( AScan( { 102, 105, 107, 110, 202, 205, 207 }, lrslt ) == 0 )  // �஢�६ १���� ��祭��
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
    endif
  endif
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

// 18.10.24
Function opt_dlitelnost_ksg_do_3dnej( cKSG, lkdata )

  // �. 3.2 �����㪨� �� �ਬ������ ��� 24 ����
  // ���祭� ��� � ��⨬��쭮� ���⥫쭮���� ��祭�� �� 3 ���� �����⥫쭮
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

// 18.10.24
function obyazat_srok_lech( cKSG, lkdata )
  // ᮣ��᭮ �/�.9 �㭪� 3.2 ������樨 �� ���
  // ��� �� ��㣠� ���. ॠ�����樨 � ��樮��� � ������� ��樮���
  // ᮣ��᭮ ��㦥���� ����᪠ �맣��� �� 13.02.23 � ������樨 �� ��� ����� �� 24 ���

  local arrKSG := { ;
    { 'st37.002', 14 }, ;
    { 'st37.003', 20 }, ;
    { 'st37.006', 12 }, ;
    { 'st37.007', 18 }, ;
    { 'st37.024', 30 }, ;
    { 'st37.025', 30 }, ;
    { 'st37.026', 30 }, ;
    { 'ds12.016', 28 }, ;
    { 'ds12.017', 28 }, ;
    { 'ds12.018', 28 }, ;
    { 'ds12.019', 28 }, ;
    { 'ds12.020', 30 }, ;
    { 'ds12.021', 30 } ;
  }
  local i, ret := 0
  
  if ( i := AScan( arrKsg, {| x | x[ 1 ] == Lower( alltrim( cKSG ) ) } ) ) > 0
    ret := arrKSG[ i, 2 ]
  endif
  return ret

// 19.10.24
Function is_hir_tromp( cKSG, lkdata )

  // ᮣ��᭮ �㭪� 3.2 ������樨 �� ��� 24 ����
  // ���祭� ���, ����� �।�������� ���ࣨ�᪮� ����⥫��⢮
  // ��� �஬��������� �࠯��

  Local arrKSG := { ;
    'st02.003', ;
    'st02.004', ;
    'st02.010', ;
    'st02.011', ;
    'st02.012', ;
    'st02.013', ;
    'st02.015', ;
    'st02.016', ;
    'st02.017', ;
    'st02.014', ;
    'st09.001', ;
    'st09.002', ;
    'st09.003', ;
    'st09.004', ;
    'st09.005', ;
    'st09.006', ;
    'st09.007', ;
    'st09.008', ;
    'st09.009', ;
    'st09.010', ;
    'st09.011', ;
    'st10.001', ;
    'st10.002', ;
    'st10.003', ;
    'st10.005', ;
    'st10.006', ;
    'st10.007', ;
    'st10.008', ;
    'st13.002', ;
    'st13.005', ;
    'st13.007', ;
    'st13.008', ;
    'st13.009', ;
    'st13.010', ;
    'st14.001', ;
    'st14.002', ;
    'st14.003', ;
    'st14.004', ;
    'st15.015', ;
    'st15.016', ;
    'st16.007', ;
    'st16.008', ;
    'st16.009', ;
    'st16.010', ;
    'st16.011', ;
    'st18.002', ;
    'st19.001', ;
    'st19.002', ;
    'st19.003', ;
    'st19.004', ;
    'st19.005', ;
    'st19.006', ;
    'st19.007', ;
    'st19.008', ;
    'st19.009', ;
    'st19.010', ;
    'st19.011', ;
    'st19.012', ;
    'st19.013', ;
    'st19.014', ;
    'st19.015', ;
    'st19.016', ;
    'st19.017', ;
    'st19.018', ;
    'st19.019', ;
    'st19.020', ;
    'st19.021', ;
    'st19.022', ;
    'st19.023', ;
    'st19.024', ;
    'st19.025', ;
    'st19.026', ;
    'st19.123', ;
    'st19.124', ;
    'st19.038', ;
    'st19.104', ;
    'st20.005', ;
    'st20.006', ;
    'st20.007', ;
    'st20.008', ;
    'st20.009', ;
    'st20.010', ;
    'st21.001', ;
    'st21.002', ;
    'st21.003', ;
    'st21.004', ;
    'st21.005', ;
    'st21.006', ;
    'st21.009', ;
    'st24.004', ;
    'st25.004', ;
    'st25.005', ;
    'st25.006', ;
    'st25.007', ;
    'st25.008', ;
    'st25.009', ;
    'st25.010', ;
    'st25.011', ;
    'st25.012', ;
    'st27.007', ;
    'st27.009', ;
    'st28.002', ;
    'st28.003', ;
    'st28.004', ;
    'st28.005', ;
    'st29.007', ;
    'st29.008', ;
    'st29.009', ;
    'st29.010', ;
    'st29.011', ;
    'st29.012', ;
    'st29.013', ;
    'st30.006', ;
    'st30.007', ;
    'st30.008', ;
    'st30.009', ;
    'st30.010', ;
    'st30.011', ;
    'st30.012', ;
    'st30.013', ;
    'st30.014', ;
    'st30.015', ;
    'st30.016', ;
    'st31.002', ;
    'st31.003', ;
    'st31.004', ;
    'st31.005', ;
    'st31.006', ;
    'st31.007', ;
    'st31.008', ;
    'st31.009', ;
    'st31.010', ;
    'st31.015', ;
    'st31.019', ;
    'st32.001', ;
    'st32.002', ;
    'st32.003', ;
    'st32.004', ;
    'st32.005', ;
    'st32.006', ;
    'st32.007', ;
    'st32.008', ;
    'st32.009', ;
    'st32.010', ;
    'st32.011', ;
    'st32.013', ;
    'st32.014', ;
    'st32.015', ;
    'st32.019', ;
    'st32.016', ;
    'st32.017', ;
    'st32.018', ;
    'st32.020', ;
    'st32.021', ;
    'st33.005', ;
    'st33.006', ;
    'st33.007', ;
    'st33.008', ;
    'st34.002', ;
    'st34.003', ;
    'st34.004', ;
    'st34.005', ;
    'st36.009', ;
    'st36.010', ;
    'st36.011', ;
    'ds02.006', ;
    'ds02.003', ;
    'ds02.004', ;
    'ds09.001', ;
    'ds09.002', ;
    'ds10.001', ;
    'ds13.002', ;
    'ds14.001', ;
    'ds14.002', ;
    'ds16.002', ;
    'ds18.003', ;
    'ds19.016', ;
    'ds19.017', ;
    'ds19.028', ;
    'ds20.002', ;
    'ds20.003', ;
    'ds20.004', ;
    'ds20.005', ;
    'ds20.006', ;
    'ds21.002', ;
    'ds21.003', ;
    'ds21.004', ;
    'ds21.005', ;
    'ds21.006', ;
    'ds21.007', ;
    'ds25.001', ;
    'ds25.002', ;
    'ds25.003', ;
    'ds28.001', ;
    'ds29.001', ;
    'ds29.002', ;
    'ds29.003', ;
    'ds30.002', ;
    'ds30.003', ;
    'ds30.004', ;
    'ds30.005', ;
    'ds30.006', ;
    'ds31.002', ;
    'ds31.003', ;
    'ds31.004', ;
    'ds31.005', ;
    'ds31.006', ;
    'ds32.001', ;
    'ds32.002', ;
    'ds32.003', ;
    'ds32.004', ;
    'ds32.005', ;
    'ds32.006', ;
    'ds32.007', ;
    'ds32.008', ;
    'ds34.002', ;
    'ds34.003' ;
    }

  Return AScan( arrKsg, Lower( cKSG ) ) > 0