#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 02.08.22 ���������� ��� ।���஢���� ���� (���� ���)
Function oms_sluch(Loc_kod, kod_kartotek)
  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)
  Static SKOD_DIAG := '     ',  st_l_z := 1, st_N_DATA, st_K_DATA, st_rez_gist, ;
         st_vrach := 0, st_profil := 0, st_profil_k := 0, st_rslt := 0, st_ishod := 0, st_povod := 9
  Static menu_bolnich := {{'���', 0}, {'�� ', 1}, {'���', 2}}

  Local bg := {|o,k| get_MKB10(o,k,.t.) }, ;
        buf, tmp_color := setcolor(),  a_smert := {}, ;
        p_uch_doc := '@!',  pic_diag := '@K@!', ;
        i, colget_menu := 'R/W',  colgetImenu := 'R/BG', ;
        pos_read := 0, k_read := 0, count_edit := 0, ;
        tmp_help := chm_help_code, fl_write_sluch := .f., when_uch_doc := .t.
  Local mm_reg_lech := {{'�᭮���', 0}, {'�������⥫��', 9}}
  local mWeight := 0
  local oldPictureTalon := '@S12'
  local newPictureTalon := '@S 99.9999.99999.999'
  
  if len(glob_otd) > 2 .and. glob_otd[3] == 4 // ᪮�� ������
    return oms_sluch_SMP(Loc_kod, kod_kartotek, TIP_LU_SMP)
  elseif len(glob_otd) > 3
    if eq_any(glob_otd[4], TIP_LU_SMP, TIP_LU_NMP) // ᪮�� ������ (���⫮���� ����樭᪠� ������)
      return oms_sluch_SMP(Loc_kod, kod_kartotek, glob_otd[4])
    elseif eq_any(glob_otd[4], TIP_LU_DDS, TIP_LU_DDSOP) // ��ᯠ��ਧ��� ���
      return oms_sluch_DDS(glob_otd[4], Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_DVN   // ��ᯠ��ਧ��� ���᫮�� ��ᥫ����
      return oms_sluch_DVN(Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_PN    // ���ᬮ��� ��ᮢ��襭����⭨�
      return oms_sluch_PN(Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_PREDN // �।���⥫�� �ᬮ��� ��ᮢ��襭����⭨�
      return func_error(4, '� 2018 ���� �।���⥫�� �ᬮ��� ��ᮢ��襭����⭨� �� �஢������')
    elseif glob_otd[4] == TIP_LU_PERN  // ��ਮ���᪨� �ᬮ��� ��ᮢ��襭����⭨�
      return func_error(4, '� 2018 ���� ��ਮ���᪨� �ᬮ��� ��ᮢ��襭����⭨� �� �஢������')
    elseif glob_otd[4] == TIP_LU_PREND // �७�⠫쭠� �������⨪�
      return oms_sluch_PrenD(Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_G_CIT // ������⭠� �⮫���� ࠪ� 襩�� ��⪨
      return oms_sluch_g_cit(Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_DVN_COVID // 㣫㡫����� ��ᯠ��ਧ��� COVID
      return oms_sluch_DVN_COVID(Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_MED_REAB // ���㫠�ୠ� ����樭᪠� ॠ�������
      return oms_sluch_MED_REAB(Loc_kod, kod_kartotek)
    elseif glob_otd[4] == TIP_LU_ONKO_DISP // ���⠭���� �� ��ᯠ���� ��� ������樥⮢ � �����������
      return oms_sluch_ONKO_DISP(Loc_kod, kod_kartotek)
    else  // �᭮���� ��� ���� ���
      return oms_sluch_main(Loc_kod, kod_kartotek)
    endif
  endif

  return nil
