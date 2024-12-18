// mo_omsi.prg - ���ଠ�� �� ���
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// ����� �����த��� ��� ����⠢��� ��� �����
Function cut_code_smo( _smo )

  Local s := Space( 5 )

  If !Empty( _smo )
    If Left( _smo, 3 ) == '340'
      s := _smo
    Else
      s := '34   '
    Endif
  Endif

  Return s

// 19.12.13
Function menu_schet_akt( r, c )

  Static mas_pmt := { '�� ~�ᥬ ���⠢����� ����', ;
    '�� ���⮬ ��� ����� �� ~��⠬', ;
    '��� ���� ~����୮ ���⠢������' }
  Static mas_msg := { '�� �ᥬ ���⠢����� ����', ;
    '�� ���⮬ ��� ��砥�, �㬬� ������ �뫨 ���� �� ��⠬', ;
    '�� �ᥬ ���⠢����� ����, �� ��� ���� ����୮ ���⠢������ ��砥�' }
  Local j, buf := save_maxrow()

  Default r To T_ROW, c To T_COL -5
  If ( j := popup_prompt( r, c, glob_schet_akt, mas_pmt, mas_msg, , 'BG+/RB,W+/B,GR+/RB,BG+/B' ) ) > 0
    glob_schet_akt := j
  Endif
  rest_box( buf )

  Return j

// 19.12.13
Function f_usl_schet_akt( loplata )

  Local fl := .t.

  If glob_schet_akt == 2
    fl := !eq_any( loplata, 2, 9 )
  Elseif glob_schet_akt == 3
    fl := ( loplata != 9 )
  Endif

  Return fl

// 18.12.24 ����⨪�
Function e_statist( k )

  Static si1 := 1, si2 := 3, si3 := 1, si4 := 1, si5 := 1, si6 := 1, ;
    si7 := 1, si8 := 1, si9 := 1, si61 := 1, si12 := 1, si13 := 1, ;
    si14 := 1, si15 := 1, si16 := 1, si17 := 1, si18 := 1, si19 := 1
  Static sds := 2
  Local mas_pmt, mas_msg, mas_fun, j, uch_otd

  Default k To 1
  Do Case
  Case k == 1
    uch_otd := saveuchotd()
    Private p_net_otd := .t.
    mas_pmt := { '�� ~��⠬', ;
      '~���� ࠡ�� �� ��㣠�', ;
      '���� �� ����������� ~�����', ;
      '������᪨� ~���', ;
      '~�������ਠ��� ����', ;
      '~���� ���ଠ��' }
    mas_msg := { '����⨪� �� ��⠬', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� �������� ��㣠�)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ����������� �����)', ;
      '����⨪� �� ��������� + ������᪨� ���', ;
      '����祭�� ᢮���� ���ଠ樨 (�������ਠ��� ����)', ;
      '���� ���ଠ��' }
    mas_fun := { 'e_statist(11)', ;
      'e_statist(12)', ;
      'e_statist(13)', ;
      'e_statist(14)', ;
      'e_statist(15)', ;
      'e_statist(16)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
    restuchotd( uch_otd )
  Case k == 11
    Private pds := 2
    mas_pmt := { '�� ~���⠢����� ��⠬', ;
      '�� ~��ॣ����஢���� ��⠬', ;
      '�� ~��⠬ ����஫�', ;
      '�� ~����祭�� ��⠬', ;
      '~������� ���ଠ��' }
    mas_msg := { '����⨪� �� ���⠢����� ��⠬', ;
      '����⨪� �� ��ॣ����஢���� ��⠬', ;
      '����⨪� �� ��⠬ ����஫�', ;
      '����⨪� �� ����祭�� ��⠬', ;
      '������� ���ଠ�� (��ॣ.��� + ���� ����஫� + ������ ���㬥���)' }
    mas_fun := { 'e_statist(121)', ;
      'e_statist(122)', ;
      'e_statist(123)', ;
      'e_statist(124)', ;
      'e_statist(125)' }
    popup_prompt( T_ROW, T_COL -5, si12, mas_pmt, mas_msg, mas_fun )
  Case k == 121
    mas_pmt := { '~��� �� ��ਮ�', ;
      '~������� ���', ;
      '�ଠ 14-~�����', ;
      '~����� ᯥ樠�����' }
    mas_msg := { '������᪠� ���ଠ�� �� �ᥬ ��⠬ �� ��ਮ� �६���', ;
      '������᪠� ���ଠ�� �� �����⭮�� ����', ;
      '�롮ઠ ���ଠ樨 �� �ଥ 14-����� �� ��ਮ� �६���', ;
      '����� ����樭᪮� ����� �� ��� �।�� �ணࠬ�� ����୨��樨 �� 2011-2012��.' }
    mas_fun := { 'e_statist(21)', ;
      'e_statist(22)', ;
      'e_statist(23)', ;
      'e_statist(24)' }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 122
    pds := 3 // �� ��� ॣ����樨 ����
    mas_pmt := { '~��� �� ��ਮ�', ;
      '�ଠ 14-~�����', ;
      '~����ॣ����஢���� ���', ;
      '�ଠ 14-��� (~���)', ;
      '�ଠ ~1 �ਪ��� �146 �����', ;
      '����� ~�-���', ;
      '����� �� ~���' }
    mas_msg := { '������᪠� ���ଠ�� �� �ᥬ ��⠬ �� ��ਮ� �६���', ;
      '�롮ઠ ���ଠ樨 �� �ଥ 14-����� �� ��ਮ� �६���', ;
      '���᮪ ����ॣ����஢����� ��⮢', ;
      '�����⮢�� ��� �14-���(���)(�� �ᯮ������ �ਪ��� ������ �� 17.04.14�. �258)', ;
      '�����⮢�� ��� �1 (�� �ᯮ������ �ਪ��� ����� �� 16.08.11� �146)', ;
      '�������� � ����樭᪮� �����, ����뢠���� �� ����ਠ�쭮� �ணࠬ�� ���', ;
      '����� �� ��� - �ਫ������ 5 � 6 (�த������� � �ଥ 62)' }
    mas_fun := { 'e_statist(141)', ;
      'e_statist(142)', ;
      'e_statist(143)', ;
      'e_statist(144)', ;
      'e_statist(145)', ;
      'e_statist(146)', ;
      'e_statist(147)' }
    popup_prompt( T_ROW, T_COL -5, si14, mas_pmt, mas_msg, mas_fun )
  Case k == 123
    mas_pmt := { '~�㬬� ��⨩', ;
      '�~㬬� ��⨩ �� ��� ���', ;
      '���᮪ ��⨩ (~��䥪��)', ;
      '���᮪ ��⨩ (~��樥���)', ;
      '~����⠭������� ���񬮢', ;
      '���᮪ ~���', ;
      '���᮪ ��⮢ ~��� ���' }
    mas_msg := { '�㬬� ��⨩ � ����஢��� �� ���, ��䥪⠬ � ����� �ᯥ�⨧�', ;
      '�㬬� ��⨩ � ����஢��� �� ���, ��䥪⠬ � ����� �ᯥ�⨧� �� ��� ���', ;
      '���᮪ ��⨩ �� ��⠬ ����஫� � 㪠������ ����� ��䥪⮢', ;
      '���᮪ ��⨩ �� ��⠬ ����஫� � 㪠������ ��樥�⮢', ;
      '���⠢����� ᯨ᪠ ��樥�⮢ ��� ����⠭������� ���񬮢 (� ����� ��⨥� � ���)', ;
      '���᮪ ॥��஢ ��⮢ ����஫� � 㪠������ ������������ � ��� 䠩��� ���', ;
      '���᮪ ��⮢, �� ����� ��� ��⮢ ����஫�' }
    mas_fun := { 'e_statist(151)', ;
      'e_statist(157)', ;
      'e_statist(152)', ;
      'e_statist(153)', ;
      'e_statist(154)', ;
      'e_statist(155)', ;
      'e_statist(156)' }
    popup_prompt( T_ROW, T_COL -5, si15, mas_pmt, mas_msg, mas_fun )
  Case k == 124
    mas_pmt := { '~������ ����祭��' }
    mas_msg := { '���᮪ ������� ����祭��' }
    mas_fun := { 'e_statist(161)' }
    popup_prompt( T_ROW, T_COL -5, si16, mas_pmt, mas_msg, mas_fun )
  Case k == 125
    mas_pmt := { '~���� ᢥન �� ���', ;
      '~����⭠� ���������' }
    mas_msg := { '��ᯥ�⪠ ��� ᢥન �� �����⭮� ���', ;
      '���⠢����� ����⭮� ��������' }
    mas_fun := { 'e_statist(171)', ;
      'e_statist(172)' }
    popup_prompt( T_ROW, T_COL -5, si17, mas_pmt, mas_msg, mas_fun )
  Case k == 12
    mas_pmt := { '���� ࠡ�� (�� ��� �������� ~��㣨)', ;
      '���� ࠡ�� (�� ��� ~�믨᪨ ���)', ;
      '���� ࠡ�� (�� ��� ~����砭�� ��祭��)', ;
      '���� ࠡ�� (�� ~���믨ᠭ�� ��⠬)' }
    mas_msg := { '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ��� ��砫� �������� ��㣨)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ��� �믨᪨ ���)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ��� ����砭�� ��祭��)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� �����, �� �� ����祭�� � ���)' }
    mas_fun := { 'ob1_statist(0, 1)', ;
      'ob1_statist(0, 2)', ;
      'ob1_statist(0, 3)', ;
      'ob1_statist(0, 4)' }
    Private pi1 := si2, psz, _arr_if, _what_if := _init_if(), _arr_komit := {}
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
    If pi1 != NIL ; si2 := pi1 ; Endif
  Case k == 13
    mas_pmt := { '���� ࠡ�� (�� ��� �������� ~��㣨)', ;
      '���� ࠡ�� (�� ��� ~�믨᪨ ���)', ;
      '���� ࠡ�� (�� ��� ~����砭�� ��祭��)', ;
      '���� ࠡ�� (�� ~���믨ᠭ�� ��⠬)' }
    mas_msg := { '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ��� ��砫� �������� ��㣨)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ��� �믨᪨ ���)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� ��� ����砭�� ��祭��)', ;
      '����⨪� �� ����� ࠡ�� ���ᮭ��� (�� �����, �� �� ����祭�� � ���)' }
    mas_fun := { 'obF_statist(0, 1)', ;
      'obF_statist(0, 2)', ;
      'obF_statist(0, 3)', ;
      'obF_statist(0, 4)' }
    Private pi1 := si2, psz, _arr_if, _what_if := _init_if(), _arr_komit := {}
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
    If pi1 != NIL ; si2 := pi1 ; Endif
  Case k == 14
    mas_pmt := { '������᪨� ��� (�� ��� ~����砭�� ��祭��)', ;
      '������᪨� ��� (�� ��� ~�믨᪨ ���)', ;
      '~�஢�ઠ �� ᮮ⢥��⢨� �ࠢ���� ����⨪�', ;
      '����/।���஢���� �ࠢ�� ~����⨪�', ;
      '~����ன�� �ࠢ�� ����⨪�' }
    mas_msg := { '����⨪� �� ��������� � ������᪨� ��� (�� ��� ����砭�� ��祭��)', ;
      '����⨪� �� ��������� � ������᪨� ��� (�� ��� �믨᪨ ���)', ;
      '�஢�ઠ �� ᮮ⢥��⢨� �ࠢ���� ����⨪�', ;
      '����/।���஢���� �ࠢ�� ����⨪�', ;
      '����ன�� �ࠢ�� ����⨪�' }
    mas_fun := { 'e_statist(41)', ;
      'e_statist(42)', ;
      'e_statist(43)', ;
      'e_statist(44)', ;
      'e_statist(45)' }
    popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    s_mnog_poisk()
  Case k == 16
    mas_pmt := { '�� �����த��� � ~�����࠭栬', ;
      '�ਪ�� �~848 ������', ;
      '~�����ਭ� ���ﭨ� ���஢�� ��ᥫ����', ;
      '��樮���/��.��樮��� - ��砨 �� ~��䨫�', ;
      '�⮬�⮫����᪠� �ଠ 39 - ~��������', ;
      '�⮬�⮫����᪠� �ଠ 39 - ~�������', ;
      '����� � ������⢥ �뤠���� ~�ࠢ�� ���' }
    mas_msg := { '�������� ����⮢ �� �����த��� � �����࠭栬 ��� ����', ;
      '�����⮢�� ���ଠ樨 �� �ᯮ������ �ਪ��� �848 ������', ;
      '�����ਭ� ���ﭨ� ���஢�� ��ᥫ���� (��ᮡ���� ���஢��� ��ࠧ� �����)', ;
      '������� ��樮����� ��砥� �� ��䨫� (�� ���������, ��� � ������)', ;
      '�⮬�⮫����᪠� �ଠ 39 �� ���ࣨ�᪨� ��񬠬', ;
      '�⮬�⮫����᪠� �ଠ 39 �� �࠯����᪨� ��񬠬', ;
      '����� � ������⢥ �뤠���� �ࠢ�� � �⮨���� ��������� ���.����� � ��� ���' }
    mas_fun := { 'e_statist(181)', ;
      'e_statist(182)', ;
      'e_statist(183)', ;
      'e_statist(184)', ;
      'e_statist(185)', ;
      'e_statist(186)', ;
      'e_statist(187)' }
//    If glob_mo[ _MO_KOD_TFOMS ] == '103001' // ������ᯠ���
//      AAdd( mas_pmt, '����� ��� ���� "���� ��������� ��.�.�.���஢�"' )
//      AAdd( mas_msg, '����� ��� ���� "���� ��������� ��.�.�.���஢�"' )
//      AAdd( mas_fun, 'ot_nmic_petrova()' )
//    Endif
    popup_prompt( T_ROW, T_COL -5, si18, mas_pmt, mas_msg, mas_fun )
  Case k == 181
    pr_inog_inostr()
  Case k == 182
    prikaz_848_miac()
  Case k == 183
    monitoring_zog()
  Case k == 184
    i_stac_sl_profil()
  Case k == 185
    f_stom_39_hirur()
  Case k == 186
    f_stom_39_terap()
  Case k == 187
    f_otchet_spravka_oms()
  Case Between( k, 21, 29 )
    pds := 2
    If eq_any( k, 21, 23 ) // ��� ��⮢ � ��� 14
      mas_pmt := { '�� ��� ~�믨᪨ ���', ;
        '�� ~����⭮�� ��ਮ��' }
      If ( j := popup_prompt( T_ROW, T_COL -5, sds, mas_pmt, , , 'B/BG,W+/B,N/BG,BG+/B' ) ) > 0
        sds := j
      Endif
      pds := j
    Endif
    If pds > 0
      Do Case
      Case k == 21
        mas_pmt := { '~���᮪ ��⮢', ;
          '� ��ꥤ������� �� ~�ਭ���������', ;
          '� ࠧ������ �� ~�⤥�����', ;
          '� ࠧ������ �� ��~����' }
        mas_fun := { 's3_statist(1)', ;
          's3_statist(2)', ;
          'e_statist(31)', ;
          's3_statist(4)' }
        Private pi4 := si4
        popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
        If pi4 != NIL ; si4 := pi4 ; Endif
      Case k == 22
        s4_statist()
      Case k == 23
        s5_statist()
      Case k == 24
        uzkie_spec()
      Endcase
    Endif
  Case k == 141
    mas_pmt := { '~���᮪ ��⮢', ;
      '� ��ꥤ������� �� ~�ਭ���������' }
    mas_fun := { 's3_statist(1)', ;
      's3_statist(2)' }
    Private pi4 := si4
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
    If pi4 != NIL ; si4 := pi4 ; Endif
  Case k == 142
    s5_statist()
  Case k == 143 // ����ॣ����஢���� ���
    spisok_s_not_registred()
  Case k == 144
    forma14_med_oms()
  Case k == 145
    forma1_ffoms()
  Case k == 146
    report_f_mpp()
  Case k == 147
    pril_5_6_62()
  Case k == 151 // �㬬� ��⨩ �� ��⠬
    akt_summa_of_refusal( 1 )
  Case k == 152 // ���᮪ ��⨩ �� ��⠬ (��䥪��)
    akt_list_of_refusal_defect()
  Case k == 153 // ���᮪ ��⨩ �� ��⠬ (��樥���)
    akt_list_of_refusal_pacient()
  Case k == 154 // ����⠭������� ���񬮢
    vosst_ob_em_rak()
  Case k == 155 // ���᮪ ���
    pr_list_rak()
  Case k == 156 // ���᮪ ��⮢ ��� ���
    pr_schet_bez_rak()
  Case k == 157 // �㬬� ��⨩ �� ��⠬ �� ��� ���
    akt_summa_of_refusal( 2 )
  Case k == 161 // ���᮪ ������� ����祭��
    i_list_of_pd()
  Case k == 171 // ���� ᢥન �� ���
    akt_sverki_smo()
  Case k == 172
    mas_pmt := { '�����, �����, ~����� �� ��⠬', ;
      '���⠢����� ~����⭮� ��������', ;
      '���� �室�饣� ~ᠫ줮' }
    mas_msg := { '��ᯥ�⪠ ���ଠ樨 �� ��⠬, �㬬� ��⨩ �� ���, �㬬� ����� � �����', ;
      '���⠢����� � �ᯥ�⪠ ����⭮� ��������', ;
      '���� �室�饣� ᠫ줮 ��� ���४⭮�� �ନ஢���� ����⭮� ��������' }
    mas_fun := { 'e_statist(191)', ;
      'e_statist(192)', ;
      'e_statist(193)' }
    popup_prompt( T_ROW, T_COL -5, si19, mas_pmt, mas_msg, mas_fun )
  Case k == 191 // ���⠢����/���/����祭�
    pr1_oborot_schet()
  Case k == 192 // ����⭠� ���������
    pr2_oborot_schet()
  Case k == 193 // ���� �室�饣� ᠫ줮
    saldo_oborot_schet()
  Case k == 31
    mas_pmt := { '�� �⤥�����, ��� ~�믨ᠭ ���', ;
      '�� �⤥�����, ��� ������� ~��㣨' }
    mas_fun := { 's3_statist(3, 1)', ;
      's3_statist(3, 2)' }
    popup_prompt( T_ROW, T_COL -5, 2, mas_pmt, mas_msg, mas_fun )
  Case k == 41 .or. k == 42
    Private pi_schet := 1
    If k == 41
      mas_pmt := { '�� ~�ᥬ ����', ;
        '�� ����, ~�����訬 � ���', ;
        '�� ����, ~�� �����訬 � ���' }
      If ( j := popup_prompt( T_ROW, T_COL -5, si61, mas_pmt, , , 'B/BG,W+/B,N/BG,BG+/B' ) ) == 0
        Return Nil
      Endif
      pi_schet := si61 := j
    Endif
    Private pi1 := k -40
    mas_pmt := { '�� ~���������', ;
      '��ଠ � 1~2', ;
      '��ଠ � 1~4', ;
      '��ଠ � 14~��', ;
      '��ଠ � 1~6-��', ;
      '��ଠ � ~30', ;
      '��ଠ � 3~9', ;
      '��ଠ � 5~7', ;
      '�� ~�����' }
    mas_msg := { '����⨪� �� ���������', ;
      '�������� � �᫥ �����������, ��ॣ����஢����� � ������...', ;
      '���� � ���⥫쭮�� ��樮���', ;
      '�������� � ���⥫쭮�� ������� ��樮��஢ ���', ;
      '�������� � ��稭�� �६����� ����㤮ᯮᮡ����', ;
      '�������� �� ��०����� ��ࠢ���࠭����', ;
      '��� ��� � ���饭�� � ����������� � �� ����', ;
      '�������� � �ࠢ���, ��ࠢ������ � ��㣨� ��᫥��⢨�� �������⢨� ���譨� ��稭', ;
      '�����, �� ����� �������� �ࠪ�� ����������� (��ࢨ筮�/����୮�)' }
    mas_fun := { 'e_statist(51)', ;
      'e_statist(52)', ;
      'e_statist(53)', ;
      'e_statist(54)', ;
      'e_statist(55)', ;
      'e_statist(56)', ;
      'e_statist(57)', ;
      'e_statist(58)', ;
      'e_statist(59)' }
    popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, mas_msg, mas_fun )
  Case k == 43
    prover_rule()
  Case k == 44
    mas_pmt := { '�ࠢ��� ~������ ��ࠢ���࠭����', ;
      '�ࠢ��� ~��祡���� ��०�����' }
    mas_msg := { '��ᬮ�� �ࠢ�� ����⨪� ������ ��ࠢ���࠭����', ;
      '����/।���஢���� �ࠢ�� ����⨪� ��襣� ��祡���� ��०�����' }
    mas_fun := { 'e_statist(61)', ;
      'e_statist(62)' }
    popup_prompt( T_ROW, T_COL -5, si7, mas_pmt, mas_msg, mas_fun )
  Case k == 45
    nastr_rule()
  Case k == 51
    mas_pmt := { '~���� �ଠ', ;
      '�� ~����姭��� ��ࠬ', ;
      '�� ~��姭��� ��ࠬ', ;
      '�� ~�����㯯�� �����������', ;
      '�� ~��㯯�� �����������', ;
      '~���騩 ��� + ��������' }
    mas_msg := { '����⨪� �� ���������: ���� �ଠ', ;
      '����⨪� �� ���������: �� ����姭��� ��ࠬ', ;
      '����⨪� �� ���������: �� ��姭��� ��ࠬ', ;
      '����⨪� �� ���������: �� �����㯯�� �����������', ;
      '����⨪� �� ���������: �� ��㯯�� �����������', ;
      '����⨪� �� ���������: ���騩 ��� + ��������' }
    mas_fun := { 'e_statist(71)', ;
      'e_statist(72)', ;
      'e_statist(73)', ;
      'e_statist(74)', ;
      'e_statist(75)', ;
      'e_statist(76)' }
    If is_uchastok > 0
      AAdd( mas_pmt, '~���⮪ + ��������' )
      AAdd( mas_msg, '����⨪� �� ���������: ���⮪ + ��������' )
      AAdd( mas_fun, 'e_statist(77)' )
    Endif
    popup_prompt( T_ROW, T_COL -5, si8, mas_pmt, mas_msg, mas_fun )
  Case k == 52
    forma_12()
  Case k == 53
    forma_14()
  Case k == 54
    forma_14ds()
  Case k == 55
    forma_16()
  Case k == 56
    forma_30()
  Case k == 57
    forma_39()
  Case k == 58
    forma_57()
  Case k == 59
    f_stat_boln()
  Case k == 61 .or. k == 62
    Private prs := k -60
    Private file_stat := { f_stat_com, f_stat_lpu }[ prs ]
    Private dostup_stat := { .f., .t. }[ prs ]
    If kod_polzovat == Chr( 0 )
      dostup_stat := .t.
    Endif
    If !hb_user_curUser:isadmin()
      dostup_stat := .f.
    Endif
    Private s_msg := '^<Esc>^ ��室'
    If dostup_stat
      s_msg += ' ^<Enter>^ ।���஢���� ^<Ins>^ ���������� ^<Del>^ 㤠�����'
    Endif
    s_msg += ' ^<F1>^ ������'
    mas_pmt := { '~����� �����������', ;
      '~��ᯠ��ਧ���', ;
      '������� + ~���' }
    mas_fun := { 'e_statist(81)', ;
      'e_statist(82)', ;
      'e_statist(83)' }
    If prs == 2 // ⮫쪮 ��� ���
      AAdd( mas_pmt, '~������ �������' )
      AAdd( mas_fun, 'e_statist(84)' )
      If yes_bukva
        AAdd( mas_pmt, '~�㪢� ࠧ � ���' )
        AAdd( mas_fun, 'e_statist(85)' )
        AAdd( mas_pmt, '~���⠭�� �㪢' )
        AAdd( mas_fun, 'e_statist(86)' )
      Endif
    Endif
    mas_msg := {}
    i := 0
    Do While i < Len( mas_pmt )
      i := i + 1
      AAdd( mas_msg, '�ࠢ��� ' + iif( prs == 1, '���-', '���-' ) + Str( i, 1 ) + ': ' + rule_section[ i ] )
    Enddo
    popup_prompt( T_ROW, T_COL -5, si9, mas_pmt, mas_msg, mas_fun )
  Case k == 71
    diag0statist()
  Case k == 72
    diag_statist( 1 )
  Case k == 73
    diag_statist( 2 )
  Case k == 74
    diag_statist( 3 )
  Case k == 75
    diag_statist( 4 )
  Case k == 76
    diaglvstatist()
  Case k == 77
    diaglustatist()
  Case k == 81
    st_rule_1()
  Case k == 82
    st_rule_2()
  Case k == 83
    st_rule_3()
  Case k == 84
    st_rule_4()
  Case k == 85
    st_rule_5()
  Case k == 86
    st_rule_6()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si5 := j
    Elseif Between( k, 51, 59 )
      si6 := j
    Elseif Between( k, 61, 69 )
      si7 := j
    Elseif Between( k, 71, 79 )
      si8 := j
    Elseif Between( k, 81, 89 )
      si9 := j
    Elseif Between( k, 121, 129 )
      si12 := j
    Elseif Between( k, 141, 149 )
      si14 := j
    Elseif Between( k, 151, 159 )
      si15 := j
    Elseif Between( k, 161, 169 )
      si16 := j
    Elseif Between( k, 171, 179 )
      si17 := j
    Elseif Between( k, 181, 189 )
      si18 := j
    Elseif Between( k, 191, 199 )
      si19 := j
    Endif
  Endif

  Return Nil


