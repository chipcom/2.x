// �㭪樨 ��� �ନ஢���� ����� ॥��� ��業⮢
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.10.25
function elem_lek_pr_zno( oONK, mdata, human_recno, mkod_human )

  // �� �������� � �ਬ������� ������⢥���� �९���� �� 娬���࠯����᪮� ��� 娬����祢�� ��祭��
  // ������� � xml-���㬥�� ���ଠ�� � ������⢥���� �९����

  local oLEK, oINJ, arrLP, aRegnum, i, iLekPr
  local old_lek, old_sh

  If mdata >= 0d20250101
    arrLP := collect_lek_pr( human_recno )
    If Len( arrLP ) > 0
      aRegnum := unique_val_in_array( arrLP, 3 ) // ����稬 㭨����� REGNUM
      For i := 1 To Len( aRegnum )
        // ����६ ⨯� ���. �९��⮢
        // �������� ᢥ����� � �ਬ������� ������⢥���� �९���� �� ��祭�� ���������᪮�� ���쭮�� ��� XML-���㬥��
        oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
        mo_add_xml_stroke( oLEK, 'REGNUM', aRegnum[ i, 3 ] )
        mo_add_xml_stroke( oLEK, 'REGNUM_DOP', ;
          get_sootv_n021( aRegnum[ i, 2 ], aRegnum[ i, 3 ], mdata )[ 7 ] )
        mo_add_xml_stroke( oLEK, 'CODE_SH', aRegnum[ i, 2 ] )
        For iLekPr := 1 To Len( arrLp )
          If arrLP[ iLekPr, 3 ] == aRegnum[ i, 3 ]
            oINJ := oLek:add( hxmlnode():new( 'INJ' ) )
            mo_add_xml_stroke( oINJ, 'DATE_INJ', date2xml( arrLP[ iLekPr, 1 ] ) )
            mo_add_xml_stroke( oINJ, 'KV_INJ', Str( arrLP[ iLekPr, 5 ], 8, 3 ) )
            mo_add_xml_stroke( oINJ, 'KIZ_INJ', Str( arrLP[ iLekPr, 9 ], 8, 3 ) )
            mo_add_xml_stroke( oINJ, 'S_INJ', Str( arrLP[ iLekPr, 10 ], 15, 6 ) )
            mo_add_xml_stroke( oINJ, 'SV_INJ', ;
              Str( arrLP[ iLekPr, 5 ] * arrLP[ iLekPr, 10 ], 15, 2 ) )
            mo_add_xml_stroke( oINJ, 'SIZ_INJ', ;
              Str( arrLP[ iLekPr, 9 ] * arrLP[ iLekPr, 10 ], 15, 2 ) )
            mo_add_xml_stroke( oINJ, 'RED_INJ', Str( arrLP[ iLekPr, 11 ], 1, 0 ) )
          Endif
        Next
      Next
    Endif
  Else
    old_lek := Space( 6 )
    old_sh := Space( 10 )
//    Select ONKLE  // 横� �� �� �������
    ONKLE->( dbSeek( Str( mkod_human, 7 ) ) )   //  find ( Str( mkod_human, 7 ) )
    Do While ONKLE->kod == mkod_human .and. ! ONKLE->( Eof() )
      If !( old_lek == ONKLE->REGNUM .and. old_sh == ONKLE->CODE_SH )
        // �������� ᢥ����� � �ਬ������� ������⢥���� �९���� �� ��祭�� ���������᪮�� ���쭮�� ��� XML-���㬥��
        oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
        mo_add_xml_stroke( oLEK, 'REGNUM', ONKLE->REGNUM )
        mo_add_xml_stroke( oLEK, 'CODE_SH', ONKLE->CODE_SH )
      Endif
      // 横� �� ��⠬ ��� ������� ������⢠
      mo_add_xml_stroke( oLEK, 'DATE_INJ', date2xml( ONKLE->DATE_INJ ) )
      old_lek := ONKLE->REGNUM
      old_sh := ONKLE->CODE_SH
