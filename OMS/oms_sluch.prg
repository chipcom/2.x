#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 03.03.24 ᥫ���� ��� ���������� ��� ।���஢���� ��砥� (���⮢ ���)
Function oms_sluch( Loc_kod, kod_kartotek )

  // Loc_kod - ��� �� �� human.dbf (�᫨ =0 - ���������� ���� ���)
  // kod_kartotek - ��� �� �� kartotek.dbf (�᫨ =0 - ���������� � ����⥪�)

  If Len( glob_otd ) > 2 .and. glob_otd[ 3 ] == 4 // ᪮�� ������
    Return oms_sluch_smp( Loc_kod, kod_kartotek, TIP_LU_SMP )
  Elseif Len( glob_otd ) > 3
    If eq_any( glob_otd[ 4 ], TIP_LU_SMP, TIP_LU_NMP ) // ᪮�� ������ (���⫮���� ����樭᪠� ������)
      Return oms_sluch_smp( Loc_kod, kod_kartotek, glob_otd[ 4 ] )
    Elseif eq_any( glob_otd[ 4 ], TIP_LU_DDS, TIP_LU_DDSOP ) // ��ᯠ��ਧ��� ���
      Return oms_sluch_dds( glob_otd[ 4 ], Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_DVN   // ��ᯠ��ਧ��� ���᫮�� ��ᥫ����
      Return oms_sluch_dvn( Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_PN    // ���ᬮ��� ��ᮢ��襭����⭨�
      Return oms_sluch_pn( Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_PREDN // �।���⥫�� �ᬮ��� ��ᮢ��襭����⭨�
      Return func_error( 4, '� 2018 ���� �।���⥫�� �ᬮ��� ��ᮢ��襭����⭨� �� �஢������' )
    Elseif glob_otd[ 4 ] == TIP_LU_PERN  // ��ਮ���᪨� �ᬮ��� ��ᮢ��襭����⭨�
      Return func_error( 4, '� 2018 ���� ��ਮ���᪨� �ᬮ��� ��ᮢ��襭����⭨� �� �஢������' )
    Elseif glob_otd[ 4 ] == TIP_LU_PREND // �७�⠫쭠� �������⨪�
      Return oms_sluch_prend( Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_G_CIT // ������⭠� �⮫���� ࠪ� 襩�� ��⪨
      Return oms_sluch_g_cit( Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_DVN_COVID // 㣫㡫����� ��ᯠ��ਧ��� COVID
      Return oms_sluch_dvn_covid( Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_MED_REAB // ���㫠�ୠ� ����樭᪠� ॠ�������
      Return oms_sluch_med_reab( Loc_kod, kod_kartotek )
    Elseif glob_otd[ 4 ] == TIP_LU_ONKO_DISP // ���⠭���� �� ��ᯠ���� ��� ������樥⮢ � �����������
      Return oms_sluch_onko_disp( Loc_kod, kod_kartotek )
    Else  // �᭮���� ��� ���� ���
      Return oms_sluch_main( Loc_kod, kod_kartotek )
    Endif
  Endif

  Return Nil
