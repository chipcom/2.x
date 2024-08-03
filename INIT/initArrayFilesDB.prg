#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.08.24 ���樠����஢��� ���ᨢ DBF-䠩��� ���� ������
Function init_Array_Files_DB()
  local i, arr

  Public array_files_DB := {}, array_task_DB[ 24, 2 ]

  afillall(array_task_DB, 0)
  // ��騥 �ࠢ�筨��
  aadd(array_files_DB, 'base1')
  aadd(array_files_DB, 'roles')
  aadd(array_files_DB, 'ver_base')
  aadd(array_files_DB, 'ver_updateDB')
  aadd(array_files_DB, 'mo_add')
  aadd(array_files_DB, 'organiz')
  aadd(array_files_DB, 'mo_oper')
  aadd(array_files_DB, 'mo_opern')
  aadd(array_files_DB, 's_adres')
  aadd(array_files_DB, 's_kemvyd')
  aadd(array_files_DB, 's_mr')
  aadd(array_files_DB, 'mo_kfio')
  aadd(array_files_DB, 'mo_kismo')
  aadd(array_files_DB, 'mo_hismo')
  aadd(array_files_DB, 'mo_stdds')
  aadd(array_files_DB, 'mo_schoo')
  aadd(array_files_DB, 'str_komp')
  aadd(array_files_DB, 'komitet')
  aadd(array_files_DB, 'slugba')
  aadd(array_files_DB, 'mo_su')
  aadd(array_files_DB, 'uslugi')
  aadd(array_files_DB, 'uslugi1')
  aadd(array_files_DB, 'uch_usl')
  aadd(array_files_DB, 'uch_usl1')
  aadd(array_files_DB, 'uch_pers')
  aadd(array_files_DB, 'uslugi_k')
  aadd(array_files_DB, 'uslugi1k')
  aadd(array_files_DB, 'ns_usl')
  aadd(array_files_DB, 'ns_usl_k')
  aadd(array_files_DB, 'usl_uva')
  aadd(array_files_DB, 'usl_otd')
  aadd(array_files_DB, 'u_usl_5')
  aadd(array_files_DB, 'u_usl_7')
  aadd(array_files_DB, 'mo_flis')
  // �⮬�⮫����
  aadd(array_files_DB, 'kart_st')
  aadd(array_files_DB, 'humanst')
  // ����⥪�
  aadd(array_files_DB, 'kartotek')
  aadd(array_files_DB, 'kartote_')
  aadd(array_files_DB, 'kartote2')
  aadd(array_files_DB, 'kart_et')
  aadd(array_files_DB, 'kart_inv')
  aadd(array_files_DB, 'kart_etk')
  aadd(array_files_DB, 'mo_kartp')
  aadd(array_files_DB, 'mo_krtp')
  aadd(array_files_DB, 'mo_krte')
  aadd(array_files_DB, 'mo_krtr')
  aadd(array_files_DB, 'mo_krto')
  aadd(array_files_DB, 'mo_krtf')
  aadd(array_files_DB, 'k_prim1')
  aadd(array_files_DB, 'mo_regi')
  aadd(array_files_DB, 'mo_kpred')
  aadd(array_files_DB, 'mo_kinos')
  aadd(array_files_DB, 'mo_dr00')
  aadd(array_files_DB, 'mo_dr01')
  aadd(array_files_DB, 'mo_dr01k')
  aadd(array_files_DB, 'mo_dr01m')
  aadd(array_files_DB, 'mo_dr01e')
  aadd(array_files_DB, 'mo_dr05')
  aadd(array_files_DB, 'mo_dr05k')
  aadd(array_files_DB, 'mo_dr05p')
  aadd(array_files_DB, 'mo_dr05e')
  aadd(array_files_DB, 'mo_d01')
  aadd(array_files_DB, 'mo_d01k')
  aadd(array_files_DB, 'mo_d01d')
  aadd(array_files_DB, 'mo_d01e')
  aadd(array_files_DB, 'mo_dnab')
  aadd(array_files_DB, 'msek')
  aadd(array_files_DB, 'p_priem')
  // ����� ���� ���
  aadd(array_files_DB, 'human')   ; array_task_DB[X_OMS, 1] := len(array_files_DB)
  aadd(array_files_DB, 'human_')
  aadd(array_files_DB, 'human_2')
  aadd(array_files_DB, 'human_3')
  aadd(array_files_DB, 'kartdelz')
  aadd(array_files_DB, 'mo_sprav')
  aadd(array_files_DB, 'mo_rhum')
  aadd(array_files_DB, 'mo_refr')
  aadd(array_files_DB, 'mo_os')
  aadd(array_files_DB, 'mo_hu')
  aadd(array_files_DB, 'human_u')
  aadd(array_files_DB, 'human_u_')
  aadd(array_files_DB, 'mo_hdisp')
  aadd(array_files_DB, 'mo_hod')
  aadd(array_files_DB, 'mo_hod_k')
  aadd(array_files_DB, 'mo_rak')
  aadd(array_files_DB, 'mo_rakexp')
  aadd(array_files_DB, 'mo_raks')
  aadd(array_files_DB, 'mo_raksh')
  aadd(array_files_DB, 'mo_raksherr')
  aadd(array_files_DB, 'mo_rpd')
  aadd(array_files_DB, 'mo_rpds')
  aadd(array_files_DB, 'mo_rpdsh')
  aadd(array_files_DB, 'mo_onkna')
  aadd(array_files_DB, 'mo_onksl')
  aadd(array_files_DB, 'mo_onkdi')
  aadd(array_files_DB, 'mo_onkpr')
  aadd(array_files_DB, 'mo_onkus')
  aadd(array_files_DB, 'mo_onkco')
  aadd(array_files_DB, 'mo_onkle')
  aadd(array_files_DB, 'human_im')
  aadd(array_files_DB, 'human_lek_pr')
  aadd(array_files_DB, 'human_ser_num')
  // ॥���� � ���
  aadd(array_files_DB, 'mo_rees')
  aadd(array_files_DB, 'mo_xml')
  aadd(array_files_DB, 'schet')
  aadd(array_files_DB, 'schet_')
  aadd(array_files_DB, 'schetd')  ; array_task_DB[X_OMS, 2] := len(array_files_DB)
  // ������� �࣠����樨
  aadd(array_files_DB, 'mo_uch')
  aadd(array_files_DB, 'mo_otd')
  aadd(array_files_DB, 'mo_uchvr')
  aadd(array_files_DB, 'mo_pers')
  // ���� �����
  aadd(array_files_DB, 'mo_ppst') ; array_task_DB[X_PPOKOJ, 1] := len(array_files_DB)
  aadd(array_files_DB, 'mo_pp')
  aadd(array_files_DB, 'mo_ppdia')
  aadd(array_files_DB, 'mo_ppper')
  aadd(array_files_DB, 'mo_ppadd'); array_task_DB[X_PPOKOJ, 2] := len(array_files_DB)
  // ����� ��㣨
  aadd(array_files_DB, 'hum_p')   ; array_task_DB[X_PLATN, 1] := len(array_files_DB)
  aadd(array_files_DB, 'hum_p_u')
  aadd(array_files_DB, 'plat_ms')
  aadd(array_files_DB, 'plat_vz')
  aadd(array_files_DB, 'hum_plat')
  aadd(array_files_DB, 'payments')
  aadd(array_files_DB, 'payer')
  aadd(array_files_DB, 'pu_cena')
  aadd(array_files_DB, 'pu_date')
  aadd(array_files_DB, 'p_pr_vz')
  aadd(array_files_DB, 'p_d_smo') ; array_task_DB[X_PLATN, 2] := len(array_files_DB)
  // ��⮯����
  aadd(array_files_DB, 'ortoped') ; array_task_DB[X_ORTO, 1] := len(array_files_DB)
  aadd(array_files_DB, 'ortoped1')
  aadd(array_files_DB, 'ortoped2')
  aadd(array_files_DB, 'diag_ort')
  aadd(array_files_DB, 'ort_brk')
  aadd(array_files_DB, 'orto_uva')
  aadd(array_files_DB, 'hum_ort')
  aadd(array_files_DB, 'hum_oro')
  aadd(array_files_DB, 'hum_oru')
  aadd(array_files_DB, 'hum_orpl')
  aadd(array_files_DB, 'tip_orto'); array_task_DB[X_ORTO, 2] := len(array_files_DB)
  // ���� ���
  aadd(array_files_DB, 'kas_pl')  ; array_task_DB[X_KASSA, 1] := len(array_files_DB)
  aadd(array_files_DB, 'kas_pl_u')
  aadd(array_files_DB, 'kas_ort')
  aadd(array_files_DB, 'kas_ortu')
  aadd(array_files_DB, 'kas_usl')
  aadd(array_files_DB, 'kas_usld'); array_task_DB[X_KASSA, 2] := len(array_files_DB)
  // ���
