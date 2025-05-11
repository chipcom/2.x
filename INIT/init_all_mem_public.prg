#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.12.18 ���樠����஢��� �� mem (public) - ��६����
Function init_all_mem_public()

  // ����ࠨ����� �� ��� �����
  Public mem_smp_input := 0
  Public mem_smp_tel := 0
  Public mem_dom_aktiv := 0
  Public mem_beg_rees := 1
  Public mem_end_rees := 999999
  Public mem_bnn_rees := 1
  Public mem_enn_rees := 99
  Public mem_bnn13rees := -1
  Public mem_enn13rees := -1
  Public okato_umolch := "18401395000"
  Public public_date := CToD( "" ) // ���a, �� ������ (�����⥫쭮) ����饭� ।���஢��� �����
  Public mem_kart_error := 0  // 1 - ࠧ���� ������������ ��⠭�������� ����� ���㫠�୮� �����
  Public mem_kodkrt  := 1     // 2 - �᫨ ���� ॣ�������???
  Public mem_trudoem := 1
  Public mem_tr_plan := 2     // ��
  Public mem_sound   := 2     // ��
  Public mem_pol     := 1
  Public mem_diag4   := 2     // ��
  Public mem_diagno  := 2     // ��
  Public mem_kodotd  := 1
  Public mem_otdusl  := 1
  Public mem_ordusl  := 1
  Public mem_ordu_1  := 2     // ��
  Public mem_kat_va  := 2     // ��
  Public mem_vv_v_a  := 2
  Public mem_por_vr  := 1
  Public mem_por_ass := 2
  Public mem_por_kol := 3
  Public mem_date_1  := CToD( "" )
  Public mem_date_2  := CToD( "" )
  Public yes_many_uch := .f.  // �롮� �⤥����� ⮫쪮 �� "᢮���" ��०�����
  Public mem_ff_lu := 1
  // ���� �����
  Public pp_NOVOR     := 1  // ������� ����஦�������
  Public pp_KEM_NAPR  := "" // ᯨ᮪ �������� ��� ���������� ���ࠢ����� ���
  Public pp_POB_D_LEK := 1  // ������� ����筮� ����⢨� �������
  Public pp_KOD_VR    := 1  // ������� ���� ��� ��񬭮�� �⤥�����
  Public pp_TRAVMA    := 1  // ������� ��� �ࠢ��
  Public pp_NE_ZAK    := 1  // ����� �����, �᫨ �� �� �����稫 ��祭�� �� �।��饬� ����
  // ���
  Public mem_KEM_NAPR := "" // ᯨ᮪ �������� ��� ���������� ���ࠢ����� ���
  Public mem_edit_ist := 2
  Public mem_e_istbol := 1
  Public mem_op_out  := 1    // ���
  Public mem_st_kat  := 1
  Public mem_st_pov  := 1
  Public mem_st_trav := 1
  Public mem_zav_l   := 3     // ���������� �।��騩
  Public mem_pom_va   := 1    // ���
  Public mem_coplec   := 1    // ���
  Public mem_dni_vr  := 365  // ��� ᮢ���⨬��� - �� �࠭��
  Public is_uchastok := 0
  Public is_oplata := 5       // ᯮᮡ ������
  Public yes_h_otd := 1
  Public yes_vypisan := B_STANDART // ��� B_END  �� ࠡ�� � "�����襭��� ��祭��"
  Public yes_num_lu := 0      // =1 - ����� �/� ࠢ�� ������ �����
  Public yes_d_plus := "+-"   // �� 㬮�砭�� ��᫥ ��������
  Public yes_bukva := .f.     // �᫨ ࠧ�蠥��� ���� �㪢
  Public is_zf_stomat := 0    // �㡭�� ��㫠 = ���
  Public mem_ls_parakl := 0   // ������� ����������� � �㬬� ������� ���
  Public is_0_schet := 0
  Public pp_OMS := .t.    // �����뢠�� �� ��񬭮�� ����� �/� � ������ ���
  Public pp_date_OMS      // � ����� ����
  Public mem_n_V034 := 0  // ��� �ࠢ�筨�� V034
  Public mem_methodinj := 0  // ��� �ࠢ�筨�� ���� ��������
  // ��� ����� "����� ��㣨" � "���-����"
  Public delta_chek := 0  // ������� �� "lpu.ini"-䠩��
  // ��� ����� "����� ��㣨"
  Public mem_anonim := 0  // ࠡ���� � ���������
  Public glob_pl_reg := 0 // ��� ����.������, 1 - ����
  Public glob_close := 0  // �����⨥ �/���: ����� � �/���� ������, ��� �� �����
  Public glob_kassa := 0  // ��� ���ᮢ��� ������, 1 - ���ᮢ� ������: ����-��-�
  Public mem_naprvr  := 2  // ��� ������ ���
  Public mem_plsoput := 1  // ��� ������ ���
  Public mem_dogovor := "_DOGOVOR.SHB"  // ��� ������ ���
  Public mem_pl_ms   := 0  // ��� ������ ���
  Public mem_pl_sn   := 0  // ��� ������ ���
  Public mem_dms     := 0  // ��� ������ ���
  Public mem_edit_s  := 2
  // ��� ����� "��⮯����"
  Public mem_ort_na  := Space( 10 ) // ��⮯����
  Public mem_ort_sl  := Space( 10 ) // ��⮯����
  Public mem_ort_ysl := 1     // ��� // ��⮯����
  Public mem_ortotd  := 0            // ��⮯����
  Public mem_ortot1  := 1            // ��⮯����
  Public mem_ort_ms  := 2     // ��  // ��⮯����
  Public mem_ort_bp  := "ZAKAZ_BP.SMY"// ��⮯����
  Public mem_ort_pl  := "ZAKAZ_PL.SMY"// ��⮯����
  Public mem_ort_dat := 1             // ��⮯����
  Public mem_ort_f8  := "LIST_U_8.SHB" // ��⮯����
  Public mem_ortfflu := 1              // ��⮯����
  Public mem_ort_dog := Space( 3 )   // ���७�� �����. ��⮯����
  Public mem_ort_f39 := 0  // ࠡ���� � �ମ� 39

  Public MUSIC_ON_OFF := ( mem_sound == 2 )

  If ( j := search_file( "lpu" + sini, 2 ) ) != NIL
  /*i := GetIniVar( j, {{"kartoteka","uchastok",}} )
  if i[1] != NIL .and. eq_any(i[1],"1","2")
    is_uchastok := int(val(i[1]))
  endif
  i := GetIniVar( j, {{"diagnoz","bukva",}} )
  if i[1] != NIL
    yes_d_plus := i[1]
    for i := 1 to len(yes_d_plus)
      if asc(substr(yes_d_plus,i, 1)) > 64
        yes_bukva := .t. ; exit
      endif
    next
  endif
  i := GetIniVar( j, {{'uslugi',"oplata",}} )
  if i[1] != NIL
    is_oplata := int(val(i[1]))
    if !between(is_oplata, 5, 7)
      is_oplata := 5
    endif
  endif
  // ����蠥��� �믨�뢠�� ��� � �㫥��� �㬬�� (�� ��ࠪ������):
  i := GetIniVar( j, {{'uslugi',"schet_nul",}} )
  if i[1] != NIL
    is_0_schet := int(val(i[1]))
    if !between(is_0_schet, 0, 1)
      is_0_schet := 0
    endif
  endif
  i := GetIniVar( j, {{"lechenie","human_otd",}, ;
                      {"lechenie","standart",}, ;
                      {"lechenie","many_uch",}} )
  if i[1] != NIL .and. i[1] == "2"
    yes_h_otd := 2        // ࠡ�⠥� ��� �롮� �⤥�����
  endif
  if i[2] != NIL .and. i[2] == "2"
    yes_vypisan := B_END  // ��⠭������ ����� "�����襭�� ��祭��"
  endif
  if i[3] != NIL .and. i[3] == "2"
    yes_many_uch := .t.  // �롮� �⤥����� �� ��� ����㯭�� ��०�����
  endif
  //
  i := GetIniVar( j, {{"list_uch","nomer",}} )
  if i[1] != NIL
    if upper(i[1]) == "RECNO"
      yes_num_lu := 1  // ����� �/� ࠢ�� ������ �����
    endif
  endif
  // ��� ����� "����� ��㣨"
  i := GetIniVar( j, {{"lpu_plat","regi_plat",}, ;
                      {"lpu_plat","close",}, ;
                      {"lpu_plat","kassa",}} )
  if i[1] != NIL .and. i[1] == "1"
    glob_pl_reg := 1  // ������ ���⠭樮���� ������ � ����� "����� ��㣨"
  endif
  if i[2] != NIL .and. i[1] == "1"
    glob_close := 1  // �����⨥ ���� ��� - ������
  endif
  if i[3] != NIL .and. eq_any(i[3],"elves","fr")
    glob_kassa := 1   // ���ᮢ� ������: ����-��-�
    glob_pl_reg := 0  // 㡨ࠥ� ���⠭樮���� ������
  endif*/
    // ��� ����� "����� ��㣨" � "���-����"
    i := getinivar( j, { { "kassa", "delta_chek", } } )
    If i[ 1 ] != NIL
      delta_chek := Int( Val( i[ 1 ] ) )
    Endif
  Endif
  //
  If ( j := search_file( "lpu_stom" + sini ) ) != NIL
    k := getinisect( j, "��⥣���" )
    If !Empty( k )
      stm_kategor2 := {}
      For i := 1 To Len( k )
        AAdd( stm_kategor2, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
    k := getinisect( j, "�����" )
    If !Empty( k )
      stm_povod := {}
      For i := 1 To Len( k )
        AAdd( stm_povod, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
    k := getinisect( j, "�ࠢ��" )
    If !Empty( k )
      stm_travma := {}
      For i := 1 To Len( k )
        AAdd( stm_travma, { k[ i, 1 ], Int( Val( k[ i, 2 ] ) ) } )
      Next
    Endif
  Endif
  //
  Public dlo_version := 4
  Public is_r_mu := .f.
  Public gpath_reg := "" // ���� � 䠩��� R_MU.DBF
  Return Nil