#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

***** 29.03.21 ᮧ���� 䠩� �ਯ�᭮�� ��ᥫ���� � �����ࠢ
Function kartotekToExcel()
  local name_file := '��樥���'
  local name_file_full := name_file + '.xlsx'

  // if (dCreate := input_value( 20, 9, 22, 70, color1, ;
  //     '���, �� ������ ����室��� ������� ���ଠ��', ;
  //     sys_date)) != nil

  exportKartExcel(hb_OemToAnsi(name_file_full))
  SaveTo(cur_dir + name_file_full)
  // endif

  return nil