//  aadd(array_files_DB, 'mo_kekh') ; array_task_DB[X_KEK, 1] := len(array_files_DB)
//  aadd(array_files_DB, 'mo_keke')
//  aadd(array_files_DB, 'mo_kekez'); array_task_DB[X_KEK, 2] := len(array_files_DB)
  // ��ᯨ⠫�����
  aadd(array_files_DB, 'mo_nfile'); array_task_DB[X_263, 1] := len(array_files_DB)
  aadd(array_files_DB, 'mo_nfina')
  aadd(array_files_DB, 'mo_nnapr')
  aadd(array_files_DB, 'mo_n7d')
  aadd(array_files_DB, 'mo_n7in')
  aadd(array_files_DB, 'mo_n7out'); array_task_DB[X_263, 2] := len(array_files_DB)
  //
  // �ࠢ�� ��� ���
  aadd(array_files_DB, 'register_fns')
  aadd(array_files_DB, 'reg_link_fns')
  aadd(array_files_DB, 'reg_xml_fns')
  aadd(array_files_DB, 'reg_xml_link_fns')


  if glob_mo[_MO_KOD_TFOMS] == kod_VOUNC  // ��� �����
    arr := { 'vouncmnn', 'vounctrn', 'vouncnaz', 'vouncrec' }
    for i := 1 to len( arr )
      aadd( array_files_DB, arr[ i ] )
    next
  endif
  return NIL
