#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  // 
#define DGZ 'Z00.8 '  //
#define FIRST_LETTER 'Z'  //

// 04.06.24 ��ᯭ�ਧ��� ९த�⨢���� ���஢�� ���᫮�� ��ᥫ���� - ���������� ��� ।���஢���� ���� (���� ���)
function oms_sluch_dvn_drz( loc_kod, kod_kartotek, f_print )
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  // f_print - ������������ �㭪樨 ��� ����

  Static sadiag1
  Static st_N_DATA, st_K_DATA, s1dispans := 1
  
  local arr_del := {}, mrec_hu := 0, mrec_mohu := 0, ;
      buf := savescreen(), tmp_color := setcolor(), a_smert := {}, ;
      p_uch_doc := '@!', pic_diag := '@K@!', arr_usl := {}, ;
      colget_menu := 'R/W', colgetImenu := 'R/BG', ;
      pos_read := 0, k_read := 0, count_edit := 0, ;
      fl, fl_write_sluch := .f., lrslt_1_etap := 0

  local iUslDop := 0, iUslOtklon := 0, iUslNeNazn := 0   // ���稪�
  local sk, i, j, k, s, ah, ar, larr, lu_kod, mu_cena
  local lenArr_Uslugi_DRZ
  local str_1, hS, wS
  local nAge, nGender
  local lUziMatkiAbdomin := .f., lUziMatkiTransvag := .f., lAllneNazn := .t.
  local lCitIsl := .f., lGidCitIsl := .f.
  local uslugi_etapa, fl_shapka_osmotr := .f.
  local fl_diag
  local arr_usl_dop := {}
  local lshifr
  local indSource := 0, indDest := 0
  local i_otkaz   // ����������� �⪠�� �� ��㣨 (0 - ���, 1 - ��)
  local view_uslugi
  local mdef_diagnoz
  local mm_gruppa
  local mm_gruppaD1 := { ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� I ��㯯� ९த�⨢���� ���஢��', 1, 375 }, ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� II ��㯯� ९த�⨢���� ���஢��', 2, 376 }, ;
    { '�஢����� ��ᯠ��ਧ��� - ��᢮��� III ��㯯� ९த�⨢���� ���஢��', 3, 377 }, ;
    { '���ࠢ��� �� II �⠯, �।���⥫쭮 ��᢮��� II ��㯯� ९த�⨢���� ���஢��', 11, 378 }, ;
    { '���ࠢ��� �� II �⠯, �।���⥫쭮 ��᢮��� III ��㯯� ९த�⨢���� ���஢��', 12, 379 } ;
  }
  local mm_gruppaD2 := asize( aclone( mm_gruppaD1 ), 3 )  // ��� II �⠯� 㬥��訬 �᫮ �-⮢ ᯨ᪠

  //
  Default st_N_DATA TO sys_date, st_K_DATA TO sys_date
  Default loc_kod TO 0, kod_kartotek TO 0
  //
  private arr_ne_nazn := {}
  Private ps1dispans := s1dispans, is_prazdnik

  Private mfio := space( 50 ), mpol, mdate_r, mvozrast, ;
    M1VZROS_REB, MVZROS_REB, m1novor := 0, ;
    m1company := 0, mcompany, mm_company, ;
    mkomu, M1KOMU := 0, M1STR_CRB := 0, ; // 0-���,1-��������,3-�������/���,5-���� ���
    msmo := '34007', rec_inogSMO := 0, ;
    madres, mokato, m1okato := '', mismo, m1ismo := '', mnameismo := space( 100 ), ;
    mvidpolis, m1vidpolis := 1, mspolis := space( 10 ), mnpolis := space( 20 )
  Private mkod := Loc_kod, is_talon := .f., mshifr_zs := '', ;
    mkod_k := kod_kartotek, fl_kartotek := ( kod_kartotek == 0 ), ;
    M1LPU := glob_uch[ 1 ], MLPU, ;
    M1OTD := glob_otd[ 1 ], MOTD, ;
    M1FIO_KART := 1, MFIO_KART, ;
    MRAB_NERAB, M1RAB_NERAB := 0, ; // 0-ࠡ���騩, 1 -��ࠡ���騩
    MUCH_DOC    := space( 10 ), ; // ��� � ����� ��⭮�� ���㬥��
    MKOD_DIAG   := space( 5 ), ; // ��� 1-�� ��.�������
    MKOD_DIAG2  := space( 5 ), ; // ��� 2-�� ��.�������
    MKOD_DIAG3  := space( 5 ), ; // ��� 3-�� ��.�������
    MKOD_DIAG4  := space( 5 ), ; // ��� 4-�� ��.�������
    MSOPUT_B1   := space( 5 ), ; // ��� 1-�� ᮯ������饩 �������
    MSOPUT_B2   := space( 5 ), ; // ��� 2-�� ᮯ������饩 �������
    MSOPUT_B3   := space( 5 ), ; // ��� 3-�� ᮯ������饩 �������
    MSOPUT_B4   := space( 5 ), ; // ��� 4-�� ᮯ������饩 �������
    MDIAG_PLUS  := space( 8 ), ; // ���������� � ���������
    adiag_talon[16], ; // �� ���⠫��� � ���������
    MN_DATA := st_N_DATA, ; // ��� ��砫� ��祭��
    MK_DATA := st_K_DATA, ; // ��� ����砭�� ��祭��
    MVRACH := space( 10 ), ; // 䠬���� � ���樠�� ���饣� ���
    M1VRACH := 0, MTAB_NOM := 0, m1prvs := 0, ; // ���, ⠡.� � ᯥ�-�� ���饣� ���
    m1povod  := 4, ;   // ��䨫����᪨�
    m1USL_OK := USL_OK_POLYCLINIC, ; // �����������
    m1VIDPOM :=  1, ; // ��ࢨ筠�
    m1PROFIL := 97, ; // 97-�࠯��,57-���� ���.�ࠪ⨪� (ᥬ���.���-�),42-��祡��� ����
    mcena_1 := 0

  private ; // 
    m1ishod := 306, ;  // ��室 = �ᬮ��
    m1rslt  := 375     // १���� (��᢮��� I ��㯯� ���஢�� ९த�⨢���� ���஢��) �ࠢ�筨� V009
