#include 'function.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 12.07.24 ����祭�� ����� ���������� �� �� ��।������� ���ᨨ
function get_status_updateDB( idVer )
  // ������: .t. - ���������� ���������
  //          .f. - ���������� ���������

  local ret := .f., fl

  fl := g_use( dir_server() + 'ver_updatedb', , 'UPD', , .t. )

  Locate For ver == idVer
  If Found() .and. ( UPD->done == 1 )
    ret := .t.
  endif

  UPD->( dbCloseArea() )

  return ret

// 12.07.24 ��⠭���� ����� ���������� �� �� ��।������� ���ᨨ
function set_status_updateDB( idVer )
  // ������: .t. - ���������� ��諮 �ᯥ譮
  //          .f. - ���������� �� ��諮 ��� ��� �� �뫮

  local fl := .f.

  fl := g_use( dir_server() + 'ver_updatedb', , 'UPD', , .t. )

  UPD->( dbAppend() )
  UPD->ver := idVer
  UPD->done := 1

  UPD->( dbCloseArea() )

  return fl

// 10.07.24 
Function update_v____()

  Local i := 0, j := 0, fl

  stat_msg( '������塞 ���� "���� ���饭��"' )
  fl := g_use( dir_server() + 'human_', , 'HUMAN_', , .t. )

//  use_base( 'mo_pers', 'PERS', .t. ) // ��஥� 䠩� mo_pers
  if fl
    HUMAN_->( dbSelectArea() )
    HUMAN_->( dbGoTop() )
    Do While ! HUMAN_->( Eof() )
  //    i++
      @ MaxRow(), 1 Say HUMAN_->( RecNo() ) Color cColorStMsg
  //    If ! Empty( HUMAN_->PRVS_NEW )
  //      j := 0
  //      If ( j := AScan( arr_conv_V015_V021, {| x| x[ 1 ] == pers->PRVS_NEW } ) ) > 0
  //        HUMAN_->PRVS_021 := arr_conv_V015_V021[ j, 2 ]
  //      Endif
  //    Elseif ! Empty( HUMAN_->PRVS )
  //      HUMAN_->PRVS_021 := ret_prvs_v021( HUMAN_->PRVS )
  //    Endif
      HUMAN_->( dbSkip() )
    End Do
    dbCloseAll()        // ���஥� ��
  endif

  Return Nil
  
// 03.02.25 �஢������ ��������� � ᮤ�ন��� �� �� ����������
Function update_data_db( aVersion )

  Local snversion := Int( aVersion[ 1 ] * 10000 + aVersion[ 2 ] * 100 + aVersion[ 3 ] )
  Local ver_base := get_version_db()

  If ver_base < 21130 // ���室 �� ����� 2.11.30
    update_v21130()     // ᪮४�஥� ����� 㣫㡫����� ��ᯠ��ਧ�樨
  Endif

  If ver_base < 21203 // ���室 �� ����� 2.12.3
    update_v21203()     // �������� ���� MO_HU_K 䠩�� human_im.dbf
  Endif

  If ver_base < 21208 // ���室 �� ����� 2.12.08
    update_v21208()     // �������� ���� PRVS_V021 ������ �� �ࠢ�筨�� ���. ᯥ樠�쭮�⥩ V021
  Endif

  If ver_base < 50104 // ���室 �� ����� 5.1.4
    update_v50104()     // ��७�� ������ �� ���⭨��� ���
  Endif

  If ver_base < 50202 // ���室 �� ����� 5.2.2
    update_v50202()     // ��७�� ������ � ����������᪨� ��㣠�
  endif

Return Nil

