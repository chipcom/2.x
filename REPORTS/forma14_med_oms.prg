// ���ଠ�� �� �ଠ 14-��� ��� (�� ��⠬)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.04.25 �ଠ 14-��� (���)
Function forma14_med_oms()

  Static group_ini := 'f14_med_oms'
  Local begin_date, end_date, buf := SaveScreen(), arr_m, i, j, k, k1, k2, ;
    t_arr[ 10 ], t_arr1[ 10 ], name_file := cur_dir() + 'f14med.txt', tfoms_pz[ 5, 11 ], ;
    sh, HH := 80, reg_print := 5, is_trudosp, is_rebenok, is_inogoro, is_onkologia, ;
    is_reabili, is_ekstra, lshifr1, koef, vid_vp, r1 := 9, fl_exit := .f., ;
    is_vmp, d2_year, ar, arr_excel := {}, fl_error := .f., is_z_sl, ;
    cFileProtokol := cur_dir + 'tmp.txt', arr_prof := {}, arr_usl, au, ii, is_school, ;
    filetmp14 := cur_dir + 'tmp14.txt', sum_k := 0, sum_ki := 0, sum_kd := 0, sum_kt := 0, kol_d := 0, sum_d := 0
  Local arr_skor[ 81, 2 ], arr_eko[ 2, 2 ], arr_profil := {}, arr_dn_stac := {}, arrDdn_stac[ 4 ], fl_pol1[ 15 ], ;
    arr_pol[ 32 ], arr_pol1[ 15, 5 ], arr_pril5[ 32, 3 ], ifff := 0, kol_stom_pos := 0, ;
    arr_pol3000[ 29, 6 ], vr_rec := 0, arr_full_usl, ;
    fl_pol3000_PROF, fl_pol3000_DVN2 := .t.

  Local sbase
  Local lal, lalf
  Local nameArr // , funcGetPZ

  old5 := old2 := 0
  afillall( arr_skor, 0 )
  afillall( arr_eko, 0 )
  AFill( arrDdn_stac, 0 )
  AFill( arr_pol, 0 )
  afillall( arr_pril5, 0 )
  afillall( arr_pol1, 0 )
  afillall( arr_pol3000, 0 )
  arr_pol1[ 1, 1 ] := '���饭�� - �ᥣ� (02+11+13)'
  arr_pol1[ 2, 1 ] := '���饭�� � ��䨫����᪨�� � ��묨 楫ﬨ (03+06+09)'
  arr_pol1[ 3, 1 ] := '���饭�� � ��䨫����᪨�� 楫ﬨ, �ᥣ�'
  arr_pol1[ 4, 1 ] := '�� ��ப� 03 - ���饭��, �易��� � ��ᯠ��ਧ�樥�'
  arr_pol1[ 5, 1 ] := '�� ��ப� 03 - ���饭�� �� ᯥ樠�쭮�� "�⮬�⮫����"'
  arr_pol1[ 6, 1 ] := 'ࠧ��� ���饭�� � �裡 � ����������ﬨ, �ᥣ�'
  arr_pol1[ 7, 1 ] := '�� ��ப� 06 - ���饭�� �� ����'
  arr_pol1[ 8, 1 ] := '�� ��ப� 06 - ���饭�� �� ᯥ樠�쭮�� "�⮬�⮫����"'
  arr_pol1[ 9, 1 ] := '���饭�� � ��묨 楫ﬨ, �ᥣ�'
  arr_pol1[ 10, 1 ] := '�� ��ப� 09 ������⨢��� ����樭᪠� ������'
  arr_pol1[ 11, 1 ] := '���饭�� �� �������� ����� � ���⫮���� �ଥ, �ᥣ�'
  arr_pol1[ 12, 1 ] := '�� ��ப� 11 - ���饭�� �� ����'
  arr_pol1[ 13, 1 ] := '���饭��, ����祭�� � ���饭�� � �裡 � ����������ﬨ'
  arr_pol1[ 14, 1 ] := '�� ��ப� 13 - ���饭�� �� ᯥ樠�쭮�� "�⮬�⮫����"'
  arr_pol1[ 15, 1 ] := '�� ��ப� 01 - ���饭�� � �।���� ������ᮭ���'
  //
  arr_pol3000[ 1, 1 ] := '���饭�� - �ᥣ� (02+21+25)' // 1-1
  arr_pol3000[ 1, 6 ] := 1
  arr_pol3000[ 2, 1 ] := '���饭�� � ��䨫����᪨�� � ��묨 楫ﬨ (03+06)' //
  arr_pol3000[ 2, 6 ] := 2
  arr_pol3000[ 3, 1 ] := '���饭�� � ��䨫����᪨�� 楫ﬨ, �ᥣ� (04+05)'
  arr_pol3000[ 3, 6 ] := 3
  arr_pol3000[ 4, 1 ] := '�� ��ப� 03 - ���饭��, �易��� � ���ᬮ�ࠬ�'
  arr_pol3000[ 4, 6 ] := 4
  arr_pol3000[ 5, 1 ] := '�� ��ப� 03 - ���饭��, �易��� � ��ᯠ��ਧ�樥�'
  arr_pol3000[ 5, 6 ] := 5
  arr_pol3000[ 6, 1 ] := '���饭�� � ��묨 楫ﬨ, �ᥣ� (07+08+12+14+15+16+19+20)'
  arr_pol3000[ 6, 6 ] := 6
  arr_pol3000[ 7, 1 ] := '�� ��ப� 06 ���饭�� � 楫�� ��ᯠ��୮�� �������'
  arr_pol3000[ 7, 6 ] := 7
  arr_pol3000[ 8, 1 ] := '�� ��ப� 06 ���饭�� � 楫�� ��ᯠ��ਧ�樨'
  arr_pol3000[ 8, 6 ] := 8
  arr_pol3000[ 9, 1 ] := '�� ��ப� 06 ࠧ��� ���饭�� � �裡 � ����������ﬨ'
  arr_pol3000[ 9, 6 ] := 12
  arr_pol3000[ 10, 1 ] := '�� ��ப� 12 - ���饭�� �� ����'
  arr_pol3000[ 10, 6 ] := 13
  arr_pol3000[ 11, 1 ] := '�� ��ப� 06 - ���饭�� 業�஢ ��஢��'
  arr_pol3000[ 11, 6 ] := 14
  arr_pol3000[ 12, 1 ] := '�� ��ப� 06 - ���饭�� ࠡ�⭨���, � �।��� �/�'
  arr_pol3000[ 12, 6 ] := 15
  arr_pol3000[ 13, 1 ] := '�� ��ப� 06 - ���饭�� ���㫠���� ���� 業�஢'
  arr_pol3000[ 13, 6 ] := 16
  arr_pol3000[ 14, 1 ] := '�� ��ப� 12 - ���饭�� �� ᯥ樠�쭮�� "���������"'
  arr_pol3000[ 14, 6 ] := 17
  arr_pol3000[ 15, 1 ] := '�� ��ப� 13 - ���饭�� �� ᯥ樠�쭮�� "�⮬�⮫����"'
  arr_pol3000[ 15, 6 ] := 18
  arr_pol3000[ 16, 1 ] := '���饭�� � ��㣨�� 楫ﬨ, �ᥣ�'
  arr_pol3000[ 16, 6 ] := 20
  arr_pol3000[ 17, 1 ] := '���饭�� �� �������� ����� � ���⫮���� �ଥ, �ᥣ�'
  arr_pol3000[ 17, 6 ] := 21
  arr_pol3000[ 18, 1 ] := '�� ��ப� 21 - ���饭�� �� ����'
  arr_pol3000[ 18, 6 ] := 22
  arr_pol3000[ 19, 1 ] := '�� ��ப� 21 - ���饭�� �� ᯥ樠�쭮�� "�⮬�⮫����"'
  arr_pol3000[ 19, 6 ] := 24
  arr_pol3000[ 20, 1 ] := '���饭��, ����祭�� � ���饭�� � �裡 � ����������ﬨ'
  arr_pol3000[ 20, 6 ] := 25
  arr_pol3000[ 21, 1 ] := '�� ��ப� 25 - ���饭�� �� ᯥ樠�쭮�� "���������"'
  arr_pol3000[ 21, 6 ] := 26
  arr_pol3000[ 22, 1 ] := '�� ��ப� 25 - ���饭�� �� ᯥ樠�쭮�� "�⮬�⮫����"'
  arr_pol3000[ 22, 6 ] := 27
  arr_pol3000[ 23, 1 ] := ' ��'
  arr_pol3000[ 23, 6 ] := 28
  arr_pol3000[ 24, 1 ] := ' ���'
  arr_pol3000[ 24, 6 ] := 29
  arr_pol3000[ 25, 1 ] := ' ��� ���'
  arr_pol3000[ 25, 6 ] := 30
  arr_pol3000[ 26, 1 ] := ' ����᪮���᪨� ���������᪨� ��᫥�������'
  arr_pol3000[ 26, 6 ] := 31
  arr_pol3000[ 27, 1 ] := ' �������୮-������᪨� ��᫥�������'
  arr_pol3000[ 27, 6 ] := 32
  arr_pol3000[ 28, 1 ] := ' ���⮫����᪨� ��᫥�������'
  arr_pol3000[ 28, 6 ] := 33
  arr_pol3000[ 29, 1 ] := ' ����஢���� �� COVID-19'
  arr_pol3000[ 29, 6 ] := 34


  //
  arr_pril5[ 1, 1 ] := '����� �ᥣ� ,��.'
  arr_pril5[ 2, 1 ] := '��� - �맮���, ��.'
  arr_pril5[ 3, 1 ] := '��� - ���, 祫.'
  arr_pril5[ 4, 1 ] := '��� - ��.'
  arr_pril5[ 8, 1 ] := '�ᥣ� ���饭��'
  arr_pril5[ 9, 1 ] := '�ᥣ� ��室�� �� ���.������'
  arr_pril5[ 10, 1 ] := '��᫮ ���饭�� �� ������ �����������'
  arr_pril5[ 32, 1 ] := '��᫮ ���饭�� �� ������ ��ᯠ��୮�� �������'
  arr_pril5[ 11, 1 ] := '��᫮ ���饭�� � ���.(����) 楫��'
  arr_pril5[ 12, 1 ] := '��.'
  arr_pril5[ 13, 1 ] := '��᫮ ���饭�� �� ����.���.�����'
  arr_pril5[ 14, 1 ] := '��.'
  arr_pril5[ 15, 1 ] := '��樮��� - �����-����'
  arr_pril5[ 16, 1 ] := '��樮��� - ��砥� ��ᯨ⠫���樨'
  arr_pril5[ 17, 1 ] := '��樮��� - ��.'
  arr_pril5[ 18, 1 ] := '���(���) - �����-����'
  arr_pril5[ 19, 1 ] := '���(���) - ��砥� ��ᯨ⠫���樨'
  arr_pril5[ 20, 1 ] := '���(���) - ��.'
  arr_pril5[ 21, 1 ] := '���(ॠ���) - �����-����'
  arr_pril5[ 22, 1 ] := '���(ॠ���) - ��砥� ��ᯨ⠫���樨'
  arr_pril5[ 23, 1 ] := '���(ॠ���) - ��.'
  arr_pril5[ 24, 1 ] := '��.���. - ��樥��-����'
  arr_pril5[ 25, 1 ] := '��.���. - ��樥�⮢, 祫.'
  arr_pril5[ 26, 1 ] := '��.���. - ��.'
  arr_pril5[ 27, 1 ] := '��.���.��� - ��樥��-����'
  arr_pril5[ 28, 1 ] := '��.���.��� - ��樥�⮢, 祫.'
  arr_pril5[ 29, 1 ] := '��.���.��� - ��.'
  arr_pril5[ 30, 1 ] := '��� - �⥭�஢����, ������'
  arr_pril5[ 31, 1 ] := '��� - �⥭�஢���� �����த���, ������'


  // //////////////////////////////////////////////////////////////////
  arr_m := { 2025, 1, 3, '�� ﭢ��� - ���� 2025 ����', 0d20250101, 0d20250331 }  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // //////////////////////////////////////////////////////////////////
  lal := create_name_alias( 'lusl', arr_m[ 1 ] )
  lalf := create_name_alias( 'luslf', arr_m[ 1 ] )
  Private mk1, mk2, mk3, mk4, md1, md11, md12, md2, md21, md22, md3, md4
  ar := getinisect( tmp_ini, group_ini )
  mk1 := Int( Val( a2default( ar, 'mk1', '0' ) ) )
  mk2 := Int( Val( a2default( ar, 'mk2', '0' ) ) )
  mk3 := Int( Val( a2default( ar, 'mk3', '0' ) ) )
  mk4 := Int( Val( a2default( ar, 'mk4', '0' ) ) )
  md1 := Int( Val( a2default( ar, 'md1', '0' ) ) )
  md11 := Int( Val( a2default( ar, 'md11', '0' ) ) )
  md12 := Int( Val( a2default( ar, 'md12', '0' ) ) )
  md2 := Int( Val( a2default( ar, 'md2', '0' ) ) )
  md21 := Int( Val( a2default( ar, 'md21', '0' ) ) )
  md22 := Int( Val( a2default( ar, 'md22', '0' ) ) )
  md3 := Int( Val( a2default( ar, 'md3', '0' ) ) )
  md4 := Int( Val( a2default( ar, 'md4', '0' ) ) )
  box_shadow( r1, 2, 22, 77, color1, '��ଠ 14-��� ' + arr_m[ 4 ], color8 )
  tmp_solor := SetColor( cDataCGet )
  @ r1 + 1, 4 Say Center( '��樮��� (ࠧ��� II)', 72 ) Color color14
  @ r1 + 2, 4 Say '��᫮ ���� �� ����� ���⭮�� ��ਮ�� (����)      ' Get mk1 Pict '9999'
  @ r1 + 3, 4 Say '  �� ���: ��� ��⥩ (0-17 ��� �����⥫쭮) (����)' Get mk2 Pict '9999'
  @ r1 + 4, 4 Say '��᫮ ���� � �।��� �� ����� ��ਮ� (����)    ' Get mk3 Pict '9999'
  @ r1 + 5, 4 Say '  �� ���: ��� ��⥩ (0-17 ��� �����⥫쭮) (����)' Get mk4 Pict '9999'
  @ r1 + 6, 4 Say Center( '������� ��樮��� (ࠧ��� IV)', 72 ) Color color14
  @ r1 + 7, 4 Say '��᫮ ������� ��樮��஢                   ' Get md1 Pict '9999'
  @ r1 + 8, 4 Say '    �� ��� �� �������� ᯥ樠����஢����� �����' Get md11 Pict '9999' Valid md11 <= md1
  @ Row(), Col() Say ', � �.�.���' Get md12 Pict '9999' Valid md12 <= md11
  @ r1 + 9, 4 Say '  �� ��� ����뢠�騥 ������ ���� (0-17 ���)' Get md2 Pict '9999'
  @ r1 + 10, 4 Say '    �� ��� �� �������� ᯥ樠����஢����� �����' Get md21 Pict '9999' Valid md21 <= md2
  @ Row(), Col() Say ', � �.�.���' Get md22 Pict '9999' Valid md22 <= md21
  @ r1 + 11, 4 Say '��᫮ ���� �� ����� ���⭮�� ��ਮ��       ' Get md3 Pict '9999'
  @ r1 + 12, 4 Say '��᫮ ����, � �।��� �� ����� ��ਮ�    ' Get md4 Pict '9999'
  status_key( '^<Esc>^ - ��室;  ^<PgDn>^ - ᮧ����� �����' )
  myread()
  RestScreen( buf )
  If LastKey() == K_ESC
    Return Nil
  Endif
  setinisect( tmp_ini, group_ini, { { 'mk1', mk1 }, ;
    { 'mk2', mk2 }, ;
    { 'mk3', mk3 }, ;
    { 'mk4', mk4 }, ;
    { 'md1', md1 }, ;
    { 'md11', md11 }, ;
    { 'md12', md12 }, ;
    { 'md2', md2 }, ;
    { 'md21', md21 }, ;
    { 'md22', md22 }, ;
    { 'md3', md3 }, ;
    { 'md4', md4 } } )
  waitstatus( arr_m[ 4 ] )
  @ MaxRow(), 0 Say ' ����...' Color 'W/R'
  begin_date := dtoc4( arr_m[ 5 ] )
  end_date := dtoc4( arr_m[ 6 ] )
  dbCreate( cur_dir + 'tmp', { { 'nstr', 'N', 2, 0 }, ;
    { 'sum4', 'N', 15, 2 }, ;
    { 'sum5', 'N', 15, 2 }, ;
    { 'sum6', 'N', 15, 2 }, ;
    { 'sum7', 'N', 15, 2 }, ;
    { 'sum8', 'N', 15, 2 }, ;
    { 'sum9', 'N', 15, 2 } } )
  Use ( cur_dir + 'tmp' ) New Alias TMP
  Index On Str( nstr, 2 ) to ( cur_dir + 'tmp' )
  Append blank ; tmp->nstr :=  1 ; tmp->sum4 := tmp->sum5 := mk1
  Append blank ; tmp->nstr :=  2 ; tmp->sum4 := tmp->sum5 := mk2
  Append blank ; tmp->nstr :=  3 ; tmp->sum4 := tmp->sum5 := mk3
  Append blank ; tmp->nstr :=  4 ; tmp->sum4 := tmp->sum5 := mk4
  Append blank ; tmp->nstr := 46 ; tmp->sum4 := tmp->sum5 := md1 ; tmp->sum7 := md11 ; tmp->sum8 := md12
  Append blank ; tmp->nstr := 47 ; tmp->sum4 := tmp->sum5 := md2 ; tmp->sum7 := md21 ; tmp->sum8 := md22
  Append blank ; tmp->nstr := 48 ; tmp->sum4 := tmp->sum5 := md3
  Append blank ; tmp->nstr := 49 ; tmp->sum4 := tmp->sum5 := md4
  dbCreate( cur_dir + 'tmpf14', { ;
    { 'KOD_XML',  'N', 6, 0 }, ; // ��뫪� �� 䠩� 'mo_xml'
    { 'SCHET',    'N', 6, 0 }, ; //
    { 'KOD_RAK',  'N', 6, 0 }, ; // � ����� � 䠩�� RAK
    { 'KOD_RAKS', 'N', 6, 0 }, ; // � ����� � 䠩�� RAKS
    { 'KOD_RAKSH', 'N', 8, 0 }, ; // � ����� � 䠩�� RAKSH
    { 'kol_akt',  'N', 2, 0 }, ; //
    { 'usl_ok',   'N', 1, 0 }, ; //
    { 'KOD_H',    'N', 7, 0 };  // ��� ���� ��� �� �� 'human'
  } )
  Use ( cur_dir + 'tmpf14' ) New Alias TMPF14
  use_base( 'lusl' )
  use_base( 'luslf' )

  sbase := prefixfilerefname( arr_m[ 1 ] ) + 'unit'
  r_use( dir_exe() + sbase, cur_dir() + sbase, 'MOUNIT' )

  r_use( dir_server + 'mo_su',, 'MOSU' )
  r_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u_', , 'HU_' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + 'kartote_', , 'KART_' )
  r_use( dir_server + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server + 'human_2', , 'HUMAN_2' )
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To kod_k into KART
  //
  // //////////////////////////////////////////////////////////////////
  mdate_rak := arr_m[ 6 ] + 13 // �� ����� ���� ��� �㬬� � ����� 13.04.25    �᭮����� - ���쬮  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // //////////////////////////////////////////////////////////////////
  r_use( dir_server + 'mo_xml', , 'MO_XML' )
  r_use( dir_server + 'mo_rak', , 'RAK' )
  Set Relation To kod_xml into MO_XML
  r_use( dir_server + 'mo_raks', , 'RAKS' )
  Set Relation To akt into RAK
  r_use( dir_server + 'mo_raksh', , 'RAKSH' )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir + 'tmp_raksh' ) For mo_xml->DFILE <= mdate_rak
  //
  r_use( dir_server + 'schet_', , 'SCHET_' )
  r_use( dir_server + 'schet', , 'SCHET' )
  Set Relation To RecNo() into SCHET_
  ob_kol := 0
  Go Top
  Do While !Eof()
    fl := .f.
    If schet_->IS_DOPLATA == 0 .and. !Empty( Val( schet_->smo ) ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      @ MaxRow(), 0 Say PadR( AllTrim( schet_->NSCHET ) + ' �� ' + date_8( schet_->DSCHET ), 27 ) Color 'W/R'
      // ��� ॣ����樨
      mdate := date_reg_schet()
      // ��� ���⭮�� ��ਮ��
      mdate1 := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '25' ) // !!!
      //
      // 2025 ���
      k := 7 // ��� ॣ����樨 �� 07.04.25 // �᭮����� - ���쬮!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      //
      fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] + k ) .and. Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // !!���.��ਮ� 2023 ���
    Endif
    If fl
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        // �� 㬮�砭�� ����祭, �᫨ ���� ��� ����
        koef := 1 ; k := j := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While human->kod == raksh->kod_h .and. !Eof()
          If !Empty( raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP )
            ++j
          Endif
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          Skip
        Enddo
        If !Empty( Round( k, 2 ) )
          If Empty( human->cena_1 ) // ᪮�� ������
            koef := 0
          Elseif round_5( human->cena_1, 2 ) <= round_5( k, 2 ) // ������ ��⨥
            koef := 0
          Else // ���筮� ��⨥
            koef := ( human->cena_1 - k ) / human->cena_1
          Endif
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          Do While human->kod == raksh->kod_h .and. !Eof()
            If !Empty( raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP )
              Select TMPF14
              Append Blank
              tmpf14->KOD_XML   := rak->kod_xml
              tmpf14->SCHET     := schet->kod
              tmpf14->KOD_RAK   := raks->AKT
              tmpf14->KOD_RAKS  := raksh->KOD_RAKS
              tmpf14->KOD_RAKSH := raksh->( RecNo() )
              tmpf14->KOD_H     := human->kod
              tmpf14->kol_akt   := j
              tmpf14->usl_ok    := iif( schet_->BUKVA == 'T', 5, human_->USL_OK )
            Endif
            Select RAKSH
            Skip
          Enddo
        Endif
        If koef > 0
          AFill( fl_pol1, 0 )
          is_vmp := ( human_2->VMP == 1 )
          is_trudosp := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data, 4 ) // ����஥� �� 2023-2024 ���
          is_reabili := ( human_->PROFIL == 158 )
          is_rebenok := ( human->VZROS_REB > 0 )
          is_inogoro := ( Int( Val( schet_->smo ) ) == 34 )
          igs := iif( f_is_selo( kart_->gorod_selo, kart_->okatog ), 3, 2 )
          If !( fl_stom := ( schet_->BUKVA == 'T' ) ) // �⮬�⮫���� � �⤥�쭮� ⠡���
            arr_pril5[ 1, igs ] += Round( human->cena_1 * koef, 2 )
          Endif
          If schet_->BUKVA == 'K' // �⤥��� ����樭᪨� ��㣨 ���뢠�� ⮫쪮 �㬬�� d 14-� �ଥ
            arr_pol1[ 6, 4 ] += Round( human->cena_1 * koef, 2 )
            If is_inogoro
              arr_pol1[ 6, 5 ] += Round( human->cena_1 * koef, 2 )
            Endif
            // ⥯��� ����� �� ��㣠�
            svp := Space( 5 )
            vr_rec := hu->( RecNo() )
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
                lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              Endif
              If PadR( AllTrim( lshifr ), 5 ) == '60.4.'
                // KT
                arr_pol3000[ 23, 4 ] += Round( hu->stoim_1 * koef, 2 )
                arr_pol3000[ 23, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 23, 5 ] += Round( hu->stoim_1 * koef, 2 )
                  arr_pol3000[ 23, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.5.'
                // ���
                arr_pol3000[ 24, 4 ] += Round( hu->stoim_1 * koef, 2 )
                arr_pol3000[ 24, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 24, 5 ] += Round( hu->stoim_1 * koef, 2 )
                  arr_pol3000[ 24, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.6.'
                // ��� ���
                arr_pol3000[ 25, 4 ] += Round( hu->stoim_1 * koef, 2 )
                arr_pol3000[ 25, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 25, 5 ] += Round( hu->stoim_1 * koef, 2 )
                  arr_pol3000[ 25, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.7.'
                // ' ����᪮���᪨� ���������᪨� ��᫥�������'
                arr_pol3000[ 26, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 26, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 26, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 26, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.9.'
                // ' �������୮-������᪨� ��᫥�������'
                arr_pol3000[ 27, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 27, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 27, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 27, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.8.'
                // ' ���⮫����᪨� ��᫥�������'
                arr_pol3000[ 28, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 28, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 28, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 28, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Endif
              Skip
            Enddo
            Select HU
            Goto ( vr_rec )
            Select HUMAN
          Endif
          //
          If human_->USL_OK == 3 // ⮫쪮 �����������
            // if !eq_any(schet_->BUKVA,'K','T','S','Z','M','H')
            // ⥯��� ����� �� ��㣠�
            svp := Space( 5 )
            vr_rec := hu->( RecNo() )
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
                lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              Endif
              If eq_any( PadR( AllTrim( lshifr ), 8 ), ;
                  '2.79.34 ', '2.79.37 ', '2.79.38 ', ;
                  '2.79.49 ', '2.79.50 ', '2.79.63 ', ;
                  '2.79.64 ', '2.88.35 ', '2.88.36 ', ;
                  '2.79.37 ', '2.88.50 ', '2.88.54 ', ;
                  '2.88.116', '2.88.117', '2.88.118' )
                // '�� ��ப� 06 - ���饭�� ࠡ�⭨���, � �।��� �/�'
                arr_pol3000[ 12, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 12, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 12, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 12, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 8 ) == '2.88.107'
                // '�� ��ப� 06 - ���饭�� ���㫠���� ���� 業�஢'
                arr_pol3000[ 13, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 13, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 13, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 13, 3 ] += 1
                Endif
              Elseif eq_any( PadR( AllTrim( lshifr ), 8 ), ;
                  '2.88.24 ', '2.88.25 ', '2.88.104', ;
                  '2.81.24 ', '2.81.25 ', '2.81.26 ', ;
                  '2.81.27 ', '2.81.28 ', '2.81.29 ', ;
                  '2.81.30 ', '2.81.31 ', '2.81.32 ', ;
                  '2.81.33 ', '2.81.45 ', '2.88.104' )
                // '�� ��ப� 12 - ���饭�� �� ᯥ樠�쭮�� '���������''
                arr_pol3000[ 14, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 14, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 14, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 14, 3 ] += 1
                Endif
              Elseif eq_any( Left( lshifr, 5 ), '2.79.', '2.76.' )
                // '���饭�� � ��㣨�� 楫ﬨ, �ᥣ�'
                If eq_any( PadR( AllTrim( lshifr ), 7 ), ;
                    '2.79.34', '2.79.37', '2.79.38', ;
                    '2.79.49', '2.79.50', '2.79.59', ;
                    '2.79.60', '2.79.61', '2.79.62', ;
                    '2.79.63', '2.79.64' )
                Else
                  arr_pol3000[ 16, 4 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 16, 2 ] += 1
                  If is_inogoro
                    arr_pol3000[ 16, 5 ] += Round( human->cena_1 * koef, 2 )
                    arr_pol3000[ 16, 3 ] += 1
                  Endif
                Endif
              Elseif eq_any( PadR( AllTrim( lshifr ), 8 ), ;
                  '2.78.61 ', '2.78.62 ', '2.78.63 ', ;
                  '2.78.64 ', '2.78.65 ', '2.78.66 ', ;
                  '2.78.67 ', '2.78.68 ', '2.78.69 ', ;
                  '2.78.70 ', '2.78.71 ', '2.78.72 ', ;
                  '2.78.73 ', '2.78.74 ', '2.78.75 ', ;
                  '2.78.76 ', '2.78.77 ', '2.78.78 ', ;
                  '2.78.79 ', '2.78.80 ', '2.78.81 ', ;
                  '2.78.82 ', '2.78.83 ', '2.78.84 ', ;
                  '2.78.85 ', '2.78.86 ', ;
                  '2.78.109', '2.78.110', '2.78.111', '2.78.112' )
                // '�� ��ப� 06 ���饭�� � 楫�� ��ᯠ��୮�� �������'
                If eq_any( PadR( AllTrim( lshifr ), 8 ), '2.78.109', '2.78.110', '2.78.111', '2.78.112' )
                  arr_pol3000[ 7, 4 ] += Round( human->cena_1 * koef, 2 )
                  If is_inogoro
                    arr_pol3000[ 7, 5 ] += Round( human->cena_1 * koef, 2 )
                  Endif
                Else
                  arr_pol3000[ 7, 4 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 7, 2 ] += 1
                  If is_inogoro
                    arr_pol3000[ 7, 5 ] += Round( human->cena_1 * koef, 2 )
                    arr_pol3000[ 7, 3 ] += 1
                  Endif
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '2.60.'
                If eq_any( human_->pztip, 38, 42, 43, 44, ) // ⮫쪮 2024 ���
                  // '2.78.109', '2.78.110','2.78.111','2.78.112')
                  // '�� ��ப� 06 ���饭�� � 楫�� ��ᯠ��୮�� �������'
                  // ⮫쪮 ���饭��
                  arr_pol3000[ 7, 2 ] += 1
                  If is_inogoro
                    arr_pol3000[ 7, 3 ] += 1
                  Endif
                Endif
              Endif
              Skip
            Enddo
            Select HU
            Goto ( vr_rec )
            Select HUMAN
            // endif // ���� ��⮢ !�
          Endif
          //
          is_dializ := .f.
          is_z_sl := .f.
          is_ekstra := .f.
          is_centr_z := .f.
          is_s_obsh := .f.
          is_disp_nabluden := .f.
          is_kt := .f.
          is_school := .f.
          is_prvs_206 := ( ret_new_prvs( human_->prvs ) == 206 ) // ��祡��� ����
          kol_2_3 := kol_2_6 := kol_2_60 := kol_sr := kol_2_sr := 0
          isp := 1
          is_sred_stom := .f.
          ds_spec := ds1_spec := kol_stom := kol_dializ := 0
          vid_vp := 0 // �� 㬮�砭�� ��䨫��⨪�
          d2_year := Year( human->k_data )
          If human_->USL_OK == 1 // ��樮���
            //
          Elseif human_->USL_OK == 2 // ������� ��樮���
            is_ekstra := ( human_->PROFIL == 137 )
          Elseif human_->USL_OK == 3 // �����������
            vid_vp := -1
          Elseif human_->USL_OK == 4 // ᪮�� ������
            i := Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) )
            isp := iif( i == 0, 1, 2 )
          Endif
          afillall( tfoms_pz, 0 )
          ap := {}
          arr_usl := {} ; au := {}
          arr_full_usl := {}
          lvidpom := 1
          lvidpoms := ''
          svp := Space( 5 )
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              AAdd( arr_full_usl, lshifr )
              ta := f14tf_nastr( @lshifr, , d2_year )
              lshifr := AllTrim( lshifr )
              AAdd( au, { lshifr, hu->kol_1, Round( hu->stoim_1 * koef, 2 ), 0, 0, hu->kol_1 } )
              i16 := 0
              dbSelectArea( lal )
              find ( PadR( lshifr, 10 ) )
              If Found() .and. !Empty( &lal.->unit_code )
                Select MOUNIT    // !!! ��������
                find ( Str( &lal.->unit_code, 3 ) )
                If Found() .and. mounit->pz > 0
                  If ( i16 := mounit->ii ) > 0
                    nameArr := get_array_pz( year( human->k_data ) )
                    j1 := nameArr[ i16, 2 ] // j1 := nameArr[i16, 1]

                    If eq_any( j1, 30 )  // � 2023-68  75 �ࠫ - �� ���� �⮬ //09.07.23
                      vid_vp := 0 // ���饭�� ��䨫����᪮�
                    Elseif eq_any( j1, 31 ) // � 2023-69 76 �ࠫ - �� ���� �⮬//09.07.23
                      vid_vp := 1 // � ���⫮���� �ଥ
                    Elseif eq_any( j1, 32, 322, 323 )  // � 2023 (70, 91, 92) 77 �ࠫ - �� ���� �⮬ //09.07.23
                      vid_vp := 2 // ���饭�� � ��祡��� 楫��
                    Elseif j1 == 38 // 2023 -71
                      is_centr_z := .t.
                      vid_vp := 0 // ���饭�� ��䨫����᪮� ����� ���஢��
                    Elseif eq_any( j1, 261, 262, 318, 319, 320, 321, 512, 513, 670, 671 )  // 2023- 73, 74, 87, 88, 89, 90, 59, 78 �.�.   //09.07.23
                      // ��������� � ९த�⨢���� ���஢��
                      vid_vp := 0 // �������᭮� ���饭�� �� ��ᯠ��ਧ�樨
                      is_z_sl := .t.
                      fl_pol3000_DVN2 := .f.
                      // ��⠢��� ������� �� ����������
                      fl_pol3000_DVN2 := .t.
                      If j1 == 262 // ��� - 2 �⠯
                        fl_pol3000_DVN2 := .f.
                      Endif
                      //
                    Elseif eq_any( j1, 206, 153, 69, 148, 149, 150, 151, 161, 162 )  .or. Between( j1, 324, 329 ) // ��᫥�������
                      is_kt := .t.
                      ds1_spec := 1
                      vid_vp := 2 // � ��祡��� 楫��
                    Elseif eq_any( j1, 205, 388, 259 )
                      is_dializ := .t.
                      // elseif   57 - ॠ�������
                    Elseif j1 == 583 // 583 - 誮�� �� ������ - ���饭�� ��䨫����᪮�
                      vid_vp := 0 // ���饭�� ��䨫����᪮�
                      is_school := .t.
                    Endif
                  Endif
                Endif
                Select HU
              Endif
              If human_->USL_OK == 1 // ��樮���
                If Left( lshifr, 5 ) == '1.11.'
                  kol_dializ += hu->kol_1 // �����-����
                Endif
              Elseif human_->USL_OK == 2  // ������� ��樮���
                If Left( lshifr, 5 ) == '60.3.'
                  is_dializ := .t.
                  kol_dializ += hu->kol_1
                Endif
                AAdd( arr_usl, lshifr )
                // aadd(arr_full_usl,lshifr)
                If !Empty( svp ) .and. ',' $ svp
                  lvidpoms := svp
                Endif
                If ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
                  lvidpom := i
                Endif
              Elseif eq_any( Left( lshifr, 5 ), '2.78.', '2.89.' ) // ���饭�� � ��祡��� 楫��
                If  eq_any( Left( lshifr, 8 ), '2.78.107', '2.78.109', '2.78.110', '2.78.111', '2.78.112' )// ��ᯠ��୮� �������
                  // ��ᯠ��୮� �������
                  is_disp_nabluden := .t.
                Endif
                vid_vp := 2 // ���饭�� � ��祡��� 楫��
                If lshifr == '2.78.2'
                  is_s_obsh := .t. // ��� ��饩 �ࠪ⨪�
                Elseif eq_any( lshifr, '2.78.36', '2.78.39', '2.78.40' )
                  kol_sr += hu->kol_1
                Endif
                If Left( lshifr, 5 ) == '2.89.'
                  ds_spec := 1 // ��ࢨ筠� ᯥ樠����஢�����
                  is_reabili := .t.
                Elseif !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87 )
                  ds_spec := 1
                Endif
                // �ਧ��� ���������
                // if eq_any(lshifr, '2.78.19', '2.78.45', '2.78.87', '2.78.90', '2.78.91')
                //
                // endif
              Endif
              If f_is_zak_sl_vr( lshifr )
                is_z_sl := .t.
              Endif
              //
              If eq_any( Left( lshifr, 4 ), '2.6.', '2.60' )
                kol_stom += hu->kol_1
              Endif
              // ���������
              If eq_any( lshifr, '2.3.3', '2.3.4', '2.60.3', '2.60.4' ) // 䥫���᪨� ����
                fl_pol1[ 15 ] := -1
              Endif
              If eq_any( lshifr, '2.78.60', '2.79.63', '2.79.64', '2.80.38', '2.88.50' ) // �㡭�� ��� (�।��� ���.���ᮭ��)
                fl_pol1[ 15 ] := -1
                is_sred_stom := .t.
              Endif
              If Left( lshifr, 5 ) == '2.80.' .and. hu->KOL_RCP < 0 // ���饭�� � ���⫮���� �ଥ �� ����
                fl_pol1[ 12 ] += hu->kol_1
              Endif
              If Left( lshifr, 5 ) == '2.88.' .and. hu->KOL_RCP < 0 // ࠧ���� ���饭�� �� ����
                fl_pol1[ 7 ] += hu->kol_1
              Endif
              //
              For j := 1 To Len( ta )
                k := ta[ j, 1 ]
                mkol1 := 0
                If Between( k, 1, 10 )
                  If ta[ j, 2 ] == 1 // �����祭�� ��砩 ��樮���
                    mkol := human->k_data - human->n_data  // �����-����
                  Elseif ta[ j, 2 ] == 0
                    mkol := hu->kol_1
                  Else
                    mkol := 0
                    mkol1 := hu->kol_1
                  Endif
                  muet := 0
                  msum := Round( hu->stoim_1 * koef, 2 )
                  //
                  ii := 0
                  is_obsh := .f.
                  If k == 2 // ��樮���
                    ii := 1
                  Elseif k == 1 // �����������
                    ii := 2
                    AAdd( arr_usl, Left( lshifr, 5 ) )
                    If Left( lshifr, 2 ) == '2.'
                      If Left( lshifr, 4 ) == '2.3.'
                        kol_2_3 += hu->kol_1
                        If eq_any( lshifr, '2.3.3', '2.3.4' )
                          kol_2_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 4 ) == '2.6.'
                        kol_2_6 += hu->kol_1
                      Elseif Left( lshifr, 5 ) == '2.60.'
                        kol_2_60 += hu->kol_1
                        If eq_any( lshifr, '2.60.3', '2.60.4' )
                          kol_2_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.76.' // 業�� ���஢��
                        vid_vp := 0 // ���饭�� ��䨫����᪮�
                        // !!!
                        arr_pol3000[ 11, 4 ] := Round( human->cena_1 * koef, 2 )
                        arr_pol3000[ 11, 2 ] := 1
                        If is_inogoro
                          arr_pol3000[ 11, 5 ] := Round( human->cena_1 * koef, 2 )
                          arr_pol3000[ 11, 3 ] := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.92.' // 誮�� ��୮�� ������
                        vid_vp := 0 // ���饭�� ��䨫����᪮�
                        // !!!
                        arr_pol3000[ 11, 4 ] := Round( human->cena_1 * koef, 2 )
                        arr_pol3000[ 11, 2 ] := 1
                        If is_inogoro
                          arr_pol3000[ 11, 5 ] := Round( human->cena_1 * koef, 2 )
                          arr_pol3000[ 11, 3 ] := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.79.' // ���饭�� � ��䨫����᪮� 楫��
                        vid_vp := 0 // ���饭�� ��䨫����᪮�
                        If !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87 )
                          ds1_spec := 1 // ��ࢨ筠� ᯥ樠����஢�����
                        Endif
                        If eq_any( lshifr, '2.79.2', '2.79.45' )
                          is_obsh := .t.
                        Endif
                        If eq_any( lshifr, '2.79.34', '2.79.37', '2.79.38', '2.79.49', '2.79.50' )
                          kol_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.80.' // � ���⫮���� �ଥ
                        vid_vp := 1 // � ���⫮���� �ଥ
                        If !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87, 160 )
                          ds1_spec := 1
                        Endif
                        // if lshifr == '2.80.2' - ��� ⠪�� ��㣨
                        // is_obsh := .t.
                        // endif
                        // if eq_any(lshifr,'2.80.19','2.80.22','2.80.23','2.80.27') - ��㣨 㤠����
                        If eq_any( lshifr, '2.80.53', '2.80.54' ) // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                          kol_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.81.' // �������樨 ᯥ樠���⮢
                        vid_vp := 0 // ���饭�� ��䨫����᪮�
                        If !eq_any( human_->PROFIL, 68, 97 )
                          ds1_spec := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.82.' // ���饭�� � ��񬭮� ����� (� ���⫮���� �ଥ)
                        vid_vp := 1 // � ���⫮���� �ଥ
                        If !eq_any( human_->PROFIL, 57, 68, 97 )
                          ds1_spec := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.83.' // ��ᯠ��ਧ��� ��⥩-���
                        If lshifr == '2.83.15'
                          is_obsh := .t.
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.88.' // ࠧ���� ���饭��
                        vid_vp := 0 // ���饭�� ��䨫����᪮�
                        If !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87 )
                          ds1_spec := 1
                        Endif
                        If eq_any( lshifr, '2.88.3' ) // ,'2.88.53','2.88.79' - ��� ���
                          is_obsh := .t.
                        Endif
                        If eq_any( lshifr, '2.88.35', '2.88.36', '2.88.37' )
                          kol_sr += hu->kol_1
                        Endif
                      Endif
                    Elseif Left( lshifr, 5 ) == '60.3.'
                      is_dializ := .t.
                    Endif
                    If i16 > 0
                      AAdd( ap, { lshifr, iif( Empty( mkol ), mkol1, mkol ), is_obsh } )
                    Endif
                  Elseif k == 7 // ��.���.��㣨
                    If glob_mo[ _MO_KOD_TFOMS ] == '171004' .and. human_->USL_OK == 1 // ��樮��� ��4
                      ii := 1 // ��樮���
                    Else
                      ii := 2 // � �����������
                      mkol := 0  // ������ �� ������⢮�, � ⮫쪮 �㬬��
                      is_kt := .t.
                      ds1_spec := 1
                    Endif
                  Elseif k == 8 // ���
                    ii := 5
                  Elseif eq_any( k, 3, 4, 5 ) // ������� ��樮���
                    ii := 4
                    If Left( lshifr, 5 ) == '55.1.'
                      //
                    Else
                      mkol := 0
                    Endif
                  Endif
                  If is_dializ
                    If human_->USL_OK == 1 // ��樮���
                      ii := 1
                    Elseif human_->USL_OK == 2 // ������� ��樮���
                      ii := 4
                    Elseif human_->USL_OK == 3 // �����������
                      ii := 2
                      mkol := 1
                      ds_spec := ds1_spec := 1
                      vid_vp := 2 // �� ������ �����������
                    Endif
                  Endif
                  If fl_stom // �⮬�⮫����
                    //
                  Elseif ii > 0
                    tfoms_pz[ ii, 1 ] := 1
                    tfoms_pz[ ii, 2 ] += mkol
                    tfoms_pz[ ii, 3 ] += msum
                    If is_vmp
                      tfoms_pz[ ii, 9 ] := 1
                      tfoms_pz[ ii, 10 ] += mkol
                      tfoms_pz[ ii, 11 ] += msum
                    Endif
                    If ii == 2 // �����������
                      If is_obsh
                        tfoms_pz[ ii, 7 ] += mkol
                        tfoms_pz[ ii, 8 ] += msum
                        If ds1_spec == 1
                          tfoms_pz[ ii, 9 ] += mkol
                          tfoms_pz[ ii, 10 ] += msum
                        Endif
                      Else
                        If ds1_spec == 1
                          tfoms_pz[ ii, 5 ] += mkol
                          tfoms_pz[ ii, 6 ] += msum
                        Endif
                      Endif
                    Endif
                  Endif
                Endif
              Next j
            Endif
            Select HU
            Skip
          Enddo
          If kol_dializ > 0
            tfoms_pz[ ii, 2 ] := kol_dializ // �����塞 �� ���-�� ��������� ��楤��
          Endif
          ta := {}
          If fl_stom // �⮬�⮫����
            tfoms_pz[ 1, 1 ] := 0
            tfoms_pz[ 2, 1 ] := 0
            tfoms_pz[ 3, 1 ] := 1
            tfoms_pz[ 4, 1 ] := 0
            tfoms_pz[ 5, 1 ] := 0
          Endif
          Do Case
            // ��樮���
          Case tfoms_pz[ 1, 1 ] > 0
            tfoms_pz[ 1, 2 ] := kol_dializ
            If ( i := AScan( arr_profil, {| x| x[ 1 ] == human_->PROFIL } ) ) == 0
              AAdd( arr_profil, { human_->PROFIL, 0, 0, 0, 0 } ) ; i := Len( arr_profil )
            Endif
            If human->ishod == 88 // �� 1-� �/� � ������� ��砥
              tfoms_pz[ 1, 1 ] := 0
            Else
              arr_profil[ i, 2 ] ++
            Endif
            arr_profil[ i, 3 ] += Round( human->cena_1 * koef, 2 )
            If is_inogoro
              arr_profil[ i, 4 ] ++; arr_profil[ i, 5 ] += Round( human->cena_1 * koef, 2 )
            Endif
            arr_pril5[ 15, igs ] += tfoms_pz[ 1, 2 ] // '��樮��� - �����-����'
            arr_pril5[ 16, igs ] += tfoms_pz[ 1, 1 ] // '��樮��� - ��砥� ��ᯨ⠫���樨'
            arr_pril5[ 17, igs ] += tfoms_pz[ 1, 3 ] // '��樮��� - ��.'
            If is_vmp
              arr_pril5[ 18, igs ] += tfoms_pz[ 1, 2 ] // ���(���) - �����-����'
              arr_pril5[ 19, igs ] += tfoms_pz[ 1, 1 ] // ���(���) - ��砥� ��ᯨ⠫���樨'
              arr_pril5[ 20, igs ] += tfoms_pz[ 1, 3 ] // ���(���) - ��.'
            Endif
            AAdd( ta, { 5, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
            AAdd( ta, { 10, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            If is_rebenok
              AAdd( ta, { 6, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 11, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            If is_trudosp
              AAdd( ta, { 7, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 12, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            If is_reabili
              arr_pril5[ 21, igs ] += tfoms_pz[ 1, 2 ] // '���(ॠ���) - �����-����'
              arr_pril5[ 22, igs ] += tfoms_pz[ 1, 1 ] // '���(ॠ���) - ��砥� ��ᯨ⠫���樨'
              arr_pril5[ 23, igs ] += tfoms_pz[ 1, 3 ] // '���(ॠ���) - ��.'
              AAdd( ta, { 8, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 13, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            If is_inogoro
              AAdd( ta, { 9, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 14, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            // �����������
          Case tfoms_pz[ 2, 1 ] > 0
            arr_pril5[ 9, igs ] += Round( human->cena_1 * koef, 2 ) // '�ᥣ� ��室�� �� ���.������'
            If is_kt // ��� �� ����塞 ������⢮
              tfoms_pz[ ii, 1 ] := tfoms_pz[ ii, 2 ] := tfoms_pz[ ii, 5 ] := tfoms_pz[ ii, 7 ] := tfoms_pz[ ii, 9 ] := 0
            Elseif is_dializ // ����.������
              vid_vp := 2 // �� ������ �����������
              ds_spec := 1
            Endif
            If kol_2_60 > 0 .and. AScan( arr_usl, '2.78.' ) > 0
              arr_pril5[ 8, igs ] += kol_2_60 // '�ᥣ� ���饭��'
              // //////////////////////////////////////////////
            Endif
            If kol_2_60 > 0 .and. AScan( arr_usl, '2.78.' ) > 0
              arr_pril5[ 8, igs ] += kol_2_60 // '�ᥣ� ���饭��'
              // //////////////////////////////////////////////
            Endif
            // ��������� � �.3000
            If kol_2_60 > 0 // .and. ;
              If eq_ascan( arr_full_usl, '2.78.19', '2.78.45', '2.78.87', '2.78.90', '2.78.91' )
                arr_pol3000[ 21, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 21, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 21, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 21, 3 ] += 1
                Endif
              Endif
            Endif
            If schet_->BUKVA == 'O'  // ��ᯠ��ਧ��� 2-� �⠯
              If AScan( arr_usl, '2.84.' ) > 0 .or. AScan( arr_full_usl, '56.1.723' ) > 0
                arr_pol3000[ 8, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 8, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 8, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 8, 3 ] += 1
                Endif
              Endif
            Endif
            //
            If kol_2_6 > 0 .and. AScan( arr_usl, '2.89.' ) > 0
              arr_pril5[ 8, igs ] += kol_2_6 // '�ᥣ� ���饭��'
            Endif
            fl := eq_any( schet_->BUKVA, 'A', 'K' )
            If schet_->BUKVA == 'K'
              vid_vp := 2 // �� ������ �����������
              ds1_spec := 1
              sum_k += tfoms_pz[ 2, 3 ]
              If is_rebenok
                sum_kd += tfoms_pz[ 2, 3 ]
              Endif
              If is_trudosp
                sum_kt += tfoms_pz[ 2, 3 ]
              Endif
              If is_inogoro
                sum_ki += tfoms_pz[ 2, 3 ]
              Endif
            Endif
            If vid_vp == 1 // � ���⫮���� �ଥ
              fl_pol1[ 11 ] += tfoms_pz[ 2, 2 ]
              arr_pril5[ 8, igs ] += tfoms_pz[ 2, 2 ] // '�ᥣ� ���饭��'
              arr_pril5[ 13, igs ] += tfoms_pz[ 2, 2 ] // '��᫮ ���饭�� �� ����.���.�����'
              arr_pril5[ 14, igs ] += tfoms_pz[ 2, 3 ] // '��.'
              AAdd( ta, { 22, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 24
              AAdd( ta, { 23, tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 9 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 10 ] } ) // 25
              If fl
                arr_pol[ 22 ] += tfoms_pz[ 2, 3 ]
                arr_pol[ 23 ] += tfoms_pz[ 2, 8 ]
              Endif
              If is_rebenok
                AAdd( ta, { 24, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 26
                If fl
                  arr_pol[ 24 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_trudosp
                AAdd( ta, { 25, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 27
                If fl
                  arr_pol[ 25 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_inogoro
                AAdd( ta, { 26, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 28
                If fl
                  arr_pol[ 26 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
            Elseif vid_vp == 2 // �� ������ �����������
              fl_pol1[ 13 ] := -1
              If is_disp_nabluden
                arr_pril5[ 32, igs ] += tfoms_pz[ 2, 1 ] // '��᫮ ���饭�� �� ������ �����������'
              Else
                arr_pril5[ 10, igs ] += tfoms_pz[ 2, 1 ] // '��᫮ ���饭�� �� ������ �����������'
                AAdd( ta, { 27, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                If fl
                  arr_pol[ 27 ] += tfoms_pz[ 2, 3 ]
                Endif
                If is_s_obsh
                  AAdd( ta, { 28, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 28 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_rebenok
                  AAdd( ta, { 29, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 29 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_trudosp
                  AAdd( ta, { 30, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 30 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_reabili
                  AAdd( ta, { 31, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 31 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_inogoro
                  AAdd( ta, { 32, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 32 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
              Endif
            Elseif vid_vp == 0 // ��䨫��⨪�
              tfoms_pz[ 2, 2 ] := tfoms_pz[ 2, 7 ] := tfoms_pz[ 2, 9 ] := tfoms_pz[ 2, 5 ] := 0 // ���㫨� ������⢮ �ਥ���
              If eq_any( schet_->BUKVA, 'O', 'F', 'R', 'D', 'U', 'W', 'Y', 'I', 'V' ) // ��ᯠ��ਧ��� � ���ᬮ��� + 㣫㡫����� + ९த�⨢�� 09.07.24
                lshifr := '���-��' ; lkol := 1
                If ( j := AScan( arr_prof, {| x| x[ 1 ] == lshifr } ) ) == 0
                  AAdd( arr_prof, { lshifr, 0 } ) ; j := Len( arr_prof )
                Endif
                arr_prof[ j, 2 ] += lkol
                //
                tfoms_pz[ 2, 2 ] += lkol
                If is_prvs_206 // ��祡��� ���� � ��ᯠ��ਧ�樨
                  fl_pol1[ 15 ] += lkol
                Endif
                // �࠯���, �������, ��� ��饩 �ࠪ⨪�, 䥫��� �� ��ᯠ��ਧ�樨
                fl_pol1[ 3 ] += lkol
                fl_pol1[ 4 ] += lkol
                fl_pol3000_PROF := .f.
                If eq_any( schet_->BUKVA, 'F', 'R' ) // ��ᯠ��ਧ��� � ���ᬮ���
                  fl_pol3000_PROF := .t.
                Else
                  fl_pol3000_PROF := .f.
                Endif
              Else
                For i := 1 To Len( ap )
                  lshifr := ap[ i, 1 ] ; lkol := ap[ i, 2 ]
                  If ( j := AScan( arr_prof, {| x| x[ 1 ] == lshifr } ) ) == 0
                    AAdd( arr_prof, { lshifr, 0 } ) ; j := Len( arr_prof )
                  Endif
                  arr_prof[ j, 2 ] += lkol
                  //
                  tfoms_pz[ 2, 2 ] += lkol
                  If ap[ i, 3 ] // is_obsh
                    tfoms_pz[ 2, 7 ] += lkol
                    If ds1_spec == 1
                      tfoms_pz[ 2, 9 ] += lkol
                    Endif
                  Else
                    If ds1_spec == 1
                      tfoms_pz[ 2, 5 ] += lkol
                    Endif
                  Endif
                  If eq_any( Left( lshifr, 5 ), '2.79.', '2.76.' ) // ��䨫��⨪� � 業��� ���஢��
                    If between_shifr( lshifr, '2.79.44', '2.79.50' )  // ���஭��
                      fl_pol1[ 9 ] += lkol
                      If eq_any( human_->profil, 49, 53, 54 ) // ������⨢��� ����樭᪠� ������
                        fl_pol1[ 10 ] += lkol
                      Endif
                    Else
                      fl_pol1[ 3 ] += lkol
                    Endif
                  Endif
                  If eq_any( lshifr, '2.79.34', '2.79.37', '2.79.38', '2.79.49', '2.79.50', ; // 䥫���᪨� ����
                    '2.79.63', '2.79.64', '2.88.50', ;
                      '2.80.19', '2.80.22', '2.80.23', '2.80.27', ;
                      '2.88.35', '2.88.36', '2.88.37', '2.90.2' )
                    fl_pol1[ 15 ] += lkol
                  Endif
                  If eq_any( Left( lshifr, 5 ), '2.88.', '2.81.' ) // ࠧ���� ���饭�� ��� �������樨
                    fl_pol1[ 6 ] += lkol
                  Endif
                Next
              Endif
              If is_z_sl .and. tfoms_pz[ 2, 2 ] > 0
                tfoms_pz[ 2, 3 ] := Round( human->cena_1 * koef, 2 )
                If ds1_spec == 1
                  tfoms_pz[ 2, 6 ] := Round( human->cena_1 * koef, 2 )
                Endif
                If is_obsh
                  tfoms_pz[ 2, 8 ] := Round( human->cena_1 * koef, 2 )
                  If ds1_spec == 1
                    tfoms_pz[ 2, 10 ] := Round( human->cena_1 * koef, 2 )
                  Endif
                Endif
              Endif
              If eq_any( schet_->BUKVA, 'G', 'J', 'D', 'O', 'R', 'F', 'V', 'I', 'U' )
                kol_d += tfoms_pz[ 2, 2 ]
                sum_d += tfoms_pz[ 2, 3 ]
              Endif
              arr_pril5[ 8, igs ] += tfoms_pz[ 2, 2 ] // '�ᥣ� ���饭��'
              arr_pril5[ 11, igs ] += tfoms_pz[ 2, 2 ] // '��᫮ ���饭�� � ���.(����) 楫��'
              arr_pril5[ 12, igs ] += tfoms_pz[ 2, 3 ] // '��.'
              AAdd( ta, { 15, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
              AAdd( ta, { 16, tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 9 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 10 ] } )
              If fl
                arr_pol[ 15 ] += tfoms_pz[ 2, 3 ]
                arr_pol[ 16 ] += tfoms_pz[ 2, 8 ]
              Endif
              If is_centr_z
                AAdd( ta, { 17, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 17 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_rebenok
                AAdd( ta, { 18, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 18 ] += tfoms_pz[ 2, 3 ]
                Endif
                If is_centr_z
                  AAdd( ta, { 19, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                  If fl
                    arr_pol[ 19 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
              Endif
              If is_trudosp
                AAdd( ta, { 20, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 20 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_inogoro
                AAdd( ta, { 21, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 21 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
            Endif
            // �⮬�⮫����
          Case tfoms_pz[ 3, 1 ] > 0
            au_flu := {} ; muet := 0
            Select MOHU
            find ( Str( human->kod, 7 ) )
            Do While mohu->kod == human->kod .and. !Eof()
              AAdd( au_flu, { mosu->shifr1, ;         // 1
              c4tod( mohu->date_u ), ;  // 2
              mohu->profil, ;         // 3
              mohu->PRVS, ;           // 4
              mosu->shifr, ;          // 5
              mohu->kol_1, ;          // 6
              c4tod( mohu->date_u2 ), ; // 7
              mohu->kod_diag } )       // 8
              dbSelectArea( lalf )
              find ( mosu->shifr1 )
              muet += round_5( mohu->kol_1 * iif( human->vzros_reb == 0, &lalf.->uetv, &lalf.->uetd ), 2 )
              Select MOHU
              Skip
            Enddo
            tfoms_pz[ 3, 4 ] := muet
            ret_tip := 0
            // 1 � ��祡��� 楫��
            // 2 � ��䨫����᪮� 楫��
            // 2  -- ' -- ' -- ' -- ' -- ࠧ���� �� ������ �����������
            // 3 �� �������� ���⫮���� �����
            ret_kol := 0
            is_2_88 := .f.
            f_vid_p_stom( au, {},,, human->k_data, @ret_tip, @ret_kol, @is_2_88, au_flu )
            Do Case
            Case ret_tip == 1
              vid_vp := 2 // �� ������ �����������
              fl_pol1[ 13 ] := -1
              fl_pol1[ 14 ] := -1
            Case ret_tip == 2
              vid_vp := 0 // ��䨫��⨪�
              If is_2_88 // ࠧ���� �� ������ �����������
                fl_pol1[ 6 ] := -1
                fl_pol1[ 8 ] := -1
              Else
                fl_pol1[ 3 ] := -1
                fl_pol1[ 5 ] := -1
              Endif
            Case ret_tip == 3
              vid_vp := 1 // � ���⫮���� �ଥ
              fl_pol1[ 11 ] := -1
            Endcase
            tfoms_pz[ 3, 1 ] := 1
            tfoms_pz[ 3, 2 ] := ret_kol
            tfoms_pz[ 3, 3 ] := Round( human->cena_1 * koef, 2 )
            // �� ��ப� 06 ࠧ��� ���饭�� � �裡 � ����������ﬨ
            // �� ��ப� 12 - ���饭�� �� ᯥ樠�쭮�� '�⮬�⮫����'
            // ������ ������
            // '���饭�� �� �������� ����� � ���⫮���� �ଥ, �ᥣ�'
            // '�� ��ப� 21 - ���饭�� �� ᯥ樠�쭮�� '�⮬�⮫����''
            //
            // '���饭��, ����祭�� � ���饭�� � �裡 � ����������ﬨ'
            // '�� ��ப� 25 - ���饭�� �� ᯥ樠�쭮�� '�⮬�⮫����''
            If ret_tip == 1
              arr_pol3000[ 22, 4 ] += Round( human->cena_1 * koef, 2 )
              arr_pol3000[ 22, 2 ] += ret_kol
              If is_inogoro
                arr_pol3000[ 22, 5 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 22, 3 ] += ret_kol
              Endif
            Endif
            func_f14_stom( tfoms_pz[ 3, 3 ], ret_tip, ret_kol, is_2_88, is_rebenok, is_trudosp, is_inogoro, is_sred_stom )
            kol_stom := ret_kol
            kol_stom_pos += ret_kol
            // � ⠡���� Excel ����������� ⮫쪮 ���-�
            AAdd( ta, { 45, tfoms_pz[ 3, 4 ], tfoms_pz[ 3, 4 ], tfoms_pz[ 3, 3 ], tfoms_pz[ 3, 3 ] } )
            // ������� ��樮���
          Case tfoms_pz[ 4, 1 ] > 0
            If !Empty( lvidpoms )
              If !eq_ascan( arr_usl, '55.1.2', '55.1.3' ) .or. glob_mo[ _MO_KOD_TFOMS ] == '801935' // ���-��᪢�
                lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // ⮫쪮 ��� ��.��樮��� �� ��樮���
              Endif
              If !Empty( lvidpoms ) .and. !( ',' $ lvidpoms )
                lvidpom := Int( Val( lvidpoms ) )
                lvidpoms := ''
              Endif
            Endif
            If !Empty( lvidpoms )
              If eq_ascan( arr_usl, '55.1.1', '55.1.4' )
                If '31' $ lvidpoms
                  lvidpom := 31
                Endif
              Elseif eq_ascan( arr_usl, '55.1.2', '55.1.3', '2.76.6', '2.76.7', '2.81.67' )
                If eq_any( human_->PROFIL, 57, 68, 97 ) // �࠯��,�������,��� ���.�ࠪ⨪�
                  If '12' $ lvidpoms
                    lvidpom := 12
                  Endif
                Else
                  If '13' $ lvidpoms
                    lvidpom := 13
                  Endif
                Endif
              Endif
            Endif
            //
            If ( i := AScan( arr_dn_stac, {| x| x[ 1 ] == human_->PROFIL } ) ) == 0
              AAdd( arr_dn_stac, { human_->PROFIL, 0, 0, 0, 0 } ) ; i := Len( arr_dn_stac )
            Endif
            is_onkologia := .f.
            If equalany( human_->PROFIL, 18, 60, 76 )
              is_onkologia := .t.
            Endif
            If is_dializ
              lvidpom := 31 // !!!!!!!
            Endif
            arr_dn_stac[ i, 2 ] += tfoms_pz[ 4, 1 ]
            arr_dn_stac[ i, 3 ] += tfoms_pz[ 4, 3 ]
            If lvidpom == 13
              ds_spec := 1
            Elseif lvidpom == 31
              ds_spec := 2
            Else
              ds_spec := 0
            Endif
            If is_rebenok
              arr_dn_stac[ i, 5 ] += tfoms_pz[ 4, 2 ]
            Else
              arr_dn_stac[ i, 4 ] += tfoms_pz[ 4, 2 ]
            Endif
            If AScan( arr_usl, '55.1.3' ) > 0 // �� ����
              arrDdn_stac[ 1 ] += tfoms_pz[ 4, 1 ]
              arrDdn_stac[ 2 ] += tfoms_pz[ 4, 3 ]
              If is_rebenok
                arrDdn_stac[ 4 ] += tfoms_pz[ 4, 2 ]
              Else
                arrDdn_stac[ 3 ] += tfoms_pz[ 4, 2 ]
              Endif
            Endif
            arr_pril5[ 24, igs ] += tfoms_pz[ 4, 2 ] // '��.���. - ��樥��-����'
            arr_pril5[ 25, igs ] += tfoms_pz[ 4, 1 ] // '��.���. - ��樥�⮢, 祫.'
            arr_pril5[ 26, igs ] += tfoms_pz[ 4, 3 ] // '��.���. - ��.'
            AAdd( ta, { 50, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
            AAdd( ta, { 56 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            If is_rebenok // 52 � 57
              AAdd( ta, { 51, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 57 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_trudosp // 54 � 59
              AAdd( ta, { 52, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 58 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_reabili  // 55 � 60
              AAdd( ta, { 53, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 59 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_inogoro  // 56 � 61
              AAdd( ta, { 55 -1, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 61 -2, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_ekstra
              arr_pril5[ 27, igs ] += tfoms_pz[ 4, 2 ] // '��.���.��� - ��樥��-����'
              arr_pril5[ 28, igs ] += tfoms_pz[ 4, 1 ] // '��.���.��� - ��樥�⮢, 祫.'
              arr_pril5[ 29, igs ] += tfoms_pz[ 4, 3 ] // '��.���.��� - ��.'
              arr_eko[ 1, 1 ] += tfoms_pz[ 4, 2 ]
              arr_eko[ 1, 2 ] += tfoms_pz[ 4, 10 ]
              AAdd( ta, { 68 -3, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 70 -3, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
              If is_inogoro
                arr_eko[ 2, 1 ] += tfoms_pz[ 4, 2 ]
                arr_eko[ 2, 2 ] += tfoms_pz[ 4, 10 ]
                AAdd( ta, { 69 -3, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
                AAdd( ta, { 71 -3, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
              Endif
            Endif
            AAdd( ta, { 62 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            If is_rebenok
              AAdd( ta, { 63 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
            If is_trudosp
              AAdd( ta, { 64 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
            If is_reabili
              AAdd( ta, { 65 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
            If is_inogoro
              AAdd( ta, { 67 -3, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
              /*if is_onkologia // ���������
                 //  ������� 13.07.22    // ��� 54, 60, 66
                 aadd(ta, {54, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                 aadd(ta, {60, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
                 aadd(ta, {66, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif
              */
            // ᪮�� ������
          Case tfoms_pz[ 5, 1 ] > 0
            arr_pril5[ 2, igs ] += tfoms_pz[ 5, 1 ] // '��� - �맮���, ��.'
            arr_pril5[ 3, igs ] += tfoms_pz[ 5, 1 ] // '��� - ���, 祫.'
            arr_pril5[ 4, igs ] += tfoms_pz[ 5, 3 ] // '��� - ��.'
            AAdd( ta, { 69, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
            arr_skor[ 69, isp ] += tfoms_pz[ 5, 1 ]
            AAdd( ta, { 73, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
            arr_skor[ 73, isp ] += tfoms_pz[ 5, 1 ]
            AAdd( ta, { 77, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
            arr_skor[ 77, isp ] += tfoms_pz[ 5, 3 ]
            If is_rebenok
              AAdd( ta, { 70, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 70, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 74, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 74, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 78, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
              arr_skor[ 78, isp ] += tfoms_pz[ 5, 3 ]
            Endif
            If is_trudosp
              AAdd( ta, { 71, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 71, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 75, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 75, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 79, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
              arr_skor[ 79, isp ] += tfoms_pz[ 5, 3 ]
            Endif
            If is_inogoro
              AAdd( ta, { 72, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 72, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 76, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 76, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 80, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
              arr_skor[ 80, isp ] += tfoms_pz[ 5, 3 ]
            Endif
          Endcase
          For j := 1 To Len( ta )
            Select TMP
            find ( Str( ta[ j, 1 ], 2 ) )
            If !Found()
              Append Blank
              tmp->nstr := ta[ j, 1 ]
            Endif
            // !!!!
            tmp->sum4 += ta[ j, 2 ]
            tmp->sum5 += ta[ j, 3 ]
            // !!!!
            If Len( ta[ j ] ) > 3
              tmp->sum6 += ta[ j, 4 ]
            Endif
            If Len( ta[ j ] ) > 4
              tmp->sum7 += ta[ j, 5 ]
            Endif
            If Len( ta[ j ] ) > 5
              tmp->sum8 += ta[ j, 6 ]
            Endif
            If Len( ta[ j ] ) > 6
              tmp->sum9 += ta[ j, 7 ]
            Endif
          Next
          For i := 1 To Len( arr_pol1 )
            If fl_pol1[ i ] > 0
              arr_pol1[ i, 2 ] += fl_pol1[ i ]
              arr_pol1[ i, 4 ] += Round( human->cena_1 * koef, 2 )
              If is_inogoro
                arr_pol1[ i, 3 ] += fl_pol1[ i ]
                arr_pol1[ i, 5 ] += Round( human->cena_1 * koef, 2 )
              Endif
              If i == 4
                If fl_pol3000_PROF   // ���ᬮ���
                  arr_pol3000[ 4, 2 ] += fl_pol1[ i ]
                  arr_pol3000[ 4, 4 ] += Round( human->cena_1 * koef, 2 )
                Else
                  If fl_pol3000_DVN2
                    arr_pol3000[ 5, 2 ] += fl_pol1[ i ]
                    arr_pol3000[ 5, 4 ] += Round( human->cena_1 * koef, 2 )
                  Endif
                Endif
              Endif
            Elseif fl_pol1[ i ] < 0
              If i == 13 .and. schet_->BUKVA == 'K'
                //
              Else
                arr_pol1[ i, 2 ] += kol_stom
                arr_pol1[ i, 4 ] += Round( human->cena_1 * koef, 2 )
                If is_inogoro
                  arr_pol1[ i, 3 ] += kol_stom
                  arr_pol1[ i, 5 ] += Round( human->cena_1 * koef, 2 )
                Endif
                If i == 4
                  If fl_pol3000_PROF   // ���ᬮ���
                    arr_pol3000[ 4, 2 ] += fl_pol1[ i ]
                    arr_pol3000[ 4, 4 ] += Round( human->cena_1 * koef, 2 )
                  Else
                    If fl_pol3000_DVN2
                      arr_pol3000[ 5, 2 ] += fl_pol1[ i ]
                      arr_pol3000[ 5, 4 ] += Round( human->cena_1 * koef, 2 )
                    Endif
                  Endif
                Endif
              Endif
            Endif
          Next
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    If fl_exit ; exit ; Endif
    Select SCHET
    Skip
  Enddo
  Delete File ( filetmp14 )
  If !fl_exit .and. tmpf14->( LastRec() ) > 0
    HH := 80
    arr_title := { ;
      '������������������������������������������������������������������������������������', ;
      '  � � ����, ���,     � ���.��ਮ�, � ����, ��㬬� ��-�                           ', ;
      '  ��-�� ����        � ��� ����           ���,���� ���, � � ��� ���        ', ;
      '������������������������������������������������������������������������������������' }
    sh := Len( arr_title[ 1 ] )
    //
    fp := FCreate( filetmp14 ) ; n_list := 1 ; tek_stroke := 0
    add_string( '' )
    add_string( Center( '���᮪ ��砥�, �� ��襤�� � ��� 14', sh ) )
    Select RAKSH
    Set Index To
    Select HUMAN
    Set Index To
    Select TMPF14
    Set Relation To KOD_RAKSH into RAKSH, To schet into SCHET, To kod_h into HUMAN
    Index On Str( usl_ok, 1 ) + Str( schet_->nyear, 4 ) + Str( schet_->nmonth, 2 ) + ;
      Str( human_->SCHET_ZAP, 6 ) to ( cur_dir + 'tmpf14' )
    For j := 1 To 5
      find ( Str( j, 1 ) )
      If Found()
        add_string( '' )
        If j == 5
          add_string( Center( '[ �⮬�⮫���� ]', sh ) )
        Else
          add_string( Center( '[' + inieditspr( A__MENUVERT, getv006(), j ) + ']', sh ) )
        Endif
        AEval( arr_title, {| x| add_string( x ) } )
        Do While tmpf14->usl_ok == j .and. !Eof()
          s1 := lstr( human_->SCHET_ZAP ) + '. ' + AllTrim( human->fio )
          If tmpf14->kol_akt > 1
            s1 += ' (' + lstr( tmpf14->kol_akt ) + ' ��⮢)'
          Endif
          s2 := Right( Str( schet_->nyear, 4 ), 2 ) + '/' + StrZero( schet_->nmonth, 2 ) + ' ' + ;
            AllTrim( schet_->nschet ) + ' �� ' + date_8( schet_->dschet )
          s3 := AllTrim( rak->nakt ) + ' �� ' + date_8( rak->dakt )
          arr1 := Array( 5 )
          arr2 := Array( 5 )
          arr3 := Array( 5 )
          k1 := perenos( arr1, s1, 22 )
          k2 := perenos( arr2, s2, 22 )
          k3 := perenos( arr3, s3, 27 )
          ins_array( arr3, 1, AllTrim( mo_xml->fname ) )
          ++k3
          k := Max( k1, k2, k3, 3 )
          If verify_ff( HH - k, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          v := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          If Round( human->cena_1, 2 ) == Round( v, 2 )
            s := '='
          Elseif Empty( human->cena_1 )
            s := '>'
          Else
            s := '<'
          Endif
          add_string( PadR( arr1[ 1 ], 23 ) + PadR( arr2[ 1 ], 22 ) + Str( human->cena_1, 11, 2 ) + ' ' + arr3[ 1 ] )
          add_string( PadR( arr1[ 2 ], 23 ) + PadR( arr2[ 2 ], 22 ) + Str( v, 11, 2 ) + ' ' + arr3[ 2 ] )
          add_string( PadR( arr1[ 3 ], 23 ) + PadR( arr2[ 3 ], 22 ) + PadL( s, 11 ) + ' ' + arr3[ 3 ] )
          For i := 4 To k
            add_string( PadR( arr1[ i ], 23 ) + PadR( arr2[ i ], 23 ) + Space( 11 ) + ' ' + arr3[ i ] )
          Next
          add_string( Replicate( '�', sh ) )
          Select TMPF14
          Skip
        Enddo
      Endif
    Next
    FClose( fp )
  Endif
  Close databases
  If fl_exit
    RestScreen( buf )
    Return func_error( 4, '����� ��ࢠ�!' )
  Endif
  //
  arr_razdel := { ;
    { '2. ��樮���', 1, 14 }, ;
    { '3. ���㫠�ୠ� ����樭᪠� ������', 15, 32 }, ;
    { '4. �⮬�⮫����᪠� ������', 33, 45 }, ;
    { '5. ������ ��樮����', 46, 68 }, ;
    { '6. ᪮�� ����樭᪠� ������', 69, 81 };
    }
  //
  r_use( dir_server + 'organiz', , 'ORG' )
  ar := {}
  AAdd( ar, { 12, 77, mm_month[ arr_m[ 3 ] ] } )
  AAdd( ar, { 12, 94, Right( lstr( arr_m[ 1 ] ), 2 ) } )
  AAdd( ar, { 35, 48, glob_mo[ _MO_FULL_NAME ] } )
  AAdd( ar, { 37, 19, glob_mo[ _MO_ADRES ] } )
  AAdd( ar, { 42, 19, org->okpo } )
  AAdd( arr_excel, { '���� 1', AClone( ar ) } )
  //
  Use ( cur_dir + 'tmp' ) index ( cur_dir + 'tmp' ) new
  For i := 1 To Len( arr_razdel )
    ar := {}
    i_stroke := iif( eq_any( i, 1, 4 ), 7, 6 )
    For j := arr_razdel[ i, 2 ] To arr_razdel[ i, 3 ]
      ++i_stroke
      find ( Str( j, 2 ) )
      If Found()
        Do Case
        Case i == 1
          dm := 9
        Case i == 2
          dm := 9
        Case i == 3
          dm := 7
        Case i == 4
          dm := 8
        Case i == 5
          dm := 5
        Endcase
        i_column := iif( i == 5, 4, 3 )
        For k := 4 To dm
          ++i_column
          d := 0
          Do Case
          Case i == 1
            d := iif( k < 7, 0, 2 )
          Case i == 2
            d := iif( k < 7, 0, 2 )
          Case i == 3
            d := iif( k < 6, 0, 2 )
          Case i == 4
            d := iif( Between( j, 60, 64 ) .or. j > 66, 2, 0 )
          Case i == 5
            d := iif( j < 77, 0, 2 )
          Endcase
          pole := 'tmp->sum' + lstr( k )
          If !Empty( &pole )
            AAdd( ar, { i_stroke, i_column, lstr( &pole, 15, d ) } )
          Endif
        Next
      Endif
    Next
    For k := 1 To Len( ar )
      If '.' $ ar[ k, 3 ]
        ar[ k, 3 ] := CharRepl( '.', ar[ k, 3 ], ',' )
      Endif
    Next
    AAdd( arr_excel, { '������ ' + Left( arr_razdel[ i, 1 ], 1 ), AClone( ar ) } )
  Next
  Close databases
  RestScreen( buf )
  Delete File ( cFileProtokol )
  /*k := 0
  for i := 1 to len(arr_prof)
    fl_error := .t.
    strfile(padr(arr_prof[i, 1], 10) + str(arr_prof[i, 2], 10) + ;
            hb_eol(), cFileProtokol, .t.)
    k += arr_prof[i, 2]
  next
  strfile(padr('������', 10) + str(k, 10) + hb_eol(), cFileProtokol, .t.)*/
  //
  StrFile( hb_eol() + ;
    PadC( '�������⥫�� ����� ��� ���������� ��� 62', 80 ) + ;
    hb_eol(), cFileProtokol, .t. )
  If kol_stom_pos > 0
    fl_error := .t.
    Use ( cur_dir + 'TMP_STOM' ) new
    StrFile( hb_eol() + ;
      '����� � ������⢥ � �⮨���� ���饭�� � ���饭�� �� �������� �⮬�⮫����᪮� �����' + ;
      hb_eol() + ;
      '___________________________________________________________________________________________________________________________' + hb_eol() + ;
      '___________________________|______�ᥣ�____________|_________���__________|____���� ��㤮ᯮ�.__|____�����த���________' + hb_eol() + ;
      '                           |���|���-|  �㬬�    |���|���-|  �㬬�    |���|���-|  �㬬�    |���|���-|  �㬬�    ' + hb_eol() + ;
      '___________________________|��___|饭��|___________|��___|饭��|___________|��___|饭��|___________|��___|饭��|___________' + hb_eol(), cFileProtokol, .t. )
    For i := 1 To 10
      Goto ( i )
      If i == 9 .and. Empty( tmp_stom->k2 )
        Loop
      Endif
      StrFile( tmp_stom->name + Str( tmp_stom->k2, 6 ) + Str( tmp_stom->k3, 6 ) + Str( tmp_stom->k4, 12, 2 ) + ;
        Str( tmp_stom->k5, 6 ) + Str( tmp_stom->k6, 6 ) + Str( tmp_stom->k7, 12, 2 ) + ;
        Str( tmp_stom->k8, 6 ) + Str( tmp_stom->k9, 6 ) + Str( tmp_stom->k10, 12, 2 ) + ;
        Str( tmp_stom->k11, 6 ) + Str( tmp_stom->k12, 6 ) + Str( tmp_stom->k13, 12, 2 ) + hb_eol(), cFileProtokol, .t. )
    Next
    // 21 '���饭�� �� �������� ����� � ���⫮���� �ଥ, �ᥣ�'
    // 24 '�� ��ப� 21 - ���饭�� �� ᯥ樠�쭮�� '�⮬�⮫����''
    Goto 7
    arr_pol3000[ 19, 2 ] := tmp_stom->k3 // ���-��
    arr_pol3000[ 19, 3 ] := tmp_stom->k12 // ��-�� �����த���
    arr_pol3000[ 19, 4 ] := tmp_stom->k4 // �㬬�
    arr_pol3000[ 19, 5 ] := tmp_stom->k13 // �㬬� �����த��
    Use
  Endif
  fl := .f.
  For i := 1 To Len( arr_pril5 )
    If !Empty( arr_pril5[ i, 2 ] + arr_pril5[ i, 3 ] )
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadL( '�ਫ������ 5 � �ଥ 62', 80 ) + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '                                         �   �ᥣ�    ���த᪨� �.�ᥫ�᪨� ���' + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol(), cFileProtokol, .t. )
    For i := 1 to ( Len( arr_pril5 ) -1 )
      If !Empty( arr_pril5[ i, 2 ] + arr_pril5[ i, 3 ] )
        StrFile( PadR( arr_pril5[ i, 1 ], 39 ) + Str( i, 2 ) + ;
          PadL( AllTrim( put_val_0( arr_pril5[ i, 2 ] + arr_pril5[ i, 3 ], 13, 2 ) ), 13 ) + ;
          PadL( AllTrim( put_val_0( arr_pril5[ i, 2 ], 13, 2 ) ), 13 ) + ;
          PadL( AllTrim( put_val_0( arr_pril5[ i, 3 ], 13, 2 ) ), 13 ) + ;
          hb_eol(), cFileProtokol, .t. )
        If i == 10
          StrFile( PadR( arr_pril5[ 32, 1 ], 39 ) + Str( 10, 2 ) + ;
            PadL( AllTrim( put_val_0( arr_pril5[ 32, 2 ] + arr_pril5[ 32, 3 ], 13, 2 ) ), 13 ) + ;
            PadL( AllTrim( put_val_0( arr_pril5[ 32, 2 ], 13, 2 ) ), 13 ) + ;
            PadL( AllTrim( put_val_0( arr_pril5[ 32, 3 ], 13, 2 ) ), 13 ) + ;
            hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
    Next
  Endif
  If !Empty( arr_dn_stac )
    fl_error := .t.
    ASort( arr_dn_stac,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    AAdd( arr_dn_stac, { '', 0, 0, 0, 0 } ) ; j := Len( arr_dn_stac )
    StrFile( hb_eol() + ;
      PadC( '������� ��樮��� �� ��䨫�', 80 ) + hb_eol() + ;
      '����������������������������������������������������������������������������������' + hb_eol() + ;
      '                              �        �ᥣ�        � �।.�  �᫮ ��樥��-���� ' + hb_eol() + ;
      '            ��䨫�           ���������������������ĳ ����.�����������������������' + hb_eol() + ;
      '                              ���砥��    �㬬�    �1���.� �ᥣ� �����.� ���  ' + hb_eol() + ;
      '����������������������������������������������������������������������������������' + hb_eol(), cFileProtokol, .t. )
    For i := 1 To Len( arr_dn_stac ) -1
      s := PadR( lstr( arr_dn_stac[ i, 1 ] ) + ' ' + inieditspr( A__MENUVERT, getv002(), arr_dn_stac[ i, 1 ] ), 30 ) + ;
        put_val( arr_dn_stac[ i, 2 ], 8 ) + put_kope( arr_dn_stac[ i, 3 ], 14 )
      k := 0
      If arr_dn_stac[ i, 2 ] > 0
        k := ( arr_dn_stac[ i, 4 ] + arr_dn_stac[ i, 5 ] ) / arr_dn_stac[ i, 2 ]
      Endif
      s += Str( k, 6, 1 ) + put_val( arr_dn_stac[ i, 4 ] + arr_dn_stac[ i, 5 ], 9 ) + ;
        put_val( arr_dn_stac[ i, 4 ], 7 ) + put_val( arr_dn_stac[ i, 5 ], 7 )
      StrFile( s + hb_eol(), cFileProtokol, .t. )
      arr_dn_stac[ j, 2 ] += arr_dn_stac[ i, 2 ]
      arr_dn_stac[ j, 3 ] += arr_dn_stac[ i, 3 ]
      arr_dn_stac[ j, 4 ] += arr_dn_stac[ i, 4 ]
      arr_dn_stac[ j, 5 ] += arr_dn_stac[ i, 5 ]
    Next
    StrFile( Replicate( '�', 83 ) + hb_eol(), cFileProtokol, .t. )
    s := PadR( '�⮣�:', 30 ) + ;
      put_val( arr_dn_stac[ j, 2 ], 8 ) + put_kope( arr_dn_stac[ j, 3 ], 14 )
    k := 0
    If arr_dn_stac[ j, 2 ] > 0
      k := ( arr_dn_stac[ j, 4 ] + arr_dn_stac[ j, 5 ] ) / arr_dn_stac[ j, 2 ]
    Endif
    s += Str( k, 6, 1 ) + put_val( arr_dn_stac[ j, 4 ] + arr_dn_stac[ j, 5 ], 9 ) + ;
      put_val( arr_dn_stac[ j, 4 ], 7 ) + put_val( arr_dn_stac[ j, 5 ], 7 )
    StrFile( s + hb_eol(), cFileProtokol, .t. )
    StrFile( Replicate( '�', 83 ) + hb_eol(), cFileProtokol, .t. )
    s := PadR( '� �.�.� ��.��樮���� �� ����', 30 ) + ;
      put_val( arrDdn_stac[ 1 ], 8 ) + put_kope( arrDdn_stac[ 2 ], 14 )
    k := 0
    If arrDdn_stac[ 1 ] > 0
      k := ( arrDdn_stac[ 3 ] + arrDdn_stac[ 4 ] ) / arrDdn_stac[ 1 ]
    Endif
    s += Str( k, 6, 1 ) + put_val( arrDdn_stac[ 3 ] + arrDdn_stac[ 4 ], 9 ) + ;
      put_val( arrDdn_stac[ 3 ], 7 ) + put_val( arrDdn_stac[ 4 ], 7 )
    StrFile( s + hb_eol(), cFileProtokol, .t. )
  Endif
  If !Empty( arr_profil )
    fl_error := .t.
    ASort( arr_profil,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    StrFile( hb_eol() + ;
      PadC( '��樮��� �� ��䨫�', 80 ) + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '                              �        �ᥣ�           �   � �.�. �����த���   ' + hb_eol() + ;
      '            ��䨫�           ��������������������������������������������������' + hb_eol() + ;
      '                              ���樥�⮢�     �㬬�    ���樥�⮢�     �㬬�    ' + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol(), cFileProtokol, .t. )
    For i := 1 To Len( arr_profil )
      StrFile( PadR( lstr( arr_profil[ i, 1 ] ) + ' ' + inieditspr( A__MENUVERT, getv002(), arr_profil[ i, 1 ] ), 30 ) + ;
        put_val( arr_profil[ i, 2 ], 10 ) + put_kope( arr_profil[ i, 3 ], 15 ) + ;
        put_val( arr_profil[ i, 4 ], 10 ) + put_kope( arr_profil[ i, 5 ], 15 ) + ;
        hb_eol(), cFileProtokol, .t. )
    Next
  Endif
  fl := .f.
  For i := 15 To 32
    If arr_pol[ i ] > 0
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadC( '���㫠�୮-����������᪠� ������', 80 ) + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '                                                  ��⮨����� �� ��⠬ "A" � "K"' + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '���饭�� � ��䨫����᪮� 楫��, �ᥣ�          15' + put_kope( arr_pol[ 15 ], 20 ) + hb_eol() + ;
      '  �� ���: ��祩 ��饩 �ࠪ⨪� (ᥬ����� ��祩)  16' + put_kope( arr_pol[ 16 ], 20 ) + hb_eol() + ;
      '          業�஢ ���஢��                         17' + put_kope( arr_pol[ 17 ], 20 ) + hb_eol() + ;
      '  �� ��ப� 15: ���쬨 (0-17 ��� �����⥫쭮)     18' + put_kope( arr_pol[ 18 ], 20 ) + hb_eol() + ;
      '    �� ��� 業�஢ ���஢�� ���쬨 (0-17 ���)      19' + put_kope( arr_pol[ 19 ], 20 ) + hb_eol() + ;
      '           ��栬� ���� ��㤮ᯮᮡ���� ������  20' + put_kope( arr_pol[ 20 ], 20 ) + hb_eol() + ;
      ' ��栬�, �����客���묨 �� �।����� ��ꥪ� ��  21' + put_kope( arr_pol[ 21 ], 20 ) + hb_eol() + ;
      '���饭�� �� �������� ���.����� � ����.�ଥ    22' + put_kope( arr_pol[ 22 ], 20 ) + hb_eol() + ;
      '  �� ���: ��祩 ��饩 �ࠪ⨪� (ᥬ����� ��祩)  23' + put_kope( arr_pol[ 23 ], 20 ) + hb_eol() + ;
      '  �� ��ப� 22: ���쬨 (0-17 ��� �����⥫쭮)     24' + put_kope( arr_pol[ 24 ], 20 ) + hb_eol() + ;
      '           ��栬� ���� ��㤮ᯮᮡ���� ������  25' + put_kope( arr_pol[ 25 ], 20 ) + hb_eol() + ;
      ' ��栬�, �����客���묨 �� �।����� ��ꥪ� ��  26' + put_kope( arr_pol[ 26 ], 20 ) + hb_eol() + ;
      '���饭�� �� ������ �����������, �ᥣ�             27' + put_kope( arr_pol[ 27 ], 20 ) + hb_eol() + ;
      ' �� ��� � ��砬 ��饩 �ࠪ⨪� (ᥬ���� ��砬)  28' + put_kope( arr_pol[ 28 ], 20 ) + hb_eol() + ;
      '  �� ��ப� 27: ��⥩ (0-17 ��� �����⥫쭮)      29' + put_kope( arr_pol[ 29 ], 20 ) + hb_eol() + ;
      '     ��� ���� ��㤮ᯮᮡ���� ������           30' + put_kope( arr_pol[ 30 ], 20 ) + hb_eol() + ;
      '     ���, �� ��宦����� ॠ�����樨             31' + put_kope( arr_pol[ 31 ], 20 ) + hb_eol() + ;
      '     ���, �����客����� �� �।����� ��ꥪ� ��  32' + put_kope( arr_pol[ 32 ], 20 ) + hb_eol(), cFileProtokol, .t. )
  Endif

  fl := .f.
  For i := 1 To 15
    If arr_pol1[ i, 2 ] > 0
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadC( '3000 �����᪨� ����� ���饭�� � �� 䨭���஢���� (���� ��ਠ��)', 80 ) + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '                                    �   ���饭��   �          �㬬�            ' + hb_eol() + ;
      ' ������������ ������⥫�            ��������������������������������������������' + hb_eol() + ;
      '                                    � �ᥣ� �������.�    �ᥣ�    �� �.�. ������' + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol(), cFileProtokol, .t. )
    add_val_2_array( arr_pol1, 2, 3, 2, 5 )
    add_val_2_array( arr_pol1, 2, 6, 2, 5 )
    add_val_2_array( arr_pol1, 2, 9, 2, 5 )
    //
    add_val_2_array( arr_pol1, 1, 2, 2, 5 )
    add_val_2_array( arr_pol1, 1, 11, 2, 5 )
    add_val_2_array( arr_pol1, 1, 13, 2, 5 )
    For i := 1 To Len( arr_pol1 )
      k := perenos( t_arr, arr_pol1[ i, 1 ], 33 )
      StrFile( PadR( RTrim( t_arr[ 1 ] ), 34, '.' ) + StrZero( i, 2 ) + ;
        put_val( arr_pol1[ i, 2 ], 8 ) + put_val( arr_pol1[ i, 3 ], 8 ) + ;
        put_kope( arr_pol1[ i, 4 ], 14 ) + put_kope( arr_pol1[ i, 5 ], 14 ) + hb_eol(), cFileProtokol, .t. )
      For j := 2 To k
        StrFile( PadL( AllTrim( t_arr[ j ] ), 34 ) + hb_eol(), cFileProtokol, .t. )
      Next
    Next
  Endif
  If !Empty( sum_k )
    fl_error := .t.
    StrFile( hb_eol() + '�㬬� �� ��⠬, ����騬 ��ࠬ��� � = ' + lstr( sum_k, 12, 2 ) + ;
      ' (� �.�.��� ' + lstr( sum_kd, 12, 2 ) + ', ��㤮ᯮ�.' + lstr( sum_kt, 12, 2 ) + ;
      ', �����த��� ' + lstr( sum_ki, 12, 2 ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif
  If !Empty( sum_d )
    fl_error := .t.
    StrFile( hb_eol() + '�� ��⠬, ����騬 ��ࠬ��� G,J,D,O,R,F,V,I,U = ' + lstr( kol_d ) + ' ��񬮢 �� �㬬� ' + lstr( sum_d, 12, 2 ) + hb_eol(), cFileProtokol, .t. )
  Endif
  If arr_eko[ 1, 1 ] > 0
    fl_error := .t.
    StrFile( hb_eol() + ;
      '�஢����� ���訬� ��樥�⠬� ��樥��-���� �� ���  ' + lstr( arr_eko[ 1, 1 ] ) + ' (� �.�.��� ' + lstr( arr_eko[ 1, 2 ] ) + ')' + hb_eol() + ;
      '  �� ��� ���, �����客����� �� �।����� ��ꥪ� �� ' + lstr( arr_eko[ 2, 1 ] ) + ' (� �.�.��� ' + lstr( arr_eko[ 2, 2 ] ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif


  fl := .f.
  For i := 1 To 29
    If arr_pol3000[ i, 2 ] > 0
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadC( '3000 �����᪨� ����� ���饭�� � �� 䨭���஢����', 80 ) + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '                                    �   ���饭��   �          �㬬�            ' + hb_eol() + ;
      ' ������������ ������⥫�            ��������������������������������������������' + hb_eol() + ;
      '                                    � �ᥣ� �������.�    �ᥣ�    �� �.�. ������' + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol(), cFileProtokol, .t. )
    //
    // '02 ���饭�� � ��䨫����᪨�� � ��묨 楫ﬨ (03+06)'
    // add_val_2_array(arr_pol3000, 2, 3, 2, 5)
    // add_val_2_array(arr_pol3000, 2, 6, 2, 5)
    // 01 ���饭�� - �ᥣ� (02+21+25)
    // add_val_2_array(arr_pol3000, 1, 2, 2, 5)
    // add_val_2_array(arr_pol3000, 1, 17, 2, 5)
    // add_val_2_array(arr_pol3000, 1, 20, 2, 5)
    //
    // ��९�᢮����
    For xx := 2 To 5
      arr_pol3000[ 1, xx ] := arr_pol1[ 1, xx ]
    Next
    //
    For xx := 2 To 5
      arr_pol3000[ 2, xx ] := arr_pol1[ 2, xx ]
    Next
    // 12 '�� ��ப� 06 ࠧ��� ���饭�� � �裡 � ����������ﬨ'
    For xx := 2 To 5
      arr_pol3000[ 9, xx ] := arr_pol1[ 6, xx ]
    Next
    // 13 '�� ��ப� 12 - ���饭�� �� ����'
    For xx := 2 To 5
      arr_pol3000[ 10, xx ] := arr_pol1[ 7, xx ]
    Next
    // '���饭�� �� �������� ����� � ���⫮���� �ଥ, �ᥣ�'
    For xx := 2 To 5
      arr_pol3000[ 17, xx ] := arr_pol1[ 11, xx ]
    Next
    // '�� ��ப� 21 - ���饭�� �� ����'
    For xx := 2 To 5
      arr_pol3000[ 18, xx ] := arr_pol1[ 12, xx ]
    Next
    // '���饭��, ����祭�� � ���饭�� � �裡 � ����������ﬨ'
    For xx := 2 To 5
      arr_pol3000[ 20, xx ] := arr_pol1[ 13, xx ]
    Next
    // '06 ���饭�� � ��묨 楫ﬨ, �ᥣ� (07+08+12+14+15+16+19+20)'
    // add_val_2_array(arr_pol3000, 6, 7, 2, 5)   // 7
    // add_val_2_array(arr_pol3000, 6, 8, 2, 5)   // 8
    // add_val_2_array(arr_pol3000, 6, 9, 2, 5)   // 12
    // add_val_2_array(arr_pol3000, 6, 11, 2, 5)  // 14
    // add_val_2_array(arr_pol3000, 6, 12, 2, 5)  // 15
    // add_val_2_array(arr_pol3000, 6, 13, 2, 5)  // 16
    // //add_val_2_array(arr_pol3000, 6,, 2, 5)  // 19 ��� � ��⥬� ���
    // add_val_2_array(arr_pol3000, 6, 16, 2, 5)  // 20

    // '03 ���饭�� � ��䨫����᪨�� 楫ﬨ, �ᥣ� (04+05)'
    add_val_2_array( arr_pol3000, 3, 4, 2, 5 )
    add_val_2_array( arr_pol3000, 3, 5, 2, 5 )
    //
    For xx := 2 To 5
      arr_pol3000[ 6, xx ] := arr_pol3000[ 2, xx ] - arr_pol3000[ 3, xx ]
    Next
    //
    For i := 1 To Len( arr_pol3000 )
      k := perenos( t_arr, arr_pol3000[ i, 1 ], 33 )
      StrFile( PadR( RTrim( t_arr[ 1 ] ), 34, '.' ) + StrZero( arr_pol3000[ i, 6 ], 2 ) + ; // strzero(arr_pol3000[i, 1], 2) + ;
      put_val( arr_pol3000[ i, 2 ], 8 ) + put_val( arr_pol3000[ i, 3 ], 8 ) + ;
        put_kope( arr_pol3000[ i, 4 ], 14 ) + put_kope( arr_pol3000[ i, 5 ], 14 ) + hb_eol(), cFileProtokol, .t. )
      For j := 2 To k
        StrFile( PadL( AllTrim( t_arr[ j ] ), 34 ) + hb_eol(), cFileProtokol, .t. )
      Next
    Next
  Endif
  If !Empty( sum_k )
    fl_error := .t.
    StrFile( hb_eol() + '�㬬� �� ��⠬, ����騬 ��ࠬ��� � = ' + lstr( sum_k, 12, 2 ) + ;
      ' (� �.�.��� ' + lstr( sum_kd, 12, 2 ) + ', ��㤮ᯮ�.' + lstr( sum_kt, 12, 2 ) + ;
      ', �����த��� ' + lstr( sum_ki, 12, 2 ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif
  If !Empty( sum_d )
    fl_error := .t.
    StrFile( hb_eol() + '�� ��⠬, ����騬 ��ࠬ��� G,J,D,O,R,F,V,I,U = ' + lstr( kol_d ) + ' ��񬮢 �� �㬬� ' + lstr( sum_d, 12, 2 ) + hb_eol(), cFileProtokol, .t. )
  Endif
  If arr_eko[ 1, 1 ] > 0
    fl_error := .t.
    StrFile( hb_eol() + ;
      '�஢����� ���訬� ��樥�⠬� ��樥��-���� �� ���  ' + lstr( arr_eko[ 1, 1 ] ) + ' (� �.�.��� ' + lstr( arr_eko[ 1, 2 ] ) + ')' + hb_eol() + ;
      '  �� ��� ���, �����客����� �� �।����� ��ꥪ� �� ' + lstr( arr_eko[ 2, 1 ] ) + ' (� �.�.��� ' + lstr( arr_eko[ 2, 2 ] ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif
  If arr_skor[ 69, 1 ] > 0 .or. arr_skor[ 69, 2 ] > 0
    fl_error := .t.
    StrFile( hb_eol() + PadC( '����� ������', 80 ) + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '                                                      �� ���⫮�.�.�� ���७.�.' + hb_eol() + ;
      '��������������������������������������������������������������������������������' + hb_eol() + ;
      '��᫮ �믮������� �맮��� ᪮ன ����樭᪮� �����, 69' + put_kope( arr_skor[ 69, 1 ], 13 ) + put_kope( arr_skor[ 69, 2 ], 13 ) + hb_eol() + ;
      '  �� ���: � ���� (0-17 ��� �����⥫쭮)          , 70' + put_kope( arr_skor[ 70, 1 ], 13 ) + put_kope( arr_skor[ 70, 2 ], 13 ) + hb_eol() + ;
      '          � ��栬 ���� ��㤮ᯮᮡ���� ������  , 71' + put_kope( arr_skor[ 71, 1 ], 13 ) + put_kope( arr_skor[ 71, 2 ], 13 ) + hb_eol() + ;
      '   � ��栬, �����客���� �� �।����� ��ꥪ� ��, 72' + put_kope( arr_skor[ 72, 1 ], 13 ) + put_kope( arr_skor[ 72, 2 ], 13 ) + hb_eol() + ;
      '��᫮ ���, ���㦥���� �ਣ����� ᪮ன ���.����� , 73' + put_kope( arr_skor[ 73, 1 ], 13 ) + put_kope( arr_skor[ 73, 2 ], 13 ) + hb_eol() + ;
      '  �� ���: ��⥩ (0-17 ��� �����⥫쭮)            , 74' + put_kope( arr_skor[ 74, 1 ], 13 ) + put_kope( arr_skor[ 74, 2 ], 13 ) + hb_eol() + ;
      '          ��� ���� ��㤮ᯮᮡ���� ������      , 75' + put_kope( arr_skor[ 75, 1 ], 13 ) + put_kope( arr_skor[ 75, 2 ], 13 ) + hb_eol() + ;
      '       ���, �����客����� �� �।����� ��ꥪ� ��, 76' + put_kope( arr_skor[ 76, 1 ], 13 ) + put_kope( arr_skor[ 76, 2 ], 13 ) + hb_eol() + ;
      '�⮨����� ��������� ᪮ன ����樭᪮� �����,�ᥣ�, 77' + put_kope( arr_skor[ 77, 1 ], 13 ) + put_kope( arr_skor[ 77, 2 ], 13 ) + hb_eol() + ;
      '  �� ���: ���� (0-17 ��� �����⥫쭮)            , 78' + put_kope( arr_skor[ 78, 1 ], 13 ) + put_kope( arr_skor[ 78, 2 ], 13 ) + hb_eol() + ;
      '          ��栬 ���� ��㤮ᯮᮡ���� ������    , 79' + put_kope( arr_skor[ 79, 1 ], 13 ) + put_kope( arr_skor[ 79, 2 ], 13 ) + hb_eol() + ;
      '     ��栬, �����客���� �� �।����� ��ꥪ� ��, 80' + put_kope( arr_skor[ 80, 1 ], 13 ) + put_kope( arr_skor[ 80, 2 ], 13 ) + hb_eol() + ;
      '�⮨����� ���� ����� ����樭᪮� ����� � ���    , 81' + put_kope( arr_skor[ 81, 1 ], 13 ) + put_kope( arr_skor[ 81, 2 ], 13 ) + hb_eol(), cFileProtokol, .t. )
  Endif
  If File( filetmp14 )
    viewtext( filetmp14,,,, .t.,,, 5 )
  Endif
  If fl_error
    viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 3 )
  Endif
  fill_in_excel_book( dir_exe() + 'mo_14med' + sxls(), ;
    cur_dir() + '__14med' + sxls(), ;
    arr_excel, ;
    '��᫠��� �� �����' )
  Return Nil