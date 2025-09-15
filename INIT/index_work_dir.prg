#include 'function.ch'
#include 'chip_mo.ch'

#define NUMBER_YEAR 3 // �᫮ ��� ��� ��२�����樨 �����
#define INDEX_NEED  2 // �᫮ ��� ��易⥫쭮� ��२�����樨

// 06.01.25 �஢�ઠ ������ �ࠢ�筨��� ���
Function files_nsi_exists( dir_file )

  Local lRet := .t.
  Local i
  Local sbase
  Local aError := {}
  Local cDbf := '.dbf'
  Local cDbt := '.dbt'
  Local arr_f  := { '_okator', '_okatoo', '_okatos', '_okatoo8', '_okatos8' }
  Local arr_check := {}
  Local prefix
  Local arr_TFOMS
  Local nSize

  sbase := dir_file + FILE_NAME_SQL
  If ! hb_FileExists( sbase )
    AAdd( aError, '��������� 䠩�: ' + sbase )
  Else
    If ( nSize := hb_vfSize( sbase ) ) < 3362000
      AAdd( aError, '������ 䠩�� "' + sbase + '" ����� 3362000 ����. ������� � ࠧࠡ��稪��.' )
    Endif
  Endif

  fill_exists_files_tfoms( dir_file )

  // �ࠢ�筨�� ���������
  sbase := dir_file + '_mo_mkb' + cDbf
  AAdd( arr_check, sbase )
  sbase := dir_file + '_mo_mkbg' + cDbf
  AAdd( arr_check, sbase )
  sbase := dir_file + '_mo_mkbk' + cDbf
  AAdd( arr_check, sbase )

  // ��㣨 <-> ᯥ樠�쭮��
  sbase := dir_file + '_mo_spec' + cDbf
  AAdd( arr_check, sbase )

  // ��㣨 <-> ��䨫�
  sbase := dir_file + '_mo_prof' + cDbf
  AAdd( arr_check, sbase )

  // �ࠢ�筨� ���客�� �������� ��
  sbase := dir_file + '_mo_smo' + cDbf
  AAdd( arr_check, sbase )

  // onkko_vmp
  sbase := dir_file + '_mo_ovmp' + cDbf
  AAdd( arr_check, sbase )

//  // N0__
//  // for i := 1 to 21
//  For i := 20 To 21
//    sbase := dir_file + '_mo_N' + StrZero( i, 3 ) + cDbf
//    AAdd( arr_check, sbase )
//  Next

  // �ࠢ�筨� ���ࠧ������� �� ��ᯮ�� ���
  sbase := dir_file + '_mo_podr' + cDbf
  AAdd( arr_check, sbase )

  // �ࠢ�筨� ᮮ⢥��⢨� ��䨫� ���.����� � ��䨫�� �����
  sbase := dir_file + '_mo_prprk' + cDbf
  AAdd( arr_check, sbase )

  // �����
  For i := 1 To Len( arr_f )
    sbase := dir_file + arr_f[ i ] + cDbf
    AAdd( arr_check, sbase )
  Next

  // �஢�ਬ ����⢮����� 䠩���
  For i := 1 To Len( arr_check )
    If ! hb_FileExists( arr_check[ i ] )
      AAdd( aError, '��������� 䠩�: ' + arr_check[ i ] )
    Endif
  Next

  prefix := dir_file + prefixfilerefname( WORK_YEAR )
  arr_TFOMS := array_exists_files_tfoms( WORK_YEAR )
  For i := 1 To Len( arr_TFOMS )
    If ! arr_TFOMS[ i, 2 ]
      AAdd( aError, '��������� 䠩�: ' + prefix + arr_TFOMS[ i, 1 ] + cDbf )
    Endif
  Next

  If Len( aError ) > 0
    AAdd( aError, '����� ����������!' )
    f_message( aError, , 'GR+/R', 'W+/R', 13 )
    Inkey( 0 )
    lret := .f.
  Endif
  Return lRet

// 15.09.25 �஢�ઠ � ��२�����஢���� �ࠢ�筨��� �����
Function index_work_dir( dir_spavoch, working_dir, flag )

  Local fl := .t., i, buf := save_maxrow()
  Local arrRefFFOMS := {}, row_flag := .t.
  Local lSchema := .f.
  Local countYear
  Local cVar
  Local sbase

  Default flag To .f.