//      Select ONKLE
      ONKLE->( dbSkip() )   //  Skip
    Enddo
  Endif
  return nil

// 27.10.25
function elem_lek_pr( oSl, mkod_human )

  // �� �������� � ��������� ������⢥���� �९���� (�� �᪫�祭��� ��砥� �������� ��᮪��孮����筮� ����樭᪮� ����� � 
  // ����樭᪮� ����� �� ���)
  // ������� � xml-���㬥�� ���ଠ�� � ������⢥���� �९����

  local oLEK, oDOSE
  local arrLP, row

  arrLP := collect_lek_pr( mkod_human )
  If Len( arrLP ) != 0
    For Each row in arrLP
      oLEK := oSL:add( hxmlnode():new( 'LEK_PR' ) )
      mo_add_xml_stroke( oLEK, 'DATA_INJ', date2xml( row[ 1 ] ) )
      mo_add_xml_stroke( oLEK, 'CODE_SH', row[ 8 ] )
      If ! Empty( row[ 3 ] )
        mo_add_xml_stroke( oLEK, 'REGNUM', row[ 3 ] )
        // mo_add_xml_stroke(oLEK, 'CODE_MARK', '')  // ��� ���쭥�襣� �ᯮ�짮�����
        oDOSE := oLEK:add( hxmlnode():new( 'LEK_DOSE' ) )
        mo_add_xml_stroke( oDOSE, 'ED_IZM', Str( row[ 4 ], 3, 0 ) )
        mo_add_xml_stroke( oDOSE, 'DOSE_INJ', Str( row[ 5 ], 8, 2 ) )
        mo_add_xml_stroke( oDOSE, 'METHOD_INJ', Str( row[ 6 ], 3, 0 ) )
        mo_add_xml_stroke( oDOSE, 'COL_INJ', Str( row[ 7 ], 5, 0 ) )
      Endif
    Next
  Endif
  return nil

// 27.10.25
function elem_med_dev( oUsl, human_kod, mohu_recno )

  // �� � �������� � ����樭᪨� ��������, ��������㥬�� � �࣠���� 祫�����

  local oMED_DEV, row

  For Each row in collect_implantant( human_kod, mohu_recNo )
    oMED_DEV := oUSL:add( hxmlnode():new( 'MED_DEV' ) )
    mo_add_xml_stroke( oMED_DEV, 'DATE_MED', date2xml( row[ 3 ] ) )
    mo_add_xml_stroke( oMED_DEV, 'CODE_MEDDEV', lstr( row[ 4 ] ) )
    mo_add_xml_stroke( oMED_DEV, 'NUMBER_SER', AllTrim( row[ 5 ] ) )
  Next
  return nil

// 27.10.25
function elem_mr_usl_n( oUsl, nyear, number, prvs, snils )

  // �� � ���. ࠡ�⭨��� �믮������ ����

  local oMR_USL_N

  oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
  mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( number ) )   // ���� �⠢�� 1 �ᯮ���⥫�
  mo_add_xml_stroke( oMR_USL_N, 'PRVS', put_prvs_to_reestr( prvs, nyear ) )
//  p2->( dbGoto( mohu->kod_vr ) )
  mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', snils )
  return nil