//  12.03.22
Function update_v21203()

  Local cAlias := 'IMPL'

  // Local t1 := 0, t2 := 0

  // t1 := seconds()
  r_use( dir_server() + 'human', dir_server() + 'humank', 'HUMAN' )
  r_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'HU' )

  g_use( dir_server() + 'human_im', dir_server() + 'human_im', cAlias )
  ( cAlias )->( dbSelectArea() )
  ( cAlias )->( dbGoTop() )
  Do While ! ( cAlias )->( Eof() )
    If ( cAlias )->KOD_HUM != 0
      HU->( dbSeek( Str( ( cAlias )->KOD_HUM, 7 ) ) )
      If HU->( Found() )
        HUMAN->( dbSeek( Str( ( cAlias )->KOD_HUM, 7 ) ) )
        If HUMAN->( Found() )
          If ( cAlias )->( dbRLock() )
            ( cAlias )->MO_HU_K := HU->( RecNo() )
          Endif
          ( cAlias )->( dbRUnlock() )
        Endif
      Endif
    Endif
    ( cAlias )->( dbSkip() )
  End Do
  HU->( dbCloseAre() )
  HUMAN->( dbCloseAre() )
  ( cAlias )->( dbSelectArea() )
  index_base( 'human_im' )
  dbCloseAll()        // ���஥� ��
  // t2 := seconds() - t1
  // if t2 > 0
  // n_message({"","�६� ��室� �� - "+sectotime(t2)},,;
  // color1,cDataCSay,,,color8)
  // endif
  // alertx(i, '������⢮ ���㤭����')

  Return Nil

//  16.12.22
Function update_v21208()

  Local i := 0, j := 0
  Local arr_conv_V015_V021 := conversion_v015_v021()

  stat_msg( '������塞 ᯥ樠�쭮���' )
  use_base( 'mo_pers', 'PERS', .t. ) // ��஥� 䠩� mo_pers

  pers->( dbSelectArea() )
  pers->( dbGoTop() )
  Do While ! pers->( Eof() )
    i++
    @ MaxRow(), 1 Say pers->fio Color cColorStMsg
    If ! Empty( pers->PRVS_NEW )
      j := 0
      If ( j := AScan( arr_conv_V015_V021, {| x| x[ 1 ] == pers->PRVS_NEW } ) ) > 0
        pers->PRVS_021 := arr_conv_V015_V021[ j, 2 ]
      Endif
    Elseif ! Empty( pers->PRVS )
      pers->PRVS_021 := ret_prvs_v021( pers->PRVS )
    Endif
    pers->( dbSkip() )
  End Do
  dbCloseAll()        // ���஥� ��

  Return Nil

// 17.12.21
Function update_v21130()

  Local is_DVN_COVID := .f.
  Local mkod
  Local begin_DVN_COVID := 0d20210701   // ��� ��砫� 㣫㡫����� ��ᯠ��ਧ�樨
  Local i := 0, j := 0
  Local lshifr := ''

  r_use( dir_server() + 'mo_otd', , 'otd' )
  OTD->( dbGoTop() )
  Do While ! otd->( Eof() )
    If otd->TIPLU == TIP_LU_DVN_COVID
      is_DVN_COVID := .t.
      Exit
    Endif
    otd->( dbSkip() )
  End Do
  otd->( dbCloseArea() )

  If is_DVN_COVID

    stat_msg( '�஢�ઠ � ��ࠢ����� ���� ��� � ����� ��� ���㡫����� ��ᯠ��ਧ�樨' )

    r_use( dir_server() + 'uslugi', , 'USL' )
    r_use( dir_server() + 'mo_su', , 'MOSU' )

    use_base( 'mo_hu' )
    use_base( 'human_u' ) // ��஥� 䠩� human_u � ᮯ������騥 䠩��

    use_base( 'human' ) // ��஥� 䠩� human_u � ᮯ������騥 䠩��

    human->( dbSelectArea() )
    human->( dbGoTop() )

    Do While ! human->( Eof() )
      mkod := human->kod
      If human->k_data >= begin_DVN_COVID
        If human->ishod == 401
          hu->( dbSelectArea() )
          hu->( dbSeek( Str( mkod, 7 ) ) )
          Do While hu->kod == mkod .and. !Eof()
            usl->( dbGoto( hu->u_kod ) )
            If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
              lshifr := usl->shifr
            Endif
            lshifr := AllTrim( lshifr )

            If lshifr == '70.8.1' .and. human_->VRACH != hu->KOD_VR
              i++
              @ MaxRow(), 1 Say human->fio Color cColorStMsg
              human_->( dbSelectArea() )
              If human_->( dbRLock() )
                human_->VRACH := hu->KOD_VR
              Endif
              human_->( dbRUnlock() )
              hu->( dbSelectArea() )
            Endif
            hu->( dbSkip() )
          End Do

        Elseif human->ishod == 402
          Select MOHU
          Set Relation To u_kod into MOSU
          mohu->( dbSeek( Str( mkod, 7 ) ) )
          Do While MOHU->kod == mkod .and. !Eof()
            MOSU->( dbGoto( MOHU->u_kod ) )
            lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )

            If ( lshifr == 'B01.026.002' .or. lshifr == 'B01.047.002' .or. lshifr == 'B01.047.006' ) .and. human_->VRACH != mohu->KOD_VR
              j++
              @ MaxRow(), 1 Say human->fio Color cColorStMsg
              human_->( dbSelectArea() )
              If human_->( dbRLock() )
                human_->VRACH := mohu->KOD_VR
              Endif
              human_->( dbRUnlock() )
              mohu->( dbSelectArea() )
            Endif
            mohu->( dbSkip() )
          Enddo
        Endif
      Endif
      human->( dbSelectArea() )
      human->( dbSkip() )
    End Do
    dbCloseAll()        // ���஥� ��
  Endif

  Return Nil