//  AFill( glob_yes_kdp2, .f. )

  If flag
    mywait( '��������, ���� ��२������� 䠩��� ��� � ࠡ�祩 ������...' )
  Else
    mywait( '��������, ���� �஢�ઠ �㦥���� ������ � ࠡ�祬 ��⠫���...' )
  Endif

  // �ࠢ�筨� ���������
  sbase := '_mo_mkb'
  r_use( dir_spavoch + sbase )
  Index On FIELD->shifr + Str( FIELD->ks, 1 ) to ( working_dir + sbase )
  Close databases

  // ��㣨 <-> ᯥ樠�쭮��
  sbase := '_mo_spec'
  r_use( dir_spavoch + sbase )
  Index On FIELD->shifr + Str( FIELD->vzros_reb, 1 ) + Str( FIELD->prvs_new, 6 ) to ( working_dir + sbase )
  Use

  // ��㣨 <-> ��䨫�
  sbase := '_mo_prof'
  r_use( dir_spavoch + sbase )
  Index On FIELD->shifr + Str( FIELD->vzros_reb, 1 ) + Str( FIELD->profil, 3 ) to ( working_dir + sbase )
  Use

  If flag
    For countYear = 2018 To WORK_YEAR
      fl := dep_index_and_fill( countYear, dir_spavoch, working_dir, flag )  // �ࠢ�筨� �⤥����� �� countYear ���
      fl := usl_index( countYear, dir_spavoch, working_dir, flag )    // �ࠢ�筨� ��� ����� �� countYear ���
      fl := uslc_index( countYear, dir_spavoch, working_dir, flag )   // 業� �� ��㣨 �� countYear ���
      fl := uslf_index( countYear, dir_spavoch, working_dir, flag )   // �ࠢ�筨� ��� ����� countYear
      fl := unit_index( countYear, dir_spavoch, working_dir, flag )   // ����-�����
      fl := k006_index( countYear, dir_spavoch, working_dir, flag )
    Next
  Else
    fl := dep_index_and_fill( WORK_YEAR, dir_spavoch, working_dir, flag )  // �ࠢ�筨� �⤥����� �� countYear ���
    fl := usl_index( WORK_YEAR, dir_spavoch, working_dir, flag )    // �ࠢ�筨� ��� ����� �� countYear ���
    fl := uslc_index( WORK_YEAR, dir_spavoch, working_dir, flag )   // 業� �� ��㣨 �� countYear ���
    fl := uslf_index( WORK_YEAR, dir_spavoch, working_dir, flag )   // �ࠢ�筨� ��� ����� countYear
    fl := unit_index( WORK_YEAR, dir_spavoch, working_dir, flag )   // ����-�����
    fl := k006_index( WORK_YEAR, dir_spavoch, working_dir, flag )
  Endif

  load_exists_uslugi()

  For i := 2019 To WORK_YEAR
    cVar := 'is_' + SubStr( Str( i, 4 ), 3 ) + '_VMP'
    is_MO_VMP := is_MO_VMP .or. __mvGet( cVar )
  Next

  // onkko_vmp
  sbase := '_mo_ovmp'
  r_use( dir_spavoch + sbase )
  Index On Str( FIELD->metod, 3 ) to ( working_dir + sbase )
  Use

  // �ࠢ�筨� ���ࠧ������� �� ��ᯮ�� ���
  sbase := '_mo_podr'
  r_use( dir_spavoch + sbase )
  Index On FIELD->codemo + PadR( Upper( FIELD->kodotd ), 25 ) to ( working_dir + sbase )
  Use

  // �ࠢ�筨� ᮮ⢥��⢨� ��䨫� ���.����� � ��䨫�� �����
  sbase := '_mo_prprk'
  r_use( dir_spavoch + sbase )
  Index On Str( FIELD->profil, 3 ) + Str( FIELD->profil_k, 3 ) to ( working_dir + sbase )
  Use

  // �ࠢ�筨� �����
  okato_index( flag )
  //
  // �ࠢ�筨� ���客�� �������� ��
/*
  sbase := '_mo_smo' 
  glob_array_srf := {}
  r_use( dir_spavoch + sbase )
  Index On FIELD->okato to ( working_dir + sbase ) UNIQUE
  dbEval( {|| AAdd( glob_array_srf, { '', field->okato } ) } )
  Index On FIELD->okato + FIELD->smo to ( working_dir + sbase )
  Index On FIELD->smo to ( working_dir + sbase + '2' )
  Index On FIELD->okato + FIELD->ogrn to ( working_dir + sbase + '3' )
  Use

  dbCreate( working_dir + 'tmp_srf', { { 'okato', 'C', 5, 0 }, { 'name', 'C', 80, 0 } } )
  Use ( working_dir + 'tmp_srf' ) New Alias TMP
  r_use( dir_spavoch + '_okator', working_dir + '_okatr', 'RE' )
  r_use( dir_spavoch + '_okatoo', working_dir + '_okato', 'OB' )
  For i := 1 To Len( glob_array_srf() )
    Select OB
    find ( glob_array_srf()[ i, 2 ] )
    If Found()
      glob_array_srf()[ i, 1 ] := RTrim( ob->name )
    Else
      Select RE
      find ( Left( glob_array_srf()[ i, 2 ], 2 ) )
      If Found()
        glob_array_srf()[ i, 1 ] := RTrim( re->name )
      Elseif Left( glob_array_srf()[ i, 2 ], 2 ) == '55'
        glob_array_srf()[ i, 1 ] := '�.��������'
      Endif
    Endif
    Select TMP
    Append Blank
    tmp->okato := glob_array_srf()[ i, 2 ]
    tmp->name  := iif( SubStr( glob_array_srf()[ i, 2 ], 3, 1 ) == '0', '', '  ' ) + glob_array_srf()[ i, 1 ]
  Next
  Close databases
*/
  glob_array_srf( dir_spavoch, working_dir )
  rest_box( buf )
  Return Nil

// 09.03.23
Function dep_index_and_fill( val_year, dir_spavoch, working_dir, flag )

  Local sbase

  Default flag To .f.
  sbase := prefixfilerefname( val_year ) + 'dep'  // �ࠢ�筨� �⤥����� �� ������� ���
  If hb_vfExists( dir_spavoch + sbase + sdbf() )
    r_use( dir_spavoch + sbase, , 'DEP' )
    Index On Str( FIELD->code, 3 ) to ( working_dir + sbase ) For FIELD->codem == glob_mo()[ _MO_KOD_TFOMS ]

    If val_year == WORK_YEAR
      dbEval( {|| AAdd( mm_otd_dep, { AllTrim( dep->name_short ) + ' (' + AllTrim( dep->name ) + ')', dep->code, dep->place } ) } )
      If ( is_otd_dep := ( Len( mm_otd_dep ) > 0 ) )
        ASort( mm_otd_dep, , , {| x, y| x[ 1 ] < y[ 1 ] } )
      Endif
    Endif
    Use
    If is_otd_dep
      sbase := prefixfilerefname( val_year ) + 'deppr' // �ࠢ�筨� �⤥����� + ��䨫�  �� ������� ���
      If hb_vfExists( dir_spavoch + sbase + sdbf() )
        r_use( dir_spavoch + sbase, , 'DEP' )
        Index On Str( FIELD->code, 3 ) + Str( FIELD->pr_mp, 3 ) to ( working_dir + sbase ) For FIELD->codem == glob_mo()[ _MO_KOD_TFOMS ]
        Use
      Endif
    Endif
  Endif
  Return Nil

// 15.09.23
Function usl_index( val_year, dir_spavoch, working_dir, flag )

  Local sbase
  Local shifrVMP

  Default flag To .f.
  sbase := prefixfilerefname( val_year ) + 'usl'  // �ࠢ�筨� ��� ����� �� ������� ���
  If hb_vfExists( dir_spavoch + sbase + sdbf() )
    r_use( dir_spavoch + sbase, , 'LUSL' )
    Index On FIELD->shifr to ( working_dir + sbase )
    If val_year == WORK_YEAR
      shifrVMP := code_services_vmp( WORK_YEAR )
      find ( shifrVMP )
      // find ('1.22.') // ��� 䥤�ࠫ쭮�   // 01.03.23 ������ ��� � 1.21 �� 1.22 ���쬮
      // find ('1.21.') // ��� 䥤�ࠫ쭮�   // 10.02.22 ������ ��� � 1.20 �� 1.21 ���쬮 12-20-60 �� 01.02.22
      // find ('1.20.') // ��� 䥤�ࠫ쭮�   // 07.02.21 ������ ��� � 1.12 �� 1.20 ���쬮 12-20-60 �� 01.02.21
      // do while left(lusl->shifr,5) == '1.20.' .and. !eof()
      // do while left(lusl->shifr,5) == '1.21.' .and. !eof()
      // do while left(lusl->shifr, 5) == '1.22.' .and. !eof()
      Do While Left( lusl->shifr, 5 ) == shifrVMP .and. !Eof()
