// ॥����/��� � 2019 ����
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// Static sadiag1

// 21.10.25 ᮧ����� XML-䠩��� ॥���
Function create2reestr19( _recno, _nyear, _nmonth, reg_sort, p_tip_reestr )

  Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, code_reestr, mb, me, nsh
  Local i, sk
  Local reserveKSG_ID_C := '' // GUID ��� ��������� ������� ��砥�
  Local arrLP
  Local controlVer
  Local diagnoz_replace := ''
  Local lReplaceDiagnose := .f.
  Local lTypeLUOnkoDisp := .f.  // 䫠� ���� ��� ���⠭���� �� ��ᯠ��୮� ������� ����������
  local dPUMPver40 := 0d20240301
  local aFilesName
  local sVersion, fl_ver
  local oXmlDoc, oXmlNode
  local oXmlDocPacient, oXmlNodePacient
  local sVersionPacient  
  local pole_diag, pole_1dispans, pole_dn_dispans
  local laluslf
  //
  dbCloseAll()

  // If ISNIL( sadiag1 )
  //   sadiag1 := load_diagnoze_disp_nabl_from_file()
  // Endif
  Private arr_usl_otkaz, adiag_talon[ 16 ]
  For i := 1 To 5
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    Private &pole_diag := Space( 6 )
    Private &pole_1dispans := 0
    Private &pole_dn_dispans := CToD( '' )
  Next

  stat_msg( '���⠢����� ॥��� ��砥�' )
  nsh := f_mb_me_nsh( _nyear, @mb, @me )
  r_use( dir_exe() + '_mo_mkb', , 'MKB_10' )
  Index On FIELD->shifr + Str( FIELD->ks, 1 ) to ( cur_dir() + '_mo_mkb' )
  g_use( dir_server() + 'mo_rees', , 'REES' )
  Index On Str( FIELD->nn, nsh ) to ( cur_dir() + 'tmp_rees' ) For FIELD->nyear == _nyear .and. FIELD->nmonth == _nmonth
  fl := .f.
  For mnn := mb To me
    find ( Str( mnn, nsh ) )
    If !Found() // ��諨 ᢮����� �����
      fl := .t.
      Exit
    Endif
  Next
  If !fl
    Close databases
    Return func_error( 10, '�� 㤠���� ���� ᢮����� ����� ����� � �����. �஢���� ����ன��!' )
  Endif
  Index On Str( FIELD->nschet, 6 ) to ( cur_dir() + 'tmp_rees' ) For FIELD->nyear == _nyear
  If !Eof()
    Go Bottom
    mnschet := rees->nschet + 1
  Endif
  If !Between( mnschet, mem_beg_rees, mem_end_rees )
    fl := .f.
    For mnschet := mem_beg_rees To mem_end_rees
      find ( Str( mnschet, 6 ) )
      If !Found() // ��諨 ᢮����� �����
        fl := .t.
        Exit
      Endif
    Next
    If !fl
      dbCloseAll()
      Return func_error( 10, '�� 㤠���� ���� ᢮����� ����� ॥���. �஢���� ����ன��!' )
    Endif
  Endif
  Set Index To
  addrecn()
  rees->KOD    := RecNo()
  rees->NSCHET := mnschet
  rees->DSCHET := sys_date
  rees->NYEAR  := _NYEAR
  rees->NMONTH := _NMONTH
  rees->NN     := mnn
  aFilesName := name_reestr_XML( p_tip_reestr, _NYEAR, _NMONTH, mnn, nsh )
//  s := 'RM' + CODE_LPU + 'T34' + '_' + Right( StrZero( _NYEAR, 4 ), 2 ) + StrZero( _NMONTH, 2 ) + StrZero( mnn, nsh )
//  rees->NAME_XML := { 'H', 'F' }[ p_tip_reestr ] + s
  rees->NAME_XML := aFilesName[ 1 ]
  mkod_reestr := rees->KOD
  rees->CODE  := ret_unique_code( mkod_reestr )
  code_reestr := rees->CODE
  //
  g_use( dir_server() + 'mo_xml', , 'MO_XML' )
  addrecn()
  mo_xml->KOD    := RecNo()
  mo_xml->FNAME  := rees->NAME_XML