// 26.10.25
function elem_ksg( oSl, lshifr_zak_sl, mdata, is_oncology )

  // �� ���������� ⮫쪮 ��� ॥��஢ 1 ⨯� � ������ � �᫮���� ��������
  // � ��㣮���筮�� ��樮���

  Local dPUMPver40 := 0d20240301
  local oKSG, oSLk
  Local akslp, iAKSLP, tKSLP, cKSLP // ���ᨢ, ���稪 ��� 横�� �� ����
  Local akiro

  // �������� ᢥ����� � ��� ��� XML-���㬥��
  akslp := {}
  akiro := {}
  oKSG := oSL:add( hxmlnode():new( 'KSG_KPG' ) )
  mo_add_xml_stroke( oKSG, 'N_KSG', lshifr_zak_sl )

  If mdata >= dPUMPver40   // ��� ����砭�� ���� ��᫥ 01.03.24
    mo_add_xml_stroke( oKSG, 'K_ZP', '1' )  // ���� �⠢�� 1
  Endif

  If !Empty( human_2->pc3 ) .and. !Left( human_2->pc3, 1 ) == '6' // �஬� '�����'
    mo_add_xml_stroke( oKSG, 'CRIT', human_2->pc3 )
  Elseif is_oncology  == 2
    If !Empty( onksl->crit ) .and. !( AllTrim( onksl->crit ) == '���' )
      mo_add_xml_stroke( oKSG, 'CRIT', onksl->crit )
    Endif
    If !Empty( onksl->crit2 )
      mo_add_xml_stroke( oKSG, 'CRIT', onksl->crit2 )  // ��ன ���਩
    Endif
  Endif

  If ! Empty( human_2->pc1 )
    akslp := list2arr( human_2->pc1 )
  Endif

  mo_add_xml_stroke( oKSG, 'SL_K', iif( Empty( akslp ), '0', '1' ) )
  If !Empty( akslp )
    // �������� ᢥ����� � ��� ��� XML-���㬥��
    If Year( human->K_DATA ) >= 2021     // 02.02.21 ������
      tKSLP := getkslptable( human->K_DATA )

      mo_add_xml_stroke( oKSG, 'IT_SL', lstr( ret_koef_kslp_21_xml( akslp, tKSLP, Year( human->K_DATA ) ), 7, 5 ) )

      For iAKSLP := 1 To Len( akslp )
        If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
          oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
          mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ iAKSLP ] ) )
          mo_add_xml_stroke( oSLk, 'VAL_C', lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
        Endif
      Next
    Else
/*
      mo_add_xml_stroke( oKSG, 'IT_SL', lstr( ret_koef_kslp( akslp ), 7, 5 ) )
      oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
      mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ 1 ] ) )
      mo_add_xml_stroke( oSLk, 'VAL_C', lstr( akslp[ 2 ], 7, 5 ) )
      If Len( akslp ) >= 4
        oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
        mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ 3 ] ) )
        mo_add_xml_stroke( oSLk, 'VAL_C', lstr( akslp[ 4 ], 7, 5 ) )
      Endif
*/
    Endif
  Endif

  If ! Empty( human_2->pc2 )
    akiro := list2arr( human_2->pc2 )
  Endif
  If ! Empty( akiro )
    // �������� ᢥ����� � ���� ��� XML-���㬥��
    oSLk := oKSG:add( hxmlnode():new( 'S_KIRO' ) )
    mo_add_xml_stroke( oSLk, 'CODE_KIRO', lstr( akiro[ 1 ] ) )
    mo_add_xml_stroke( oSLk, 'VAL_K', lstr( akiro[ 2 ], 4, 2 ) )
  Endif
  return nil

// 26.10.25
function elem_disability( oPac )

  // �� ���������� ⮫쪮 ��� ॥��஢ 1 ⨯� � ���㫠�୮-����������᪮� ����� �
  // ��०������ ������ �ਪ९������ ��ᥫ����
  
  local oDISAB
  Local tmpSelect

//  If glob_mo[ _MO_IS_UCH ] .and. ;                      // ��� �� ����� �ਪ९�񭭮� ��ᥫ����
//      human_->USL_OK == USL_OK_POLYCLINIC .and. ;                    // �����������
//      kart2->MO_PR == glob_MO[ _MO_KOD_TFOMS ] .and. ;  // �ਪ९�� � ��襬� ��
  if Between( kart_->INVALID, 1, 4 )                   // �������
    tmpSelect := Select()
    dbSelectArea( 'INV' )
    inv->( dbSeek( Str( human->kod_k, 7 ) ) )
//    If inv->( Found() ) .and. ! emptyany( inv->DATE_INV, inv->PRICH_INV )
    If inv->( Found() ) .and. ! ( empty( inv->DATE_INV ) .or. Empty( inv->PRICH_INV ) )
      // ��� ��砫� ��祭�� ���⮨� �� ���� ��ࢨ筮�� ��⠭������� ����������� �� ����� 祬 �� ���
      if ( inv->DATE_INV < human->n_data .and. human->n_data <= AddMonth( inv->DATE_INV, 12 ) )
        // �������� ᢥ����� �� ����������� ��樥�� ��� XML-���㬥��
        oDISAB := oPAC:add( hxmlnode():new( 'DISABILITY' ) )
        // ��㯯� ����������� �� ��ࢨ筮� �ਧ����� �����客������ ��� ���������
        mo_add_xml_stroke( oDISAB, 'INV', lstr( kart_->invalid ) )
        // ��� ��ࢨ筮�� ��⠭������� �����������
        mo_add_xml_stroke( oDISAB, 'DATA_INV', date2xml( inv->DATE_INV ) )
        // ��� ��稭� ��⠭�������  �����������
        mo_add_xml_stroke( oDISAB, 'REASON_INV', lstr( inv->PRICH_INV ) )
        If !Empty( inv->DIAG_INV ) // ��� �᭮����� ����������� �� ���-10
          mo_add_xml_stroke( oDISAB, 'DS_INV', inv->DIAG_INV )
        Endif
      endif
    Endif
    Select( tmpSelect )
  Endif
  return nil

// 20.08.25
Function schet_smoname()

  Local cRet

  cRet := ''
  If AllTrim( human_->smo ) == '34'
    cRet := ret_inogsmo_name( 2 )
  Endif

  Return cRet

// 19.08.25
Function schet_is_oncology( p_tip_reestr, /*@*/is_oncology_smp )

  is_oncology_smp := 0

  Return iif( p_tip_reestr == TYPE_REESTR_DISPASER, 0, f_is_oncology( 1, @is_oncology_smp ) )

// 19.08.25
Function collect_schet_onkna()

  Local arr_onkna, tmpSelect

  tmpSelect := Select()
  arr_onkna := {}
  dbSelectArea( 'ONKNA' )
  onkna->( dbSeek( Str( human->kod, 7 ) ) )
  Do While onkna->kod == human->kod .and. !onkna->( Eof() )
    P2TABN->( dbGoto( onkna->KOD_VR ) )
    If !( P2TABN->( Eof() ) ) .and. !( P2TABN->( Bof() ) )
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
    Else
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, '', '' } )
    Endif
    onkna->( dbSkip() )
  Enddo
  Select( tmpSelect )

  Return arr_onkna