// 29.01.25
function update_v50104()     // ��७�� ������ �� ���⭨��� ���

  stat_msg( '��७�ᨬ ���ଠ�� �� ���⭨��� ���' )
  use_base( 'kartotek', 'kart', .t. ) // ��஥� 䠩� kartotek

//  dbEval( { || kart->PC3 := iif( kart->PN1 == 30, '035', ;
//      iif( Empty( kart->PC3 ), '000', kart->PC3 ) ) } )
  dbEval( { || kart->PC3 := '000' } )

  dbCloseAll()        // ���஥� ��
  return nil

// 03.02.25
Function update_v50202()     // ��७�� ������ � ����������᪨� ��㣠�

  local  i
  Local org_gen_N_PNF := { ;  
   "101001",; //	���� "���� � 1"
   "101002",; //	���� "�����"
   "101003",; //	���� "���� � 3"
   "101201",; //	���� "������"
   "102604",; //	���� "������"
   "104001",; //	���� "������"
   "104401",; //	���� "�����"
   "106001",; //	���� "����� � 1", �.����᪨�
   "106002",; //	���� "����� � 2"
   "131001",; //	��� "��� � 1"
   "131940",; //	����� ���� ���� ���ᨨ
   "146004",; //	��� "������� ��� � 4"
   "151005",; //	��� "�� � 5"
   "161007",; //	��� "�� ��� � 7"
   "171004",; //	��� "������᪠� ���쭨� � 4 "
   "184551",; //	������ ��� "�����" � �.������ࠤ�
   "186002",; //	��� "������᪨� த���� ��� � 2"
   "254570",; //	�� "���"
   "731002",; //	���� "��� ��� ���ᨨ �� ������ࠤ᪮� ������"
   "741904",; //	���� "413 ��" ������஭� ���ᨨ
   "801926",; //	��� "�����-�����"
   "804504",; //	�� "���� "��⠭-���ਪ���"
   "805929",; //	��� "�� "��䫥��"
   "805938",; //	���� "��������+"
   "805960",; //	��� "���-����"
   "805972"} //	��� "������� �����"
  
  Local mas_usl_gen0      := {"2.79.13", "2.79.47", "2.80.8",  "2.88.33",  "2.78.26"}
  Local mas_usl_gen_N_PNF := {"2.79.78", "2.79.80", "2.80.70", "2.88.147", "2.78.118"}
  Local mas_usl_gen_PNF   := {"2.79.77", "2.79.79", "2.80.69", "2.88.146", "2.78.117"}
  Local mas_kod_gen_N_PNF := {0,0,0,0,0}
  Local mas_kod_gen_PNF   := {0,0,0,0,0}
  Local mas_kod_gen0      := {0,0,0,0,0}
  Local cena, flag := .F. 
  
  
  stat_msg( '��������� ���ଠ樨 � �����������᪨� �ਥ���' )
  Use_base('lusl')
  Use_base('luslc')
  Use_base('uslugi')
  R_Use(dir_server() + 'uslugi1', {dir_server() + 'uslugi1',;
                              dir_server() + 'uslugi1s'}, 'USL1')
  //�஢��塞 ����稥 ��� � ��襬 �ࠢ�筨�� - �᫨ ��� - ������塞
  // � ᮧ���� ���ᨢ ����権 � 䠩�� ���
  //Function foundourusluga( lshifr, ldate, lprofil, lvzros_reb, /*@*/lu_cena, ipar, not_cycle)
  for i := 1 to len(org_gen_N_PNF)
     my_debug(,i)
     my_debug(,org_gen_N_PNF[i])
     my_debug(,glob_mo[ _MO_KOD_TFOMS ])
     my_debug(,_MO_KOD_TFOMS)
    if org_gen_N_PNF[i] == glob_mo[ _MO_KOD_TFOMS ] 
      flag := .T. 
    endif
  next  
  if flag
    for i := 1 to 5
      mas_kod_gen_N_PNF[i] := foundourusluga( mas_usl_gen_N_PNF[i], 0d20250102,136,0,cena)
    next
  else
    for i := 1 to 5
      mas_kod_gen_PNF[i] := foundourusluga( mas_usl_gen_PNF[i], 0d20250102,136,0,cena)
    next
  endif  
  // ⥯��� ���� ��㣨   
  for i := 1 to 5
    mas_kod_gen0[i] := foundourusluga( mas_usl_gen0[i], 0d20241202,136,0,cena) // ᬮ��� �� ������� 2024 ����
  next    
  // ���ᨢ� ��� ������ ��⮢�
  Use_base('human')
  Use_base('human_u')
  select HUMAN
  set order to 4 //   dir_server() + 'humand'
  find (dtos(stod("20250101")))
  do while year(human->k_data)== 2025 .and. !eof()    
    // �� ��� - ��䨫��஢�� - ⥯��� ���� �� ��㣠�
    select hu
    set order to 1
    find (str(human->kod,7))
    do while human->kod == hu->kod .and. !eof() 
      // �஢��塞 �� ��� ��㣨 �� ᯨ�� 
      g_rlock( forever )
      if hu->u_kod == mas_kod_gen0[1]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[1]
        else
          hu->u_kod := mas_kod_gen_PNF[1]
        endif
      elseif hu->u_kod == mas_kod_gen0[2]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[2]
        else
          hu->u_kod := mas_kod_gen_PNF[2]
        endif
      elseif hu->u_kod == mas_kod_gen0[3]  
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[3]
        else
          hu->u_kod := mas_kod_gen_PNF[3]
        endif
      elseif hu->u_kod == mas_kod_gen0[4]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[4]
        else
          hu->u_kod := mas_kod_gen_PNF[4]
        endif
      elseif hu->u_kod == mas_kod_gen0[5]
        if flag
          hu->u_kod := mas_kod_gen_N_PNF[5]
        else
          hu->u_kod := mas_kod_gen_PNF[5]
        endif
      endif  
      select hu 
      Unlock
      skip
    enddo 
    select human
    skip
  enddo

  dbCloseAll()        // ���஥� ��
  Return Nil
  