//
  Private arr_otklon := {}
  Private m1p_otk := 0
  Private metap := 1,;  // 1-���� �⠯, 2-��ன �⠯ (�� 㬮�砭�� 1 �⠯)
    mnapr_onk := space( 10 ), m1napr_onk := 0, ;
    mgruppa, m1gruppa := 1      // ��㯯� ���஢��
  Private mdispans, m1dispans := 0, mnazn_l , m1nazn_l  := 0, ;
    mdopo_na, m1dopo_na := 0, mssh_na , m1ssh_na  := 0, ;
    mspec_na, m1spec_na := 0, msank_na, m1sank_na := 0

  Private m1NAPR_MO, mNAPR_MO, mNAPR_DATE, mNAPR_V, m1NAPR_V, mMET_ISSL, m1MET_ISSL, ;
    mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0, ;
    mTab_Number := 0

  // Private mm_napr_v := {{'���', 0}, ;
  //   {'� ��������', 1}, ;
  //   {'�� ����᫥�������', 3}}
  // /*Private mm_napr_v := {{'���', 0}, ;
  //   {'� ��������', 1}, ;
  //   {'�� ������', 2}, ;
  //   {'�� ����᫥�������', 3}, ;
  //   {'��� ��।���� ⠪⨪� ��祭��', 4}}*/
  // Private mm_met_issl := {{'���', 0}, ;
  //     {'������ୠ� �������⨪�', 1}, ;
  //     {'�����㬥�⠫쭠� �������⨪�', 2}, ;
  //     {'��⮤� ��祢�� �������⨪� (����ண����騥)', 3}, ;
  //     {'��ண����騥 ��⮤� ��祢�� �������⨪�', 4}}

  Private mDS_ONK, m1DS_ONK := 0 // �ਧ��� �����७�� �� �������⢥���� ������ࠧ������

  Private mvar, m1var // ��६���� ��� �࣠����樨 ����� ��-樨 � ⠡��筮� ���
  Private mm_ndisp := { ;
                        { '��ᯠ��ਧ��� ९த�⨢���� ���஢�� I �⠯', 1 }, ;
                        { '��ᯠ��ਧ��� ९த�⨢���� ���஢�� II �⠯', 2 } ;
                      }

  Private mm_pervich := arr_mm_pervich()
  Private mm_dispans := arr_mm_dispans()
  Private mm_dopo_na := arr_mm_dopo_na()
  Private gl_arr := { ;  // ��� ��⮢�� �����
    { 'dopo_na', 'N', 10, 0, , , , { | x | inieditspr( A__MENUBIT, mm_dopo_na, x ) } } ;
  }
  Private mnapr_v_mo, m1napr_v_mo := 0, mm_napr_v_mo := arr_mm_napr_v_mo(), ;
    arr_mo_spec := {}, ma_mo_spec, m1a_mo_spec := 1
  Private mnapr_stac, m1napr_stac := 0, mm_napr_stac := arr_mm_napr_stac(), ;
    mprofil_stac, m1profil_stac := 0
  Private mnapr_reab, m1napr_reab := 0, mprofil_kojki, m1profil_kojki := 0

  private mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

  Private mshifr, mshifr1, mname_u, mU_KOD, cur_napr := 0, count_napr := 0, tip_onko_napr := 0

  Private pole_diag, pole_pervich, pole_1pervich, pole_d_diag, ;
    pole_stadia, pole_dispans, pole_1dispans, pole_d_dispans, pole_dn_dispans

  if kod_kartotek == 0 // ���������� � ����⥪�
    if ( kod_kartotek := edit_kartotek( 0, , , .t. ) ) == 0
      return NIL
    endif
  elseif loc_kod > 0
    R_Use( dir_server + 'human', , 'HUMAN' )
    goto (Loc_kod)
    fl := (human->k_data < 0d20240101)
    Use
    if fl
      return func_error( 4, '��ᯠ��ਧ��� ९த�⨢���� ���஢�� ��砫��� 01 ﭢ��� 2024 ����.' )
    endif
  endif

  for i := 1 to 5 // ᮧ����� �ਢ��� ��६���� ��� ������� ���������
    sk := lstr( i )
    pole_diag := 'mdiag' + sk
    pole_d_diag := 'mddiag' + sk
    pole_pervich := 'mpervich' + sk
    pole_1pervich := 'm1pervich' + sk
    pole_stadia := 'm1stadia' + sk
    pole_dispans := 'mdispans' + sk
    pole_1dispans := 'm1dispans' + sk
    pole_d_dispans := 'mddispans' + sk
    pole_dn_dispans := 'mdndispans' + sk
    Private &pole_diag := space( 6 )
    Private &pole_d_diag := ctod( '' )
    Private &pole_pervich := space( 7 )
    Private &pole_1pervich := 0
    Private &pole_stadia := 1
    Private &pole_dispans := space( 10 )
    Private &pole_1dispans := 0
    Private &pole_d_dispans := ctod( '' )
    Private &pole_dn_dispans := ctod( '' )
  next

  for i := 1 to len( ret_array_drz() )  // ᮧ����� ���� ����� ��� ��� ��������� ��� ��ᯠ��ਧ�樨
    mvar := 'MTAB_NOMv' + lstr( i )
    Private &mvar := 0
    mvar := 'MTAB_NOMa' + lstr( i )
    Private &mvar := 0
    mvar := 'MDATE'+lstr( i )
    Private &mvar := ctod( '' )
    mvar := 'MKOD_DIAG' + lstr( i )
    Private &mvar := space( 6 )
    mvar := 'MOTKAZ' + lstr( i )
    Private &mvar := substr( arr_mm_result_drz( metap )[ 1, 1 ], 1, 10 )
    mvar := 'M1OTKAZ' + lstr( i )
    Private &mvar := arr_mm_result_drz( metap )[ 1, 2 ]
  next
  // 
  afill( adiag_talon, 0 )

  R_Use( dir_server + 'human_2', , 'HUMAN_2' )
  R_Use( dir_server + 'human_', , 'HUMAN_' )
  R_Use( dir_server + 'human', , 'HUMAN' )
  set relation to recno() into HUMAN_, to recno() into HUMAN_2

  if mkod_k > 0
    R_Use( dir_server + 'kartote2', , 'KART2' )
    goto ( mkod_k )
    R_Use( dir_server + 'kartote_', , 'KART_' )
    goto ( mkod_k )
    R_Use( dir_server + 'kartotek', , 'KART' )
    goto ( mkod_k )
    M1FIO       := 1
    mfio        := kart->fio
    mpol        := kart->pol
    mdate_r     := kart->date_r
    M1VZROS_REB := kart->VZROS_REB
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    m1okato     := kart_->KVARTAL_D    // ����� ��ꥪ� �� ����ਨ ���客����
    msmo        := kart_->SMO
    m1MO_PR     := kart2->MO_PR

//    nAge := count_years( mdate_r, mn_data )
    nAge := Year( mn_data ) - Year( mdate_r ) // �᫮ ��� �� �६� �஢������ ���
    nGender := mpol
  
    if kart->MI_GIT == 9
      m1komu    := kart->KOMU
      m1str_crb := kart->STR_CRB
    endif
    if eq_any( is_uchastok, 1, 3 )
      MUCH_DOC := padr( amb_kartaN(), 10 )
    elseif mem_kodkrt == 2
      MUCH_DOC := padr( lstr( mkod_k ), 10 )
    endif
    if alltrim( msmo ) == '34'
      mnameismo := ret_inogSMO_name( 1, , .t. ) // ������ � �������
    endif
    // �஢�ઠ ��室� = ������
    ah := {}
    select HUMAN
    set index to (dir_server + 'humankk' )
    find ( str( mkod_k, 7 ) )
    do while human->kod_k == mkod_k .and. !eof()
      if human_->oplata != 9 .and. human_->NOVOR == 0 .and. recno() != Loc_kod
        if is_death( human_->RSLT_NEW ) .and. empty( a_smert )
          a_smert := { '����� ���쭮� 㬥�!', ;
                      '��祭�� � ' + full_date( human->N_DATA ) + ' �� ' + full_date( human->K_DATA ) }
        endif
        if between( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 )
          aadd( ah, { human->(recno() ), human->K_DATA } )
        endif
      endif
      select HUMAN
      skip
    enddo
    set index to
    if len( ah ) > 0
      asort( ah, , , { | x, y | x[ 2 ] < y[ 2 ] } )
      select HUMAN
      goto (atail( ah )[ 1 ] )
      M1RAB_NERAB := human->RAB_NERAB // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
      letap := human->ishod - BASE_ISHOD_RZD
      if eq_any( letap, 1, 2 )
        lrslt_1_etap := human_->RSLT_NEW
      endif
    endif
  endif

  if Loc_kod > 0  // �⠥� ���ଠ�� �� HUMAN, HUMAN_U � MO_HU � �������� ⠡����� ����
    select HUMAN
    goto ( Loc_kod )
    M1LPU       := human->LPU
    M1OTD       := human->OTD
    M1FIO       := 1
    mfio        := human->fio
    mpol        := human->pol
    mdate_r     := human->date_r
    MTIP_H      := human->tip_h
    M1VZROS_REB := human->VZROS_REB
    MADRES      := human->ADRES         // ���� ���쭮��
    MMR_DOL     := human->MR_DOL        // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
    M1RAB_NERAB := human->RAB_NERAB     // 0-ࠡ���騩, 1-��ࠡ���騩, 2-������.����
    mUCH_DOC    := human->uch_doc
    m1VRACH     := human_->vrach
    MPOLIS      := human->POLIS         // ��� � ����� ���客��� �����
    m1VIDPOLIS  := human_->VPOLIS
    mSPOLIS     := human_->SPOLIS
    mNPOLIS     := human_->NPOLIS

    if human->OBRASHEN == '1'
      m1DS_ONK := 1
    endif