// 19.08.25
Function collect_schet_onkco()

  Local arr_onkco, tmpSelect

  tmpSelect := Select()
  arr_onkco := {}
  dbSelectArea( 'ONKCO' )
  onkco->( dbSeek( Str( human->kod, 7 ) ) )
  Select( tmpSelect )

  Return arr_onkco

// 19.08.25
Function collect_schet_onksl()

  Local arr_onksl, tmpSelect

  tmpSelect := Select()
  arr_onksl := {}
  dbSelectArea( 'ONKSL' )
  onksl->( dbSeek( Str( human->kod, 7 ) ) )
  Select( tmpSelect )

  Return arr_onksl

// 19.08.25
Function collect_schet_onkdi()

  Local arr_onkdi, tmpSelect

  tmpSelect := Select()
  arr_onkdi := {}
  dbSelectArea( 'ONKSL' )
  onksl->( dbSeek( Str( human->kod, 7 ) ) )

  If eq_any( onksl->b_diag, 98, 99 )
    dbSelectArea( 'ONKDI' )
    onkdi->( dbSeek( Str( human->kod, 7 ) ) )
    Do While onkdi->kod == human->kod .and. !Eof()
      AAdd( arr_onkdi, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
      onkdi->( dbSkip() )
    Enddo
  Endif
  Select( tmpSelect )

  Return arr_onkdi

// 19.08.25
Function collect_schet_onkpr()

  Local arr_onkpr, tmpSelect

  tmpSelect := Select()
  arr_onkpr := {}
  dbSelectArea( 'ONKSL' )
  onksl->( dbSeek( Str( human->kod, 7 ) ) )

  If human_->USL_OK < 3 // ��⨢���������� �� ��祭�� ⮫쪮 � ��樮��� � ������� ��樮���
    dbSelectArea( 'ONKPR' )
    onkpr->( dbSeek( Str( human->kod, 7 ) ) )
    Do While onkpr->kod == human->kod .and. ! onkpr->( Eof() )
      AAdd( arr_onkpr, { onkpr->PROT, onkpr->D_PROT } )
      onkpr->( dbSkip() )
    Enddo
  Endif
  If eq_any( onksl->b_diag, 0, 7, 8 ) .and. AScan( arr_onkpr, {| x| x[ 1 ] == onksl->b_diag } ) == 0
    // ������� �⪠�,�� ��������,��⨢��������� �� ���⮫����
    AAdd( arr_onkpr, { onksl->b_diag, human->n_data } )
  Endif
  Select( tmpSelect )

  Return arr_onkpr

// 19.08.25
Function collect_schet_onkusl()

  Local arr_onkusl, tmpSelect

  tmpSelect := Select()
  arr_onkusl := {}
  If iif( human_2->VMP == 1, .t., Between( onksl->DS1_T, 0, 2 ) )
    dbSelectArea( 'ONKUS' )
    onkus->( dbSeek( Str( human->kod, 7 ) ) )
    Do While onkus->kod == human->kod .and. !onkus->( Eof() )
      If Between( onkus->USL_TIP, 1, 5 )
        AAdd( arr_onkusl, onkus->USL_TIP )
      Endif
      onkus->( dbSkip() )
    Enddo
  Endif
  Select( tmpSelect )

  Return arr_onkusl

/*
// 26.10.25
Function is_disability( p_tip_reestr )

  Local fl_DISABILITY := .f.
  Local tmpSelect

  If p_tip_reestr == TYPE_REESTR_GENERAL
    If glob_mo[ _MO_IS_UCH ] .and. ;                      // ��� �� ����� �ਪ९�񭭮� ��ᥫ����
        human_->USL_OK == USL_OK_POLYCLINIC .and. ;                    // �����������
        kart2->MO_PR == glob_MO[ _MO_KOD_TFOMS ] .and. ;  // �ਪ९�� � ��襬� ��
        Between( kart_->INVALID, 1, 4 )                   // �������
      tmpSelect := Select()
      dbSelectArea( 'INV' )
      inv->( dbSeek( Str( human->kod_k, 7 ) ) )
      If inv->( Found() ) .and. ! emptyany( inv->DATE_INV, inv->PRICH_INV )
        // ��� ��砫� ��祭�� ���⮨� �� ���� ��ࢨ筮�� ��⠭������� ����������� �� ����� 祬 �� ���
        fl_DISABILITY := ( inv->DATE_INV < human->n_data .and. human->n_data <= AddMonth( inv->DATE_INV, 12 ) )
      Endif
      Select( tmpSelect )
    Endif
  Endif

  Return fl_DISABILITY
*/

// 19.08.25 ����室��� �� �뢥�� �ࠪ�� ����������� � ॥���
Function need_reestr_c_zab_2025( is_oncology, lUSL_OK, osn_diag )

  Local fl := .f.

  If lUSL_OK < 4
    If lUSL_OK == 3 .and. !( Left( osn_diag, 1 ) == 'Z' )
      fl := .t. // �᫮��� �������� <���㫠�୮> (USL_OK=3) � �᭮���� ������� �� �� ��㯯� Z00-Z99
    Elseif is_oncology == 2
      fl := .t. // �� ��⠭�������� ���
    Endif
  Endif

  Return fl