//        AAdd( arr_12_VMP, Int( Val( SubStr( lusl->shifr, 6 ) ) ) )
        arr_VMP( Int( Val( SubStr( lusl->shifr, 6 ) ) ) )
        Skip
      Enddo
    Endif
    Close databases
  Endif
  Return Nil

// 23.03.23
Function uslc_index( val_year, dir_spavoch, working_dir, flag )

  Local sbase, prefix
  Local index_usl_name

  Default flag To .f.
  prefix := prefixfilerefname( val_year )
  sbase :=  prefix + 'uslc'  // 業� �� ��㣨 �� ������� ���
  If hb_vfExists( dir_spavoch + sbase + sdbf() )
    index_usl_name :=  prefix + 'uslu'  //

    r_use( dir_spavoch + sbase, , 'LUSLC' )
    Index On FIELD->shifr + Str( FIELD->vzros_reb, 1 ) + Str( FIELD->depart, 3 ) + DToS( FIELD->datebeg ) to ( working_dir + sbase ) ;
      For FIELD->codemo == glob_mo()[ _MO_KOD_TFOMS ]
    Index On FIELD->codemo + FIELD->shifr + Str( FIELD->vzros_reb, 1 ) + Str( FIELD->depart, 3 ) + DToS( FIELD->datebeg ) to ( working_dir + index_usl_name ) ;
      For FIELD->codemo == glob_mo()[ _MO_KOD_TFOMS ] // ��� ᮢ���⨬��� � ��ன ���ᨥ� �ࠢ�筨��

    Close databases
  Endif
  Return Nil

// 09.03.23
Function uslf_index( val_year, dir_spavoch, working_dir, flag )

  Local sbase

  Default flag To .f.
  sbase := prefixfilerefname( val_year ) + 'uslf'  // �ࠢ�筨� ��� ����� �� ������� ���
  If hb_vfExists( dir_spavoch + sbase + sdbf() )
    r_use( dir_spavoch + sbase, , 'LUSLF' )
    Index On FIELD->shifr to ( working_dir + sbase )
    Use
  Endif
  Return Nil

// 09.03.23
Function unit_index( val_year, dir_spavoch, working_dir, flag )

  Local sbase

  Default flag To .f.
  sbase := prefixfilerefname( val_year ) + 'unit'  // ����-����� �� ������� ���
  If hb_vfExists( dir_spavoch + sbase + sdbf() )
    r_use( dir_spavoch + sbase )
    Index On Str( FIELD->code, 3 ) to ( working_dir + sbase )
    Use
  Endif
  Return Nil

// 05.11.23
Function k006_index( val_year, dir_spavoch, working_dir, flag )

  Local sbase

  Default flag To .f.

  sbase := prefixfilerefname( val_year ) + 'k006'  //
  If hb_vfExists( dir_spavoch + sbase + sdbf() ) .and. hb_vfExists( dir_spavoch + sbase + sdbt() )
    r_use( dir_spavoch + sbase )
    Index On SubStr( FIELD->shifr, 1, 2 ) + FIELD->ds + FIELD->sy + FIELD->age + FIELD->sex + FIELD->los to ( working_dir + sbase ) // �� ��������/����樨
    Index On SubStr( FIELD->shifr, 1, 2 ) + FIELD->sy + FIELD->ds + FIELD->age + FIELD->sex + FIELD->los to ( working_dir + sbase + '_' ) // �� ����樨/��������
    Index On FIELD->ad_cr to ( working_dir + sbase + 'AD' ) // �� �������⥫쭮�� ����� ������
    // index on FIELD->ad_cr1 to (working_dir + sbase + 'AD1') // �� ��������� �ࠪ権, �� ����饥
    Use
  Endif
  Return Nil