//    nAge := count_years( mdate_r, mn_data )
    nAge := Year( mn_data ) - Year( mdate_r ) // �᫮ ��� �� �६� �஢������ ���
    nGender := mpol
  
    if empty( val( msmo := human_->SMO ) )
      m1komu := human->KOMU
      m1str_crb := human->STR_CRB
    else
      m1komu := m1str_crb := 0
    endif
    m1okato    := human_->OKATO  // ����� ��ꥪ� �� ����ਨ ���客����
    mn_data    := human->N_DATA
    mk_data    := human->K_DATA
    mcena_1    := human->CENA_1
    m1rslt     := human_->RSLT_NEW
    //
    is_prazdnik := ! is_work_day( mn_data )

    metap := human->ishod - BASE_ISHOD_RZD   // ����稬 ��࠭���� �⠯ ��ᯠ��ਧ�樨

    if between( metap, 1, 2 )
      mm_gruppa := { mm_gruppaD1, mm_gruppaD2 }[ metap ]
      if ( i := ascan( mm_gruppa, { | x | x[ 3 ] == m1rslt } ) ) > 0
        m1GRUPPA := mm_gruppa[ i, 2 ]
      endif
    endif
    //
    // �롨ࠥ� ��ଠ�� �� ��㣠�
    uslugi_etapa := uslugietap_drz( metap, nAge, nGender )  // ����稬 ��㣨 �⠯�
    lenArr_Uslugi_DRZ := Len( uslugi_etapa )

    larr := array( 2, lenArr_Uslugi_DRZ )
    arr_usl := {}
    afillall( larr, 0 )
    R_Use( dir_server + 'uslugi', , 'USL')
    R_Use( dir_server + 'mo_su', , 'MOSU')
    use_base( 'mo_hu' )
    use_base( 'human_u' )

    // ᭠砫� �롥६ ���ଠ�� �� human_u �� ��㣠� �����
    find ( str( Loc_kod, 7 ) )
    do while hu->kod == Loc_kod .and. !eof()
      usl->( dbGoto( hu->u_kod ) )
      if empty( lshifr := opr_shifr_TFOMS( usl->shifr1, usl->kod, mk_data ) )
        lshifr := usl->shifr
      endif
      lshifr := alltrim( lshifr )
      for i := 1 to lenArr_Uslugi_DRZ
        if empty( larr[ 1, i ] )
          if valtype( uslugi_etapa[ i, 2 ] ) == 'C' .and. uslugi_etapa[ i, 12 ] == 0  // ��㣠 �����
            if uslugi_etapa[ i, 2 ] == lshifr
              fl := .f.
              larr[ 1, i ] := hu->( recno() )
              larr[ 2, i ] := lshifr
              // arr_usl[i] := hu->(recno())
              aadd( arr_usl, hu->( recno() ) )

              if valtype( uslugi_etapa[ i, 13 ] ) == 'C' .and. ! empty( uslugi_etapa[ i, 13 ] )
                select MOHU
                set relation to u_kod into MOSU 
                find ( str( Loc_kod, 7 ) )
                do while MOHU->kod == Loc_kod .and. ! eof()
                  MOSU->( dbGoto( MOHU->u_kod ) )
                  lshifr := alltrim( iif( empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )
                  if lshifr == uslugi_etapa[ i, 13 ]
                    aadd( arr_usl, MOHU->( recno() ) )
                  endif
                  select MOHU
                  skip
                enddo
                SELECT HU
              endif
            endif
          endif
        endif
      next
      select HU
      skip
    enddo

    // ��⥬ �롥६ ���ଠ�� �� mo_hu �� ��㣠� �����
    select MOHU
    set relation to u_kod into MOSU 
    find ( str( Loc_kod, 7 ) )
    do while MOHU->kod == Loc_kod .and. ! eof()
      MOSU->( dbGoto( MOHU->u_kod ) )
      lshifr := alltrim( iif( empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )

      for i := 1 to lenArr_Uslugi_DRZ // len( uslugi_etapa )
        if empty( larr[ 1, i ] )
          if valtype( uslugi_etapa[ i, 2 ] ) == 'C' .and. uslugi_etapa[ i, 12 ] == 1  // ��㣠 �����
            if uslugi_etapa[ i, 2 ] == lshifr
              fl := .f.
              larr[ 1, i ] := MOHU->( recno() )
              larr[ 2, i ] := lshifr
              aadd( arr_usl, MOHU->( recno() ) )
            endif
          endif
        endif
      next
      select MOHU
      skip
    enddo

    // ������� ��㣨 �� �����������
    for i := 1 to lenArr_Uslugi_DRZ
      lshifr := alltrim( uslugi_etapa[ i, 2 ] )
      if ascan( larr[ 2 ], lshifr ) == 0
        larr[ 2, i ] := lshifr
      endif
    next
    //
    R_Use(dir_server + 'mo_pers', , 'P2' )
    read_arr_drz( Loc_kod, .t. )     // �⠥� ��࠭���� ����� �� 㣫㡫����� ��ᯠ��ਧ�樨

    view_uslugi := uslugi_to_view( uslugi_etapa )

    for i := 1 to len( view_uslugi )    // len( larr[ 1 ] )
      if ( j := ascan( larr[ 2 ], view_uslugi[ i, 2 ] ) ) > 0
        if ( valtype( larr[ 2, j ] ) == 'C' ) .and. ( ! eq_any( SubStr( larr[ 2, j ], 1, 1 ), 'A', 'B') )  // �� ��㣠 �����, � �� ����� (���� ᨬ��� �� A,B)
          hu->( dbGoto( larr[ 1, j ] ) )
          if hu->kod_vr > 0
            p2->( dbGoto( hu->kod_vr ) )
            mvar := 'MTAB_NOMv' + lstr( i )
            &mvar := p2->tab_nom
          endif
          if hu->kod_as > 0
            p2->( dbGoto( hu->kod_as ) )
            mvar := 'MTAB_NOMa' + lstr( i )
            &mvar := p2->tab_nom
          endif
          mvar := 'MDATE' + lstr( i )
          &mvar := c4tod( hu->date_u )
          if ! empty( hu_->kod_diag ) .and. ! ( left( hu_->kod_diag, 1 ) == FIRST_LETTER )
            mvar := 'MKOD_DIAG' + lstr( i )
            &mvar := hu_->kod_diag
          endif
          m1var := 'M1OTKAZ' + lstr( i )
          &m1var := 0 // �믮�����
          if valtype( view_uslugi[ i, 2 ] ) == 'C'
            if ascan( arr_otklon, view_uslugi[ i, 2 ] ) > 0
              &m1var := 3 // �믮�����, �����㦥�� �⪫������
            endif
          endif
          if valtype( view_uslugi[ i, 2 ] ) == 'C'
            if ascan( arr_ne_nazn, view_uslugi[ i, 2 ] ) > 0
              &m1var := 4 // �� �����祭�
            endif
          endif
          mvar := 'MOTKAZ' + lstr( i )
          &mvar := substr( inieditspr( A__MENUVERT, arr_mm_result_drz( metap ), &m1var ), 1, 10 )
        elseif ( valtype( larr[ 2, j ] ) == 'C' ) .and. ( eq_any( SubStr( larr[ 2, j ], 1, 1 ), 'A', 'B') )  // �� ��㣠 ����� (���� ᨬ��� A,B)
          MOHU->( dbGoto( larr[ 1, j ] ) )
          if MOHU->kod_vr > 0
            p2->( dbGoto( MOHU->kod_vr ) )
            mvar := 'MTAB_NOMv' + lstr( i )
            &mvar := p2->tab_nom
          endif
          if MOHU->kod_as > 0
            p2->( dbGoto( MOHU->kod_as ) )
            mvar := 'MTAB_NOMa' + lstr( i )
            &mvar := p2->tab_nom
          endif
          mvar := 'MDATE' + lstr( i )
          &mvar := c4tod( MOHU->date_u )
          if ! empty( MOHU->kod_diag ) .and. ! ( left( MOHU->kod_diag, 1 ) == FIRST_LETTER )
            mvar := 'MKOD_DIAG' + lstr( i )
            &mvar := hu_->kod_diag
          endif
          m1var := 'M1OTKAZ' + lstr( i )
          &m1var := 0 // �믮�����
          if valtype( view_uslugi[ i, 2 ] ) == 'C'
            if ascan( arr_otklon, view_uslugi[ i, 2 ] ) > 0
              &m1var := 3 // �믮�����, �����㦥�� �⪫������
            endif
          endif
          if valtype( view_uslugi[ i, 2 ] ) == 'C'
            if ascan( arr_ne_nazn, view_uslugi[ i, 2 ] ) > 0
              &m1var := 4 // �� �����祭�
            endif
          endif
          mvar := 'MOTKAZ' + lstr( i )
          &mvar := substr( inieditspr( A__MENUVERT, arr_mm_result_drz( metap ), &m1var ), 1, 10 )
        endif
      endif
    next
    if alltrim( msmo ) == '34'
      mnameismo := ret_inogSMO_name( 2, @rec_inogSMO, .t. ) // ������ � �������
    endif
    for i := 1 to 5
      f_valid_vyav_diag_dispanser(, i )
    next i
  endif
  if isnil( uslugi_etapa )
    uslugi_etapa := uslugietap_drz( metap, nAge, nGender )  // ����稬 ��㣨 �⠯�
    lenArr_Uslugi_DRZ := Len( uslugi_etapa )
  endif

  if loc_kod == 0 .and. eq_any( lrslt_1_etap, 378, 379 )
    metap := 2
    uslugi_etapa := uslugietap_drz( metap, nAge, nGender )  // ����稬 ��㣨 �⠯�
    lenArr_Uslugi_DRZ := Len( uslugi_etapa )
  endif

  dbcreate(cur_dir + 'tmp_onkna', create_struct_temporary_onkna())
  cur_napr := 1 // �� ।-�� - ᭠砫� ��ࢮ� ���ࠢ����� ⥪�饥
  count_napr := collect_napr_zno( Loc_kod )
  if count_napr > 0
    mnapr_onk := '������⢮ ���ࠢ����� - ' + lstr( count_napr )
  endif

  If !( Left( msmo, 2 ) == '34' ) // �� ������ࠤ᪠� �������
    m1ismo := msmo
    msmo := '34'
  Endif
  is_talon := .t.
  Close databases

  fv_date_r( iif( Loc_kod > 0, mn_data, ) )

  MFIO_KART := _f_fio_kart()
  mndisp    := inieditspr( A__MENUVERT, mm_ndisp, metap )
  mrab_nerab := inieditspr( A__MENUVERT, menu_rab, m1rab_nerab )
  mvzros_reb := inieditspr( A__MENUVERT, menu_vzros, m1vzros_reb )
  mlpu      := inieditspr( A__POPUPMENU, dir_server + 'mo_uch', m1lpu )
  motd      := inieditspr( A__POPUPMENU, dir_server + 'mo_otd', m1otd )
  mvidpolis := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
  mokato    := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
  mkomu     := inieditspr( A__MENUVERT, mm_komu, m1komu )
  mismo     := init_ismo( m1ismo )
  mDS_ONK    := inieditspr(A__MENUVERT, mm_danet, M1DS_ONK)
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
  mdispans  := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  mnazn_l   := inieditspr( A__MENUVERT, mm_danet, m1nazn_l )
  mdopo_na  := inieditspr( A__MENUBIT, mm_dopo_na, m1dopo_na )
  mnapr_v_mo := inieditspr( A__MENUVERT, mm_napr_v_mo, m1napr_v_mo )
  If Empty( arr_mo_spec )
    ma_mo_spec := '---'
  Else
    ma_mo_spec := ''
    For i := 1 To Len( arr_mo_spec )
      ma_mo_spec += lstr( arr_mo_spec[ i ] ) + ','
    Next
    ma_mo_spec := Left( ma_mo_spec, Len( ma_mo_spec ) - 1 )
  Endif
  mnapr_stac := inieditspr( A__MENUVERT, mm_napr_stac, m1napr_stac )
  mprofil_stac := inieditspr( A__MENUVERT, getv002(), m1profil_stac )
  mnapr_reab := inieditspr( A__MENUVERT, mm_danet, m1napr_reab )
  mprofil_kojki := inieditspr( A__MENUVERT, getv020(), m1profil_kojki )
  mssh_na   := inieditspr( A__MENUVERT, mm_danet, m1ssh_na )
  mspec_na  := inieditspr( A__MENUVERT, mm_danet, m1spec_na )
  msank_na  := inieditspr( A__MENUVERT, mm_danet, m1sank_na )

  //
  If !Empty( f_print )
    return &( f_print + '(' + lstr( Loc_kod ) + ',' + lstr( kod_kartotek ) + ')' )
  Endif

  //
  str_1 := ' ���� ��ᯠ��ਧ�樨 ९த�⨢���� ���஢�� ������'
  If Loc_kod == 0
    str_1 := '����������' + str_1
  Else
    str_1 := '������஢����' + str_1
  Endif

  SetColor( color8 )
  Private gl_area
  SetColor( cDataCGet )
  make_diagp( 1 )  // ᤥ���� '��⨧����' ��������

  Private num_screen := 1

  Do While .t.
    Close databases
    DispBegin()
    hS := 26
    wS := 80
    SetMode( hS, wS )
    @ 0, 0 Say PadC( str_1, wS ) Color 'B/BG*'
    gl_area := { 1, 0, MaxRow() -1, MaxCol(), 0 }

    j := 1
    myclear( j )

    @ j, 0 Say '��࠭ ' + lstr( num_screen ) Color color8
    If num_screen > 1
      s := AllTrim( mfio ) + ' (' + lstr( mvozrast ) + ' ' + s_let( mvozrast ) + ')'
      @ j, wS - Len( s ) Say s Color color14
    Endif
    If num_screen == 1 //
      @ ++j, 1 Say '���' Get mfio_kart ;
        reader {| x | menu_reader( x, { {| k, r, c| get_fio_kart( k, r, c ) } }, A__FUNCTION,,, .f. ) } ;
        valid {| g, o| update_get( 'mdate_r' ), ;
        update_get( 'mkomu' ), update_get( 'mcompany' ) }
      @ Row(), Col() + 5 Say '�.�.' Get mdate_r When .f. Color color14

      @ ++j, 1 Say ' ����� ���: ���' Get mvidpolis ;
        reader {| x | menu_reader( x, mm_vid_polis, A__MENUVERT,,, .f. ) } ;
        When m1komu == 0 ;
        Valid func_valid_polis( m1vidpolis, mspolis, mnpolis )
      @ Row(), Col() + 2 Say '�����'  Get mnpolis When m1komu == 0
      @ Row(), Col() + 2 Say '���' Get mspolis When ( m1vidpolis == 1 .and. m1komu == 0 )

      @ ++j, 1 Say ' �ਭ���������� ����' Get mkomu ;
        reader {| x | menu_reader( x, mm_komu, A__MENUVERT,,, .f. ) } ;
        valid {| g, o| f_valid_komu( g, o ) } ;
        Color colget_menu
      @ Row(), Col() + 1 Say '==>' Get mcompany ;
        reader {| x | menu_reader( x, mm_company, A__MENUVERT,,, .f. ) } ;
        When m1komu < 5 ;
        valid {| g | func_valid_ismo( g, m1komu, 38 ) }
      //
//      j++
      @ ++j, 1 Say '�ப�' Get mn_data ;
        valid {| g | f_k_data( g, 1 ), f_valid_begdata_drz( g, Loc_kod ), ;
        iif( ( mvozrast < 18 .or. mvozrast > 49 ), func_error( 4, '��樥�� �� �������� ������� ���� ��ᯠ��ਧ�樨!' ), nil ), ;
        ret_ndisp_drz( Loc_kod, kod_kartotek ) ;
        }
      @ Row(), Col() + 1 Say '-' Get mk_data ;
        valid {| g | f_k_data( g, 2 ), ret_ndisp_drz( Loc_kod, kod_kartotek ) ;
        }

      @ j, Col() + 5 Say '� ���㫠�୮� �����' Get much_doc Picture '@!' ;
        When !( is_uchastok == 1 .and. is_task( X_REGIST ) ) .or. mem_edit_ist == 2

      ret_ndisp_drz( Loc_kod, kod_kartotek )
//      j++
      @ ++j, 8 Get mndisp When .f. Color color14  // ���������

      if ! ( metap == 1 .and. nGender == '�' )  // �� I �⠯� ��� �㦨� ��᫥������� ���
        @ ++j, 1 Say '������������������������������������������������������������������������������' Color color8
        @ ++j, 1 Say '������������ ��᫥�������                   ���� ����᳤�� ��㣳�믮������ ' Color color8
        @ ++j, 1 Say '������������������������������������������������������������������������������' Color color8
        If mem_por_ass == 0
          @ j - 1, 52 Say Space( 5 )
        Endif
      else
        j += 2
      endif
      view_uslugi := uslugi_to_view( uslugi_etapa )
      For i := 1 To len( view_uslugi )  //  lenArr_Uslugi_DRZ

        fl_diag := .f.
        i_otkaz := 0
        If f_is_usl_sluch_drz( view_uslugi, i, .f., @fl_diag, @i_otkaz )
          if view_uslugi[ i, 4 ] == 0 .and. ! fl_shapka_osmotr
            @ ++j, 1 Say '��������������������������������������������������������������������' Color color8
            @ ++j, 1 Say '������������ �ᬮ�஢                       ���� ����᳤�� ��㣨' Color color8
            @ ++j, 1 Say '��������������������������������������������������������������������' Color color8
            If mem_por_ass == 0
              @ j - 1, 52 Say Space( 5 )
            Endif
            fl_shapka_osmotr := .t.
          Endif
          mvarv := 'MTAB_NOMv' + lstr( i )
          mvara := 'MTAB_NOMa' + lstr( i )
          mvard := 'MDATE' + lstr( i )
          If Empty( &mvard )
            &mvard := mn_data
          Endif
          mvarz := 'MKOD_DIAG' + lstr( i )
          mvaro := 'MOTKAZ' + lstr( i )
          @ ++j, 1 Say padr( view_uslugi[ i, 1 ], 44 )
          @ j, 46 get &mvarv Pict '99999' valid {| g | v_kart_vrach( g ) }
          If mem_por_ass > 0
            @ j, 52 get &mvara Pict '99999' valid {| g | v_kart_vrach( g ) }
          Endif
          @ j, 58 get &mvard valid {| g | valid_date_uslugi_drz( g, metap, mn_data, mk_data, lenArr_Uslugi_DRZ, i ) }

          If fl_diag  // ��� ���������᪨� ���
            if i_otkaz == 0
              @ j, 69 get &mvaro ;
                reader {| x | menu_reader( x, arr_mm_result_drz( metap ), A__MENUVERT,,, .f. ) }
            endif
          Endif

        Endif
      Next
      @ ++j, 1 Say Replicate( '�', 68 ) Color color8
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgDn>^ �� 2-� ��࠭���' )
    Elseif num_screen == 2 //

      mm_gruppa := { mm_gruppaD1, mm_gruppaD2 }[ metap ]
      mgruppa := inieditspr( A__MENUVERT, mm_gruppa, m1gruppa )
      If ( i := AScan( mm_gruppa, {| x | x[ 3 ] == m1rslt } ) ) > 0
        m1GRUPPA := mm_gruppa[ i, 2 ]
      Endif

      ret_ndisp_drz( Loc_kod, kod_kartotek )

      dispans_vyav_diag( @j, mndisp ) // �맮� ���������� ����� ������� �����������
      // ������ ��ண� ����
      @ ++j, 1 Say '��ᯠ��୮� ������� ��⠭������' Get mdispans ;
        reader {| x | menu_reader( x, mm_dispans, A__MENUVERT,,, .f. ) } ;
        When !emptyall( mdispans1, mdispans2, mdispans3, mdispans4, mdispans5 )

      @ ++j, 1 say '�ਧ��� �����७�� �� �������⢥���� ������ࠧ������' get mDS_ONK ;
        reader { | x | menu_reader( x, mm_danet, A__MENUVERT, , , .f. ) }
      @ ++j, 1 say '���ࠢ����� �� �����७�� �� ���' get mnapr_onk ;
        reader { | x | menu_reader( x, { { | k, r, c | fget_napr_ZNO( k, r, c ) } }, A__FUNCTION, , , .f. ) } ;
        when m1ds_onk == 1

      @ ++j, 1 Say '�����祭� ��祭�� (��� �.131)' Get mnazn_l ;
        reader {| x | menu_reader( x, mm_danet, A__MENUVERT,,, .f. ) }

      dispans_napr( mk_data, @j, .t. )  // �맮� ���������� ����� ���ࠢ�����

      ++j

      @ ++j, 1 Say '������ ���ﭨ� ��������'
      @ j, Col() + 1 Get mGRUPPA ;
        reader {| x | menu_reader( x, mm_gruppa, A__MENUVERT,,, .f. ) }
      status_key( '^<Esc>^ ��室 ��� ����� ^<PgUp>^ �� 1-� ��࠭��� ^<PgDn>^ ������' )
    Endif
    DispEnd()
    count_edit += myread()

    //

    If num_screen == 2
      If LastKey() == K_PGUP
        k := 3
        --num_screen
        fl_shapka_osmotr := .f.
      Else
        k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
          { ' ��室 ��� ����� ', ' ������ ', ' ������ � ।���஢���� ' }, ;
          iif( LastKey() == K_ESC, 1, 2 ), 'W+/N', 'N+/N', MaxRow() -2,, 'W+/N,N/BG' )
      Endif
    Else
      If LastKey() == K_PGUP
        k := 3
        If num_screen > 1
          --num_screen
        Endif
      Elseif LastKey() == K_ESC
        If ( k := f_alert( { PadC( '�롥�� ����⢨�', 60, '.' ) }, ;
            { ' ��室 ��� ����� ', ' ������ � ।���஢���� ' }, ;
            1, 'W+/N', 'N+/N', MaxRow() -2,, 'W+/N,N/BG' ) ) == 2
          k := 3
          fl_shapka_osmotr := .f.
        Endif
      Else
        k := 3
        ++num_screen
        If mvozrast < 18 .or. mvozrast > 49
          num_screen := 1
          func_error( 4, '��樥�� �� �������� ������� ���� ��ᯠ��ਧ�樨!' )
        Elseif metap == 0
          num_screen := 1
          func_error( 4, '�஢���� �ப� ��ᯠ��ਧ�樨!' )
        Endif
      Endif
    Endif

    SetMode( 25, 80 )
    If k == 3
      Loop
    Elseif k == 2
      num_screen := 1
      If m1komu < 5 .and. Empty( m1company )
        If m1komu == 0
          s := '���'
        Elseif m1komu == 1
          s := '��������'
        Else
          s := '������/��'
        Endif
        func_error( 4, '�� ��������� ������������ ' + s )
        Loop
      Endif
      If m1komu == 0 .and. Empty( mnpolis )
        func_error( 4, '�� �������� ����� �����' )
        Loop
      Endif
      If Empty( mn_data )
        func_error( 4, '�� ������� ��� ��砫� ��ᯠ��ਧ�樨.' )
        Loop
      Endif
      If mvozrast < 18
        func_error( 4, '��ᯠ��ਧ��� ������� �� ���᫮�� ��樥���!' )
        Loop
      Endif
      If Empty( mk_data )
        func_error( 4, '�� ������� ��� ����砭�� ��ᯠ��ਧ�樨.' )
        Loop
      Endif
      If Empty( CharRepl( '0', much_doc, Space( 10 ) ) )
        func_error( 4, '�� �������� ����� ���㫠�୮� �����' )
        fl_shapka_osmotr := .f.
        Loop
      Endif
//      If eq_any( m1gruppa, 2, 3, 11, 12 ) .and. ( m1dopo_na == 0 ) .and. ( m1napr_v_mo == 0 ) .and. ( m1napr_stac == 0 ) .and. ( m1napr_reab == 0 )
//        func_error( 4, '��� ��࠭��� ������ �������� �롥�� �����祭�� (���ࠢ�����) ��� ��樥��!' )
//        Loop
//      Endif
      If ! checktabnumberdoctor( mk_data, .t. )
        Loop
      Endif
      //
      // ////////////////////////////////////////////////////////////
      mdef_diagnoz := DGZ
      r_use( dir_exe + '_mo_mkb', cur_dir + '_mo_mkb', 'MKB_10' )
      r_use( dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2' )
      num_screen := 2
      fl := .t.
      k := 0
      kol_d_usl := 0

      arr_osm1 := Array( len( view_uslugi ), 14 ) // �뫮 13
      afillall( arr_osm1, 0 )
      for i := 1 to len( view_uslugi )
        arr_osm1[ i, 5 ] := view_uslugi[ i, 2 ]
      next

      // ��� ����������
      lAllneNazn := .t.
      lUziMatkiAbdomin := .f.
      lUziMatkiTransvag := .f.
      lCitIsl := .f.
      lGidCitIsl := .f.
      For i := 1 To len( view_uslugi )  //   lenArr_Uslugi_DRZ
//        fl_diag := .f.
//        i_otkaz := 0
//        f_is_usl_sluch_drz( uslugi_etapa, i, .t., @fl_diag, @i_otkaz )
        mvart := 'MTAB_NOMv' + lstr( i )
        mvara := 'MTAB_NOMa' + lstr( i )
        mvard := 'MDATE' + lstr( i )
        mvarz := 'MKOD_DIAG' + lstr( i )
        mvaro := 'M1OTKAZ' + lstr( i )
        ar := view_uslugi[ i ]

        // ��⮫����᪨� ��᫥�������
        if nGender == '�' .and. ar[ 2 ] == 'A08.20.017' .and. &mvaro != 4 .and. ! empty( &mvart ) // �஢�ઠ �⮫����᪮�� ��᫥�������
          lCitIsl := .t.
        endif
        if nGender == '�' .and. ar[ 2 ] == 'A08.20.017.002' .and. &mvaro != 4 .and. ! empty( &mvart ) // �஢�ઠ ������⭮�� �⮫����᪮�� ��᫥�������
          lGidCitIsl := .t.
        endif

        // ��� ������ ⠧� ��㣠 70.9.52
        if nGender == '�' .and. ar[ 2 ] == 'A04.20.001' .and. &mvaro != 4 .and. ! empty( &mvart ) // �஢�ઠ ���������쭮�� ���
          lUziMatkiAbdomin := .t.
        endif
        if nGender == '�' .and. ar[ 2 ] == 'A04.20.001.001' .and. &mvaro != 4 .and. ! empty( &mvart ) // �஢�ઠ �࠭ᢠ�����쭮�� ���
          lUziMatkiTransvag := .t.  
        endif
        if &mvaro != 4 .and. view_uslugi[ i, 4 ] == 1
          lAllneNazn := .f.
        endif
        //
      next
        //
      // ��� �஢��塞
      For i := 1 To len( view_uslugi )  //   lenArr_Uslugi_DRZ
        mvart := 'MTAB_NOMv' + lstr( i )
        mvara := 'MTAB_NOMa' + lstr( i )
        mvard := 'MDATE' + lstr( i )
        mvarz := 'MKOD_DIAG' + lstr( i )
        mvaro := 'M1OTKAZ' + lstr( i )
        ar := view_uslugi[ i ]
        ++kol_d_usl
        arr_osm1[ i, 12 ] := view_uslugi[ i, 12 ]   // �ਧ��� ��㣨 0 - ����� / 1 - �����
        If arr_osm1[ i, 12 ] == 0
          arr_osm1[ i, 13 ] := view_uslugi[ i, 13 ]
        Endif
        if Empty( &mvard ) .and. &mvaro != 4
          fl := func_error( 4, '�� ������� ��� ��㣨 "' + LTrim( ar[ 1 ] ) + '"' )
        elseif ( lUziMatkiTransvag .and. lUziMatkiAbdomin ) .and. &mvaro != 4
          fl := func_error( 4, '����� �ਬ����� �����६���� ��㣨 ��� (�࠭ᠡ�������쭮� � �࠭ᢠ�����쭮�)' )
        elseif ( lCitIsl .and. lGidCitIsl )
          fl := func_error( 4, '����� �ਬ����� �����६���� ��㣨 �⮫���� � ������⭮� �⮫����' )
        elseif Empty( &mvart ) .and. &mvaro != 4 .and. ;
          ( ( LTrim( ar[ 2 ] ) == 'A04.20.001' .and. ! lUziMatkiTransvag ) .or. ;
          ( LTrim( ar[ 2 ] ) == 'A04.20.001.001' .and. ! lUziMatkiAbdomin ) )
          fl := func_error( 4, '�� ������ ��� � ��㣥 ��� ������ ⠧�' )
        elseif Empty( &mvart ) .and. &mvaro != 4
          if ! eq_any( LTrim( ar[ 2 ] ), 'A08.20.017', 'A08.20.017.002', 'A04.20.001', 'A04.20.001.001' )
            fl := func_error( 4, '�� ������ ��� � ��㣥 "' + LTrim( ar[ 1 ] ) + '"' )
          endif
        Else  // ⠡���� ����� ��� � ��� ᯥ樠�쭮���
         If ! Empty( &mvart ) // ⠡���� ����� ���
           Select P2
           find ( Str( &mvart, 5 ) )
           If Found()
             arr_osm1[ i, 1 ] := p2->kod
             arr_osm1[ i, 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
             arr_osm1[ i, 14 ] := p2->prvs_021
           Endif
         Endif
         If !Empty( &mvara ) // ⠡���� ����� ����⥭�
           Select P2
           find ( Str( &mvara, 5 ) )
           If Found()
             arr_osm1[ i, 3 ] := p2->kod
           Endif
         Endif
         If ValType( ar[ 10 ] ) == 'N' // ��䨫�
           arr_osm1[ i, 4 ] := ret_profil_dispans_drz( ar[ 10 ], arr_osm1[ i, 2 ] )
          Else
            // ࠧ�������
            // If Len( ar[ 10 ] ) == Len( ar[ 11 ] ) ; // ���-�� ��䨫�� = ���-�� ᯥ�-⥩
            //   .and. arr_osm1[ i, 2 ] < 0 ; // � ��諨 ᯥ樠�쭮��� �� V015
            //   .and. ( j := AScan( ar[ 11 ], ret_old_prvs( arr_osm1[ i, 2 ] ) ) ) > 0
            //   // ���� ��䨫�, ᮮ⢥�����騩 ᯥ樠�쭮��
            // Else
              j := 1 // �᫨ ���, ���� ���� ��䨫� �� ᯨ᪠
            // Endif
            arr_osm1[ i, 4 ] := ar[ 10, j ] // ��䨫�
          Endif
          If ValType( ar[ 2 ] ) == 'C'  // ��� ��㣨
            arr_osm1[ i, 5 ] := ar[ 2 ] // ��� ��㣨
          Else
            If Len( ar[ 2 ] ) >= metap
              j := metap
            Else
              j := 1
            Endif
            arr_osm1[ i, 5 ] := ar[ 2, j ] // ��� ��㣨
          Endif

          If ! fl_diag .or. Empty( &mvarz ) .or. Left( &mvarz, 1 ) == FIRST_LETTER
            arr_osm1[i, 6] := mdef_diagnoz
          Else
            arr_osm1[ i, 6 ] := &mvarz
            Select MKB_10
            find ( PadR( arr_osm1[ i, 6 ], 6 ) )
            If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
              fl := func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + arr_osm1[ i, 6 ] )
            Endif
          Endif
          arr_osm1[ i, 10 ] := &mvaro
          arr_osm1[ i, 9 ] := &mvard
        Endif

        If ! fl
          Exit
        Endif
      Next
      if metap == 2 .and. lAllneNazn
        fl := func_error( 4, '�� II �⠯� �� ����᪠���� ������� �ਥ� ���!' )
      endif
      If ! fl
        Loop
      Endif

      num_screen := 2
      arr_diag := {}
      For i := 1 To 5
        sk := lstr( i )
        pole_diag := 'mdiag' + sk
        pole_d_diag := 'mddiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If ! Empty( &pole_diag )
          if &pole_1pervich == 0
            If Empty( &pole_d_diag )
              fl := func_error( 4, '�� ������� ��� ������ �������� ' + &pole_diag )
            elseif &pole_1dispans == 1 .and. Empty( &pole_d_dispans )
              fl := func_error( 4, '�� ������� ��� ��⠭������� ��ᯠ��୮�� ������� ��� �������� ' + &pole_diag )
            Endif
          Endif
          If fl .and. Between( &pole_1pervich, 0, 1 ) // �।���⥫�� �������� �� ����
            AAdd( arr_diag, { &pole_diag, &pole_1pervich, &pole_1dispans, &pole_dn_dispans } )
          Endif
        Endif
        If !fl
          Exit
        Endif
      Next
      If !fl
        Loop
      Endif
      AFill( adiag_talon, 0 )
      if m1DS_ONK == 1
        aadd( arr_diag, { 'Z03.1', 0, 0, ctod( '' ) } ) // ������� �� 㬮�砭��
      endif
      If Empty( arr_diag ) // �������� �� �������
        MKOD_DIAG := mdef_diagnoz
      Else
        For i := 1 To Len( arr_diag )
          If arr_diag[ i, 2 ] == 0 // '࠭�� �����'
            arr_diag[ i, 2 ] := 2  // �����塞, ��� � ���� ���� ���
          Endif
          If arr_diag[ i, 3 ] > 0 // '���.������� ��⠭������' � '࠭�� �����'
            If arr_diag[ i, 2 ] == 2 // '࠭�� �����'
              arr_diag[ i, 3 ] := 1 // � '���⮨�'
            Else
              arr_diag[ i, 3 ] := 2 // � '����'
            Endif
          Endif
        Next
        For i := 1 To Len( arr_diag )
          adiag_talon[ i * 2 - 1 ] := arr_diag[ i, 2 ]
          adiag_talon[ i * 2  ] := arr_diag[ i, 3 ]
          If i == 1
            MKOD_DIAG := arr_diag[ i, 1 ]
          Elseif i == 2
            MKOD_DIAG2 := arr_diag[ i, 1 ]
          Elseif i == 3
            MKOD_DIAG3 := arr_diag[ i, 1 ]
          Elseif i == 4
            MKOD_DIAG4 := arr_diag[ i, 1 ]
          Elseif i == 5
            MSOPUT_B1 := arr_diag[ i, 1 ]
          Endif
          Select MKB_10
          find ( PadR( arr_diag[ i, 1 ], 6 ) )
          If Found()
            If !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
              fl := func_error( 4, '��ᮢ���⨬���� �������� �� ���� ' + AllTrim( arr_diag[ i, 1 ] ) )
            Endif
          Else
            fl := func_error( 4, '�� ������ ������� ' + AllTrim( arr_diag[ i, 1 ] ) + ' � �ࠢ�筨�� ���-10' )
          Endif
          If !fl
            Exit
          Endif
        Next
        If !fl
          Loop
        Endif
      Endif

      mm_gruppa := { mm_gruppaD1, mm_gruppaD2 }[ metap ]

//      m1p_otk := 0
      If ( i := AScan( mm_gruppa, {| x | x[ 2 ] == m1GRUPPA } ) ) > 0
        m1rslt := mm_gruppa[ i, 3 ]
//        If ( m1rslt := mm_gruppa[ i, 3 ] ) == 352
//          m1rslt := 353 // �� ����� ����� �� 06.07.18 �09-30-96
//        Endif
        If eq_any( m1GRUPPA, 11, 21 )
          m1GRUPPA++ // �� ����� ����� �� 06.07.18 �09 -30 -96
        Endif
        If m1GRUPPA > 20
//          m1p_otk := 1 // �⪠� �� ��室� �� 2-� �⠯
        Endif
      Else
        func_error( 4, '�� ������� ������ ���ﭨ� ��������' )
        Loop
      Endif
      //
      m1ssh_na := m1spec_na := 0
      If m1napr_v_mo > 0
        If eq_ascan( arr_mo_spec, 45, 141 ) // ���ࠢ��� � ����-�थ筮-��㤨�⮬� �����
          m1ssh_na := 1
        Endif
      Endif
      If m1napr_stac > 0 .and. m1profil_stac > 0
        m1spec_na := 1 // ���ࠢ��� ��� ����祭�� ᯥ樠����஢����� ����樭᪮� ����� (� �.�. ���)
      Endif
      //
      If mem_op_out == 2 .and. yes_parol
        box_shadow( 19, 10, 22, 69, cColorStMsg )
        str_center( 20, '������ "' + fio_polzovat + '".', cColorSt2Msg )
        str_center( 21, '���� ������ �� ' + date_month( sys_date ), cColorStMsg )
      Endif
      mywait()
      is_prazdnik := ! is_work_day( mn_data )

      make_diagp( 2 )  // ᤥ���� '��⨧����' ��������
      If m1dispans > 0
        s1dispans := m1dispans
      Endif
      // ��⮢�� ���ᨢ� ��� ���������� १���⠬� �������⨪�
      arr_usl_dop := {}
      arr_otklon := {}
      arr_ne_nazn := {}
      iUslDop := 0
      iUslOtklon := 0
      iUslNeNazn := 0

      // �������� ⠡���� arr_osm1 �����
      for i := 1 to lenArr_Uslugi_DRZ
        if ( j := ascan( arr_osm1, { | x | x[ 5 ] == uslugi_etapa[ i, 2 ] } ) ) == 0
          aadd( arr_osm1, { 0, 0, 0, 0, uslugi_etapa[ i, 2 ], DGZ, 0, 0, 0, 0, 0, uslugi_etapa[ i, 12 ], 0, 0 } )
        endif
      next

      For i := 1 To Len( arr_osm1 )
        If eq_any( arr_osm1[ i, 10 ], 0, 3, 4 ) // �믮�����, �⪫������, �� �����祭�
          If arr_osm1[ i, 10 ] == 3 // �����㦥�� �⪫������
            AAdd( arr_otklon, arr_osm1[ i, 5 ] )
            iUslOtklon++
          elseIf arr_osm1[ i, 10 ] == 4 // �� �����祭�
            AAdd( arr_ne_nazn, arr_osm1[ i, 5 ] )
            iUslNeNazn++
          elseIf arr_osm1[ i, 10 ] == 0
            if alltrim( arr_osm1[ i, 5 ] ) == '70.9.52' .and. ;
              ( ! lUziMatkiAbdomin ) .and. ( ! lUziMatkiTransvag )
              arr_osm1[ i, 10 ] := 4
              AAdd( arr_ne_nazn, arr_osm1[ i, 5 ] )
              iUslNeNazn++
            elseif alltrim( arr_osm1[ i, 5 ] ) == 'A04.20.002'
              arr_osm1[ i, 10 ] := 4
              AAdd( arr_ne_nazn, arr_osm1[ i, 5 ] )
              iUslNeNazn++
            endif
          Endif
        Endif
      next
      if metap == 1
        if nGender == '�' // ��稭�
          indSource := index_usluga_etap_drz( arr_osm1, '70.9.20', 5)
          if arr_osm1[ indSource, 14 ] == 84
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'B01.057.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            indDest := index_usluga_etap_drz( arr_osm1, 'B01.053.001', 5 )
          else
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'B01.053.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            indDest := index_usluga_etap_drz( arr_osm1, 'B01.057.001', 5 )
          endif
          if indSource != 0 .and. indDest != 0
            change_field_arr_osm1( indSource, indDest )
          endif
        else  // ���騭�
          if eq_any_new( nAge, 21, 24, 27 )
            indSource := index_usluga_etap_drz( arr_osm1, '70.9.1', 5)  // ������ 21, 24, 27 ���
          elseif eq_any_new( nAge, 30, 35, 40, 45 )
            indSource := index_usluga_etap_drz( arr_osm1, '70.9.2', 5)  // ������ 30, 35, 40, 45 ���
          elseif eq_any_new( nAge, 18, 19, 20, 22, 23, 25, 26, 28, 29 )
            indSource := index_usluga_etap_drz( arr_osm1, '70.9.3', 5)  // ������ 18, 19, 20, 22, 23, 25, 26, 28, 29 ���
          elseif eq_any_new( nAge, 31, 32, 33, 34, 36, 37, 38, 39, 41, 42, 43, 44, 46, 47, 48, 49 )
            indSource := index_usluga_etap_drz( arr_osm1, '70.9.4', 5)  // ������ 31, 32, 33, 34, 36, 37, 38, 39, 41, 42, 43, 44, 46, 47, 48, 49 ���
          endif
          indDest := index_usluga_etap_drz( arr_osm1, 'B01.001.001', 5 )
          if indSource != 0 .and. indDest != 0
            change_field_arr_osm1( indSource, indDest )
          endif
          if lCitIsl
            if ( indSource := index_usluga_etap_drz( arr_osm1, 'A08.20.017', 5) ) > 0  // �⮫����᪮� ��᫥�������
              if ( indDest := index_usluga_etap_drz( arr_osm1, 'A08.20.017.001', 5 ) ) > 0
                change_field_arr_osm1( indSource, indDest )
              endif
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A08.20.017.002' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          else
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A08.20.017' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A08.20.017.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif
        endif
      elseif metap == 2
        if nGender == '�' // ��稭�
          indSource := index_usluga_etap_drz( arr_osm1, '70.9.80', 5) // ������ �ਥ�
          if arr_osm1[ indSource, 14 ] == 84
            j := ascan( arr_osm1, { | x | x[ 5 ] == 'B01.057.002' } )
            indDest := index_usluga_etap_drz( arr_osm1, 'B01.053.002', 5 )
          else
            j := ascan( arr_osm1, { | x | x[ 5 ] == 'B01.053.002' } )
            indDest := index_usluga_etap_drz( arr_osm1, 'B01.057.002', 5 )
          endif
          if indSource != 0 .and. indDest != 0
            change_field_arr_osm1( indSource, indDest )
            if j > 0
              hb_ADel( arr_osm1, j, .t. ) // 㤠��� ���㦭�� ����
            endif
          endif

          indSource := index_usluga_etap_drz( arr_osm1, '70.9.81', 5) // ᯥମ�ࠬ��
          if arr_osm1[ indSource, 10 ] != 4
            indDest := index_usluga_etap_drz( arr_osm1, 'B03.053.002', 5 )
            if indSource != 0 .and. indDest != 0
              change_field_arr_osm1( indSource, indDest )
            endif
          else  // 㤠��� �� �㦭� ��㣨
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.81' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'B03.053.002' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif

          indSource := index_usluga_etap_drz( arr_osm1, '70.9.82', 5) // ��� ��训�� � ������
          if arr_osm1[ indSource, 10 ] != 4
            indDest := index_usluga_etap_drz( arr_osm1, 'A04.28.003', 5 )
            if indSource != 0 .and. indDest != 0
              change_field_arr_osm1( indSource, indDest )
              if ( indDest := index_usluga_etap_drz( arr_osm1, 'A04.21.001', 5 ) ) > 0
                change_field_arr_osm1( indSource, indDest )
              endif
            endif
          else  // 㤠��� �� �㦭� ��㣨
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.82' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.28.003' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.21.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif
          
          indSource := index_usluga_etap_drz( arr_osm1, '70.9.83', 5) // ��� ��� ����
          if arr_osm1[ indSource, 10 ] != 4
            indDest := index_usluga_etap_drz( arr_osm1, 'A26.21.036.001', 5 )
            if indSource != 0 .and. indDest != 0
              change_field_arr_osm1( indSource, indDest )
            endif
          else  // 㤠��� �� �㦭� ��㣨
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.83' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A26.21.036.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif

          indSource := index_usluga_etap_drz( arr_osm1, '70.9.84', 5) // ��� ��� ����������
          if arr_osm1[ indSource, 10 ] != 4
            indDest := index_usluga_etap_drz( arr_osm1, 'A26.21.035.001', 5 )
            if indSource != 0 .and. indDest != 0
              change_field_arr_osm1( indSource, indDest )
            endif
          else  // 㤠��� �� �㦭� ��㣨
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.84' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A26.21.035.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif
        else  // ���騭�
          indSource := index_usluga_etap_drz( arr_osm1, '70.9.51', 5) // ��� ������� �����
          if arr_osm1[ indSource, 10 ] != 4
            if indSource != 0
              if ( indDest := index_usluga_etap_drz( arr_osm1, 'A04.20.002', 5 ) ) > 0
                change_field_arr_osm1( indSource, indDest )
              endif
            endif
          else  // 㤠��� �᫨ �� �����祭�
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.51' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.20.002' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif

          if lUziMatkiAbdomin
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.20.001.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            indSource := index_usluga_etap_drz( arr_osm1, 'A04.20.001', 5) // ��� ��⪨ �࠭ᠡ�������쭮�
          elseif lUziMatkiTransvag
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.20.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            indSource := index_usluga_etap_drz( arr_osm1, 'A04.20.001.001', 5) // ��� ��⪨ �࠭ᢠ�����쭮�
          else  // 㤠��� �� �㦭� ��㣨 ���
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.20.001.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A04.20.001' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
            indSource := 0
            if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.52' } ) ) > 0
              hb_ADel( arr_osm1, j, .t. )
            endif
          endif
          if indSource != 0
            if ( indDest := index_usluga_etap_drz( arr_osm1, '70.9.52', 5 ) ) > 0
              change_field_arr_osm1( indSource, indDest )
            endif
          endif
          if ( indSource := index_usluga_etap_drz( arr_osm1, '70.9.53', 5 ) ) > 0  // ����� ����
            if arr_osm1[ indSource, 10 ] != 4
              if ( indDest := index_usluga_etap_drz( arr_osm1, 'A26.20.034.001', 5 ) ) > 0
                change_field_arr_osm1( indSource, indDest )
              endif
            else  // 㤠��� �� �㦭� ��㣨
              if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.53' } ) ) > 0
                hb_ADel( arr_osm1, j, .t. )
              endif
              if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A26.20.034.001' } ) ) > 0
                hb_ADel( arr_osm1, j, .t. )
              endif
            endif
          endif
          if ( indSource := index_usluga_etap_drz( arr_osm1, '70.9.54', 5 ) ) > 0 // ����� �������� 祫�����
            if arr_osm1[ indSource, 10 ] != 4
              if ( indDest := index_usluga_etap_drz( arr_osm1, 'A26.20.009.002', 5 ) ) > 0
                change_field_arr_osm1( indSource, indDest )
              endif
            else  // 㤠��� �� �㦭� ��㣨
              if ( j := ascan( arr_osm1, { | x | x[ 5 ] == '70.9.54' } ) ) > 0
                hb_ADel( arr_osm1, j, .t. )
              endif
              if ( j := ascan( arr_osm1, { | x | x[ 5 ] == 'A26.20.009.002' } ) ) > 0
                hb_ADel( arr_osm1, j, .t. )
              endif
            endif
          endif
          if ( indSource := index_usluga_etap_drz( arr_osm1, '70.9.50', 5) ) > 0 // ������ �ਥ� ����������
            if ( indDest := index_usluga_etap_drz( arr_osm1, 'B01.001.002', 5 ) ) > 0
              change_field_arr_osm1( indSource, indDest )
            endif
          endif
        endif
      endif

      use_base( 'lusl' )
      use_base( 'luslc' )
      use_base( 'uslugi' )
      r_use( dir_server + 'uslugi1', { dir_server + 'uslugi1', ;
        dir_server + 'uslugi1s' }, 'USL1' )
      mcena_1 := mu_cena := 0
//      arr_usl_dop := {}
//      arr_otklon := {}
//      arr_ne_nazn := {}
//      iUslDop := 0
//      iUslOtklon := 0
//      iUslNeNazn := 0
      For i := 1 To Len( arr_osm1 )
        If ValType( arr_osm1[ i, 5 ] ) == 'C'
          If arr_osm1[ i, 12 ] == 0
            arr_osm1[ i, 7 ] := foundourusluga( arr_osm1[ i, 5 ], mk_data, arr_osm1[ i, 4 ], M1VZROS_REB, @mu_cena )
            arr_osm1[ i, 8 ] := iif( eq_any( arr_osm1[ i, 10 ], 0, 3 ), mu_cena, 0 )
          Else
            arr_osm1[ i, 7 ] := foundffomsusluga( arr_osm1[ i, 5 ] )
            arr_osm1[ i, 8 ] := 0  // ��� 䥤�ࠫ��� ��� 業� ����� 0
          Endif
          If eq_any( arr_osm1[ i, 10 ], 0, 3, 4 ) // �믮�����, �⪫������, �� �����祭�
            AAdd( arr_usl_dop, AClone( arr_osm1[ i ] ) )
            iUslDop++
            If arr_osm1[ i, 12 ] == 0 .and. ! Empty( arr_osm1[ i, 13 ] )  // ��� ��㣨 ����� ������� ���� �����
              AAdd( arr_usl_dop, AClone( arr_osm1[ i ] ) )
              iUslDop := Len( arr_usl_dop ) // ++
              arr_usl_dop[ iUslDop, 5 ] := arr_osm1[ i, 13 ]
              arr_usl_dop[ iUslDop, 7 ] := foundffomsusluga( arr_usl_dop[ iUslDop, 5 ] )
              arr_usl_dop[ iUslDop, 8 ] := 0  // ��� 䥤�ࠫ��� ��� 業� ����� 0
              arr_usl_dop[ iUslDop, 12 ] := 1  // ��⠭���� 䫠� ��㣨 �����
              arr_usl_dop[ iUslDop, 13 ] := ''  // ���⨬ 䥤�ࠫ��� ����
            Endif
//            If arr_osm1[ i, 10 ] == 3 // �����㦥�� �⪫������
//              AAdd( arr_otklon, arr_osm1[ i, 5 ] )
//              iUslOtklon++
//            elseIf arr_osm1[ i, 10 ] == 4 // �� �����祭�
//              AAdd( arr_ne_nazn, arr_osm1[ i, 5 ] )
//              iUslNeNazn++
//            Endif
          Endif
        Endif
      Next
      // ����稬 ����� �⮨����� ���� ��� �ਭ������� ���
      For i := 1 To Len( arr_usl_dop )
        mcena_1 += iif( arr_usl_dop[ i, 1 ] == 0, 0, arr_usl_dop[ i, 8 ] )
      Next
      //
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
      st_N_DATA := MN_DATA
      glob_perso := mkod
      If m1komu == 0
        msmo := lstr( m1company )
        m1str_crb := 0
      Else
        msmo := ''
        m1str_crb := m1company
      Endif
      //
      human->kod_k      := glob_kartotek
      human->TIP_H      := B_STANDART // 3-��祭�� �����襭�
      human->FIO        := MFIO          // �.�.�. ���쭮��
      human->POL        := MPOL          // ���
      human->DATE_R     := MDATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->ADRES      := MADRES        // ���� ���쭮��
      human->MR_DOL     := MMR_DOL       // ���� ࠡ��� ��� ��稭� ���ࠡ�⭮��
      human->RAB_NERAB  := M1RAB_NERAB   // 0-ࠡ���騩, 1-��ࠡ���騩, 2-��㤥��
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
      human->UCH_DOC    := MUCH_DOC      // ��� � ����� ��⭮�� ���㬥��
      human->N_DATA     := MN_DATA       // ��� ��砫� ��祭��
      human->K_DATA     := MK_DATA       // ��� ����砭�� ��祭��
      human->CENA := human->CENA_1 := MCENA_1 // �⮨����� ��祭��
      human->ishod      := BASE_ISHOD_RZD + metap
      human->OBRASHEN   := iif( m1DS_ONK == 1, '1', ' ' )
      human->bolnich    := 0
      human->date_b_1   := ''
      human->date_b_2   := ''
      human_->RODIT_DR  := CToD( '' )
      human_->RODIT_POL := ''
      s := ''
      AEval( adiag_talon, {| x | s += Str( x, 1 ) } )
      human_->DISPANS   := s
      human_->STATUS_ST := ''
      human_->POVOD     := iif( metap == 3, 5, 6 )
      human_->VPOLIS    := m1vidpolis
      human_->SPOLIS    := LTrim( mspolis )
      human_->NPOLIS    := LTrim( mnpolis )
      human_->OKATO     := '' // �� ���� ������� �� ����� � ��砥 �����த����
      human_->NOVOR     := 0
      human_->DATE_R2   := CToD( '' )
      human_->POL2      := ''
      human_->USL_OK    := m1USL_OK
      human_->VIDPOM    := m1VIDPOM
      human_->PROFIL    := 151    // m1PROFIL
      human_->IDSP      := 30     // iif(metap == 3, 17, 11)
      human_->NPR_MO    := ''
      human_->FORMA14   := '0000'
      human_->KOD_DIAG0 := ''
      human_->RSLT_NEW  := m1rslt
      human_->ISHOD_NEW := m1ishod

      m1vrach := arr_osm1[ Len( arr_osm1 ), 1 ]  // ���쬥� ��� ������襣� ��᫥���� ����

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
        g_use( dir_server + 'mo_hismo',, 'SN' )
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
      i1 := Len( arr_usl )

      // 㤠��� ���� ����� ��ᯠ��ਧ�樨
      use_base( 'mo_hdisp' )
      Do While .t.
        Select HDISP 
        find ( Str( mkod, 7 ) )
        If ! Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      HDISP->( dbCloseArea() )

      r_use( dir_server + 'mo_su',, 'MOSU' )
      use_base( 'mo_hu' )
      // 㤠��� ���� ��㣨 �����
      Do While .t.
        Select MOHU
        find ( Str( mkod, 7 ) )
        If ! Found()
          Exit
        Endif
        deleterec( .t., .f. )  // ��� ����⪨ �� 㤠�����
      Enddo

      use_base( 'human_u' )
      // 㤠��� ���� ��㣨 �����
      Do While .t.
        Select HU
        find ( Str( mkod, 7 ) )
        If ! Found()
          Exit
        Endif
        //
        Select HU_
        deleterec( .t., .f. )
        Select HU
        deleterec( .t., .f. )  // ��� ����⪨ �� 㤠�����
      Enddo

      For i := 1 To Len( arr_usl_dop )
        flExist := .f.
        If arr_usl_dop[ i, 12 ] == 0   // �� ��㣠 �����
          // ᭠砫� �롥६ ���ଠ�� �� human_u �� ��㣠� �����
          Select HU
          find ( Str( Loc_kod, 7 ) )
          Do While hu->kod == Loc_kod .and. !Eof()
            usl->( dbGoto( hu->u_kod ) )
            If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
              lshifr := usl->shifr
            Endif
            lshifr := AllTrim( lshifr )
            If lshifr == AllTrim( arr_usl_dop[ i, 5 ] )
              g_rlock( forever )
              flExist := .t.
              Exit
            Endif
            Skip
          Enddo
          If ! flExist
            add1rec( 7 )
            hu->kod := human->kod
          Endif
          mrec_hu := hu->( RecNo() )
          hu->kod_vr  := arr_usl_dop[ i, 1 ]
          hu->kod_as  := arr_usl_dop[ i, 3 ]
          hu->u_koef  := 1
          hu->u_kod   := arr_usl_dop[ i, 7 ]
          hu->u_cena  := arr_usl_dop[ i, 8 ]
          hu->is_edit := iif( Len( arr_usl_dop[ i ] ) > 10 .and. ValType( arr_usl_dop[ i, 11 ] ) == 'N', arr_usl_dop[ i, 11 ], 0 )
          hu->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
          hu->otd     := m1otd
          hu->kol := hu->kol_1 := 1
          hu->stoim := hu->stoim_1 := arr_usl_dop[ i, 8 ]
          hu->KOL_RCP := 0
          Select HU_
          Do While hu_->( LastRec() ) < mrec_hu
            Append Blank
          Enddo
          Goto ( mrec_hu )
          g_rlock( forever )
          If i > i1 .or. !valid_guid( hu_->ID_U )
            hu_->ID_U := mo_guid( 3, hu_->( RecNo() ) )
          Endif
          hu_->PROFIL := arr_usl_dop[ i, 4 ]
          hu_->PRVS   := arr_usl_dop[ i, 2 ]
          hu_->kod_diag := iif( Empty( arr_usl_dop[ i, 6 ] ), MKOD_DIAG, arr_usl_dop[ i, 6 ] )
          hu_->zf := ''
          Unlock
        Else  // 1 - �� ��㣠 �����
          // ��⥬ �롥६ ���ଠ�� �� mo_hu �� ��㣠� �����
          Select MOHU
          Set Relation To u_kod into MOSU
          find ( Str( Loc_kod, 7 ) )
          Do While MOHU->kod == Loc_kod .and. !Eof()
            MOSU->( dbGoto( MOHU->u_kod ) )
            Select MOHU
            lshifr := AllTrim( iif( Empty( MOSU->shifr ), MOSU->shifr1, MOSU->shifr ) )
            If AllTrim( lshifr ) == AllTrim( arr_usl_dop[ i, 5 ] )
              g_rlock( forever )
              flExist := .t.
              Exit
            Endif
            Skip
          Enddo
          If ! flExist
            add1rec( 7 )
            MOHU->kod := human->kod
          Endif
          mrec_mohu := MOHU->( RecNo() )
          MOHU->kod_vr  := arr_usl_dop[ i, 1 ]
          MOHU->kod_as  := arr_usl_dop[ i, 3 ]
          MOHU->u_kod   := arr_usl_dop[ i, 7 ]
          MOHU->u_cena  := arr_usl_dop[ i, 8 ]
          MOHU->date_u  := dtoc4( arr_usl_dop[ i, 9 ] )
          MOHU->otd     := m1otd
          MOHU->kol_1 := 1
          MOHU->stoim_1 := arr_usl_dop[ i, 8 ]
          If i > i1 .or. !valid_guid( MOHU->ID_U )
            MOHU->ID_U := mo_guid( 3, MOHU->( RecNo() ) )
          Endif
          MOHU->PROFIL := arr_usl_dop[ i, 4 ]
          MOHU->PRVS   := arr_usl_dop[ i, 2 ]
          MOHU->kod_diag := iif( Empty( arr_usl_dop[ i, 6 ] ), MKOD_DIAG, arr_usl_dop[ i, 6 ] )
          Unlock
        Endif
      Next

      save_arr_drz( mkod, mk_data )

      write_work_oper( glob_task, OPER_LIST, iif( Loc_kod == 0, 1, 2 ), 1, count_edit )
      fl_write_sluch := .t.
      Close databases

      if m1ds_onk == 1 // �����७�� �� �������⢥���� ������ࠧ������
        save_mo_onkna( mkod )
      endif
      stat_msg( '������ �����襭�!', .f. )
    Endif
    Exit
  Enddo

  Close databases
  SetColor( tmp_color )
  RestScreen( buf )
  If fl_write_sluch // �᫨ ����ᠫ� - ����᪠�� �஢���
    If Type( 'fl_edit_dvn_drz' ) == 'L'
      fl_edit_dvn_drz := .t.
    Endif
    If !Empty( Val( msmo ) )
      verify_oms_sluch( glob_perso )
    Endif
  Endif

  return nil