//  mo_xml->FNAME2 := 'L' + s
  mo_xml->FNAME2 := aFilesName[ 2 ]
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min( Seconds() )
  mo_xml->TIP_OUT := _XML_FILE_REESTR // ⨯ ���뫠����� 䠩��;1-॥���
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  Unlock
  Commit
  //
  use_base( 'lusl' )
  use_base( 'luslc' )
  use_base( 'luslf' )
  r_use( dir_server() + 'human_im', dir_server() + 'human_im', 'IMPL' )
  r_use( dir_server() + 'human_lek_pr', dir_server() + 'human_lek_pr', 'LEK_PR' )

  laluslf := create_name_alias( 'luslf', _nyear )
  r_use( dir_server() + 'mo_uch', , 'UCH' )
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'mo_pers', , 'P2' )
  r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'P2TABN' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  g_use( dir_server() + 'mo_rhum', , 'RHUM' )
  Index On Str( FIELD->REESTR, 6 ) to ( cur_dir() + 'tmp_rhum' )
  g_use( dir_server() + 'human_u_', , 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To FIELD->u_kod into USL
  r_use( dir_server() + 'mo_su', , 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To FIELD->u_kod into MOSU
  If p_tip_reestr == 1
    r_use( dir_server() + 'kart_inv', , 'INV' )
    Index On Str( FIELD->kod, 7 ) to ( cur_dir() + 'tmp_inv' )
  Endif
  r_use( dir_server() + 'kartote2', , 'KART2' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_, To RecNo() into KART2
  r_use( dir_server() + 'mo_onkna', dir_server() + 'mo_onkna', 'ONKNA' ) // �������ࠢ�����
  r_use( dir_server() + 'mo_onkco', dir_server() + 'mo_onkco', 'ONKCO' )
  r_use( dir_server() + 'mo_onksl', dir_server() + 'mo_onksl', 'ONKSL' ) // �������� � ��砥 ��祭�� ���������᪮�� �����������
  r_use( dir_server() + 'mo_onkdi', dir_server() + 'mo_onkdi', 'ONKDI' ) // ���������᪨� ����
  r_use( dir_server() + 'mo_onkpr', dir_server() + 'mo_onkpr', 'ONKPR' ) // �������� �� �������� ��⨢�����������
  g_use( dir_server() + 'mo_onkus', dir_server() + 'mo_onkus', 'ONKUS' )
  g_use( dir_server() + 'mo_onkle', dir_server() + 'mo_onkle', 'ONKLE' )
  g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  Set Order To 2 // ������ �� 2-�� ����
  g_use( dir_server() + 'human_2', , 'HUMAN_2' )
  g_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To FIELD->kod_k into KART
  r_use( dir_exe() + '_mo_t2_v1', , 'T21' )
  Index On FIELD->shifr to ( cur_dir() + 'tmp_t21' )

  Use ( cur_dir() + 'tmpb' ) new
  If reg_sort == 1
    Index On Upper( FIELD->fio ) to ( cur_dir() + 'tmpb' ) For FIELD->kod_tmp == _recno .and. FIELD->plus
  Else
    Index On Str( FIELD->pz, 2 ) + Str( 10000000 - FIELD->cena_1, 11, 2 ) to ( cur_dir() + 'tmpb' ) For FIELD->kod_tmp == _recno .and. FIELD->plus
  Endif
  pkol := psumma := iusl := 0
//  Go Top
  tmpb->( dbGoTop() )
  Do While !tmpb->( Eof() )
    arrLP := {}
    @ MaxRow(), 1 Say lstr( pkol ) Color cColorSt2Msg
    Select HUMAN
    Goto ( tmpb->kod_human )

    otd->( dbGoto( human->OTD ) )
    lTypeLUOnkoDisp := ( otd->tiplu == TIP_LU_ONKO_DISP )

    pkol++
    psumma += human->cena_1
    Select RHUM
    addrec( 6 )
    rhum->REESTR := mkod_reestr
    rhum->KOD_HUM := human->kod
    rhum->REES_ZAP := pkol
    human_->( g_rlock( forever ) )
    If human_->REES_NUM < 99
      human_->REES_NUM := human_->REES_NUM + 1
    Endif
    human_->REESTR := mkod_reestr
    human_->REES_ZAP := pkol
    If tmpb->ishod == 89  // 2-� ��砩
      Select HUMAN_3
      find ( Str( tmpb->kod_human, 7 ) )
      If Found()
        g_rlock( forever )
        If human_3->REES_NUM < 99
          human_3->REES_NUM := human_3->REES_NUM + 1
        Endif
        human_3->REESTR := mkod_reestr
        human_3->REES_ZAP := pkol
        //
        Select HUMAN
        Goto ( human_3->kod )  // ����� �� 1-� ��砩
        human_->( g_rlock( forever ) )
        psumma += human->cena_1
        If human_->REES_NUM < 99
          human_->REES_NUM := human_->REES_NUM + 1
        Endif
        human_->REESTR := mkod_reestr
        human_->REES_ZAP := pkol
      Endif
    Endif
    If pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    Endif
    tmpb->( dbSkip() )
  Enddo
  Select REES
  g_rlock( forever )
  rees->KOL := pkol
  rees->SUMMA := psumma
  dbUnlockAll()
  dbCommitAll()
  //
  //
  //
  // ᮧ����� ���� XML-���㬥��
  oXmlDoc := hxmldoc():new()

  // �������� ��୥��� ����� XML-���㬥��
  oXmlDoc:add( hxmlnode():new( 'ZL_LIST' ) )
  oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )

  // �������� ��������� XML-���㬥��
  sVersion := '3.11'
  controlVer := _nyear * 100 + _nmonth
  if p_tip_reestr == 1
    // ������ ��砥� �������� ����樭᪮� �����, �� �᪫�祭��� ����樭᪮� ����� �� ��ᯠ��ਧ�樨,
    // ����樭᪨� �ᬮ�ࠬ ��ᮢ��襭����⭨� � ��䨫����᪨� ����樭᪨� �ᬮ�ࠬ ��।������� ��㯯 ���᫮�� ��ᥫ����
    If ( controlVer >= 202201 ) // � ﭢ��� 2022 ����
      sVersion := '3.2'
    Endif
    If ( controlVer >= 202403 ) // � ���� 2024 ����
      sVersion := '4.0'
    Endif
    If ( controlVer >= 202501 ) // � ﭢ��� 2025 ����
      sVersion := '5.0'
    Endif
    If ( controlVer >= 202507 ) // � ��� 2025 ����
      sVersion := '5.1'
    Endif
  elseif p_tip_reestr == 2
    // ������ ��砥� �������� ����樭᪮� ����� �� ��ᯠ��ਧ�樨, ��䨫����᪨� ����樭᪨�
    // �ᬮ�ࠬ ��ᮢ��襭����⭨� � ��䨫����᪨� ����樭᪨� �ᬮ�ࠬ ��।������� ��㯯 ���᫮�� ��ᥫ����
    If ( controlVer >= 202501 ) // � ﭢ��� 2025 ����
      sVersion := '5.0'
    Endif
  endif

  mo_add_xml_stroke( oXmlNode, 'VERSION', sVersion )
  mo_add_xml_stroke( oXmlNode, 'DATA', date2xml( rees->DSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'FILENAME', mo_xml->FNAME )
  mo_add_xml_stroke( oXmlNode, 'SD_Z', lstr( pkol ) )

  // �������� ॥��� ��砥� ��� XML-���㬥��
  oXmlNode := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'SCHET' ) )
  mo_add_xml_stroke( oXmlNode, 'CODE', lstr( code_reestr ) )
  mo_add_xml_stroke( oXmlNode, 'CODE_MO', CODE_MO )
  mo_add_xml_stroke( oXmlNode, 'YEAR', lstr( _NYEAR ) )
  mo_add_xml_stroke( oXmlNode, 'MONTH', lstr( _NMONTH ) )
  mo_add_xml_stroke( oXmlNode, 'NSCHET', lstr( rees->NSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'DSCHET', date2xml( rees->DSCHET ) )
  mo_add_xml_stroke( oXmlNode, 'SUMMAV', Str( psumma, 15, 2 ) )
  // mo_add_xml_stroke(oXmlNode, 'COMENTS', '')
  //
  // ᮧ����� ���� XML-���㬥�� ��� ॥��� ��樥�⮢
  fl_ver := 311
  oXmlDocPacient := hxmldoc():new()
  // �������� ��୥��� ����� ॥��� ��樥�⮢ ��� XML-���㬥��
  oXmlDocPacient:add( hxmlnode():new( 'PERS_LIST' ) )
  // �������� ��������� 䠩�� ॥��� ��樥�⮢ ��� XML-���㬥��
  oXmlNodePacient := oXmlDocPacient:aItems[ 1 ]:add( hxmlnode():new( 'ZGLV' ) )
  sVersionPacient := '3.11'
  If StrZero( _nyear, 4 ) + StrZero( _nmonth, 2 ) > '201910' // � ����� 2019 ����
    fl_ver := 32
    sVersionPacient := '3.2'
  Endif
  mo_add_xml_stroke( oXmlNodePacient, 'VERSION', sVersionPacient )
  mo_add_xml_stroke( oXmlNodePacient, 'DATA', date2xml( rees->DSCHET ) )
  mo_add_xml_stroke( oXmlNodePacient, 'FILENAME', mo_xml->FNAME2 )
  mo_add_xml_stroke( oXmlNodePacient, 'FILENAME1', mo_xml->FNAME )
  //
  Select RHUM
  Index On Str( FIELD->REES_ZAP, 6 ) to ( cur_dir() + 'tmp_rhum' ) For FIELD->REESTR == mkod_reestr
  rhum->( dbGoTop() )   //  Go Top
  Do While ! rhum->( Eof() )
    @ MaxRow(), 0 Say Str( rhum->REES_ZAP / pkol * 100, 6, 2 ) + '%' Color cColorSt2Msg

    // �����뢠�� ����� ��� ����
    elem_reestr_sluch( oXmlDoc, p_tip_reestr, _nyear )

    // �����뢠�� ����� ��� ��樥��
    elem_reestr_pacient( oXmlDocPacient, fl_ver, p_tip_reestr )      
    rhum->( dbSkip() )  //  Skip
  Enddo
  dbUnlockAll()
  dbCommitAll()

//  stat_msg( '������ XML-���㬥�� � 䠩� ॥��� ��砥�' )

  oXmlDoc:save( AllTrim( mo_xml->FNAME ) + sxml() )
  name_zip := AllTrim( mo_xml->FNAME ) + szip()
  AAdd( arr_zip, AllTrim( mo_xml->FNAME ) + sxml() )
  //
  oXmlDocPacient:save( AllTrim( mo_xml->FNAME2 ) + sxml() )
  AAdd( arr_zip, AllTrim( mo_xml->FNAME2 ) + sxml() )
  //
  //
  dbCloseAll()
  If chip_create_zipxml( name_zip, arr_zip, .t. )
    Keyboard Chr( K_TAB ) + Chr( K_ENTER )
  Endif
  Return Nil
