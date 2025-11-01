#include 'function.ch'
#include 'chip_mo.ch'

// 13.09.25
function load_exists_uslugi()
  
  local countYear, lAlias, cVar
  local cSearch, i
  local tmp_stom, is_vr_pr_pp
  local kod_mo_tfoms

  kod_mo_tfoms := glob_mo()[ _MO_KOD_TFOMS ]

  is_vr_pr_pp := .f.
  use_base( 'luslc' )
  for countYear := 2018 to WORK_YEAR
    lAlias := 'luslc' + iif( countYear == WORK_YEAR, '', substr( str( countYear, 4 ), 3 ) )
    set order to 2  // uslcu.ntx
    if ! exists_file_TFOMS( countYear, 'uslc' )
      loop
    endif
    if select( lAlias ) == 0
      loop
    endif
    if countYear == WORK_YEAR
      // ����樭᪠� ॠ������� ��⥩ � ����襭�ﬨ ��� ��� ������ �祢��� ������ ��⥬� ��嫥�୮� �������樨
      ( lAlias )->( dbSeek ( kod_mo_tfoms + 'st37.015' ) )
//      if ( lAlias )->( found() )
//        is_reabil_slux := ( lAlias )->( found() )
//      endif
      is_reabil_slux( ( lAlias )->( found() ) )
  
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '2.' ) ) // ��祡�� ����
      do while FIELD->codemo == kod_mo_tfoms .and. left( FIELD->shifr, 2 ) == '2.' .and. !eof()
        if left( FIELD->shifr, 5 ) == '2.82.'
          is_vr_pr_pp := .t. // ��祡�� �ਥ� � ��񬭮� �⤥����� ��樮���
          if is_napr_pol()
            exit
          endif
        else
          is_napr_pol( .t. )
          if is_vr_pr_pp
            exit
          endif
        endif
        skip
      enddo
    
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.3.' ) )
//      if ( lAlias )->( found() )
//        is_alldializ := .t.
//      endif
      is_alldializ( ( lAlias )->( found() ) )
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.3.1' ) )
//      if ( lAlias )->( found() )
//        is_per_dializ := .t.
//      endif
      is_per_dializ( ( lAlias )->( found() ) )
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.3.9' ) )
      if ( lAlias )->( found() )
        is_hemodializ( .t. )
      else
        ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.3.10' ) )
        if ( lAlias )->( found() )
          is_hemodializ( .t. )
        endif
      endif

      ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.3.19' ) )
      if ( lAlias )->( found() )
        is_hemodializ( .t. )
      else
        ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.3.20') )
        if ( lAlias )->( found() )
          is_hemodializ( .t. )
        endif
      endif
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '60.10.' ) )
//      if ( lAlias )->( found() )
//        is_alldializ := .t.
//      endif
      is_alldializ( ( lAlias )->( found() ) )

      
      ( lAlias )->( dbSeek ( kod_mo_tfoms + 'st') ) // �����-���
      if ( is_napr_stac ( ( lAlias )->( found() ) ) )
//        glob_menu_mz_rf[1] := .t.
        glob_menu_mz_rf( 1, .t. )
      endif
      //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + 'ds' ) ) // ������� ��樮���
      if ( lAlias )->( found() )
        if ! is_napr_stac()
          is_napr_stac( .t. )
        endif
//        glob_menu_mz_rf[2] := ( lAlias )->( found() )
        glob_menu_mz_rf( 2, ( lAlias )->( found() ) )
      endif

      // is_napr_stac( .t. )  // ����砫 � ��砫� ���� ��� ��ᯨ⠫���樨
    
    //
      tmp_stom := { '2.78.54', '2.78.55', '2.78.56', '2.78.57', '2.78.58', '2.78.59', '2.78.60' }
      for i := 1 to len( tmp_stom )
        ( lAlias )->( dbSeek ( kod_mo_tfoms + tmp_stom[ i ] ) ) //
        if ( lAlias )->( found() )
//          glob_menu_mz_rf[3] := .t.
          glob_menu_mz_rf( 3, .t. )
          exit
        endif
      next
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '4.20.702' ) ) // ������⭮� �⮫����
      if ( lAlias )->( found() )
//        aadd(glob_klin_diagn, 1)
        glob_klin_diagn( 1 )
      endif
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '4.15.746' ) ) // �७�⠫쭮�� �ਭ����
      if ( lAlias )->( found() )
//        aadd(glob_klin_diagn(), 2)
        glob_klin_diagn( 2 )
      endif
    //
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '70.3.123' ) ) // �����祭�� ��砩 ��ᯠ��ਧ�樨 ���騭 (� ������ 21,24,27 ���), 1 �⠯ ��� ����⮫����᪨� ��᫥�������
//      if ( lAlias )->( found() )
//        glob_yes_kdp2[TIP_LU_DVN] := .t.
        glob_yes_kdp2( TIP_LU_DVN, ( lAlias )->( found() ) )
//      endif
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '70.5.15' ) ) // �����祭�� ��砩 ��ᯠ��ਧ�樨 ��⥩-��� (0-11 ����楢), 1 �⠯ ��� ����⮫����᪨� ��᫥�������
//      if ( lAlias )->( found() )
//        glob_yes_kdp2[TIP_LU_DDS] := .t.
        glob_yes_kdp2( TIP_LU_DDS, ( lAlias )->( found() ) )
//      endif
    //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '70.6.13' ) ) // �����祭�� ��砩 ��ᯠ��ਧ�樨 ��⥩-��� (0-11 ����楢), 1 �⠯ ��� ����⮫����᪨� ��᫥�������
//      if ( lAlias )->( found() )
//        glob_yes_kdp2[TIP_LU_DDSOP] := .t.
        glob_yes_kdp2( TIP_LU_DDSOP, ( lAlias )->( found() ) )
//      endif
          //
      ( lAlias )->( dbSeek ( kod_mo_tfoms + '72.2.41' ) )// �����祭�� ��砩 ��䨫����᪮�� �ᬮ�� ��ᮢ��襭����⭨� (2 ���.) 1 �⠯ ��� ����⮫����᪮�� ��᫥�������
//      if ( lAlias )->( found() )
//        glob_yes_kdp2[TIP_LU_PN] := .t.
        glob_yes_kdp2( TIP_LU_PN, ( lAlias )->( found() ) )
//      endif
    endif
    cVar := 'is_' + substr(str( countYear, 4 ), 3 ) + '_VMP'
    ( lAlias )->( dbSelectArea() )
    ( lAlias )->( ordSetFocus( 2 ) )  // uslcu.ntx
    cSearch := kod_mo_tfoms + code_services_VMP( countYear )
    ( lAlias )->( dbSeek( cSearch ) )
    __mvPut( cVar, ( lAlias )->( found() ) )
    ( lAlias )->( dbCloseArea() )
  next
  return nil