// 30.05.25
function illegal_stad_kod()

  local cAlias, cAliasHum, ft, exist, i
  local name_file := cur_dir() + 'error_stad.txt', reg_print := 2

  exist := .f.
  i := 0
  cAlias := 'ONKOSL'
  cAliasHum := 'HUMAN'

  r_use( dir_server() + 'human', , cAliasHum )
  r_use( dir_server() + 'mo_onksl', , cAlias )
  ( cAlias )->( dbGoTop() )
  do while ! ( cAlias )->( Eof() )

    if ( cAlias )->STAD > 333 // ��᫥���� ��� ��ண� N002
      if ! exist
        ft := tfiletext():new( name_file, , .t., , .t. )
        ft:add_string( '' )
        ft:add_string( '���᮪ ��樥�⮢ � �訡���� �⠤�� ���������������', FILE_CENTER, ' ' )
        ft:add_string( '' )
        exist := .t.
      endif
      ( cAliasHum )->( dbGoto( ( cAlias )->KOD ) )
      if ( ! ( cAliasHum )->( Eof() ) ) .and. ( ! ( cAliasHum )->( Bof() ) )
        ft:add_string( AllTrim( ( cAliasHum )->FIO ) + '  ' + DToC( ( cAliasHum )->Date_R ) )
      endif
      i++
    endif
    ( cAlias )->( dbSkip() )
  Enddo

  ( cAlias )->( dbCloseArea() )
  ( cAliasHum )->( dbCloseArea() )
  if i > 0
    ft := nil
    viewtext( name_file, , , , .t., , , reg_print )
  endif
  return nil