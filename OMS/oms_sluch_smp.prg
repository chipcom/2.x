#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 25.06.24 ��� - ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch_smp( Loc_kod, kod_kartotek, tip_lu )

  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // tip_lu - TIP_LU_SMP ��� TIP_LU_NMP - ᪮�� ������ (���⫮���� ����樭᪠� ������)
  Static mm_brigada, st_brigada, mm_trombolit, st_trombolit, mm_spec, SKOD_DIAG := '     ', ;
    st_N_DATA, st_vrach := 0, st_rslt := 0, st_ishod := 0
  Local top2, ar, ibrm := 0
  Local bg := {| o, k| get_mkb10( o, k, .t. ) }, arr_del := {}, mrec_hu := 0, ;
    buf := SaveScreen(), tmp_color := SetColor(), a_smert := {}, ;
    arr_usluga := {}, p_uch_doc := '@!', pic_diag := '@K@!', ;
    i, colget_menu := 'R/W', colgetImenu := 'R/BG', ;
    pos_read := 0, k_read := 0, count_edit := 0, ;
    tmp_help := chm_help_code, fl_write_sluch := .f.
  //
  Default st_N_DATA To sys_date
  Default Loc_kod To 0, kod_kartotek To 0
  Private row_diag_screen, rdiag := 1
  If mem_smp_input == 0
    If  kod_kartotek == 0 // ���������� � ����⥪�
      If ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
        Return Nil
      Endif
    Endif
    top2 := 6
    row_diag_screen := 6
  Else
    top2 := 5
    row_diag_screen := 9
    Private ;
      MFIO        := Space( 50 ), ; // �.�.�. ���쭮��
    mfam := Space( 40 ), mim := Space( 40 ), mot := Space( 40 ), ;
      mpol        := '�', ;
      mdate_r     := BoY( AddMonth( sys_date, -12 * 30 ) ), ;
      MVZROS_REB, M1VZROS_REB := 0, ;
      MADRES      := Space( 50 ), ; // ���� ���쭮��
    m1MEST_INOG := 0, newMEST_INOG := 0, ;
      MVID_UD, ; // ��� 㤮�⮢�७��
    M1VID_UD    := 14, ; // 1-18
    mser_ud := Space( 10 ), mnom_ud := Space( 20 ), mmesto_r := Space( 100 ), ;
      MKEMVYD, M1KEMVYD := 0, MKOGDAVYD := CToD( '' ), ; // ��� � ����� �뤠� ��ᯮ��
    mspolis := Space( 10 ), mnpolis := Space( 20 ), msmo := '34007', ;
      mnamesmo, m1namesmo, ;
      m1company := 0, mcompany, mm_company, ;
      m1KOMU := 0, MKOMU, M1STR_CRB := 0, ;
      mvidpolis, m1vidpolis := 1, ;
      msnils := Space( 11 ), ;
      mokatog := PadR( AllTrim( okato_umolch ), 11, '0' ), ;
      m1adres_reg := 1, madres_reg, ;
      rec_inogSMO := 0, ;
      mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 )
    If kod_kartotek > 0
      r_use( dir_server + 'kartote_', , 'KART_' )
      r_use( dir_server + 'kartotek', , 'KART' )
      Select KART
      Goto ( kod_kartotek )
      Select KART_
      Goto ( kod_kartotek )
      mFIO        := kart->FIO
      mpol        := kart->pol
      mDATE_R     := kart->DATE_R
      m1VZROS_REB := kart->VZROS_REB
      mADRES      := kart->ADRES
      msnils      := kart->snils
      If kart->MI_GIT == 9
        m1KOMU    := kart->KOMU
        M1STR_CRB := kart->STR_CRB
      Endif
      If kart->MEST_INOG == 9 // �.�. �⤥�쭮 ����ᥭ� �.�.�.
        m1MEST_INOG := kart->MEST_INOG
      Endif
      m1vidpolis  := kart_->VPOLIS // ��� ����� (�� 1 �� 3);1-����, 2-�६., 3-����
      mspolis     := kart_->SPOLIS // ��� �����
      mnpolis     := kart_->NPOLIS // ����� �����
      msmo        := kart_->SMO    // ॥��஢� ����� ���
      m1vid_ud    := kart_->vid_ud   // ��� 㤮�⮢�७�� ��筮��
      mser_ud     := kart_->ser_ud   // ��� 㤮�⮢�७�� ��筮��
      mnom_ud     := kart_->nom_ud   // ����� 㤮�⮢�७�� ��筮��
      m1kemvyd    := kart_->kemvyd   // ��� �뤠� ���㬥��
      mkogdavyd   := kart_->kogdavyd // ����� �뤠� ���㬥��
      mmesto_r    := kart_->mesto_r      // ���� ஦�����
      mokatog     := kart_->okatog       // ��� ���� ��⥫��⢠ �� �����
      m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
      //
      arr := retfamimot( 1, .f. )
      mfam := PadR( arr[ 1 ], 40 )
      mim  := PadR( arr[ 2 ], 40 )
      mot  := PadR( arr[ 3 ], 40 )
      If AllTrim( msmo ) == '34'
        mnameismo := ret_inogsmo_name( 1, @rec_inogSMO, .t. )
      Elseif Left( msmo, 2 ) == '34'
        // ������ࠤ᪠� �������
      Elseif !Empty( msmo )
        m1ismo := msmo ; msmo := '34'
      Endif
    Endif
    Close databases
  Endif
  If tip_lu == TIP_LU_SMP .and. Empty( mm_brigada )
    mm_brigada := {}
    mm_trombolit := {}
    use_base( 'luslc' )
    Set Order To 2
    find ( glob_mo[ _MO_KOD_TFOMS ] + '71.' )
    Do While luslc->CODEMO == glob_mo[ _MO_KOD_TFOMS ] .and. Left( luslc->shifr, 3 ) == '71.'
      // ���� 業� �� ��� ����砭�� ��祭��
      If between_date( luslc->datebeg, luslc->dateend, sys_date )
        If eq_any( Left( luslc->shifr, 5 ), '71.1.', '71.2.' )
          i := Right( AllTrim( luslc->shifr ), 1 )
          If AScan( mm_brigada, {| x| x[ 2 ] == i } ) == 0
            AAdd( mm_brigada, { '-', i } )
          Endif
        Elseif Left( luslc->shifr, 5 ) == '71.3.'
          i := AfterAtNum( '.', AllTrim( luslc->shifr ) )
          If AScan( mm_trombolit, {| x| x[ 2 ] == i } ) == 0
            AAdd( mm_trombolit, { '-', i } )
          Endif
        Endif
      Endif
      Skip
    Enddo
    luslc->( dbCloseArea() )
    If Len( mm_brigada ) == 0
      Return func_error( 4, '���� ᪮ன ����� �� ࠧ��� � ��襩 �� �� ���ﭨ� �� ' + full_date( sys_date ) )
    Endif
    ASort( mm_brigada, , , {| x, y| x[ 2 ] < y[ 2 ] } )
    For i := 1 To Len( mm_brigada )
      Do Case
      Case mm_brigada[ i, 2 ] == '1'
        mm_brigada[ i, 1 ] := '1-䥫���᪠�'
        st_brigada := '1'
      Case mm_brigada[ i, 2 ] == '2'
        mm_brigada[ i, 1 ] := '2-��祡���'
        st_brigada := '2'
      Case mm_brigada[ i, 2 ] == '3'
        mm_brigada[ i, 1 ] := '3-��⥭ᨢ��� �࠯��'
      Case mm_brigada[ i, 2 ] == '4'
        mm_brigada[ i, 1 ] := '4-����⥧������� � ॠ����⮫����'
      Case mm_brigada[ i, 2 ] == '5'
        mm_brigada[ i, 1 ] := '5-��न������᪠�'
      Case mm_brigada[ i, 2 ] == '6'
        mm_brigada[ i, 1 ] := '6-��������᪠�'
      Endcase
    Next
    If Len( mm_trombolit ) > 0
      ASort( mm_trombolit, , , {| x, y| Val( x[ 2 ] ) < Val( y[ 2 ] ) } )
      st_trombolit := mm_trombolit[ 1, 2 ]
      For i := 1 To Len( mm_trombolit )
        Do Case
        Case mm_trombolit[ i, 2 ] == '1'
          mm_trombolit[ i, 1 ] := '䥫���᪠� - �ਬ������ ��⨫���'
        Case mm_trombolit[ i, 2 ] == '2'
          mm_trombolit[ i, 1 ] := '䥫���᪠� - �ਬ������ ��⮫�����'
        Case mm_trombolit[ i, 2 ] == '3'
          mm_trombolit[ i, 1 ] := '䥫���᪠� - �ਬ������ ��஫���'
        Case mm_trombolit[ i, 2 ] == '4'
          mm_trombolit[ i, 1 ] := '䥫���᪠� - �ਬ������ ��⠫���'
        Case mm_trombolit[ i, 2 ] == '5'
          mm_trombolit[ i, 1 ] := '��祡��� - �ਬ������ ��⨫���'
        Case mm_trombolit[ i, 2 ] == '6'
          mm_trombolit[ i, 1 ] := '��祡��� - �ਬ������ ��⮫�����'
        Case mm_trombolit[ i, 2 ] == '7'
          mm_trombolit[ i, 1 ] := '��祡��� - �ਬ������ ��஫���'
        Case mm_trombolit[ i, 2 ] == '8'
          mm_trombolit[ i, 1 ] := '��祡��� - �ਬ������ ��⠫���'
        Case mm_trombolit[ i, 2 ] == '9'
          mm_trombolit[ i, 1 ] := 'ᯥ�.��祡��� - �ਬ������ ��⨫���'
        Case mm_trombolit[ i, 2 ] == '10'
          mm_trombolit[ i, 1 ] := 'ᯥ�.��祡��� - �ਬ������ ��⮫�����'
        Case mm_trombolit[ i, 2 ] == '11'
          mm_trombolit[ i, 1 ] := 'ᯥ�.��祡��� - �ਬ������ ��஫���'
        Case mm_trombolit[ i, 2 ] == '12'
          mm_trombolit[ i, 1 ] := 'ᯥ�.��祡��� - �ਬ������ ��⠫���'
        Endcase
      Next
    Endif
  Endif
  If tip_lu == TIP_LU_NMP .and. Empty( mm_spec )
    mm_spec := { { '䥫���', 1 }, { '���', 2 } }
  Endif
  chm_help_code := 3002
  //
  ar := getinivar( tmp_ini, { { 'RAB_MESTO', 'kart_polis', '1' } } )
  Private mm_rslt := {}, mm_ishod := {}, rslt_umolch := 401, ishod_umolch := 401, p_find_polis := Int( Val( ar[ 1 ] ) )
  If tip_lu == TIP_LU_NMP
    rslt_umolch := 301 ; ishod_umolch := 301
  Endif
  //
  If mem_smp_input == 0
    Private mfio := Space( 50 ), mpol, mdate_r, madres, ;
      M1VZROS_REB, MVZROS_REB, m1company := 0, mcompany, mm_company, ;
      mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���, 1-��������, 3-�������/���, 5-���� ���
    msmo := '34007', rec_inogSMO := 0, ;
      mokato, m1okato := '', mismo, m1ismo := '', mnameismo := Space( 100 ), ;
      mvidpolis, m1vidpolis := 1, mspolis := Space( 10 ), mnpolis := Space( 20 )
  Endif
  Private mkod := Loc_kod, mtip_h, is_talon := .f., ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MUCH_DOC    := 0, ; // ��� � ����� ��⭮�� ���㬥��
  MKOD_DIAG   := SKOD_DIAG, ; // ��� 1-�� ��.�������
  MKOD_DIAG2  := Space( 5 ), ; // ��� 2-�� ��.�������
  MKOD_DIAG3  := Space( 5 ), ; // ��� 3-�� ��.�������
  MKOD_DIAG4  := Space( 5 ), ; // ��� 4-�� ��.�������
  MSOPUT_B1   := Space( 5 ), ; // ��� 1-�� ᮯ������饩 �������
  MSOPUT_B2   := Space( 5 ), ; // ��� 2-�� ᮯ������饩 �������
  MSOPUT_B3   := Space( 5 ), ; // ��� 3-�� ᮯ������饩 �������
  MSOPUT_B4   := Space( 5 ), ; // ��� 4-�� ᮯ������饩 �������
  MDIAG_PLUS  := Space( 8 ), ; // ���������� � ���������
  mrslt, m1rslt := st_rslt, ; // १����
  mishod, m1ishod := st_ishod, ; // ��室
  MN_DATA := MK_DATA := st_N_DATA, ; // ��� ��砫� ��祭��
  MVRACH      := Space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
  M1VRACH := st_vrach, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
  MF14_EKST, M1F14_EKST := 0, ; //
  m1novor := 0, mnovor, mcount_reb := 0, ;
    mDATE_R2 := CToD( '' ), mpol2 := ' ', ;
    mbrigada, m1brigada := st_brigada, ;
    mtrombolit, m1trombolit := st_trombolit, ;
    m1brig := 0, mbrig, mm_brig, ;
    m1spec := 1, mspec, ;
    mprer_b := Space( 28 ), m1prer_b := 0, ; // ���뢠��� ��६������
  mm1prer_b := { { '�� ����樭᪨� ���������   ', 1 }, ;
    { '�� �� ����樭᪨� ���������', 2 } }, ;
    mm2prer_b := { { '���⠭���� �� ���� �� ��६.', 1 }, ;
    { '�த������� �������      ', 0 } }, ;
    mm3prer_b := { { '������⢨� �������� ᨭ�஬�', 0 }, ;
    { '����� ����                 ', 1 }, ;
    { '����ﭭ�� ���㯨����. ���� ', 2 }, ;
    { '��㣠� ����ﭭ�� ����      ', 3 }, ;
    { '���� �����񭭠�           ', 4 } }, ;
    mtip, m1tip := 0, ;
    musluga, m1usluga := 0, ;
    mm_usluga := { { '�05.10.004.001 �����஢�� ���', 1 }, ;
    { '�01.015.007 ��������� ��न�����', 2 } }, ;
    m1USL_OK := iif( tip_lu == TIP_LU_SMP, USL_OK_AMBULANCE, USL_OK_POLYCLINIC ), ;
    m1VIDPOM := iif( tip_lu == TIP_LU_SMP, 21, 11 ), ;
    m1PROFIL := iif( tip_lu == TIP_LU_SMP, 84, 160 ), ;
    m1IDSP   := iif( tip_lu == TIP_LU_SMP, 24, 41 )
  Private mm_prer_b := mm2prer_b
  //
  AEval( getv009(), {| x| iif( x[ 5 ] == m1USL_OK, AAdd( mm_rslt, x ), nil ) } )
  AEval( getv012(), {| x| iif( x[ 5 ] == m1USL_OK, AAdd( mm_ishod, x ), nil ) } )
  If AScan( mm_rslt, {| x| x[ 2 ] == rslt_umolch } ) > 0
    m1rslt := rslt_umolch
  Endif
  If AScan( mm_ishod, {| x| x[ 2 ] == ishod_umolch } ) > 0
    m1ishod := ishod_umolch
  Endif
  //
  r_use( dir_server + 'human_2', , 'HUMAN_2' )
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', , 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, RecNo() into HUMAN_2
  If mkod_k > 0
    If mem_smp_input == 0
      r_use( dir_server + 'kartote_', , 'KART_' )
      Goto ( mkod_k )
      r_use( dir_server + 'kartotek', , 'KART' )
      Goto ( mkod_k )
      M1FIO       := 1
      mfio        := kart->fio
      mpol        := kart->pol
      mdate_r     := kart->date_r
      M1VZROS_REB := kart->VZROS_REB
      mADRES      := kart->ADRES
      m1VIDPOLIS  := kart_->VPOLIS
      mSPOLIS     := kart_->SPOLIS
      mNPOLIS     := kart_->NPOLIS
      mmesto_r    := kart_->mesto_r      // ���� ஦�����
      m1kemvyd    := kart_->kemvyd   // ��� �뤠� ���㬥��
      mkogdavyd   := kart_->kogdavyd // ����� �뤠� ���㬥��
      m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
      msmo        := kart_->SMO
      If kart->MI_GIT == 9
        m1komu    := kart->KOMU
        m1str_crb := kart->STR_CRB
      Endif
      If AllTrim( msmo ) == '34'
        mnameismo := ret_inogsmo_name( 1, , .t. ) // ������ � �������
      Endif
    Endif
    // �஢�ઠ ��室� = ������
    Select HUMAN
    Set Index to ( dir_server + 'humankk' )
    // find (str(mkod_k, 7))
    // do while human->kod_k == mkod_k .and. !eof()
    // if recno() != Loc_kod .and. is_death(human_->RSLT_NEW) .and. ;
    // human_->oplata != 9 .and. human_->NOVOR == 0
    // a_smert := {'����� ���쭮� 㬥�!', ;
    // '��祭�� � ' + full_date(human->N_DATA)+;
    // ' �� ' + full_date(human->K_DATA)}
    // exit
    // endif
    // skip
    // enddo
    arr_patient_died_during_treatment( mkod_k, loc_kod )
    Set Index To
  Endif
  If Loc_kod > 0
    Select HUMAN
    Goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // ���� ���쭮��
    mUCH_DOC    := Int( Val( human->uch_doc ) )
    m1VRACH     := human_->vrach
    MKOD_DIAG0  := human_->KOD_DIAG0
    MKOD_DIAG   := human->KOD_DIAG
    MKOD_DIAG2  := human->KOD_DIAG2
    MKOD_DIAG3  := human->KOD_DIAG3
    MKOD_DIAG4  := human->KOD_DIAG4
    MSOPUT_B1   := human->SOPUT_B1
    MSOPUT_B2   := human->SOPUT_B2
    MSOPUT_B3   := human->SOPUT_B3
    MSOPUT_B4   := human->SOPUT_B4
    MDIAG_PLUS  := human->DIAG_PLUS
    mstatus_st  := human_->STATUS_ST
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS
    If Empty( Val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    Else
      m1komu := m1str_crb := 0
    Endif
    If human_->NOVOR > 0
      m1novor := 1
      mcount_reb := human_->NOVOR
      mDATE_R2 := human_->DATE_R2
      mpol2 := human_->POL2
    Endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    M1F14_EKST := Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) )
    mn_data := mk_data := human->N_DATA
    m1rslt     := human_->RSLT_NEW
    m1ishod    := human_->ISHOD_NEW
    If ( ibrm := f_oms_beremenn( mkod_diag, MN_DATA ) ) > 0
      m1prer_b := human_2->PN2
    Endif
    //
    r_use( dir_server + 'uslugi', , 'USL' )
    use_base( 'human_u' )
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      Endif
      If tip_lu == TIP_LU_SMP .and. Left( lshifr, 3 ) == '71.' .and. mrec_hu == 0
        If Left( lshifr, 5 ) == '71.3.'
          m1trombolit := Right( RTrim( lshifr ), 1 )
          m1tip := 1
        Else
          m1brigada := Right( RTrim( lshifr ), 1 )
          m1tip := 0
        Endif
        mrec_hu := hu->( RecNo() )
      Elseif tip_lu == TIP_LU_NMP .and. eq_any( AllTrim( lshifr ), '2.80.27', '2.80.28' ) .and. mrec_hu == 0
        m1spec := iif( AllTrim( lshifr ) == '2.80.27', 1, 2 )
        mrec_hu := hu->( RecNo() )
      Else
        AAdd( arr_del, hu->( RecNo() ) )
      Endif
      Select HU
      Skip
    Enddo
    For i := 1 To Len( arr_del )
      Select HU
      Goto ( arr_del[ i ] )
      deleterec( .t., .f. )  // ���⪠ ����� ��� ����⪨ �� 㤠�����
    Next
    If mem_smp_tel == 1
      r_use( dir_server + 'mo_su', , 'MOSU' )
      g_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
      find ( Str( Loc_kod, 7 ) )
      Do While mohu->kod == Loc_kod .and. !Eof()
        mosu->( dbGoto( mohu->u_kod ) )
        If AllTrim( mosu->shifr1 ) == 'A05.10.004.001'
          m1usluga := SetBit( m1usluga, 1 )
          AAdd( arr_usluga, { 1, mohu->( RecNo() ) } )
        Elseif AllTrim( mosu->shifr1 ) == 'B01.015.007'
          m1usluga := SetBit( m1usluga, 2 )
          AAdd( arr_usluga, { 2, mohu->( RecNo() ) } )
        Else
          AAdd( arr_usluga, { 0, mohu->( RecNo() ) } )
        Endif
        Select MOHU
        Skip
      Enddo
    Endif
    If AllTrim( msmo ) == '34'
      mnameismo := ret_inogsmo_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    Endif
  Endif
  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo ; msmo := '34'
  Endif
  If m1vrach > 0
    r_use( dir_server + 'mo_pers', , 'P2' )
    Goto ( m1vrach )
    MTAB_NOM := p2->tab_nom
    m1prvs := -ret_new_spec( p2->prvs, p2->prvs_new )
    // mvrach := padr(fam_i_o(p2->fio)+' ' +ret_tmp_prvs(m1prvs), 36)
    mvrach := PadR( fam_i_o( p2->fio ) + ' ' + ret_str_spec( p2->PRVS_021 ), 36 )
  Endif
  Close databases
  fv_date_r( iif( Loc_kod > 0, mn_data, ) )
  MFIO_KART := _f_fio_kart()
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  MNOVOR    := inieditspr( A__MENUVERT, mm_danet, M1NOVOR )
  MF14_EKST := inieditspr( A__MENUVERT, mm_ekst_smp, M1F14_EKST )
  mrslt     := inieditspr( A__MENUVERT, getv009(), m1rslt )
  mishod    := inieditspr( A__MENUVERT, getv012(), m1ishod )
  mlpu      := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', m1otd )
  MKEMVYD   := inieditspr( A__POPUPMENU, dir_server + 's_kemvyd', M1KEMVYD )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mtip      := inieditspr( A__MENUVERT, mm_danet, m1tip )
  musluga   := inieditspr( A__MENUBIT,  mm_usluga, m1usluga )
  mismo     := init_ismo( m1ismo )
  If ibrm > 0
    mm_prer_b := iif( ibrm == 1, mm1prer_b, iif( ibrm == 2, mm2prer_b, mm3prer_b ) )
    If ibrm == 1 .and. m1prer_b == 0
      mprer_b := Space( 28 )
    Else
      mprer_b := inieditspr( A__MENUVERT, mm_prer_b, m1prer_b )
    Endif
  Endif
  If mem_smp_input == 1
    mvid_ud := inieditspr( A__MENUVERT, getvidud(), m1vid_ud )
    madres_reg := ini_adres( 1 )
  Endif
  f_valid_komu(, -1 )
  If m1komu == 0
    m1company := Int( Val( msmo ) )
  Elseif eq_any( m1komu, 1, 3 )
    m1company := m1str_crb
  Endif
  mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
  If m1company == 34
    If !Empty( mismo )
      mcompany := PadR( mismo, 38 )
    Elseif !Empty( mnameismo )
      mcompany := PadR( mnameismo, 38 )
    Endif
  Endif
  If tip_lu == TIP_LU_SMP
    f_valid_brig(, -1, mm_brigada, mm_trombolit, st_brigada, st_trombolit )
    If m1tip == 0
      m1brig := m1brigada
    Else
      m1brig := m1trombolit
    Endif
    mbrig := inieditspr( A__MENUVERT, mm_brig, m1brig )
    str_1 := ' ���� �������� ���'
  Else
    --top2
    mspec := inieditspr( A__MENUVERT, mm_spec, m1spec )
    str_1 := ' ���� �������� ���⫮���� ����樭᪮� �����'
  Endif
  If Loc_kod == 0
    str_1 := '����������' + str_1
    mtip_h := yes_vypisan
  Else
    str_1 := '������஢����' + str_1
  Endif
  SetColor( color8 )
  myclear( top2 )
  @ top2 - 1, 0 Say PadC( str_1, 80 ) Color 'B/BG*'
  Private gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }
  Private gl_arr := { ;  // ��� ��⮢�� �����
  { 'usluga', 'N', 10, 0, , , , {| x| inieditspr( A__MENUBIT, mm_usluga, x ) } };
    }
  @ MaxRow(), 0 Say PadC( '<Esc> - ��室;  <PgDn> - ������;  <F1> - ������', MaxCol() + 1 ) Color color0
  mark_keys( { '<F1>', '<Esc>', '<PgDn>' }, 'R/BG' )
  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������
  diag_screen( 0 )
  Do While .t.
    j := top2
    If yes_num_lu == 1 .and. Loc_kod > 0
      @ j, 50 Say PadL( '���� ��� � ' + lstr( Loc_kod ), 29 ) Color color14
    Endif
    //
    ++j; @ j, 1 Say '��०�����' Get mlpu When .f. Color cDataCSay
    @ Row(), Col() + 2 Say '�⤥�����' Get motd When .f. Color cDataCSay
    //
    If tip_lu == TIP_LU_SMP
      ++j; @ j, 1 Say '���� �맮��: �' Get much_doc Picture '999999'
      @ Row(), Col() Say ', ��� �륧��' Get mn_data ;
        valid {| g| mk_data := mn_data, f_k_data( g, 1 ) }
    Else
      ++j; @ j, 1 Say '���� �' Get much_doc Picture '999999'
      @ Row(), Col() Say ', ��� ���' Get mn_data ;
        valid {| g| mk_data := mn_data, f_k_data( g, 1 ) }
    Endif
    //
    If mem_smp_input == 0
      ++j; @ j, 1 Say '���' Get mfio_kart ;
        reader {| x| menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        valid {| g, o| update_get( 'mkomu' ), update_get( 'mcompany' ) }
    Else
      ++j; @ j, 1 Say '����� ���: ���' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say '�����'  Get mnpolis When m1komu == 0 ;
        valid {|| findkartoteka( 2, @mkod_k ) }
      @ Row(), Col() + 3 Say '���'    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      //
      ++j ; @ j, 1 Say '�������' Get mfam Pict '@S33' ;
        valid {| g| LastKey() == K_UP .or. valfamimot( 1, mfam ) }
      @ Row(), Col() + 1 Say '���' Get mim Pict '@S32' ;
        valid {| g| valfamimot( 2, mim ) }
      ++j ; @ j, 1 Say '����⢮' Get mot ;
        valid {| g| valfamimot( 3, mot ) }
      If mem_pol == 1
        @ Row(), 70 Say '���' Get mpol ;
          reader {| x| menu_reader( x, menupol, A__MENUVERT, , , .f. ) }
      Else
        @ Row(), 70 Say '���' Get mpol Pict '@!' valid {| g| mpol $ '��' }
      Endif
      ++j
      @ j, 1 Say '��� ஦�����' Get mdate_r ;
        valid {|| fv_date_r( mn_data ), findkartoteka( 1, @mkod_k ) }
      @ Row(), 30 Say '==>' Get mvzros_reb When .f. Color cDataCSay
      @ Row(), 50 Say '�����' Get msnils Pict picture_pf ;
        valid {|| val_snils( msnils, 1 ), findkartoteka( 3, @mkod_k ) }

      @ ++j, 1 Say '��-�� ��筮��:' Get mvid_ud ;
        reader {| x| menu_reader( x, getvidud(), A__MENUVERT, , , .f. ) }
      @ j, 42 Say '����' Get mser_ud Pict '@!' Valid val_ud_ser( 1, m1vid_ud, mser_ud )
      @ j, Col() + 1 Say '�' Get mnom_ud Pict '@!S18' Valid val_ud_nom( 1, m1vid_ud, mnom_ud )
      If tip_lu == TIP_LU_NMP
        ++j
        @ j, 2 Say '���� ஦�����' Get mmesto_r Pict '@S62'
        ++j
        @ j, 2 Say '�뤠��' Get mkogdavyd
        @ j, Col() Say ', ' Get mkemvyd ;
          reader {| x| menu_reader( x, { {| k, r, c| get_s_kemvyd( k, r, c ) } }, A__FUNCTION, , , .f. ) }
      Endif
      ++j
      @ j, 1 Say '���� ॣ����樨' Get madres_reg ;
        reader {| x| menu_reader( x, { {| k, r, c| get_adres( 1, k, r, c ) } }, A__FUNCTION, , , .f. ) }
    Endif
    ++j
    @ j, 1 Say '�ਭ���������� ����' Get mkomu ;
      reader {| x| menu_reader( x, mm_komu, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_komu( g, o ) } ;
      Color colget_menu
    @ Row(), Col() + 1 Say '==>' Get mcompany ;
      reader {| x| menu_reader( x, mm_company, A__MENUVERT, , , .f. ) } ;
      When diag_screen( 2 ) .and. m1komu < 5 ;
      valid {| g| func_valid_ismo( g, m1komu, 38 ) }
    //
    If mem_smp_input == 0
      ++j; @ j, 1 Say '����� ���: ���' Get mspolis When m1komu == 0
      @ Row(), Col() + 3 Say '�����'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 3 Say '���'    Get mvidpolis ;
        reader {| x| menu_reader( x, mm_vid_polis, A__MENUVERT, , , .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
    Endif
    //
    ++j; @ j, 1 Say '����஦�����?' Get mnovor ;
      reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_novor( g, o ) } ;
      Color colget_menu
    @ Row(), Col() + 3 Say '�/�� ॡ񭪠' Get mcount_reb Pict '99' Range 1, 99 ;
      when ( m1novor == 1 )
    @ Row(), Col() + 3 Say '�.�. ॡ񭪠' Get mdate_r2 when ( m1novor == 1 )
    If mem_pol == 1
      @ Row(), Col() + 3 Say '��� ॡ񭪠' Get mpol2 ;
        reader {| x| menu_reader( x, menupol, A__MENUVERT, , , .f. ) } ;
        When diag_screen( 2 ) .and. ( m1novor == 1 )
    Else
      @ Row(), Col() + 3 Say '��� ॡ񭪠' Get mpol2 Pict '@!' ;
        valid {| g| mpol2 $ '��' } ;
        When diag_screen( 2 ) .and. ( m1novor == 1 )
    Endif
    //
    ++j; @ j, 1 Say '�������(�)' Get mkod_diag Picture pic_diag ;
      reader {| o| mygetreader( o, bg ) } ;
      When when_diag() ;
      valid {|| val1_10diag( .t., .t., .t., mk_data, iif( m1novor == 0, mpol, mpol2 ) ), f_valid_beremenn( mkod_diag, mk_data ) }
    @ Row(), Col() Say ', ' Get mkod_diag2 Picture pic_diag ;
      reader {| o| mygetreader( o, bg ) } ;
      When when_diag() ;
      Valid val1_10diag( .t., .t., .t., mn_data, iif( m1novor == 0, mpol, mpol2 ) )
    If tip_lu == TIP_LU_SMP
      @ Row(), Col() + 3 Say '��ଠ �������� ���' Get MF14_EKST ;
        reader {| x| menu_reader( x, mm_ekst_smp, A__MENUVERT, , , .f. ) }
    Endif
    ++j ; rdiag := j
    If ( ibrm := f_oms_beremenn( mkod_diag, MN_DATA ) ) == 1
      @ j, 26 Say '���뢠��� ��६������'
    Elseif ibrm == 2
      @ j, 26 Say '���.����.�� ��६�����'
    Elseif ibrm == 3
      @ j, 26 Say '     ���� �� ���������'
    Endif
    @ j, 51 Get mprer_b ;
      reader {| x| menu_reader( x, mm_prer_b, A__MENUVERT, , , .f. ) } ;
      when {|| diag_screen( 2 ), ;
      ibrm := f_oms_beremenn( mkod_diag, MN_DATA ), ;
      mm_prer_b := iif( ibrm == 1, mm1prer_b, iif( ibrm == 2, mm2prer_b, mm3prer_b ) ), ;
      ( ibrm > 0 ) }
    //
    ++j; @ j, 1 Say '������� ���饭��' Get mrslt ;
      reader {| x| menu_reader( x, mm_rslt, A__MENUVERT, , , .f. ) } ;
      valid {| g, o| f_valid_rslt( g, o ) }
    //
    ++j; @ j, 1 Say '��室 �����������' Get mishod ;
      reader {| x| menu_reader( x, mm_ishod, A__MENUVERT, , , .f. ) }
    //
    If tip_lu == TIP_LU_SMP
      If Empty( mm_trombolit )
        ++j; @ j, 1 Say '�ਣ��� ���' Get mbrig ;
          reader {| x| menu_reader( x, mm_brig, A__MENUVERT, , , .f. ) }
      Else
        ++j; @ j, 1 Say '�஬������᪠� �࠯��:' Get mtip ;
          reader {| x| menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) } ;
          valid {| g, o| f_valid_brig( g, o, mm_brigada, mm_trombolit, st_brigada, st_trombolit ) }
        @ j, 32 Say '�ਣ��� ���' Get mbrig ;
          reader {| x| menu_reader( x, mm_brig, A__MENUVERT, , , .f. ) }
      Endif
      If mem_smp_tel == 1
        ++j; @ j, 1 Say '��㣠(�) ⥫�����樭�' Get musluga ;
          reader {| x| menu_reader( x, mm_usluga, A__MENUBIT, , , .f. ) }
      Endif
    Else
      ++j; @ j, 1 Say '��� (䥫���)' Get mspec ;
        reader {| x| menu_reader( x, mm_spec, A__MENUVERT, , , .f. ) }
    Endif
    //
    ++j; @ j, 1 Say '���.� ��� (䥫���)' Get MTAB_NOM Pict '99999' ;
      valid {| g| v_kart_vrach( g, .t. ) } When diag_screen( 2 )
    @ Row(), Col() + 1 Get mvrach When .f. Color color14
    If !Empty( a_smert )
      n_message( a_smert, , 'GR+/R', 'W+/R', , , 'G+/R' )
    Endif
    If pos_read > 0 .and. Lower( GetList[ pos_read ]:name ) == 'mvrach'
      --pos_read
    Endif
    count_edit := myread(, @pos_read, ++k_read )
    diag_screen( 2 )
    k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
      { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
      iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' )
    If k == 3
      Loop
    Elseif k == 2
      If Empty( much_doc )
        func_error( 4, '�� �������� ����� �����' + iif( tip_lu == TIP_LU_SMP, ' �맮��', '' ) )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, '�� ������� ��� ' + iif( tip_lu == TIP_LU_SMP, '�륧��.', '���.' ) )
        Loop
      Elseif tip_lu == TIP_LU_SMP .and. Year( mn_data ) < 2016 .and. m1tip == 1
        func_error( 4, '�஬������᪠� �࠯�� ࠧ�襭� ⮫쪮 � 2016 ����.' )
        Loop
      Endif
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0     ; s := '���'
        Elseif m1komu == 1 ; s := '��������'
        else               ; s := '������/��'
        Endif
        func_error( 4, '�� ��������� ������������ ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, '�� �������� ����� �����' )
        Loop
      Endif
      If mem_smp_input == 1
        If Empty( mfio )
          func_error( 4, '�� ������� �.�.�. ��� �����!' )
          Loop
        Endif
        If Empty( mdate_r )
          func_error( 4, '�� ��������� ��� ஦�����' )
          Loop
        Endif
        If tip_lu == TIP_LU_NMP .and. eq_any( m1vid_ud, 3, 14 ) .and. ;
            !Empty( mser_ud ) .and. Empty( del_spec_symbol( mmesto_r ) )
          func_error( 4, iif( m1vid_ud == 3, '��� ᢨ�-�� � ஦�����', '��� ��ᯮ�� ��' ) + ;
            ' ��易⥫쭮 ���������� ���� "���� ஦�����"' )
          Loop
        Endif
      Endif
      If Empty( mkod_diag )
        func_error( 4, '�� ������ ��� �᭮����� �����������.' )
        Loop
      Endif
      err_date_diap( mn_data, '��� �륧��' )
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait()
      make_diagp( 2 )  // ᤥ���� '��⨧����' ��������
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ''
        m1str_crb := m1company
      Endif
      Private old_vzros_reb := M1VZROS_REB
      fv_date_r( MN_DATA ) // ��८�।������ M1VZROS_REB
      If tip_lu == TIP_LU_SMP // ��।��塞 ��� ��㣨 ���
        lshifr := '71.'
        If m1tip == 0
          If ( is_komm_smp() .and. mk_data < 0d20190501 ) .or. ( is_komm_smp() .and. mk_data >= 0d20220101 )// �᫨ �� �������᪠� ᪮��
            lshifr += '2.'
          Elseif m1komu == 0
            If Len( AllTrim( msmo ) ) == 5 .and. Left( msmo, 2 ) == '34'
              lshifr += '1.'
            Else
              lshifr += '2.'
            Endif
          Else
            lshifr += '1.'
          Endif
          lshifr += m1brig
          st_brigada := m1brig
        Else // �஬������᪠� �࠯��
          lshifr += '3.' + m1brig
          st_trombolit := m1brig
          M1F14_EKST := 1 // ���७���
        Endif
      Else // ��।��塞 ��� ��㣨 ���
        lshifr := iif( m1spec == 1, '2.80.27', '2.80.28' )
      Endif
      lshifr := PadR( lshifr, 10 )
      //
      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server + 'uslugi1', { dir_server + 'uslugi1', ;
        dir_server + 'uslugi1s' }, 'USL1' )
      Private mu_kod, mu_cena
      glob_podr := '' ; glob_otd_dep := 0
      mu_kod := foundourusluga( lshifr, mk_data, m1PROFIL, M1VZROS_REB, @mu_cena )
      If mem_smp_input == 1
        mfio := RTrim( mfam ) + ' ' + RTrim( mim ) + ' ' + mot
        If twowordfamimot( mfam ) .or. twowordfamimot( mim ) .or. twowordfamimot( mot )
          newMEST_INOG := 9
        Endif
        use_base( 'kartotek' )
        If mkod_k == 0  // ���������� � ����⥪�
          add1rec( 7 )
          glob_kartotek := mkod_k := kart->kod := RecNo()
        Else
          find ( Str( mkod_k, 7 ) )
          If Found()
            g_rlock( forever )
          Else
            add1rec( 7 )
            glob_kartotek := mkod_k := kart->kod := RecNo()
          Endif
        Endif
        glob_k_fio := AllTrim( mfio )
        //
        kart->FIO       := mfio
        kart->pol       := mpol
        kart->DATE_R    := mdate_r
        kart->VZROS_REB := old_vzros_reb
        kart->ADRES     := mADRES
        kart->POLIS     := make_polis( mspolis, mnpolis ) // ��� � ����� ���客��� �����
        kart->snils     := msnils
        kart->KOMU      := m1KOMU
        kart->STR_CRB   := m1str_crb
        kart->MI_GIT    := 9
        kart->MEST_INOG := newMEST_INOG
        //
        Select KART2
        Do While kart2->( LastRec() ) < mkod_k
          Append Blank
        Enddo
        //
        Select KART_
        Do While kart_->( LastRec() ) < mkod_k
          Append Blank
        Enddo
        Goto ( mkod_k )
        g_rlock( forever )
        kart_->VPOLIS := m1vidpolis
        kart_->SPOLIS := mSPOLIS
        kart_->NPOLIS := mNPOLIS
        kart_->SMO    := msmo
        kart_->vid_ud := m1vid_ud
        kart_->ser_ud := mser_ud
        kart_->nom_ud := mnom_ud
        If tip_lu == TIP_LU_NMP
          kart_->mesto_r  := mmesto_r
          kart_->kemvyd   := m1kemvyd
          kart_->kogdavyd := mkogdavyd
        Endif
        kart_->okatog := mokatog
        Private fl_nameismo := .f.
        If m1komu == 0 .and. m1company == 34
          kart_->KVARTAL_D := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
          If Empty( m1ismo )
            If !Empty( mnameismo )
              fl_nameismo := .t.
            Endif
          Else
            kart_->SMO := m1ismo  // �����塞 '34' �� ��� �����த��� ���
          Endif
        Endif
        If m1MEST_INOG == 9 .or. newMEST_INOG == 9
          g_use( dir_server + 'mo_kfio', , 'KFIO' )
          Index On Str( kod, 7 ) to ( cur_dir + 'tmp_kfio' )
          find ( Str( mkod_k, 7 ) )
          If Found()
            If newMEST_INOG == 9
              g_rlock( forever )
              kfio->FAM := mFAM
              kfio->IM  := mIM
              kfio->OT  := mOT
            Else
              deleterec( .t. )
            Endif
          Else
            If newMEST_INOG == 9
              addrec( 7 )
              kfio->kod := mkod_k
              kfio->FAM := mFAM
              kfio->IM  := mIM
              kfio->OT  := mOT
            Endif
          Endif
        Endif
        If fl_nameismo .or. rec_inogSMO > 0
          g_use( dir_server + 'mo_kismo', , 'SN' )
          Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
          find ( Str( mkod_k, 7 ) )
          If Found()
            If fl_nameismo
              g_rlock( forever )
              sn->smo_name := mnameismo
            Else
              deleterec( .t. )
            Endif
          Else
            If fl_nameismo
              addrec( 7 )
              sn->kod := mkod_k
              sn->smo_name := mnameismo
            Endif
          Endif
          sn->( dbCloseArea() )
        Endif
      Endif
      use_base( 'human' )
      If Loc_kod > 0
        find ( Str( Loc_kod, 7 ) )
        mkod := Loc_kod
        g_rlock( forever )
      Else
        add1rec( 7 )
        mkod := RecNo()
        Replace human->kod With mkod
      Endif
      Select HUMAN_
      Do While human_->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      Select HUMAN_2
      Do While human_2->( LastRec() ) < mkod
        Append Blank
      Enddo
      Goto ( mkod )
      g_rlock( forever )
      //
      If IsBit( mem_oms_pole, 1 )  // '�ப� ��祭��', ;  1
        st_N_DATA := MN_DATA
      Endif
      If IsBit( mem_oms_pole, 2 )  // '���.���', ;       2
        st_VRACH := m1vrach
      Endif
      If IsBit( mem_oms_pole, 3 )  // '��.�������', ;    3
        SKOD_DIAG := SubStr( MKOD_DIAG, 1, 5 )
      Endif
      If IsBit( mem_oms_pole, 5 )  // '१����', ;      5
        st_RSLT := m1rslt
      Endif
      If IsBit( mem_oms_pole, 6 )  // '��室', ;          6
        st_ISHOD := m1ishod
      Endif
      st_brigada := m1brigada
      glob_perso := mkod
      //
      human->kod_k      := mkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->KOD_DIAG   := MKOD_DIAG     // ��� 1-�� ��.�������
      human->KOD_DIAG2  := MKOD_DIAG2    // ��� 2-�� ��.�������
      human->KOD_DIAG3  := MKOD_DIAG3    // ��� 3-�� ��.�������
      human->KOD_DIAG4  := MKOD_DIAG4    // ��� 4-�� ��.�������
      human->SOPUT_B1   := MSOPUT_B1     // ��� 1-�� ᮯ������饩 �������
      human->SOPUT_B2   := MSOPUT_B2     // ��� 2-�� ᮯ������饩 �������
      human->SOPUT_B3   := MSOPUT_B3     // ��� 3-�� ᮯ������饩 �������
      human->SOPUT_B4   := MSOPUT_B4     // ��� 4-�� ᮯ������饩 �������
      human->diag_plus  := mdiag_plus    //
      human->KOMU       := M1KOMU        // �� 0 �� 5
      human_->SMO       := msmo
      human->STR_CRB    := m1str_crb
      human->POLIS      := make_polis( mspolis, mnpolis ) // ��� � ����� ���客��� �����
      human->LPU        := M1LPU         // ��� ��०�����
      human->OTD        := M1OTD         // ��� �⤥�����
      human->UCH_DOC    := lstr( MUCH_DOC ) // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA := human->K_DATA := MN_DATA // ��� ��砫�-����砭�� ��祭��
      human->CENA := human->CENA_1 := mu_cena // �⮨����� ��祭��
      human_->DISPANS   := Replicate( '0', 16 )
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := iif( m1novor == 0, 0, mcount_reb )
      human_->DATE_R2   := iif( m1novor == 0, CToD( '' ), mDATE_R2  )
      human_->POL2      := iif( m1novor == 0, '', mpol2     )
      human_->USL_OK    := m1USL_OK // 4
      human_->VIDPOM    := m1VIDPOM // 2
      human_->PROFIL    := m1PROFIL // 84
      human_->IDSP      := m1IDSP   // 24
      human_->FORMA14   := Str( M1F14_EKST, 1 ) + '000'
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod
      human_->VRACH     := m1vrach
      human_->PRVS      := m1prvs
      human_->OPLATA    := 0 // 㡥�� '2', �᫨ ��।���஢��� ������ �� ॥��� �� � ��
      human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
      If Loc_kod == 0  // �� ����������
        human_->ID_PAC    := mo_guid( 1, human_->( RecNo() ) )
        human_->ID_C      := mo_guid( 2, human_->( RecNo() ) )
        human_->SUMP      := 0
        human_->SANK_MEK  := 0
        human_->SANK_MEE  := 0
        human_->SANK_EKMP := 0
        human_->REESTR    := 0
        human_->REES_ZAP  := 0
        human->schet      := 0
        human_->SCHET_ZAP := 0
        human->kod_p   := kod_polzovat    // ��� ������
        human->date_e  := c4sys_date
      Else // �� ।���஢�����
        human_->kod_p2  := kod_polzovat    // ��� ������
        human_->date_e2 := c4sys_date
      Endif
      put_0_human_2()
      If f_oms_beremenn( mkod_diag, MN_DATA ) > 0
        human_2->PN2 := m1prer_b
      Endif
      Private fl_nameismo := .f.
      If m1komu == 0 .and. m1company == 34
        human_->OKATO := m1okato // ����� ��ꥪ� �� ����ਨ ���客����
        If Empty( m1ismo )
          If !Empty( mnameismo )
            fl_nameismo := .t.
          Endif
        Else
          human_->SMO := m1ismo  // �����塞 '34' �� ��� �����த��� ���
        Endif
      Endif
      If fl_nameismo .or. rec_inogSMO > 0
        g_use( dir_server + 'mo_hismo', , 'SN' )
        Index On Str( kod, 7 ) to ( cur_dir + 'tmp_ismo' )
        find ( Str( mkod, 7 ) )
        If Found()
          If fl_nameismo
            g_rlock( forever )
            sn->smo_name := mnameismo
          Else
            deleterec( .t. )
          Endif
        Else
          If fl_nameismo
            addrec( 7 )
            sn->kod := mkod
            sn->smo_name := mnameismo
          Endif
        Endif
      Endif
      use_base( 'human_u' )
      Select HU
      If mrec_hu == 0
        add1rec( 7 )
        mrec_hu := hu->( RecNo() )
      Else
        Goto ( mrec_hu )
        g_rlock( forever )
      Endif
      Replace hu->kod     With human->kod, ;
        hu->kod_vr  With m1vrach, ;
        hu->kod_as  With 0, ;
        hu->u_koef  With 1, ;
        hu->u_kod   With mu_kod, ;
        hu->u_cena  With mu_cena, ;
        hu->is_edit With 0, ;
        hu->date_u  With dtoc4( MK_DATA ), ;
        hu->otd     With m1otd, ;
        hu->kol     With 1, ;
        hu->stoim   With mu_cena, ;
        hu->kol_1   With 1, ;
        hu->stoim_1 With mu_cena, ;
        hu->KOL_RCP With 0
      Select HU_
      Do While hu_->( LastRec() ) < mrec_hu
        Append Blank
      Enddo
      Goto ( mrec_hu )
      g_rlock( forever )
      If Loc_kod == 0 .or. !valid_guid( hu_->ID_U )
        hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
      Endif
      hu_->PROFIL   := m1PROFIL
      hu_->PRVS     := m1PRVS
      hu_->kod_diag := mkod_diag
      hu_->zf       := ''
      //
      If mem_smp_tel == 1 .and. ( Len( arr_usluga ) > 0 .or. m1usluga > 0 )
        For i := 1 To 2
          j := AScan( arr_usluga, {| x| x[ 1 ] == i } )
          If IsBit( m1usluga, i )
            If j == 0
              AAdd( arr_usluga, { i, 0 } )
            Endif
          Else
            If j > 0
              arr_usluga[ j, 1 ] := 0
            Endif
          Endif
        Next
        use_base( 'luslf' )
        use_base( 'mo_su' )
        use_base( 'mo_hu' )
        For i := 1 To Len( arr_usluga )
          If arr_usluga[ i, 1 ] > 0
            kod_uslf := 0
            lshifr := iif( arr_usluga[ i, 1 ] == 1, 'A05.10.004.001', 'B01.015.007' )
            Select MOSU
            Set Order To 3 // �� ���� �����
            find ( PadR( lshifr, 20 ) )
            If Found()
              kod_uslf := mosu->kod
            Else
              Select LUSLF
              find ( PadR( lshifr, 20 ) )
              If Found()
                Select MOSU
                Set Order To 1
                find ( Str( -1, 6 ) )
                If Found()
                  g_rlock( forever )
                Else
                  addrec( 6 )
                Endif
                kod_uslf := mosu->kod := RecNo()
                mosu->name := luslf->name
                mosu->shifr1 := lshifr
                mosu->PROFIL := 0
              Endif
            Endif
            If !Empty( kod_uslf )
              Select MOHU
              If arr_usluga[ i, 2 ] > 0
                Goto ( arr_usluga[ i, 2 ] )
                g_rlock( forever )
              Else
                add1rec( 7 )
              Endif
              mohu->kod     := human->kod
              mohu->kod_vr  := 0
              mohu->u_kod   := kod_uslf
              mohu->u_cena  := 0
              mohu->date_u  := dtoc4( MK_DATA )
              mohu->date_u2 := dtoc4( MK_DATA )
              mohu->otd     := m1otd
              mohu->kol_1   := 1
              mohu->stoim_1 := 0
              mohu->ID_U    := mo_guid( 4, mohu->( RecNo() ) )
              mohu->PROFIL  := m1PROFIL
              mohu->PRVS    := m1PRVS
              mohu->kod_diag := mkod_diag
            Endif
          Else
            Select MOHU
            If arr_usluga[ i, 2 ] > 0
              Goto ( arr_usluga[ i, 2 ] )
              deleterec( .t. )
            Endif
          Endif
        Next i
      Endif
      //
      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases
      stat_msg( '������ �����襭�!', .f. )
    Endif
    Exit
  Enddo
  Close databases
  diag_screen( 2 )
  SetColor( tmp_color )
  RestScreen( buf )
  chm_help_code := tmp_help
  If fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    If Type( 'fl_edit_smp' ) == 'L'
      fl_edit_smp := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  Return Nil

// * 16.11.22 ����⢨� � �⢥� �� �롮� � ���� "�஬������᪠� �࠯��:"
Function f_valid_brig( get, old, menu1, menu2, st1, st2 )

  If m1tip != old .and. old != NIL
    mm_brig := {}
    If m1tip == 0 //
      mm_brig := AClone( menu1 )
      m1brig := st1
    Else
      mm_brig := AClone( menu2 )
      m1brig := st2
    Endif
    mbrig := PadR( inieditspr( A__MENUVERT, mm_brig, m1brig ), 40 )
    update_get( 'mbrig' )
  Endif

  Return .t.