// 01.11.24 ����⠭������� ���񬮢
Function vosst_ob_em_rak()

  Static arr_smo, mm_pz
  Static mm_poisk := { { '�� ��� ��� (XML-䠩��)', 0 }, ;
    { '�� ��� ��� ����஫� ', 1 } }
  Static mm_eks := { { '�� ', 0 }, { '��� ', 1 }, { '��� ', 2 }, { '����', 3 } }
  Static s1eks := 0, s1smo := 0, s1pz := 0, s1poisk := 0
  Local buf := SaveScreen(), i, ar, s, r := 14
  Local nameArr // , funcGetPZ

  If arr_smo == NIL
    arr_smo := mo_cut_menu( glob_arr_smo )
    For i := 1 To Len( arr_smo )
      arr_smo[ i, 3 ] := PadR( lstr( arr_smo[ i, 2 ] ), 5 )
      arr_smo[ i, 2 ] := i
    Next
    If Len( arr_smo ) > 2
      ASize( arr_smo, 2 ) // ��ᥪ��� �����
    Endif
    mm_pz := { { '��', 0 } }

    // nameArr := 'glob_array_PZ_' + '19'  // last_digits_year(ly)

    // for i := 1 to len(glob_array_PZ_19)
    // aadd(mm_pz, {glob_array_PZ_19[i, 3],glob_array_PZ_19[i, 1]})
    // For i := 1 To Len( &nameArr )
    // AAdd( mm_pz, { &nameArr.[ i, 3 ], &nameArr.[ i, 1 ] } )
    // Next

    // funcGetPZ := 'get_array_PZ_19()'
    // nameArr := &funcGetPZ
    nameArr := get_array_pz( 2024 )
    For i := 1 To Len( nameArr )
      AAdd( mm_pz, { nameArr[ i, 3 ], nameArr[ i, 1 ] } )
    Next

  Endif
  If Empty( s1smo )
    s1smo := 0
    For i := 1 To Len( arr_smo )
      s1smo := SetBit( s1smo, arr_smo[ i, 2 ] )
    Next
  Endif
  Private mdate := Space( 10 ), m1date := 0, ;
    msmo, m1smo := s1smo, ;
    meks, m1eks := s1eks, ;
    mpz, m1pz := s1pz, ;
    mpoisk, m1poisk := s1poisk, ;
    myear := 2024, mkvartal := 0
  Private pdate, gl_arr := { ;  // ��� ��⮢�� �����
    { 'smo', 'N', 10, 0, , , , {| x| inieditspr( A__MENUBIT, arr_smo, x ) } };
    }
  mpoisk := inieditspr( A__MENUVERT, mm_poisk, m1poisk )
  meks   := inieditspr( A__MENUVERT, mm_eks,   m1eks )
  mpz    := inieditspr( A__MENUVERT, mm_pz,    m1pz  )
  msmo   := inieditspr( A__MENUBIT,  arr_smo,  m1smo )
  SetColor( cDataCGet )
  myclear( r )
  Private gl_area := { r, 1, MaxRow() -1, MaxCol(), 0 }, pdate
  status_key( '^<Esc>^ - ��室;  ^<PgDn>^ - ��⠢����� ���㬥��' )
  //
  @ r, 0 To MaxRow() -1, MaxCol() Color color8
  str_center( r, ' ����⠭������� ���񬮢 (�����⮢�� ���ଠ樨) ', color14 )
  Do While .t.
    @ r + 2, 2 Say '���客��(�) ��������(�)' Get msmo ;
      reader {| x| menu_reader( x, arr_smo, A__MENUBIT, , , .f. ) }
    @ r + 3, 2 Say '��ਮ� �६���' Get mdate ;
      reader {| x| menu_reader( x, { {| k, r, c| ;
      k := year_month( r + 1, c ), iif( k == nil, nil, ( pdate := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
      k } }, A__FUNCTION, , , .f. ) }
    @ r + 4, 2 Say '��� ������뢠�� (���/����)' Get mpoisk ;
      reader {| x| menu_reader( x, mm_poisk, A__MENUVERT, , , .f. ) }
    @ r + 5, 2 Say '��� �ᯥ�⨧�' Get meks ;
      reader {| x| menu_reader( x, mm_eks, A__MENUVERT, , , .f. ) }
    @ r + 6, 2 Say '��� ����-������' Get mpz ;
      reader {| x| menu_reader( x, mm_pz, A__MENUVERT_SPACE, , , .f. ) }
    @ r + 7, 2 Say '������ ��� 2024, ������ ����⠫' Get mkvartal Pict '9' Range 0, 4
    myread()
    If LastKey() == K_ESC
      Exit
    Endif
    s1smo := m1smo
    s1pz  := m1pz
    s1eks := m1eks
    s1poisk := m1poisk
    If Empty( pdate )
      func_error( 4, '�� ����� ��ਮ� �६���' )
    Elseif pdate[ 1 ] < 2024
      func_error( 4, '����� ०�� ����ᠭ ��� 2024 ����' )
    Elseif Empty( m1smo )
      func_error( 4, '�� ������� ���客�� ��������' )
    Else
      ar := {} ; s := ''
      For i := 1 To Len( arr_smo )
        If IsBit( s1smo, i )
          AAdd( ar, arr_smo[ i, 3 ] )
          s += arr_smo[ i, 1 ] + ', '
        Endif
      Next
      s := SubStr( s, 1, Len( s ) -2 )
      f1vosst_ob_em_rak( ar, s, mm_pz )
    Endif
  Enddo
  RestScreen( buf )

  Return Nil

// 02.10.19 �㭪�� ��� ᯨ᪠ ��� ����⠭������� ���񬮢
Function f1vosst_ob_em_rak( asmo, ssmo, mm_pz )

  Local adbf, i, nkvartal, n_file := 'v_ob_em' + stxt, HH := 60, sh := 80, buf := save_maxrow(), t_arr[ 2 ]

  mywait()
  adbf := { { 'kvartal', 'N', 1, 0 }, ;
    { 'nschet', 'C', 15, 0 }, ;
    { 'dschet', 'D', 8, 0 }, ;
    { 'pos_sch', 'N', 6, 0 }, ;
    { 'vid_pz', 'C', 45, 0 }, ;
    { 'ed_pz', 'N', 4, 0 }, ;
    { 'nakt', 'C', 26, 0 }, ;
    { 'dakt', 'D', 8, 0 }, ;
    { 'nrak', 'C', 26, 0 }, ;
    { 'drak', 'D', 8, 0 }, ;
    { 'usluga', 'C', 10, 0 };
    }
  dbCreate( cur_dir + 'v_ob_em', adbf )
  Use ( cur_dir + 'v_ob_em' ) New Alias TMP
  use_base( 'lusl' )
  use_base( 'luslc' )
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'schet_', , 'SCHET_' )
  r_use_base( 'human_u' )
  Set Relation To u_kod into USL
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_
  r_use( dir_server + 'mo_raksh', , 'RAKSH' )
  Index On Str( kod_raks, 6 ) To tmpraksh memory
  r_use( dir_server + 'mo_raks', , 'RAKS' )
  Index On Str( akt, 6 ) To tmpraks memory
  r_use( dir_server + 'mo_rak', , 'RAK' )
  Index On Str( kod_xml, 6 ) + DToS( dakt ) + nakt To tmprak memory
  r_use( dir_server + 'mo_xml', , 'MO_XML' )
  Index On dfile To tmp_xml For TIP_IN == _XML_FILE_RAK memory
  Go Top
  Do While !Eof()
    If iif( m1poisk == 0, Between( mo_xml->DFILE, pdate[ 5 ], pdate[ 6 ] ), .t. )
      Select RAK
      find ( Str( mo_xml->kod, 6 ) )
      Do While mo_xml->kod == rak->kod_xml .and. !Eof()
        If iif( m1poisk == 1, Between( rak->dakt, pdate[ 5 ], pdate[ 6 ] ), .t. )
          vid_eks := ret_vid_eks()
          Select RAKS
          find ( Str( rak->akt, 6 ) )
          Do While rak->akt == raks->akt .and. !Eof()
            If AScan( asmo, raks->plat ) > 0
              schet_->( dbGoto( raks->schet ) )
              If schet_->NMONTH < 4
                nkvartal := 1
              Elseif schet_->NMONTH < 7
                nkvartal := 2
              Elseif schet_->NMONTH < 10
                nkvartal := 3
              Else
                nkvartal := 4
              Endif
              If ( fl := schet_->NYEAR == myear ) .and. mkvartal > 0
                fl := nkvartal == mkvartal
              Endif
              If fl
                Select RAKSH
                find ( Str( raks->kod_raks, 6 ) )
                Do While raks->kod_raks == raksh->kod_raks .and. !Eof()
                  If raksh->OPLATA == 2 // ����� �⪠�
                    human->( dbGoto( raksh->KOD_H ) )
                    s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
                    ssh := raksh->penalty
                    fl := .f.
                    If m1eks == 0
                      fl := .t.
                    Elseif vid_eks == 2 .or. !Empty( raksh->SANK_EKMP )
                      fl := ( m1eks == 3 )
                    Elseif vid_eks == 1 .or. !Empty( raksh->SANK_MEE )
                      fl := ( m1eks == 2 )
                    Else
                      fl := ( m1eks == 1 )
                    Endif
                    If fl .and. m1pz > 0
                      fl := ( m1pz == human_->pztip )
                    Endif
                    If fl
                      Select TMP
                      Append Blank
                      tmp->kvartal := nkvartal
                      tmp->nschet := AllTrim( schet_->nschet )
                      tmp->dschet := schet_->dschet
                      tmp->pos_sch := human_->SCHET_ZAP
                      tmp->vid_pz := inieditspr( A__MENUVERT, mm_pz, human_->pztip )
                      tmp->ed_pz := iif( human_->usl_ok < 3, 1, human_->PZKOL )
                      tmp->nakt := AllTrim( rak->nakt )
                      tmp->dakt := rak->dakt
                      tmp->nrak := AllTrim( mo_xml->FNAME )
                      tmp->drak := mo_xml->DFILE
                      If human_->usl_ok == 3
                        Select HU
                        find ( Str( human->kod, 7 ) )
                        Do While hu->kod == human->kod .and. !Eof()
                          If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
                            lshifr := usl->shifr
                          Endif
                          If eq_any( Left( lshifr, 4 ), '2.78', '2.79', '2.80', '2.82', '2.88' )
                            tmp->usluga := lshifr
                            Exit
                          Endif
                          Select HU
                          Skip
                        Enddo
                      Endif
                    Endif
                  Endif
                  Select RAKSH
                  Skip
                Enddo
              Endif
            Endif
            Select RAKS
            Skip
          Enddo
        Endif
        Select RAK
        Skip
      Enddo
    Endif
    Select MO_XML
    Skip
  Enddo
  adbf := { { 'vid_pz', 'C', 45, 0 }, ;
    { 'ed_pz', 'N', 4, 0 }, ;
    { 'nrak', 'C', 26, 0 }, ;
    { 'drak', 'D', 8, 0 };
    }
  dbCreate( cur_dir + 'tmp1', adbf )
  Use ( cur_dir + 'tmp1' ) new
  Index On nrak + vid_pz to ( cur_dir + 'tmp1' )
  Select TMP
  Go Top
  Do While !Eof()
    Select TMP1
    find ( tmp->nrak + tmp->vid_pz )
    If !Found()
      Append Blank
      tmp1->vid_pz := tmp->vid_pz
      tmp1->nrak := tmp->nrak
      tmp1->drak := tmp->drak
    Endif
    tmp1->ed_pz += tmp->ed_pz
    Select TMP
    Skip
  Enddo
  If tmp1->( LastRec() ) == 0
    func_error( 4, '�� ������� ������ ��祣� �� �������!' )
  Else
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( '' )
    add_string( Center( '��� �ᯥ�⨧�: ' + meks, sh ) )
    add_string( Center( '���: ' + ssmo, sh ) )
    add_string( Center( '���� ' + iif( m1poisk == 0, '��� - ', '��⮢ ����஫� - ' ) + pdate[ 4 ], sh ) )
    If m1pz > 0
      add_string( Center( '��� ����-������: ' + mpz, sh ) )
    Endif
    add_string( Center( '����⠭����� ��ꥬ�, 㤥ঠ��� �� ᫥���騬 䠩��� ���:', sh ) )
    Select TMP1
    Go Top
    Do While !Eof()
      s := AllTrim( tmp1->nrak ) + ' �� ' + date_8( tmp1->drak ) + ', ' + AllTrim( tmp1->vid_pz ) + ;
        ' � ������⢥ - ' + lstr( tmp1->ed_pz ) + ' ��.'
      verify_ff( HH, .t., sh )
      add_string( '' )
      For i := 1 To perenos( t_arr, s, sh )
        add_string( t_arr[ i ] )
      Next
      Skip
    Enddo
    FClose( fp )
    Close databases
    rest_box( buf )
    viewtext( n_file, , , , .t., , , 2 )
    t_arr := { '� ��⠫��� ' + cur_dir, ;
      'ᮧ��� 䠩� V_OB_EM.DBF', ;
      '� ᯨ᪮� ��樥�⮢ ��� ����㧪� � Excel' }
    n_message( t_arr, , 'GR+/R', 'W+/R', , , 'G+/R' )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// ��ꥬ ࠡ�� ���ᮭ��� (�� �������� ��㣠)
Function ob1_statist( k, k1 )

  Static si0 := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, ;
    si6 := 1, si_slugba
  Local mas_pmt, mas_msg, mas_fun, j, fl

  Do Case
  Case k == 0
    pi1 := k1
    Private pi_schet := 1
    If k1 == 3
      mas_pmt := { '�� ~�ᥬ ����', ;
        '�� ����, ~�����訬 � ���', ;
        '�� ����, ~�� �����訬 � ���' }
      If ( j := popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, , , 'B/BG,W+/B,N/BG,BG+/B' ) ) == 0
        Return Nil
      Endif
      pi_schet := si6 := j
    Endif
    mas_pmt := { '~�⮨����� ��祭��', ;
      '~��ࠡ�⭠� ����' }
    mas_msg := { '����⨪� �� ����� ࠡ�� � �����⮬ �⮨���� ��祭��', ;
      '����⨪� �� ����� ࠡ�� � �����⮬ ��ࠡ�⭮� �����' }
    mas_fun := { 'ob1_statist(1, 1)', ;
      'ob1_statist(1, 2)' }
    popup_prompt( T_ROW, T_COL -5, si0, mas_pmt, mas_msg, mas_fun, color0 + ',R/BG,GR+/N' )
  Case k == 1
    psz := si0 := k1
    mas_pmt := { '~�⤥�����', ;
      '~��㦡�', ;
      '~���ᮭ��', ;
      '~��㣨' }
    mas_msg := { '����⨪� �� ࠡ�� ���ᮭ��� � �������� ��㣠� � �⤥������', ;
      '������⢮ ��� � �㬬� ��祭�� �� �㦡��', ;
      '����⨪� �� ࠡ�� ���ᮭ��� (������ᨬ� �� �⤥�����)', ;
      '����⨪� �� �������� �������� ��� (������ᨬ� �� �⤥�����)' }
    mas_fun := { 'ob1_statist(11)', ;
      'ob1_statist(12)', ;
      'ob1_statist(13)', ;
      'ob1_statist(14)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11  // �⤥�����
    mas_pmt := { '~���᮪ �⤥�����', ;
      '�⤥����� + ~���ᮭ��', ;
      '�⤥����� + ~��㣨', ;
      '�⤥����~� + ��㣨', ;
      '~�⤥����� + ���ᮭ�� + ��㣨', ;
      '�⤥����� + ��㣠 + ~�����', ;
      '�⤥����� + 1 祫���� + ��~���' }
    mas_msg := { '������⢮ ��� � �㬬� ��祭�� �� �⤥�����', ;
      '����⨪� �� ࠡ�� ���ᮭ��� � �����⭮� �⤥�����', ;
      '����⨪� �� ��㣠�, �������� � �����⭮� �⤥�����', ;
      '����⨪� �� ��㣠�, �������� � �⤥������ (���� �஬������ �⮣�)', ;
      '����⨪� �� ࠡ�� ���ᮭ��� (���� �������� ��㣨) � �����⭮� �⤥�����', ;
      '����⨪� �� ��������� ��㣥 (���� �����) � �����⭮� �⤥�����', ;
      '����⨪� �� ࠡ�� 1 祫����� (���� �����) � �����⭮� �⤥�����' }
    mas_fun := { 'ob1_statist(21)', ;
      'ob1_statist(22)', ;
      'ob1_statist(23)', ;
      'ob1_statist(24)', ;
      'ob1_statist(25)', ;
      'ob1_statist(26)', ;
      'ob1_statist(27)' }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 12  // �㦡�
    mas_pmt := { '��㦡� + ~�⤥�����', ;
      '�⤥����� + ~�㦡�', ;
      '��㦡� + ~��㣨', ;
      '��㦡~� + ��㣨', ;
      '�⤥����~� + �㦡� + ��㣨', ;
      '�⤥���~�� + �㦡� + ��㣨' }
    mas_msg := { '������⢮ ��� � �㬬� ��祭�� �� �㦡�� (� ࠧ������ �� �⤥�����)', ;
      '������⢮ ��� � �㬬� ��祭�� �� �⤥����� (� ࠧ������ �� �㦡��)', ;
      '����⨪� �� �������� ��㣠� (� ��ꥤ������� �� �㦡��)', ;
      '����⨪� �� �������� ��㣠� (�� �����⭮� �㦡�)', ;
      '����⨪� �� �������� ��㣠� � �����⭮� �⤥����� (� ��ꥤ. �� �㦡��)', ;
      '����⨪� �� �������� ��㣠� � �����⭮� �⤥����� (�� �����⭮� �㦡�)' }
    mas_fun := { 'ob1_statist(31)', ;
      'ob1_statist(32)', ;
      'ob1_statist(33)', ;
      'ob1_statist(34)', ;
      'ob1_statist(35)', ;
      'ob1_statist(36)' }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 13  // ���ᮭ��
    mas_pmt := { '1 祫���� + ~��㣨', ;
      '1 祫���� + ��㣨 + ~�����', ;
      '~���� ���ᮭ��', ;
      '~N 祫���� + ��㣨', ;
      '���� ~���ᮭ�� + ��㣨' }
    mas_msg := { '����⨪� �� ࠡ�� �����⭮�� ࠡ���饣� (���� �������� ��㣨)', ;
      '����⨪� �� ࠡ�� �����⭮�� ࠡ���饣� (���� ��㣨 ���� �����)', ;
      '������⢮ ��� � �㬬� ��祭�� �� �ᥬ� ᯨ�� ࠡ�����', ;
      '����⨪� �� ࠡ�� �������� ࠡ����� (���� �������� ��㣨)', ;
      '����⨪� �� ࠡ�� ��� ࠡ����� (���� �������� ��㣨)' }
    mas_fun := { 'ob1_statist(41)', ;
      'ob1_statist(42)', ;
      'ob1_statist(43)', ;
      'ob1_statist(44)', ;
      'ob1_statist(45)' }
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 14  // ��㣨
    mas_pmt := { '~���᮪ ���', ;
      '�� ~��㣨', ;
      '���᮪ ���+~�����' }
    mas_msg := { '����⨪� �� �������� �������� ��� (������ᨬ� �� �⤥�����)', ;
      '����⨪� �� �������� ��� ��� (������ᨬ� �� �⤥�����)', ;
      '����⨪� �� �������� �������� ��� [� ����묨] (������ᨬ� �� �⤥�����)' }
    mas_fun := { 'ob1_statist(51)', ;
      'ob1_statist(52)', ;
      'ob1_statist(53)' }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
    // �⤥�����
  Case k == 21    // ᯨ᮪ �⤥�����
    ob2_statist( 1 )
  Case k == 22    // �⤥����� + ���ᮭ��
    ob2_statist( 2 )
  Case k == 23    // �⤥����� + ��㣨
    ob2_statist( 3 )
  Case k == 24    // �⤥����� + ��㣨
    ob2_statist( 31 )
  Case k == 25    // �⤥����� + ���ᮭ�� + ��㣨
    ob2_statist( 4 )
  Case k == 26    // �⤥����� + ��㣠 + �����
    ob2_statist( 8 )
  Case k == 27    // �⤥����� + ���ᮭ�� + �����
    ob2_statist( 9 )
    // �㦡�
  Case k == 31    // �㦡� + �⤥�����
    ob2_statist( 0 )
  Case k == 32    // �⤥����� + �㦡�
    ob2_statist( 100 )
  Case k == 33    // �㦡� + ��㣨
    ob2_statist( 10 )
  Case equalany( k, 34, 36 )    // �㦡� + ��㣨
    fl := .f.
    r_use( dir_server + 'slugba', dir_server + 'slugba', 'SL' )
    If si_slugba == NIL
      Go Top
    Else
      find ( Str( si_slugba, 3 ) )
    Endif
    If alpha_browse( T_ROW, T_COL -5, MaxRow() -2, T_COL + 45, 'f2spr_other', color0 )
      fl := .t. ; si_slugba := sl->shifr
      j := { sl->shifr, lstr( sl->shifr ) + '. ' + AllTrim( sl->name ) }
    Endif
    sl->( dbCloseArea() )
    If fl
      ob2_statist( iif( k == 34, 11, 111 ), j )
    Endif
  Case k == 35    // �⤥����� + �㦡� + ��㣨
    ob2_statist( 110 )
    // ���ᮭ��
  Case k == 41    // ������� ࠡ���騩 + ��㣨
    ob2_statist( 5 )
  Case k == 42    // ������� ࠡ���騩 + ��㣨 + �����
    ob2_statist( 13 )
  Case k == 43    // ᯨ᮪ ���ᮭ��� � ��ꥬ�� ࠡ��
    ob2_statist( 7 )
  Case k == 44    // ᯨ᮪ ࠡ����� + ��㣨
    ob2_statist( 5, { 1 } )
  Case k == 45    // ���� ���ᮭ�� + ��㣨
    ob2_statist( 5, { 2 } )
    // ��㣨
  Case k == 51    // ᯨ᮪ ���
    ob2_statist( 6 )
  Case k == 52    // �� ��㣨
    ob2_statist( 12 )
  Case k == 53    // ᯨ᮪ ��� + �����
    ob2_statist( 14 )
  Endcase
  If k > 10
    If Between( k, 11, 19 )
      si1 := k -10
    Elseif Between( k, 21, 29 )
      si2 := k -20
    Elseif Between( k, 31, 39 )
      si3 := k -30
    Elseif Between( k, 41, 49 )
      si4 := k -40
    Elseif Between( k, 51, 59 )
      si5 := k -50
    Endif
  Endif

  Return Nil

// 12.03.14 ��ꥬ ࠡ�� ���ᮭ��� (�� ����������� �����)
Function obf_statist( k, k1 )

  Static si0 := 1, si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si6 := 1
  Local mas_pmt, mas_msg, mas_fun, j, fl

  Do Case
  Case k == 0
    pi1 := k1
    Private pi_schet := 1
    If k1 == 3
      mas_pmt := { '�� ~�ᥬ ����', ;
        '�� ����, ~�����訬 � ���', ;
        '�� ����, ~�� �����訬 � ���' }
      If ( j := popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, , , 'B/BG,W+/B,N/BG,BG+/B' ) ) == 0
        Return Nil
      Endif
      pi_schet := si6 := j
    Endif
    /*mas_pmt := {'~�⮨����� ��祭��', ;
                '~��ࠡ�⭠� ����'}
    mas_msg := {'����⨪� �� ����� ࠡ�� � �����⮬ �⮨���� ��祭��', ;
                '����⨪� �� ����� ࠡ�� � �����⮬ ��ࠡ�⭮� �����'}
    mas_fun := {'obF_statist(1, 1)', ;
                'obF_statist(1, 2)'}
    popup_prompt(T_ROW,T_COL-5,si0,mas_pmt,mas_msg,mas_fun,color0+ ',R/BG,GR+/N')*/
    obf_statist( 1, 1 )
  Case k == 1
    psz := si0 := k1
    mas_pmt := { '~�⤥�����', ;
      '~���ᮭ��', ;
      '~�����������' }
    mas_msg := { '����⨪� �� ࠡ�� ���ᮭ��� � �������� ������������ ��㣠� � �⤥������', ;
      '����⨪� �� ࠡ�� ���ᮭ��� (������ᨬ� �� �⤥�����)', ;
      '����⨪� �� �������� �������� ������������� ��� (������ᨬ� �� �⤥�����)' }
    mas_fun := { 'obF_statist(11)', ;
      'obF_statist(12)', ;
      'obF_statist(13)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11  // �⤥�����
    mas_pmt := { '~���᮪ �⤥�����', ;
      '�⤥����� + ~���ᮭ��', ;
      '�⤥����� + ~��㣨', ;
      '�⤥����~� + ��㣨', ;
      '~�⤥����� + ���ᮭ�� + ��㣨', ;
      '�⤥����� + ��㣠 + ~�����', ;
      '�⤥����� + 1 祫���� + ��~���' }
    mas_msg := { '������⢮ ��� �� �⤥�����', ;
      '����⨪� �� ࠡ�� ���ᮭ��� � �����⭮� �⤥�����', ;
      '����⨪� �� ��㣠�, �������� � �����⭮� �⤥�����', ;
      '����⨪� �� ��㣠�, �������� � �⤥������ (���� �஬������ �⮣�)', ;
      '����⨪� �� ࠡ�� ���ᮭ��� (���� �������� ��㣨) � �����⭮� �⤥�����', ;
      '����⨪� �� ��������� ��㣥 (���� �����) � �����⭮� �⤥�����', ;
      '����⨪� �� ࠡ�� 1 祫����� (���� �����) � �����⭮� �⤥�����' }
    mas_fun := { 'obF_statist(21)', ;
      'obF_statist(22)', ;
      'obF_statist(23)', ;
      'obF_statist(24)', ;
      'obF_statist(25)', ;
      'obF_statist(26)', ;
      'obF_statist(27)' }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 12  // ���ᮭ��
    mas_pmt := { '1 祫���� + ~��㣨', ;
      '1 祫���� + ��㣨 + ~�����', ;
      '~���� ���ᮭ��', ;
      '~N 祫���� + ��㣨', ;
      '���� ~���ᮭ�� + ��㣨' }
    mas_msg := { '����⨪� �� ࠡ�� �����⭮�� ࠡ���饣� (���� �������� ��㣨)', ;
      '����⨪� �� ࠡ�� �����⭮�� ࠡ���饣� (���� ��㣨 ���� �����)', ;
      '������⢮ ��� �� �ᥬ� ᯨ�� ࠡ�����', ;
      '����⨪� �� ࠡ�� �������� ࠡ����� (���� �������� ��㣨)', ;
      '����⨪� �� ࠡ�� ��� ࠡ����� (���� �������� ��㣨)' }
    mas_fun := { 'obF_statist(41)', ;
      'obF_statist(42)', ;
      'obF_statist(43)', ;
      'obF_statist(44)', ;
      'obF_statist(45)' }
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 13  // ��㣨
    mas_pmt := { '~���᮪ ���', ;
      '�� ~��㣨', ;
      '���᮪ ���+~�����' }
    mas_msg := { '����⨪� �� �������� �������� ��� (������ᨬ� �� �⤥�����)', ;
      '����⨪� �� �������� ��� ��� (������ᨬ� �� �⤥�����)', ;
      '����⨪� �� �������� �������� ��� [� ����묨] (������ᨬ� �� �⤥�����)' }
    mas_fun := { 'obF_statist(51)', ;
      'obF_statist(52)', ;
      'obF_statist(53)' }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
    // �⤥�����
  Case k == 21    // ᯨ᮪ �⤥�����
    obf2_statist( 1 )
  Case k == 22    // �⤥����� + ���ᮭ��
    obf2_statist( 2 )
  Case k == 23    // �⤥����� + ��㣨
    obf2_statist( 3 )
  Case k == 24    // �⤥����� + ��㣨
    obf2_statist( 31 )
  Case k == 25    // �⤥����� + ���ᮭ�� + ��㣨
    obf2_statist( 4 )
  Case k == 26    // �⤥����� + ��㣠 + �����
    obf2_statist( 8 )
  Case k == 27    // �⤥����� + ���ᮭ�� + �����
    obf2_statist( 9 )
    // ���ᮭ��
  Case k == 41    // ������� ࠡ���騩 + ��㣨
    obf2_statist( 5 )
  Case k == 42    // ������� ࠡ���騩 + ��㣨 + �����
    obf2_statist( 13 )
  Case k == 43    // ᯨ᮪ ���ᮭ��� � ��ꥬ�� ࠡ��
    obf2_statist( 7 )
  Case k == 44    // ᯨ᮪ ࠡ����� + ��㣨
    obf2_statist( 5, { 1 } )
  Case k == 45    // ���� ���ᮭ�� + ��㣨
    obf2_statist( 5, { 2 } )
    // ��㣨
  Case k == 51    // ᯨ᮪ ���
    obf2_statist( 6 )
  Case k == 52    // �� ��㣨
    obf2_statist( 12 )
  Case k == 53    // ᯨ᮪ ��� + �����
    obf2_statist( 14 )
  Endcase
  If k > 10
    If Between( k, 11, 19 )
      si1 := k -10
    Elseif Between( k, 21, 29 )
      si2 := k -20
    Elseif Between( k, 31, 39 )
      si3 := k -30
    Elseif Between( k, 41, 49 )
      si4 := k -40
    Elseif Between( k, 51, 59 )
      si5 := k -50
    Endif
  Endif

  Return Nil


//
Function ret_g_o_i( r, c )

  Static sast := { .t., .f. }, ;
    sarr := { { '��த+�������', 1 }, ;
    { '�����த���  ', 2 } }
  Local ret, i, j, a

  If ( a := bit_popup( T_ROW, T_COL -5, sarr, sast ) ) != NIL
    ret := {} ; AFill( sast, .f. )
    For i := 1 To Len( a )
      AAdd( ret, a[ i, 2 ] )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
      Endif
    Next
  Endif

  Return ret

//
Function ret_z_n( r, c )

  Static sast := { .t., .t. }, ;
    sarr := { { '�� �����稢訥 ��祭��', B_END }, ;
    { '�����稢訥 ��祭��', B_STANDART } }
  Local ret, i, j, a

  If ( a := bit_popup( T_ROW, T_COL -5, sarr, sast ) ) != NIL
    ret := {} ; AFill( sast, .f. )
    For i := 1 To Len( a )
      AAdd( ret, a[ i, 2 ] )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
      Endif
    Next
  Endif

  Return ret

//
Function ret_reestr_no( r, c )

  Static sast := { .t., .t. }, ;
    sarr := { { '�� �����訥 � ॥����', 1 }, ;
    { '�����訥 � ॥����', 2 } }
  Local ret, i, j, a

  If ( a := bit_popup( T_ROW, T_COL -5, sarr, sast ) ) != NIL
    ret := {} ; AFill( sast, .f. )
    For i := 1 To Len( a )
      AAdd( ret, a[ i, 2 ] )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
      Endif
    Next
  Endif

  Return ret


// 28.12.21 ����⨪� �� ࠡ�� �����஢
Function st_operator()

  Local i, j, k, mdate, buf24, sh := 0, arr_oper := {}, arr_g, ;
    s0, s1, s2, s3, s4, buf, name_file := 'operator' + stxt, ;
    arr_title, reg_print := 2, ls, fl_orto := .f., r1 := 9, ;
    arrNtitle, llen, ldec, fl_old, fl_new
  Private koef0, koef1 := 20, koef2 := 9, koef21 := 3, koef3 := 1, ;
    stoim := 0.012, mprocent := 0, ;
    koef_orto := 22, koef1_orto := 22

  koef0 := koef1 - koef2
  If !hb_user_curUser:isadmin()
    Return func_error( 4, '����� � ����� ०�� ࠧ�襭 ⮫쪮 ������������ ��⥬�!' )
  Endif
  If ( arr_g := year_month() ) == NIL
    Return Nil
  Endif
  r_use( dir_server + 'mo_oper', dir_server + 'mo_oper', 'OP' )
  dbSeek( arr_g[ 7 ], .t. )
  fl_old := ( op->pd <= arr_g[ 8 ] .and. !Eof() )
  Close databases
  //
  r_use( dir_server + 'mo_opern', dir_server + 'mo_opern', 'OP' )
  dbSeek( arr_g[ 7 ], .t. )
  fl_new := ( op->pd <= arr_g[ 8 ] .and. !Eof() )
  Close databases
  buf24 := save_maxrow()
  If fl_old
    If is_task( X_ORTO )
      fl_orto := .t. ; r1 -= 2
    Endif
    SetColor( cDataCGet )
    buf := box_shadow( r1, 10, 22, 69 )
    str_center( r1 + 2, '��� �।�������� ᫥���騥 �����樥��� ��㤮������', color8 )
    str_center( r1 + 3, '(����� ������� ����������� ��।���஢���):', color8 )
    j := r1 + 5
    @ j, 13 Say '���������� ����⥪� (������������)               ' ;
      Get koef0 Pict '99' valid {| g| fst_operator( g ) }
    ++j
    @ j, 13 Say '���� ������ ४����⮢ �� ����� ���� ����      ' ;
      Get koef1 Pict '99' valid {| g| fst_operator( g ) }
    ++j
    @ j, 13 Say '�롮� �� ����⥪� �� ����� ���� ����          ' ;
      Get koef2 Pict '99' valid {| g| fst_operator( g ) }
    ++j
    @ j, 13 Say '������ �롮� ��樥�� �� ����⥪� �� �����   ' ;
      Get koef21 Pict '99' valid {| g| fst_operator( g ) }
    ++j
    @ j, 13 Say '�����樥�� ��㤮������ �� ����� ����� ��㣨   ' ;
      Get koef3 Pict '99' When .f.
    If fl_orto
      ++j
      @ j, 13 Say '���������� ����⥪� � ����� ���������           ' ;
        Get koef1_orto Pict '99' valid {| g| fst_operator( g ) }
      ++j
      @ j, 13 Say '���������� ��⮯����᪮� ����窨 ���쭮��       ' ;
        Get koef_orto Pict '99' valid {| g| fst_operator( g ) }
    Endif
    ++j
    @ j, 13 Say '���� ����� �᫮���� ������� ���ଠ樨 � �㡫��' ;
      Get stoim Pict '9.999'
    ++j
    @ j, 13 Say '��業� ��������' Get mprocent Pict '99'
    status_key( '^<Esc>^ - ��室 �� ०���;  ^<Enter>^ - ���⢥ত���� �����' )
    myread()
    rest_box( buf )
    If LastKey() == K_ESC
      Return Nil
    Endif
    If mprocent > 0
      reg_print := 3
    Endif
    mywait()
    arr_title := Array( 5 )
    arr_title[ 1 ] := '������������������������������������������������������������������������������������'
    arr_title[ 2 ] := '       �.�.�.       �����窠 � �����  ��롮� �� �  ���-�� ����� � ���� ���ࠡ��.'
    arr_title[ 3 ] := '     �����஢     �(ॣ�-�)�४�����볪���⥪��  ���  �� ��.� ࠡ�� � �㬬�  '
    arr_title[ 4 ] := '                    �' + PadC( '( *' + lstr( koef0 ) + ' )', 9 ) + ;
      '�' + PadC( '( *' + lstr( koef1 ) + ' )', 9 ) + ;
      '�' + PadC( '( *' + lstr( koef2 ) + '/' + lstr( koef21 ) + ' )', 9 ) + ;
      '�' + PadC( '( *' + lstr( koef3 ) + ' )', 9 ) + ;
      '�����. �  � %  � � ��. '
    arr_title[ 5 ] := '������������������������������������������������������������������������������������'
    If mprocent > 0
      arr_title[ 1 ] := arr_title[ 1 ] + '���������'
      arr_title[ 2 ] := arr_title[ 2 ] + '���௫��'
      arr_title[ 3 ] := arr_title[ 3 ] + '� � ��.'
      arr_title[ 4 ] := arr_title[ 4 ] + '�' + PadC( '(+ ' + lstr( mprocent ) + '%)', 8 )
      arr_title[ 5 ] := arr_title[ 5 ] + '���������'
    Endif
    sh := Len( arr_title[ 1 ] )
  Endif
  If fl_new
    arrNtitle := Array( 5 )
    arrNtitle[ 1 ] := '��������������������������������������������������������������������������������'
    arrNtitle[ 2 ] := '                              � ����⥪�  � ���� ���� �   ��㣨   ��ᥣ� ��- '
    arrNtitle[ 3 ] := '  �.�.�. �����஢           ��������������������������������������Ĵ।����-'
    arrNtitle[ 4 ] := '                              � 祫.� ������ �/� � ��������㣳 ���������� �����'
    arrNtitle[ 5 ] := '��������������������������������������������������������������������������������'
    sh := Max( sh, Len( arrNtitle[ 1 ] ) )
  Endif
  fp := FCreate( 'operator' + stxt ) ; tek_stroke := 0 ; n_list := 1
  add_string( '' )
  add_string( Center( '���� ࠡ��� �����஢', sh ) )
  add_string( Center( arr_g[ 4 ], sh ) )
  add_string( '' )
  If fl_old
    AEval( arr_title, {| x| add_string( x ) } )
    r_use( dir_server + 'base1', , 'B1' )
    r_use( dir_server + 'mo_oper', dir_server + 'mo_oper', 'OP' )
    dbSeek( arr_g[ 7 ], .t. )
    Do While op->pd <= arr_g[ 8 ] .and. !Eof()
      If ( i := AScan( arr_oper, {| x| x[ 1 ] == op->task } ) ) == 0
        AAdd( arr_oper, { op->task, {} } ) ; i := Len( arr_oper )
      Endif
      If op->app_edit == 1 .and. ;
          AScan( arr_oper[ i, 2 ], {| x| x[ 1 ] == op->po .and. x[ 10 ] == 0 } ) == 0
        b1->( dbGoto( Asc( op->po ) ) )
        AAdd( arr_oper[ i, 2 ], { op->po, ;
          Crypt( b1->p1, gpasskod ), ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0 } )
      Endif
      If ( k := AScan( arr_oper[ i, 2 ], ;
          {| x| x[ 1 ] == op->po .and. x[ 10 ] == op->app_edit } ) ) == 0
        b1->( dbGoto( Asc( op->po ) ) )
        AAdd( arr_oper[ i, 2 ], { op->po, ;
          Crypt( b1->p1, gpasskod ), ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          0, ;
          op->app_edit } )
        k := Len( arr_oper[ i, 2 ] )
      Endif
      If op->app_edit == 0
        llen := 6 ; ldec := 0
      Else
        llen := 7 ; ldec := 2
      Endif
      arr_oper[ i, 2, k, 3 ] += ft_Unsqzn( op->v0, llen, ldec )
      arr_oper[ i, 2, k, 4 ] += ft_Unsqzn( op->vr, llen, ldec )
      arr_oper[ i, 2, k, 5 ] += ft_Unsqzn( op->vk, 6, 0 )  // �ᥣ�� 楫�� �᫮
      arr_oper[ i, 2, k, 6 ] += ft_Unsqzn( op->vu, llen, ldec )
      Skip
    Enddo
    Store 0 To s0, s1, s2, s3, s4, skart, skart2
    ASort( arr_oper, , , {| x, y| x[ 1 ] < y[ 1 ] } )
    For i := 1 To Len( arr_oper )
      ASort( arr_oper[ i, 2 ], , , {| x, y| if( x[ 2 ] == y[ 2 ], x[ 10 ] < y[ 10 ], x[ 2 ] < y[ 2 ] ) } )
      AEval( arr_oper[ i, 2 ], {| x| s0 += x[ 3 ], s1 += x[ 4 ], s2 += x[ 5 ], s3 += x[ 6 ] } )
      If eq_any( arr_oper[ i, 1 ], 3, 4 )  // ���������
        AEval( arr_oper[ i, 2 ], {| x, j| arr_oper[ i, 2, j, 7 ] := ;
          Round( koef1_orto * x[ 3 ] + koef_orto * x[ 5 ] + koef3 * x[ 6 ], 0 ) } )
      Else
        AEval( arr_oper[ i, 2 ], {| x, j| arr_oper[ i, 2, j, 7 ] := ;
          Round( koef0 * x[ 3 ] + ;
          koef1 * x[ 4 ] + ;
          iif( x[ 10 ] == 0, koef2, koef21 ) * x[ 5 ] + ;
          koef3 * x[ 6 ], 0 ) ;
          } )
      Endif
      AEval( arr_oper[ i, 2 ], {| x, j| s4 += arr_oper[ i, 2, j, 7 ] } )
    Next
    Close databases
    s4 := Round( s4, 0 ) // ��ꥬ � �᫮���� ������� - 楫�� �᫮
    If s4 > 0
      For i := 1 To Len( arr_oper )
        For j := 1 To Len( arr_oper[ i, 2 ] )
          If arr_oper[ i, 2, j, 10 ] == 1 .and. j > 1 ;
              .and. arr_oper[ i, 2, j -1, 10 ] == 0 ;
              .and. arr_oper[ i, 2, j -1, 1 ] == arr_oper[ i, 2, j, 1 ]
            arr_oper[ i, 2, j -1, 7 ] += arr_oper[ i, 2, j, 7 ]
          Endif
          If arr_oper[ i, 2, j, 10 ] == 0   // ��� ⮫쪮 ����������
            skart += ( arr_oper[ i, 2, j, 4 ] + arr_oper[ i, 2, j, 5 ] )
          Endif
          If arr_oper[ i, 2, j, 10 ] == 1   // ��� ������ �롮஢
            skart2 += arr_oper[ i, 2, j, 5 ]
          Endif
          arr_oper[ i, 2, j, 8 ] := arr_oper[ i, 2, j, 7 ] * 100 / s4
        Next
      Next
      // ������ ��業⮢
      For i := 1 To Len( arr_oper )
        For j := 1 To Len( arr_oper[ i, 2 ] )
          arr_oper[ i, 2, j, 8 ] := arr_oper[ i, 2, j, 7 ] * 100 / s4
        Next
      Next
      k := ssum := szrp := 0 ; fl_orto := .f.
      For i := 1 To Len( arr_oper )
        sum1 := zrp1 := 0
        s := '��������� ��������'
        If arr_oper[ i, 1 ] == 1
          s := '������������'
        Elseif arr_oper[ i, 1 ] == 2
          s := '������� ������'
        Elseif eq_any( arr_oper[ i, 1 ], 3, 4 )
          s := '��������� ' + iif( arr_oper[ i, 1 ] == 3, '�������', '����������' )
          If !fl_orto
            arr_title[ 4 ] := Stuff( arr_title[ 4 ], 22, 9, PadC( '( *' + lstr( koef1_orto ) + ' )', 9 ) )
            arr_title[ 4 ] := Stuff( arr_title[ 4 ], 42, 9, PadC( '( *' + lstr( koef_orto ) + ' )', 9 ) )
            add_string( '' )
            AEval( arr_title, {| x| add_string( x ) } )
            fl_orto := .t.
          Endif
        Endif
        add_string( Center( Expand( s ), sh ) )
        For j := 1 To Len( arr_oper[ i, 2 ] )
          If arr_oper[ i, 2, j, 7 ] > 0
            If arr_oper[ i, 2, j, 10 ] == 0
              ++k
              ls := Round( arr_oper[ i, 2, j, 7 ] * stoim, 2 )
              sum1 += ls
              ssum += ls
              s := arr_oper[ i, 2, j, 2 ] + ;
                put_val( arr_oper[ i, 2, j, 3 ], 9 ) + ;
                put_val( arr_oper[ i, 2, j, 4 ], 10 ) + ;
                put_val( arr_oper[ i, 2, j, 5 ], 10 ) + ;
                put_val( arr_oper[ i, 2, j, 6 ], 10 ) + ;
                put_val( arr_oper[ i, 2, j, 7 ], 8 ) + ;
                put_val( arr_oper[ i, 2, j, 8 ], 8, 2 ) + ;
                put_kope( ls, 9 )
              If mprocent > 0
                ls := Round( ls * ( 100 + mprocent ) / 100, 2 )
                s += put_kope( ls, 9 )
                zrp1 += ls
                szrp += ls
              Endif
            Else
              s := Space( 20 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 3 ], 9 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 4 ], 10 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 5 ], 10 ) + ;
                put_dec_oper( arr_oper[ i, 2, j, 6 ], 10 )
            Endif
            add_string( s )
          Endif
        Next
        add_string( Space( sh -25 ) + Replicate( '-', 25 ) )
        s := PadL( '�⮣� : ' + lput_kop( sum1 ), 84 )
        If mprocent > 0
          s += put_kope( zrp1, 9 )
        Endif
        add_string( s )
      Next
      If k > 1
        add_string( Replicate( '�', sh ) )
        s := PadL( '�⮣� : ', 20 ) + put_dec_oper( s0, 9, .f. ) + ;
          put_dec_oper( s1, 10, .f. ) + ;
          put_dec_oper( s2, 10, .f. ) + ;
          put_dec_oper( s3, 10, .f. ) + ;
          put_val( s4, 8 ) + ;
          Space( 8 ) + ;
          put_kope( ssum, 9 )
        If mprocent > 0
          s += put_kope( szrp, 9 )
        Endif
        add_string( s )
      Endif
      add_string( Replicate( '�', sh ) )
      add_string( '  ������⢮ ��������� ����祪 : ' + lstr( skart ) )
      If skart2 > 0
        add_string( '  ������� �롮஢ �� ����⥪�: ' + lstr( skart2 ) )
      Endif
    Endif
  Endif
  If fl_new
    dbCreate( cur_dir + 'tmp', { ;
      { 'PO',      'N',   3,   0 }, ; // ��� ������
    { 'FO',      'C',  20,   0 }, ; // ��� ������
    { 'PT',      'N',   3,   0 }, ; // ��� �����
    { 'TP',      'N',   1,   0 }, ; // ⨯ (1-����窠, 2-�/�, 3-��㣨)
    { 'AE',      'N',   1,   0 }, ; // 1-����������, 2-।���஢����, 3-㤠�����
    { 'KK',      'N',   9,   0 }, ; // ���-�� (����祪, �/� ��� ���)
    { 'KP',      'N',   9,   0 };  // ������⢮ ������� �����
    } )
    Use ( cur_dir + 'tmp' ) new
    Index On Str( pt, 3 ) + Str( po, 3 ) + Str( ae, 1 ) + Str( tp, 1 ) to ( cur_dir + 'tmp' )
    r_use( dir_server + 'base1', , 'B1' )
    r_use( dir_server + 'mo_opern', dir_server + 'mo_opern', 'OP' )
    dbSeek( arr_g[ 7 ], .t. )
    Do While op->pd <= arr_g[ 8 ] .and. !Eof()
      _po := Asc( op->po )
      _pt := Asc( op->pt )
      _ae := Asc( op->ae )
      _tp := Asc( op->tp )
      llen := 6
      Select TMP
      find ( Str( _pt, 3 ) + Str( _po, 3 ) + Str( _ae, 1 ) + Str( _tp, 1 ) )
      If !Found()
        Append Blank
        tmp->pt := _pt
        tmp->po := _po
        tmp->ae := _ae
        tmp->tp := _tp
        b1->( dbGoto( _po ) )
        tmp->fo := Crypt( b1->p1, gpasskod )
      Endif
      tmp->kk += ft_Unsqzn( op->kk, llen )
      tmp->kp += ft_Unsqzn( op->kp, llen )
      Select OP
      Skip
    Enddo
    arr_task := { ;
      { '����������', X_REGIST }, ;
      { '���� �����', X_PPOKOJ }, ;
      { '���', X_OMS   }, ;
      { '����� ��㣨', X_PLATN }, ;
      { '��⮯���� �������', X_ORTO  }, ;
      { '��⮯���� ������', X_ORTO + 100 }, ;
      { '���� ��', X_KASSA };
      }
    AEval( arrNtitle, {| x| add_string( x ) } )
    Select TMP
    For i := 1 To Len( arr_task )
      find ( Str( arr_task[ i, 2 ], 3 ) )
      If Found()
        add_string( PadC( arr_task[ i, 1 ], sh, '_' ) )
        arr_oper := {}
        find ( Str( arr_task[ i, 2 ], 3 ) )
        Do While tmp->pt == arr_task[ i, 2 ] .and. !Eof()
          If AScan( arr_oper, {| x| x[ 2 ] == tmp->po } ) == 0
            AAdd( arr_oper, { tmp->fo, tmp->po } )
          Endif
          Skip
        Enddo
        ASort( arr_oper, , , {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )
        For j := 1 To Len( arr_oper )
          For k := 1 To 3
            s := PadR( iif( k == 1, arr_oper[ j, 1 ], '' ), 21 )
            s += PadR( { '���������', '��।���.', '㤠����' }[ k ], 9 )
            skp := 0
            For n := 1 To 3
              find ( Str( arr_task[ i, 2 ], 3 ) + Str( arr_oper[ j, 2 ], 3 ) + Str( k, 1 ) + Str( n, 1 ) )
              s += put_val( tmp->kk, 5 ) + put_val( tmp->kp, 7 ) + ' '
              skp += tmp->kp
            Next
            s += put_val( skp, 9 )
            add_string( s )
          Next
        Next
      Endif
    Next
  Endif
  FClose( fp )
  Close databases
  rest_box( buf24 )
  viewtext( devide_into_pages( name_file, 60, 80 ), , , , .t., , , 2 )

  Return Nil

//
Function fst_operator( get )

  Local mvar := ReadVar(), s := '�����⨬� �������� ��� ������� �����樥�� ��㤮������ '

  If mvar == 'KOEF1' .and. !Between( &mvar, 15, 99 )
    &mvar := get:original
    Return func_error( 4, s + '15 - 99.' )
  Endif
  If ( mvar == 'KOEF0' .or. mvar == 'KOEF2' ) .and. !Between( &mvar, 3, 50 )
    &mvar := get:original
    Return func_error( 4, s + '3 - 50.' )
  Endif
  If mvar == 'KOEF21' .and. !Between( &mvar, 2, KOEF2 -1 )
    &mvar := get:original
    Return func_error( 4, s + '2 - ' + lstr( KOEF2 -1 ) + '.' )
  Endif

  Return .t.


//
Function put_dec_oper( v, l, fl_plus )

  Local s := put_val_0( v, l, 2 )

  Default fl_plus To .t.

  Return PadL( if( Empty( s ) .or. ! fl_plus, '', ' + ' ) + AllTrim( s ), l )


// 29.05.24 ����� �������
Function prn_blank( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 1, si6 := 1, si7 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { '~���������', ;
      '����� ~������', ;
      '��ᯠ��ਧ��� ��⥩-~���', ;
      '��ᯠ��ਧ��� ~������', ;
      '����ᬮ��� ~��ᮢ��襭����⭨�', ;
      '���㡫����� ~��ᯠ��ਧ���', ;
      '����樭᪠� ~ॠ�������', ;
      '��ᯠ��ਧ��� ९த�⨢���� ���஢��' }
    mas_msg := { '��ᯥ�⪠ ������� � �ࠢ�筨��� ��� ���������᪨� ���⮢ ����', ;
      '��ᯥ�⪠ ������� ��� ᪮ன �����', ;
      '��ᯥ�⪠ ������� �� ��ᯠ��ਧ�樨 ��⥩-���', ;
      '��ᯥ�⪠ ������� �� ��ᯠ��ਧ�樨 � ��䨫��⨪� ���᫮�� ��ᥫ����', ;
      '��ᯥ�⪠ ������� �� ����樭᪨� �ᬮ�ࠬ ��ᮢ��襭����⭨�', ;
      '��ᯥ�⪠ ������� �� 㣫㡫����� ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ����', ;
      '��ᯥ�⪠ ������� �� ����樭᪮� ॠ�����樨', ;
      '��ᯥ�⪠ ������� �� ��ᯠ��ਧ�樨 ९த�⨢���� ���஢��' }
    mas_fun := { 'prn_blank(11)', ;
      'prn_blank(12)', ;
      'prn_blank(13)', ;
      'prn_blank(14)', ;
      'prn_blank(15)', ;
      'prn_blank(16)', ;
      'prn_blank(17)', ;
      'prn_blank(18)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    mas_pmt := { '~����஫�� ���� ���� ���', ;
      '~�ࠢ��� ���������� ����஫쭮�� ���� ���� ���' }
    mas_msg := { '��ᯥ�⪠ ����஫쭮�� ���� ���� ���.�����, ��������� ��樥�⠬, ��ࠤ��騬 ���', ;
      '��ᯥ�⪠ �ࠢ�� ���������� ����஫쭮�� ���� ���� ���' }
    mas_fun := { 'prn_blank(61)', ;
      'prn_blank(62)' }
    popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, mas_msg, mas_fun )
  Case k == 12
    mas_pmt := { '�ਫ������ � ~���� �맮�� ���', ;
      '~�ࠢ��� ���������� �ਫ������' }
    mas_msg := { '��ᯥ�⪠ �ਫ������ � ���� �맮�� ᪮ன �����', ;
      '��ᯥ�⪠ �ࠢ�� ���������� �ਫ������ � ���� �맮�� ᪮ன �����' }
    mas_fun := { 'prn_blank(21)', ;
      'prn_blank(22)' }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 13
    mas_pmt := { '��ᯠ��ਧ��� ��⥩-~���', ;
      '~����⪠ �� ���������� �/� �� ��ᯠ��ਧ�樨 ��⥩-���' }
    mas_msg := { '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ��⥩-���', ;
      '��ᯥ�⪠ ����⪨ �� ���������� �/� �� ��ᯠ��ਧ�樨 ��⥩-���' }
    mas_fun := { 'prn_blank(31)', ;
      'prn_blank(32)' }
    popup_prompt( T_ROW, T_COL -5, si3, mas_pmt, mas_msg, mas_fun )
  Case k == 14
    mas_pmt := { '~��ᯠ��ਧ��� I �⠯', ;
      '��ᯠ��ਧ��� II ~�⠯', ;
      '~��䨫����᪨� �ᬮ��' }
    // '��ᯠ��ਧ��� ࠧ � ~2 ����'}
    mas_msg := { '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ���� I �⠯', ;
      '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ���� II �⠯', ;
      '��ᯥ�⪠ ������ ���� ���� ��� ��䨫����ᮣ� �ᬮ�� ���᫮�� ��ᥫ����' }
    // '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ���� ࠧ � 2 ����'}
    mas_fun := { 'prn_blank(41)', ;
      'prn_blank(42)', ;
      'prn_blank(43)' }
    // 'prn_blank(44)'}
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    mas_pmt := { '���� ���� ~��䨫��⨪� ��ᮢ��襭����⭨�', ;
      '~������(�) ��� � �/� ��䨫��⨪� ��ᮢ��襭����⭨�' }
    // '���� ���� �।~���⥫쭮�� ����ᬮ��', ;
    // '���� ���� ��ਮ~���᪮�� ����ᬮ��'}
    mas_msg := { '��ᯥ�⪠ ������ ���� ���� ��� ��䨫��⨪� ��ᮢ��襭����⭨�', ;
      '��ᯥ�⪠ ������� � ��㣠�� � �/� ��� ��䨫��⨪� ��ᮢ��襭����⭨�' }
    // '��ᯥ�⪠ ������ ���� ���� ��� �।���⥫쭮�� ����ᬮ�� ��ᮢ��襭����⭨�', ;
    // '��ᯥ�⪠ ������ ���� ���� ��� ��ਮ���᪮�� ����ᬮ�� ��ᮢ��襭����⭨�'}
    mas_fun := { 'prn_blank(51)', ;
      'prn_blank(52)' }
    // 'prn_blank(53)', ;
    // 'prn_blank(54)'}
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
  Case k == 16
    mas_pmt := { '���㡫����� ~��ᯠ��ਧ��� I �⠯', ;
      '���㡫����� ��ᯠ��ਧ��� II ~�⠯' }
    mas_msg := { '��ᯥ�⪠ ������ ���� ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 I �⠯', ;
      '��ᯥ�⪠ ������ ���� ���� ��� 㣫㡫����� ��ᯠ��ਧ�樨 II �⠯' }
    mas_fun := { 'prn_blank(71)', ;
      'prn_blank(72)' }
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 17
    mas_pmt := { '���������� ~���', ;
      '���������� �࣠��� ~��堭��', ;
      '���������� ��᫥ COVID-~19', ;
      '���������� �࣠��� �-~� ������', ;
      '���������� 業�ࠫ쭮� ��ࢭ�� �~��⥬�', ;
      '���������� ������᪮� ��ࢭ�� �~��⥬�' }
    // '���������� ��᫥ COVID-19 ~��������樭�', ;
    mas_msg := { '��ᯥ�⪠ ������ ॠ�����樨 �थ筮-��㤨���� ���ﭨ�', ;
      '��ᯥ�⪠ ������ ॠ�����樨 �࣠��� ��堭��', ;
      '��ᯥ�⪠ ������ ॠ�����樨 �࣠��� ��堭��, ��᫥ COVID-19', ;
      '��ᯥ�⪠ ������ ॠ�����樨 � ����������ﬨ ���୮-�����⥫쭮�� ������', ;
      '��ᯥ�⪠ ������ ॠ�����樨 � ����������ﬨ 業�ࠫ쭮� ��ࢭ�� ��⥬�', ;
      '��ᯥ�⪠ ������ ॠ�����樨 � ����������ﬨ ������᪮� ��ࢭ�� ��⥬�' }
    // '��ᯥ�⪠ ������ ॠ�����樨 �࣠��� ��堭��, ��᫥ COVID-19 � �ᯮ�짮������ ⥫�����樭�', ;
    mas_fun := { 'prn_blank(81)', ;
      'prn_blank(82)', ;
      'prn_blank(83)', ;
      'prn_blank(85)', ;
      'prn_blank(87)', ;
      'prn_blank(86)' }
    // 'prn_blank(84)', ;
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 18
    mas_pmt := { '��ᯠ��ਧ��� ९த�⨢���� ���஢�� ���騭� I �⠯', ;
      '��ᯠ��ਧ��� ९த�⨢���� ���஢�� ��稭� I �⠯', ;
      '��ᯠ��ਧ��� ९த�⨢���� ���஢�� II �⠯' }
    mas_msg := { '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ��த�⨢���� ���஢�� ���騭 I �⠯', ;
      '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ��த�⨢���� ���஢�� ��稭 I �⠯', ;
      '��ᯥ�⪠ ������ ���� ���� ��� ��ᯠ��ਧ�樨 ��த�⨢���� ���஢�� II �⠯' }
    mas_fun := { 'prn_blank(88)', ;
      'prn_blank(89)', ;
      'prn_blank(90)' }
    popup_prompt( T_ROW, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
  Case k == 21
    call_fr( 'smp_2' )
  Case k == 22
    call_fr( 'smpp_2' )
  Case k == 31
    call_fr( 'mo_b_dds' )
  Case k == 32
    call_fr( 'mo_p_dds' )
  Case k == 41
    call_fr( 'mo_b1dvn' )
  Case k == 42
    call_fr( 'mo_b2dvn' )
  Case k == 43
    call_fr( 'mo_b3dvn' )
    // case k == 44
    // call_fr('mo_b4dvn')
  Case k == 51
    call_fr( 'mo_b_pn' )
  Case k == 52
    f_blank_usl_pn()
    // case k == 53
    // call_fr('mo_b_predn')
    // case k == 54
    // call_fr('mo_b_pern')
  Case k == 61 // ����஫�� ���� ���� ���
    call_fr( 'mo_onko_KL' )
  Case k == 62 // �ࠢ��� ���������� ����஫쭮�� ���� ���� ���
    // file_Wordpad(dir_exe() + cslash + 'RULE_KL.RTF')
    view_file_in_viewer( dir_exe() + cslash + 'RULE_KL.RTF' )
  Case k == 71
    call_fr( 'mo_y1dvn' )
  Case k == 72
    call_fr( 'mo_y2dvn' )
  Case k == 81
    call_fr( 'mo_reabC' )
  Case k == 82
    call_fr( 'mo_reabD' )
  Case k == 83
    call_fr( 'mo_reabV' )
  Case k == 84
    call_fr( 'mo_reabL' )
  Case k == 85
    call_fr( 'mo_reabT' )
  Case k == 86
    call_fr( 'mo_reabN' )
  Case k == 87
    call_fr( 'mo_reabM' )
  Case k == 88
    call_fr( 'mo_drz1jen' )
  Case k == 89
    call_fr( 'mo_drz1muj' )
  Case k == 90
    call_fr( 'mo_drz2' )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Elseif Between( k, 61, 69 )
      si6 := j
    Elseif Between( k, 71, 69 )
      si7 := j
    Endif
  Endif

  Return Nil


// 19.09.23
Function pr_sprav_onk_vmp()

  Local buf := save_maxrow(), name_file := cur_dir + 'metodVMPonko' + stxt, sh := 80, HH := 60, t_arr[ 2 ], i, s

  // Static mm_usl_tip := {'"����ࣨ�᪮� ��祭��"', ;
  // '"������⢥���� ��⨢����宫���� �࠯��"', ;
  // '"��祢�� �࠯��"', ;
  // '', ;
  // '"��ᯥ���᪮� ��祭��"', ;
  // '"�������⨪�"'}
  Local row, mm_usl_tip := {}
  For Each row in getn013()
    AAdd( mm_usl_tip, row[ 1 ] )
  Next

  mywait()
  fp := FCreate( name_file )
  n_list := 1
  tek_stroke := 0
  r_use( dir_exe() + '_mo_ovmp', cur_dir + '_mo_ovmp', 'OVMP' )
  add_string( '' )
  add_string( Center( '�����䨪��� ��⮤�� ��� �� ��������������� � 㪠������ ⨯�� ��祭��', sh ) )
  add_string( '' )
  For i := 1 To 1000
    find ( Str( i, 3 ) )
    If Found()
      verify_ff( HH, .t., sh )
      s := Str( i, 3 ) + '  ' + iif( Between( OVMP->USL1, 1, 6 ), mm_usl_tip[ OVMP->USL1 ], lstr( OVMP->USL1 ) )
      If ovmp->usl2 > 0
        s += iif( ovmp->tip == 0, ' ��� ', ' � ' ) + mm_usl_tip[ OVMP->USL2 ]
      Endif
      add_string( s )
    Endif
  Next
  rest_box( buf )
  FClose( fp )
  viewtext( name_file, , , , .t., , , 2 )
  Close databases

  Return Nil

// 09.09.23
Function pr_sprav_onko( n )

  Local ft, aTmp
  Local nSize, nFile
  Local name_file := cur_dir + 'n00' + lstr( n ) + '.txt', i, j, reg_print := 2
  Local nameFunc := 'getDS_N00' + lstr( n ) + '()'
  Local aStadii, fl, t_arr, k

  aStadii := &nameFunc
  r_use( dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG' )

  ft := tfiletext():new( name_file, , .t., , .t. )
  // ft:TableHeader := arr_title
  // ft:EnableTableHeader := .t.
  // ft:printTableHeader()
  ft:add_string( '' )
  ft:add_string( '�����䨪��� ' + { '', '�⠤��', 'Tumor', 'Nodus', 'Metastasis' }[ n ] + ' N00' + lstr( n ), FILE_CENTER, ' ' )
  ft:add_string( '' )

  For i := 1 To Len( aStadii )
    ft:add_string( Replicate( '�', ft:Width ) )
    If Empty( aStadii[ i, 1 ] )
      ft:add_string( '��稥 ��������' )
      ft:add_string( Replicate( '�', ft:Width ) )
    Else
      Select DIAG
      find ( aStadii[ i, 1 ] )
      Do While AllTrim( diag->shifr ) == AllTrim( aStadii[ i, 1 ] ) .and. !Eof()
        If diag->ks == 0
          ft:add_string( PadR( aStadii[ i, 1 ], 10 ) + Space( 6 ) + diag->name )
        Else
          ft:add_string( Space( 16 ) + diag->name )
        Endif
        Skip
      Enddo
      ft:add_string( Replicate( '�', ft:Width ) )
      ft:add_string( Space( 5 ) + PadL( { '', '�⠤��', 'Tumor', 'Nodus', 'Metastasis' }[ n ], 15 ) + Space( 10 ) + iif( n > 2, '������������', '' ) )
      ft:add_string( Replicate( '�', ft:Width ) )
    Endif
    For j := 1 To Len( aStadii[ i, 2 ] )
      aTmp := aStadii[ i, 2, j ]
      k := perenos( t_arr, iif( n > 2, aTmp[ 3 ], '' ), 55 )
      ft:add_string( Space( 5 ) + PadL( aTmp[ 1 ], 15 ) + iif( ISNIL( t_arr ), '', t_arr[ 1 ] ) )
      If ! ISNIL( t_arr )
        For j := 2 To k
          ft:add_string( Space( 20 ) + t_arr[ j ] )
        Next
      Endif
    Next
  Next

  nFile := ft:NameFile
  ft := nil
  DIAG->( dbCloseArea() )
  viewtext( name_file, , , , .t., , , reg_print )

  Return Nil

// // 16.08.18
// Function pr_sprav_N002(n)
// Local sh := 75, HH := 60, reg_print := 2, name_file := 'n00' + lstr(n) + '.txt', i, ad := {}, ;
// as_ := {'', 'st', 't', 'n', 'm'}, poled, polen, polek, lal, j, k, t_arr[2]
// lal := 'N' + lstr(n)
// poled := lal+ '->ds_' + as_[n]
// polek := lal+ '->kod_' + as_[n]
// polen := lal+ '->' + as_[n] + '_name'
// R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG')
// R_Use(dir_exe() + '_mo_N00' + lstr(n), , 'N' + lstr(n))
// do case
// case n == 2
// index on ds_st to tmp_n2 unique memory
// case n == 3
// index on ds_t to tmp_n3 unique memory
// case n == 4
// index on ds_n to tmp_n4 unique memory
// case n == 5
// index on ds_m to tmp_n5 unique memory
// endcase
// go top
// do while !eof()
// aadd(ad, padr(&poled, 6))
// skip
// enddo
// if empty(ad[1])
// aadd(ad,space(6))
// Del_Array(ad, 1)
// endif
// set index to (cur_dir + '_mo_N00' + lstr(n) + 'd')
// fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
// add_string('')
// add_string(center('�����䨪��� ' +{'', '�⠤��', 'Tumor', 'Nodus', 'Metastasis'}[n] + ' N00' + lstr(n), sh))
// add_string('')
// for i := 1 to len(ad)
// verify_FF(HH-2, .t., sh)
// add_string(replicate('-', sh))
// if empty(ad[i])
// add_string('��稥 ��������')
// else
// fl := .t.
// select DIAG
// find (ad[i])
// do while diag->shifr == ad[i] .and. !eof()
// add_string(iif(fl, ad[i], space(6)) +diag->name)
// fl := .f.
// skip
// enddo
// endif
// verify_FF(HH-3, .t., sh)
// add_string(replicate('-', sh))
// add_string(space(5) +padl({'', '�⠤��', 'Tumor', 'Nodus', 'Metastasis'}[n], 15) +space(10) +iif(n > 2, '������������', ''))
// add_string(replicate('-', sh))
// ad[i] := left(ad[i], 5)
// dbSelectArea(lal)
// find (ad[i])
// do while &poled == ad[i] .and. !eof()
// verify_FF(HH, .t., sh)
// k := perenos(t_arr,iif(n > 2, &polen, ''), 55)
// add_string(space(5) +padl(&polek, 15) +t_arr[1])
// for j := 2 to k
// verify_FF(HH, .t., sh)
// add_string(space(20) +t_arr[j])
// next
// skip
// enddo
// next
// fclose(fp)
// close databases
// viewtext(name_file, , , , .t., , ,reg_print)
// return NIL


// // 16.08.18
// FUNCTION pr_sprav_N006()
// Local sh := 75, HH := 60, reg_print := 2, name_file := cur_dir + 'n006.txt', i, ad := {}

// R_Use(dir_exe() + '_mo_mkb', cur_dir + '_mo_mkb', 'DIAG')
// R_Use(dir_exe() + '_mo_N002', , 'N2')
// index on str(id_st, 6) to tmp_n2 memory
// R_Use(dir_exe() + '_mo_N003', , 'N3')
// index on str(id_t, 6) to tmp_n3 memory
// R_Use(dir_exe() + '_mo_N004', , 'N4')
// index on str(id_n, 6) to tmp_n4 memory
// R_Use(dir_exe() + '_mo_N005', , 'N5')
// index on str(id_m, 6) to tmp_n5 memory
// R_Use(dir_exe() + '_mo_N006', , 'N6')
// index on ds_gr to tmp_n6 unique memory
// dbeval({|| aadd(ad, padr(n6->ds_gr, 6)) })
// fp := fcreate(name_file)
// tek_stroke := 0
// n_list := 1
// add_string('')
// add_string(center('��ࠢ�筨� ᮮ⢥��⢨� �⠤�� TNM', sh))
// add_string(center('( �ࠢ��쭮� ᮮ⢥��⢨� ���祭�� �����䨪��஢ TNM � �⠤�� )', sh))
// add_string('')
// for i := 1 to len(ad)
// verify_FF(HH - 2, .t., sh)
// add_string(replicate('-', sh))
// fl := .t.
// select DIAG
// find (ad[i])
// do while diag->shifr == ad[i] .and. !eof()
// add_string(iif(fl, ad[i], space(6)) + diag->name)
// fl := .f.
// skip
// enddo
// verify_FF(HH - 3, .t., sh)
// add_string(replicate('-', sh))
// add_string(space(5) + padl('Tumor', 15) + padl('Nodus', 15) + padl('Metastasis', 15) + padl('�⠤��', 15))
// add_string(replicate('-', sh))
// ad[i] := left(ad[i], 5)
// select N6
// set relation to str(id_st, 6) into N2, to str(id_t, 6) into N3, to str(id_n, 6) into N4, to str(id_m, 6) into N5
// index on id_gr to tmp_n6 for ds_gr == ad[i] memory
// go top
// do while !eof()
// verify_FF(HH, .t., sh)
// add_string(space(5) + padl(n3->kod_t, 15) + padl(n4->kod_n, 15) + padl(n5->kod_m, 15) + padl(n2->kod_st, 15))
// select N6
// skip
// enddo
// next
// fclose(fp)
// close databases
// viewtext(name_file, , , , .t., , , reg_print)
// return NIL


// 05.11.19
Function f_blank_usl_pn()

  Static arrv := { ;
    { '����஦�����', 1 }, ;
    { '1 �����', 2 }, ;
    { '2 �����', 3 }, ;
    { '3 �����', 4 }, ;
    { '4 �., 5 �., 6 �., 7 �., 8 �., 9 �., 10 �., 11 �., 1 ��� 3 �., 1 ��� 6 �.', 5 }, ;
    { '1 ���', 13 }, ;
    { '2 ����', 16 }, ;
    { '3 ����', 17 }, ;
    { '4 ����, 5 ���, 8 ���, 9 ���, 11 ���, 12 ���', 18 }, ;
    { '6 ���', 20 }, ;
    { '7 ���', 21 }, ;
    { '10 ���', 24 }, ;
    { '13 ���', 27 }, ;
    { '14 ���', 28 }, ;
    { '15 ���', 29 }, ;
    { '16 ���', 30 }, ;
    { '17 ���', 31 };
    }
  Local i, mperiod, ar, s, buf := SaveScreen(), ret_arr[ 2 ]

  delfrfiles()
  Do While ( mperiod := popup_2array( arrv, 3, 11, mperiod, 1, @ret_arr, ;
      '������ ��� � �/� ��䨫��⨪� ��ᮢ��襭����⭨�', 'B/W', color5 ) ) > 0
    dbCreate( fr_titl, { { 'name', 'C', 130, 0 } } )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->name := ret_arr[ 1 ]
    dbCreate( fr_data, { { 'name', 'C', 100, 0 } } )
    Use ( fr_data ) New Alias FRD
    np_oftal_2_85_21( mperiod, 0d20180901 )
    ar := np_arr_1_etap[ mperiod ]
    If !Empty( ar[ 5 ] ) // �� ���⮩ ���ᨢ ��᫥�������
      For i := 1 To count_pn_arr_iss
        If AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0
          s := np_arr_issled[ i, 3 ]
          // if ascan(glob_arr_usl_LIS,np_arr_issled[i, 1]) > 0
          // s += '    <b><i>� �� / � ���2</b></i>'
          // endif
          If ValType( np_arr_issled[ i, 2 ] ) == 'C'
            s += ' (' + iif( np_arr_issled[ i, 2 ] == '�', '����稪�', '����窨' ) + ')'
          Endif
          Append Blank
          frd->name := s
        Endif
      Next
    Endif
    dbCreate( fr_data + '1', { { 'name', 'C', 100, 0 } } )
    Use ( fr_data + '1' ) New Alias FRD1
    If !Empty( ar[ 4 ] ) // �� ���⮩ ���ᨢ �ᬮ�஢
      For i := 1 To count_pn_arr_osm
        If AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0
          s := np_arr_osmotr[ i, 3 ]
          If ValType( np_arr_osmotr[ i, 2 ] ) == 'C'
            s += ' (' + iif( np_arr_osmotr[ i, 2 ] == '�', '����稪�', '����窨' ) + ')'
          Endif
          Append Blank
          frd1->name := s
        Endif
      Next
    Endif
    Append Blank
    frd1->name := '������� (��� ��饩 �ࠪ⨪�)'
    dbCreate( fr_data + '2', { { 'name', 'C', 100, 0 } } )
    Use ( fr_data + '2' ) New Alias FRD2
    For i := 1 To count_pn_arr_osm
      If AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0
        s := np_arr_osmotr[ i, 3 ]
        If ValType( np_arr_osmotr[ i, 2 ] ) == 'C'
          s += ' (' + iif( np_arr_osmotr[ i, 2 ] == '�', '����稪�', '����窨' ) + ')'
        Endif
        Append Blank
        frd2->name := s
      Endif
    Next
    Append Blank
    frd2->name := '������� (��� ��饩 �ࠪ⨪�)'
    Close databases
    call_fr( 'mo_b_pn1' )
  Enddo
  RestScreen( buf )

  Return Nil


//
Function ne_real()

  Local c := cColorStMsg, c1 := cColorSt2Msg

  n_message( { '�ਭ�ᨬ ���������.', ;
    '� ����� ������ �㭪�� �� ॠ��������.' }, , c, c, , , c1 )

  Return Nil

// 24.01.19 ����� �-���
Function report_f_mpp()

  Local begin_date, end_date, buf := SaveScreen(), arr_m, i, j, k, k1, k2, is_rebenok, is_inogoro, ;
    lshifr1, koef, mvid, mour, fl_exit := .f., mkol, musl, d2_year, ar, arr_profil, ii, fl_K

  If ( arr_m := year_month(, , , 4 ) ) == NIL
    Return Nil
  Elseif arr_m[ 1 ] < 2018
    Return func_error( 4, '������ ������ � 2018 ����!' )
  Elseif !eq_any( arr_m[ 3 ], 3, 6, 9, 12 )
    Return func_error( 4, '��᫥���� ����� ������ ���� ����砭��� ����⠫�.' )
  Elseif arr_m[ 2 ] != 1
    Return func_error( 4, '���� ����� ������ ���� ������.' )
  Endif
  waitstatus( arr_m[ 4 ] )
  dbCreate( cur_dir + 'tmp1', { ;
    { 'usl_ok', 'N', 1, 0 }, ;
    { 'profil', 'N', 3, 0 }, ;  // ��䨫� � ��
  { 'is_our', 'N', 1, 0 }, ;  // 0-���, 1-�����த���
    { 'vz_reb', 'N', 1, 0 }, ;  // 0-�����, 1-ॡ񭮪
  { 'vid',    'N', 1, 0 }, ;  // 1-3
    { 'kol',    'N', 6, 0 }, ;  // ��砥�
  { 'usl',    'N', 6, 0 }, ;  // ���
    { 'summa',  'N', 14, 2 } } )  // ����祭��� �㬬�
  Use ( cur_dir + 'tmp1' ) new
  Index On Str( usl_ok, 1 ) + Str( profil, 3 ) + Str( is_our, 1 ) + Str( vid, 1 ) + Str( vz_reb, 1 ) to ( cur_dir + 'tmp1' )
  use_base( 'lusl' )
  r_use( dir_exe() + '_mo9unit', cur_dir + '_mo9unit', 'MOUNIT' )
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
  //
  mdate_rak := arr_m[ 6 ] + iif( arr_m[ 3 ] == 12, 22, 10 ) // �� ����� ���� ��� �㬬� � ����� 10.04.18
  If arr_m[ 3 ] == 12 .and. glob_mo[ _MO_KOD_TFOMS ] == '134505'
    mdate_rak := 23
  Endif
  //
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
      mdate1 := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '15' )
      //
      // 18 ���
      k := iif( arr_m[ 3 ] == 12, 21, 10 ) // ��� ॣ����樨 �� 10.04.18
      If arr_m[ 3 ] == 12 .and. glob_mo[ _MO_KOD_TFOMS ] == '134505'
        k := 23
      Endif
      //
      fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] + k ) ;
        .and. Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // !!���.��ਮ� 18 ���
    Endif
    If fl
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        If .t. // human_->USL_OK < 4 // �஬� ᪮ன �����
          // �� 㬮�砭�� ����祭, �᫨ ���� ��� ����
          koef := 1 ; k := 0
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          Do While human->kod == raksh->kod_h .and. !Eof()
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
          Endif
          If koef > 0
            is_rebenok := ( human->VZROS_REB > 0 )
            is_inogoro := ( Int( Val( schet_->smo ) ) == 34 )
            fl_K := ( schet_->BUKVA == 'K' ) // �⤥��� ����樭᪨� ��㣨 ���뢠�� ⮫쪮 �㬬��
            is_dializ := .f.
            is_z_sl := .f.
            d2_year := Year( human->k_data )
            munit := musl := 0
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
                lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
                If human_->USL_OK == 1 // ��樮���
                  If Left( lshifr, 5 ) == '1.11.'
                    musl += hu->kol_1
                  Endif
                  Select LUSL
                  find ( PadR( lshifr, 10 ) )
                  If Found() .and. !Empty( lusl->unit_code )
                    munit := lusl->unit_code
                    If !( eq_any( munit, 29, 141, 142 ) .or. Between( munit, 207, 258 ) )
                      munit := 0
                    Endif
                  Endif
                Elseif human_->USL_OK == 2 // ������� ��樮���
                  Select LUSL
                  find ( PadR( lshifr, 10 ) )
                  If Found() .and. !Empty( lusl->unit_code )
                    munit := lusl->unit_code
                    If !eq_any( munit, 143, 259 )
                      munit := 0
                    Endif
                  Endif
                Elseif human_->USL_OK == 3 // �����������
                  Select LUSL
                  find ( PadR( lshifr, 10 ) )
                  If Found() .and. !Empty( lusl->unit_code )
                    munit := lusl->unit_code
                    musl += hu->kol_1
                  Endif
                Endif
              Endif
              Select HU
              Skip
            Enddo
            mvid := mkol := 1
            If human_->USL_OK == 1 // ��樮���
              If munit == 141 // ������
                mkol := musl := 0
              Endif
            Elseif human_->USL_OK == 2 // ������� ��樮���
              //
            Elseif human_->USL_OK == 3 // �����������
              If eq_any( munit, 31, 146 )
                mvid := 2
              Elseif eq_any( munit, 32, 147, 205 )
                mvid := 3
                If munit == 205 // ����.������
                  mkol := musl := 1
                Endif
              Else
                If Between( munit, 260, 262 ) // ��ᯠ��ਧ���
                  musl := 1 // ����� ������⢠ ��� ���뢠�� ���� ����
                Elseif eq_any( munit, 30, 38, 145 )
                  // ��䨫��⨪� - ���뢠�� ��㣨
                Else
                  mkol := musl := 0 // �� ��⠫�� - ���뢠�� ⮫쪮 �⮨�����
                Endif
              Endif
            Elseif human_->USL_OK == 4 // ᪮�� ������
              mkol := musl := 1
            Endif
            mour := iif( is_inogoro, 1, 0 )
            If is_rebenok
              j := 1
            Else
              j := 0
            Endif
            Select TMP1
            find ( Str( human_->USL_OK, 1 ) + Str( human_->profil, 3 ) + Str( mour, 1 ) + Str( mvid, 1 ) + Str( j, 1 ) )
            If !Found()
              Append Blank
              tmp1->usl_ok := human_->USL_OK
              tmp1->profil := human_->profil
              tmp1->is_our := mour
              tmp1->vz_reb := j
              tmp1->vid    := mvid
            Endif
            tmp1->kol += mkol
            tmp1->usl += musl
            tmp1->summa += Round( human->cena_1 * koef, 2 )
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    Select SCHET
    Skip
  Enddo
  If fl_exit
    func_error( 4, '����� ��ࢠ�!' )
  Elseif tmp1->( LastRec() ) == 0
    func_error( 4, '��� ���ଠ樨!' )
  Else
    name_file := '_fmpp' + stxt
    HH := 55
    arr_title := { ;
      '�������������������������������������������������������������������������������������������������������������������������������������������', ;
      '                                        �   � ��䨫����᪮� 楫��     �    �� ���⫮���� ���.�����    �        �� �����������          ', ;
      '                                        ���������������������������������������������������������������������������������������������������', ;
      '         ������������ ��䨫��          �  �⮨����� �    � �.�.  ����- �  �⮨����� �    � �.�.  ����- �  �⮨����� �    � �.�.  ����- ', ;
      '                                        �            �  �� ����  � 饭���            �  �� ����  � 饭���            �  �� ����  � 饭��', ;
      '�������������������������������������������������������������������������������������������������������������������������������������������', ;
      '                    1                   �     9      �     10     �  11  �     12     �     13     �  14  �     15     �     16     �  17  ', ;
      '�������������������������������������������������������������������������������������������������������������������������������������������';
      }
    sh := Len( arr_title[ 1 ] )
    reg_print := 5
    fp := FCreate( name_file ) ; tek_stroke := 0 ; n_list := 1
    add_string( PadR( glob_mo[ _MO_SHORT_NAME ], sh -10 ) + '(� �㡫��)' )
    add_string( Center( '�������� � ����樭᪮� �����, ����뢠���� �� ����ਠ�쭮� �ணࠬ�� ��� (�-���)', sh ) )
    add_string( Center( '�� ���ﭨ� �� " 1 " ' + month_r( arr_m[ 6 ] + 1 ) + Str( Year( arr_m[ 6 ] + 1 ), 5 ) + ' �.', sh ) )
    add_string( '' )
    ii := 3
    Select TMP1
    find ( Str( ii, 1 ) )
    If Found()
      AEval( arr_title, {| x| add_string( x ) } )
      For mour := 0 To 1
        arr_profil := {}
        find ( Str( ii, 1 ) )
        Do While tmp1->usl_ok == ii .and. !Eof()
          If tmp1->is_our == mour .and. AScan( arr_profil, {| x| x[ 1 ] == tmp1->profil } ) == 0
            AAdd( arr_profil, { tmp1->profil, inieditspr( A__MENUVERT, getv002(), tmp1->profil ) } )
          Endif
          Skip
        Enddo
        If Len( arr_profil ) > 0
          If verify_ff( HH -2, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( Center( '����������� ' + iif( mour == 0, '(���)', '(�����த���)' ), sh ) )
          add_string( Replicate( '~', sh ) )
          ASort( arr_profil, , , {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
          For i := 1 To Len( arr_profil )
            s := PadR( arr_profil[ i, 2 ], 40 )
            For mvid := 1 To 3
              ss := { 0, 0, 0 }
              For j := 0 To 1
                find ( Str( ii, 1 ) + Str( arr_profil[ i, 1 ], 3 ) + Str( mour, 1 ) + Str( mvid, 1 ) + Str( j, 1 ) )
                If Found()
                  ss[ 1 ] += tmp1->summa
                  If j == 1
                    ss[ 2 ] += tmp1->summa
                  Endif
                  ss[ 3 ] += tmp1->usl
                Endif
              Next j
              s += put_kope( ss[ 1 ], 13 ) + put_kope( ss[ 2 ], 13 ) + put_val( ss[ 3 ], 7 )
            Next mvid
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( s )
            add_string( Replicate( '�', sh ) )
          Next i
        Endif
      Next
    Endif
    arr_title := { ;
      '����������������������������������������������������������������������������������������������������������������', ;
      '                                                            �         �ᥥ��          �       � �.�. ���       ', ;
      '                                                            ����������������������������������������������������', ;
      '                   ������������ ��䨫��                    �   ��砨   �   �㬬�    �   ��砨   �   �㬬�    ', ;
      '                                                            �  ��祭��   �            �  ��祭��   �            ', ;
      '����������������������������������������������������������������������������������������������������������������', ;
      '                              1                             �     5      �     6      �     7      �      8     ', ;
      '����������������������������������������������������������������������������������������������������������������';
      }
    sh := Len( arr_title[ 1 ] )
    ii := 2
    Select TMP1
    find ( Str( ii, 1 ) )
    If Found()
      verify_ff( HH -10, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
      For mour := 0 To 1
        arr_profil := {}
        find ( Str( ii, 1 ) )
        Do While tmp1->usl_ok == ii .and. !Eof()
          If tmp1->is_our == mour .and. AScan( arr_profil, {| x| x[ 1 ] == tmp1->profil } ) == 0
            AAdd( arr_profil, { tmp1->profil, inieditspr( A__MENUVERT, getv002(), tmp1->profil ) } )
          Endif
          Skip
        Enddo
        If Len( arr_profil ) > 0
          If verify_ff( HH -2, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( Center( '������� ��樮��� ' + iif( mour == 0, '(���)', '(�����த���)' ), sh ) )
          add_string( Replicate( '~', sh ) )
          ASort( arr_profil, , , {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
          For i := 1 To Len( arr_profil )
            s := PadR( arr_profil[ i, 2 ], 60 )
            For mvid := 1 To 1
              ss := { 0, 0, 0, 0 }
              For j := 0 To 1
                find ( Str( ii, 1 ) + Str( arr_profil[ i, 1 ], 3 ) + Str( mour, 1 ) + Str( mvid, 1 ) + Str( j, 1 ) )
                If Found()
                  ss[ 1 ] += tmp1->kol
                  ss[ 2 ] += tmp1->summa
                  If j == 1
                    ss[ 3 ] += tmp1->kol
                    ss[ 4 ] += tmp1->summa
                  Endif
                Endif
              Next j
              s += put_val( ss[ 1 ], 10 ) + put_kope( ss[ 2 ], 16 ) + ;
                put_val( ss[ 3 ], 10 ) + put_kope( ss[ 4 ], 16 )
            Next mvid
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( s )
            add_string( Replicate( '�', sh ) )
          Next i
        Endif
      Next
    Endif
    arr_title := { ;
      '������������������������������������������������������������������������������������������������������������������', ;
      '                                                            �           �ᥣ�          �      � �.�. ���         ', ;
      '                                                            ������������������������������������������������������', ;
      '                   ������������ ��䨫��                    ���砨������-�   �㬬�    ���砨������-�   �㬬�    ', ;
      '                                                            �      � ���  �            �      � ���  �            ', ;
      '������������������������������������������������������������������������������������������������������������������', ;
      '                              1                             �  5   �  6   �     7      �  8   �  9   �     10     ', ;
      '������������������������������������������������������������������������������������������������������������������';
      }
    sh := Len( arr_title[ 1 ] )
    ii := 1
    Select TMP1
    find ( Str( ii, 1 ) )
    If Found()
      verify_ff( HH -10, .t., sh )
      AEval( arr_title, {| x| add_string( x ) } )
      For mour := 0 To 1
        arr_profil := {}
        find ( Str( ii, 1 ) )
        Do While tmp1->usl_ok == ii .and. !Eof()
          If tmp1->is_our == mour .and. AScan( arr_profil, {| x| x[ 1 ] == tmp1->profil } ) == 0
            AAdd( arr_profil, { tmp1->profil, inieditspr( A__MENUVERT, getv002(), tmp1->profil ) } )
          Endif
          Skip
        Enddo
        If Len( arr_profil ) > 0
          If verify_ff( HH -2, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          add_string( Center( '��樮��� ' + iif( mour == 0, '(���)', '(�����த���)' ), sh ) )
          add_string( Replicate( '~', sh ) )
          ASort( arr_profil, , , {| x, y| Upper( x[ 2 ] ) < Upper( y[ 2 ] ) } )
          For i := 1 To Len( arr_profil )
            s := PadR( arr_profil[ i, 2 ], 60 )
            For mvid := 1 To 1
              ss := { 0, 0, 0, 0, 0, 0 }
              For j := 0 To 1
                find ( Str( ii, 1 ) + Str( arr_profil[ i, 1 ], 3 ) + Str( mour, 1 ) + Str( mvid, 1 ) + Str( j, 1 ) )
                If Found()
                  ss[ 1 ] += tmp1->kol
                  ss[ 2 ] += tmp1->usl
                  ss[ 3 ] += tmp1->summa
                  If j == 1
                    ss[ 4 ] += tmp1->kol
                    ss[ 5 ] += tmp1->usl
                    ss[ 6 ] += tmp1->summa
                  Endif
                Endif
              Next j
              s += put_val( ss[ 1 ], 7 ) + put_val( ss[ 2 ], 7 ) + put_kope( ss[ 3 ], 13 ) + ;
                put_val( ss[ 4 ], 7 ) + put_val( ss[ 5 ], 7 ) + put_kope( ss[ 6 ], 13 )
            Next mvid
            If verify_ff( HH, .t., sh )
              AEval( arr_title, {| x| add_string( x ) } )
            Endif
            add_string( s )
            add_string( Replicate( '�', sh ) )
          Next i
        Endif
      Next
    Endif
    ii := 4
    Select TMP1
    find ( Str( ii, 1 ) )
    If Found()
      verify_ff( HH, .t., sh )
      ss := Array( 2, 2 )
      afillall( ss, 0 )
      For mour := 0 To 1
        arr_profil := {}
        find ( Str( ii, 1 ) )
        Do While tmp1->usl_ok == ii .and. !Eof()
          If tmp1->is_our == mour
            ss[ mour + 1, 1 ] += tmp1->kol
            ss[ mour + 1, 2 ] += tmp1->summa
          Endif
          Skip
        Enddo
      Next
      add_string( '᪮�� ������ (���)       ' + put_val( ss[ 1, 1 ], 6 ) + ' 祫.' + put_kope( ss[ 1, 2 ], 12 ) + ' ��.' )
      add_string( '᪮�� ������ (�����த���)' + put_val( ss[ 2, 1 ], 6 ) + ' 祫.' + put_kope( ss[ 2, 2 ], 12 ) + ' ��.' )
    Endif
    FClose( fp )
    Close databases
    RestScreen( buf )
    Private yes_albom := .t.
    viewtext( name_file, , , , .t., , , reg_print )
  Endif
  Close databases
  RestScreen( buf )

  Return Nil

// 02.01.23
Function pril_5_6_62()

  Local begin_date, end_date, buf := SaveScreen(), i, j, k, k1, k2, ;
    t_arr[ 10 ], t_arr1[ 10 ], name_file := 'f14med' + stxt, tfoms_pz[ 5, 11 ], ;
    sh, HH := 80, reg_print := 5, is_trudosp, is_rebenok, is_inogoro, ;
    is_reabili, is_ekstra, lshifr1, koef, vid_vp, r1 := 9, fl_exit := .f., ;
    is_vmp, d2_year, ar, arr_excel := {}, fl_error := .f., is_z_sl, ;
    arr_usl, au, ii, lal, lalf
  Local sbase

  If !hb_FileExists( dir_exe() + '_mo_pr62' + sdbf )
    Return func_error( 4, '�� �����㦥� 䠩� _mo_pr62' + sdbf )
  Endif
  Private arr_m := { 2022, 1, 12, '�� ﭢ��� - ������� 2022 ����', 0d20220101, 0d20221231 }, ;
    mm_uslov := { { '�� ��⠬ ���.��ਮ�� (��� ���� ���)', 0 }, ;
    { '� ���⮬ ��� (��� � �ଥ 14-���/���)', 1 } }
  Private mdate := arr_m[ 4 ], m1date := arr_m[ 1 ], muslov := mm_uslov[ 2, 1 ], m1uslov := mm_uslov[ 2, 2 ], ;
    mdializ := mm_danet[ 1, 1 ], m1dializ := mm_danet[ 1, 2 ]
  r1 := 17
  box_shadow( r1, 2, 22, 77, color1, ' ����� �� ��� ', color8 )
  tmp_solor := SetColor( cDataCGet )
  @ r1 + 2, 4 Say '��ਮ� �६���' Get mdate ;
    reader {| x| menu_reader( x, ;
    { {| k, r, c| k := year_month( r + 1, c, , { 3, 4 } ), ;
    iif( k == nil, nil, ( arr_m := AClone( k ), k := { k[ 1 ], k[ 4 ] } ) ), ;
    k } }, A__FUNCTION, , , .f. ) }
  @ r1 + 3, 4 Say '�᫮��� �⡮�' Get muslov ;
    reader {| x| menu_reader( x, mm_uslov, A__MENUVERT, , , .f. ) }
  // @ r1+ 4, 4 say '���뢠�� �⮨����� ��楤�� ������� (����� � ���)?' get mdializ ;
  // reader {|x|menu_reader(x,mm_danet,A__MENUVERT, , ,.f.)}
  status_key( '^<Esc>^ - ��室;  ^<PgDn>^ - ᮧ����� �����' )
  myread()
  RestScreen( buf )
  If LastKey() == K_ESC
    Return Nil
  Elseif !Between( arr_m[ 1 ], 2019, WORK_YEAR )
    Return func_error( 4, '����� ����� ࠡ�⠥� ⮫쪮 � 2019 �� ' + Str( WORK_YEAR, 4 ) + ' ������' )
  Endif
  lal := 'lusl'
  lalf := 'luslf'
  lal := create_name_alias( lal, arr_m[ 1 ] )
  lalf := create_name_alias( lalf, arr_m[ 1 ] )

  waitstatus( arr_m[ 4 ] )
  @ MaxRow(), 0 Say ' ����...' Color 'W/R'
  begin_date := dtoc4( arr_m[ 5 ] )
  end_date := dtoc4( arr_m[ 6 ] )
  use_base( 'lusl' )
  use_base( 'luslf' )

  sbase := prefixfilerefname( arr_m[ 1 ] ) + 'unit'
  r_use( dir_exe() + sbase, cur_dir + sbase, 'MOUNIT' )

  r_use( dir_server + 'mo_su', , 'MOSU' )
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
  kds := kdr := 10
  If arr_m[ 1 ] == 2019 .and. arr_m[ 3 ] == 12
    kds := 17 // ��� ॣ����樨 �� 17.01.20
    kdr := 21 // �� ����� ���� ��� �㬬� � ����� 21.01.20
  Endif
  If arr_m[ 1 ] == 2020 .and. arr_m[ 3 ] == 12
    kds := 15 // ��� ॣ����樨 �� 15.01.21
    kdr := 18 // �� ����� ���� ��� �㬬� � ����� 18.01.21
  Endif
  If arr_m[ 1 ] == 2021 .and. arr_m[ 3 ] == 12
    kds := 14 // ��� ॣ����樨 �� 14.01.22
    kdr := 17 // �� ����� ���� ��� �㬬� � ����� 17.01.22
  Endif
  If arr_m[ 1 ] == 2022 .and. arr_m[ 3 ] == 6
    kds := 7 // ��� ॣ����樨 �� 7.07.22
    kdr := 13 // �� ����� ���� ��� �㬬� � ����� 2
  Endif
  If arr_m[ 1 ] == 2022 .and. arr_m[ 3 ] == 12
    kds := 14 // ��� ॣ����樨 �� 7.07.23
    kdr := 20 // �� ����� ���� ��� �㬬� � ����� 2
  Endif
  If arr_m[ 1 ] == 2023 .and. arr_m[ 3 ] == 1 //
    kds := 14 // ��� ॣ����樨 �� 7.07.23
    kdr := 20 // �� ����� ���� ��� �㬬� � ����� 2
  Endif
  If arr_m[ 1 ] == 2024 .and. arr_m[ 3 ] == 1 // �஢����
    kds := 14 // ��� ॣ����樨 �� 7.07.24
    kdr := 20 // �� ����� ���� ��� �㬬� � ����� 2
  Endif
  //
  mdate_rak := arr_m[ 6 ] + kdr
  //
  r_use( dir_server + 'mo_xml', , 'MO_XML' )
  r_use( dir_server + 'mo_rak', , 'RAK' )
  Set Relation To kod_xml into MO_XML
  r_use( dir_server + 'mo_raks', , 'RAKS' )
  Set Relation To akt into RAK
  r_use( dir_server + 'mo_raksh', , 'RAKSH' )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir + 'tmp_raksh' ) For mo_xml->DFILE <= mdate_rak
  //
  dbCreate( cur_dir + 'tmp', { { 'usl_ok', 'N', 1, 0 }, ;
    { 'stroke', 'C', 3, 0 }, ;
    { 'shifr', 'C', 10, 0 }, ;
    { 'kols', 'N', 6, 0 }, ;
    { 'kold', 'N', 10, 0 }, ;
    { 'summa', 'N', 15, 2 }, ;
    { 'sr_kol', 'N', 5, 1 } } )
  Use ( cur_dir + 'tmp' ) New Alias TMP
  Index On Str( usl_ok, 1 ) + shifr to ( cur_dir + 'tmp' )
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
      mdate1 := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '15' )
      //
      fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] + kds ) .and. Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // !!���.��ਮ�
    Endif
    If fl
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        // �� 㬮�砭�� ����祭, �᫨ ���� ��� ����
        koef := 1 ; k := j := 0
        If m1uslov == 0
          If human_->oplata == 9
            koef := 0
          Endif
        Else // ��� � 14-���
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
          Endif
        Endif
        If koef > 0 .and. human_->USL_OK < 3
          kodKSG := ''
          s_dializ := mkol := s_dializ_KB4 := 0
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              lshifr := AllTrim( lshifr )
              If is_ksg( lshifr )
                kodKSG := lshifr
              Elseif Left( lshifr, 5 ) == '60.3.'
                s_dializ += Round( hu->stoim_1 * koef, 2 )
              Elseif Left( lshifr, 6 ) == '60.10.'  // ������ � �� 4
                s_dializ_KB4 += Round( hu->stoim_1 * koef, 2 )
              Endif
              If human_->USL_OK == 1
                mkol := human->k_data - human->n_data  // �����-����
              Elseif Left( lshifr, 5 ) == '55.1.'
                mkol += hu->kol_1
              Endif
            Endif
            Select HU
            Skip
          Enddo
          If m1dializ == 1 // �᫨ ���뢠�� �⮨����� �������
            s_dializ := 0  // � �� ���⠥� ���
          Endif
          ssum := Round( human->cena_1 * koef, 2 )
          If !Empty( kodKSG )
            Select TMP
            find ( Str( human_->USL_OK, 1 ) + PadR( kodKSG, 8 ) ) // ���� 10
            If !Found()
              Append Blank
              tmp->usl_ok := human_->USL_OK
              tmp->shifr  := PadR( kodKSG, 8 )
              tmp->stroke := '999'
            Endif
            tmp->kols++
            tmp->kold += mkol
            tmp->summa += ssum - s_dializ - s_dializ_KB4
          Endif
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    If fl_exit ; exit ; Endif
    Select SCHET
    Skip
  Enddo
  ar := { { 0, 0, 0 }, { 0, 0, 0 } }
  Select TMP
  Go Top
  Do While !Eof()
    i := tmp->usl_ok
    ar[ i, 1 ] += tmp->kols
    ar[ i, 2 ] += tmp->kold
    ar[ i, 3 ] += tmp->summa
    tmp->sr_kol := tmp->kold / tmp->kols
    Skip
  Enddo
  r_use( dir_exe() + '_mo_pr62', , 'PR' )
  Go Top
  Do While !Eof()
    Select TMP
    find ( Str( pr->USL_OK, 1 ) + PadR( pr->shifr, 10 ) )
    If !Found()
      Append Blank
      tmp->usl_ok := pr->USL_OK
      tmp->shifr  := pr->shifr
      If Empty( pr->shifr )
        i := tmp->usl_ok
        tmp->kols := ar[ i, 1 ]
        tmp->kold := ar[ i, 2 ]
        tmp->summa := ar[ i, 3 ]
        tmp->sr_kol := tmp->kold / tmp->kols
      Endif
    Endif
    tmp->stroke := pr->stroke
    Select PR
    Skip
  Enddo
  Select PR
  Go Top
  Do While !Eof()
    If !Empty( pr->shifr ) .and. !( '.' $ pr->shifr )
      afillall( ar, 0 )
      i := tmp->usl_ok
      Select TMP
      find ( Str( pr->USL_OK, 1 ) + PadR( pr->shifr, 4 ) )
      Do While pr->usl_ok == tmp->usl_ok .and. PadR( pr->shifr, 4 ) == Left( tmp->shifr, 4 )
        ar[ i, 1 ] += tmp->kols
        ar[ i, 2 ] += tmp->kold
        ar[ i, 3 ] += tmp->summa
        Skip
      Enddo
      find ( Str( pr->USL_OK, 1 ) + PadR( pr->shifr, 4 ) )
      tmp->kols := ar[ i, 1 ]
      tmp->kold := ar[ i, 2 ]
      tmp->summa := ar[ i, 3 ]
      tmp->sr_kol := tmp->kold / tmp->kols
    Endif
    Select PR
    Skip
  Enddo
  Select TMP
  Index On Str( usl_ok, 1 ) + stroke to ( cur_dir + 'tmp' )
  For i := 1 To 2
    ar := {}
    bk := { 4, 5 }[ i ] ; j := 0
    Select TMP
    find ( Str( i, 1 ) )
    Do While tmp->usl_ok == i .and. !Eof()
      ++j
      AAdd( ar, { bk + j, 4, tmp->kols } )
      AAdd( ar, { bk + j, 5, tmp->summa } )
      AAdd( ar, { bk + j, 6, tmp->sr_kol } )
      Skip
    Enddo
    If i == 1
      ar_pr5 := { { '���� ��� (��)', AClone( ar ) } }
    Else
      ar_pr6 := { { '���� ��� (��)', AClone( ar ) } }
    Endif
  Next
  // �᫨ ���� ��� ���� - ᮧ���� ⥪��
  fl_999 := .f.
  Select tmp
  Go Top
  Do While !Eof()
    If tmp->stroke == '999'
      fl_999 := .t.
    Endif
    Skip
  Enddo
  If fl_999
    HH := 80
    arr_title := { ;
      '�������������������������������������������������������������������', ;
      '      ���     � ���砥� �     ��ꥬ    �  �।��� ���⥫쭮���     ', ;
      '              � ��祭�� �䨭���஢����  �ॡ뢠��� � ��樮���  ', ;
      '�������������������������������������������������������������������' }
    sh := Len( arr_title[ 1 ] )
    //
    fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( '' )
    add_string( Center( '���᮪ ���, ����������� � �ਫ������� 5 � 6 ��� 62', sh ) )
    add_string( '' )
    AEval( arr_title, {| x| add_string( x ) } )
    Select tmp
    Go Top
    Do While !Eof()
      If tmp->stroke == '999'
        add_string( PadR( tmp->shifr, 14 ) + PadL( lstr( tmp->kols ), 10 ) + put_kop( tmp->summa, 15 ) + ' ' + put_kop( tmp->sr_kol, 15 ) )
      Endif
      Skip
    Enddo
    FClose( fp )
  Endif
  //
  Close databases
  RestScreen( buf )
  //
  If fl_999
    viewtext( name_file, , , , .t., , , 5 )
  Endif
  fill_in_excel_book( dir_exe() + 'mo_pr5_62' + sxls, ;
    cur_dir + '__pr5_62' + sxls, ;
    ar_pr5, ;
    '��᫠��� �� �����' )
  fill_in_excel_book( dir_exe() + 'mo_pr6_62' + sxls, ;
    cur_dir + '__pr6_62' + sxls, ;
    ar_pr6, ;
    '��᫠��� �� �����' )

  Return Nil

// 07.07.20 �����ਭ� ���ﭨ� ���஢�� ��ᥫ���� � ��� �����������, ���ﭨ�, 䠪�஢ �᪠,
// �易���� � ��ᮡ����� ���஢��� ��ࠧ� �����
Function monitoring_zog()

  Static sad := { 'R73.9', 'E10', 'E11', 'E12', 'E13', 'E14', 'R63.5', 'E66', 'K25', 'K26', 'K29', 'E78', ;
    'K70', 'K71', 'K72', 'K73', 'K74', 'K85', 'K86' }
  Static mas1pmt := { '~�� �������� ��砨', ;
    '��砨 � ���⠢������ ~����', ;
    '��砨 � ��~ॣ����஢����� ����' }
  Local sh := 80, HH := 80, n_file := 'monitoring_zog' + stxt
  Local fl, par, arr_m, i, j, n, ad, arr, adiag_talon[ 16 ], lcount_uch := 1, buf := save_maxrow()
  Private mdate_r, M1VZROS_REB, is_disp_19, m1tip_mas := 0, m1glukozadn := 0, mglukoza := 0

  If !del_dbf_file( 'tmp' + sdbf )
    Return .f.
  Endif
  If ( par := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0 .and. ;
      ( st_a_uch := inputn_uch( T_ROW, T_COL -5, , , @lcount_uch ) ) != Nil .and. ( arr_m := year_month(, , , 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir + 'tmp', { { 'kod_k', 'N', 7, 0 }, ;
      { 'pens', 'L', 1, 0 }, ;
      { 'diag', 'C', 5, 0 }, ;
      { 'is_1', 'L', 1, 0 }, ;
      { 'disp', 'L', 1, 0 } } )
    Use ( cur_dir + 'tmp' ) new
    Index On Str( kod_k, 7 ) + diag to ( cur_dir + 'tmp' )
    r_use( dir_server + 'schet_', , 'SCHET_' )
    r_use( dir_server + 'human_', , 'HUMAN_' )
    r_use( dir_server + 'human', dir_server + 'humand', 'HUMAN' )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      @ MaxRow(), 1 Say full_date( human->k_data ) Color cColorWait
      fl := human_->usl_ok == 3 .and. human->cena_1 > 0 .and. human_->oplata != 9 .and. f_is_uch( st_a_uch, human->lpu )
      If fl
        mdate_r := human->date_r ; M1VZROS_REB := human->VZROS_REB
        fv_date_r( human->n_data ) // ��८�।������ M1VZROS_REB
        fl := ( M1VZROS_REB == 0 )
      Endif
      If fl .and. par > 1
        fl := ( human->schet > 0 )
        If fl .and. par == 3
          fl := .f.
          Select SCHET_
          Goto ( human->schet )
          If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
            fl := .t.
          Endif
        Endif
      Endif
      If fl
        For i := 1 To 16
          adiag_talon[ i ] := Int( Val( SubStr( human_->DISPANS, i, 1 ) ) )
        Next
        arr := diag_to_array(, .f., .f., .f., .f., adiag_talon )
        ad := {}
        For i := 1 To Len( sad )
          n := Len( sad[ i ] )
          For j := 1 To Len( arr )
            If Left( arr[ j ], n ) == sad[ i ]
              AAdd( ad, arr[ j ] )
            Endif
          Next
        Next
        If ( is_disp := Between( human->ishod, 201, 204 ) )
          is_disp_19 := !( human->k_data < 0d20190501 )
          read_arr_dvn( human->kod )
          If m1glukozadn == 1 .or. mglukoza > 6.1
            AAdd( ad, 'R73.9' )
          Endif
          If AScan( ad, {| x| Left( x, 3 ) == 'E66' } ) == 0 .and. m1tip_mas >= 3
            AScan( ad, 'R63.5' )
          Endif
        Endif
        If Len( ad ) > 0
          is_pens := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
          For i := 1 To Len( ad )
            Select TMP
            find ( Str( human->kod_k, 7 ) + PadR( ad[ i ], 5 ) )
            If !Found()
              Append Blank
              tmp->kod_k := human->kod_k
              tmp->pens := is_pens
              tmp->diag := PadR( ad[ i ], 5 )
              tmp->is_1 := ( ' + ' $ ad[ i ] )
              If tmp->is_1
                tmp->disp := is_disp
              Endif
              If LastRec() % 1000 == 0
                Commit
              Endif
            Endif
          Next
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    rest_box( buf )
    fl := .t.
    If tmp->( LastRec() ) == 0
      fl := func_error( 4, '�� ������� ���ଠ樨 �� ������� ������ ' + arr_m[ 4 ] )
    Endif
    Close databases
    If fl
      mywait()
      arr := { ;
        { '1.����࣫������ ����筥����', 'R73.9', 0, 0, 0, 0, 0, 0 }, ;
        { '2.����� ������', 'E10-E14', 0, 0, 0, 0, 0, 0, { 'E10', 'E11', 'E12', 'E13', 'E14' } }, ;
        { '3.���ଠ�쭠� �ਡ���� ����� ⥫�', 'R63.5', 0, 0, 0, 0, 0, 0 }, ;
        { '3.5.���७��', 'E66', 0, 0, 0, 0, 0, 0 }, ;
        { '4.���� ���㤪�', 'K25', 0, 0, 0, 0, 0, 0 }, ;
        { '5.���� �������⨯���⭮� ��誨', 'K26', 0, 0, 0, 0, 0, 0 }, ;
        { '6.������ � �㮤����', 'K29', 0, 0, 0, 0, 0, 0 }, ;
        { '7.����襭�� ������ ������⥨��� � ��㣨� ���������', 'E78', 0, 0, 0, 0, 0, 0 }, ;
        { '8.������� ��祭�', 'K70-K74', 0, 0, 0, 0, 0, 0, { 'K70', 'K71', 'K72', 'K73', 'K74' } }, ;
        { '9.����� ����ॠ��, ��㣨� ������� ������㤮筮� ������', 'K85-K86', 0, 0, 0, 0, 0, 0, { 'K85', 'K86' } } }
      Use TMP
      Go Top
      Do While !Eof()
        n := 0
        For i := 1 To Len( arr )
          If '-' $ arr[ i, 2 ]
            For j := 1 To Len( arr[ i, 9 ] )
              If f1monitoring_zog( arr[ i, 9, j ] )
                n := i ; Exit
              Endif
            Next
          Else
            If f1monitoring_zog( arr[ i, 2 ] )
              n := i
            Endif
          Endif
          If n > 0
            arr[ i, 3 ] ++
            If tmp->is_1
              arr[ i, 4 ] ++
            Endif
            If tmp->disp
              arr[ i, 5 ] ++
            Endif
            If tmp->pens
              arr[ i, 6 ] ++
              If tmp->is_1
                arr[ i, 7 ] ++
              Endif
              If tmp->disp
                arr[ i, 8 ] ++
              Endif
            Endif
            Exit
          Endif
        Next
        Skip
      Enddo
      Use
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( '' )
      add_string( Center( '�����ਭ� ���ﭨ� ���஢�� ��ᥫ���� � ��� �����������, ���ﭨ�, ', sh ) )
      add_string( Center( '䠪�஢ �᪠, �易���� � ��ᮡ����� ���஢��� ��ࠧ� �����', sh ) )
      add_string( Center( '[ ' + CharRem( '~', mas1pmt[ par ] ) + ' ]', sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( full_date( sys_date ) )
      add_string( '��������������������������������������������������������������������������������' )
      add_string( '������������ ����������� (䠪�஢ �᪠)          � ���-10������.�����볤�ᯠ�' )
      add_string( '��������������������������������������������������������������������������������' )
      For i := 1 To Len( arr )
        add_string( PadR( arr[ i, 1 ], 51 ) + ' ' + PadC( arr[ i, 2 ], 7 ) )
        add_string( PadL( '�����         ', 52 ) + put_val( arr[ i, 3 ], 13 ) + put_val( arr[ i, 4 ], 7 ) + put_val( arr[ i, 5 ], 7 ) )
        add_string( PadL( '� �.�.���ᨮ���� ', 52 ) + put_val( arr[ i, 6 ], 13 ) + put_val( arr[ i, 7 ], 7 ) + put_val( arr[ i, 8 ], 7 ) )
      Next
      FClose( fp )
      rest_box( buf )
      Close databases
      viewtext( n_file, , , , .t., , , 2 )
    Endif
  Endif

  Return Nil

// 07.07.20
Function f1monitoring_zog( ldiag )

  Local fl := .f.

  If Len( ldiag ) == 3
    fl := ( Left( tmp->diag, 3 ) == ldiag )
  Else
    fl := ( tmp->diag == ldiag )
  Endif

  Return fl
